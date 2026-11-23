import 'package:intl/intl.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

class WeeklyReviewData {
  final int habitsCompleted;
  final int tasksCompleted;
  final int bestStreak;
  final String encouragingMessage;

  const WeeklyReviewData({
    required this.habitsCompleted,
    required this.tasksCompleted,
    required this.bestStreak,
    required this.encouragingMessage,
  });
}

class ProductivityScoreResult {
  final double score; // 0 - 100
  final double habitConsistency; // 0 - 100
  final double taskCompletionRate; // 0 - 100
  final String grade;

  const ProductivityScoreResult({
    required this.score,
    required this.habitConsistency,
    required this.taskCompletionRate,
    required this.grade,
  });
}

class BestTimeResult {
  final int? bestWeekday; // 1 = Monday ... 7 = Sunday
  final String bestWeekdayName;
  final String bestTimeOfDayRange;
  final int peakCompletionsCount;

  const BestTimeResult({
    required this.bestWeekday,
    required this.bestWeekdayName,
    required this.bestTimeOfDayRange,
    required this.peakCompletionsCount,
  });
}

class HabitTaskCorrelationResult {
  final bool hasEnoughData;
  final String? habitId;
  final String? habitName;
  final double? taskBoostPercentage;
  final String insightText;

  const HabitTaskCorrelationResult({
    required this.hasEnoughData,
    this.habitId,
    this.habitName,
    this.taskBoostPercentage,
    required this.insightText,
  });
}

class InsightsEngine {
  static const int minDaysForCorrelation = 14;

  /// Calculates Productivity Score (0 to 100)
  /// Formula: 60% Habit Consistency + 40% Task Completion Rate
  static ProductivityScoreResult calculateProductivityScore({
    required int habitCompletionsLast7Days,
    required int scheduledHabitOpportunitiesLast7Days,
    required int tasksCompletedLast7Days,
    required int tasksTotalDueLast7Days,
  }) {
    final double habitConsistency = scheduledHabitOpportunitiesLast7Days > 0
        ? (habitCompletionsLast7Days / scheduledHabitOpportunitiesLast7Days).clamp(0.0, 1.0) * 100
        : (habitCompletionsLast7Days > 0 ? 100.0 : 0.0);

    final double taskRate = tasksTotalDueLast7Days > 0
        ? (tasksCompletedLast7Days / tasksTotalDueLast7Days).clamp(0.0, 1.0) * 100
        : (tasksCompletedLast7Days > 0 ? 100.0 : 0.0);

    double score;
    if (scheduledHabitOpportunitiesLast7Days == 0 && tasksTotalDueLast7Days == 0) {
      score = habitCompletionsLast7Days > 0 || tasksCompletedLast7Days > 0 ? 100.0 : 0.0;
    } else if (scheduledHabitOpportunitiesLast7Days == 0) {
      score = taskRate;
    } else if (tasksTotalDueLast7Days == 0) {
      score = habitConsistency;
    } else {
      score = (0.6 * habitConsistency) + (0.4 * taskRate);
    }

    score = score.clamp(0.0, 100.0);

    String grade;
    if (score >= 85) {
      grade = 'Thriving';
    } else if (score >= 65) {
      grade = 'Steady';
    } else if (score >= 40) {
      grade = 'Building';
    } else {
      grade = 'Starting';
    }

    return ProductivityScoreResult(
      score: double.parse(score.toStringAsFixed(1)),
      habitConsistency: double.parse(habitConsistency.toStringAsFixed(1)),
      taskCompletionRate: double.parse(taskRate.toStringAsFixed(1)),
      grade: grade,
    );
  }

  /// Calculates the best day of the week and best time window from completion timestamps.
  static BestTimeResult calculateBestTiming({
    required List<DateTime> completionTimestamps,
  }) {
    if (completionTimestamps.isEmpty) {
      return const BestTimeResult(
        bestWeekday: null,
        bestWeekdayName: 'No data yet',
        bestTimeOfDayRange: 'Keep tracking to reveal peak hours',
        peakCompletionsCount: 0,
      );
    }

    final weekdayCounts = <int, int>{};
    final hourWindowCounts = <String, int>{
      'Morning (6 AM - 12 PM)': 0,
      'Afternoon (12 PM - 5 PM)': 0,
      'Evening (5 PM - 10 PM)': 0,
      'Night (10 PM - 6 AM)': 0,
    };

    for (final dt in completionTimestamps) {
      weekdayCounts[dt.weekday] = (weekdayCounts[dt.weekday] ?? 0) + 1;

      final h = dt.hour;
      if (h >= 6 && h < 12) {
        hourWindowCounts['Morning (6 AM - 12 PM)'] = hourWindowCounts['Morning (6 AM - 12 PM)']! + 1;
      } else if (h >= 12 && h < 17) {
        hourWindowCounts['Afternoon (12 PM - 5 PM)'] = hourWindowCounts['Afternoon (12 PM - 5 PM)']! + 1;
      } else if (h >= 17 && h < 22) {
        hourWindowCounts['Evening (5 PM - 10 PM)'] = hourWindowCounts['Evening (5 PM - 10 PM)']! + 1;
      } else {
        hourWindowCounts['Night (10 PM - 6 AM)'] = hourWindowCounts['Night (10 PM - 6 AM)']! + 1;
      }
    }

    // Find best weekday
    int bestDay = 1;
    int maxDayCount = -1;
    weekdayCounts.forEach((day, count) {
      if (count > maxDayCount) {
        maxDayCount = count;
        bestDay = day;
      }
    });

    final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final bestDayName = weekdayNames[bestDay - 1];

    // Find best time window
    String bestWindow = 'Morning (6 AM - 12 PM)';
    int maxWindowCount = -1;
    hourWindowCounts.forEach((window, count) {
      if (count > maxWindowCount) {
        maxWindowCount = count;
        bestWindow = window;
      }
    });

    return BestTimeResult(
      bestWeekday: bestDay,
      bestWeekdayName: bestDayName,
      bestTimeOfDayRange: bestWindow,
      peakCompletionsCount: maxDayCount,
    );
  }

  /// Calculates habit-to-task correlation.
  /// Requires at least 14 days of history to avoid spurious claims, and carefully words findings.
  static HabitTaskCorrelationResult calculateHabitTaskCorrelation({
    required List<Habit> habits,
    required List<HabitEntry> entries,
    required List<Task> tasks,
    required int distinctActiveDays,
  }) {
    if (distinctActiveDays < minDaysForCorrelation || habits.isEmpty || tasks.isEmpty) {
      return const HabitTaskCorrelationResult(
        hasEnoughData: false,
        insightText: 'Correlations unlock after 14 days of consistent tracking.',
      );
    }

    // Group task completions by date YYYY-MM-DD
    final tasksByDate = <String, int>{};
    for (final task in tasks) {
      if (task.completedAt != null && task.isCompleted) {
        final dStr = DateFormat('yyyy-MM-dd').format(task.completedAt!);
        tasksByDate[dStr] = (tasksByDate[dStr] ?? 0) + 1;
      }
    }

    // Compare days habit was completed vs days habit was not completed
    Habit? topHabit;
    double maxBoost = -1.0;

    for (final habit in habits) {
      final habitDoneDates = entries
          .where((e) => e.habitId == habit.id && e.isDone)
          .map((e) => e.entryDate)
          .toSet();

      if (habitDoneDates.length < 5) continue; // Minimum sample

      int doneDayTasks = 0;
      int doneDaysCount = 0;
      int nonDoneDayTasks = 0;
      int nonDoneDaysCount = 0;

      for (final dateStr in tasksByDate.keys) {
        final count = tasksByDate[dateStr] ?? 0;
        if (habitDoneDates.contains(dateStr)) {
          doneDayTasks += count;
          doneDaysCount++;
        } else {
          nonDoneDayTasks += count;
          nonDoneDaysCount++;
        }
      }

      if (doneDaysCount >= 3 && nonDoneDaysCount >= 3) {
        final avgDone = doneDayTasks / doneDaysCount;
        final avgNonDone = nonDoneDayTasks / nonDoneDaysCount;

        if (avgNonDone > 0 && avgDone > avgNonDone) {
          final boost = ((avgDone - avgNonDone) / avgNonDone) * 100;
          if (boost > maxBoost) {
            maxBoost = boost;
            topHabit = habit;
          }
        }
      }
    }

    if (topHabit != null && maxBoost > 5) {
      final boostInt = maxBoost.round();
      return HabitTaskCorrelationResult(
        hasEnoughData: true,
        habitId: topHabit.id,
        habitName: topHabit.name,
        taskBoostPercentage: maxBoost,
        insightText: 'On days you complete "${topHabit.name}", you tend to finish $boostInt% more tasks.',
      );
    }

    return const HabitTaskCorrelationResult(
      hasEnoughData: true,
      insightText: 'Your habits and task completions are progressing evenly throughout the week.',
    );
  }

  /// Generates calm, encouraging Weekly Review data.
  static WeeklyReviewData generateWeeklyReview({
    required int habitsCompleted,
    required int tasksCompleted,
    required int bestStreak,
  }) {
    String encouragement;
    final totalActions = habitsCompleted + tasksCompleted;

    if (totalActions == 0) {
      encouragement = 'A fresh week is a clean slate. Small steps build greatness.';
    } else if (totalActions < 5) {
      encouragement = 'Every action counts. Consistency begins with a single check-in.';
    } else if (bestStreak >= 7) {
      encouragement = 'Unstoppable rhythm. Your habits are turning into natural second nature.';
    } else if (tasksCompleted > habitsCompleted) {
      encouragement = 'Superb task focus this week. High impact across all your priorities.';
    } else {
      encouragement = 'Balanced and steady progress. Keep building your momentum quietly.';
    }

    return WeeklyReviewData(
      habitsCompleted: habitsCompleted,
      tasksCompleted: tasksCompleted,
      bestStreak: bestStreak,
      encouragingMessage: encouragement,
    );
  }
}
