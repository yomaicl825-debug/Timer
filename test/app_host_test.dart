import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/app_host.dart';
import 'package:study_timer/data/cloud/cloudbase_gateway.dart';
import 'package:study_timer/data/local/app_database.dart';
import 'package:study_timer/data/local/local_repository.dart';
import 'package:study_timer/domain/records/task.dart';

void main() {
  test('second online timer claim is rejected before local start', () async {
    final services = AppServices(
      ownerId: 'student',
      cloud: CloudGateway(_FakeTransport(claimStatus: 'conflict')),
    );
    await expectLater(services.startElapsed(null), throwsStateError);
    expect(services.activeTimer, isNull);
  });
  test(
    'offline claim is explicit while permission denial blocks start',
    () async {
      final offline = AppServices(
        ownerId: 'student',
        cloud: CloudGateway(_FakeTransport(claimStatus: 'offline')),
      );
      await offline.startElapsed(null);
      expect(offline.syncMessage, '离线计时，稍后同步');
      final denied = AppServices(
        ownerId: 'student',
        cloud: CloudGateway(_FakeTransport(claimStatus: 'permissionDenied')),
      );
      await expectLater(denied.startElapsed(null), throwsStateError);
      expect(denied.activeTimer, isNull);
    },
  );
  test('online timer sends revisioned state updates after pause', () async {
    var now = DateTime.utc(2026, 1, 1);
    final transport = _FakeTransport();
    final services = AppServices(
      ownerId: 'student',
      cloud: CloudGateway(transport),
      clock: () => now,
    );
    await services.startElapsed(null);
    now = now.add(const Duration(minutes: 5));
    await services.pauseTimer();
    expect(transport.actions.where((action) => action == 'update').length, 2);
    expect(transport.expectedRevisions, [1, 2]);
  });
  test('ended timer retries release only for its own cloud lock', () async {
    final transport = _ReleaseTransport();
    final services = AppServices(
      ownerId: 'student',
      cloud: CloudGateway(transport),
      clock: () => DateTime.utc(2026, 1, 1),
    );
    await services.startElapsed(null);
    await services.endTimer();
    expect(transport.releaseAttempts, 1);
    transport.offline = false;
    await services.releaseCloudLockIfEnded();
    expect(transport.releaseAttempts, 2);
    transport.active = true;
    transport.startedAt = DateTime.utc(2026, 1, 2).toIso8601String();
    await services.releaseCloudLockIfEnded();
    expect(transport.releaseAttempts, 2);
  });
  test(
    'offline new timer releases old lock before claiming on reconnect',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = LocalRepository(db, ownerId: 'student');
      final transport = _ReleaseTransport();
      var now = DateTime.utc(2026, 1, 1);
      final services = AppServices(
        repository: repo,
        ownerId: 'student',
        cloud: CloudGateway(transport),
        clock: () => now,
      );
      await services.startElapsed(null);
      now = now.add(const Duration(minutes: 10));
      transport.networkDown = true;
      await services.endTimer();
      expect((await repo.pendingCloudReleases()).length, 1);
      now = now.add(const Duration(minutes: 1));
      await services.startElapsed(null);
      transport.networkDown = false;
      transport.offline = false;
      await services.reconcileCloudLock();
      expect(await repo.pendingCloudReleases(), isEmpty);
      expect(transport.claims, 2);
      expect(transport.releaseAttempts, 1);
      expect(
        transport.startedAt,
        services.activeTimer!.startedAt.toIso8601String(),
      );
      await db.close();
    },
  );
  testWidgets(
    'sign-in switches to isolated account records and sign-out restores local',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final local = LocalRepository(db, ownerId: 'local');
      await local.upsertTask(
        TaskRecord(id: 'private', ownerId: 'local', name: 'Local notes'),
        operationId: 'local-op',
      );
      final user = LocalRepository(db, ownerId: 'student');
      await user.upsertTask(
        TaskRecord(id: 'cloud', ownerId: 'student', name: 'Exam'),
        operationId: 'cloud-op',
      );
      final closedOwners = <String>[];
      final services = AppServices(
        repository: local,
        ownerId: 'local',
        nativeWindows: false,
      );
      await services.load();
      await tester.pumpWidget(
        AppHost(
          database: db,
          initialServices: services,
          gateway: CloudGateway(_FakeTransport()),
          closeAccountWindows: (ownerId) async => closedOwners.add(ownerId),
        ),
      );
      expect(find.text('Local notes'), findsOneWidget);
      await tester.tap(find.text('账号'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'student@example.com',
      );
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.text('登录').last);
      await tester.pumpAndSettle();
      expect(find.text('Exam'), findsOneWidget);
      expect(find.text('Local notes'), findsNothing);
      await tester.tap(find.text('退出账号'));
      await tester.pumpAndSettle();
      expect(find.text('Local notes'), findsOneWidget);
      expect(find.text('Exam'), findsNothing);
      expect(closedOwners, ['local', 'student']);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}

class _FakeTransport extends CloudTransport {
  _FakeTransport({this.claimStatus = 'success'});
  final String claimStatus;
  final actions = <String>[];
  final expectedRevisions = <int>[];
  @override
  Future<String?> signIn(String email, String password) async => 'student';
  @override
  Future<String?> signUp(String email, String password) async => 'student';
  @override
  Future<String?> currentUser() async => 'student';
  @override
  Future<Map<String, dynamic>> command(Map<String, dynamic> data) async {
    final action = data['action'] as String;
    actions.add(action);
    if (action == 'claim') return {'status': claimStatus, 'revision': 1};
    if (action == 'update') {
      expectedRevisions.add(data['expectedRevision'] as int);
      return {
        'status': 'success',
        'revision': (data['expectedRevision'] as int) + 1,
      };
    }
    if (action == 'pull') {
      return {
        'status': 'success',
        'records': <Map<String, dynamic>>[],
        'hasMore': false,
      };
    }
    return {'status': 'success', 'appliedIds': <String>[]};
  }
}

class _ReleaseTransport extends CloudTransport {
  bool offline = true;
  bool networkDown = false;
  bool active = false;
  String? startedAt;
  int releaseAttempts = 0;
  int claims = 0;

  @override
  Future<String?> signIn(String email, String password) async => 'student';
  @override
  Future<String?> signUp(String email, String password) async => 'student';
  @override
  Future<String?> currentUser() async => 'student';
  @override
  Future<Map<String, dynamic>> command(Map<String, dynamic> data) async {
    if (networkDown) return {'status': 'offline'};
    switch (data['action']) {
      case 'claim':
        claims++;
        if (active) return {'status': 'conflict'};
        active = true;
        startedAt = (data['snapshot'] as Map)['startedAt'] as String;
        return {'status': 'success', 'revision': 1};
      case 'update':
        return {'status': 'success', 'revision': 2};
      case 'inspect':
        return {
          'status': 'success',
          'active': active,
          'snapshot': {'startedAt': startedAt},
        };
      case 'release':
        releaseAttempts++;
        expect(data['startedAt'], startedAt);
        if (offline) return {'status': 'offline'};
        active = false;
        return {'status': 'success'};
      default:
        return {'status': 'success'};
    }
  }
}
