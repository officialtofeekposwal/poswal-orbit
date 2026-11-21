import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/streak_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';

void main() {
  group('StreakEngine (Master Prompt Section 6.1 Rules)', () {
    final dailyHabit = Habit(
      id: 'h1',
      name: 'Read 20 min',
      iconName: 'book',
      colorValue: 0xFF8B7CFF,
      habitType: HabitType.yesNo,
      targetValue: 1.0,
      unit: 'times',
      timeOfDay: TimeOfDayGroup.evening,
      scheduleType: ScheduleType.daily,
      startDate: DateTime(2026, 11, 1),
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
    );

    test('Rule 1: Consecutive scheduled occurrences done increment streak', () {
      final entries = [
        HabitEntry(
          id: 'e1',
          habitId: 'h1',
          entryDate: '2026-11-18',
          status: HabitEntryStatus.done,
          value: 1.0,
          createdAt: DateTime(2026, 11, 18),
          updatedAt: DateTime(2026, 11, 18),
        ),
        HabitEntry(
          id: 'e2',
          habitId: 'h1',
          entryDate: '2026-11-19',
          status: HabitEntryStatus.done,
          value: 1.0,
          createdAt: DateTime(2026, 11, 19),
          updatedAt: DateTime(2026, 11, 19),
        ),
        HabitEntry(
          id: 'e3',
          habitId: 'h1',
          entryDate: '2026-11-20',
          status: HabitEntryStatus.done,
          value: 1.0,
          createdAt: DateTime(2026, 11, 20),
          updatedAt: DateTime(2026, 11, 20),
        ),
      ];

      final res = StreakEngine.calculate(
        habit: dailyHabit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 20),
      );

      expect(res.currentStreak, 3);
      expect(res.bestStreak, 3);
    });

    test('Rule 2: Days that are not scheduled are ignored (e.g. weekends do not break weekday streak)', () {
      final weekdayHabit = dailyHabit.copyWith(scheduleType: ScheduleType.weekdays);

      // Friday Nov 20 = Done
      // Saturday Nov 21 = Not scheduled
      // Sunday Nov 22 = Not scheduled
      // Monday Nov 23 = Done
      final entries = [
        HabitEntry(
          id: 'e1',
          habitId: 'h1',
          entryDate: '2026-11-20',
          status: HabitEntryStatus.done,
          value: 1.0,
          createdAt: DateTime(2026, 11, 20),
          updatedAt: DateTime(2026, 11, 20),
        ),
        HabitEntry(
          id: 'e2',
          habitId: 'h1',
          entryDate: '2026-11-23',
          status: HabitEntryStatus.done,
          value: 1.0,
          createdAt: DateTime(2026, 11, 23),
          updatedAt: DateTime(2026, 11, 23),
        ),
      ];

      final res = StreakEngine.calculate(
        habit: weekdayHabit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 23),
      );

      // Friday and Monday are consecutive scheduled days -> streak is 2
      expect(res.currentStreak, 2);
    });

    test('Rule 3: Skipped does NOT break streak and does NOT add to it', () {
      // Nov 18 = Done (+1)
      // Nov 19 = Skipped (preserves streak, +0)
      // Nov 20 = Done (+1)
      final entries = [
        HabitEntry(
          id: 'e1',
          habitId: 'h1',
          entryDate: '2026-11-18',
          status: HabitEntryStatus.done,
          value: 1.0,
          createdAt: DateTime(2026, 11, 18),
          updatedAt: DateTime(2026, 11, 18),
        ),
        HabitEntry(
          id: 'e2',
          habitId: 'h1',
          entryDate: '2026-11-19',
          status: HabitEntryStatus.skipped,
          value: 0.0,
          note: 'Excused sick day',
          createdAt: DateTime(2026, 11, 19),
          updatedAt: DateTime(2026, 11, 19),
        ),
        HabitEntry(
          id: 'e3',
          habitId: 'h1',
          entryDate: '2026-11-20',
          status: HabitEntryStatus.done,
          value: 1.0,
          createdAt: DateTime(2026, 11, 20),
          updatedAt: DateTime(2026, 11, 20),
        ),
      ];

      final res = StreakEngine.calculate(
        habit: dailyHabit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 20),
      );

      // Nov 18 (done=1) -> Nov 19 (skipped=no change) -> Nov 20 (done=2)
      expect(res.currentStreak, 2);
    });

    test('Rule 4: Numeric habit is done only when value >= target', () {
      final waterHabit = Habit(
        id: 'h2',
        name: 'Drink 8 glasses of water',
        iconName: 'drop',
        colorValue: 0xFF14B8A6,
        habitType: HabitType.numeric,
        targetValue: 8.0,
        unit: 'glasses',
        timeOfDay: TimeOfDayGroup.anytime,
        scheduleType: ScheduleType.daily,
        startDate: DateTime(2026, 11, 1),
        createdAt: DateTime(2026, 11, 1),
        updatedAt: DateTime(2026, 11, 1),
      );

      // Nov 19: 8 glasses (met target)
      // Nov 20: 5 glasses (under target -> not completed)
      final entries = [
        HabitEntry(
          id: 'e1',
          habitId: 'h2',
          entryDate: '2026-11-19',
          status: HabitEntryStatus.done,
          value: 8.0,
          createdAt: DateTime(2026, 11, 19),
          updatedAt: DateTime(2026, 11, 19),
        ),
        HabitEntry(
          id: 'e2',
          habitId: 'h2',
          entryDate: '2026-11-20',
          status: HabitEntryStatus.done,
          value: 5.0, // < 8 target!
          createdAt: DateTime(2026, 11, 20),
          updatedAt: DateTime(2026, 11, 20),
        ),
      ];

      final res = StreakEngine.calculate(
        habit: waterHabit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 20),
      );

      // On Nov 20, 5 is not >= 8, so streak is 0 on Nov 20
      expect(res.currentStreak, 0);
      expect(res.bestStreak, 1);
    });

    test('Rule 5: X-per-week habit counts consecutive weeks that met the target', () {
      final gymHabit = Habit(
        id: 'h3',
        name: 'Gym Workout',
        iconName: 'barbell',
        colorValue: 0xFFFF7A59,
        habitType: HabitType.yesNo,
        targetValue: 1.0,
        unit: 'times',
        timeOfDay: TimeOfDayGroup.morning,
        scheduleType: ScheduleType.xPerWeek,
        targetDaysPerPeriod: 3, // 3 times per week
        startDate: DateTime(2026, 11, 1),
        createdAt: DateTime(2026, 11, 1),
        updatedAt: DateTime(2026, 11, 1),
      );

      // Week 46 (Nov 9 - Nov 15): 3 sessions done -> week met
      // Week 47 (Nov 16 - Nov 22): 3 sessions done -> week met
      final entries = [
        // Week 46
        HabitEntry(id: '1', habitId: 'h3', entryDate: '2026-11-10', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 10), updatedAt: DateTime(2026, 11, 10)),
        HabitEntry(id: '2', habitId: 'h3', entryDate: '2026-11-12', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 12), updatedAt: DateTime(2026, 11, 12)),
        HabitEntry(id: '3', habitId: 'h3', entryDate: '2026-11-14', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 14), updatedAt: DateTime(2026, 11, 14)),
        // Week 47
        HabitEntry(id: '4', habitId: 'h3', entryDate: '2026-11-17', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 17), updatedAt: DateTime(2026, 11, 17)),
        HabitEntry(id: '5', habitId: 'h3', entryDate: '2026-11-19', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 19), updatedAt: DateTime(2026, 11, 19)),
        HabitEntry(id: '6', habitId: 'h3', entryDate: '2026-11-21', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 21), updatedAt: DateTime(2026, 11, 21)),
      ];

      final res = StreakEngine.calculate(
        habit: gymHabit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 21),
      );

      expect(res.currentStreak, 2);
    });

    test('Rule 6: Streak freeze protects one missed day', () {
      // Nov 18 = Done
      // Nov 19 = Missed (protected by 1 available freeze!)
      // Nov 20 = Done
      final entries = [
        HabitEntry(id: '1', habitId: 'h1', entryDate: '2026-11-18', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 18), updatedAt: DateTime(2026, 11, 18)),
        // Nov 19 is unentered / missed
        HabitEntry(id: '2', habitId: 'h1', entryDate: '2026-11-20', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 20), updatedAt: DateTime(2026, 11, 20)),
      ];

      // Without freeze:
      final withoutFreeze = StreakEngine.calculate(
        habit: dailyHabit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 20),
        availableFreezes: 0,
      );
      expect(withoutFreeze.currentStreak, 1); // Only Nov 20

      // With 1 freeze:
      final withFreeze = StreakEngine.calculate(
        habit: dailyHabit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 20),
        availableFreezes: 1,
      );
      expect(withFreeze.currentStreak, 2); // Nov 18 + Nov 20 protected!
      expect(withFreeze.freezesUsed, 1);
    });
  });
}
