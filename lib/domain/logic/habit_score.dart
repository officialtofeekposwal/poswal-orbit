// Pure Dart habit score calculator - ZERO Flutter imports.
// Implements Poswal Orbit Master Prompt Section 6.1 EWMA consistency score (inspired by Loop Habit Tracker).

import 'dart:math' as math;
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';

/// Habit Consistency Score using Exponentially Weighted Moving Average (EWMA).
///
/// Mathematical Formula:
/// ---------------------
/// For each day t from habit start to reference date:
///
///   If day t is unscheduled or skipped:
///     S_t = S_{t-1}  (no decay occurs for non-scheduled or excused days)
///
///   If day t is scheduled:
///     S_t = S_{t-1} * lambda + C_t * (1 - lambda)
///
///   where:
///     - lambda = 0.5 ^ (1 / halfLifeDays)
///       With halfLife = 14 days, lambda ~= 0.9517.
///       A habit performed consistently for 14 days reaches ~50% of the maximum
///       from zero, and reaches ~95%+ within 40-50 days.
///     - C_t in [0.0, 1.0]:
///       * Yes/No: 1.0 if done, 0.0 if missed.
///       * Numeric: clamp(value / target, 0.0, 1.0).
///     - S_t in [0.0, 1.0]: Output habit strength percentage.
class HabitScoreCalculator {
  final int halfLifeDays;

  const HabitScoreCalculator({this.halfLifeDays = 14});

  double get lambda => math.pow(0.5, 1.0 / halfLifeDays).toDouble();

  /// Calculates the current habit score (0.0 to 1.0) on [referenceDate].
  double calculate({
    required Habit habit,
    required List<HabitEntry> entries,
    required DateTime referenceDate,
  }) {
    final start = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
    final ref = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);

    if (ref.isBefore(start)) {
      return 0.0;
    }

    final Map<String, HabitEntry> entryMap = {
      for (final e in entries) e.entryDate: e,
    };

    final double decay = lambda;
    final double weight = 1.0 - decay;
    double score = 0.0;

    DateTime cursor = start;
    while (!cursor.isAfter(ref)) {
      final isScheduled = ScheduleEngine.isScheduledOn(habit, cursor);

      if (!isScheduled) {
        // Unscheduled days do not degrade score
        cursor = cursor.add(const Duration(days: 1));
        continue;
      }

      final dateStr = DateBoundary.toDateString(cursor);
      final entry = entryMap[dateStr];

      if (entry != null && entry.status == HabitEntryStatus.skipped) {
        // Skipped days do not degrade score
        cursor = cursor.add(const Duration(days: 1));
        continue;
      }

      double completion = 0.0;
      if (entry != null && entry.status == HabitEntryStatus.done) {
        if (habit.habitType == HabitType.numeric) {
          if (habit.targetValue > 0) {
            completion = (entry.value / habit.targetValue).clamp(0.0, 1.0);
          } else {
            completion = 1.0;
          }
        } else {
          completion = 1.0;
        }
      }

      score = (score * decay) + (completion * weight);
      cursor = cursor.add(const Duration(days: 1));
    }

    return score.clamp(0.0, 1.0);
  }

  /// Formats score as a 0-100 percentage integer.
  static int toPercentage(double score) {
    return (score * 100).round().clamp(0, 100);
  }
}
