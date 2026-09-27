import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/domain/records/task.dart';
import 'package:study_timer/domain/records/session.dart';
import 'package:study_timer/domain/timer/timer_state.dart';

void main() {
  final task = TaskRecord(id: 'math', ownerId: 'test', name: 'Math');
  final focus = FocusSession(
    id: 's',
    ownerId: 'test',
    taskId: 'math',
    mode: TimerMode.elapsed,
    focusSegments: [
      FocusSegment(
        start: DateTime.utc(2026, 1, 1),
        end: DateTime.utc(2026, 1, 1, 1, 30),
      ),
    ],
    revision: 0,
  );

  testWidgets('task row shows only name and cumulative duration', (
    tester,
  ) async {
    final services = AppServices.fake(tasks: [task], sessions: [focus]);
    await tester.pumpWidget(TimerApp(services: services));
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('01:30:00'), findsOneWidget);
    expect(find.text('今日'), findsNothing);
    expect(find.text('本周'), findsNothing);
  });

  testWidgets('generic start is unassigned elapsed study', (tester) async {
    final services = AppServices.fake();
    await tester.pumpWidget(TimerApp(services: services));
    await tester.tap(find.text('开始学习'));
    await tester.pump();
    expect(services.activeTimer?.mode, TimerMode.elapsed);
    expect(services.activeTimer?.taskId, isNull);
  });

  testWidgets('named task offers elapsed and pomodoro', (tester) async {
    final services = AppServices.fake(tasks: [task]);
    await tester.pumpWidget(TimerApp(services: services));
    await tester.tap(find.text('Math'));
    await tester.pumpAndSettle();
    expect(find.text('正数计时'), findsOneWidget);
    expect(find.text('番茄钟'), findsOneWidget);
    await tester.tap(find.text('番茄钟'));
    await tester.pumpAndSettle();
    expect(services.activeTimer?.mode, TimerMode.pomodoro);
    expect(services.activeTimer?.taskId, 'math');
  });

  testWidgets('duplicate task name is rejected', (tester) async {
    final services = AppServices.fake(tasks: [task]);
    await tester.pumpWidget(TimerApp(services: services));
    await tester.tap(find.text('新建任务'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), ' math ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('任务名称已存在'), findsOneWidget);
    expect(services.tasks.length, 1);
  });

  testWidgets('active timer can reopen after its view closes', (tester) async {
    final services = AppServices.fake();
    await services.startElapsed(null);
    await tester.pumpWidget(TimerApp(services: services));
    expect(find.text('继续当前计时'), findsOneWidget);
    await tester.tap(find.text('继续当前计时'));
    await tester.pumpAndSettle();
    expect(find.text('结束'), findsOneWidget);
  });
  testWidgets('clock and profile are separate entries', (tester) async {
    final services = AppServices.fake();
    await tester.pumpWidget(TimerApp(services: services));
    expect(find.text('全屏时钟'), findsOneWidget);
    expect(find.text('个人主页'), findsOneWidget);
  });
}
