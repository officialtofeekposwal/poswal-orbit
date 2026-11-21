import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/insights_engine.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/logic/streak_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/tasks/application/task_providers.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class InsightsState {
  final bool hasAnyData;
  final WeeklyReviewData weeklyReview;
  final ProductivityScoreResult productivityScore;
  final BestTimeResult bestTiming;
  final HabitTaskCorrelationResult correlation;
  final List<Habit> habits;
  final List<HabitEntry> entries;
  final List<Task> tasks;
  final Map<String, int> dailyOverallCompletions; // dateStr -> count

  const InsightsState({
    required this.hasAnyData,
    required this.weeklyReview,
    required this.productivityScore,
    required this.bestTiming,
    required this.correlation,
    required this.habits,
    required this.entries,
    required this.tasks,
    required this.dailyOverallCompletions,
  });
}

final allHabitEntriesStreamProvider = StreamProvider<List<HabitEntry>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchAllEntries();
});

final allTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAllTasks();
});

final insightsDataProvider = Provider<AsyncValue<InsightsState>>((ref) {
  final habitsAsync = ref.watch(activeHabitsStreamProvider);
  final entriesAsync = ref.watch(allHabitEntriesStreamProvider);
  final tasksAsync = ref.watch(allTasksStreamProvider);

  if (habitsAsync.isLoading || entriesAsync.isLoading || tasksAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (habitsAsync.hasError) {
    return AsyncValue.error(habitsAsync.error!, habitsAsync.stackTrace!);
  }
  if (entriesAsync.hasError) {
    return AsyncValue.error(entriesAsync.error!, entriesAsync.stackTrace!);
  }
  if (tasksAsync.hasError) {
    return AsyncValue.error(tasksAsync.error!, tasksAsync.stackTrace!);
  }

  final habits = habitsAsync.value ?? [];
  final entries = entriesAsync.value ?? [];
  final tasks = tasksAsync.value ?? [];

  const boundary = DateBoundary(dayStartHour: 4);
  final today = boundary.getAppDate(DateTime.now());

  // 1. Last 7 Days Window
  final List<DateTime> last7Days = [];
  final Set<String> last7DaysStr = {};
  for (int i = 6; i >= 0; i--) {
    final d = today.subtract(Duration(days: i));
    last7Days.add(d);
    last7DaysStr.add(DateBoundary.toDateString(d));
  }

  int habitCompletionsLast7Days = 0;
  int habitOpportunitiesLast7Days = 0;

  for (final habit in habits) {
    for (final day in last7Days) {
      if (ScheduleEngine.isScheduledOn(habit, day)) {
        habitOpportunitiesLast7Days++;
      }
    }
  }

  final Map<String, List<HabitEntry>> entriesByHabit = {};
  final Map<String, int> dailyOverallCompletions = {};
  final List<DateTime> allCompletionTimestamps = [];
  final Set<String> distinctActiveDates = {};

  for (final entry in entries) {
    entriesByHabit.putIfAbsent(entry.habitId, () => []).add(entry);

    if (entry.isDone) {
      distinctActiveDates.add(entry.entryDate);
      dailyOverallCompletions[entry.entryDate] = (dailyOverallCompletions[entry.entryDate] ?? 0) + 1;
      allCompletionTimestamps.add(entry.updatedAt);

      if (last7DaysStr.contains(entry.entryDate)) {
        habitCompletionsLast7Days++;
      }
    }
  }

  int tasksCompletedLast7Days = 0;
  int tasksTotalDueLast7Days = 0;

  for (final task in tasks) {
    if (task.isCompleted && task.completedAt != null) {
      allCompletionTimestamps.add(task.completedAt!);
      final dStr = DateBoundary.toDateString(boundary.getAppDate(task.completedAt!));
      distinctActiveDates.add(dStr);
      dailyOverallCompletions[dStr] = (dailyOverallCompletions[dStr] ?? 0) + 1;

      if (last7DaysStr.contains(dStr)) {
        tasksCompletedLast7Days++;
      }
    }

    if (task.dueAt != null) {
      final taskDueDateStr = DateBoundary.toDateString(boundary.getAppDate(task.dueAt!));
      if (last7DaysStr.contains(taskDueDateStr)) {
        tasksTotalDueLast7Days++;
      }
    }
  }

  // Calculate Best Streak across habits
  int bestStreak = 0;
  for (final habit in habits) {
    final habitEntries = entriesByHabit[habit.id] ?? [];
    final streak = StreakEngine.calculate(
      habit: habit,
      entries: habitEntries,
      referenceDate: today,
    );
    if (streak.bestStreak > bestStreak) {
      bestStreak = streak.bestStreak;
    }
    if (streak.currentStreak > bestStreak) {
      bestStreak = streak.currentStreak;
    }
  }

  final weeklyReview = InsightsEngine.generateWeeklyReview(
    habitsCompleted: habitCompletionsLast7Days,
    tasksCompleted: tasksCompletedLast7Days,
    bestStreak: bestStreak,
  );

  final productivityScore = InsightsEngine.calculateProductivityScore(
    habitCompletionsLast7Days: habitCompletionsLast7Days,
    scheduledHabitOpportunitiesLast7Days: habitOpportunitiesLast7Days,
    tasksCompletedLast7Days: tasksCompletedLast7Days,
    tasksTotalDueLast7Days: tasksTotalDueLast7Days,
  );

  final bestTiming = InsightsEngine.calculateBestTiming(
    completionTimestamps: allCompletionTimestamps,
  );

  final correlation = InsightsEngine.calculateHabitTaskCorrelation(
    habits: habits,
    entries: entries,
    tasks: tasks,
    distinctActiveDays: distinctActiveDates.length,
  );

  final bool hasAnyData = entries.any((e) => e.isDone) || tasks.any((t) => t.isCompleted);

  return AsyncValue.data(
    InsightsState(
      hasAnyData: hasAnyData,
      weeklyReview: weeklyReview,
      productivityScore: productivityScore,
      bestTiming: bestTiming,
      correlation: correlation,
      habits: habits,
      entries: entries,
      tasks: tasks,
      dailyOverallCompletions: dailyOverallCompletions,
    ),
  );
});
