import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/insights_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

Habit _createHabit({required String id, required String name}) {
  return Habit(
    id: id,
    name: name,
    iconName: 'target',
    colorValue: 0xFF14B8A6,
    habitType: HabitType.yesNo,
    targetValue: 1.0,
    unit: 'times',
    timeOfDay: TimeOfDayGroup.anytime,
    scheduleType: ScheduleType.daily,
    startDate: DateTime(2026, 1, 1),
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('InsightsEngine - Domain Logic & Productivity Formula Tests', () {
    test('1. calculateProductivityScore weights 60% habits and 40% tasks correctly', () {
      // 80% habit consistency, 50% task completion
      // Score = 0.6 * 80 + 0.4 * 50 = 48.0 + 20.0 = 68.0 -> Steady
      final res = InsightsEngine.calculateProductivityScore(
        habitCompletionsLast7Days: 8,
        scheduledHabitOpportunitiesLast7Days: 10,
        tasksCompletedLast7Days: 5,
        tasksTotalDueLast7Days: 10,
      );

      expect(res.score, 68.0);
      expect(res.habitConsistency, 80.0);
      expect(res.taskCompletionRate, 50.0);
      expect(res.grade, 'Steady');
    });

    test('2. calculateProductivityScore handles 100% completions as Thriving', () {
      final res = InsightsEngine.calculateProductivityScore(
        habitCompletionsLast7Days: 10,
        scheduledHabitOpportunitiesLast7Days: 10,
        tasksCompletedLast7Days: 5,
        tasksTotalDueLast7Days: 5,
      );

      expect(res.score, 100.0);
      expect(res.grade, 'Thriving');
    });

    test('3. calculateProductivityScore handles edge case with 0 scheduled opportunities without NaN', () {
      final res = InsightsEngine.calculateProductivityScore(
        habitCompletionsLast7Days: 0,
        scheduledHabitOpportunitiesLast7Days: 0,
        tasksCompletedLast7Days: 0,
        tasksTotalDueLast7Days: 0,
      );

      expect(res.score, 0.0);
      expect(res.grade, 'Starting');

      // Only tasks scheduled
      final resTasksOnly = InsightsEngine.calculateProductivityScore(
        habitCompletionsLast7Days: 0,
        scheduledHabitOpportunitiesLast7Days: 0,
        tasksCompletedLast7Days: 4,
        tasksTotalDueLast7Days: 5,
      );
      expect(resTasksOnly.score, 80.0);
      expect(resTasksOnly.grade, 'Steady');
    });

    test('4. calculateProductivityScore assigns correct grades across thresholds', () {
      // < 40 = Starting
      expect(
        InsightsEngine.calculateProductivityScore(
          habitCompletionsLast7Days: 2,
          scheduledHabitOpportunitiesLast7Days: 10,
          tasksCompletedLast7Days: 1,
          tasksTotalDueLast7Days: 10,
        ).grade,
        'Starting',
      );

      // 40-64 = Building
      expect(
        InsightsEngine.calculateProductivityScore(
          habitCompletionsLast7Days: 5,
          scheduledHabitOpportunitiesLast7Days: 10,
          tasksCompletedLast7Days: 5,
          tasksTotalDueLast7Days: 10,
        ).grade,
        'Building',
      );

      // 85+ = Thriving
      expect(
        InsightsEngine.calculateProductivityScore(
          habitCompletionsLast7Days: 9,
          scheduledHabitOpportunitiesLast7Days: 10,
          tasksCompletedLast7Days: 9,
          tasksTotalDueLast7Days: 10,
        ).grade,
        'Thriving',
      );
    });

    test('5. calculateBestTiming returns graceful fallback when no completion timestamps exist', () {
      final res = InsightsEngine.calculateBestTiming(completionTimestamps: []);

      expect(res.bestWeekday, isNull);
      expect(res.bestWeekdayName, 'No data yet');
      expect(res.peakCompletionsCount, 0);
    });

    test('6. calculateBestTiming calculates peak weekday and time of day window accurately', () {
      // Monday is weekday 1. Put 3 timestamps on Monday morning (8 AM, 9 AM, 10 AM)
      final mondayMorning1 = DateTime(2026, 11, 23, 8, 30); // 2026-11-23 is Monday
      final mondayMorning2 = DateTime(2026, 11, 23, 9, 15);
      final mondayMorning3 = DateTime(2026, 11, 23, 10, 00);
      final tuesdayAfternoon = DateTime(2026, 11, 24, 14, 00);

      final res = InsightsEngine.calculateBestTiming(
        completionTimestamps: [mondayMorning1, mondayMorning2, mondayMorning3, tuesdayAfternoon],
      );

      expect(res.bestWeekday, 1);
      expect(res.bestWeekdayName, 'Monday');
      expect(res.bestTimeOfDayRange, 'Morning (6 AM - 12 PM)');
      expect(res.peakCompletionsCount, 3);
    });

    test('7. calculateHabitTaskCorrelation requires at least 14 days of data to prevent false claims', () {
      final habit = _createHabit(
        id: 'h1',
        name: 'Morning Meditation',
      );

      final res = InsightsEngine.calculateHabitTaskCorrelation(
        habits: [habit],
        entries: [],
        tasks: [],
        distinctActiveDays: 10, // < 14
      );

      expect(res.hasEnoughData, isFalse);
      expect(res.insightText, contains('14 days'));
    });

    test('8. calculateHabitTaskCorrelation observes boost on days habit is completed', () {
      final habit = _createHabit(
        id: 'h1',
        name: 'Deep Work',
      );

      final entries = <HabitEntry>[];
      final tasks = <Task>[];

      // Simulate 14 days (Nov 1 to Nov 14)
      for (int i = 1; i <= 14; i++) {
        final dStr = '2026-11-${i.toString().padLeft(2, '0')}';
        final isHabitDone = i % 2 == 1; // 7 done days, 7 non-done days

        if (isHabitDone) {
          entries.add(
            HabitEntry(
              id: 'e$i',
              habitId: 'h1',
              entryDate: dStr,
              status: HabitEntryStatus.done,
              value: 1.0,
              createdAt: DateTime(2026, 11, i, 9),
              updatedAt: DateTime(2026, 11, i, 9),
            ),
          );
          // 4 tasks completed on habit done days
          for (int t = 0; t < 4; t++) {
            tasks.add(
              Task(
                id: 't_${i}_$t',
                title: 'Task $t on day $i',
                isCompleted: true,
                completedAt: DateTime(2026, 11, i, 11),
                createdAt: DateTime(2026, 11, i, 8),
                updatedAt: DateTime(2026, 11, i, 11),
              ),
            );
          }
        } else {
          // 1 task completed on non-habit days
          tasks.add(
            Task(
              id: 't_${i}_0',
              title: 'Task 0 on day $i',
              isCompleted: true,
              completedAt: DateTime(2026, 11, i, 11),
              createdAt: DateTime(2026, 11, i, 8),
              updatedAt: DateTime(2026, 11, i, 11),
            ),
          );
        }
      }

      final res = InsightsEngine.calculateHabitTaskCorrelation(
        habits: [habit],
        entries: entries,
        tasks: tasks,
        distinctActiveDays: 14,
      );

      expect(res.hasEnoughData, isTrue);
      expect(res.habitName, 'Deep Work');
      expect(res.taskBoostPercentage, isNotNull);
      expect(res.insightText, contains('On days you complete "Deep Work"'));
      expect(res.insightText, contains('more tasks'));
    });

    test('9. generateWeeklyReview provides calm, non-guilt encouragement', () {
      // 0 actions -> clean slate
      final review0 = InsightsEngine.generateWeeklyReview(
        habitsCompleted: 0,
        tasksCompleted: 0,
        bestStreak: 0,
      );
      expect(review0.encouragingMessage, contains('clean slate'));

      // High streak -> rhythm
      final reviewStreak = InsightsEngine.generateWeeklyReview(
        habitsCompleted: 7,
        tasksCompleted: 3,
        bestStreak: 14,
      );
      expect(reviewStreak.encouragingMessage, contains('rhythm'));

      // Task focus
      final reviewTasks = InsightsEngine.generateWeeklyReview(
        habitsCompleted: 2,
        tasksCompleted: 8,
        bestStreak: 2,
      );
      expect(reviewTasks.encouragingMessage, contains('task focus'));
    });
  });
}
