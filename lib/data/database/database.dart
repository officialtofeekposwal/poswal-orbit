import 'dart:io';

import 'package:drift/drift.dart';

part 'database.g.dart';

@DataClassName('HabitRow')
class HabitsTable extends Table {
  @override
  String get tableName => 'habits';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get iconName => text().withDefault(const Constant('target'))();
  IntColumn get colorValue => integer()();
  TextColumn get habitType => text().withDefault(const Constant('yesNo'))();
  RealColumn get targetValue => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().withDefault(const Constant('times'))();
  TextColumn get timeOfDay => text().withDefault(const Constant('anytime'))();
  TextColumn get scheduleType => text().withDefault(const Constant('daily'))();
  TextColumn get scheduleDays => text().withDefault(const Constant(''))();
  IntColumn get targetDaysPerPeriod => integer().withDefault(const Constant(1))();
  IntColumn get everyNDaysInterval => integer().withDefault(const Constant(1))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('HabitEntryRow')
class HabitEntriesTable extends Table {
  @override
  String get tableName => 'habit_entries';

  TextColumn get id => text()();
  TextColumn get habitId => text()();
  TextColumn get entryDate => text()(); // YYYY-MM-DD
  TextColumn get status => text().withDefault(const Constant('missed'))();
  RealColumn get value => real().withDefault(const Constant(1.0))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, entryDate},
  ];
}

@DataClassName('ReminderRow')
class RemindersTable extends Table {
  @override
  String get tableName => 'reminders';

  TextColumn get id => text()();
  TextColumn get parentId => text()();
  TextColumn get parentType => text().withDefault(const Constant('habit'))();
  TextColumn get timeString => text()(); // HH:mm
  TextColumn get daysOfWeek => text().withDefault(const Constant(''))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSettingRow')
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

// Phase 2: Tasks, Projects & Tags Tables
@DataClassName('TaskRow')
class TasksTable extends Table {
  @override
  String get tableName => 'tasks';

  TextColumn get id => text()();
  TextColumn get parentId => text().nullable()(); // Subtasks support
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  BoolColumn get hasTime => boolean().withDefault(const Constant(false))();
  IntColumn get priority => integer().withDefault(const Constant(4))(); // 1: Urgent/High, 2: Medium, 3: Low, 4: None
  TextColumn get projectId => text().nullable()();
  TextColumn get repeatRule => text().nullable()(); // Serialized repeat rule
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get linkedHabitId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProjectRow')
class ProjectsTable extends Table {
  @override
  String get tableName => 'projects';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconName => text().withDefault(const Constant('folder'))();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF14B8A6))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagRow')
class TagsTable extends Table {
  @override
  String get tableName => 'tags';

  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF8B7CFF))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TaskTagRow')
class TaskTagsTable extends Table {
  @override
  String get tableName => 'task_tags';

  TextColumn get taskId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

// Phase 3: Notes & NoteTags Tables
@DataClassName('NoteRow')
class NotesTable extends Table {
  @override
  String get tableName => 'notes';

  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  IntColumn get colorLabel => integer().withDefault(const Constant(0))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isJournal => boolean().withDefault(const Constant(false))();
  TextColumn get journalDate => text().nullable()(); // YYYY-MM-DD
  TextColumn get linkedTaskId => text().nullable()();
  TextColumn get linkedHabitId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NoteTagRow')
class NoteTagsTable extends Table {
  @override
  String get tableName => 'note_tags';

  TextColumn get noteId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

@DriftDatabase(tables: [
  HabitsTable,
  HabitEntriesTable,
  RemindersTable,
  AppSettingsTable,
  TasksTable,
  ProjectsTable,
  TagsTable,
  TaskTagsTable,
  NotesTable,
  NoteTagsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  Future<void> _backupDatabaseFileBeforeMigration(int fromVersion) async {
    try {
      final dbList = await customSelect('PRAGMA database_list;').get();
      final mainDb = dbList.firstWhere(
        (r) => r.read<String>('name') == 'main',
        orElse: () => dbList.first,
      );
      final filePath = mainDb.read<String?>('file');
      if (filePath != null && filePath.isNotEmpty && filePath != '""') {
        final dbFile = File(filePath);
        if (await dbFile.exists()) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final backupPath = '$filePath.pre_migration_v${fromVersion}_$timestamp.bak';
          await dbFile.copy(backupPath);
        }
      }
    } catch (_) {
      // In test or in-memory environments, proceed safely
    }
  }

  Future<Set<String>> _getTableColumns(String tableName) async {
    final rows = await customSelect("PRAGMA table_info('$tableName');").get();
    return rows.map((r) => r.read<String>('name').toLowerCase()).toSet();
  }

  Future<Set<String>> _getTables() async {
    final rows = await customSelect("SELECT name FROM sqlite_master WHERE type = 'table';").get();
    return rows.map((r) => r.read<String>('name').toLowerCase()).toSet();
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Habit indexes
      await customStatement('CREATE INDEX IF NOT EXISTS idx_habit_entries_date ON habit_entries (entry_date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_habit_entries_habit ON habit_entries (habit_id);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_habits_archived ON habits (is_archived);');
      // Task indexes
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_due_at ON tasks (due_at);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks (project_id);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_parent_id ON tasks (parent_id);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks (is_completed);');
      // Note indexes
      await customStatement('CREATE INDEX IF NOT EXISTS idx_notes_pinned ON notes (is_pinned);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_notes_journal_date ON notes (journal_date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_notes_deleted_at ON notes (deleted_at);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_note_tags_tag_id ON note_tags (tag_id);');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      await _backupDatabaseFileBeforeMigration(from);

      if (from < 2) {
        await customStatement('SAVEPOINT migration_v2;');
        try {
          final taskCols = await _getTableColumns('tasks');
          if (!taskCols.contains('parent_id')) {
            await m.addColumn(tasksTable, tasksTable.parentId);
          }
          if (!taskCols.contains('has_time')) {
            await m.addColumn(tasksTable, tasksTable.hasTime);
          }
          if (!taskCols.contains('priority')) {
            await m.addColumn(tasksTable, tasksTable.priority);
          }
          if (!taskCols.contains('project_id')) {
            await m.addColumn(tasksTable, tasksTable.projectId);
          }
          if (!taskCols.contains('repeat_rule')) {
            await m.addColumn(tasksTable, tasksTable.repeatRule);
          }
          if (!taskCols.contains('completed_at')) {
            await m.addColumn(tasksTable, tasksTable.completedAt);
          }
          if (!taskCols.contains('linked_habit_id')) {
            await m.addColumn(tasksTable, tasksTable.linkedHabitId);
          }
          if (!taskCols.contains('sort_order')) {
            await m.addColumn(tasksTable, tasksTable.sortOrder);
          }

          final tables = await _getTables();
          if (!tables.contains('projects')) {
            await m.createTable(projectsTable);
          }
          if (!tables.contains('tags')) {
            await m.createTable(tagsTable);
          }
          if (!tables.contains('task_tags')) {
            await m.createTable(taskTagsTable);
          }

          // Create task indexes
          await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_due_at ON tasks (due_at);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks (project_id);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_parent_id ON tasks (parent_id);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks (is_completed);');

          await customStatement('RELEASE SAVEPOINT migration_v2;');
        } catch (e) {
          await customStatement('ROLLBACK TO SAVEPOINT migration_v2;');
          await customStatement('RELEASE SAVEPOINT migration_v2;');
          rethrow;
        }
      }

      if (from < 3) {
        await customStatement('SAVEPOINT migration_v3;');
        try {
          final notesCols = await _getTableColumns('notes');
          if (!notesCols.contains('is_pinned')) {
            await customStatement('ALTER TABLE notes ADD COLUMN is_pinned INTEGER NOT NULL DEFAULT 0;');
          }
          if (!notesCols.contains('body')) {
            await customStatement("ALTER TABLE notes ADD COLUMN body TEXT NOT NULL DEFAULT '';");
          }
          if (!notesCols.contains('color_label')) {
            await customStatement('ALTER TABLE notes ADD COLUMN color_label INTEGER NOT NULL DEFAULT 0;');
          }
          if (!notesCols.contains('is_journal')) {
            await customStatement('ALTER TABLE notes ADD COLUMN is_journal INTEGER NOT NULL DEFAULT 0;');
          }
          if (!notesCols.contains('journal_date')) {
            await customStatement('ALTER TABLE notes ADD COLUMN journal_date TEXT;');
          }
          if (!notesCols.contains('linked_task_id')) {
            await customStatement('ALTER TABLE notes ADD COLUMN linked_task_id TEXT;');
          }
          if (!notesCols.contains('linked_habit_id')) {
            await customStatement('ALTER TABLE notes ADD COLUMN linked_habit_id TEXT;');
          }

          // Copy legacy content and color data if present in earlier v1/v2 schema
          if (notesCols.contains('content')) {
            await customStatement("UPDATE notes SET body = content WHERE (body IS NULL OR body = '') AND content IS NOT NULL;");
          }
          if (notesCols.contains('color_value') || notesCols.contains('color')) {
            final col = notesCols.contains('color_value') ? 'color_value' : 'color';
            await customStatement('UPDATE notes SET color_label = $col WHERE color_label = 0 AND $col IS NOT NULL;');
          }

          final tables = await _getTables();
          if (!tables.contains('note_tags')) {
            await m.createTable(noteTagsTable);
          }

          // Create note indexes
          await customStatement('CREATE INDEX IF NOT EXISTS idx_notes_pinned ON notes (is_pinned);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_notes_journal_date ON notes (journal_date);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_notes_deleted_at ON notes (deleted_at);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_note_tags_tag_id ON note_tags (tag_id);');

          await customStatement('RELEASE SAVEPOINT migration_v3;');
        } catch (e) {
          await customStatement('ROLLBACK TO SAVEPOINT migration_v3;');
          await customStatement('RELEASE SAVEPOINT migration_v3;');
          rethrow;
        }
      }
    },
  );
}
