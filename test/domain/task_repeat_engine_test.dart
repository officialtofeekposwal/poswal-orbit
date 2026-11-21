import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/task_repeat_engine.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

void main() {
  group('TaskRepeatEngine Unit Tests', () {
    test('Daily repeat adds interval days correctly', () {
      final base = DateTime(2026, 11, 21, 10, 0); // Saturday
      const rule = TaskRepeatRule(type: TaskRepeatType.daily, interval: 1);

      final next = TaskRepeatEngine.calculateNextDueDate(
        rule: rule,
        currentDue: base,
      );

      expect(next, DateTime(2026, 11, 22, 10, 0));
    });

    test('Weekdays repeat skips Saturday and Sunday (Friday -> Monday)', () {
      final friday = DateTime(2026, 11, 20, 14, 0); // Friday
      const rule = TaskRepeatRule(type: TaskRepeatType.weekdays);

      final next = TaskRepeatEngine.calculateNextDueDate(
        rule: rule,
        currentDue: friday,
      );

      expect(next, DateTime(2026, 11, 23, 14, 0)); // Monday
      expect(next!.weekday, DateTime.monday);
    });

    test('Weekly repeat adds 7 * interval days', () {
      final base = DateTime(2026, 11, 21, 9, 30);
      const rule = TaskRepeatRule(type: TaskRepeatType.weekly, interval: 2);

      final next = TaskRepeatEngine.calculateNextDueDate(
        rule: rule,
        currentDue: base,
      );

      expect(next, DateTime(2026, 12, 5, 9, 30));
    });

    test('Monthly repeat preserves day or clamps for shorter months', () {
      final jan31 = DateTime(2026, 1, 31, 11, 0);
      const rule = TaskRepeatRule(type: TaskRepeatType.monthly, interval: 1);

      final next = TaskRepeatEngine.calculateNextDueDate(
        rule: rule,
        currentDue: jan31,
      );

      expect(next, DateTime(2026, 2, 28, 11, 0)); // 2026 is non-leap year
    });

    test('Custom days repeat advances to the next specified weekday', () {
      final monday = DateTime(2026, 11, 16, 8, 0); // Monday
      // Repeat on Monday (1), Wednesday (3), Friday (5)
      const rule = TaskRepeatRule(
        type: TaskRepeatType.custom,
        daysOfWeek: [1, 3, 5],
      );

      final next = TaskRepeatEngine.calculateNextDueDate(
        rule: rule,
        currentDue: monday,
      );

      expect(next, DateTime(2026, 11, 18, 8, 0)); // Wednesday
      expect(next!.weekday, DateTime.wednesday);
    });

    test('After-completion repeat calculates from completionDate', () {
      final due = DateTime(2026, 11, 10, 12, 0);
      final completed = DateTime(2026, 11, 21, 16, 0); // Completed 11 days late
      const rule = TaskRepeatRule(
        type: TaskRepeatType.afterCompletion,
        afterDays: 3,
      );

      final next = TaskRepeatEngine.calculateNextDueDate(
        rule: rule,
        currentDue: due,
        completionDate: completed,
      );

      expect(next, DateTime(2026, 11, 24, 16, 0)); // 3 days after completion
    });
  });
}
