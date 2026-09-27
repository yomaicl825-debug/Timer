# Timer V1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship an open-source Windows and Android study timer with private accounts, offline records, cross-device synchronization, a detached Windows timer window, and GitHub downloads.

**Architecture:** A Flutter client keeps an authoritative local SQLite record and a deterministic timer state machine. A CloudBase adapter synchronizes user-owned data and arbitrates the one active focus timer; UI layers observe local state. Windows opens a second native window for immersion, while Android uses a full-screen route.

**Tech Stack:** Flutter/Dart; Drift + SQLite for local data; `cloudbase_flutter` for authentication and cloud calls; `desktop_multi_window` for Windows; CloudBase cloud functions and document storage; GitHub Actions for checks and release builds.

**Spec:** `docs/superpowers/specs/2026-09-27-timer-design.md`; user-facing summary: `docs/superpowers/specs/2026-09-27-timer-design-zh.md`.

## Global Constraints

- Trial targets: Windows and Android. iPhone is later; no web client in V1.
- The source is public under MIT; no credentials, signing keys, or administrator secrets enter Git.
- Main task list shows only task name and all-time cumulative focus duration.
- Clock date format is `YYYY / MM / DD`; weekdays are short English names; account statistics timezone defaults to `Asia/Shanghai`.
- Three display modes: clock, unbounded elapsed focus, and Pomodoro focus/break. Clock and breaks do not count as focus.
- Pomodoro break ends in a waiting state; the next focus never starts unattended. No long break, sound, or system notification in V1.
- Pause/resume/early end and application-close recovery preserve actual focus time. One online active focus timer per account.
- Offline changes queue locally; overlapping offline sessions require explicit reconciliation before totals include both.
- Tests must cover time math, statistics, edits, offline sync, cloud ownership, and Windows/Android smoke paths.

## Review Focus

- Device wall clock moves backwards during a running session: credited duration stays nonnegative and the app surfaces a recoverable clock warning (Task 2 test).
- A different account signs in on a shared device: cached tasks and sessions from the prior account never appear (Task 4 test).
- A user enters an empty task name or a zero-minute Pomodoro duration: the form rejects it without starting a timer (Task 3 and Task 9 tests).
- A focus interval crosses a daylight-saving transition: calendar allocation follows the account's IANA timezone and still sums to the true elapsed duration (Task 3 test).
- A study session runs beyond 99 hours: the timer remains legible as hours, minutes, seconds without wrapping (Task 8 test).

## File map

`lib/domain/timer/` owns time math and phase transitions. `lib/domain/records/` owns task/session identity and calendar allocation. `lib/data/local/` owns Drift tables and transactional repositories. `lib/data/cloud/` owns CloudBase requests. `lib/data/sync/` owns the upload queue and conflict resolution. `lib/features/launcher/`, `timer/`, `profile/`, and `auth/` own their respective screens. `lib/platform/` owns native-window behavior. `cloudbase/functions/` and `cloudbase/rules/` hold backend logic and access rules. `test/` mirrors each unit. `integration_test/` holds a navigation smoke test.

---

### Task 1: Project bootstrap and runnable shell

**Files:** Create `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, `lib/app.dart`, `test/app_smoke_test.dart`, `.gitignore`, `LICENSE`, `README.md`; generated Flutter platform folders `android/` and `windows/`.

**Interfaces:** Produces `TimerApp({required AppServices services})` and `AppServices` in `lib/app.dart`. Later tasks inject repositories and platform services through `AppServices`; no screen instantiates network clients directly.

- [ ] **Step 1: Verify the toolchain.** Run `flutter doctor -v`, `flutter devices`, `git status --short`, and confirm Android SDK plus Visual Studio Windows desktop components. Record missing components in README setup instructions.
- [ ] **Step 2: Scaffold and add a failing shell test.** Run `flutter create --platforms=android,windows .`; add a widget test that pumps `TimerApp(services: AppServices.fake())` and expects `find.text('新建任务')` and `find.text('个人主页')`.
- [ ] **Step 3: Run `flutter test test/app_smoke_test.dart` and confirm the missing app types or labels fail.**
- [ ] **Step 4: Add the minimal shell.** `main()` loads services, then calls `runApp(TimerApp(services: services))`; `TimerApp` renders `MaterialApp(home: LauncherPage(services: services))`, with task creation and profile entry as visible controls. Keep `AppServices.fake()` in test support, not production credentials.
- [ ] **Step 5: Run `flutter analyze` and the widget test. Commit as `chore: scaffold timer app`.**

### Task 2: Deterministic timer engine

**Files:** Create `lib/domain/timer/timer_state.dart`, `lib/domain/timer/timer_engine.dart`, `test/domain/timer_engine_test.dart`.

**Interfaces:** `TimerEngine.startElapsed({String? taskId, required DateTime at}) -> TimerState`; `startPomodoro({required String taskId, required Duration focus, required Duration rest, required DateTime at}) -> TimerState`; `pause`, `resume`, `end`, `advance` each return a new `TimerState`; `TimerState.creditedFocusAt(DateTime at) -> Duration`. `TimerState` stores UTC instants, accumulated focus, active segment start, phase, focus/rest defaults, and round index.

- [ ] **Step 1: Write failing tests** for elapsed pause/resume, early end, a focus deadline moving to break, a completed break moving to waiting, early break end, restoration after a six-hour process gap, and a wall clock correction backwards while running. Assert that credited focus never becomes negative.
- [ ] **Step 2: Run `flutter test test/domain/timer_engine_test.dart`; confirm assertions fail before implementation.**
- [ ] **Step 3: Implement immutable transitions.** In `advance(state, at)`, cap Pomodoro focus at its deadline, create the break at that exact deadline, then cap the break at its deadline and enter waiting. For elapsed focus, add `at.difference(activeSegmentStart)` only while active. `pause` closes a focus segment; `resume` starts a new one. Clamp a backwards wall-clock correction to the last valid instant and expose a recoverable warning. Reject negative durations and transitions from a stopped state.
- [ ] **Step 4: Run the timer tests and `flutter analyze`; commit as `feat: add deterministic timer engine`.**

### Task 3: Tasks, sessions, and calendar calculations

**Files:** Create `lib/domain/records/task.dart`, `session.dart`, `statistics.dart`, `test/domain/statistics_test.dart`, `test/domain/record_edit_test.dart`.

**Interfaces:** `TaskRecord(id, ownerId, name, deletedAt)`; `FocusSession(id, ownerId, taskId, mode, focusSegments, creditedOverride, revision, deletedAt)`; `Statistics.calculate(Iterable<FocusSession>, String timezoneId) -> StatisticsSnapshot`. `StatisticsSnapshot` exposes daily totals, Monday-based weekly totals, monthly totals, and per-task all-time totals.

- [ ] **Step 1: Write failing tests** for duplicate and blank task name rejection, rename preserving session association, delete moving sessions to unassigned, session edit/delete changing totals, a session crossing midnight in `Asia/Shanghai` splitting correctly between two dates, and a daylight-saving boundary preserving total elapsed focus.
- [ ] **Step 2: Run the two domain test files; confirm expected failures.**
- [ ] **Step 3: Implement record operations and allocation.** Split each UTC focus segment at midnight boundaries of the selected statistics timezone. If a user overrides a credited duration, distribute it proportionally over that session's original focus segments, with remainder on the last segment. Aggregate by date and task ID; never count breaks.
- [ ] **Step 4: Run both test files and `flutter analyze`; commit as `feat: calculate task and calendar totals`.**

### Task 4: Local persistence and offline mutation queue

**Files:** Create `lib/data/local/app_database.dart`, `local_repository.dart`, `pending_change.dart`, `test/data/local_repository_test.dart`; generated Drift file `app_database.g.dart`.

**Interfaces:** `LocalRepository.saveTimer(TimerState)`, `loadTimer()`, `upsertTask(TaskRecord)`, `upsertSession(FocusSession)`, `watchTasks()`, `watchSessions()`, `pendingChanges()`, `acknowledgeChange(id)`; each mutation writes its record and a unique operation ID in one SQLite transaction.

- [ ] **Step 1: Add Drift, SQLite native libraries, path provider, and code generation dependencies, then write failing in-memory database tests** for atomic record-plus-queue writes, reload after repository recreation, duplicate operation IDs, and signing out then signing in as another account without exposing the previous account's cache.
- [ ] **Step 2: Run `flutter test test/data/local_repository_test.dart`; confirm failures.**
- [ ] **Step 3: Implement tables** for tasks, sessions, timer snapshots, settings, and pending changes. Use UUID primary keys, UTC timestamp columns, JSON-encoded focus segments, unique `(owner_id, normalized_task_name)` for active tasks, and a unique operation ID. Every repository query filters by current owner ID; account switching closes the prior database view before loading another account. Run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] **Step 4: Run repository tests and `flutter analyze`; commit as `feat: persist timers and offline changes`.**

### Task 5: CloudBase account and owner-only data contract

**Files:** Create `lib/data/cloud/cloudbase_gateway.dart`, `lib/features/auth/auth_page.dart`, `cloudbase/rules/owner-rules.json`, `cloudbase/functions/timer-command/index.js`, `cloudbase/functions/timer-command/package.json`, `test/data/cloudbase_gateway_test.dart`, `cloudbase/README.md`.

**Interfaces:** `CloudGateway.signUp(email,password)`, `signIn(email,password)`, `currentUser()`, `pullSince(cursor)`, `pushChanges(changes)`, `claimTimer(snapshot, operationId)`, `updateTimer(snapshot, expectedRevision)`, `releaseTimer(operationId)`. Return typed `CloudResult` values: success, unauthenticated, offline, revision conflict, and permission denied.

- [ ] **Step 1: Write failing gateway tests** with a fake CloudBase transport for sign-in errors, owner filtering, idempotent operation retries, and a second online timer claim being rejected.
- [ ] **Step 2: Run the gateway tests; confirm failures.**
- [ ] **Step 3: Implement the adapter** using `cloudbase_flutter` authentication and document APIs. Read only non-secret environment ID and client configuration at build time. The timer-command cloud function checks authenticated UID, atomically compares the active timer revision, then writes or rejects the command; duplicate operation IDs return the earlier result. Rules deny unauthenticated access and require document `ownerId` to equal authenticated UID for reads and writes.
- [ ] **Step 4: Run unit tests. In a CloudBase test environment, verify user A cannot read or write user B's task/session and two simultaneous claims yield one success. Document environment setup without exposing secrets. Commit as `feat: add private CloudBase account contract`.**

### Task 6: Synchronization and offline collision handling

**Files:** Create `lib/data/sync/sync_coordinator.dart`, `sync_conflict.dart`, `test/data/sync_coordinator_test.dart`.

**Interfaces:** `SyncCoordinator.syncNow() -> SyncReport`; `watchStatus() -> Stream<SyncStatus>`; `resolveOverlap(conflictId, winningSessionId)`. `SyncReport` includes applied, queued, and conflicted operation counts. The UI can display a concise sync badge outside full-screen mode.

- [ ] **Step 1: Write failing tests** for offline queue retention, reconnect upload, idempotent retry after timeout, remote revision refresh, and two overlapping offline intervals being withheld from combined totals until resolved.
- [ ] **Step 2: Run `flutter test test/data/sync_coordinator_test.dart`; confirm failures.**
- [ ] **Step 3: Implement ordered sync.** Pull remote revisions, compare operation IDs, upload pending local changes, acknowledge only confirmed operations, and persist overlap conflicts locally. `resolveOverlap` keeps the selected interval, marks the rejected one superseded, and queues both changes for cloud sync. Network errors leave the queue untouched.
- [ ] **Step 4: Run sync tests and full `flutter test`; commit as `feat: synchronize offline focus records`.**

### Task 7: Launcher and task actions

**Files:** Create `lib/features/launcher/launcher_page.dart`, `task_row.dart`, `task_editor.dart`, `test/features/launcher_test.dart`; modify `lib/app.dart`.

**Interfaces:** `LauncherPage(services)` reads task and timer streams; row actions invoke `AppServices.startElapsed(taskId)` or `startPomodoro(taskId)`; generic start invokes `startElapsed(null)`; clock entry invokes `openClock()`.

- [ ] **Step 1: Write failing widget tests** for only task name plus all-time duration in each row, generic unassigned start, named mode choice, duplicate-name validation, and the separate personal-page entry.
- [ ] **Step 2: Run launcher tests; confirm failures.**
- [ ] **Step 3: Implement a restrained launcher** with task list and four small actions: new task, generic start, clock, and personal page. Keep task management behind a contextual action rather than adding statistics to each row.
- [ ] **Step 4: Run launcher widget tests and `flutter analyze`; commit as `feat: add minimal task launcher`.**

### Task 8: Immersive timer and Windows independent window

**Files:** Create `lib/features/timer/timer_page.dart`, `clock_page.dart`, `timer_controls.dart`, `lib/platform/timer_window.dart`, `test/features/timer_page_test.dart`; modify `lib/main.dart`, `windows/runner/flutter_window.cpp` for plugin registration.

**Interfaces:** `TimerWindow.open(TimerViewArgs args)`, `setCompact(bool compact)`, `close()`; Windows adapter uses `desktop_multi_window` and window method channels; Android adapter pushes a full-screen route. Both render the same timer view model backed by persisted timer state.

- [ ] **Step 1: Write failing widget tests** for `YYYY / MM / DD`, abbreviated English weekday, timezone corner control, clock not creating a session, pause/resume/end controls, waiting-after-break prompt, and an elapsed display of `123:04:05` without wrapping.
- [ ] **Step 2: Run timer widget tests; confirm failures.**
- [ ] **Step 3: Implement clock and timer views** with central tabular numerals, auto-updated display from stored timestamps, dark/light themes, and in-app-only transition prompts. Implement Windows second-engine plugin registration and use a method channel plus local repository changes to refresh its view; prevent a duplicate timer window. Compact mode is movable, full-screen mode has minimal controls.
- [ ] **Step 4: Run widget tests, `flutter analyze`, and a Windows smoke run that opens, compacts, restores, and closes the timer window while the launcher remains open. Commit as `feat: add immersive timer window`.**

### Task 9: Personal page, history editing, and preferences

**Files:** Create `lib/features/profile/profile_page.dart`, `calendar_view.dart`, `session_editor.dart`, `preferences_page.dart`, `test/features/profile_test.dart`.

**Interfaces:** `ProfilePage(services)` observes `StatisticsSnapshot`; `SessionEditor.save(taskId, creditedDuration)` and `delete()` call local repository transactions; preferences persist `theme`, `fontStyle`, `statisticsTimezone`, `clockTimezone`, `focusDuration`, `breakDuration`.

- [ ] **Step 1: Write failing widget tests** for daily/weekly/monthly totals, desktop hover and mobile tap day detail, task reassignment, edit/delete changing displayed totals, theme/font switch, saved Pomodoro durations, and rejection of zero or negative durations.
- [ ] **Step 2: Run profile tests; confirm failures.**
- [ ] **Step 3: Implement a separate personal page** with calendar and session list. Keep cloud errors and sync status here or in the launcher, never as timer overlays. Persist settings locally and queue their cloud updates.
- [ ] **Step 4: Run profile tests and full `flutter test`; commit as `feat: add private study history and settings`.**

### Task 10: End-to-end verification and GitHub trial release

**Files:** Create `integration_test/study_flow_test.dart`, `.github/workflows/check.yml`, `.github/workflows/release.yml`, `docs/installation.md`, `docs/privacy.md`, `docs/cloudbase-setup.md`, `CHANGELOG.md`; modify `README.md`, Android release signing configuration, and Windows packaging script `scripts/package-windows.ps1`.

**Interfaces:** GitHub Releases attach a versioned Android APK, a Windows installer, SHA-256 checksums, and release notes. The build pipeline reads signing material from protected secrets, not source files.

- [ ] **Step 1: Write an integration test** for sign-in using a test gateway, create task, start elapsed mode, pause/resume/end, reassign the session, and view its calendar total. Add a deterministic clock to avoid waiting in real time.
- [ ] **Step 2: Run `flutter test` and the integration test on available Windows/Android targets; investigate concrete failures.**
- [ ] **Step 3: Add CI** for formatting, static analysis, unit/widget tests, Windows build, and Android build. Add packaging and checksums, with a documented local signing path and protected CI signing variables. Document APK source-install steps, Windows publisher warnings if unsigned, CloudBase setup, account privacy, and backup/export limitations.
- [ ] **Step 4: Run `flutter analyze`, `flutter test`, `flutter build windows --release`, `flutter build apk --release`, package checks, and the available UI smoke tests. Review the artifact contents for secrets.**
- [ ] **Step 5: Commit as `build: prepare Windows and Android trial release`; push the public repository and create a GitHub prerelease with verified downloads. Attach the repository/release link to the task.**

## Plan self-review

The ten tasks cover every section of both specs: launcher and detached timer; three modes; Pomodoro transition policy; task/history edits and calendar math; private email accounts; offline local records and reconciliation; cross-device singleton; themes/timezones/fonts; Windows and Android packaging. Before implementation, check the exact Flutter SDK and package versions in the available toolchain, then lock them in `pubspec.lock`. An unavailable Android SDK, CloudBase environment, GitHub authentication, or signing key is a release dependency to report precisely; it does not justify skipping locally testable tasks.
