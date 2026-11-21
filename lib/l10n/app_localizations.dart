import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('hi'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Poswal Orbit'**
  String get appTitle;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get tabHabits;

  /// No description provided for @tabTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tabTasks;

  /// No description provided for @tabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tabNotes;

  /// No description provided for @tabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get tabInsights;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingNight;

  /// No description provided for @habitsProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed'**
  String habitsProgress(int completed, int total);

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All clear. Enjoy the quiet.'**
  String get allClear;

  /// No description provided for @habitsAllDone.
  ///
  /// In en, this message translates to:
  /// **'All habits complete for today. Outstanding work!'**
  String get habitsAllDone;

  /// No description provided for @tasksDueOverdue.
  ///
  /// In en, this message translates to:
  /// **'Tasks Due & Overdue'**
  String get tasksDueOverdue;

  /// No description provided for @habitsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get habitsActive;

  /// No description provided for @habitsArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get habitsArchived;

  /// No description provided for @newHabit.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get newHabit;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d streak'**
  String streakDays(int days);

  /// No description provided for @tasksSmartToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tasksSmartToday;

  /// No description provided for @tasksSmartUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tasksSmartUpcoming;

  /// No description provided for @tasksSmartAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tasksSmartAll;

  /// No description provided for @tasksSmartDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tasksSmartDone;

  /// No description provided for @quickAddTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Add a task (e.g. Call mom tomorrow 6pm !high #family)'**
  String get quickAddTaskHint;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get priorityNone;

  /// No description provided for @notesPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get notesPinned;

  /// No description provided for @notesAll.
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get notesAll;

  /// No description provided for @notesTodayJournal.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Journal'**
  String get notesTodayJournal;

  /// No description provided for @notesSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get notesSaved;

  /// No description provided for @notesSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get notesSaving;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @weeklyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Review'**
  String get weeklyReviewTitle;

  /// No description provided for @productivityScore.
  ///
  /// In en, this message translates to:
  /// **'Productivity Score'**
  String get productivityScore;

  /// No description provided for @bestDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Best Day of Week'**
  String get bestDayOfWeek;

  /// No description provided for @bestTimeOfDay.
  ///
  /// In en, this message translates to:
  /// **'Best Time of Day'**
  String get bestTimeOfDay;

  /// No description provided for @habitHeatmaps.
  ///
  /// In en, this message translates to:
  /// **'Habit Heatmaps'**
  String get habitHeatmaps;

  /// No description provided for @habitTaskCorrelation.
  ///
  /// In en, this message translates to:
  /// **'Habit & Task Correlation'**
  String get habitTaskCorrelation;

  /// No description provided for @shareCard.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareCard;

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your insights will grow as you go'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete habits and check off tasks to unlock personalized patterns, weekly review cards, and productivity scores.'**
  String get insightsEmptySubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settingsTheme;

  /// No description provided for @settingsAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settingsAccent;

  /// No description provided for @settingsGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass Intensity'**
  String get settingsGlass;

  /// No description provided for @settingsReduceTransparency.
  ///
  /// In en, this message translates to:
  /// **'Reduce Transparency'**
  String get settingsReduceTransparency;

  /// No description provided for @settingsTime.
  ///
  /// In en, this message translates to:
  /// **'Time & Orbit Boundary'**
  String get settingsTime;

  /// No description provided for @settingsDayStart.
  ///
  /// In en, this message translates to:
  /// **'Day-Start Boundary'**
  String get settingsDayStart;

  /// No description provided for @settingsFirstDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'First Day of Week'**
  String get settingsFirstDayOfWeek;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get settingsHaptics;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminders & Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsHealthCheck.
  ///
  /// In en, this message translates to:
  /// **'Reminders Health Check'**
  String get settingsHealthCheck;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsDataSafety.
  ///
  /// In en, this message translates to:
  /// **'Data Safety & Backups'**
  String get settingsDataSafety;

  /// No description provided for @settingsBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Back Up Now'**
  String get settingsBackupNow;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsExport;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsImport;

  /// No description provided for @settingsDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settingsDanger;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get settingsDeleteAll;
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
      <String>['en', 'hi', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
