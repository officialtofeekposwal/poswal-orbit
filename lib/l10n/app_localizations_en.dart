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
  String get greetingNight => 'Good evening';

  @override
  String habitsProgress(int completed, int total) {
    return '$completed of $total completed';
  }

  @override
  String get allClear => 'All clear. Enjoy the quiet.';

  @override
  String get habitsAllDone =>
      'All habits complete for today. Outstanding work!';

  @override
  String get tasksDueOverdue => 'Tasks Due & Overdue';

  @override
  String get yourOrbitClear => 'Your Orbit is Clear';

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
  String get newHabit => 'New Habit';

  @override
  String streakDays(int days) {
    return '${days}d streak';
  }

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
  String get currentStreakLabel => 'Current Streak';

  @override
  String get bestStreakLabel => 'Best Streak';

  @override
  String get habitScoreLabel => 'Habit Score';

  @override
  String get completionRateLabel => 'Completion Rate';

  @override
  String get archiveHabit => 'Archive Habit';

  @override
  String get restoreHabit => 'Restore Habit';

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
      'Add a task (e.g. Call mom tomorrow 6pm !high #family)';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNone => 'None';

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
  String get notesLabel => 'Notes';

  @override
  String get addNotesHint => 'Add detailed notes...';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get projectLabel => 'Project';

  @override
  String get taskDeletedToast => 'Task deleted';

  @override
  String get undoButton => 'Undo';

  @override
  String get notesPinned => 'Pinned';

  @override
  String get notesAll => 'All Notes';

  @override
  String get notesTodayJournal => 'Today\'s Journal';

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
  String journalForDate(String date) {
    return 'Daily Journal: $date';
  }

  @override
  String get insightsTitle => 'Insights';

  @override
  String get weeklyReviewTitle => 'Weekly Review';

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
      'Complete habits and check off tasks to unlock personalized patterns, weekly review cards, and productivity scores.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme Mode';

  @override
  String get settingsAccent => 'Accent Color';

  @override
  String get settingsGlass => 'Glass Intensity';

  @override
  String get settingsReduceTransparency => 'Reduce Transparency';

  @override
  String get settingsTime => 'Time & Orbit Boundary';

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
  String get securityTitle => 'App Lock & Security';

  @override
  String get biometricLock => 'Biometric Lock';

  @override
  String get biometricLockSubtitle =>
      'Require Face ID, fingerprint or device PIN on launch';

  @override
  String get lockTimeout => 'Lock Timeout';

  @override
  String get lockTimeoutImmediate => 'Immediately';

  @override
  String get lockTimeout30s => 'After 30 seconds';

  @override
  String get lockTimeout1m => 'After 1 minute';

  @override
  String get lockTimeout5m => 'After 5 minutes';

  @override
  String get hideContentRecents => 'Hide in Recent Apps';

  @override
  String get hideContentRecentsSubtitle =>
      'Blurs or blocks app preview in OS task switcher';

  @override
  String get unlockPrompt =>
      'Unlock Poswal Orbit to view your habits and notes';

  @override
  String get unlockWithBiometrics => 'Unlock with Biometrics';

  @override
  String get unlockWithPasscode => 'Use Device Passcode';

  @override
  String get widgetTodayProgress => 'Orbit Today Progress';

  @override
  String get widgetQuickCheckin => 'Quick Habit Check-in';

  @override
  String get widgetTasksGlance => 'Pending Tasks at a Glance';
}
