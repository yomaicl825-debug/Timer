class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.ownerId,
    required this.kind,
    required this.recordId,
    required this.payload,
    required this.createdAt,
  });
  final String id;
  final String ownerId;
  final String kind;
  final String recordId;
  final String payload;
  final DateTime createdAt;
}
