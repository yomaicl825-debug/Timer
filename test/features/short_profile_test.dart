import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/features/profile/profile_page.dart';

void main() {
  testWidgets('short profile sidebar can scroll to settings without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(home: ProfilePage(services: AppServices.fake())),
    );
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile-nav-settings')),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('profile-nav-settings')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('深灰底浅灰字'),
      100,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('preferences-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('深灰底浅灰字'), findsOneWidget);
  });
}
