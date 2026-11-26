// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Poswal Orbit';

  @override
  String get tabToday => 'Today';

  @override
  String get tabHabits => 'Habits';

  @override
  String get tabTasks => 'Tasks';

  @override
  String get tabNotes => 'Notes';

  @override
  String get tabInsights => 'Insights';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get allClear => 'All clear. Enjoy the quiet.';

  @override
  String get noHabitsScheduled =>
      'No habits scheduled for this day.\nRest and recharge, or create a new habit below.';

  @override
  String get addHabit => 'Add Habit';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String tasksDueCount(int count) {
    return '($count due)';
  }

  @override
  String get allHabits => 'All Habits';

  @override
  String get habitsActive => 'Active';

  @override
  String get habitsArchived => 'Archived';

  @override
  String get streakFreezeActive => '1 Streak Freeze Active';

  @override
  String get streakFreezeDescription =>
      'Protects one missed scheduled day per month.';

  @override
  String get noHabitsYet => 'No Habits Yet';

  @override
  String get noHabitsYetSubtitle =>
      'Create your first habit to begin your orbit.';

  @override
  String get noArchivedHabits => 'No Archived Habits';

  @override
  String get noArchivedHabitsSubtitle =>
      'Archived habits are stored safely here without cluttering your daily view.';

  @override
  String get archivedTapToRestore => 'Archived • Tap restore to reactivate';

  @override
  String habitRestored(String name) {
    return 'Restored \"$name\" to Active Habits';
  }

  @override
  String habitDeleted(String name) {
    return 'Permanently deleted \"$name\"';
  }

  @override
  String get createHabitTitle => 'Create Habit';

  @override
  String get editHabitTitle => 'Edit Habit';

  @override
  String get livePreview => 'Live Preview';

  @override
  String get habitNameLabel => 'Habit Name';

  @override
  String get habitNameHint => 'e.g. Read 20 pages';

  @override
  String get paletteColor => 'Palette Color';

  @override
  String get iconLabel => 'Icon';

  @override
  String get timeOfDayLabel => 'Time of Day';

  @override
  String get scheduleLabel => 'Schedule';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get habitNotFound => 'Habit not found';

  @override
  String get currentStreakLabel => 'Current streak';

  @override
  String get bestStreakLabel => 'Best streak';

  @override
  String get habitScoreLabel => 'Habit score';

  @override
  String get archiveHabit => 'Archive Habit';

  @override
  String get deleteHabit => 'Delete Habit';

  @override
  String get checkinStatusDone => 'Done';

  @override
  String get checkinStatusSkip => 'Skip';

  @override
  String get checkinStatusMissed => 'Missed';

  @override
  String get tasksSmartToday => 'Today';

  @override
  String get tasksSmartUpcoming => 'Upcoming';

  @override
  String get tasksSmartAll => 'All';

  @override
  String get tasksSmartDone => 'Done';

  @override
  String get quickAddTaskHint =>
      'Add a task (e.g. Call mom tomorrow at 6pm #family)';

  @override
  String get keepDayInMotion => 'Keep your day in motion';

  @override
  String get allProjects => 'All Projects';

  @override
  String get noPendingTasksFound => 'No pending tasks found for this view.';

  @override
  String get addTask => 'Add Task';

  @override
  String get subtasksTitle => 'Subtasks';

  @override
  String get addSubtaskHint => 'Add a subtask...';

  @override
  String get addNotesHint => 'Add detailed notes...';

  @override
  String get dueDateLabel => 'Due date and time';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get undoButton => 'Undo';

  @override
  String get notesSaved => 'Saved';

  @override
  String get notesSaving => 'Saving...';

  @override
  String get unpinNote => 'Unpin Note';

  @override
  String get pinNote => 'Pin Note';

  @override
  String get changeColorLabel => 'Change Color Label';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get noteDeletedToast => 'Note deleted';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get noNotesYetSubtitle =>
      'Capture your thoughts, ideas, or start today\'s journal.';

  @override
  String get newNote => 'New Note';

  @override
  String get noteTitleHint => 'Title';

  @override
  String get noteBodyHint => 'Start writing (Markdown-lite supported)...';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get weeklyReviewTitle => 'Weekly review';

  @override
  String get productivityScore => 'Productivity Score';

  @override
  String get bestDayOfWeek => 'Best Day of Week';

  @override
  String get bestTimeOfDay => 'Best Time of Day';

  @override
  String get habitHeatmaps => 'Habit Heatmaps';

  @override
  String get habitTaskCorrelation => 'Habit & Task Correlation';

  @override
  String get shareCard => 'Share';

  @override
  String get insightsEmptyTitle => 'Your insights will grow as you go';

  @override
  String get insightsEmptySubtitle =>
      'Complete habits and check off tasks to see personalized patterns, weekly review cards, and productivity scores.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsReduceTransparency => 'Reduce Transparency';

  @override
  String get settingsDayStart => 'Day-Start Boundary';

  @override
  String get settingsFirstDayOfWeek => 'First Day of Week';

  @override
  String get settingsHaptics => 'Haptic Feedback';

  @override
  String get settingsNotifications => 'Reminders & Notifications';

  @override
  String get settingsHealthCheck => 'Reminders Health Check';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDataSafety => 'Data Safety & Backups';

  @override
  String get settingsBackupNow => 'Back Up Now';

  @override
  String get settingsExport => 'Export';

  @override
  String get settingsImport => 'Import';

  @override
  String get settingsDanger => 'Danger Zone';

  @override
  String get settingsDeleteAll => 'Delete All Data';

  @override
  String get dayStartBoundarySubtitle =>
      'Habit check-ins before this hour count towards previous day';

  @override
  String get reduceTransparencySubtitle =>
      'Solid background cards for reduced GPU load or high contrast';

  @override
  String get hapticFeedbackSubtitle =>
      'Tactile vibration on habit rings, checkboxes and gestures';

  @override
  String get remindersHealthCheckSubtitle =>
      'Verify system permissions and Samsung One UI background rules to ensure 100% reliable streak reminders.';

  @override
  String get sendTestAlert => 'Send Test Alert';

  @override
  String get syncSchedule => 'Sync Schedule';

  @override
  String get displayLanguage => 'Display Language';

  @override
  String get displayLanguageSubtitle =>
      'Supports English, Hindi (हिन्दी), and Urdu (اردو) with native fonts and RTL direction';

  @override
  String get autoDailyBackupsActive => 'Automatic Daily Backups Active';

  @override
  String get autoDailyBackupsSubtitle =>
      'Rolling retention keeps the last 7 daily snapshots safely.';

  @override
  String get deleteAllDataSubtitle =>
      'Permanently erase habits, entries, tasks, and notes';

  @override
  String get deleteAllDataDialogTitle => 'Delete All Data?';

  @override
  String get deleteAllDataDialogContent =>
      'This will wipe all habits, entries, tasks, and notes.\n\nA safety backup snapshot will be created automatically before wiping so you can recover if needed.';

  @override
  String get finalConfirmationTitle => 'Final Confirmation';

  @override
  String get finalConfirmationContent =>
      'Are you completely sure? This action will reset your active workspace.';

  @override
  String get keepMyData => 'Keep My Data';

  @override
  String get wipeEverything => 'Wipe Everything';

  @override
  String get importDialogTitle => 'Import Data / Loop CSV';

  @override
  String get importDialogContent =>
      'Paste JSON backup content or Loop Habit Tracker CSV data below:';

  @override
  String get inspectAndImport => 'Inspect & Import';

  @override
  String get cancel => 'Cancel';

  @override
  String get proceed => 'Proceed';

  @override
  String get understood => 'Understood';

  @override
  String get notificationPermissionTitle => 'Notification Permission';

  @override
  String get notificationPermissionSubtitle =>
      'Allows Poswal Orbit to display alerts in your status bar and lock screen.';

  @override
  String get openNotificationSettings => 'Open Notification Settings';

  @override
  String get exactAlarmSchedulingTitle => 'Exact Alarm Scheduling';

  @override
  String get exactAlarmSchedulingSubtitle =>
      'Allows reminders to fire at the exact minute rather than being batched or delayed by Android battery management.';

  @override
  String get manageAlarmPermission => 'Manage Alarm Permission';

  @override
  String get samsungBatteryExemptionTitle => 'Samsung Battery Exemption';

  @override
  String get samsungBatteryExemptionSubtitle =>
      'One UI automatically sleeps apps not used for a few days. Exempting Orbit guarantees streak prompts survive.';

  @override
  String get howToSetUnrestricted => 'How to set \"Unrestricted\"';

  @override
  String get rollingWindowStatusTitle => 'Rolling 7-Day Window';

  @override
  String rollingWindowStatusSubtitle(int count) {
    return '$count scheduled reminders active in OS queue.';
  }

  @override
  String get refillBtn => 'Refill';

  @override
  String get sendTestNotificationBtn => 'Send Test Notification';

  @override
  String get dispatching => 'Dispatching...';

  @override
  String get granted => 'Granted';

  @override
  String get restricted => 'Restricted';

  @override
  String get samsungGuideTitle => 'Samsung One UI Battery Guide';

  @override
  String get samsungGuideIntro =>
      'Samsung phones aggressively close background apps to preserve battery. To prevent missing habit streaks:';

  @override
  String get habitsDoneCount => 'Habits Done';

  @override
  String get bestStreakCount => 'Best Streak';

  @override
  String get peakMomentum => 'Peak Momentum';

  @override
  String get observedPattern => 'Observed Pattern';

  @override
  String get correlationDisclaimer =>
      'We never jump to conclusions on limited data. Keep tracking to reveal true correlations.';

  @override
  String get overallHeatmap => 'Overall Activity Heatmap';

  @override
  String get last8Weeks => 'Last 8 Weeks';

  @override
  String get heatmapLess => 'Less';

  @override
  String get heatmapMore => 'More';

  @override
  String get shareWeeklyRhythm => 'My weekly rhythm on Poswal Orbit';

  @override
  String shareFailed(String error) {
    return 'Failed to share: $error';
  }

  @override
  String get restoreHabitTooltip => 'Restore Habit';

  @override
  String get deletePermanentlyTooltip => 'Delete Permanently';

  @override
  String get habitNotePlaceholder =>
      'e.g. Felt great today, did 20 extra minutes';

  @override
  String get searchNotesPlaceholder => 'Filter notes by title or content...';

  @override
  String get addTagPlaceholder => 'e.g. project, ideas';

  @override
  String get addTag => 'Add';

  @override
  String get colorLabelTooltip => 'Color Label';

  @override
  String get linkHabitTaskTooltip => 'Link to Habit/Task';

  @override
  String get addTagTooltip => 'Add Tag';

  @override
  String get headingTooltip => 'Heading';

  @override
  String get boldTooltip => 'Bold';

  @override
  String get italicTooltip => 'Italic';

  @override
  String get bulletListTooltip => 'Bullet List';

  @override
  String get checklistTooltip => 'Checklist';

  @override
  String get insertLinkTooltip => 'Insert Link';

  @override
  String get linkTextLabel => 'Link Text';

  @override
  String get linkUrlLabel => 'URL (https://...)';

  @override
  String get globalSearchPlaceholder => 'Search habits, tasks, notes...';

  @override
  String get searchTasksPlaceholder => 'Search tasks...';

  @override
  String get noHabitLinked => 'No habit linked';

  @override
  String taskDeletedNamed(String title) {
    return 'Task \"$title\" deleted';
  }

  @override
  String get searchTooltip => 'Search';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get mondayShort => 'Mon';

  @override
  String get sundayShort => 'Sun';

  @override
  String get saving => 'Saving...';

  @override
  String get availableBackups => 'Available Backups (Last 7)';

  @override
  String get noBackupsYet =>
      'No backup snapshots yet. Tap \"Back Up Now\" to save your first snapshot.';

  @override
  String get restore => 'Restore';

  @override
  String get resetOrClearData => 'Reset or Clear Data';

  @override
  String get backupFullJson => 'Full Database Snapshot (JSON)';

  @override
  String get backupFullJsonSubtitle =>
      'Complete portable backup with habits, tasks & notes';

  @override
  String get exportHabitsCsv => 'Habits & Check-ins (CSV)';

  @override
  String get exportTasksCsv => 'Tasks & Subtasks (CSV)';

  @override
  String get exportNotesCsv => 'Notes & Journal (CSV)';

  @override
  String get importPreview => 'Import Preview';

  @override
  String importFormat(String format) {
    return 'Format: $format';
  }

  @override
  String get importSafetyNote =>
      'A safety backup will be created automatically before importing to protect your current database.';

  @override
  String get importPlaceholder => 'Paste JSON backup or Loop CSV data...';

  @override
  String get applyImport => 'Apply Import';

  @override
  String get allDataClearedToast =>
      'All data cleared. Pre-wipe safety snapshot was preserved in backups.';

  @override
  String fullJsonCopiedToast(int bytes) {
    return 'Full JSON backup copied to clipboard ($bytes bytes)';
  }

  @override
  String get habitsCsvCopiedToast => 'Habits CSV copied to clipboard';

  @override
  String get tasksCsvCopiedToast => 'Tasks CSV copied to clipboard';

  @override
  String get notesCsvCopiedToast => 'Notes CSV copied to clipboard';

  @override
  String importSuccessToast(int habits, int tasks, int notes) {
    return 'Successfully imported $habits habits, $tasks tasks, $notes notes';
  }

  @override
  String get remindersHealthCheckTitle => 'Reminders Health Check';

  @override
  String get onboardingHabitsTitle => 'Build Lasting Momentum';

  @override
  String get onboardingHabitsDesc =>
      'Track daily rhythm with beautiful orbit rings, streaks, and zero guilt.';

  @override
  String get onboardingTasksTitle => 'Calm, Focused Action';

  @override
  String get onboardingTasksDesc =>
      'Smart lists, natural language due dates, and simple checklists keep you clear.';

  @override
  String get onboardingNotesTitle => 'Private Thoughts & Journal';

  @override
  String get onboardingNotesDesc =>
      'Markdown notes and daily journals stored safely on your device only.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get restoreBackupDialogTitle => 'Restore from Backup?';

  @override
  String restoreBackupDialogBody(String date) {
    return 'This will replace your current data with backup from $date.\n\nA safety snapshot of your current database will be taken immediately before restoring so nothing is lost.';
  }

  @override
  String get restoreSafelyBtn => 'Restore Safely';

  @override
  String get settingsAccentColor => 'Accent Color';

  @override
  String get settingsGlassIntensity => 'Glass Intensity';

  @override
  String get settingsTimeBoundary => 'Time & Orbit Boundary';

  @override
  String get settingsAbout => 'About';

  @override
  String get deleteTaskBtn => 'Delete Task';

  @override
  String get taskDetailsTitle => 'Task Details';

  @override
  String get noMatchingResults => 'No matching results found';

  @override
  String searchSectionHabits(int count) {
    return 'Habits ($count)';
  }

  @override
  String searchSectionTasks(int count) {
    return 'Tasks ($count)';
  }

  @override
  String searchSectionNotes(int count) {
    return 'Notes ($count)';
  }

  @override
  String get colorLabelTitle => 'Color Label';

  @override
  String get allFilter => 'All';

  @override
  String get noteColorLabelTitle => 'Note Color Label';

  @override
  String get linkHabitOrTaskTitle => 'Link to Habit or Task';

  @override
  String get habitsSectionHeader => 'Habits';

  @override
  String get tasksSectionHeader => 'Tasks';

  @override
  String dailyJournalHeader(String date) {
    return 'Daily Journal • $date';
  }

  @override
  String get linkedHabitLabel => 'Linked habit';

  @override
  String get linkedTaskLabel => 'Linked Task';

  @override
  String get heatmapSkipped => 'Skipped';

  @override
  String get habitConsecutiveOccurrences => 'consecutive occurrences';

  @override
  String get habitHistoricalRecord => 'historical record';

  @override
  String get testNotificationTitle => 'Poswal Orbit test notification';

  @override
  String get testNotificationBody =>
      'Exact alarms and notification channels are working properly on this device.';

  @override
  String get testNotificationSent =>
      'Test notification sent. Check your notifications to test Mark Done or Snooze.';

  @override
  String get calendarTapHint => 'Tap any day to edit check-in or add notes';

  @override
  String get consistencyHeatmapHeader => 'Consistency heatmap';

  @override
  String get weeklyPerformanceHeader => 'Weekly performance';

  @override
  String get consistencyTrendHeader => '30-day consistency trend';

  @override
  String recordProgressTitle(String unit) {
    return 'Record progress ($unit)';
  }

  @override
  String get notificationUrgentPrefix => 'Urgent: ';

  @override
  String get notificationHighPrefix => 'High priority: ';

  @override
  String notificationHabitTitle(String name) {
    return 'Time for $name';
  }

  @override
  String get notificationKeepMomentum => 'Keep your momentum alive today.';

  @override
  String get notificationTaskDueNow => 'Task due now';

  @override
  String get datePickerSetDate => 'Set date';

  @override
  String get datePickerSetTime => 'Set time';

  @override
  String get notificationActionMarkDone => 'Mark done';

  @override
  String get notificationActionSnooze10m => 'Snooze 10m';

  @override
  String get insightsTabOverview => 'Overview';

  @override
  String get insightsTabHabits => 'Habits';

  @override
  String get insightsTabTiming => 'Timing';

  @override
  String get insightsEmptyAction => 'Explore habits';

  @override
  String habitStreakDays(int count) {
    return '${count}d streak';
  }

  @override
  String habitThirtyDayRate(int rate) {
    return '$rate% in 30d';
  }

  @override
  String get habitHeatmapExpand => 'Tap to expand heatmap';

  @override
  String get habitHeatmapCollapse => 'Tap to collapse heatmap';

  @override
  String get heatmapDayMon => 'M';

  @override
  String get heatmapDayWed => 'W';

  @override
  String get heatmapDayFri => 'F';

  @override
  String heatmapCellTooltip(String date, int count) {
    return '$date: $count completed';
  }

  @override
  String get timingDistributionTitle => 'Completions by Weekday';

  @override
  String get dayShortMon => 'Mon';

  @override
  String get dayShortTue => 'Tue';

  @override
  String get dayShortWed => 'Wed';

  @override
  String get dayShortThu => 'Thu';

  @override
  String get dayShortFri => 'Fri';

  @override
  String get dayShortSat => 'Sat';

  @override
  String get dayShortSun => 'Sun';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get autoUpdateChecks => 'Automatic update checks';

  @override
  String get autoUpdateChecksSubtitle =>
      'Check GitHub Releases once a day for new versions';

  @override
  String currentVersionLabel(String version) {
    return 'Current version: $version';
  }

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateVersionSubtitle(String version) {
    return 'Version $version is ready to download';
  }

  @override
  String get updateUpToDate => 'You are on the latest version';

  @override
  String get updateDownloadBtn => 'Download update';

  @override
  String get updateLaterBtn => 'Later';

  @override
  String get updateSkipVersionBtn => 'Skip this version';

  @override
  String get updateCheckOffline =>
      'Unable to check for updates. Check your internet connection.';

  @override
  String get updateCheckRateLimited =>
      'GitHub rate limit reached. Please try again later.';

  @override
  String get updateCheckFailed => 'Could not check for updates right now.';
}
