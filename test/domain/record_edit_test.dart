import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/domain/records/task.dart';
import 'package:study_timer/domain/records/session.dart';
import 'package:study_timer/domain/timer/timer_state.dart';

void main() {
  test('blank and duplicate task names are rejected', () {
    final existing = TaskRecord(id: 'a', ownerId: 'u', name: 'Math');
    expect(
      () => TaskCatalog.create(
        id: 'b',
        ownerId: 'u',
        name: '  ',
        existing: [existing],
      ),
      throwsArgumentError,
    );
    expect(
      () => TaskCatalog.create(
        id: 'b',
        ownerId: 'u',
        name: ' math ',
        existing: [existing],
      ),
      throwsArgumentError,
    );
  });

  test('rename preserves stable session association', () {
    final task = TaskRecord(id: 'a', ownerId: 'u', name: 'Math');
    final changed = TaskCatalog.rename(task, 'Physics', [task]);
    final focus = FocusSession(
      id: 's',
      ownerId: 'u',
      taskId: task.id,
      mode: TimerMode.elapsed,
      focusSegments: const [],
      revision: 0,
    );
    expect(changed.id, focus.taskId);
    expect(changed.name, 'Physics');
  });

  test('deleting task moves associated sessions to unassigned', () {
    final task = TaskRecord(id: 'a', ownerId: 'u', name: 'Math');
    final focus = FocusSession(
      id: 's',
      ownerId: 'u',
      taskId: task.id,
      mode: TimerMode.elapsed,
      focusSegments: const [],
      revision: 0,
    );
    final result = TaskCatalog.delete(task, [focus], DateTime.utc(2026));
    expect(result.task.deletedAt, isNotNull);
    expect(result.sessions.single.taskId, isNull);
  });
}
