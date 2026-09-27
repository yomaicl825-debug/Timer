import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/data/cloud/cloudbase_gateway.dart';
import 'package:study_timer/data/local/app_database.dart';
import 'package:study_timer/data/local/local_repository.dart';
import 'package:study_timer/data/sync/sync_coordinator.dart';
import 'package:study_timer/domain/records/session.dart';
import 'package:study_timer/domain/records/task.dart';
import 'package:study_timer/domain/timer/timer_state.dart';

class FakeSyncTransport implements CloudTransport {
  bool offline = false;
  bool failAfterApply = false;
  Map<String, dynamic>? revisionConflictRecord;
  final records = <Map<String, dynamic>>[];
  final applied = <String>{};
  final pushedRevisions = <int>[];
  @override
  Future<void> signOut() async {}

  @override
  Future<String?> currentUser() async => 'u';
  @override
  Future<String?> signIn(String email, String password) async => 'u';
  @override
  Future<String?> signUp(String email, String password) async => 'u';
  @override
  Future<Map<String, dynamic>> command(Map<String, dynamic> data) async {
    if (offline) throw const CloudTransportError(CloudStatus.offline);
    if (data['action'] == 'pull') {
      return {
        'status': 'success',
        'records': records,
        'cursor': 'cursor1',
        'hasMore': false,
      };
    }
    if (data['action'] == 'push' && revisionConflictRecord != null) {
      return {
        'status': 'conflict',
        'appliedIds': <String>[],
        'kind': 'session',
        'recordId': 'same',
        'record': revisionConflictRecord,
      };
    }
    if (data['action'] == 'push') {
      final changes = (data['changes'] as List).cast<Map<String, dynamic>>();
      for (final change in changes) {
        if (change['kind'] == 'session') {
          pushedRevisions.add(
            (jsonDecode(change['payload'] as String)
                    as Map<String, dynamic>)['revision']
                as int,
          );
        }
        applied.add(change['operationId'] as String);
      }
      if (failAfterApply) {
        failAfterApply = false;
        throw const CloudTransportError(CloudStatus.offline);
      }
      return {
        'status': 'success',
        'applied': changes.length,
        'appliedIds': changes.map((c) => c['operationId']).toList(),
      };
    }
    throw StateError('Unexpected action');
  }
}

FocusSession focus(String id, int startHour, int endHour) => FocusSession(
  id: id,
  ownerId: 'u',
  taskId: 't',
  mode: TimerMode.elapsed,
  focusSegments: [
    FocusSegment(
      start: DateTime.utc(2026, 1, 1, startHour),
      end: DateTime.utc(2026, 1, 1, endHour),
    ),
  ],
  revision: 0,
);

void main() {
  late AppDatabase db;
  late LocalRepository repo;
  late FakeSyncTransport transport;
  late SyncCoordinator sync;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LocalRepository(db, ownerId: 'u');
    transport = FakeSyncTransport();
    sync = SyncCoordinator(repo, CloudGateway(transport));
  });
  tearDown(() async => db.close());

  test('queued edits of one session upload in revision order', () async {
    await repo.upsertSession(focus('same', 0, 1), operationId: 'first');
    await repo.upsertSession(
      focus('same', 0, 1).copyWith(revision: 1),
      operationId: 'second',
    );
    await sync.syncNow();
    expect(transport.pushedRevisions, [0, 1]);
  });
  test(
    'concurrent edit is retained until user chooses remote version',
    () async {
      await repo.upsertSession(
        focus('same', 0, 1).copyWith(revision: 1),
        operationId: 'local-edit',
      );
      final remote = {
        'ownerId': 'u',
        'kind': 'session',
        'recordId': 'same',
        'payload': jsonEncode({
          'id': 'same',
          'ownerId': 'u',
          'taskId': 't',
          'mode': 'elapsed',
          'segments': [
            {
              'start': DateTime.utc(2026, 1, 1).toIso8601String(),
              'end': DateTime.utc(2026, 1, 1, 1).toIso8601String(),
            },
          ],
          'creditedOverride': const Duration(minutes: 30).inMicroseconds,
          'revision': 1,
          'deletedAt': null,
        }),
      };
      transport.revisionConflictRecord = remote;
      final report = await sync.syncNow();
      expect(report.conflicted, 1);
      expect(
        sync.revisionConflict?.remote.creditedDuration,
        const Duration(minutes: 30),
      );
      expect((await repo.pendingChanges()).length, 1);
      await sync.resolveRevisionConflict(keepLocal: false);
      expect(await repo.pendingChanges(), isEmpty);
      expect(
        (await repo.getSessions()).single.creditedDuration,
        const Duration(minutes: 30),
      );
    },
  );
  test('new edit after conflict cannot be discarded by stale choice', () async {
    await repo.upsertSession(
      focus('same', 0, 1).copyWith(revision: 1),
      operationId: 'local-edit',
    );
    transport.revisionConflictRecord = {
      'ownerId': 'u',
      'kind': 'session',
      'recordId': 'same',
      'payload': jsonEncode({
        'id': 'same',
        'ownerId': 'u',
        'taskId': 't',
        'mode': 'elapsed',
        'segments': [
          {
            'start': DateTime.utc(2026, 1, 1).toIso8601String(),
            'end': DateTime.utc(2026, 1, 1, 1).toIso8601String(),
          },
        ],
        'creditedOverride': const Duration(minutes: 30).inMicroseconds,
        'revision': 1,
        'deletedAt': null,
      }),
    };
    await sync.syncNow();
    await repo.upsertSession(
      focus('same', 0, 1).copyWith(revision: 2),
      operationId: 'new-edit',
    );
    await expectLater(
      sync.resolveRevisionConflict(keepLocal: false),
      throwsStateError,
    );
    expect((await repo.pendingChanges()).map((change) => change.id).toSet(), {
      'local-edit',
      'new-edit',
    });
    expect((await repo.getSessions()).single.revision, 2);
  });
  test('offline keeps operations queued; reconnect acknowledges', () async {
    await repo.upsertTask(
      TaskRecord(id: 't', ownerId: 'u', name: 'Math'),
      operationId: 'op1',
    );
    transport.offline = true;
    expect((await sync.syncNow()).queued, 1);
    expect((await repo.pendingChanges()).length, 1);
    transport.offline = false;
    expect((await sync.syncNow()).applied, 1);
    expect(await repo.pendingChanges(), isEmpty);
  });

  test('retry after response loss is idempotent', () async {
    await repo.upsertTask(
      TaskRecord(id: 't', ownerId: 'u', name: 'Math'),
      operationId: 'op1',
    );
    transport.failAfterApply = true;
    expect((await sync.syncNow()).queued, 1);
    expect(transport.applied, {'op1'});
    expect((await sync.syncNow()).applied, 1);
    expect(transport.applied, {'op1'});
  });

  test('remote task revision refreshes local cache', () async {
    transport.records.add({
      'ownerId': 'u',
      'kind': 'task',
      'recordId': 'remote',
      'payload': jsonEncode({
        'id': 'remote',
        'ownerId': 'u',
        'name': 'Physics',
        'deletedAt': null,
      }),
    });
    await sync.syncNow();
    expect((await repo.getTasks()).single.name, 'Physics');
    expect(await repo.pendingChanges(), isEmpty);
  });

  test('overlapping offline sessions are withheld until choice', () async {
    await repo.upsertSession(focus('local', 0, 2), operationId: 'op1');
    transport.records.add({
      'ownerId': 'u',
      'kind': 'session',
      'recordId': 'remote',
      'payload': jsonEncode({
        'id': 'remote',
        'ownerId': 'u',
        'taskId': 't',
        'mode': 'elapsed',
        'segments': [
          {
            'start': DateTime.utc(2026, 1, 1, 1).toIso8601String(),
            'end': DateTime.utc(2026, 1, 1, 3).toIso8601String(),
          },
        ],
        'creditedOverride': null,
        'revision': 0,
        'deletedAt': null,
      }),
    });
    final report = await sync.syncNow();
    expect(report.conflicted, 1);
    expect(await sync.visibleSessions(), isEmpty);
    final conflict = (await sync.unresolvedConflicts()).single;
    await sync.resolveOverlap(conflict.id, 'local');
    expect((await sync.visibleSessions()).single.id, 'local');
    expect((await repo.pendingChanges()).isNotEmpty, isTrue);
    await sync.syncNow();
    expect(await sync.unresolvedConflicts(), isEmpty);
  });
}
