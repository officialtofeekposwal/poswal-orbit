import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';

void main() {
  group('ScheduleEngine', () {
    final baseHabit = Habit(
      id: 'test-habit-1',
      name: 'Morning Hydration',
      iconName: 'drop',
      colorValue: 0xFF14B8A6,
      habitType: HabitType.yesNo,
      targetValue: 1.0,
      unit: 'times',
      timeOfDay: TimeOfDayGroup.morning,
      scheduleType: ScheduleType.daily,
      startDate: DateTime(2026, 11, 1),
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
    );

    test('Daily schedule is scheduled every day after start date', () {
      expect(ScheduleEngine.isScheduledOn(baseHabit, DateTime(2026, 10, 31)), isFalse); // Before start
      expect(ScheduleEngine.isScheduledOn(baseHabit, DateTime(2026, 11, 1)), isTrue);
      expect(ScheduleEngine.isScheduledOn(baseHabit, DateTime(2026, 11, 21)), isTrue);
    });

    test('Weekdays schedule only matches Monday through Friday', () {
      final weekdayHabit = baseHabit.copyWith(scheduleType: ScheduleType.weekdays);

      // 2026-11-20 is Friday (weekday = 5)
      expect(ScheduleEngine.isScheduledOn(weekdayHabit, DateTime(2026, 11, 20)), isTrue);
      // 2026-11-21 is Saturday (weekday = 6)
      expect(ScheduleEngine.isScheduledOn(weekdayHabit, DateTime(2026, 11, 21)), isFalse);
      // 2026-11-22 is Sunday (weekday = 7)
      expect(ScheduleEngine.isScheduledOn(weekdayHabit, DateTime(2026, 11, 22)), isFalse);
      // 2026-11-23 is Monday (weekday = 1)
      expect(ScheduleEngine.isScheduledOn(weekdayHabit, DateTime(2026, 11, 23)), isTrue);
    });

    test('Custom days schedule matches specified days of week', () {
      // Monday (1), Wednesday (3), Friday (5) only
      final customHabit = baseHabit.copyWith(
        scheduleType: ScheduleType.weekdays,
        scheduleDays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
      );

      expect(ScheduleEngine.isScheduledOn(customHabit, DateTime(2026, 11, 16)), isTrue); // Mon
      expect(ScheduleEngine.isScheduledOn(customHabit, DateTime(2026, 11, 17)), isFalse); // Tue
      expect(ScheduleEngine.isScheduledOn(customHabit, DateTime(2026, 11, 18)), isTrue); // Wed
      expect(ScheduleEngine.isScheduledOn(customHabit, DateTime(2026, 11, 19)), isFalse); // Thu
      expect(ScheduleEngine.isScheduledOn(customHabit, DateTime(2026, 11, 20)), isTrue); // Fri
    });

    test('Every N Days schedule matches exact cadence', () {
      // Every 3 days starting Nov 1
      final cadenceHabit = baseHabit.copyWith(
        scheduleType: ScheduleType.everyNDays,
        everyNDaysInterval: 3,
        startDate: DateTime(2026, 11, 1),
      );

      expect(ScheduleEngine.isScheduledOn(cadenceHabit, DateTime(2026, 11, 1)), isTrue); // Day 0
      expect(ScheduleEngine.isScheduledOn(cadenceHabit, DateTime(2026, 11, 2)), isFalse);
      expect(ScheduleEngine.isScheduledOn(cadenceHabit, DateTime(2026, 11, 3)), isFalse);
      expect(ScheduleEngine.isScheduledOn(cadenceHabit, DateTime(2026, 11, 4)), isTrue); // Day 3
      expect(ScheduleEngine.isScheduledOn(cadenceHabit, DateTime(2026, 11, 7)), isTrue); // Day 6
    });

    test('End date stops schedule evaluation', () {
      final endedHabit = baseHabit.copyWith(
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 10),
      );

      expect(ScheduleEngine.isScheduledOn(endedHabit, DateTime(2026, 11, 10)), isTrue);
      expect(ScheduleEngine.isScheduledOn(endedHabit, DateTime(2026, 11, 11)), isFalse);
    });
  });
}
