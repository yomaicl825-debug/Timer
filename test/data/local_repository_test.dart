import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/data/local/app_database.dart';
import 'package:study_timer/data/local/local_repository.dart';
import 'package:study_timer/domain/records/task.dart';
import 'package:study_timer/domain/records/session.dart';
import 'package:study_timer/domain/timer/timer_engine.dart';
import 'package:study_timer/domain/timer/timer_state.dart';

void main() {
  late AppDatabase database;
  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => database.close());

  test('observation checkpoint persists without growing sync queue', () async {
    final repo = LocalRepository(database, ownerId: 'u');
    final engine = TimerEngine();
    final started = engine.startElapsed(at: DateTime.utc(2026, 1, 1));
    await repo.saveTimer(started, operationId: 'start');
    final observed = engine.advance(
      started,
      at: DateTime.utc(2026, 1, 1, 0, 1),
    );
    await repo.checkpointTimer(observed);
    expect((await repo.loadTimer())?.lastObservedAt, observed.lastObservedAt);
    expect((await repo.pendingChanges()).length, 1);
  });
  test(
    'last signed-in account survives restart without mixing records',
    () async {
      await database.setLastAccount('student');
      expect(await database.getLastAccount(), 'student');
      await database.setLastAccount('local');
      expect(await database.getLastAccount(), 'local');
    },
  );
  test(
    'finishing a timer atomically saves session and ended snapshot',
    () async {
      final repo = LocalRepository(database, ownerId: 'u');
      final engine = TimerEngine();
      final started = engine.startElapsed(at: DateTime.utc(2026, 1, 1));
      final ended = engine.end(started, at: DateTime.utc(2026, 1, 1, 1));
      final session = FocusSession(
        id: 'focus-u-1',
        ownerId: 'u',
        taskId: null,
        mode: TimerMode.elapsed,
        focusSegments: ended.focusSegments,
        revision: 0,
      );
      await repo.finishTimer(
        ended,
        session,
        sessionOperationId: 'finish-session',
        timerOperationId: 'finish-timer',
      );
      expect((await repo.getSessions()).single.id, session.id);
      expect((await repo.loadTimer())?.phase, TimerPhase.ended);
      expect((await repo.pendingChanges()).length, 2);
      await expectLater(
        repo.finishTimer(
          ended,
          session,
          sessionOperationId: 'finish-session',
          timerOperationId: 'again',
        ),
        throwsA(isA<Exception>()),
      );
      expect((await repo.pendingChanges()).length, 2);
    },
  );
  test('task and unique pending operation persist together', () async {
    final repo = LocalRepository(database, ownerId: 'u');
    final task = TaskRecord(id: 't', ownerId: 'u', name: 'Math');
    await repo.upsertTask(task, operationId: 'op1');
    expect((await repo.getTasks()).single.name, 'Math');
    expect((await repo.pendingChanges()).single.id, 'op1');
    await expectLater(
      repo.upsertTask(task, operationId: 'op1'),
      throwsA(isA<Exception>()),
    );
    expect((await repo.getTasks()).length, 1);
    expect((await repo.pendingChanges()).length, 1);
  });

  test('timer and session survive repository recreation', () async {
    final repo = LocalRepository(database, ownerId: 'u');
    final state = TimerEngine().startElapsed(at: DateTime.utc(2026, 1, 1));
    await repo.saveTimer(state, operationId: 'op1');
    final session = FocusSession(
      id: 's',
      ownerId: 'u',
      taskId: null,
      mode: TimerMode.elapsed,
      focusSegments: [
        FocusSegment(
          start: DateTime.utc(2026, 1, 1),
          end: DateTime.utc(2026, 1, 1, 1),
        ),
      ],
      revision: 0,
    );
    await repo.upsertSession(session, operationId: 'op2');
    final reopened = LocalRepository(database, ownerId: 'u');
    expect((await reopened.loadTimer())?.phase, TimerPhase.focus);
    expect(
      (await reopened.getSessions()).single.creditedDuration,
      const Duration(hours: 1),
    );
    await reopened.acknowledgeChange('op1');
    expect((await reopened.pendingChanges()).length, 1);
  });

  test('another account cannot see cached tasks, sessions or timer', () async {
    final first = LocalRepository(database, ownerId: 'first');
    await first.upsertTask(
      TaskRecord(id: 't', ownerId: 'first', name: 'Math'),
      operationId: 'op1',
    );
    await first.saveTimer(
      TimerEngine().startElapsed(at: DateTime.utc(2026)),
      operationId: 'op2',
    );
    final second = LocalRepository(database, ownerId: 'second');
    expect(await second.getTasks(), isEmpty);
    expect(await second.getSessions(), isEmpty);
    expect(await second.loadTimer(), isNull);
    expect(await second.pendingChanges(), isEmpty);
  });
  test('preferences persist per account and queue for sync', () async {
    final first = LocalRepository(database, ownerId: 'first');
    await first.setSetting('focusMinutes', '35', operationId: 'setting-op');
    expect(
      (await LocalRepository(
        database,
        ownerId: 'first',
      ).getSettings())['focusMinutes'],
      '35',
    );
    expect(
      await LocalRepository(database, ownerId: 'second').getSettings(),
      isEmpty,
    );
    expect((await first.pendingChanges()).single.kind, 'setting');
  });
}
