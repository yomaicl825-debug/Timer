import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/domain/records/task.dart';
import 'package:study_timer/features/profile/calendar_view.dart';

void main() {
  Future<void> openProfile(
    WidgetTester tester, {
    Size size = const Size(1200, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TimerApp(
        services: AppServices.fake(
          tasks: [TaskRecord(id: 'math', ownerId: 'test', name: '数学')],
        ),
      ),
    );
    await tester.tap(find.text('个人主页'));
    await tester.pumpAndSettle();
  }

  testWidgets('desktop profile sections are isolated and sidebar collapses', (
    tester,
  ) async {
    await openProfile(tester);
    expect(find.byType(CalendarView), findsOneWidget);
    expect(find.text('数学'), findsNothing);
    await tester.tap(find.byKey(const Key('profile-nav-tasks')));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarView), findsNothing);
    expect(find.text('数学'), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile-nav-history')));
    await tester.pumpAndSettle();
    expect(find.text('暂无历史记录'), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile-collapse')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-expand')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone uses drawer and selection closes it', (tester) async {
    await openProfile(tester, size: const Size(390, 844));
    await tester.tap(find.byTooltip('打开导航'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-nav-tasks')));
    await tester.pumpAndSettle();
    expect(find.text('数学'), findsOneWidget);
    expect(find.byType(CalendarView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gray theme changes the application and labels are larger', (
    tester,
  ) async {
    await openProfile(tester);
    await tester.tap(find.byKey(const Key('profile-nav-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('深灰底浅灰字'));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('深灰底浅灰字'));
    final theme = Theme.of(context);
    expect(theme.scaffoldBackgroundColor, const Color(0xff141414));
    expect(theme.colorScheme.onSurface, const Color(0xffc4c4c4));
    expect(theme.textTheme.bodyLarge!.fontSize, greaterThanOrEqualTo(18));
    expect(theme.textTheme.labelLarge!.fontWeight, FontWeight.w400);
    expect(tester.takeException(), isNull);
  });
}
