import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/ui/app_appearance.dart';

void main() {
  test(
    'window appearance update leaves active timer intact and notifies once',
    () async {
      final services = AppServices.fake(clock: () => DateTime.utc(2026, 1, 1));
      await services.startElapsed(null);
      final timer = services.activeTimer;
      var notifications = 0;
      services.addListener(() => notifications++);
      services.applyAppearance(theme: AppTheme.gray, fontStyle: 2);
      expect(services.theme, AppTheme.gray);
      expect(services.fontStyle, 2);
      expect(services.activeTimer, same(timer));
      services.applyAppearance(theme: AppTheme.gray, fontStyle: 2);
      expect(notifications, 1);
    },
  );
}
