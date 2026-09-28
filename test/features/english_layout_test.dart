import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/features/profile/profile_page.dart';
import 'package:study_timer/features/timer/timer_page.dart';
import 'package:study_timer/l10n/app_language.dart';
import 'package:study_timer/l10n/generated/app_localizations.dart';
import 'package:study_timer/ui/app_appearance.dart';

void main() {
  testWidgets('English phone navigation closes after choosing Settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final services = AppServices.fake(language: AppLanguage.en);
    await tester.pumpWidget(
      MaterialApp(
        locale: services.language.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppAppearance.themeFor(AppTheme.gray),
        home: ProfilePage(services: services),
      ),
    );
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English compact timer controls fit while paused', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(560, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final services = AppServices.fake(
      language: AppLanguage.en,
      clock: () => DateTime.utc(2026, 9, 28),
    );
    await services.startElapsed(null);
    await services.pauseTimer();
    await tester.pumpWidget(
      MaterialApp(
        locale: services.language.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppAppearance.themeFor(AppTheme.gray),
        home: TimerPage(services: services),
      ),
    );
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
