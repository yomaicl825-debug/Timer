import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/app.dart';
import 'package:study_timer/data/local/app_database.dart';
import 'package:study_timer/data/local/local_repository.dart';
import 'package:study_timer/domain/records/task.dart';
import 'package:study_timer/ui/app_appearance.dart';

void main() {
  test(
    'old dark preference and tasks survive gray theme and restart',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = LocalRepository(database, ownerId: 'local');
      await repository.setSetting('theme', 'dark', operationId: 'old-theme');
      await repository.setSetting('fontStyle', '2', operationId: 'old-font');
      await repository.upsertTask(
        TaskRecord(id: 'math', ownerId: 'local', name: '数学'),
        operationId: 'old-task',
      );
      final services = AppServices(repository: repository, ownerId: 'local');
      await services.load();
      expect(services.theme, AppTheme.dark);
      expect(services.fontStyle, 2);
      await services.setTheme(AppTheme.gray);
      final restarted = AppServices(repository: repository, ownerId: 'local');
      await restarted.load();
      expect(restarted.theme, AppTheme.gray);
      expect(restarted.tasks.single.name, '数学');
      expect(restarted.fontStyle, 2);
    },
  );
}
