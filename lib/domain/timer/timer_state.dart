enum TimerMode { elapsed, pomodoro }

enum TimerPhase { focus, pausedFocus, breakTime, pausedBreak, waiting, ended }

class FocusSegment {
  FocusSegment({required DateTime start, required DateTime end})
    : start = start.toUtc(),
      end = end.toUtc() {
    if (this.end.isBefore(this.start)) {
      throw ArgumentError('Focus segment ends before it starts');
    }
  }

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
}

const _unset = Object();

class TimerState {
  TimerState({
    required this.mode,
    required this.phase,
    required this.taskId,
    required this.startedAt,
    required this.lastObservedAt,
    required this.activeSegmentStartedAt,
    required this.deadlineAt,
    required this.pausedRemaining,
    required this.focusDuration,
    required this.restDuration,
    required this.round,
    required List<FocusSegment> focusSegments,
    this.clockWarning = false,
    this.endedAt,
  }) : focusSegments = List.unmodifiable(focusSegments);

  final TimerMode mode;
  final TimerPhase phase;
  final String? taskId;
  final DateTime startedAt;
  final DateTime lastObservedAt;
  final DateTime? activeSegmentStartedAt;
  final DateTime? deadlineAt;
  final Duration? pausedRemaining;
  final Duration? focusDuration;
  final Duration? restDuration;
  final int round;
  final List<FocusSegment> focusSegments;
  final bool clockWarning;
  final DateTime? endedAt;

  Duration creditedFocusAt(DateTime at) {
    var total = Duration.zero;
    for (final segment in focusSegments) {
      total += segment.duration;
    }
    if (phase == TimerPhase.focus && activeSegmentStartedAt != null) {
      var end = at.toUtc();
      if (deadlineAt != null && end.isAfter(deadlineAt!)) {
        end = deadlineAt!;
      }
      if (end.isAfter(activeSegmentStartedAt!)) {
        total += end.difference(activeSegmentStartedAt!);
      }
    }
    return total;
  }

  TimerState copyWith({
    TimerPhase? phase,
    DateTime? lastObservedAt,
    Object? activeSegmentStartedAt = _unset,
    Object? deadlineAt = _unset,
    Object? pausedRemaining = _unset,
    int? round,
    List<FocusSegment>? focusSegments,
    bool? clockWarning,
    DateTime? endedAt,
  }) {
    return TimerState(
      mode: mode,
      phase: phase ?? this.phase,
      taskId: taskId,
      startedAt: startedAt,
      lastObservedAt: lastObservedAt ?? this.lastObservedAt,
      activeSegmentStartedAt: identical(activeSegmentStartedAt, _unset)
          ? this.activeSegmentStartedAt
          : activeSegmentStartedAt as DateTime?,
      deadlineAt: identical(deadlineAt, _unset)
          ? this.deadlineAt
          : deadlineAt as DateTime?,
      pausedRemaining: identical(pausedRemaining, _unset)
          ? this.pausedRemaining
          : pausedRemaining as Duration?,
      focusDuration: focusDuration,
      restDuration: restDuration,
      round: round ?? this.round,
      focusSegments: focusSegments ?? this.focusSegments,
      clockWarning: clockWarning ?? this.clockWarning,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
