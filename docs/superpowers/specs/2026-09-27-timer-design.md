# Timer: product and architecture design

Date: 2026-09-27  
Status: approved in conversation; written review pending  
Working product name: Timer

## Purpose and release scope

Timer is a quiet study timer for the creator, family members, classmates, and other people with similar needs. It records focus time over long periods, including a year of exam preparation, without setting target hours or deadlines. Each person's records are private. The first downloadable trial release targets Windows and Android. A later public release will add iPhone through Apple's distribution process. There is no web client in the first release.

The source repository is public under the MIT license. The first GitHub release will contain Windows and Android downloads and instructions. The final product name may replace the working name before the first release without changing the scope.

## User experience

The main window is a restrained launcher. It shows tasks as name plus all-time cumulative focus duration, and provides actions to create a task, start unassigned study time, open a full-screen clock, and open the personal page. Starting a named task offers elapsed-time study or Pomodoro. Starting unassigned study immediately enters elapsed-time mode; the record can be assigned after finishing.

On Windows, the timer opens in an independent window while the launcher remains available. The timer window starts full screen and can be reduced to a movable compact window. Android opens the equivalent immersive timer screen. The full-screen layout follows concept A: large centered numerals, black-on-white or white-on-black theme, ample empty space, and small controls. The personal page contains theme and font-style settings: standard sans-serif, narrow sans-serif, and monospaced numerals. These settings persist per account and work offline.

The clock mode shows the current time in a manually selectable IANA timezone and does not create a focus record or claim the account's one active focus timer. Its timezone control remains in a corner. Date uses `YYYY / MM / DD`; weekday uses a short English name such as `Sun`. Clock and timer screens avoid Chinese text where icons or short labels suffice. Clock timezone selection changes the display only; it does not change the account's statistics timezone. The account's statistics timezone defaults to `Asia/Shanghai` and can be changed in personal settings.

The personal page is a separate destination, not a side panel on the timer. It shows daily, weekly, and monthly focus totals, a calendar, and session history. Desktop hover and mobile tap reveal a day's total. A day detail shows constituent sessions and their tasks. The week begins on Monday. No goals, streak rewards, or social comparison are in the first release.

## Timer rules

Elapsed study time and Pomodoro focus time count toward records. A session may be paused, resumed, or ended early; paused intervals never count. Ending early saves actual focus duration. Unassigned elapsed sessions remain visible in history and the overall totals until assigned to a task. Breaks and clock display do not count as focus.

The user stores one default focus duration and one default break duration in settings. The first release has no long break. When a Pomodoro focus interval finishes, the app records its actual focus time and automatically starts a break. When the break finishes, the app displays an in-app prompt and waits; it never begins the next focus interval without confirmation. A break can be ended early, followed by a choice to start the next interval or end the cycle. Transition messages are in-app only; there is no sound or system notification in the first release.

Timer state is persisted from start and pause/resume timestamps rather than counting UI ticks. If an application closes or a device sleeps during active focus, elapsed wall time continues to count and the view reconstructs the correct duration when reopened. A completed Pomodoro break reconstructs to the waiting-for-confirmation state, so unattended time after that break cannot become focus time. The same rule holds when the app is offline.

## Tasks, history, and statistics

Task names are unique within an account. Each task has a stable internal ID, so renaming it updates labels without rewriting history. Deleting a task leaves its sessions as unassigned for later reassignment. The task list displays all-time cumulative focus duration; there is no target duration or deadline.

Each focus record stores the account, task ID or unassigned state, mode, start/end instants, focus intervals, and revision information. Users can edit a record's task and credited time, or delete the record. Edits and deletion immediately update local totals and synchronize later. Daily totals split a session at local midnight in the account's statistics timezone; week and month totals aggregate those daily allocations. Changing the statistics timezone recalculates calendar groupings from the stored instants.

## Accounts, privacy, and synchronization

CloudBase supplies email/password authentication, storage, and server-side coordination for the trial release. Its Flutter SDK covers Windows, Android, and future iOS. Only authenticated owners can read or change their tasks, sessions, settings, and timer state. Credentials and administrative secrets remain outside the public repository and release binaries. Client-visible configuration contains only values intended to be public; authorization relies on server rules, not hidden client keys. Other sign-in methods can later be linked to an existing account.

A local database stores tasks, sessions, settings, active timer timestamps, and an ordered queue of unsynced changes. Users with a previously authenticated session can time and review records offline. On reconnection, queued changes synchronize and other devices refresh. Online starts use an atomic server operation to enforce one active timer per account; every signed-in device observes that timer's state. If two devices create overlapping offline timers, synchronization flags the overlap and asks the user which interval is valid. Neither interval is silently double-counted. A recoverable sync error keeps local changes queued and makes sync status visible in the main window and personal page, never as a full-screen interruption.

## Architecture

The Flutter application separates: (1) timer state machine and time calculations, (2) tasks and history domain logic, (3) local persistence and sync queue, (4) CloudBase adapter and authorization, and (5) presentation for launcher, timer window, and personal page. Timer calculations depend on an injectable clock for deterministic tests. UI observes persisted state; it does not own authoritative elapsed time. Platform adapters handle Windows' independent timer window and Android's immersive screen. The CloudBase adapter is replaceable without changing timer or statistics logic.

Cloud operations that must be atomic, especially claiming or releasing the one active timer and reconciling revisions, run server-side. Ownership checks are enforced on every cloud collection or endpoint. No public repository content contains signing keys, email credentials, or service administrator keys.

## Delivery and verification

The repository includes setup instructions, privacy description, MIT license, sample non-secret configuration, and reproducible build commands. The first release attaches a Windows build and a signed Android APK to GitHub Releases. Windows and Android users can download from GitHub; store submissions and iOS distribution are later work. Signing credentials are supplied privately during release preparation, never committed.

Verification covers timer pause/resume and early end, Pomodoro phase transitions, reconstruction after app close and sleep, midnight and timezone aggregation, edit/delete/reassignment of records, local offline operation, online single-timer enforcement, and offline overlap resolution. Windows UI and Android UI receive smoke tests on available devices or emulators. If a platform build or cloud deployment cannot be verified in the current environment, the release notes state that limitation explicitly instead of claiming it passed.
