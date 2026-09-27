import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/domain/timer/timer_engine.dart';
import 'package:study_timer/domain/timer/timer_state.dart';

void main() {
  final start = DateTime.utc(2026, 9, 27, 8);
  final engine = TimerEngine();

  test(
    'elapsed focus excludes a paused interval and ends with actual credit',
    () {
      var state = engine.startElapsed(taskId: 'math', at: start);
      state = engine.pause(state, at: start.add(const Duration(minutes: 10)));
      expect(
        state.creditedFocusAt(start.add(const Duration(hours: 1))),
        const Duration(minutes: 10),
      );

      state = engine.resume(state, at: start.add(const Duration(hours: 1)));
      state = engine.end(
        state,
        at: start.add(const Duration(hours: 1, minutes: 5)),
      );
      expect(state.phase, TimerPhase.ended);
      expect(
        state.creditedFocusAt(start.add(const Duration(hours: 2))),
        const Duration(minutes: 15),
      );
      expect(state.focusSegments.length, 2);
    },
  );

  test('pomodoro focus caps at deadline and enters break', () {
    var state = engine.startPomodoro(
      taskId: 'english',
      focus: const Duration(minutes: 25),
      rest: const Duration(minutes: 5),
      at: start,
    );
    state = engine.advance(state, at: start.add(const Duration(minutes: 27)));
    expect(state.phase, TimerPhase.breakTime);
    expect(
      state.creditedFocusAt(start.add(const Duration(minutes: 27))),
      const Duration(minutes: 25),
    );
    expect(
      state.focusSegments.single.end,
      start.add(const Duration(minutes: 25)),
    );
  });

  test('rest completion waits for confirmation even after long absence', () {
    var state = engine.startPomodoro(
      taskId: 'english',
      focus: const Duration(minutes: 25),
      rest: const Duration(minutes: 5),
      at: start,
    );
    state = engine.advance(state, at: start.add(const Duration(hours: 6)));
    expect(state.phase, TimerPhase.waiting);
    expect(
      state.creditedFocusAt(start.add(const Duration(hours: 6))),
      const Duration(minutes: 25),
    );

    state = engine.nextRound(state, at: start.add(const Duration(hours: 6)));
    expect(state.phase, TimerPhase.focus);
    expect(state.round, 2);
  });

  test('early break end waits until user chooses next round', () {
    var state = engine.startPomodoro(
      taskId: 'english',
      focus: const Duration(minutes: 25),
      rest: const Duration(minutes: 5),
      at: start,
    );
    state = engine.advance(state, at: start.add(const Duration(minutes: 25)));
    state = engine.finishBreak(
      state,
      at: start.add(const Duration(minutes: 26)),
    );
    expect(state.phase, TimerPhase.waiting);
    expect(
      state.creditedFocusAt(start.add(const Duration(minutes: 26))),
      const Duration(minutes: 25),
    );
  });

  test('application close does not stop elapsed focus', () {
    final state = engine.startElapsed(at: start);
    expect(
      state.creditedFocusAt(start.add(const Duration(hours: 6))),
      const Duration(hours: 6),
    );
  });

  test('clock correction backwards never creates negative focus', () {
    final state = engine.startElapsed(at: start);
    final corrected = engine.advance(
      state,
      at: start.subtract(const Duration(minutes: 2)),
    );
    expect(corrected.clockWarning, isTrue);
    expect(corrected.creditedFocusAt(start), Duration.zero);
  });

  test('zero or negative pomodoro duration is rejected', () {
    expect(
      () => engine.startPomodoro(
        taskId: 'math',
        focus: Duration.zero,
        rest: const Duration(minutes: 5),
        at: start,
      ),
      throwsArgumentError,
    );
    expect(
      () => engine.startPomodoro(
        taskId: 'math',
        focus: const Duration(minutes: 25),
        rest: const Duration(minutes: -1),
        at: start,
      ),
      throwsArgumentError,
    );
  });

  test('stopped timer cannot resume', () {
    var state = engine.startElapsed(at: start);
    state = engine.end(state, at: start.add(const Duration(minutes: 3)));
    expect(
      () => engine.resume(state, at: start.add(const Duration(minutes: 4))),
      throwsStateError,
    );
  });
}
