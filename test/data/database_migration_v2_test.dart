import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';

void main() {
  group('Database Schema v2 & Migration Tests', () {
    test('Fresh Schema v2 database creates all tables and indexes', () async {
      final db = AppDatabase(NativeDatabase.memory());

      // Insert a project, a tag, and a task with new Schema v2 fields
      final now = DateTime.now();

      await db.into(db.projectsTable).insert(
        ProjectsTableCompanion.insert(
          id: 'proj-1',
          name: 'Personal Orbit',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.into(db.tagsTable).insert(
        TagsTableCompanion.insert(
          id: 'tag-1',
          name: 'family',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.into(db.tasksTable).insert(
        TasksTableCompanion.insert(
          id: 'task-1',
          title: 'Call mom',
          hasTime: const Value(true),
          dueAt: Value(now),
          priority: const Value(1),
          projectId: const Value('proj-1'),
          repeatRule: const Value('{"type":"weekly","interval":1}'),
          sortOrder: const Value(0),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.into(db.taskTagsTable).insert(
        TaskTagsTableCompanion.insert(
          taskId: 'task-1',
          tagId: 'tag-1',
        ),
      );

      // Verify records
      final tasks = await db.select(db.tasksTable).get();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Call mom');
      expect(tasks.first.priority, 1);
      expect(tasks.first.hasTime, isTrue);

      final projects = await db.select(db.projectsTable).get();
      expect(projects.length, 1);
      expect(projects.first.name, 'Personal Orbit');

      // Verify all Schema v2 indexes exist in sqlite_master
      final indices = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index';",
      ).get();

      final indexNames = indices.map((row) => row.read<String>('name')).toSet();
      expect(indexNames.contains('idx_tasks_due_at'), isTrue);
      expect(indexNames.contains('idx_tasks_project_id'), isTrue);
      expect(indexNames.contains('idx_tasks_parent_id'), isTrue);
      expect(indexNames.contains('idx_tasks_completed'), isTrue);

      await db.close();
    });

    test('Migration from v1 to v2 upgrades tasks table and preserves existing data', () async {
      // 1. Create a raw SQLite in-memory database with v1 schema and sample data
      final executor = NativeDatabase.memory(
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE habits (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT,
              icon_name TEXT NOT NULL DEFAULT 'target',
              color_value INTEGER NOT NULL,
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
            CREATE TABLE habit_entries (
              id TEXT NOT NULL PRIMARY KEY,
              habit_id TEXT NOT NULL,
              entry_date TEXT NOT NULL,
              status TEXT NOT NULL DEFAULT 'missed',
              value REAL NOT NULL DEFAULT 1.0,
              note TEXT,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER
            );
            CREATE TABLE reminders (
              id TEXT NOT NULL PRIMARY KEY,
              parent_id TEXT NOT NULL,
              parent_type TEXT NOT NULL DEFAULT 'habit',
              time_string TEXT NOT NULL,
              days_of_week TEXT NOT NULL DEFAULT '',
              is_enabled INTEGER NOT NULL DEFAULT 1,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER
            );
            CREATE TABLE app_settings (
              key TEXT NOT NULL PRIMARY KEY,
              value TEXT NOT NULL,
              updated_at INTEGER NOT NULL
            );
            CREATE TABLE tasks (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL,
              notes TEXT,
              parent_id TEXT,
              due_at INTEGER,
              priority INTEGER NOT NULL DEFAULT 0,
              project_id TEXT,
              is_completed INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER
            );
            CREATE TABLE notes (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL,
              content TEXT NOT NULL DEFAULT '',
              is_pinned INTEGER NOT NULL DEFAULT 0,
              color_value INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER
            );
            -- Insert sample v1 data
            INSERT INTO tasks (id, title, priority, is_completed, created_at, updated_at)
            VALUES ('v1-task-1', 'Legacy Task from v1', 2, 0, 1700000000, 1700000000);
            
            PRAGMA user_version = 1;
          ''');
        },
      );

      // 2. Open with AppDatabase (which is schemaVersion = 2, triggers onUpgrade automatically)
      final upgradedDb = AppDatabase(executor);

      // 3. Verify legacy v1 task is still intact
      final tasks = await upgradedDb.select(upgradedDb.tasksTable).get();
      expect(tasks.length, 1);
      expect(tasks.first.id, 'v1-task-1');
      expect(tasks.first.title, 'Legacy Task from v1');
      // Verify new v2 columns have defaults on the migrated row
      expect(tasks.first.hasTime, isFalse);
      expect(tasks.first.repeatRule, isNull);
      expect(tasks.first.sortOrder, 0);

      // 4. Verify new v2 tables can be used
      final projects = await upgradedDb.select(upgradedDb.projectsTable).get();
      expect(projects, isEmpty);

      // 5. Verify new v2 indexes exist
      final indices = await upgradedDb.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index';",
      ).get();
      final indexNames = indices.map((row) => row.read<String>('name')).toSet();
      expect(indexNames.contains('idx_tasks_due_at'), isTrue);
      expect(indexNames.contains('idx_tasks_project_id'), isTrue);

      await upgradedDb.close();
    });
  });
}
