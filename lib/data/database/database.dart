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
      if (from < 2) {
        // Upgrade tasks table from v1 to v2 schema
        await m.addColumn(tasksTable, tasksTable.hasTime);
        await m.addColumn(tasksTable, tasksTable.repeatRule);
        await m.addColumn(tasksTable, tasksTable.completedAt);
        await m.addColumn(tasksTable, tasksTable.linkedHabitId);
        await m.addColumn(tasksTable, tasksTable.sortOrder);

        // Create new projects, tags, task_tags tables
        await m.createTable(projectsTable);
        await m.createTable(tagsTable);
        await m.createTable(taskTagsTable);

        // Create task indexes
        await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_due_at ON tasks (due_at);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks (project_id);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_parent_id ON tasks (parent_id);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks (is_completed);');
      }

      if (from < 3) {
        // Upgrade notes table from v1/v2 stub to full v3 schema
        await customStatement(r"ALTER TABLE notes ADD COLUMN body TEXT NOT NULL DEFAULT '';");
        await customStatement(r'ALTER TABLE notes ADD COLUMN color_label INTEGER NOT NULL DEFAULT 0;');
        await customStatement(r'ALTER TABLE notes ADD COLUMN is_journal INTEGER NOT NULL DEFAULT 0;');
        await customStatement(r'ALTER TABLE notes ADD COLUMN journal_date TEXT;');
        await customStatement(r'ALTER TABLE notes ADD COLUMN linked_task_id TEXT;');
        await customStatement(r'ALTER TABLE notes ADD COLUMN linked_habit_id TEXT;');

        // Copy legacy content and color_value data if present in v1/v2 rows
        try {
          await customStatement(r"UPDATE notes SET body = content WHERE content IS NOT NULL AND body = '';");
        } catch (_) {}
        try {
          await customStatement(r'UPDATE notes SET color_label = color_value WHERE color_value IS NOT NULL AND color_label = 0;');
        } catch (_) {}

        // Create note_tags table
        await m.createTable(noteTagsTable);

        // Create note indexes
        await customStatement('CREATE INDEX IF NOT EXISTS idx_notes_pinned ON notes (is_pinned);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_notes_journal_date ON notes (journal_date);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_notes_deleted_at ON notes (deleted_at);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_note_tags_tag_id ON note_tags (tag_id);');
      }
    },
  );
}
