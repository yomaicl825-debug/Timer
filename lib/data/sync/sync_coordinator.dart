import 'package:uuid/uuid.dart';

import 'dart:async';
import 'dart:convert';

import '../../domain/records/session.dart';
import '../../domain/timer/timer_state.dart';
import '../cloud/cloudbase_gateway.dart';
import '../local/local_repository.dart';
import 'sync_conflict.dart';

enum SyncStatus { idle, syncing, offline, conflict, current }

class SyncReport {
  const SyncReport({
    required this.applied,
    required this.queued,
    required this.conflicted,
    this.offline = false,
  });
  final int applied;
  final int queued;
  final int conflicted;
  final bool offline;
}

class SyncCoordinator {
  SyncCoordinator(this.repository, this.cloud);
  final LocalRepository repository;
  final CloudGateway cloud;
  final StreamController<SyncStatus> _status =
      StreamController<SyncStatus>.broadcast();
  String? _cursor;
  RevisionConflict? revisionConflict;

  Stream<SyncStatus> watchStatus() => _status.stream;

  Future<SyncReport> syncNow() async {
    _status.add(SyncStatus.syncing);
    revisionConflict = null;
    var applied = 0;
    final originalSessions = await repository.getSessions();
    final pendingBefore = await repository.pendingChanges();
    var cursor = _cursor;
    while (true) {
      final pull = await cloud.pullSince(cursor);
      if (!pull.isSuccess) {
        _status.add(SyncStatus.offline);
        return SyncReport(
          applied: applied,
          queued: (await repository.pendingChanges()).length,
          conflicted: (await unresolvedConflicts()).length,
          offline: true,
        );
      }
      final data = pull.data!;
      final records = (data['records'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
      for (final record in records) {
        if (record['ownerId'] != repository.ownerId) continue;
        if (record['kind'] == 'session') {
          final incoming = _sessionFromPayload(record['payload'] as String);
          if (incoming.ownerId != repository.ownerId) continue;
          for (final local in originalSessions) {
            if (local.id == incoming.id ||
                local.deletedAt != null ||
                incoming.deletedAt != null ||
                !pendingBefore.any(
                  (change) =>
                      change.kind == 'session' && change.recordId == local.id,
                ) ||
                !_overlaps(local, incoming)) {
              continue;
            }
            final ids = [local.id, incoming.id]..sort();
            await repository.saveConflict(
              SyncConflict(
                id: '${ids[0]}:${ids[1]}',
                firstSessionId: ids[0],
                secondSessionId: ids[1],
              ),
            );
          }
        }
        await repository.importRemoteRecord(record);
      }
      cursor = data['cursor'] as String? ?? cursor;
      if (data['hasMore'] != true) break;
    }
    _cursor = cursor;
    final conflicts = await unresolvedConflicts();
    final conflictedIds = <String>{
      for (final conflict in conflicts) ...[
        conflict.firstSessionId,
        conflict.secondSessionId,
      ],
    };
    final ready =
        (await repository.pendingChanges())
            .where(
              (change) =>
                  change.kind != 'session' ||
                  !conflictedIds.contains(change.recordId),
            )
            .toList()
          ..sort((a, b) {
            final first = '${a.kind}:${a.recordId}';
            final second = '${b.kind}:${b.recordId}';
            final byRecord = first.compareTo(second);
            if (byRecord != 0) return byRecord;
            if (a.kind == 'session') {
              final firstRevision =
                  (jsonDecode(a.payload) as Map<String, dynamic>)['revision']
                      as int;
              final secondRevision =
                  (jsonDecode(b.payload) as Map<String, dynamic>)['revision']
                      as int;
              final byRevision = firstRevision.compareTo(secondRevision);
              if (byRevision != 0) return byRevision;
            }
            return a.createdAt.compareTo(b.createdAt);
          });
    var uploadFailed = false;
    for (var index = 0; index < ready.length; index += 40) {
      final end = index + 40 > ready.length ? ready.length : index + 40;
      final batch = ready.sublist(index, end);
      final result = await cloud.pushPending(batch);
      final confirmed = (result.data?['appliedIds'] as List? ?? const [])
          .cast<String>();
      for (final id in confirmed) {
        await repository.acknowledgeChange(id);
        applied++;
      }
      if (result.status == CloudStatus.conflict) {
        final remoteRecord = result.data?['record'];
        if (remoteRecord is Map && result.data?['kind'] == 'session') {
          final record = Map<String, dynamic>.from(remoteRecord);
          final sessionId = result.data!['recordId'] as String;
          final local = (await repository.getSessions()).singleWhere(
            (session) => session.id == sessionId,
          );
          revisionConflict = RevisionConflict(
            sessionId: sessionId,
            local: local,
            remote: _sessionFromPayload(record['payload'] as String),
            remoteRecord: record,
            pendingOperationIds: [
              for (final change in await repository.pendingChanges())
                if (change.kind == 'session' && change.recordId == sessionId)
                  change.id,
            ],
          );
        }
        _status.add(SyncStatus.conflict);
        break;
      }
      if (!result.isSuccess) {
        _status.add(SyncStatus.offline);
        uploadFailed = true;
        break;
      }
    }
    final queued = (await repository.pendingChanges()).length;
    _status.add(
      (conflicts.isNotEmpty || revisionConflict != null)
          ? SyncStatus.conflict
          : queued == 0
          ? SyncStatus.current
          : SyncStatus.offline,
    );
    return SyncReport(
      applied: applied,
      queued: queued,
      conflicted: conflicts.length + (revisionConflict == null ? 0 : 1),
      offline: uploadFailed,
    );
  }

  Future<void> resolveRevisionConflict({required bool keepLocal}) async {
    final conflict = revisionConflict;
    if (conflict == null) throw StateError('No revision conflict');
    await repository.resolveRevisionConflict(
      conflict,
      keepLocal: keepLocal,
      operationId: const Uuid().v4(),
    );
    revisionConflict = null;
  }

  Future<List<SyncConflict>> unresolvedConflicts() =>
      repository.unresolvedConflicts();

  Future<List<FocusSession>> visibleSessions() async {
    final sessions = await repository.getSessions();
    final conflicts = await unresolvedConflicts();
    final excluded = <String>{
      for (final conflict in conflicts) ...[
        conflict.firstSessionId,
        conflict.secondSessionId,
      ],
    };
    return sessions
        .where(
          (session) =>
              session.deletedAt == null && !excluded.contains(session.id),
        )
        .toList();
  }

  Future<void> resolveOverlap(
    String conflictId,
    String winningSessionId,
  ) async {
    final conflict = (await unresolvedConflicts()).singleWhere(
      (item) => item.id == conflictId,
    );
    await repository.resolveConflict(conflict, winningSessionId);
    _status.add(SyncStatus.syncing);
    revisionConflict = null;
  }

  static bool _overlaps(FocusSession first, FocusSession second) {
    for (final a in first.focusSegments) {
      for (final b in second.focusSegments) {
        if (a.start.isBefore(b.end) && b.start.isBefore(a.end)) return true;
      }
    }
    return false;
  }

  static FocusSession _sessionFromPayload(String payload) {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    return FocusSession(
      id: data['id'] as String,
      ownerId: data['ownerId'] as String,
      taskId: data['taskId'] as String?,
      mode: TimerMode.values.byName(data['mode'] as String),
      focusSegments: [
        for (final item in data['segments'] as List)
          FocusSegment(
            start: DateTime.parse(item['start'] as String),
            end: DateTime.parse(item['end'] as String),
          ),
      ],
      creditedOverride: data['creditedOverride'] == null
          ? null
          : Duration(microseconds: data['creditedOverride'] as int),
      revision: data['revision'] as int,
      deletedAt: data['deletedAt'] == null
          ? null
          : DateTime.parse(data['deletedAt'] as String),
    );
  }
}
