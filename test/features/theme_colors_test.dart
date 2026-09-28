import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/features/timer/clock_page.dart';
import 'package:study_timer/ui/app_appearance.dart';

void main() {
  testWidgets(
    'gray clock displays softened text on the selected G background',
    (tester) async {
      final services = AppServices.fake(
        clock: () => DateTime.utc(2026, 9, 28, 6, 28, 36),
      );
      await services.setTheme(AppTheme.gray);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppAppearance.themeFor(services.theme),
          home: ClockPage(services: services),
        ),
      );
      final context = tester.element(find.byType(ClockPage));
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        const Color(0xff141414),
      );
      final clock = tester.widget<Text>(find.text('14:28:36'));
      expect(clock.style!.color, const Color(0xffc4c4c4));
      expect(
        Theme.of(context).colorScheme.onSurfaceVariant,
        const Color(0xffa8a8a8),
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}
