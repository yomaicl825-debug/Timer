import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../sync/sync_conflict.dart';

import '../../domain/records/session.dart';
import '../../domain/records/task.dart';
import '../../domain/timer/timer_state.dart';
import 'app_database.dart';
import 'pending_change.dart';

class LocalRepository {
  LocalRepository(this.database, {required this.ownerId}) {
    if (ownerId.isEmpty) throw ArgumentError('Owner ID is required');
  }

  final AppDatabase database;
  final String ownerId;

  Future<void> _queue(
    String id,
    String kind,
    String recordId,
    String payload,
  ) => database
      .into(database.pendingChanges)
      .insert(
        PendingChangesCompanion.insert(
          id: id,
          ownerId: ownerId,
          kind: kind,
          recordId: recordId,
          payload: payload,
          createdAt: DateTime.now().toUtc(),
        ),
      );

  Future<void> upsertTask(
    TaskRecord task, {
    required String operationId,
  }) async {
    if (task.ownerId != ownerId) throw StateError('Wrong account');
    await database.transaction(() async {
      await database
          .into(database.taskEntries)
          .insertOnConflictUpdate(
            TaskEntriesCompanion.insert(
              id: task.id,
              ownerId: ownerId,
              name: task.name,
              normalizedName: task.normalizedName,
              deletedAt: Value(task.deletedAt),
            ),
          );
      await _queue(
        operationId,
        'task',
        task.id,
        jsonEncode({
          'id': task.id,
          'ownerId': ownerId,
          'name': task.name,
          'deletedAt': task.deletedAt?.toIso8601String(),
        }),
      );
    });
  }

  Future<List<TaskRecord>> getTasks() async {
    final rows = await (database.select(
      database.taskEntries,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    return [
      for (final row in rows)
        TaskRecord(
          id: row.id,
          ownerId: row.ownerId,
          name: row.name,
          deletedAt: row.deletedAt,
        ),
    ];
  }

  Stream<List<TaskRecord>> watchTasks() =>
      (database.select(
        database.taskEntries,
      )..where((row) => row.ownerId.equals(ownerId))).watch().map(
        (rows) => [
          for (final row in rows)
            TaskRecord(
              id: row.id,
              ownerId: row.ownerId,
              name: row.name,
              deletedAt: row.deletedAt,
            ),
        ],
      );

  Future<void> upsertSession(
    FocusSession session, {
    required String operationId,
  }) async {
    if (session.ownerId != ownerId) throw StateError('Wrong account');
    final payload = _encodeSession(session);
    await database.transaction(() async {
      await database
          .into(database.sessionEntries)
          .insertOnConflictUpdate(
            SessionEntriesCompanion.insert(
              id: session.id,
              ownerId: ownerId,
              taskId: Value(session.taskId),
              payload: payload,
              deletedAt: Value(session.deletedAt),
            ),
          );
      await _queue(operationId, 'session', session.id, payload);
    });
  }

  Future<List<FocusSession>> getSessions() async {
    final rows = await (database.select(
      database.sessionEntries,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    return [for (final row in rows) _decodeSession(row.payload)];
  }

  Stream<List<FocusSession>> watchSessions() =>
      (database.select(database.sessionEntries)
            ..where((row) => row.ownerId.equals(ownerId)))
          .watch()
          .map((rows) => [for (final row in rows) _decodeSession(row.payload)]);

  Future<void> saveTimer(
    TimerState state, {
    required String operationId,
  }) async {
    final payload = _encodeTimer(state);
    await database.transaction(() async {
      await database
          .into(database.timerSnapshots)
          .insertOnConflictUpdate(
            TimerSnapshotsCompanion.insert(ownerId: ownerId, payload: payload),
          );
      await _queue(operationId, 'timer', ownerId, payload);
    });
  }

  Future<void> finishTimer(
    TimerState ended,
    FocusSession session, {
    required String sessionOperationId,
    required String timerOperationId,
    bool queueCloudRelease = false,
  }) async {
    if (session.ownerId != ownerId) throw StateError('Wrong account');
    await database.transaction(() async {
      await upsertSession(session, operationId: sessionOperationId);
      await saveTimer(ended, operationId: timerOperationId);
      if (queueCloudRelease) {
        await database
            .into(database.settingEntries)
            .insertOnConflictUpdate(
              SettingEntriesCompanion.insert(
                ownerId: ownerId,
                key: 'cloudRelease:${ended.startedAt.microsecondsSinceEpoch}',
                value: ended.startedAt.toIso8601String(),
              ),
            );
      }
    });
  }

  Future<Map<String, String>> pendingCloudReleases() async {
    final rows =
        await (database.select(database.settingEntries)..where(
              (entry) =>
                  entry.ownerId.equals(ownerId) &
                  entry.key.like('cloudRelease:%'),
            ))
            .get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> acknowledgeCloudRelease(String key) async {
    await (database.delete(database.settingEntries)..where(
          (entry) => entry.ownerId.equals(ownerId) & entry.key.equals(key),
        ))
        .go();
  }

  Future<void> checkpointTimer(TimerState state) async {
    await database
        .into(database.timerSnapshots)
        .insertOnConflictUpdate(
          TimerSnapshotsCompanion.insert(
            ownerId: ownerId,
            payload: _encodeTimer(state),
          ),
        );
  }

  Future<TimerState?> loadTimer() async {
    final row = await (database.select(
      database.timerSnapshots,
    )..where((row) => row.ownerId.equals(ownerId))).getSingleOrNull();
    return row == null ? null : _decodeTimer(row.payload);
  }

  Future<List<PendingOperation>> pendingChanges() async {
    final rows = await (database.select(
      database.pendingChanges,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return [
      for (final row in rows)
        PendingOperation(
          id: row.id,
          ownerId: row.ownerId,
          kind: row.kind,
          recordId: row.recordId,
          payload: row.payload,
          createdAt: row.createdAt,
        ),
    ];
  }

  Future<void> acknowledgeChange(String id) async {
    await (database.delete(
      database.pendingChanges,
    )..where((row) => row.ownerId.equals(ownerId) & row.id.equals(id))).go();
  }

  Future<void> resolveRevisionConflict(
    RevisionConflict conflict, {
    required bool keepLocal,
    required String operationId,
  }) async {
    await database.transaction(() async {
      final row =
          await (database.select(database.sessionEntries)..where(
                (entry) =>
                    entry.ownerId.equals(ownerId) &
                    entry.id.equals(conflict.sessionId),
              ))
              .getSingleOrNull();
      if (row == null || row.payload != _encodeSession(conflict.local)) {
        throw StateError('Session changed after conflict was shown');
      }
      final pending =
          await (database.select(database.pendingChanges)..where(
                (entry) =>
                    entry.ownerId.equals(ownerId) &
                    entry.kind.equals('session') &
                    entry.recordId.equals(conflict.sessionId),
              ))
              .get();
      if (pending
              .map((entry) => entry.id)
              .toSet()
              .difference(conflict.pendingOperationIds.toSet())
              .isNotEmpty ||
          conflict.pendingOperationIds
              .toSet()
              .difference(pending.map((entry) => entry.id).toSet())
              .isNotEmpty) {
        throw StateError('Pending edits changed after conflict was shown');
      }
      for (final id in conflict.pendingOperationIds) {
        await acknowledgeChange(id);
      }
      if (keepLocal) {
        await upsertSession(
          conflict.local.copyWith(revision: conflict.remote.revision + 1),
          operationId: operationId,
        );
      } else {
        await importRemoteRecord(conflict.remoteRecord);
      }
    });
  }

  Future<void> setSetting(
    String key,
    String value, {
    required String operationId,
  }) async {
    if (key.isEmpty) throw ArgumentError('Setting key is required');
    final payload = jsonEncode({'key': key, 'value': value});
    await database.transaction(() async {
      await database
          .into(database.settingEntries)
          .insertOnConflictUpdate(
            SettingEntriesCompanion.insert(
              ownerId: ownerId,
              key: key,
              value: value,
            ),
          );
      await _queue(operationId, 'setting', key, payload);
    });
  }

  Future<Map<String, String>> getSettings() async {
    final rows = await (database.select(
      database.settingEntries,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> importRemoteRecord(Map<String, dynamic> record) async {
    if (record['ownerId'] != ownerId) throw StateError('Wrong account');
    final kind = record['kind'] as String;
    final recordId = record['recordId'] as String;
    final pending =
        await (database.select(database.pendingChanges)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.kind.equals(kind) &
                  row.recordId.equals(recordId),
            ))
            .get();
    if (pending.isNotEmpty) return;
    final payload = record['payload'] as String;
    if (kind == 'task') {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['ownerId'] != ownerId) throw StateError('Wrong account');
      final task = TaskRecord(
        id: data['id'] as String,
        ownerId: ownerId,
        name: data['name'] as String,
        deletedAt: data['deletedAt'] == null
            ? null
            : DateTime.parse(data['deletedAt'] as String),
      );
      await database
          .into(database.taskEntries)
          .insertOnConflictUpdate(
            TaskEntriesCompanion.insert(
              id: task.id,
              ownerId: ownerId,
              name: task.name,
              normalizedName: task.normalizedName,
              deletedAt: Value(task.deletedAt),
            ),
          );
    } else if (kind == 'session') {
      final session = _decodeSession(payload);
      if (session.ownerId != ownerId) throw StateError('Wrong account');
      final old =
          await (database.select(database.sessionEntries)..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.id.equals(session.id),
              ))
              .getSingleOrNull();
      if (old != null &&
          _decodeSession(old.payload).revision > session.revision) {
        return;
      }
      await database
          .into(database.sessionEntries)
          .insertOnConflictUpdate(
            SessionEntriesCompanion.insert(
              id: session.id,
              ownerId: ownerId,
              taskId: Value(session.taskId),
              payload: payload,
              deletedAt: Value(session.deletedAt),
            ),
          );
    } else if (kind == 'timer') {
      await database
          .into(database.timerSnapshots)
          .insertOnConflictUpdate(
            TimerSnapshotsCompanion.insert(ownerId: ownerId, payload: payload),
          );
    } else if (kind == 'setting') {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      await database
          .into(database.settingEntries)
          .insertOnConflictUpdate(
            SettingEntriesCompanion.insert(
              ownerId: ownerId,
              key: data['key'] as String,
              value: data['value'] as String,
            ),
          );
    }
  }

  Future<void> saveConflict(SyncConflict conflict) => database
      .into(database.conflictEntries)
      .insert(
        ConflictEntriesCompanion.insert(
          id: conflict.id,
          ownerId: ownerId,
          firstSessionId: conflict.firstSessionId,
          secondSessionId: conflict.secondSessionId,
          winningSessionId: Value(conflict.winningSessionId),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<List<SyncConflict>> unresolvedConflicts() async {
    final rows =
        await (database.select(database.conflictEntries)..where(
              (row) =>
                  row.ownerId.equals(ownerId) & row.winningSessionId.isNull(),
            ))
            .get();
    return [
      for (final row in rows)
        SyncConflict(
          id: row.id,
          firstSessionId: row.firstSessionId,
          secondSessionId: row.secondSessionId,
          winningSessionId: row.winningSessionId,
        ),
    ];
  }

  Future<void> resolveConflict(
    SyncConflict conflict,
    String winningSessionId,
  ) async {
    if (winningSessionId != conflict.firstSessionId &&
        winningSessionId != conflict.secondSessionId) {
      throw ArgumentError('Winner must belong to conflict');
    }
    final losingId = winningSessionId == conflict.firstSessionId
        ? conflict.secondSessionId
        : conflict.firstSessionId;
    await database.transaction(() async {
      final sessions = await getSessions();
      final loser = sessions.singleWhere((s) => s.id == losingId);
      final winner = sessions.singleWhere((s) => s.id == winningSessionId);
      final rejected = loser.copyWith(
        deletedAt: DateTime.now().toUtc(),
        revision: loser.revision + 1,
      );
      for (final session in [rejected, winner]) {
        final payload = _encodeSession(session);
        await database
            .into(database.sessionEntries)
            .insertOnConflictUpdate(
              SessionEntriesCompanion.insert(
                id: session.id,
                ownerId: ownerId,
                taskId: Value(session.taskId),
                payload: payload,
                deletedAt: Value(session.deletedAt),
              ),
            );
        await _queue(const Uuid().v4(), 'session', session.id, payload);
      }
      await (database.update(database.conflictEntries)..where(
            (row) => row.id.equals(conflict.id) & row.ownerId.equals(ownerId),
          ))
          .write(
            ConflictEntriesCompanion(winningSessionId: Value(winningSessionId)),
          );
    });
  }

  static Map<String, Object> _segment(FocusSegment segment) => {
    'start': segment.start.toIso8601String(),
    'end': segment.end.toIso8601String(),
  };

  static FocusSegment _readSegment(dynamic value) {
    final map = value as Map<String, dynamic>;
    return FocusSegment(
      start: DateTime.parse(map['start'] as String),
      end: DateTime.parse(map['end'] as String),
    );
  }

  static String _encodeSession(FocusSession session) => jsonEncode({
    'id': session.id,
    'ownerId': session.ownerId,
    'taskId': session.taskId,
    'mode': session.mode.name,
    'segments': session.focusSegments.map(_segment).toList(),
    'creditedOverride': session.creditedOverride?.inMicroseconds,
    'revision': session.revision,
    'deletedAt': session.deletedAt?.toIso8601String(),
  });

  static FocusSession _decodeSession(String payload) {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    return FocusSession(
      id: data['id'] as String,
      ownerId: data['ownerId'] as String,
      taskId: data['taskId'] as String?,
      mode: TimerMode.values.byName(data['mode'] as String),
      focusSegments: (data['segments'] as List).map(_readSegment).toList(),
      creditedOverride: data['creditedOverride'] == null
          ? null
          : Duration(microseconds: data['creditedOverride'] as int),
      revision: data['revision'] as int,
      deletedAt: data['deletedAt'] == null
          ? null
          : DateTime.parse(data['deletedAt'] as String),
    );
  }

  static String _encodeTimer(TimerState state) => jsonEncode({
    'mode': state.mode.name,
    'phase': state.phase.name,
    'taskId': state.taskId,
    'startedAt': state.startedAt.toIso8601String(),
    'lastObservedAt': state.lastObservedAt.toIso8601String(),
    'activeSegmentStartedAt': state.activeSegmentStartedAt?.toIso8601String(),
    'deadlineAt': state.deadlineAt?.toIso8601String(),
    'pausedRemaining': state.pausedRemaining?.inMicroseconds,
    'focusDuration': state.focusDuration?.inMicroseconds,
    'restDuration': state.restDuration?.inMicroseconds,
    'round': state.round,
    'focusSegments': state.focusSegments.map(_segment).toList(),
    'clockWarning': state.clockWarning,
    'endedAt': state.endedAt?.toIso8601String(),
  });

  static TimerState _decodeTimer(String payload) {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    DateTime? date(String key) =>
        data[key] == null ? null : DateTime.parse(data[key] as String);
    Duration? duration(String key) =>
        data[key] == null ? null : Duration(microseconds: data[key] as int);
    return TimerState(
      mode: TimerMode.values.byName(data['mode'] as String),
      phase: TimerPhase.values.byName(data['phase'] as String),
      taskId: data['taskId'] as String?,
      startedAt: date('startedAt')!,
      lastObservedAt: date('lastObservedAt')!,
      activeSegmentStartedAt: date('activeSegmentStartedAt'),
      deadlineAt: date('deadlineAt'),
      pausedRemaining: duration('pausedRemaining'),
      focusDuration: duration('focusDuration'),
      restDuration: duration('restDuration'),
      round: data['round'] as int,
      focusSegments: (data['focusSegments'] as List).map(_readSegment).toList(),
      clockWarning: data['clockWarning'] as bool,
      endedAt: date('endedAt'),
    );
  }
}
