import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/data/sync/sync_conflict.dart';
import 'package:study_timer/domain/records/session.dart';
import 'package:study_timer/domain/records/task.dart';
import 'package:study_timer/domain/timer/timer_state.dart';
import 'package:study_timer/features/profile/profile_page.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);
  final task = TaskRecord(id: 'math', ownerId: 'test', name: 'Math');
  final physics = TaskRecord(id: 'physics', ownerId: 'test', name: 'Physics');
  FocusSession sample() => FocusSession(
    id: 's',
    ownerId: 'test',
    taskId: 'math',
    mode: TimerMode.elapsed,
    focusSegments: [
      FocusSegment(
        start: DateTime.utc(2026, 1, 1, 10),
        end: DateTime.utc(2026, 1, 1, 11),
      ),
    ],
    revision: 0,
  );

  testWidgets('profile shows day, week and month totals', (tester) async {
    final services = AppServices.fake(
      tasks: [task],
      sessions: [sample()],
      clock: () => now,
    );
    await tester.pumpWidget(MaterialApp(home: ProfilePage(services: services)));
    expect(find.text('今日 01:00:00'), findsOneWidget);
    expect(find.text('本周 01:00:00'), findsOneWidget);
    expect(find.text('本月 01:00:00'), findsOneWidget);
  });

  testWidgets('calendar day tap reveals duration', (tester) async {
    final services = AppServices.fake(sessions: [sample()], clock: () => now);
    await tester.pumpWidget(MaterialApp(home: ProfilePage(services: services)));
    await tester.tap(find.byKey(const Key('day-2026-01-01')));
    await tester.pump();
    expect(find.text('2026-01-01 · 01:00:00'), findsOneWidget);
  });

  testWidgets('history can reassign and delete a session', (tester) async {
    final services = AppServices.fake(
      tasks: [task, physics],
      sessions: [sample()],
      clock: () => now,
    );
    await tester.pumpWidget(MaterialApp(home: ProfilePage(services: services)));
    await openProfileSection(tester, 'history');
    await tester.scrollUntilVisible(
      find.byKey(const Key('session-s')),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('session-s')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Physics').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(services.sessions.single.taskId, 'physics');
    await openProfileSection(tester, 'history');
    await tester.scrollUntilVisible(
      find.byKey(const Key('session-s')),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('session-s')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除记录'));
    await tester.pumpAndSettle();
    expect(services.statistics.total, Duration.zero);
  });

  testWidgets('preferences change theme, font and saved durations', (
    tester,
  ) async {
    final services = AppServices.fake(clock: () => now);
    await tester.pumpWidget(MaterialApp(home: ProfilePage(services: services)));
    await openProfileSection(tester, 'settings');
    await tester.pumpAndSettle();
    await tester.tap(find.text('黑底白字'));
    await tester.pump();
    expect(services.darkMode, isTrue);
    await tester.tap(find.text('数字字体'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('等宽').last);
    await tester.pumpAndSettle();
    expect(services.fontStyle, 1);
    await tester.scrollUntilVisible(
      find.text('保存时长'),
      150,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('preferences-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(find.byKey(const Key('focus-minutes')), '35');
    await tester.enterText(find.byKey(const Key('break-minutes')), '8');
    await tester.tap(find.text('保存时长'));
    await tester.pump();
    expect(services.focusDuration, const Duration(minutes: 35));
    expect(services.breakDuration, const Duration(minutes: 8));
    await tester.enterText(find.byKey(const Key('focus-minutes')), '0');
    await tester.tap(find.text('保存时长'));
    await tester.pump();
    expect(find.text('时长必须大于 0'), findsOneWidget);
  });
  testWidgets('editing credited time updates visible daily total', (
    tester,
  ) async {
    final services = AppServices.fake(
      tasks: [task],
      sessions: [sample()],
      clock: () => now,
    );
    await tester.pumpWidget(MaterialApp(home: ProfilePage(services: services)));
    await openProfileSection(tester, 'history');
    await tester.scrollUntilVisible(
      find.byKey(const Key('session-s')),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('session-s')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '02:30:00');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(
      services.sessions.single.creditedDuration,
      const Duration(hours: 2, minutes: 30),
    );
    await openProfileSection(tester, 'calendar');
    await tester.drag(find.byType(ListView).last, const Offset(0, 800));
    await tester.pumpAndSettle();
    expect(find.text('今日 02:30:00'), findsOneWidget);
  });
  testWidgets('overlapping offline records are excluded until chosen', (
    tester,
  ) async {
    final second = FocusSession(
      id: 't',
      ownerId: 'test',
      taskId: 'physics',
      mode: TimerMode.elapsed,
      focusSegments: [
        FocusSegment(
          start: DateTime.utc(2026, 1, 1, 10, 30),
          end: DateTime.utc(2026, 1, 1, 11, 30),
        ),
      ],
      revision: 0,
    );
    final services = AppServices.fake(
      tasks: [task, physics],
      sessions: [sample(), second],
      clock: () => now,
    );
    services.setSyncConflicts(const [
      SyncConflict(id: 's:t', firstSessionId: 's', secondSessionId: 't'),
    ]);
    String? kept;
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(
          services: services,
          conflicts: const [
            SyncConflict(id: 's:t', firstSessionId: 's', secondSessionId: 't'),
          ],
          onResolveConflict: (id, winner) async {
            kept = winner;
          },
        ),
      ),
    );
    expect(find.text('今日 00:00:00'), findsOneWidget);
    await openProfileSection(tester, 'history');
    await tester.scrollUntilVisible(
      find.text('待处理的重叠记录'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('保留 Math · 01:00:00'));
    await tester.pump();
    expect(kept, 's');
  });
  testWidgets('desktop hover reveals calendar duration', (tester) async {
    final services = AppServices.fake(sessions: [sample()], clock: () => now);
    await tester.pumpWidget(MaterialApp(home: ProfilePage(services: services)));
    final day = find.byKey(const Key('day-2026-01-01'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(day));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('2026-01-01 · 01:00:00'), findsOneWidget);
    await mouse.removePointer();
  });
}

Future<void> openProfileSection(WidgetTester tester, String name) async {
  final target = find.byKey(Key('profile-nav-$name'));
  if (target.evaluate().isEmpty) {
    await tester.tap(find.byTooltip('打开导航'));
    await tester.pumpAndSettle();
  }
  await tester.tap(target);
  await tester.pumpAndSettle();
}
