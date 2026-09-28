// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profile => 'Profile';

  @override
  String get calendar => 'Calendar';

  @override
  String get tasks => 'Tasks';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get newTask => 'New task';

  @override
  String get startLearning => 'Start learning';

  @override
  String get fullClock => 'Full-screen clock';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get yourTasks => 'Your tasks';

  @override
  String get emptyTasks => 'Add a task to begin focusing';

  @override
  String get resumeCurrent => 'Resume timer';

  @override
  String get timerActive =>
      'A timer is running. End it before starting another.';

  @override
  String get elapsed => 'Elapsed timer';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get taskName => 'Task name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get duplicateTask => 'A task with this name already exists';

  @override
  String get enterTask => 'Enter a task name';

  @override
  String get renameTask => 'Rename task';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get expandNav => 'Expand navigation';

  @override
  String get collapseNav => 'Collapse navigation';

  @override
  String get today => 'Today';

  @override
  String get week => 'This week';

  @override
  String get month => 'This month';

  @override
  String get revisionConflict => 'This record was changed on two devices';

  @override
  String get localLabel => 'Local: ';

  @override
  String get remoteLabel => 'Cloud: ';

  @override
  String get keepLocal => 'Keep local version';

  @override
  String get keepRemote => 'Keep cloud version';

  @override
  String get overlaps => 'Overlapping records';

  @override
  String get chooseOverlap =>
      'Offline study sessions overlap. Choose the record to keep.';

  @override
  String get keepLabel => 'Keep ';

  @override
  String get emptyHistory => 'No records yet';

  @override
  String get noManagedTasks => 'No tasks yet. Add one on the task page.';

  @override
  String get manageTask => 'Manage task';

  @override
  String get rename => 'Rename';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get openNav => 'Open navigation';

  @override
  String get backToTasks => 'Back to tasks';

  @override
  String get sync => 'Sync';

  @override
  String get resolveConflicts => 'Resolve conflicts';

  @override
  String get appearance => 'Appearance';

  @override
  String get lightTheme => 'White background · Black text';

  @override
  String get darkTheme => 'Black background · White text';

  @override
  String get grayTheme => 'Deep gray · Soft gray text';

  @override
  String get oldGrayTheme => 'Deep gray · Soft gray text';

  @override
  String get digitFont => 'Clock font';

  @override
  String get thinFont => 'Light';

  @override
  String get monoFont => 'Monospace';

  @override
  String get serifFont => 'Serif';

  @override
  String get focusMinutes => 'Focus minutes';

  @override
  String get breakMinutes => 'Break minutes';

  @override
  String get saveDurations => 'Save durations';

  @override
  String get statisticsZone => 'Statistics time zone';

  @override
  String get clockZone => 'Default clock time zone';

  @override
  String get saveZones => 'Save time zones';

  @override
  String get durationPositive => 'Durations must be greater than zero';

  @override
  String get invalidZone => 'Invalid time zone name';

  @override
  String get invalidZoneShort => 'Invalid time zone';

  @override
  String get editRecord => 'Edit record';

  @override
  String get task => 'Task';

  @override
  String get creditedDuration => 'Credited duration HH:MM:SS';

  @override
  String get deleteRecord => 'Delete record';

  @override
  String get durationFormat => 'Enter a duration as HH:MM:SS';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get noTimer => 'No active timer';

  @override
  String get waiting => 'Waiting for the next round';

  @override
  String get ended => 'Ended';

  @override
  String get closeTimer => 'Close timer window';

  @override
  String get compact => 'Toggle window size';

  @override
  String get clockWarning =>
      'The system clock moved backwards. Correct it before continuing.';

  @override
  String get breakFinished =>
      'Break finished. Start the next round when ready.';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get finishBreak => 'End break early';

  @override
  String get nextRound => 'Next round';

  @override
  String get end => 'End';

  @override
  String get timezone => 'Time zone';

  @override
  String get apply => 'Apply';

  @override
  String get back => 'Back';

  @override
  String get invalidCredentials =>
      'Enter a valid email and a password of at least 8 characters';

  @override
  String get checkEmail => 'Check your email and enter the verification code';

  @override
  String get networkUnavailable => 'Network unavailable';

  @override
  String get authFailed =>
      'Sign-in or verification failed. Check your details.';

  @override
  String get verifyEmail => 'Verify email';

  @override
  String get createAccount => 'Create account';

  @override
  String get signIn => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailCode => 'Email verification code';

  @override
  String get verify => 'Verify';

  @override
  String get register => 'Register';

  @override
  String get existingAccount => 'Have an account? Sign in';

  @override
  String get newAccount => 'No account? Sign up';

  @override
  String get cloudNotConfigured =>
      'Cloud accounts are not configured. Local timing is available.';

  @override
  String get timerNeedsReview =>
      'Another device is timing. Review the local timer.';

  @override
  String get timerConflict => 'Timer sync conflict. Check your other devices.';

  @override
  String get offlineTimer => 'Timing offline. Sync will resume later.';

  @override
  String get offlineRecords =>
      'Network unavailable. Records are saved locally.';

  @override
  String get pendingConflict => 'Sync conflicts need review';

  @override
  String get pendingSync => 'Records are waiting to sync';

  @override
  String get synced => 'Synced';

  @override
  String get syncFailed => 'Sync failed. Records are saved locally.';

  @override
  String get conflictChanged =>
      'The record changed. Choose how to resolve the conflict again.';

  @override
  String get language => 'Language / 语言';

  @override
  String get focusLabel => 'FOCUS';

  @override
  String get breakLabel => 'BREAK';

  @override
  String get elapsedLabel => 'ELAPSED';

  @override
  String get ianaTimezone => 'IANA time zone';
}
