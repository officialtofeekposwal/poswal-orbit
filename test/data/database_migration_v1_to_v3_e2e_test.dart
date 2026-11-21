import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  group('Database End-to-End Migration Chain Tests (v1 -> v2 -> v3)', () {
    test('Migrates raw Schema v1 database all the way to v3 preserving all data and streaks', () async {
      final rawDb = sqlite.sqlite3.openInMemory();

      // 1. Build raw Schema v1 tables directly in SQLite
      rawDb.execute('''
        CREATE TABLE habits (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          icon_name TEXT NOT NULL DEFAULT 'star',
          color_value INTEGER NOT NULL DEFAULT 4280193446,
          habit_type TEXT NOT NULL DEFAULT 'yesNo',
          target_value REAL NOT NULL DEFAULT 1.0,
          unit TEXT NOT NULL DEFAULT 'times',
          time_of_day TEXT NOT NULL DEFAULT 'anytime',
          schedule_type TEXT NOT NULL DEFAULT 'daily',
          schedule_days TEXT NOT NULL DEFAULT '',
          target_days_per_period INTEGER NOT NULL DEFAULT 1,
          every_n_days_interval INTEGER NOT NULL DEFAULT 1,
          start_date INTEGER NOT NULL,
          end_date INTEGER,
          is_archived INTEGER NOT NULL DEFAULT 0,
          sort_order INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''');

      rawDb.execute('''
        CREATE TABLE habit_entries (
          id TEXT NOT NULL PRIMARY KEY,
          habit_id TEXT NOT NULL,
          entry_date TEXT NOT NULL,
          status TEXT NOT NULL,
          value REAL NOT NULL DEFAULT 1.0,
          notes TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''');

      rawDb.execute('''
        CREATE TABLE reminders (
          id TEXT NOT NULL PRIMARY KEY,
          habit_id TEXT NOT NULL,
          reminder_time TEXT NOT NULL,
          days_of_week TEXT NOT NULL DEFAULT '',
          is_enabled INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');

      rawDb.execute('''
        CREATE TABLE app_settings (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');

      rawDb.execute('''
        CREATE TABLE tasks (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          notes TEXT,
          due_at INTEGER,
          is_completed INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''');

      rawDb.execute('''
        CREATE TABLE notes (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          color INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''');

      // Set user_version to 1
      rawDb.execute('PRAGMA user_version = 1;');

      // 2. Insert realistic historical records in v1
      final nowMs = DateTime(2026, 11, 21, 10, 0).millisecondsSinceEpoch;

      rawDb.execute('''
        INSERT INTO habits (id, name, description, start_date, created_at, updated_at)
        VALUES ('habit-v1', 'Read 20 pages', 'Focus reading', $nowMs, $nowMs, $nowMs);
      ''');

      rawDb.execute('''
        INSERT INTO habit_entries (id, habit_id, entry_date, status, value, created_at, updated_at)
        VALUES ('entry-v1', 'habit-v1', '2026-11-20', 'done', 1.0, $nowMs, $nowMs);
      ''');

      rawDb.execute('''
        INSERT INTO reminders (id, habit_id, reminder_time, created_at, updated_at)
        VALUES ('rem-v1', 'habit-v1', '08:00', $nowMs, $nowMs);
      ''');

      rawDb.execute('''
        INSERT INTO tasks (id, title, notes, due_at, is_completed, created_at, updated_at)
        VALUES ('task-v1', 'Prepare financial tax return', 'Check invoices', $nowMs, 0, $nowMs, $nowMs);
      ''');

      rawDb.execute('''
        INSERT INTO notes (id, title, content, color, created_at, updated_at)
        VALUES ('note-v1', 'Weekly Retrospective', '## Summary\n- [ ] Reflect on habit momentum\n- [x] Clear mailbox', 1, $nowMs, $nowMs);
      ''');

      // 3. Connect Drift AppDatabase - triggers step-by-step migration chain (v1 -> v2 -> v3)
      final db = AppDatabase(NativeDatabase.opened(rawDb));

      // Force migration execution
      final versionResult = await db.customSelect('PRAGMA user_version;').getSingle();
      final currentVersion = versionResult.read<int>('user_version');
      expect(currentVersion, equals(3), reason: 'Database must have successfully migrated to schema v3');

      // 4. Verify Habits and Entries are 100% intact
      final habits = await db.select(db.habitsTable).get();
      expect(habits.length, equals(1));
      expect(habits.first.id, equals('habit-v1'));
      expect(habits.first.name, equals('Read 20 pages'));

      final entries = await db.select(db.habitEntriesTable).get();
      expect(entries.length, equals(1));
      expect(entries.first.id, equals('entry-v1'));
      expect(entries.first.entryDate, equals('2026-11-20'));
      expect(entries.first.status, equals('done'));

      // 5. Verify Tasks table gained v2 fields with safe defaults
      final tasks = await db.select(db.tasksTable).get();
      expect(tasks.length, equals(1));
      expect(tasks.first.id, equals('task-v1'));
      expect(tasks.first.title, equals('Prepare financial tax return'));
      expect(tasks.first.priority, equals(4)); // default low priority
      expect(tasks.first.hasTime, isFalse);

      // 6. Verify Notes table migrated to v3 markdown-lite schema
      final notes = await db.select(db.notesTable).get();
      expect(notes.length, equals(1));
      expect(notes.first.id, equals('note-v1'));
      expect(notes.first.title, equals('Weekly Retrospective'));
      expect(notes.first.body, equals('## Summary\n- [ ] Reflect on habit momentum\n- [x] Clear mailbox'));
      expect(notes.first.colorLabel, isA<int>());
      expect(notes.first.isPinned, isFalse);
      expect(notes.first.isJournal, isFalse);

      // 7. Verify Schema v3 tables accept new records
      final insertTime = DateTime.now();
      await db.into(db.projectsTable).insert(
        ProjectsTableCompanion.insert(
          id: 'proj-e2e',
          name: 'Sprint 2026',
          createdAt: insertTime,
          updatedAt: insertTime,
        ),
      );
      final projects = await db.select(db.projectsTable).get();
      expect(projects.length, equals(1));

      await db.close();
    });
  });
}
