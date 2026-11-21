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
}
