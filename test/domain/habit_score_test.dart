import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/habit_score.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';

void main() {
  group('HabitScoreCalculator (EWMA Consistency Score)', () {
    const calculator = HabitScoreCalculator(halfLifeDays: 14);

    final habit = Habit(
      id: 'score-habit',
      name: 'Meditation',
      iconName: 'sparkle',
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

    test('Habit with zero entries has a score of 0.0', () {
      final score = calculator.calculate(
        habit: habit,
        entries: [],
        referenceDate: DateTime(2026, 11, 15),
      );
      expect(score, 0.0);
    });

    test('Consistent daily performance increases score exponentially towards 1.0', () {
      final entries = List.generate(14, (i) {
        final day = (i + 1).toString().padLeft(2, '0');
        return HabitEntry(
          id: 'e-$i',
          habitId: 'score-habit',
          entryDate: '2026-11-$day',
          status: HabitEntryStatus.done,
          value: 1.0,
          createdAt: DateTime(2026, 11, i + 1),
          updatedAt: DateTime(2026, 11, i + 1),
        );
      });

      final scoreAt14Days = calculator.calculate(
        habit: habit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 14),
      );

      // By definition of half-life = 14 days, score after 14 consecutive days of 1.0 is ~50%
      expect(scoreAt14Days, greaterThanOrEqualTo(0.48));
      expect(scoreAt14Days, lessThanOrEqualTo(0.52));
    });

    test('Skipped days do not cause score decay', () {
      final entries = [
        HabitEntry(id: '1', habitId: 'score-habit', entryDate: '2026-11-01', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 1), updatedAt: DateTime(2026, 11, 1)),
        HabitEntry(id: '2', habitId: 'score-habit', entryDate: '2026-11-02', status: HabitEntryStatus.skipped, value: 0.0, createdAt: DateTime(2026, 11, 2), updatedAt: DateTime(2026, 11, 2)),
      ];

      final scoreNov1 = calculator.calculate(
        habit: habit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 1),
      );

      final scoreNov2 = calculator.calculate(
        habit: habit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 2),
      );

      // Score should not decrease on an excused skipped day
      expect(scoreNov2, equals(scoreNov1));
    });

    test('Missed scheduled days cause exponential score decay', () {
      final entries = [
        HabitEntry(id: '1', habitId: 'score-habit', entryDate: '2026-11-01', status: HabitEntryStatus.done, value: 1.0, createdAt: DateTime(2026, 11, 1), updatedAt: DateTime(2026, 11, 1)),
      ];

      final scoreNov1 = calculator.calculate(
        habit: habit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 1),
      );

      // Nov 2 through Nov 5 missed:
      final scoreNov5 = calculator.calculate(
        habit: habit,
        entries: entries,
        referenceDate: DateTime(2026, 11, 5),
      );

      expect(scoreNov5, lessThan(scoreNov1));
    });
  });
}
