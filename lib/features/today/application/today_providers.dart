import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/data/database/connection/native.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/repositories/habit_repository.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/habit_score.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/logic/streak_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';

// 1. Database & Repository Providers
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(connectDatabase());
  ref.onDispose(() => db.close());
  return db;
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HabitRepository(db);
});

// 2. Date State Notifier
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    const boundary = DateBoundary(dayStartHour: 4);
    return boundary.getAppDate(DateTime.now());
  }

  void selectDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void selectToday() {
    const boundary = DateBoundary(dayStartHour: 4);
    state = boundary.getAppDate(DateTime.now());
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

// 3. Reactive Streams
final activeHabitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchActiveHabits();
});

final todayEntriesStreamProvider = StreamProvider<List<HabitEntry>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final dateStr = DateBoundary.toDateString(selectedDate);
  return repo.watchEntriesForDate(dateStr);
});

// 4. Combined Model: Today's Scheduled Habits with Live Streaks & Progress
class TodayHabitsData {
  final DateTime date;
  final List<HabitWithEntry> allScheduled;
  final Map<TimeOfDayGroup, List<HabitWithEntry>> grouped;
  final int totalDue;
  final int totalDone;
  final double completionRate;

  const TodayHabitsData({
    required this.date,
    required this.allScheduled,
    required this.grouped,
    required this.totalDue,
    required this.totalDone,
    required this.completionRate,
  });
}

final todayHabitsDataProvider = FutureProvider<TodayHabitsData>((ref) async {
  final repo = ref.watch(habitRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  // Watch streams so data refreshes instantly on any DB change
  final habits = ref.watch(activeHabitsStreamProvider).value ?? await repo.getActiveHabits();
  final entries = ref.watch(todayEntriesStreamProvider).value ?? [];

  final Map<String, HabitEntry> entryMap = {
    for (final e in entries) e.habitId: e,
  };

  final List<HabitWithEntry> scheduled = [];

  for (final habit in habits) {
    if (ScheduleEngine.isScheduledOn(habit, selectedDate)) {
      final entry = entryMap[habit.id];
      final history = await repo.getEntriesForHabit(habit.id);

      final streak = StreakEngine.calculate(
        habit: habit,
        entries: history,
        referenceDate: selectedDate,
      );

      const scoreCalc = HabitScoreCalculator(halfLifeDays: 14);
      final score = scoreCalc.calculate(
        habit: habit,
        entries: history,
        referenceDate: selectedDate,
      );

      scheduled.add(
        HabitWithEntry(
          habit: habit,
          entry: entry,
          currentStreak: streak.currentStreak,
          habitScore: score,
        ),
      );
    }
  }

  // Group by Time of Day
  final Map<TimeOfDayGroup, List<HabitWithEntry>> grouped = {
    TimeOfDayGroup.morning: [],
    TimeOfDayGroup.afternoon: [],
    TimeOfDayGroup.evening: [],
    TimeOfDayGroup.anytime: [],
  };

  int doneCount = 0;
  for (final item in scheduled) {
    grouped[item.habit.timeOfDay]?.add(item);
    if (item.isCompleted) {
      doneCount++;
    }
  }

  final double rate = scheduled.isEmpty ? 0.0 : (doneCount / scheduled.length).clamp(0.0, 1.0);

  return TodayHabitsData(
    date: selectedDate,
    allScheduled: scheduled,
    grouped: grouped,
    totalDue: scheduled.length,
    totalDone: doneCount,
    completionRate: rate,
  );
});

// Phase 1.5 Providers
final archivedHabitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchArchivedHabits();
});

final singleHabitStreamProvider = StreamProvider.family<Habit?, String>((ref, habitId) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchHabitById(habitId);
});

final habitEntriesStreamProvider = StreamProvider.family<List<HabitEntry>, String>((ref, habitId) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchEntriesForHabit(habitId);
});

final habitDetailStatsProvider = FutureProvider.family<HabitDetailedStats?, String>((ref, habitId) async {
  final repo = ref.watch(habitRepositoryProvider);
  final habit = await repo.getHabitById(habitId);
  if (habit == null) return null;

  // Watch entries stream so stats recompute instantly when any check-in changes
  ref.watch(habitEntriesStreamProvider(habitId));

  const boundary = DateBoundary(dayStartHour: 4);
  final today = boundary.getAppDate(DateTime.now());

  return repo.getDetailedStats(
    habit: habit,
    referenceDate: today,
    availableFreezes: 1,
  );
});
