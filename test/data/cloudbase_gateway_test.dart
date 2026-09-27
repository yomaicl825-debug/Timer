import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/data/cloud/cloudbase_gateway.dart';

class FakeTransport implements CloudTransport {
  String? uid;
  bool offline = false;
  bool networkThrows = false;
  final operations = <String, Map<String, dynamic>>{};
  Map<String, dynamic>? active;
  final records = <Map<String, dynamic>>[];

  @override
  Future<void> signOut() async {}

  @override
  Future<String?> signUp(String email, String password) async => 'u';
  @override
  Future<String?> signIn(String email, String password) async {
    if (password != 'correct123') {
      throw CloudTransportError(CloudStatus.unauthenticated);
    }
    uid = 'u';
    return uid;
  }

  @override
  Future<String?> currentUser() async => uid;
  @override
  Future<Map<String, dynamic>> command(Map<String, dynamic> data) async {
    if (networkThrows) throw Exception('socket closed');
    if (offline) throw CloudTransportError(CloudStatus.offline);
    if (uid == null) throw CloudTransportError(CloudStatus.unauthenticated);
    final id = data['operationId'] as String?;
    if (id != null && operations.containsKey(id)) return operations[id]!;
    late Map<String, dynamic> result;
    switch (data['action']) {
      case 'pull':
        result = {
          'status': 'success',
          'records': records.where((r) => r['ownerId'] == uid).toList(),
          'cursor': 'next',
        };
      case 'push':
        final changes = data['changes'] as List;
        if (changes.any((c) => c['ownerId'] != uid)) {
          result = {'status': 'permissionDenied'};
        } else {
          records.addAll(changes.cast<Map<String, dynamic>>());
          result = {'status': 'success', 'applied': changes.length};
        }
      case 'claim':
        if (active != null) {
          result = {'status': 'conflict'};
        } else {
          active = data['snapshot'] as Map<String, dynamic>;
          result = {'status': 'success', 'revision': 1};
        }
      case 'update':
        result = data['expectedRevision'] == 1
            ? {'status': 'success', 'revision': 2}
            : {'status': 'conflict'};
      case 'release':
        active = null;
        result = {'status': 'success'};
      default:
        throw StateError('Unknown command');
    }
    if (id != null) operations[id] = result;
    return result;
  }
}

void main() {
  test('sign-in error is typed and unauthenticated read is denied', () async {
    final gateway = CloudGateway(FakeTransport());
    expect(
      (await gateway.signIn('a@example.com', 'wrong')).status,
      CloudStatus.unauthenticated,
    );
    expect((await gateway.pullSince(null)).status, CloudStatus.unauthenticated);
  });

  test('push rejects another owner and pull filters records', () async {
    final transport = FakeTransport()..uid = 'u';
    transport.records.add({'ownerId': 'other', 'id': 'hidden'});
    final gateway = CloudGateway(transport);
    expect(
      (await gateway.pushChanges([
        {'ownerId': 'other', 'id': 'x'},
      ])).status,
      CloudStatus.permissionDenied,
    );
    final pull = await gateway.pullSince(null);
    expect(pull.status, CloudStatus.success);
    expect((pull.data!['records'] as List), isEmpty);
  });

  test('claim is idempotent and second active timer conflicts', () async {
    final gateway = CloudGateway(FakeTransport()..uid = 'u');
    final first = await gateway.claimTimer({'mode': 'elapsed'}, 'op1');
    expect(first.status, CloudStatus.success);
    expect(
      (await gateway.claimTimer({'mode': 'elapsed'}, 'op1')).status,
      CloudStatus.success,
    );
    expect(
      (await gateway.claimTimer({'mode': 'elapsed'}, 'op2')).status,
      CloudStatus.conflict,
    );
  });

  test(
    'offline transport is reported without changing operation state',
    () async {
      final transport = FakeTransport()
        ..uid = 'u'
        ..offline = true;
      final gateway = CloudGateway(transport);
      expect((await gateway.releaseTimer('op3')).status, CloudStatus.offline);
    },
  );
  test('unexpected network exception is reported as offline', () async {
    final gateway = CloudGateway(
      FakeTransport()
        ..uid = 'u'
        ..networkThrows = true,
    );
    expect((await gateway.releaseTimer('op4')).status, CloudStatus.offline);
  });
}
