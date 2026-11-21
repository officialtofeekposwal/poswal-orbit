import 'package:poswal_orbit/domain/models/task_models.dart';

class TaskRepeatEngine {
  /// Calculates the next due date for a task based on its repeat rule.
  /// If the rule is [TaskRepeatType.afterCompletion], [completionDate] is used as the base.
  /// Otherwise, [currentDue] is used as the base.
  static DateTime? calculateNextDueDate({
    required TaskRepeatRule rule,
    required DateTime currentDue,
    DateTime? completionDate,
  }) {
    switch (rule.type) {
      case TaskRepeatType.daily:
        return _addDays(currentDue, rule.interval.clamp(1, 365));

      case TaskRepeatType.weekdays:
        return _nextWeekday(currentDue);

      case TaskRepeatType.weekly:
        return _addDays(currentDue, 7 * rule.interval.clamp(1, 52));

      case TaskRepeatType.monthly:
        return _addMonths(currentDue, rule.interval.clamp(1, 12));

      case TaskRepeatType.custom:
        return _nextCustomDay(currentDue, rule.daysOfWeek);

      case TaskRepeatType.afterCompletion:
        final base = completionDate ?? currentDue;
        return _addDays(base, rule.afterDays.clamp(1, 365));
    }
  }

  static DateTime _addDays(DateTime base, int days) {
    return DateTime(
      base.year,
      base.month,
      base.day + days,
      base.hour,
      base.minute,
      base.second,
      base.millisecond,
    );
  }

  static DateTime _nextWeekday(DateTime base) {
    DateTime next = _addDays(base, 1);
    while (next.weekday == DateTime.saturday || next.weekday == DateTime.sunday) {
      next = _addDays(next, 1);
    }
    return next;
  }

  static DateTime _addMonths(DateTime base, int months) {
    var newYear = base.year;
    var newMonth = base.month + months;

    while (newMonth > 12) {
      newYear += 1;
      newMonth -= 12;
    }

    final daysInNewMonth = _daysInMonth(newYear, newMonth);
    final newDay = base.day > daysInNewMonth ? daysInNewMonth : base.day;

    return DateTime(
      newYear,
      newMonth,
      newDay,
      base.hour,
      base.minute,
      base.second,
      base.millisecond,
    );
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const days = [31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  static DateTime _nextCustomDay(DateTime base, List<int> daysOfWeek) {
    if (daysOfWeek.isEmpty) {
      return _addDays(base, 1);
    }

    DateTime candidate = _addDays(base, 1);
    for (int i = 0; i < 14; i++) {
      if (daysOfWeek.contains(candidate.weekday)) {
        return candidate;
      }
      candidate = _addDays(candidate, 1);
    }
    return _addDays(base, 7);
  }
}
