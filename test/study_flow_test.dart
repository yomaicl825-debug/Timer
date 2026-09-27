import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/data/cloud/cloudbase_gateway.dart';
import 'package:study_timer/features/auth/auth_page.dart';
import 'package:study_timer/features/profile/profile_page.dart';

void main() {
  testWidgets('create, study, pause, reassign and inspect calendar', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 1, 1, 10);
    final services = AppServices.fake(clock: () => now);
    String? signedIn;
    await tester.pumpWidget(
      MaterialApp(
        home: AuthPage(
          gateway: CloudGateway(_FakeTransport()),
          onAuthenticated: (ownerId) => signedIn = ownerId,
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'student@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.text('登录').last);
    await tester.pumpAndSettle();
    expect(signedIn, 'student');
    await tester.pumpWidget(TimerApp(services: services));
    await tester.tap(find.text('新建任务'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Math');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(services.tasks.single.name, 'Math');

    await tester.tap(find.text('开始学习'));
    await tester.pumpAndSettle();
    expect(services.activeTimer?.taskId, isNull);
    now = now.add(const Duration(minutes: 20));
    await tester.tap(find.text('暂停'));
    await tester.pumpAndSettle();
    now = now.add(const Duration(minutes: 10));
    await tester.tap(find.text('继续'));
    await tester.pumpAndSettle();
    now = now.add(const Duration(minutes: 25));
    await tester.tap(find.text('结束'));
    await tester.pumpAndSettle();
    expect(
      services.sessions.single.creditedDuration,
      const Duration(minutes: 45),
    );

    await tester.pumpWidget(MaterialApp(home: ProfilePage(services: services)));
    await tester.scrollUntilVisible(
      find.byKey(Key('session-${services.sessions.single.id}')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('session-${services.sessions.single.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Math').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(services.sessions.single.taskId, services.tasks.single.id);
    expect(
      services.statistics.daily['2026-01-01'],
      const Duration(minutes: 45),
    );
  });
}

class _FakeTransport extends CloudTransport {
  @override
  Future<String?> signIn(String email, String password) async => 'student';
  @override
  Future<String?> signUp(String email, String password) async => 'student';
  @override
  Future<String?> currentUser() async => 'student';
  @override
  Future<Map<String, dynamic>> command(Map<String, dynamic> data) async => {
    'status': 'success',
  };
}
