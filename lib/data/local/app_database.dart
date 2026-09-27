import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class TaskEntries extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class SessionEntries extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get taskId => text().nullable()();
  TextColumn get payload => text()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class TimerSnapshots extends Table {
  TextColumn get ownerId => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {ownerId};
}

class SettingEntries extends Table {
  TextColumn get ownerId => text()();
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {ownerId, key};
}

class PendingChanges extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get kind => text()();
  TextColumn get recordId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class ConflictEntries extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get firstSessionId => text()();
  TextColumn get secondSessionId => text()();
  TextColumn get winningSessionId => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    TaskEntries,
    SessionEntries,
    TimerSnapshots,
    SettingEntries,
    PendingChanges,
    ConflictEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'study_timer'));

  Future<String?> getLastAccount() async {
    final row =
        await (select(settingEntries)..where(
              (entry) =>
                  entry.ownerId.equals('__device__') &
                  entry.key.equals('lastAccount'),
            ))
            .getSingleOrNull();
    return row?.value;
  }

  Future<void> setLastAccount(String ownerId) async {
    await into(settingEntries).insertOnConflictUpdate(
      SettingEntriesCompanion.insert(
        ownerId: '__device__',
        key: 'lastAccount',
        value: ownerId,
      ),
    );
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement(
        'CREATE UNIQUE INDEX active_task_name ON task_entries (owner_id, normalized_name) WHERE deleted_at IS NULL',
      );
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(conflictEntries);
    },
  );
}
