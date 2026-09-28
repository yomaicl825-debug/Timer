import 'package:flutter/material.dart';
import 'package:study_timer/features/timer/clock_page.dart';
import 'package:study_timer/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/domain/records/task.dart';
import 'package:study_timer/l10n/app_language.dart';
import 'package:study_timer/ui/app_appearance.dart';

void main() {
  testWidgets('open task validation error follows a locale change', (
    tester,
  ) async {
    final services = AppServices.fake(language: AppLanguage.en);
    await tester.pumpWidget(TimerApp(services: services));
    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a task name'), findsOneWidget);
    await services.setLanguage(AppLanguage.zh);
    await tester.pumpAndSettle();
    expect(find.text('请输入任务名'), findsOneWidget);
    expect(find.text('Enter a task name'), findsNothing);
  });

  testWidgets('clock time zone editor label is localized', (tester) async {
    final services = AppServices.fake();
    await tester.pumpWidget(
      MaterialApp(
        locale: services.language.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ClockPage(services: services),
      ),
    );
    await tester.tap(find.text('Asia/Shanghai'));
    await tester.pumpAndSettle();
    expect(find.text('IANA 时区'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'profile language choice updates launcher but preserves task name',
    (tester) async {
      final services = AppServices.fake(
        tasks: [TaskRecord(id: 'math', ownerId: 'test', name: '数学')],
      );
      await tester.pumpWidget(TimerApp(services: services));
      await tester.tap(find.text('个人主页'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('English'));
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Appearance'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('New task'), findsOneWidget);
      expect(find.text('数学'), findsOneWidget);
      expect(find.text('新建任务'), findsNothing);
    },
  );

  test('pending offline message is translated when language changes', () async {
    final services = AppServices.fake();
    services.setSyncMessage('离线计时，稍后同步');
    expect(services.syncMessage, '离线计时，稍后同步');
    await services.setLanguage(AppLanguage.en);
    expect(services.syncMessage, 'Timing offline. Sync will resume later.');
  });

  test(
    'window language updates preserve paused timer and notify once',
    () async {
      final services = AppServices.fake(
        clock: () => DateTime.utc(2026, 9, 28, 8),
      );
      await services.startElapsed(null);
      await services.pauseTimer();
      final before = services.activeTimer;
      var notifications = 0;
      services.addListener(() => notifications++);
      services.applyAppearance(
        theme: AppTheme.gray,
        fontStyle: 1,
        language: AppLanguage.en,
      );
      expect(identical(services.activeTimer, before), isTrue);
      expect(services.language, AppLanguage.en);
      expect(notifications, 1);
      services.applyAppearance(
        theme: AppTheme.gray,
        fontStyle: 1,
        language: AppLanguage.en,
      );
      expect(notifications, 1);
    },
  );
}
