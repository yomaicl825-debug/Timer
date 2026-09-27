import '../timer/timer_state.dart';

const _unset = Object();

class FocusSession {
  FocusSession({
    required this.id,
    required this.ownerId,
    required this.taskId,
    required this.mode,
    required List<FocusSegment> focusSegments,
    required this.revision,
    this.creditedOverride,
    this.deletedAt,
  }) : focusSegments = List.unmodifiable(focusSegments) {
    if (id.isEmpty ||
        ownerId.isEmpty ||
        revision < 0 ||
        (creditedOverride != null && creditedOverride!.isNegative)) {
      throw ArgumentError('Invalid focus session');
    }
  }

  final String id;
  final String ownerId;
  final String? taskId;
  final TimerMode mode;
  final List<FocusSegment> focusSegments;
  final Duration? creditedOverride;
  final int revision;
  final DateTime? deletedAt;

  Duration get creditedDuration =>
      creditedOverride ??
      focusSegments.fold(
        Duration.zero,
        (sum, segment) => sum + segment.duration,
      );

  FocusSession copyWith({
    Object? taskId = _unset,
    Object? creditedOverride = _unset,
    Object? deletedAt = _unset,
    int? revision,
  }) => FocusSession(
    id: id,
    ownerId: ownerId,
    taskId: identical(taskId, _unset) ? this.taskId : taskId as String?,
    mode: mode,
    focusSegments: focusSegments,
    creditedOverride: identical(creditedOverride, _unset)
        ? this.creditedOverride
        : creditedOverride as Duration?,
    revision: revision ?? this.revision,
    deletedAt: identical(deletedAt, _unset)
        ? this.deletedAt
        : deletedAt as DateTime?,
  );
}
