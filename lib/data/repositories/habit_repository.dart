import 'package:drift/drift.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/domain/logic/habit_score.dart';
import 'package:poswal_orbit/domain/logic/streak_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:uuid/uuid.dart';

class HabitRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  HabitRepository(this._db);

  // Mappers
  Habit _mapHabit(HabitRow row) {
    List<int> days = [];
    if (row.scheduleDays.isNotEmpty) {
      days = row.scheduleDays
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();
    }

    return Habit(
      id: row.id,
      name: row.name,
      description: row.description,
      iconName: row.iconName,
      colorValue: row.colorValue,
      habitType: HabitType.fromString(row.habitType),
      targetValue: row.targetValue,
      unit: row.unit,
      timeOfDay: TimeOfDayGroup.fromString(row.timeOfDay),
      scheduleType: ScheduleType.fromString(row.scheduleType),
      scheduleDays: days,
      targetDaysPerPeriod: row.targetDaysPerPeriod,
      everyNDaysInterval: row.everyNDaysInterval,
      startDate: row.startDate,
      endDate: row.endDate,
      isArchived: row.isArchived,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  HabitEntry _mapEntry(HabitEntryRow row) {
    return HabitEntry(
      id: row.id,
      habitId: row.habitId,
      entryDate: row.entryDate,
      status: HabitEntryStatus.fromString(row.status),
      value: row.value,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  // Habits Queries & Mutations
  Stream<List<Habit>> watchActiveHabits() {
    final query = _db.select(_db.habitsTable)
      ..where((tbl) => tbl.deletedAt.isNull() & tbl.isArchived.equals(false))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.sortOrder)]);

    return query.watch().map((rows) => rows.map(_mapHabit).toList());
  }

  Future<List<Habit>> getActiveHabits() async {
    final query = _db.select(_db.habitsTable)
      ..where((tbl) => tbl.deletedAt.isNull() & tbl.isArchived.equals(false))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.sortOrder)]);

    final rows = await query.get();
    return rows.map(_mapHabit).toList();
  }

  Future<Habit?> getHabitById(String id) async {
    final query = _db.select(_db.habitsTable)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    final row = await query.getSingleOrNull();
    return row != null ? _mapHabit(row) : null;
  }

  Future<void> createHabit(Habit habit) async {
    final now = DateTime.now();
    final companion = HabitsTableCompanion.insert(
      id: habit.id.isEmpty ? _uuid.v4() : habit.id,
      name: habit.name,
      description: Value(habit.description),
      iconName: Value(habit.iconName),
      colorValue: habit.colorValue,
      habitType: Value(habit.habitType.name),
      targetValue: Value(habit.targetValue),
      unit: Value(habit.unit),
      timeOfDay: Value(habit.timeOfDay.name),
      scheduleType: Value(habit.scheduleType.name),
      scheduleDays: Value(habit.scheduleDays.join(',')),
      targetDaysPerPeriod: Value(habit.targetDaysPerPeriod),
      everyNDaysInterval: Value(habit.everyNDaysInterval),
      startDate: habit.startDate,
      endDate: Value(habit.endDate),
      isArchived: Value(habit.isArchived),
      sortOrder: Value(habit.sortOrder),
      createdAt: now,
      updatedAt: now,
    );

    await _db.into(_db.habitsTable).insert(companion);
  }

  Future<void> updateHabit(Habit habit) async {
    final now = DateTime.now();
    await (_db.update(_db.habitsTable)..where((tbl) => tbl.id.equals(habit.id))).write(
      HabitsTableCompanion(
        name: Value(habit.name),
        description: Value(habit.description),
        iconName: Value(habit.iconName),
        colorValue: Value(habit.colorValue),
        habitType: Value(habit.habitType.name),
        targetValue: Value(habit.targetValue),
        unit: Value(habit.unit),
        timeOfDay: Value(habit.timeOfDay.name),
        scheduleType: Value(habit.scheduleType.name),
        scheduleDays: Value(habit.scheduleDays.join(',')),
        targetDaysPerPeriod: Value(habit.targetDaysPerPeriod),
        everyNDaysInterval: Value(habit.everyNDaysInterval),
        startDate: Value(habit.startDate),
        endDate: Value(habit.endDate),
        isArchived: Value(habit.isArchived),
        sortOrder: Value(habit.sortOrder),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> archiveHabit(String id, bool archive) async {
    final now = DateTime.now();
    await (_db.update(_db.habitsTable)..where((tbl) => tbl.id.equals(id))).write(
      HabitsTableCompanion(
        isArchived: Value(archive),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteHabit(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.habitsTable)..where((tbl) => tbl.id.equals(id))).write(
      HabitsTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  // Entries Queries & Mutations
  Stream<List<HabitEntry>> watchEntriesForDate(String dateStr) {
    final query = _db.select(_db.habitEntriesTable)
      ..where((tbl) => tbl.entryDate.equals(dateStr) & tbl.deletedAt.isNull());
    return query.watch().map((rows) => rows.map(_mapEntry).toList());
  }

  Future<List<HabitEntry>> getEntriesForHabit(String habitId) async {
    final query = _db.select(_db.habitEntriesTable)
      ..where((tbl) => tbl.habitId.equals(habitId) & tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.entryDate)]);
    final rows = await query.get();
    return rows.map(_mapEntry).toList();
  }

  Future<HabitEntry?> getEntryForHabitAndDate(String habitId, String dateStr) async {
    final query = _db.select(_db.habitEntriesTable)
      ..where((tbl) => tbl.habitId.equals(habitId) & tbl.entryDate.equals(dateStr) & tbl.deletedAt.isNull());
    final row = await query.getSingleOrNull();
    return row != null ? _mapEntry(row) : null;
  }

  Future<void> setEntryStatus({
    required String habitId,
    required String dateStr,
    required HabitEntryStatus status,
    double? value,
    String? note,
  }) async {
    final now = DateTime.now();
    final existing = await getEntryForHabitAndDate(habitId, dateStr);

    if (existing == null) {
      await _db.into(_db.habitEntriesTable).insert(
        HabitEntriesTableCompanion.insert(
          id: _uuid.v4(),
          habitId: habitId,
          entryDate: dateStr,
          status: Value(status.name),
          value: Value(value ?? (status == HabitEntryStatus.done ? 1.0 : 0.0)),
          note: Value(note),
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      await (_db.update(_db.habitEntriesTable)..where((tbl) => tbl.id.equals(existing.id))).write(
        HabitEntriesTableCompanion(
          status: Value(status.name),
          value: Value(value ?? existing.value),
          note: Value(note ?? existing.note),
          updatedAt: Value(now),
        ),
      );
    }
  }

  // Aggregate Habit with Live Stats (Streak & Score)
  Future<HabitWithEntry> getHabitWithEntry({
    required Habit habit,
    required String dateStr,
    required DateTime referenceDate,
  }) async {
    final entries = await getEntriesForHabit(habit.id);
    final entry = entries.where((e) => e.entryDate == dateStr).firstOrNull;

    final streak = StreakEngine.calculate(
      habit: habit,
      entries: entries,
      referenceDate: referenceDate,
    );

    const scoreCalc = HabitScoreCalculator(halfLifeDays: 14);
    final score = scoreCalc.calculate(
      habit: habit,
      entries: entries,
      referenceDate: referenceDate,
    );

    return HabitWithEntry(
      habit: habit,
      entry: entry,
      currentStreak: streak.currentStreak,
      habitScore: score,
    );
  }
}
