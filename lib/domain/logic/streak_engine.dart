// Pure Dart streak calculation engine - ZERO Flutter imports.
// Implements Poswal Orbit Master Prompt Section 6.1 streak rules.

import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';

class StreakCalculation {
  final int currentStreak;
  final int bestStreak;
  final int freezesUsed;

  const StreakCalculation({
    required this.currentStreak,
    required this.bestStreak,
    this.freezesUsed = 0,
  });
}

class StreakEngine {
  /// Calculates current and best streaks for [habit] given its complete [entries] history.
  /// [referenceDate]: Logical app date to evaluate streaks from (defaults to today).
  /// [availableFreezes]: Number of streak freezes available to protect missed days.
  static StreakCalculation calculate({
    required Habit habit,
    required List<HabitEntry> entries,
    required DateTime referenceDate,
    int availableFreezes = 0,
  }) {
    if (habit.scheduleType == ScheduleType.xPerWeek) {
      return _calculateWeeklyStreak(habit, entries, referenceDate);
    }

    return _calculateDailyStreak(
      habit: habit,
      entries: entries,
      referenceDate: referenceDate,
      availableFreezes: availableFreezes,
    );
  }

  /// Calculates streaks for day-based schedules (Daily, Weekdays, Every N Days).
  static StreakCalculation _calculateDailyStreak({
    required Habit habit,
    required List<HabitEntry> entries,
    required DateTime referenceDate,
    required int availableFreezes,
  }) {
    // Map entries by YYYY-MM-DD
    final Map<String, HabitEntry> entryMap = {
      for (final e in entries) e.entryDate: e,
    };

    final ref = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    final start = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);

    if (ref.isBefore(start)) {
      return const StreakCalculation(currentStreak: 0, bestStreak: 0);
    }

    // Determine current streak starting point:
    // If today is scheduled and completed, start from today.
    // If today has no entry yet (day in progress), evaluate from yesterday.
    // If today was skipped, preserve streak from yesterday.
    // If today was entered but missed / incomplete, check streak freeze.
    final todayStr = DateBoundary.toDateString(ref);
    final todayEntry = entryMap[todayStr];
    final bool todayDone = todayEntry != null && _isEntryCompleted(habit, todayEntry);

    DateTime evalDate = ref;
    int currentStreak = 0;
    int remainingFreezes = availableFreezes;
    int freezesUsed = 0;

    if (!todayDone) {
      if (todayEntry == null) {
        // Today is not yet entered / still in progress:
        // Gracefully evaluate streak from yesterday
        evalDate = ref.subtract(const Duration(days: 1));
      } else if (todayEntry.status == HabitEntryStatus.skipped) {
        // Skipped does not break streak: evaluate from yesterday
        evalDate = ref.subtract(const Duration(days: 1));
      } else {
        // Today was entered but failed / missed:
        if (remainingFreezes > 0) {
          remainingFreezes--;
          freezesUsed++;
          evalDate = ref.subtract(const Duration(days: 1));
        } else {
          // Missed today with no freeze -> current streak broken (0)
          evalDate = start.subtract(const Duration(days: 1));
        }
      }
    }

    while (!evalDate.isBefore(start)) {
      final isScheduled = ScheduleEngine.isScheduledOn(habit, evalDate);

      // Rule: Days not scheduled are ignored (do not break and do not add)
      if (!isScheduled) {
        evalDate = evalDate.subtract(const Duration(days: 1));
        continue;
      }

      final dateKey = DateBoundary.toDateString(evalDate);
      final entry = entryMap[dateKey];

      if (entry != null && _isEntryCompleted(habit, entry)) {
        // Rule: Consecutive scheduled occurrences done add to streak
        currentStreak++;
      } else if (entry != null && entry.status == HabitEntryStatus.skipped) {
        // Rule: Skipped does NOT break streak and does NOT add to it
        // Keep scanning backward
      } else {
        // Missed or unentered scheduled day:
        // Rule: Streak freeze protects one missed day
        if (remainingFreezes > 0) {
          remainingFreezes--;
          freezesUsed++;
          // Freeze absorbed the miss: streak continues
        } else {
          // No freeze available: streak ends
          break;
        }
      }

      evalDate = evalDate.subtract(const Duration(days: 1));
    }

    // Calculate Best Streak across full historical timeline (forward pass)
    int bestStreak = 0;
    int runningStreak = 0;
    DateTime cursor = start;

    while (!cursor.isAfter(ref)) {
      final isScheduled = ScheduleEngine.isScheduledOn(habit, cursor);
      if (!isScheduled) {
        cursor = cursor.add(const Duration(days: 1));
        continue;
      }

      final dateKey = DateBoundary.toDateString(cursor);
      final entry = entryMap[dateKey];

      if (entry != null && _isEntryCompleted(habit, entry)) {
        runningStreak++;
        if (runningStreak > bestStreak) {
          bestStreak = runningStreak;
        }
      } else if (entry != null && entry.status == HabitEntryStatus.skipped) {
        // Skipped preserves streak
      } else {
        runningStreak = 0;
      }

      cursor = cursor.add(const Duration(days: 1));
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    return StreakCalculation(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      freezesUsed: freezesUsed,
    );
  }

  /// Calculates weekly streaks for X-per-week habits.
  static StreakCalculation _calculateWeeklyStreak(
    Habit habit,
    List<HabitEntry> entries,
    DateTime referenceDate,
  ) {
    final Map<String, int> weeklyCompletions = {};
    for (final entry in entries) {
      if (_isEntryCompleted(habit, entry)) {
        final date = DateBoundary.parseDateString(entry.entryDate);
        final weekKey = DateBoundary.getWeekKey(date);
        weeklyCompletions[weekKey] = (weeklyCompletions[weekKey] ?? 0) + 1;
      }
    }

    final currentWeekKey = DateBoundary.getWeekKey(referenceDate);
    final target = habit.targetDaysPerPeriod > 0 ? habit.targetDaysPerPeriod : 1;

    // Evaluate backwards week by week
    int currentStreak = 0;
    int bestStreak = 0;
    DateTime weekCursor = referenceDate;
    final start = habit.startDate;

    final currentWeekCount = weeklyCompletions[currentWeekKey] ?? 0;
    final bool currentWeekMet = currentWeekCount >= target;

    if (currentWeekMet) {
      currentStreak = 1;
      weekCursor = weekCursor.subtract(const Duration(days: 7));
    } else {
      // Current week in progress, start evaluation from prior week
      weekCursor = weekCursor.subtract(const Duration(days: 7));
    }

    while (!weekCursor.isBefore(start)) {
      final key = DateBoundary.getWeekKey(weekCursor);
      final count = weeklyCompletions[key] ?? 0;
      if (count >= target) {
        currentStreak++;
      } else {
        break;
      }
      weekCursor = weekCursor.subtract(const Duration(days: 7));
    }

    // Historical scan for best weekly streak
    int running = 0;
    DateTime forwardCursor = start;
    while (!forwardCursor.isAfter(referenceDate)) {
      final key = DateBoundary.getWeekKey(forwardCursor);
      final count = weeklyCompletions[key] ?? 0;
      if (count >= target) {
        running++;
        if (running > bestStreak) bestStreak = running;
      } else {
        running = 0;
      }
      forwardCursor = forwardCursor.add(const Duration(days: 7));
    }

    if (currentStreak > bestStreak) bestStreak = currentStreak;

    return StreakCalculation(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
    );
  }

  static bool _isEntryCompleted(Habit habit, HabitEntry entry) {
    if (entry.status == HabitEntryStatus.done) {
      if (habit.habitType == HabitType.numeric) {
        // Rule: Numeric habit is done when value >= target
        return entry.value >= habit.targetValue;
      }
      return true;
    }
    return false;
  }
}
