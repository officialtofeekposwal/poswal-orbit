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

// Stubs for future phases (Phase 2 & 3)
@DataClassName('TaskRow')
class TasksTable extends Table {
  @override
  String get tableName => 'tasks';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get parentId => text().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get projectId => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NoteRow')
class NotesTable extends Table {
  @override
  String get tableName => 'notes';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get colorValue => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  HabitsTable,
  HabitEntriesTable,
  RemindersTable,
  AppSettingsTable,
  TasksTable,
  NotesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Add indexes for date and habit queries
      await customStatement('CREATE INDEX IF NOT EXISTS idx_habit_entries_date ON habit_entries (entry_date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_habit_entries_habit ON habit_entries (habit_id);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_habits_archived ON habits (is_archived);');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Schema v1 is initial version
    },
  );
}
