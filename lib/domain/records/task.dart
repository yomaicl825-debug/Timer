import 'session.dart';

class TaskRecord {
  TaskRecord({
    required this.id,
    required this.ownerId,
    required String name,
    this.deletedAt,
  }) : name = name.trim() {
    if (id.isEmpty || ownerId.isEmpty || this.name.isEmpty) {
      throw ArgumentError('Task ID, owner, and name are required');
    }
  }

  final String id;
  final String ownerId;
  final String name;
  final DateTime? deletedAt;
  String get normalizedName => name.toLowerCase();
}

class TaskDeletion {
  TaskDeletion(this.task, List<FocusSession> sessions)
    : sessions = List.unmodifiable(sessions);
  final TaskRecord task;
  final List<FocusSession> sessions;
}

class TaskCatalog {
  static TaskRecord create({
    required String id,
    required String ownerId,
    required String name,
    required Iterable<TaskRecord> existing,
  }) {
    final task = TaskRecord(id: id, ownerId: ownerId, name: name);
    _checkUnique(task, existing);
    return task;
  }

  static TaskRecord rename(
    TaskRecord task,
    String name,
    Iterable<TaskRecord> existing,
  ) {
    final changed = TaskRecord(
      id: task.id,
      ownerId: task.ownerId,
      name: name,
      deletedAt: task.deletedAt,
    );
    _checkUnique(changed, existing);
    return changed;
  }

  static void _checkUnique(TaskRecord task, Iterable<TaskRecord> existing) {
    if (existing.any(
      (other) =>
          other.id != task.id &&
          other.ownerId == task.ownerId &&
          other.deletedAt == null &&
          other.normalizedName == task.normalizedName,
    )) {
      throw ArgumentError('Task name already exists');
    }
  }

  static TaskDeletion delete(
    TaskRecord task,
    Iterable<FocusSession> sessions,
    DateTime at,
  ) {
    final deleted = TaskRecord(
      id: task.id,
      ownerId: task.ownerId,
      name: task.name,
      deletedAt: at.toUtc(),
    );
    return TaskDeletion(deleted, [
      for (final session in sessions)
        session.ownerId == task.ownerId && session.taskId == task.id
            ? session.copyWith(taskId: null, revision: session.revision + 1)
            : session,
    ]);
  }
}
