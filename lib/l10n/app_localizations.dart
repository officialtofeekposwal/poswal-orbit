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

  /// No description provided for @yourOrbitClear.
  ///
  /// In en, this message translates to:
  /// **'Your Orbit is Clear'**
  String get yourOrbitClear;

  /// No description provided for @noHabitsScheduled.
  ///
  /// In en, this message translates to:
  /// **'No habits scheduled for this day.\nRest and recharge, or create a new habit below.'**
  String get noHabitsScheduled;

  /// No description provided for @addHabit.
  ///
  /// In en, this message translates to:
  /// **'Add Habit'**
  String get addHabit;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksDueCount.
  ///
  /// In en, this message translates to:
  /// **'({count} due)'**
  String tasksDueCount(int count);

  /// No description provided for @allHabits.
  ///
  /// In en, this message translates to:
  /// **'All Habits'**
  String get allHabits;

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

  /// No description provided for @streakFreezeActive.
  ///
  /// In en, this message translates to:
  /// **'1 Streak Freeze Active'**
  String get streakFreezeActive;

  /// No description provided for @streakFreezeDescription.
  ///
  /// In en, this message translates to:
  /// **'Protects one missed scheduled day per month.'**
  String get streakFreezeDescription;

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No Habits Yet'**
  String get noHabitsYet;

  /// No description provided for @noHabitsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first habit to begin your orbit.'**
  String get noHabitsYetSubtitle;

  /// No description provided for @noArchivedHabits.
  ///
  /// In en, this message translates to:
  /// **'No Archived Habits'**
  String get noArchivedHabits;

  /// No description provided for @noArchivedHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Archived habits are stored safely here without cluttering your daily view.'**
  String get noArchivedHabitsSubtitle;

  /// No description provided for @archivedTapToRestore.
  ///
  /// In en, this message translates to:
  /// **'Archived • Tap restore to reactivate'**
  String get archivedTapToRestore;

  /// No description provided for @habitRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored \"{name}\" to Active Habits'**
  String habitRestored(String name);

  /// No description provided for @habitDeleted.
  ///
  /// In en, this message translates to:
  /// **'Permanently deleted \"{name}\"'**
  String habitDeleted(String name);

  /// No description provided for @createHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Habit'**
  String get createHabitTitle;

  /// No description provided for @editHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get editHabitTitle;

  /// No description provided for @livePreview.
  ///
  /// In en, this message translates to:
  /// **'Live Preview'**
  String get livePreview;

  /// No description provided for @habitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Habit Name'**
  String get habitNameLabel;

  /// No description provided for @habitNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Read 20 pages'**
  String get habitNameHint;

  /// No description provided for @paletteColor.
  ///
  /// In en, this message translates to:
  /// **'Palette Color'**
  String get paletteColor;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @timeOfDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Time of Day'**
  String get timeOfDayLabel;

  /// No description provided for @scheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @habitNotFound.
  ///
  /// In en, this message translates to:
  /// **'Habit not found'**
  String get habitNotFound;

  /// No description provided for @currentStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreakLabel;

  /// No description provided for @bestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreakLabel;

  /// No description provided for @habitScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Habit Score'**
  String get habitScoreLabel;

  /// No description provided for @completionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRateLabel;

  /// No description provided for @archiveHabit.
  ///
  /// In en, this message translates to:
  /// **'Archive Habit'**
  String get archiveHabit;

  /// No description provided for @restoreHabit.
  ///
  /// In en, this message translates to:
  /// **'Restore Habit'**
  String get restoreHabit;

  /// No description provided for @deleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get deleteHabit;

  /// No description provided for @checkinStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get checkinStatusDone;

  /// No description provided for @checkinStatusSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get checkinStatusSkip;

  /// No description provided for @checkinStatusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get checkinStatusMissed;

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

  /// No description provided for @keepDayInMotion.
  ///
  /// In en, this message translates to:
  /// **'Keep your day in motion'**
  String get keepDayInMotion;

  /// No description provided for @allProjects.
  ///
  /// In en, this message translates to:
  /// **'All Projects'**
  String get allProjects;

  /// No description provided for @noPendingTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks found for this view.'**
  String get noPendingTasksFound;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @subtasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasksTitle;

  /// No description provided for @addSubtaskHint.
  ///
  /// In en, this message translates to:
  /// **'Add a subtask...'**
  String get addSubtaskHint;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @addNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add detailed notes...'**
  String get addNotesHint;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateLabel;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @projectLabel.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectLabel;

  /// No description provided for @taskDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeletedToast;

  /// No description provided for @undoButton.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoButton;

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

  /// No description provided for @unpinNote.
  ///
  /// In en, this message translates to:
  /// **'Unpin Note'**
  String get unpinNote;

  /// No description provided for @pinNote.
  ///
  /// In en, this message translates to:
  /// **'Pin Note'**
  String get pinNote;

  /// No description provided for @changeColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Change Color Label'**
  String get changeColorLabel;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @noteDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeletedToast;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesYet;

  /// No description provided for @noNotesYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture your thoughts, ideas, or start today\'s journal.'**
  String get noNotesYetSubtitle;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @noteTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitleHint;

  /// No description provided for @noteBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Start writing (Markdown-lite supported)...'**
  String get noteBodyHint;

  /// No description provided for @journalForDate.
  ///
  /// In en, this message translates to:
  /// **'Daily Journal: {date}'**
  String journalForDate(String date);

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
  /// **'Theme'**
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

  /// No description provided for @widgetTodayProgress.
  ///
  /// In en, this message translates to:
  /// **'Orbit Today Progress'**
  String get widgetTodayProgress;

  /// No description provided for @widgetQuickCheckin.
  ///
  /// In en, this message translates to:
  /// **'Quick Habit Check-in'**
  String get widgetQuickCheckin;

  /// No description provided for @widgetTasksGlance.
  ///
  /// In en, this message translates to:
  /// **'Pending Tasks at a Glance'**
  String get widgetTasksGlance;

  /// No description provided for @dayStartBoundarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Habit check-ins before this hour count towards previous day'**
  String get dayStartBoundarySubtitle;

  /// No description provided for @reduceTransparencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solid background cards for reduced GPU load or high contrast'**
  String get reduceTransparencySubtitle;

  /// No description provided for @hapticFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tactile vibration on habit rings, checkboxes and gestures'**
  String get hapticFeedbackSubtitle;

  /// No description provided for @remindersHealthCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify system permissions and Samsung One UI background rules to ensure 100% reliable streak reminders.'**
  String get remindersHealthCheckSubtitle;

  /// No description provided for @sendTestAlert.
  ///
  /// In en, this message translates to:
  /// **'Send Test Alert'**
  String get sendTestAlert;

  /// No description provided for @syncSchedule.
  ///
  /// In en, this message translates to:
  /// **'Sync Schedule'**
  String get syncSchedule;

  /// No description provided for @displayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display Language'**
  String get displayLanguage;

  /// No description provided for @displayLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supports English, Hindi (हिन्दी), and Urdu (اردو) with native fonts and RTL direction'**
  String get displayLanguageSubtitle;

  /// No description provided for @autoDailyBackupsActive.
  ///
  /// In en, this message translates to:
  /// **'Automatic Daily Backups Active'**
  String get autoDailyBackupsActive;

  /// No description provided for @autoDailyBackupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rolling retention keeps the last 7 daily snapshots safely.'**
  String get autoDailyBackupsSubtitle;

  /// No description provided for @deleteAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently erase habits, entries, tasks, and notes'**
  String get deleteAllDataSubtitle;

  /// No description provided for @deleteAllDataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get deleteAllDataDialogTitle;

  /// No description provided for @deleteAllDataDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will wipe all habits, entries, tasks, and notes.\n\nA safety backup snapshot will be created automatically before wiping so you can recover if needed.'**
  String get deleteAllDataDialogContent;

  /// No description provided for @finalConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get finalConfirmationTitle;

  /// No description provided for @finalConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you completely sure? This action will reset your active workspace.'**
  String get finalConfirmationContent;

  /// No description provided for @keepMyData.
  ///
  /// In en, this message translates to:
  /// **'Keep My Data'**
  String get keepMyData;

  /// No description provided for @wipeEverything.
  ///
  /// In en, this message translates to:
  /// **'Wipe Everything'**
  String get wipeEverything;

  /// No description provided for @importDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Data / Loop CSV'**
  String get importDialogTitle;

  /// No description provided for @importDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON backup content or Loop Habit Tracker CSV data below:'**
  String get importDialogContent;

  /// No description provided for @inspectAndImport.
  ///
  /// In en, this message translates to:
  /// **'Inspect & Import'**
  String get inspectAndImport;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allows Poswal Orbit to display alerts in your status bar and lock screen.'**
  String get notificationPermissionSubtitle;

  /// No description provided for @openNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Notification Settings'**
  String get openNotificationSettings;

  /// No description provided for @exactAlarmSchedulingTitle.
  ///
  /// In en, this message translates to:
  /// **'Exact Alarm Scheduling'**
  String get exactAlarmSchedulingTitle;

  /// No description provided for @exactAlarmSchedulingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allows reminders to fire at the exact minute rather than being batched or delayed by Android battery management.'**
  String get exactAlarmSchedulingSubtitle;

  /// No description provided for @manageAlarmPermission.
  ///
  /// In en, this message translates to:
  /// **'Manage Alarm Permission'**
  String get manageAlarmPermission;

  /// No description provided for @samsungBatteryExemptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Samsung Battery Exemption'**
  String get samsungBatteryExemptionTitle;

  /// No description provided for @samsungBatteryExemptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One UI automatically sleeps apps not used for a few days. Exempting Orbit guarantees streak prompts survive.'**
  String get samsungBatteryExemptionSubtitle;

  /// No description provided for @howToSetUnrestricted.
  ///
  /// In en, this message translates to:
  /// **'How to set \"Unrestricted\"'**
  String get howToSetUnrestricted;

  /// No description provided for @rollingWindowStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Rolling 7-Day Window'**
  String get rollingWindowStatusTitle;

  /// No description provided for @rollingWindowStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} scheduled reminders active in OS queue.'**
  String rollingWindowStatusSubtitle(int count);

  /// No description provided for @refillBtn.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get refillBtn;

  /// No description provided for @sendTestNotificationBtn.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get sendTestNotificationBtn;

  /// No description provided for @dispatching.
  ///
  /// In en, this message translates to:
  /// **'Dispatching...'**
  String get dispatching;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @restricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get restricted;

  /// No description provided for @samsungGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Samsung One UI Battery Guide'**
  String get samsungGuideTitle;

  /// No description provided for @samsungGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'Samsung phones aggressively close background apps to preserve battery. To prevent missing habit streaks:'**
  String get samsungGuideIntro;

  /// No description provided for @habitsDoneCount.
  ///
  /// In en, this message translates to:
  /// **'Habits Done'**
  String get habitsDoneCount;

  /// No description provided for @tasksFinishedCount.
  ///
  /// In en, this message translates to:
  /// **'Tasks Finished'**
  String get tasksFinishedCount;

  /// No description provided for @bestStreakCount.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreakCount;

  /// No description provided for @peakMomentum.
  ///
  /// In en, this message translates to:
  /// **'Peak Momentum'**
  String get peakMomentum;

  /// No description provided for @observedPattern.
  ///
  /// In en, this message translates to:
  /// **'Observed Pattern'**
  String get observedPattern;

  /// No description provided for @correlationDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'We never jump to conclusions on limited data. Keep tracking to reveal true correlations.'**
  String get correlationDisclaimer;

  /// No description provided for @overallHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Overall Activity Heatmap'**
  String get overallHeatmap;

  /// No description provided for @last8Weeks.
  ///
  /// In en, this message translates to:
  /// **'Last 8 Weeks'**
  String get last8Weeks;

  /// No description provided for @heatmapLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get heatmapLess;

  /// No description provided for @heatmapMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get heatmapMore;

  /// No description provided for @shareWeeklyRhythm.
  ///
  /// In en, this message translates to:
  /// **'My weekly rhythm on Poswal Orbit 🚀'**
  String get shareWeeklyRhythm;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share: {error}'**
  String shareFailed(String error);

  /// No description provided for @restoreHabitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore Habit'**
  String get restoreHabitTooltip;

  /// No description provided for @deletePermanentlyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanentlyTooltip;

  /// No description provided for @habitNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Felt great today, did 20 extra minutes'**
  String get habitNotePlaceholder;

  /// No description provided for @searchNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Filter notes by title or content...'**
  String get searchNotesPlaceholder;

  /// No description provided for @addTagPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. project, ideas'**
  String get addTagPlaceholder;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addTag;

  /// No description provided for @colorLabelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Color Label'**
  String get colorLabelTooltip;

  /// No description provided for @linkHabitTaskTooltip.
  ///
  /// In en, this message translates to:
  /// **'Link to Habit/Task'**
  String get linkHabitTaskTooltip;

  /// No description provided for @addTagTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTagTooltip;

  /// No description provided for @headingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get headingTooltip;

  /// No description provided for @boldTooltip.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get boldTooltip;

  /// No description provided for @italicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italicTooltip;

  /// No description provided for @bulletListTooltip.
  ///
  /// In en, this message translates to:
  /// **'Bullet List'**
  String get bulletListTooltip;

  /// No description provided for @checklistTooltip.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklistTooltip;

  /// No description provided for @insertLinkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Insert Link'**
  String get insertLinkTooltip;

  /// No description provided for @linkTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Link Text'**
  String get linkTextLabel;

  /// No description provided for @linkUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL (https://...)'**
  String get linkUrlLabel;

  /// No description provided for @globalSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search habits, tasks, notes...'**
  String get globalSearchPlaceholder;

  /// No description provided for @searchTasksPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchTasksPlaceholder;

  /// No description provided for @noHabitLinked.
  ///
  /// In en, this message translates to:
  /// **'No Habit Linked'**
  String get noHabitLinked;

  /// No description provided for @taskDeletedNamed.
  ///
  /// In en, this message translates to:
  /// **'Task \"{title}\" deleted'**
  String taskDeletedNamed(String title);

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @designPlaygroundTooltip.
  ///
  /// In en, this message translates to:
  /// **'Design Playground'**
  String get designPlaygroundTooltip;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @availableBackups.
  ///
  /// In en, this message translates to:
  /// **'Available Backups (Last 7)'**
  String get availableBackups;

  /// No description provided for @noBackupsYet.
  ///
  /// In en, this message translates to:
  /// **'No backup snapshots yet. Tap \"Back Up Now\" to save your first snapshot.'**
  String get noBackupsYet;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @resetOrClearData.
  ///
  /// In en, this message translates to:
  /// **'Reset or Clear Data'**
  String get resetOrClearData;

  /// No description provided for @backupFullJson.
  ///
  /// In en, this message translates to:
  /// **'Full Database Snapshot (JSON)'**
  String get backupFullJson;

  /// No description provided for @backupFullJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete portable backup with habits, tasks & notes'**
  String get backupFullJsonSubtitle;

  /// No description provided for @exportHabitsCsv.
  ///
  /// In en, this message translates to:
  /// **'Habits & Check-ins (CSV)'**
  String get exportHabitsCsv;

  /// No description provided for @exportTasksCsv.
  ///
  /// In en, this message translates to:
  /// **'Tasks & Subtasks (CSV)'**
  String get exportTasksCsv;

  /// No description provided for @exportNotesCsv.
  ///
  /// In en, this message translates to:
  /// **'Notes & Journal (CSV)'**
  String get exportNotesCsv;

  /// No description provided for @importPreview.
  ///
  /// In en, this message translates to:
  /// **'Import Preview'**
  String get importPreview;

  /// No description provided for @importFormat.
  ///
  /// In en, this message translates to:
  /// **'Format: {format}'**
  String importFormat(String format);

  /// No description provided for @importSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'A safety backup will be created automatically before importing to protect your current database.'**
  String get importSafetyNote;

  /// No description provided for @importPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON backup or Loop CSV data...'**
  String get importPlaceholder;

  /// No description provided for @applyImport.
  ///
  /// In en, this message translates to:
  /// **'Apply Import'**
  String get applyImport;

  /// No description provided for @allDataClearedToast.
  ///
  /// In en, this message translates to:
  /// **'All data cleared. Pre-wipe safety snapshot was preserved in backups.'**
  String get allDataClearedToast;

  /// No description provided for @fullJsonCopiedToast.
  ///
  /// In en, this message translates to:
  /// **'Full JSON backup copied to clipboard ({bytes} bytes)'**
  String fullJsonCopiedToast(int bytes);

  /// No description provided for @habitsCsvCopiedToast.
  ///
  /// In en, this message translates to:
  /// **'Habits CSV copied to clipboard'**
  String get habitsCsvCopiedToast;

  /// No description provided for @tasksCsvCopiedToast.
  ///
  /// In en, this message translates to:
  /// **'Tasks CSV copied to clipboard'**
  String get tasksCsvCopiedToast;

  /// No description provided for @notesCsvCopiedToast.
  ///
  /// In en, this message translates to:
  /// **'Notes CSV copied to clipboard'**
  String get notesCsvCopiedToast;

  /// No description provided for @importSuccessToast.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {habits} habits, {tasks} tasks, {notes} notes'**
  String importSuccessToast(int habits, int tasks, int notes);

  /// No description provided for @remindersHealthCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders Health Check'**
  String get remindersHealthCheckTitle;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Poswal Orbit'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your private, offline space for intentional habits, tasks, and reflections.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Build Lasting Momentum'**
  String get onboardingHabitsTitle;

  /// No description provided for @onboardingHabitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track daily rhythm with beautiful orbit rings, streaks, and zero guilt.'**
  String get onboardingHabitsDesc;

  /// No description provided for @onboardingTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Calm, Focused Action'**
  String get onboardingTasksTitle;

  /// No description provided for @onboardingTasksDesc.
  ///
  /// In en, this message translates to:
  /// **'Smart lists, natural language due dates, and simple checklists keep you clear.'**
  String get onboardingTasksDesc;

  /// No description provided for @onboardingNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Private Thoughts & Journal'**
  String get onboardingNotesTitle;

  /// No description provided for @onboardingNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'Markdown notes and daily journals stored safely on your device only.'**
  String get onboardingNotesDesc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @restoreBackupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup?'**
  String get restoreBackupDialogTitle;

  /// No description provided for @restoreBackupDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This will replace your current data with backup from {date}.\n\nA safety snapshot of your current database will be taken immediately before restoring so nothing is lost.'**
  String restoreBackupDialogBody(String date);

  /// No description provided for @restoreSafelyBtn.
  ///
  /// In en, this message translates to:
  /// **'Restore Safely'**
  String get restoreSafelyBtn;

  /// No description provided for @settingsAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settingsAccentColor;

  /// No description provided for @settingsGlassIntensity.
  ///
  /// In en, this message translates to:
  /// **'Glass Intensity'**
  String get settingsGlassIntensity;

  /// No description provided for @settingsTimeBoundary.
  ///
  /// In en, this message translates to:
  /// **'Time & Orbit Boundary'**
  String get settingsTimeBoundary;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @deleteTaskBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTaskBtn;

  /// No description provided for @taskDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetailsTitle;

  /// No description provided for @noMatchingResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results found'**
  String get noMatchingResults;

  /// No description provided for @searchSectionHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits ({count})'**
  String searchSectionHabits(int count);

  /// No description provided for @searchSectionTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks ({count})'**
  String searchSectionTasks(int count);

  /// No description provided for @searchSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes ({count})'**
  String searchSectionNotes(int count);

  /// No description provided for @colorLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Label'**
  String get colorLabelTitle;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @noteColorLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Note Color Label'**
  String get noteColorLabelTitle;

  /// No description provided for @linkHabitOrTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Link to Habit or Task'**
  String get linkHabitOrTaskTitle;

  /// No description provided for @habitsSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'HABITS'**
  String get habitsSectionHeader;

  /// No description provided for @tasksSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'TASKS'**
  String get tasksSectionHeader;

  /// No description provided for @dailyJournalHeader.
  ///
  /// In en, this message translates to:
  /// **'Daily Journal • {date}'**
  String dailyJournalHeader(String date);

  /// No description provided for @linkedHabitLabel.
  ///
  /// In en, this message translates to:
  /// **'Linked Habit'**
  String get linkedHabitLabel;

  /// No description provided for @linkedTaskLabel.
  ///
  /// In en, this message translates to:
  /// **'Linked Task'**
  String get linkedTaskLabel;

  /// No description provided for @heatmapSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get heatmapSkipped;

  /// No description provided for @habitConsecutiveOccurrences.
  ///
  /// In en, this message translates to:
  /// **'consecutive occurrences'**
  String get habitConsecutiveOccurrences;

  /// No description provided for @habitHistoricalRecord.
  ///
  /// In en, this message translates to:
  /// **'historical record'**
  String get habitHistoricalRecord;

  /// No description provided for @habitEwmaConsistency.
  ///
  /// In en, this message translates to:
  /// **'14-day EWMA consistency'**
  String get habitEwmaConsistency;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'🌟 Poswal Orbit Test Notification'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms & notification channels are working beautifully on this device!'**
  String get testNotificationBody;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent! Check your shade & test \"Mark Done\" / \"Snooze 10m\".'**
  String get testNotificationSent;

  /// No description provided for @calendarTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any day to edit check-in or add notes'**
  String get calendarTapHint;
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
