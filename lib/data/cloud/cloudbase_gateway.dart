import 'package:cloudbase_flutter/cloudbase_flutter.dart';

import '../local/pending_change.dart';

enum CloudStatus {
  success,
  unauthenticated,
  offline,
  conflict,
  permissionDenied,
}

class CloudResult<T> {
  const CloudResult(this.status, [this.data]);
  final CloudStatus status;
  final T? data;
  bool get isSuccess => status == CloudStatus.success;
}

class CloudTransportError implements Exception {
  const CloudTransportError(this.status);
  final CloudStatus status;
}

abstract class CloudTransport {
  Future<String?> signUp(String email, String password);
  Future<String?> signIn(String email, String password);
  Future<String?> currentUser();
  Future<void> signOut() async {}
  Future<Map<String, dynamic>> command(Map<String, dynamic> data);
}

class CloudGateway {
  CloudGateway(this.transport);
  final CloudTransport transport;

  Future<CloudResult<String>> signUp(String email, String password) =>
      _attempt(() => transport.signUp(email, password));

  Future<CloudResult<String>> verifyRegistration(String code) {
    final current = transport;
    if (current is! CloudBaseTransport) {
      return Future.value(const CloudResult(CloudStatus.unauthenticated));
    }
    return _attempt(() => current.verifyRegistration(code));
  }

  Future<CloudResult<String>> signIn(String email, String password) =>
      _attempt(() => transport.signIn(email, password));

  Future<void> signOut() => transport.signOut();

  Future<CloudResult<String>> currentUser() =>
      _attempt(() => transport.currentUser());

  Future<CloudResult<Map<String, dynamic>>> pullSince(String? cursor) =>
      _command('pull', {'cursor': cursor});

  Future<CloudResult<Map<String, dynamic>>> pushChanges(
    List<Map<String, dynamic>> changes,
  ) => _command('push', {'changes': changes});

  Future<CloudResult<Map<String, dynamic>>> pushPending(
    List<PendingOperation> changes,
  ) => pushChanges([
    for (final change in changes)
      {
        'operationId': change.id,
        'ownerId': change.ownerId,
        'kind': change.kind,
        'recordId': change.recordId,
        'payload': change.payload,
      },
  ]);

  Future<CloudResult<Map<String, dynamic>>> inspectTimer() =>
      _command('inspect', {});
  Future<CloudResult<Map<String, dynamic>>> claimTimer(
    Map<String, dynamic> snapshot,
    String operationId,
  ) => _command('claim', {'snapshot': snapshot, 'operationId': operationId});

  Future<CloudResult<Map<String, dynamic>>> updateTimer(
    Map<String, dynamic> snapshot,
    int expectedRevision,
  ) => _command('update', {
    'snapshot': snapshot,
    'expectedRevision': expectedRevision,
    'operationId': 'update-$expectedRevision',
  });

  Future<CloudResult<Map<String, dynamic>>> releaseTimer(
    String operationId, {
    String? startedAt,
  }) =>
      _command('release', {'operationId': operationId, 'startedAt': startedAt});

  Future<CloudResult<T>> _attempt<T>(Future<T?> Function() action) async {
    try {
      final result = await action();
      return result == null
          ? const CloudResult(CloudStatus.unauthenticated)
          : CloudResult(CloudStatus.success, result);
    } on CloudTransportError catch (error) {
      return CloudResult(error.status);
    } on Exception {
      return const CloudResult(CloudStatus.offline);
    }
  }

  Future<CloudResult<Map<String, dynamic>>> _command(
    String action,
    Map<String, dynamic> fields,
  ) async {
    try {
      final userId = await transport.currentUser();
      if (userId == null) return const CloudResult(CloudStatus.unauthenticated);
      final response = await transport.command({'action': action, ...fields});
      final statusName = response['status'] as String? ?? 'offline';
      final status = CloudStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => CloudStatus.offline,
      );
      return CloudResult(status, response);
    } on CloudTransportError catch (error) {
      return CloudResult(error.status);
    } on Exception {
      return const CloudResult(CloudStatus.offline);
    }
  }
}

class CloudBaseTransport implements CloudTransport {
  CloudBaseTransport(this.app);
  final CloudBase app;
  Future<SignInRes> Function(VerifyOtpParams)? _verifyRegistration;

  static Future<CloudBaseTransport> connect({
    String environmentId = const String.fromEnvironment('CLOUDBASE_ENV'),
    String region = const String.fromEnvironment(
      'CLOUDBASE_REGION',
      defaultValue: 'ap-shanghai',
    ),
  }) async {
    if (environmentId.isEmpty) {
      throw StateError('CLOUDBASE_ENV is required for online accounts');
    }
    return CloudBaseTransport(
      await CloudBase.init(env: environmentId, region: region),
    );
  }

  @override
  Future<String?> signUp(String email, String password) async {
    final response = await app.auth.signUp(
      SignUpReq(email: email, password: password),
    );
    if (!response.isSuccess) {
      throw const CloudTransportError(CloudStatus.unauthenticated);
    }
    _verifyRegistration = response.data?.verifyOtp;
    return response.data?.user?.id ?? 'verificationRequired';
  }

  Future<String?> verifyRegistration(String code) async {
    final verify = _verifyRegistration;
    if (verify == null) throw StateError('No registration to verify');
    final response = await verify(VerifyOtpParams(token: code));
    if (!response.isSuccess) {
      throw const CloudTransportError(CloudStatus.unauthenticated);
    }
    return response.data?.user?.id;
  }

  @override
  Future<String?> signIn(String email, String password) async {
    final response = await app.auth.signInWithPassword(
      SignInWithPasswordReq(email: email, password: password),
    );
    if (!response.isSuccess) {
      throw const CloudTransportError(CloudStatus.unauthenticated);
    }
    return response.data?.user?.id;
  }

  @override
  Future<void> signOut() async {
    await app.auth.signOut();
  }

  @override
  Future<String?> currentUser() async {
    final response = await app.auth.getUser();
    return response.isSuccess ? response.data?.user?.id : null;
  }

  @override
  Future<Map<String, dynamic>> command(Map<String, dynamic> data) async {
    final response = await app.callFunction(name: 'timer-command', data: data);
    if (!response.isSuccess) {
      throw const CloudTransportError(CloudStatus.offline);
    }
    final payload = response.result;
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw const CloudTransportError(CloudStatus.offline);
  }
}
