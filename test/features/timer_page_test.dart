import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/features/timer/clock_page.dart';
import 'package:study_timer/features/timer/timer_page.dart';
import 'package:study_timer/domain/timer/timer_engine.dart';
import 'package:study_timer/domain/timer/timer_state.dart';

void main() {
  testWidgets('clock uses slash date, English weekday and corner timezone', (
    tester,
  ) async {
    final services = AppServices.fake();
    await tester.pumpWidget(
      MaterialApp(
        home: ClockPage(
          services: services,
          now: () => DateTime.utc(2026, 9, 27, 0, 0),
        ),
      ),
    );
    expect(find.text('2026 / 09 / 27'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Asia/Shanghai'), findsOneWidget);
    expect(services.sessions, isEmpty);
    expect(services.activeTimer, isNull);
  });

  testWidgets('elapsed display supports more than 99 hours', (tester) async {
    final now = DateTime.utc(2026, 1, 6, 3, 4, 5);
    final services = AppServices.fake(clock: () => now);
    services.activeTimer = TimerEngine().startElapsed(
      at: now.subtract(const Duration(hours: 123, minutes: 4, seconds: 5)),
    );
    await tester.pumpWidget(MaterialApp(home: TimerPage(services: services)));
    expect(find.text('123:04:05'), findsOneWidget);
  });

  testWidgets('backward clock change warns and holds displayed credit', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 1, 1, 10);
    final services = AppServices.fake(clock: () => now);
    await services.startElapsed(null);
    now = now.add(const Duration(minutes: 20));
    await services.advanceTimer();
    now = now.subtract(const Duration(minutes: 1));
    await services.advanceTimer();
    await tester.pumpWidget(MaterialApp(home: TimerPage(services: services)));
    expect(services.activeTimer?.clockWarning, isTrue);
    expect(find.text('00:20:00'), findsOneWidget);
    expect(find.text('系统时间发生回拨，请校准时间后继续'), findsOneWidget);
  });
  testWidgets('focus can pause, resume and end', (tester) async {
    final now = DateTime.utc(2026, 1, 1, 1);
    final services = AppServices.fake(clock: () => now);
    services.activeTimer = TimerEngine().startElapsed(
      at: DateTime.utc(2026, 1, 1),
    );
    await tester.pumpWidget(MaterialApp(home: TimerPage(services: services)));
    await tester.tap(find.text('暂停'));
    await tester.pump();
    expect(services.activeTimer?.phase, TimerPhase.pausedFocus);
    await tester.tap(find.text('继续'));
    await tester.pump();
    expect(services.activeTimer?.phase, TimerPhase.focus);
    await tester.tap(find.text('结束'));
    await tester.pump();
    expect(services.activeTimer?.phase, TimerPhase.ended);
    expect(services.sessions.single.creditedDuration, const Duration(hours: 1));
  });

  testWidgets('completed break waits for explicit next round', (tester) async {
    final engine = TimerEngine();
    final start = DateTime.utc(2026, 1, 1);
    final now = start.add(const Duration(minutes: 31));
    final services = AppServices.fake(clock: () => now);
    services.activeTimer = engine.advance(
      engine.startPomodoro(
        taskId: 't',
        focus: const Duration(minutes: 25),
        rest: const Duration(minutes: 5),
        at: start,
      ),
      at: now,
    );
    await tester.pumpWidget(MaterialApp(home: TimerPage(services: services)));
    expect(find.text('等待下一轮'), findsOneWidget);
    await tester.tap(find.text('下一轮'));
    await tester.pump();
    expect(services.activeTimer?.phase, TimerPhase.focus);
    expect(services.activeTimer?.round, 2);
  });
}
