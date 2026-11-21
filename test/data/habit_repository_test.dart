import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/repositories/habit_repository.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';

void main() {
  late AppDatabase db;
  late HabitRepository repo;

  Habit createTestHabit({
    required String id,
    required String name,
    String iconName = 'sparkle',
    int colorValue = 0xFF14B8A6,
    HabitType habitType = HabitType.yesNo,
    double targetValue = 1.0,
    String unit = '',
    TimeOfDayGroup timeOfDay = TimeOfDayGroup.morning,
    ScheduleType scheduleType = ScheduleType.daily,
    List<int> scheduleDays = const [],
    required DateTime startDate,
    int sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = createdAt ?? DateTime.now();
    return Habit(
      id: id,
      name: name,
      iconName: iconName,
      colorValue: colorValue,
      habitType: habitType,
      targetValue: targetValue,
      unit: unit,
      timeOfDay: timeOfDay,
      scheduleType: scheduleType,
      scheduleDays: scheduleDays,
      startDate: startDate,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: updatedAt ?? now,
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HabitRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('HabitRepository Phase 1.5 Features & Logic Tests', () {
    test('reorderHabits updates sortOrder transactionally and retrieves in new order', () async {
      final now = DateTime.now();

      final h1 = createTestHabit(
        id: 'h-1',
        name: 'Habit 1',
        iconName: 'sparkle',
        colorValue: 0xFF14B8A6,
        startDate: now,
        sortOrder: 0,
      );
      final h2 = createTestHabit(
        id: 'h-2',
        name: 'Habit 2',
        iconName: 'drop',
        colorValue: 0xFF8B7CFF,
        startDate: now,
        sortOrder: 1,
      );
      final h3 = createTestHabit(
        id: 'h-3',
        name: 'Habit 3',
        iconName: 'book',
        colorValue: 0xFFFF7A59,
        startDate: now,
        sortOrder: 2,
      );

      await repo.createHabit(h1);
      await repo.createHabit(h2);
      await repo.createHabit(h3);

      var active = await repo.getActiveHabits();
      expect(active.map((h) => h.id).toList(), ['h-1', 'h-2', 'h-3']);

      // Reorder to [h-3, h-1, h-2]
      await repo.reorderHabits(['h-3', 'h-1', 'h-2']);

      active = await repo.getActiveHabits();
      expect(active.map((h) => h.id).toList(), ['h-3', 'h-1', 'h-2']);
      expect(active[0].sortOrder, 0);
      expect(active[1].sortOrder, 1);
      expect(active[2].sortOrder, 2);
    });

    test('setEntryStatus saves and updates status, numeric value, and journaling note', () async {
      final now = DateTime.now();
      const habitId = 'h-water';

      final habit = createTestHabit(
        id: habitId,
        name: 'Drink Water',
        iconName: 'drop',
        colorValue: 0xFF0284C7,
        habitType: HabitType.numeric,
        targetValue: 8.0,
        unit: 'glasses',
        startDate: now,
      );
      await repo.createHabit(habit);

      // 1. Initial partial check-in with note
      await repo.setEntryStatus(
        habitId: habitId,
        dateStr: '2026-11-21',
        status: HabitEntryStatus.done,
        value: 5.0,
        note: 'Felt well hydrated before afternoon gym session',
      );

      var entry = await repo.getEntryForHabitAndDate(habitId, '2026-11-21');
      expect(entry, isNotNull);
      expect(entry!.status, HabitEntryStatus.done);
      expect(entry.value, 5.0);
      expect(entry.note, 'Felt well hydrated before afternoon gym session');

      // 2. Update entry with skip status and new note
      await repo.setEntryStatus(
        habitId: habitId,
        dateStr: '2026-11-21',
        status: HabitEntryStatus.skipped,
        value: 0.0,
        note: 'Fasting day, water tracking paused',
      );

      entry = await repo.getEntryForHabitAndDate(habitId, '2026-11-21');
      expect(entry, isNotNull);
      expect(entry!.status, HabitEntryStatus.skipped);
      expect(entry.value, 0.0);
      expect(entry.note, 'Fasting day, water tracking paused');
    });

    test('archiveHabit toggles active and archived state correctly', () async {
      final now = DateTime.now();
      final habit = createTestHabit(
        id: 'h-archive-test',
        name: 'Old Habit',
        iconName: 'archive',
        colorValue: 0xFF14B8A6,
        startDate: now,
      );
      await repo.createHabit(habit);

      // Verify active
      var active = await repo.getActiveHabits();
      expect(active.any((h) => h.id == 'h-archive-test'), isTrue);

      // Archive habit
      await repo.archiveHabit('h-archive-test', true);

      active = await repo.getActiveHabits();
      expect(active.any((h) => h.id == 'h-archive-test'), isFalse);

      final archivedList = await repo.watchArchivedHabits().first;
      expect(archivedList.any((h) => h.id == 'h-archive-test'), isTrue);

      // Restore habit
      await repo.archiveHabit('h-archive-test', false);

      active = await repo.getActiveHabits();
      expect(active.any((h) => h.id == 'h-archive-test'), isTrue);
    });

    test('getDetailedStats aggregates heatmap entries, weekday completions and score', () async {
      final now = DateTime(2026, 11, 21); // Saturday
      const habitId = 'h-detailed-stats';

      final habit = createTestHabit(
        id: habitId,
        name: 'Daily Meditation',
        iconName: 'sparkle',
        colorValue: 0xFF14B8A6,
        scheduleType: ScheduleType.daily,
        startDate: now.subtract(const Duration(days: 6)), // 7 days total
      );
      await repo.createHabit(habit);

      // Insert entries for the 7 days: 5 done, 1 skip, 1 missed
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final dateStr = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

        HabitEntryStatus status = HabitEntryStatus.done;
        String? note;
        if (i == 3) {
          status = HabitEntryStatus.skipped;
          note = 'Travel day';
        } else if (i == 5) {
          status = HabitEntryStatus.missed;
        } else {
          note = 'Morning session $i';
        }

        await repo.setEntryStatus(
          habitId: habitId,
          dateStr: dateStr,
          status: status,
          note: note,
        );
      }

      final stats = await repo.getDetailedStats(
        habit: habit,
        referenceDate: now,
        availableFreezes: 1,
      );

      expect(stats.totalScheduled, 7);
      expect(stats.totalCompleted, 5);
      expect(stats.totalSkipped, 1);
      expect(stats.entries.length, 7);
      expect(stats.habitScore, greaterThan(0.0));
      expect(stats.completionRate, closeTo(5 / 7, 0.01));

      // Weekday completions must have entries
      final totalWeekdayHits = stats.weekdayCompletions.values.fold(0, (a, b) => a + b);
      expect(totalWeekdayHits, 5);
    });
  });
}
