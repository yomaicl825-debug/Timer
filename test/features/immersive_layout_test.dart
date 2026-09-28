import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/features/timer/timer_page.dart';
import 'package:study_timer/features/timer/clock_page.dart';
import 'package:study_timer/ui/app_appearance.dart';

void main() {
  void compact(WidgetTester tester) {
    tester.view.physicalSize = const Size(560, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('compact timer digits do not overlap controls', (tester) async {
    compact(tester);
    final services = AppServices.fake(clock: () => DateTime.utc(2026, 1, 1));
    await services.startElapsed(null);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppAppearance.themeFor(AppTheme.gray),
        home: TimerPage(services: services),
      ),
    );
    expect(
      tester.getRect(find.text('00:00:00')).bottom,
      lessThan(tester.getRect(find.text('暂停')).top - 12),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('compact clock avoids timezone button', (tester) async {
    compact(tester);
    final services = AppServices.fake(clock: () => DateTime.utc(2026, 1, 1, 1));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppAppearance.themeFor(AppTheme.gray),
        home: ClockPage(services: services),
      ),
    );
    expect(
      tester.getRect(find.text('09:00:00')).top,
      greaterThan(tester.getRect(find.text('Asia/Shanghai')).bottom + 8),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
