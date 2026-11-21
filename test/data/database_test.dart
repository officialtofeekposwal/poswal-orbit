import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase Schema v1 & Operations', () {
    test('Can insert and retrieve a habit with default values', () async {
      final now = DateTime.now();
      final habit = HabitsTableCompanion.insert(
        id: 'habit-uuid-1',
        name: 'Morning Hydration',
        colorValue: 0xFF14B8A6,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await db.into(db.habitsTable).insert(habit);

      final allHabits = await db.select(db.habitsTable).get();
      expect(allHabits.length, 1);
      expect(allHabits.first.id, 'habit-uuid-1');
      expect(allHabits.first.name, 'Morning Hydration');
      expect(allHabits.first.habitType, 'yesNo');
      expect(allHabits.first.isArchived, isFalse);
    });

    test('Can insert and upsert habit entries for a specific date', () async {
      final now = DateTime.now();

      // Initial entry: missed
      await db.into(db.habitEntriesTable).insert(
        HabitEntriesTableCompanion.insert(
          id: 'entry-uuid-1',
          habitId: 'habit-uuid-1',
          entryDate: '2026-11-21',
          status: const Value('missed'),
          value: const Value(0.0),
          createdAt: now,
          updatedAt: now,
        ),
      );

      var entries = await db.select(db.habitEntriesTable).get();
      expect(entries.first.status, 'missed');

      // Update to completed
      await (db.update(db.habitEntriesTable)..where((tbl) => tbl.id.equals('entry-uuid-1'))).write(
        HabitEntriesTableCompanion(
          status: const Value('done'),
          value: const Value(1.0),
          updatedAt: Value(DateTime.now()),
        ),
      );

      entries = await db.select(db.habitEntriesTable).get();
      expect(entries.first.status, 'done');
      expect(entries.first.value, 1.0);
    });

    test('Indexes are created on habit_entries table', () async {
      final indices = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index';",
      ).get();

      final indexNames = indices.map((row) => row.read<String>('name')).toList();
      expect(indexNames.contains('idx_habit_entries_date'), isTrue);
      expect(indexNames.contains('idx_habit_entries_habit'), isTrue);
      expect(indexNames.contains('idx_habits_archived'), isTrue);
    });
  });
}
