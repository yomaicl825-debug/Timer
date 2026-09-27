import '../../domain/records/session.dart';

class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.firstSessionId,
    required this.secondSessionId,
    this.winningSessionId,
  });
  final String id;
  final String firstSessionId;
  final String secondSessionId;
  final String? winningSessionId;
  bool get resolved => winningSessionId != null;
}

class RevisionConflict {
  const RevisionConflict({
    required this.sessionId,
    required this.local,
    required this.remote,
    required this.remoteRecord,
    required this.pendingOperationIds,
  });
  final String sessionId;
  final FocusSession local;
  final FocusSession remote;
  final Map<String, dynamic> remoteRecord;
  final List<String> pendingOperationIds;
}
