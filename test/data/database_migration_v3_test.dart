import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Database Schema v3 & Migration Tests', () {
    test('Fresh Schema v3 database creates notes, note_tags tables and indexes', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.now();

      // Insert tag
      await db.into(db.tagsTable).insert(
        TagsTableCompanion.insert(
          id: 'tag-1',
          name: 'ideas',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Insert Note with Schema v3 fields
      await db.into(db.notesTable).insert(
        NotesTableCompanion.insert(
          id: 'note-1',
          title: const Value('Project Roadmap'),
          body: const Value('# Goals\n- [ ] Release Orbit'),
          colorLabel: const Value(1),
          isPinned: const Value(true),
          isJournal: const Value(false),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Insert NoteTag
      await db.into(db.noteTagsTable).insert(
        NoteTagsTableCompanion.insert(
          noteId: 'note-1',
          tagId: 'tag-1',
        ),
      );

      // Verify Note retrieval
      final notes = await db.select(db.notesTable).get();
      expect(notes.length, 1);
      expect(notes.first.title, 'Project Roadmap');
      expect(notes.first.body, '# Goals\n- [ ] Release Orbit');
      expect(notes.first.isPinned, isTrue);
      expect(notes.first.colorLabel, 1);

      // Verify Schema v3 indexes in sqlite_master
      final indices = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index';",
      ).get();

      final indexNames = indices.map((row) => row.read<String>('name')).toSet();
      expect(indexNames.contains('idx_notes_pinned'), isTrue);
      expect(indexNames.contains('idx_notes_journal_date'), isTrue);
      expect(indexNames.contains('idx_notes_deleted_at'), isTrue);
      expect(indexNames.contains('idx_note_tags_tag_id'), isTrue);

      await db.close();
    });

    test('Migration from v2 to v3 upgrades notes table and preserves legacy content', () async {
      // 1. Create a raw SQLite in-memory database with v2 schema
      final executor = NativeDatabase.memory(
        setup: (rawDb) {
          // Minimal v2 tables
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
              parent_id TEXT,
              title TEXT NOT NULL,
              notes TEXT,
              due_at INTEGER,
              has_time INTEGER NOT NULL DEFAULT 0,
              priority INTEGER NOT NULL DEFAULT 4,
              project_id TEXT,
              repeat_rule TEXT,
              is_completed INTEGER NOT NULL DEFAULT 0,
              completed_at INTEGER,
              linked_habit_id TEXT,
              sort_order INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER
            );
          ''');

          rawDb.execute('''
            CREATE TABLE projects (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              icon_name TEXT NOT NULL DEFAULT 'folder',
              color_value INTEGER NOT NULL DEFAULT 1358038,
              sort_order INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER
            );
          ''');

          rawDb.execute('''
            CREATE TABLE tags (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              color_value INTEGER NOT NULL DEFAULT 9141503,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              deleted_at INTEGER
            );
          ''');

          rawDb.execute('''
            CREATE TABLE task_tags (
              task_id TEXT NOT NULL,
              tag_id TEXT NOT NULL,
              PRIMARY KEY (task_id, tag_id)
            );
          ''');

          // Legacy v2 notes table with 'content' and 'color_value'
          rawDb.execute('''
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
          ''');

          // Seed sample note in v2 schema
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          rawDb.execute('''
            INSERT INTO notes (id, title, content, is_pinned, color_value, created_at, updated_at)
            VALUES ('v2-note-1', 'Legacy Note', 'Legacy markdown content', 1, 2, $nowMs, $nowMs);
          ''');

          // Set user_version = 2
          rawDb.execute('PRAGMA user_version = 2;');
        },
      );

      // 2. Open via Drift AppDatabase (triggers onUpgrade from 2 to 3)
      final migratedDb = AppDatabase(executor);

      final notes = await migratedDb.select(migratedDb.notesTable).get();
      expect(notes.length, 1);
      final note = notes.first;
      expect(note.id, 'v2-note-1');
      expect(note.title, 'Legacy Note');
      // Body should have received legacy content
      expect(note.body, 'Legacy markdown content');
      expect(note.isPinned, isTrue);
      expect(note.colorLabel, 2);

      // Verify note_tags table was created by migration
      final tables = await migratedDb.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table';",
      ).get();
      final tableNames = tables.map((r) => r.read<String>('name')).toSet();
      expect(tableNames.contains('note_tags'), isTrue);

      await migratedDb.close();
    });
  });
}
