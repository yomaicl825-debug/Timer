import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/main.dart';

void main() {
  testWidgets('launcher exposes task creation and personal page', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('新建任务'), findsOneWidget);
    expect(find.text('个人主页'), findsOneWidget);
  });
}
