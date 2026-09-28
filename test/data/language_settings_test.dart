import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/data/local/app_database.dart';
import 'package:study_timer/data/local/local_repository.dart';
import 'package:study_timer/domain/records/task.dart';
import 'package:study_timer/l10n/app_language.dart';

void main() {
  test('first use recognizes Chinese variants and falls back to English', () {
    expect(resolveLanguage(null, const Locale('zh', 'TW')), AppLanguage.zh);
    expect(resolveLanguage(null, const Locale('zh', 'CN')), AppLanguage.zh);
    expect(resolveLanguage('invalid', const Locale('fr')), AppLanguage.en);
    expect(resolveLanguage('en', const Locale('zh')), AppLanguage.en);
  });

  test('language survives restart without renaming an existing task', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = LocalRepository(db, ownerId: 'local');
    await repo.upsertTask(
      TaskRecord(id: 'math', ownerId: 'local', name: '数学'),
      operationId: 'old-task',
    );
    final services = AppServices(repository: repo, ownerId: 'local');
    await services.load();
    await services.setLanguage(AppLanguage.en);
    final restarted = AppServices(repository: repo, ownerId: 'local');
    await restarted.load();
    expect(restarted.language, AppLanguage.en);
    expect(restarted.tasks.single.name, '数学');
    expect(restarted.tasks.single.id, 'math');
  });
}
