// Pure Dart schedule engine - ZERO Flutter imports.

import 'package:poswal_orbit/domain/models/habit_models.dart';

class ScheduleEngine {
  /// Checks whether [habit] is expected to be performed on [date].
  static bool isScheduledOn(Habit habit, DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final startDate = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);

    // If before start date, not scheduled
    if (targetDate.isBefore(startDate)) {
      return false;
    }

    // If after end date (when specified), not scheduled
    if (habit.endDate != null) {
      final endDate = DateTime(habit.endDate!.year, habit.endDate!.month, habit.endDate!.day);
      if (targetDate.isAfter(endDate)) {
        return false;
      }
    }

    switch (habit.scheduleType) {
      case ScheduleType.daily:
        return true;

      case ScheduleType.weekdays:
        if (habit.scheduleDays.isNotEmpty) {
          return habit.scheduleDays.contains(targetDate.weekday);
        }
        // Standard Monday through Friday (1 to 5)
        return targetDate.weekday >= DateTime.monday && targetDate.weekday <= DateTime.friday;

      case ScheduleType.everyNDays:
        if (habit.everyNDaysInterval <= 1) return true;
        final differenceInDays = targetDate.difference(startDate).inDays;
        if (differenceInDays < 0) return false;
        return differenceInDays % habit.everyNDaysInterval == 0;

      case ScheduleType.xPerWeek:
        // For target count per week, any active day in the week is an eligible opportunity
        if (habit.scheduleDays.isNotEmpty) {
          return habit.scheduleDays.contains(targetDate.weekday);
        }
        return true;

      case ScheduleType.xPerMonth:
        return true;
    }
  }

  /// Generates a human-friendly schedule description string.
  static String formatScheduleDescription(Habit habit) {
    switch (habit.scheduleType) {
      case ScheduleType.daily:
        return 'Daily';
      case ScheduleType.weekdays:
        if (habit.scheduleDays.isNotEmpty) {
          const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return habit.scheduleDays.map((d) => names[d - 1]).join(', ');
        }
        return 'Weekdays';
      case ScheduleType.xPerWeek:
        return '${habit.targetDaysPerPeriod}x per week';
      case ScheduleType.xPerMonth:
        return '${habit.targetDaysPerPeriod}x per month';
      case ScheduleType.everyNDays:
        return 'Every ${habit.everyNDaysInterval} days';
    }
  }
}
