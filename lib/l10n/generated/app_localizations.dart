import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get startLearning;

  /// No description provided for @fullClock.
  ///
  /// In en, this message translates to:
  /// **'Full-screen clock'**
  String get fullClock;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @yourTasks.
  ///
  /// In en, this message translates to:
  /// **'Your tasks'**
  String get yourTasks;

  /// No description provided for @emptyTasks.
  ///
  /// In en, this message translates to:
  /// **'Add a task to begin focusing'**
  String get emptyTasks;

  /// No description provided for @resumeCurrent.
  ///
  /// In en, this message translates to:
  /// **'Resume timer'**
  String get resumeCurrent;

  /// No description provided for @timerActive.
  ///
  /// In en, this message translates to:
  /// **'A timer is running. End it before starting another.'**
  String get timerActive;

  /// No description provided for @elapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed timer'**
  String get elapsed;

  /// No description provided for @pomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get pomodoro;

  /// No description provided for @taskName.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get taskName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @duplicateTask.
  ///
  /// In en, this message translates to:
  /// **'A task with this name already exists'**
  String get duplicateTask;

  /// No description provided for @enterTask.
  ///
  /// In en, this message translates to:
  /// **'Enter a task name'**
  String get enterTask;

  /// No description provided for @renameTask.
  ///
  /// In en, this message translates to:
  /// **'Rename task'**
  String get renameTask;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @expandNav.
  ///
  /// In en, this message translates to:
  /// **'Expand navigation'**
  String get expandNav;

  /// No description provided for @collapseNav.
  ///
  /// In en, this message translates to:
  /// **'Collapse navigation'**
  String get collapseNav;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get month;

  /// No description provided for @revisionConflict.
  ///
  /// In en, this message translates to:
  /// **'This record was changed on two devices'**
  String get revisionConflict;

  /// No description provided for @localLabel.
  ///
  /// In en, this message translates to:
  /// **'Local: '**
  String get localLabel;

  /// No description provided for @remoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Cloud: '**
  String get remoteLabel;

  /// No description provided for @keepLocal.
  ///
  /// In en, this message translates to:
  /// **'Keep local version'**
  String get keepLocal;

  /// No description provided for @keepRemote.
  ///
  /// In en, this message translates to:
  /// **'Keep cloud version'**
  String get keepRemote;

  /// No description provided for @overlaps.
  ///
  /// In en, this message translates to:
  /// **'Overlapping records'**
  String get overlaps;

  /// No description provided for @chooseOverlap.
  ///
  /// In en, this message translates to:
  /// **'Offline study sessions overlap. Choose the record to keep.'**
  String get chooseOverlap;

  /// No description provided for @keepLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep '**
  String get keepLabel;

  /// No description provided for @emptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get emptyHistory;

  /// No description provided for @noManagedTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Add one on the task page.'**
  String get noManagedTasks;

  /// No description provided for @manageTask.
  ///
  /// In en, this message translates to:
  /// **'Manage task'**
  String get manageTask;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @openNav.
  ///
  /// In en, this message translates to:
  /// **'Open navigation'**
  String get openNav;

  /// No description provided for @backToTasks.
  ///
  /// In en, this message translates to:
  /// **'Back to tasks'**
  String get backToTasks;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @resolveConflicts.
  ///
  /// In en, this message translates to:
  /// **'Resolve conflicts'**
  String get resolveConflicts;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'White background · Black text'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Black background · White text'**
  String get darkTheme;

  /// No description provided for @grayTheme.
  ///
  /// In en, this message translates to:
  /// **'Deep gray · Soft gray text'**
  String get grayTheme;

  /// No description provided for @oldGrayTheme.
  ///
  /// In en, this message translates to:
  /// **'Deep gray · Soft gray text'**
  String get oldGrayTheme;

  /// No description provided for @digitFont.
  ///
  /// In en, this message translates to:
  /// **'Clock font'**
  String get digitFont;

  /// No description provided for @thinFont.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get thinFont;

  /// No description provided for @monoFont.
  ///
  /// In en, this message translates to:
  /// **'Monospace'**
  String get monoFont;

  /// No description provided for @serifFont.
  ///
  /// In en, this message translates to:
  /// **'Serif'**
  String get serifFont;

  /// No description provided for @focusMinutes.
  ///
  /// In en, this message translates to:
  /// **'Focus minutes'**
  String get focusMinutes;

  /// No description provided for @breakMinutes.
  ///
  /// In en, this message translates to:
  /// **'Break minutes'**
  String get breakMinutes;

  /// No description provided for @saveDurations.
  ///
  /// In en, this message translates to:
  /// **'Save durations'**
  String get saveDurations;

  /// No description provided for @statisticsZone.
  ///
  /// In en, this message translates to:
  /// **'Statistics time zone'**
  String get statisticsZone;

  /// No description provided for @clockZone.
  ///
  /// In en, this message translates to:
  /// **'Default clock time zone'**
  String get clockZone;

  /// No description provided for @saveZones.
  ///
  /// In en, this message translates to:
  /// **'Save time zones'**
  String get saveZones;

  /// No description provided for @durationPositive.
  ///
  /// In en, this message translates to:
  /// **'Durations must be greater than zero'**
  String get durationPositive;

  /// No description provided for @invalidZone.
  ///
  /// In en, this message translates to:
  /// **'Invalid time zone name'**
  String get invalidZone;

  /// No description provided for @invalidZoneShort.
  ///
  /// In en, this message translates to:
  /// **'Invalid time zone'**
  String get invalidZoneShort;

  /// No description provided for @editRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get editRecord;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @creditedDuration.
  ///
  /// In en, this message translates to:
  /// **'Credited duration HH:MM:SS'**
  String get creditedDuration;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get deleteRecord;

  /// No description provided for @durationFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a duration as HH:MM:SS'**
  String get durationFormat;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @noTimer.
  ///
  /// In en, this message translates to:
  /// **'No active timer'**
  String get noTimer;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the next round'**
  String get waiting;

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// No description provided for @closeTimer.
  ///
  /// In en, this message translates to:
  /// **'Close timer window'**
  String get closeTimer;

  /// No description provided for @compact.
  ///
  /// In en, this message translates to:
  /// **'Toggle window size'**
  String get compact;

  /// No description provided for @clockWarning.
  ///
  /// In en, this message translates to:
  /// **'The system clock moved backwards. Correct it before continuing.'**
  String get clockWarning;

  /// No description provided for @breakFinished.
  ///
  /// In en, this message translates to:
  /// **'Break finished. Start the next round when ready.'**
  String get breakFinished;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @finishBreak.
  ///
  /// In en, this message translates to:
  /// **'End break early'**
  String get finishBreak;

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **'Next round'**
  String get nextRound;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timezone;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email and a password of at least 8 characters'**
  String get invalidCredentials;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email and enter the verification code'**
  String get checkEmail;

  /// No description provided for @networkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Network unavailable'**
  String get networkUnavailable;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in or verification failed. Check your details.'**
  String get authFailed;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmail;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailCode.
  ///
  /// In en, this message translates to:
  /// **'Email verification code'**
  String get emailCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @existingAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? Sign in'**
  String get existingAccount;

  /// No description provided for @newAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Sign up'**
  String get newAccount;

  /// No description provided for @cloudNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloud accounts are not configured. Local timing is available.'**
  String get cloudNotConfigured;

  /// No description provided for @timerNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Another device is timing. Review the local timer.'**
  String get timerNeedsReview;

  /// No description provided for @timerConflict.
  ///
  /// In en, this message translates to:
  /// **'Timer sync conflict. Check your other devices.'**
  String get timerConflict;

  /// No description provided for @offlineTimer.
  ///
  /// In en, this message translates to:
  /// **'Timing offline. Sync will resume later.'**
  String get offlineTimer;

  /// No description provided for @offlineRecords.
  ///
  /// In en, this message translates to:
  /// **'Network unavailable. Records are saved locally.'**
  String get offlineRecords;

  /// No description provided for @pendingConflict.
  ///
  /// In en, this message translates to:
  /// **'Sync conflicts need review'**
  String get pendingConflict;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Records are waiting to sync'**
  String get pendingSync;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Records are saved locally.'**
  String get syncFailed;

  /// No description provided for @conflictChanged.
  ///
  /// In en, this message translates to:
  /// **'The record changed. Choose how to resolve the conflict again.'**
  String get conflictChanged;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language / 语言'**
  String get language;

  /// No description provided for @focusLabel.
  ///
  /// In en, this message translates to:
  /// **'FOCUS'**
  String get focusLabel;

  /// No description provided for @breakLabel.
  ///
  /// In en, this message translates to:
  /// **'BREAK'**
  String get breakLabel;

  /// No description provided for @elapsedLabel.
  ///
  /// In en, this message translates to:
  /// **'ELAPSED'**
  String get elapsedLabel;

  /// No description provided for @ianaTimezone.
  ///
  /// In en, this message translates to:
  /// **'IANA time zone'**
  String get ianaTimezone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
