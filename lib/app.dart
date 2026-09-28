import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'data/local/local_repository.dart';
import 'data/cloud/cloudbase_gateway.dart';
import 'data/sync/sync_conflict.dart';
import 'domain/records/session.dart';
import 'domain/records/statistics.dart';
import 'domain/records/task.dart';
import 'domain/timer/timer_engine.dart';
import 'domain/timer/timer_state.dart';
import 'features/launcher/launcher_page.dart';
import 'ui/app_appearance.dart';

class AppServices extends ChangeNotifier {
  AppServices({
    this.repository,
    this.cloud,
    this.nativeWindows = true,
    this.ownerId = 'test',
    List<TaskRecord> tasks = const [],
    List<FocusSession> sessions = const [],
    DateTime Function()? clock,
  }) : _tasks = List.of(tasks),
       _sessions = List.of(sessions),
       clock = clock ?? DateTime.now;

  factory AppServices.fake({
    List<TaskRecord> tasks = const [],
    List<FocusSession> sessions = const [],
    DateTime Function()? clock,
  }) => AppServices(
    tasks: tasks,
    sessions: sessions,
    clock: clock,
    nativeWindows: false,
  );

  final LocalRepository? repository;
  final CloudGateway? cloud;
  final bool nativeWindows;
  final String ownerId;
  final DateTime Function() clock;
  final TimerEngine engine = TimerEngine();
  List<TaskRecord> _tasks;
  List<FocusSession> _sessions;
  Set<String> _excludedSessionIds = {};
  List<SyncConflict> syncConflicts = [];
  RevisionConflict? revisionConflict;
  String? syncMessage;
  void setSyncMessage(String? message) {
    syncMessage = message;
    notifyListeners();
  }

  TimerState? activeTimer;
  DateTime? _lastCheckpoint;
  int? _cloudRevision;
  Duration focusDuration = const Duration(minutes: 25);
  Duration breakDuration = const Duration(minutes: 5);
  String statisticsTimezone = 'Asia/Shanghai';
  String clockTimezone = 'Asia/Shanghai';
  AppTheme theme = AppTheme.light;
  bool get darkMode => theme != AppTheme.light;
  int fontStyle = 0;

  List<TaskRecord> get tasks =>
      List.unmodifiable(_tasks.where((task) => task.deletedAt == null));
  List<FocusSession> get sessions => List.unmodifiable(_sessions);
  List<FocusSession> get visibleSessions => List.unmodifiable(
    _sessions.where((session) => !_excludedSessionIds.contains(session.id)),
  );
  void setSyncConflicts(
    List<SyncConflict> conflicts, {
    RevisionConflict? revision,
  }) {
    revisionConflict = revision;
    syncConflicts = List.unmodifiable(conflicts);
    excludeConflictedSessions([
      for (final conflict in conflicts) ...[
        conflict.firstSessionId,
        conflict.secondSessionId,
      ],
      if (revision != null) revision.sessionId,
    ]);
  }

  void excludeConflictedSessions(Iterable<String> ids) {
    _excludedSessionIds = ids.toSet();
    notifyListeners();
  }

  StatisticsSnapshot get statistics =>
      Statistics.calculate(visibleSessions, statisticsTimezone);
  Duration totalForTask(String taskId) =>
      statistics.perTask[taskId] ?? Duration.zero;

  Future<void> load() async {
    final store = repository;
    if (store == null) return;
    _tasks = await store.getTasks();
    _sessions = await store.getSessions();
    activeTimer = await store.loadTimer();
    _lastCheckpoint = activeTimer?.lastObservedAt;
    final settings = await store.getSettings();
    theme = AppAppearance.parseTheme(settings['theme']);
    fontStyle = int.tryParse(settings['fontStyle'] ?? '') ?? 0;
    statisticsTimezone = settings['statisticsTimezone'] ?? 'Asia/Shanghai';
    clockTimezone = settings['clockTimezone'] ?? 'Asia/Shanghai';
    focusDuration = Duration(
      minutes: int.tryParse(settings['focusMinutes'] ?? '') ?? 25,
    );
    breakDuration = Duration(
      minutes: int.tryParse(settings['breakMinutes'] ?? '') ?? 5,
    );
    notifyListeners();
  }

  Future<void> _savePreference(String key, String value) async {
    final store = repository;
    if (store != null) {
      await store.setSetting(key, value, operationId: const Uuid().v4());
    }
  }

  Future<void> setDarkMode(bool value) async {
    await setTheme(value ? AppTheme.dark : AppTheme.light);
  }

  Future<void> setTheme(AppTheme value) async {
    await _savePreference('theme', value.name);
    theme = value;
    notifyListeners();
  }

  Future<void> setFontStyle(int value) async {
    if (value < 0 || value > 2) throw ArgumentError('Unknown font style');
    await _savePreference('fontStyle', value.toString());
    fontStyle = value;
    notifyListeners();
  }

  void applyAppearance({required AppTheme theme, required int fontStyle}) {
    if (fontStyle < 0 || fontStyle > 2) {
      throw ArgumentError('Unknown font style');
    }
    if (this.theme == theme && this.fontStyle == fontStyle) return;
    this.theme = theme;
    this.fontStyle = fontStyle;
    notifyListeners();
  }

  Future<void> setStatisticsTimezone(String value) async {
    Statistics.calculate(const [], value);
    await _savePreference('statisticsTimezone', value);
    statisticsTimezone = value;
    notifyListeners();
  }

  Future<void> setClockTimezone(String value) async {
    Statistics.calculate(const [], value);
    await _savePreference('clockTimezone', value);
    clockTimezone = value;
    notifyListeners();
  }

  Future<void> setDurations(Duration focus, Duration rest) async {
    if (focus.inMinutes <= 0 || rest.inMinutes <= 0) {
      throw ArgumentError('Durations must be positive');
    }
    await _savePreference('focusMinutes', focus.inMinutes.toString());
    await _savePreference('breakMinutes', rest.inMinutes.toString());
    focusDuration = focus;
    breakDuration = rest;
    notifyListeners();
  }

  Future<TaskRecord> createTask(String name) async {
    final task = TaskCatalog.create(
      id: const Uuid().v4(),
      ownerId: ownerId,
      name: name,
      existing: _tasks,
    );
    final store = repository;
    if (store != null) {
      await store.upsertTask(task, operationId: const Uuid().v4());
    }
    _tasks.add(task);
    notifyListeners();
    return task;
  }

  Future<void> renameTask(TaskRecord task, String name) async {
    final changed = TaskCatalog.rename(task, name, _tasks);
    final store = repository;
    if (store != null) {
      await store.upsertTask(changed, operationId: const Uuid().v4());
    }
    _tasks = [for (final item in _tasks) item.id == task.id ? changed : item];
    notifyListeners();
  }

  Future<void> deleteTask(TaskRecord task) async {
    final change = TaskCatalog.delete(task, _sessions, clock());
    final store = repository;
    if (store != null) {
      await store.upsertTask(change.task, operationId: const Uuid().v4());
      for (final session in change.sessions) {
        if (session.taskId == null &&
            _sessions.any(
              (old) => old.id == session.id && old.taskId == task.id,
            )) {
          await store.upsertSession(session, operationId: const Uuid().v4());
        }
      }
    }
    _tasks = [
      for (final item in _tasks) item.id == task.id ? change.task : item,
    ];
    _sessions = change.sessions;
    notifyListeners();
  }

  Map<String, dynamic> _cloudSnapshot(TimerState state) => {
    'ownerId': ownerId,
    'startedAt': state.startedAt.toIso8601String(),
    'lastObservedAt': state.lastObservedAt.toIso8601String(),
    'mode': state.mode.name,
    'phase': state.phase.name,
    'creditedMicroseconds': state
        .creditedFocusAt(state.lastObservedAt)
        .inMicroseconds,
  };

  Future<void> restoreCloudLock() async {
    final gateway = cloud;
    final state = activeTimer;
    if (gateway == null || state == null || state.phase == TimerPhase.ended) {
      return;
    }
    final result = await gateway.inspectTimer();
    if (!result.isSuccess) return;
    if (result.data?['active'] == true &&
        (result.data?['snapshot'] as Map?)?['startedAt'] ==
            state.startedAt.toIso8601String()) {
      _cloudRevision = result.data?['revision'] as int?;
    } else if (result.data?['active'] == true) {
      setSyncMessage('其他设备已有计时，当前本机计时待核对');
    }
  }

  Future<void> reconcileCloudLock() async {
    await releaseCloudLockIfEnded();
    final gateway = cloud;
    final state = activeTimer;
    if (gateway == null ||
        state == null ||
        state.phase == TimerPhase.ended ||
        _cloudRevision != null) {
      return;
    }
    final inspected = await gateway.inspectTimer();
    if (!inspected.isSuccess) return;
    if (inspected.data?['active'] == true) {
      if ((inspected.data?['snapshot'] as Map?)?['startedAt'] ==
          state.startedAt.toIso8601String()) {
        _cloudRevision = inspected.data?['revision'] as int?;
      } else {
        setSyncMessage('其他设备已有计时，当前本机计时待核对');
      }
      return;
    }
    final claimed = await gateway.claimTimer(
      _cloudSnapshot(state),
      const Uuid().v4(),
    );
    if (claimed.isSuccess) {
      _cloudRevision = claimed.data?['revision'] as int?;
    } else if (claimed.status == CloudStatus.conflict) {
      setSyncMessage('其他设备已有计时，当前本机计时待核对');
    }
  }

  Future<void> updateCloudSnapshot() async {
    final gateway = cloud;
    final revision = _cloudRevision;
    final state = activeTimer;
    if (gateway == null ||
        revision == null ||
        state == null ||
        state.phase == TimerPhase.ended) {
      return;
    }
    final result = await gateway.updateTimer(_cloudSnapshot(state), revision);
    if (result.isSuccess) {
      _cloudRevision = result.data?['revision'] as int? ?? revision;
    } else if (result.status == CloudStatus.conflict) {
      setSyncMessage('云端计时状态冲突，请检查其他设备');
    } else if (result.status == CloudStatus.offline) {
      setSyncMessage('离线计时，稍后同步');
    }
  }

  Future<void> _claimOnline(TimerState state) async {
    final gateway = cloud;
    if (gateway == null) return;
    _cloudRevision = null;
    await releaseCloudLockIfEnded();
    final result = await gateway.claimTimer(
      _cloudSnapshot(state),
      const Uuid().v4(),
    );
    if (result.status == CloudStatus.conflict) {
      throw StateError('Another device is already timing');
    }
    if (result.status == CloudStatus.unauthenticated ||
        result.status == CloudStatus.permissionDenied) {
      throw StateError('Account cannot claim timer');
    }
    if (result.isSuccess) {
      _cloudRevision = result.data?['revision'] as int?;
    }
    if (result.status == CloudStatus.offline) {
      setSyncMessage('离线计时，稍后同步');
    }
  }

  Future<void> _persistClaimedStart(TimerState state) async {
    await _claimOnline(state);
    try {
      await _saveTimer(state);
    } catch (_) {
      if (_cloudRevision != null) {
        await cloud?.releaseTimer(
          const Uuid().v4(),
          startedAt: state.startedAt.toIso8601String(),
        );
        _cloudRevision = null;
      }
      rethrow;
    }
  }

  Future<TimerState> startElapsed(String? taskId) async {
    _ensureNoActiveTimer();
    final state = engine.startElapsed(taskId: taskId, at: clock());
    await _persistClaimedStart(state);
    return state;
  }

  Future<TimerState> startPomodoro(String taskId) async {
    _ensureNoActiveTimer();
    final state = engine.startPomodoro(
      taskId: taskId,
      focus: focusDuration,
      rest: breakDuration,
      at: clock(),
    );
    await _persistClaimedStart(state);
    return state;
  }

  void _ensureNoActiveTimer() {
    if (activeTimer != null && activeTimer!.phase != TimerPhase.ended) {
      throw StateError('A timer is already active');
    }
  }

  Future<void> _saveTimer(TimerState state) async {
    final store = repository;
    if (store != null) {
      await store.saveTimer(state, operationId: const Uuid().v4());
    }
    activeTimer = state;
    notifyListeners();
    await updateCloudSnapshot();
  }

  Future<void> advanceTimer() async {
    final state = activeTimer;
    if (state == null || state.phase == TimerPhase.ended) return;
    final next = engine.advance(state, at: clock());
    if (next.phase != state.phase || next.clockWarning != state.clockWarning) {
      await _saveTimer(next);
      _lastCheckpoint = next.lastObservedAt;
      return;
    }
    activeTimer = next;
    final last = _lastCheckpoint;
    if (repository != null &&
        (last == null ||
            next.lastObservedAt.difference(last) >=
                const Duration(seconds: 30))) {
      await repository!.checkpointTimer(next);
      _lastCheckpoint = next.lastObservedAt;
    }
    notifyListeners();
  }

  Future<void> pauseTimer() async {
    final state = activeTimer;
    if (state == null) return;
    await _saveTimer(engine.pause(state, at: clock()));
  }

  Future<void> resumeTimer() async {
    final state = activeTimer;
    if (state == null) return;
    await _saveTimer(engine.resume(state, at: clock()));
  }

  Future<void> nextRound() async {
    final state = activeTimer;
    if (state == null) return;
    await _saveTimer(engine.nextRound(state, at: clock()));
  }

  Future<void> finishBreak() async {
    final state = activeTimer;
    if (state == null) return;
    await _saveTimer(engine.finishBreak(state, at: clock()));
  }

  Future<void> endTimer() async {
    final state = activeTimer;
    if (state == null) return;
    final ended = engine.end(state, at: clock());
    final session = FocusSession(
      id: 'focus-$ownerId-${state.startedAt.microsecondsSinceEpoch}',
      ownerId: ownerId,
      taskId: state.taskId,
      mode: state.mode,
      focusSegments: ended.focusSegments,
      revision: 0,
    );
    final store = repository;
    if (store != null) {
      await store.finishTimer(
        ended,
        session,
        sessionOperationId: const Uuid().v4(),
        timerOperationId: const Uuid().v4(),
        queueCloudRelease: cloud != null,
      );
    }
    _sessions = [
      for (final existing in _sessions)
        if (existing.id != session.id) existing,
      session,
    ];
    activeTimer = ended;
    notifyListeners();
    await releaseCloudLockIfEnded();
  }

  Future<void> releaseCloudLockIfEnded() async {
    final gateway = cloud;
    if (gateway == null) return;
    final store = repository;
    final pending = store == null
        ? <String, String>{
            if (activeTimer?.phase == TimerPhase.ended)
              'inMemory': activeTimer!.startedAt.toIso8601String(),
          }
        : await store.pendingCloudReleases();
    for (final entry in pending.entries) {
      final inspected = await gateway.inspectTimer();
      if (!inspected.isSuccess) return;
      if (inspected.data?['active'] == true &&
          (inspected.data?['snapshot'] as Map?)?['startedAt'] == entry.value) {
        final released = await gateway.releaseTimer(
          const Uuid().v4(),
          startedAt: entry.value,
        );
        if (!released.isSuccess) return;
      }
      await store?.acknowledgeCloudRelease(entry.key);
      if (activeTimer?.startedAt.toIso8601String() == entry.value) {
        _cloudRevision = null;
      }
    }
  }

  Future<void> updateSession(FocusSession session) async {
    final store = repository;
    if (store != null) {
      await store.upsertSession(session, operationId: const Uuid().v4());
    }
    _sessions = [
      for (final item in _sessions) item.id == session.id ? session : item,
    ];
    notifyListeners();
  }
}

class TimerApp extends StatelessWidget {
  const TimerApp({
    super.key,
    required this.services,
    this.onAccount,
    this.onSync,
    this.conflicts = const [],
    this.onResolveConflict,
    this.onResolveRevision,
  });
  final AppServices services;
  final Future<void> Function(BuildContext)? onAccount;
  final Future<void> Function()? onSync;
  final List<SyncConflict> conflicts;
  final Future<void> Function(String, String)? onResolveConflict;
  final Future<void> Function(bool)? onResolveRevision;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: services,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timer',
      theme: AppAppearance.themeFor(services.theme),
      home: LauncherPage(
        services: services,
        onAccount: onAccount,
        onSync: onSync,
        conflicts: conflicts,
        onResolveConflict: onResolveConflict,
        onResolveRevision: onResolveRevision,
      ),
    ),
  );
}
