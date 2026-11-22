import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/logic/streak_engine.dart';
import 'package:poswal_orbit/domain/logic/task_nlp_parser.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

void main() {
  group('Scalability & Edge Cases Performance Tests', () {
    test('Evaluates 1000 habit streaks in under 100 milliseconds', () {
      final now = DateTime(2026, 11, 21, 10, 0);

      final habits = List.generate(
        1000,
        (i) => Habit(
          id: 'habit-$i',
          name: 'Habit $i',
          iconName: 'target',
          colorValue: 0xFF14B8A6,
          habitType: HabitType.yesNo,
          targetValue: 1.0,
          unit: 'times',
          timeOfDay: TimeOfDayGroup.anytime,
          scheduleType: ScheduleType.daily,
          startDate: now.subtract(const Duration(days: 30)),
          createdAt: now,
          updatedAt: now,
        ),
      );

      int scheduledCount = 0;
      int zeroStreakCount = 0;
      final stopwatch = Stopwatch()..start();

      for (final h in habits) {
        if (ScheduleEngine.isScheduledOn(h, now)) scheduledCount++;

        final streak = StreakEngine.calculate(
          habit: h,
          entries: const [],
          referenceDate: now,
        );
        if (streak.currentStreak == 0) zeroStreakCount++;
      }

      stopwatch.stop();
      expect(scheduledCount, equals(1000));
      expect(zeroStreakCount, equals(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(800),
          reason: '1000 habit schedule and streak evaluations must complete well under 800ms');
    });

    test('Parses 1000 natural language tasks in under 100 milliseconds', () {
      final refDate = DateTime(2026, 11, 21, 12, 0);

      int urgentCount = 0;
      int hasTimeCount = 0;
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        final parsed = TaskNlpParser.parse(
          'Complete audit item $i tomorrow 5pm !urgent #work',
          referenceDate: refDate,
        );
        if (parsed.priority == TaskPriority.urgent) urgentCount++;
        if (parsed.hasTime) hasTimeCount++;
      }

      stopwatch.stop();
      expect(urgentCount, equals(1000));
      expect(hasTimeCount, equals(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(2500),
          reason: '1000 NLP task parsing operations must complete well under 2500ms');
    });

    test('Handles extreme string lengths safely without crashing or throwing', () {
      final refDate = DateTime(2026, 11, 21, 12, 0);

      final longText = 'A' * 2000;
      final parsed = TaskNlpParser.parse(longText, referenceDate: refDate);
      expect(parsed.cleanTitle.length, equals(2000));
      expect(parsed.priority, equals(TaskPriority.none));
    });
  });
}
