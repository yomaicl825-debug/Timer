import 'timer_state.dart';

class TimerEngine {
  TimerState startElapsed({String? taskId, required DateTime at}) {
    final now = at.toUtc();
    return TimerState(
      mode: TimerMode.elapsed,
      phase: TimerPhase.focus,
      taskId: taskId,
      startedAt: now,
      lastObservedAt: now,
      activeSegmentStartedAt: now,
      deadlineAt: null,
      pausedRemaining: null,
      focusDuration: null,
      restDuration: null,
      round: 1,
      focusSegments: const [],
    );
  }

  TimerState startPomodoro({
    required String taskId,
    required Duration focus,
    required Duration rest,
    required DateTime at,
  }) {
    if (taskId.trim().isEmpty ||
        focus.inMicroseconds <= 0 ||
        rest.inMicroseconds <= 0) {
      throw ArgumentError(
        'Task and positive focus/rest durations are required',
      );
    }
    final now = at.toUtc();
    return TimerState(
      mode: TimerMode.pomodoro,
      phase: TimerPhase.focus,
      taskId: taskId,
      startedAt: now,
      lastObservedAt: now,
      activeSegmentStartedAt: now,
      deadlineAt: now.add(focus),
      pausedRemaining: null,
      focusDuration: focus,
      restDuration: rest,
      round: 1,
      focusSegments: const [],
    );
  }

  TimerState advance(TimerState state, {required DateTime at}) {
    final requested = at.toUtc();
    final wentBackwards = requested.isBefore(state.lastObservedAt);
    final now = wentBackwards ? state.lastObservedAt : requested;
    var next = state.copyWith(
      lastObservedAt: now,
      clockWarning: state.clockWarning || wentBackwards,
    );

    if (next.phase == TimerPhase.focus &&
        next.mode == TimerMode.pomodoro &&
        !now.isBefore(next.deadlineAt!)) {
      final focusEnd = next.deadlineAt!;
      final segments = [...next.focusSegments];
      if (focusEnd.isAfter(next.activeSegmentStartedAt!)) {
        segments.add(
          FocusSegment(start: next.activeSegmentStartedAt!, end: focusEnd),
        );
      }
      next = next.copyWith(
        phase: TimerPhase.breakTime,
        activeSegmentStartedAt: null,
        deadlineAt: focusEnd.add(next.restDuration!),
        focusSegments: segments,
      );
    }

    if (next.phase == TimerPhase.breakTime && !now.isBefore(next.deadlineAt!)) {
      next = next.copyWith(phase: TimerPhase.waiting, deadlineAt: null);
    }
    return next;
  }

  TimerState pause(TimerState state, {required DateTime at}) {
    final current = advance(state, at: at);
    final now = current.lastObservedAt;
    if (current.phase == TimerPhase.focus) {
      final segments = [...current.focusSegments];
      if (now.isAfter(current.activeSegmentStartedAt!)) {
        segments.add(
          FocusSegment(start: current.activeSegmentStartedAt!, end: now),
        );
      }
      return current.copyWith(
        phase: TimerPhase.pausedFocus,
        activeSegmentStartedAt: null,
        pausedRemaining: current.deadlineAt?.difference(now),
        deadlineAt: null,
        focusSegments: segments,
      );
    }
    if (current.phase == TimerPhase.breakTime) {
      return current.copyWith(
        phase: TimerPhase.pausedBreak,
        pausedRemaining: current.deadlineAt!.difference(now),
        deadlineAt: null,
      );
    }
    throw StateError('Only a running timer can pause');
  }

  TimerState resume(TimerState state, {required DateTime at}) {
    final current = advance(state, at: at);
    final now = current.lastObservedAt;
    if (current.phase == TimerPhase.pausedFocus) {
      return current.copyWith(
        phase: TimerPhase.focus,
        activeSegmentStartedAt: now,
        deadlineAt: current.pausedRemaining == null
            ? null
            : now.add(current.pausedRemaining!),
        pausedRemaining: null,
      );
    }
    if (current.phase == TimerPhase.pausedBreak) {
      return current.copyWith(
        phase: TimerPhase.breakTime,
        deadlineAt: now.add(current.pausedRemaining!),
        pausedRemaining: null,
      );
    }
    throw StateError('Only a paused timer can resume');
  }

  TimerState finishBreak(TimerState state, {required DateTime at}) {
    final current = advance(state, at: at);
    if (current.phase != TimerPhase.breakTime &&
        current.phase != TimerPhase.pausedBreak) {
      throw StateError('No break is running');
    }
    return current.copyWith(
      phase: TimerPhase.waiting,
      deadlineAt: null,
      pausedRemaining: null,
    );
  }

  TimerState nextRound(TimerState state, {required DateTime at}) {
    final current = advance(state, at: at);
    if (current.phase != TimerPhase.waiting) {
      throw StateError('The break has not ended');
    }
    final now = current.lastObservedAt;
    return current.copyWith(
      phase: TimerPhase.focus,
      round: current.round + 1,
      activeSegmentStartedAt: now,
      deadlineAt: now.add(current.focusDuration!),
    );
  }

  TimerState end(TimerState state, {required DateTime at}) {
    final current = advance(state, at: at);
    if (current.phase == TimerPhase.ended) {
      throw StateError('Timer already ended');
    }
    final now = current.lastObservedAt;
    final segments = [...current.focusSegments];
    if (current.phase == TimerPhase.focus &&
        now.isAfter(current.activeSegmentStartedAt!)) {
      segments.add(
        FocusSegment(start: current.activeSegmentStartedAt!, end: now),
      );
    }
    return current.copyWith(
      phase: TimerPhase.ended,
      activeSegmentStartedAt: null,
      deadlineAt: null,
      pausedRemaining: null,
      endedAt: now,
      focusSegments: segments,
    );
  }
}
