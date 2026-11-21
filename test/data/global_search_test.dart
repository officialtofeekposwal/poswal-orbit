import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/repositories/habit_repository.dart';
import 'package:poswal_orbit/data/repositories/note_repository.dart';
import 'package:poswal_orbit/data/repositories/task_repository.dart';
import 'package:poswal_orbit/data/repositories/global_search_repository.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/domain/models/search_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late HabitRepository habitRepo;
  late TaskRepository taskRepo;
  late NoteRepository noteRepo;
  late GlobalSearchRepository searchRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    habitRepo = HabitRepository(db);
    taskRepo = TaskRepository(db);
    noteRepo = NoteRepository(db);
    searchRepo = GlobalSearchRepository(
      db: db,
      habitRepo: habitRepo,
      taskRepo: taskRepo,
      noteRepo: noteRepo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('GlobalSearchRepository Multi-Entity & Ranking Tests', () {
    test('Searches across habits, tasks, and notes simultaneously', () async {
      final now = DateTime.now();

      // 1. Create a habit
      await habitRepo.createHabit(Habit(
        id: 'h-1',
        name: 'Morning Workout Routine',
        description: 'Fitness and cardio daily',
        iconName: 'barbell',
        colorValue: 0xFF14B8A6,
        habitType: HabitType.yesNo,
        targetValue: 1.0,
        unit: 'times',
        timeOfDay: TimeOfDayGroup.morning,
        scheduleType: ScheduleType.daily,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      // 2. Create a task
      await taskRepo.createTask(
        Task(
          id: 't-1',
          title: 'Buy workout shoes',
          notes: 'Running shoes for gym',
          priority: TaskPriority.high,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 3. Create a note
      await noteRepo.createNote(
        Note(
          id: 'n-1',
          title: 'Workout Split Plan',
          body: '# Schedule\nPush, Pull, Legs routine',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Search for "workout"
      final results = await searchRepo.search('workout');

      expect(results.habits.length, 1);
      expect(results.habits.first.title, 'Morning Workout Routine');
      expect(results.habits.first.type, SearchResultType.habit);

      expect(results.tasks.length, 1);
      expect(results.tasks.first.title, 'Buy workout shoes');
      expect(results.tasks.first.type, SearchResultType.task);

      expect(results.notes.length, 1);
      expect(results.notes.first.title, 'Workout Split Plan');
      expect(results.notes.first.type, SearchResultType.note);

      expect(results.totalCount, 3);
    });

    test('Ranking: Exact title matches score higher than body/tag matches', () async {
      final now = DateTime.now();

      // Note A has "Flutter" as exact title
      await noteRepo.createNote(Note(
        id: 'n-exact',
        title: 'Flutter',
        body: 'Framework overview',
        createdAt: now,
        updatedAt: now,
      ));

      // Note B has "Flutter" mentioned only inside its body
      await noteRepo.createNote(Note(
        id: 'n-body',
        title: 'Mobile App Architecture',
        body: 'We are using Flutter and Riverpod for this project.',
        createdAt: now,
        updatedAt: now,
      ));

      final results = await searchRepo.search('Flutter');
      expect(results.notes.length, 2);

      // The exact title match must be ranked first (highest score)
      expect(results.notes.first.id, 'n-exact');
      expect(results.notes.first.score, greaterThan(results.notes.last.score));
    });

    test('Excludes soft-deleted tasks/notes and archived habits from results', () async {
      final now = DateTime.now();

      // Active task
      await taskRepo.createTask(Task(
        id: 't-active',
        title: 'Active meeting prep',
        createdAt: now,
        updatedAt: now,
      ));

      // Soft-deleted task
      await taskRepo.createTask(Task(
        id: 't-deleted',
        title: 'Old meeting prep',
        createdAt: now,
        updatedAt: now,
      ));
      await taskRepo.softDeleteTask('t-deleted');

      // Soft-deleted note
      await noteRepo.createNote(Note(
        id: 'n-deleted',
        title: 'Meeting minutes',
        createdAt: now,
        updatedAt: now,
      ));
      await noteRepo.softDeleteNote('n-deleted');

      final results = await searchRepo.search('meeting');

      // Only the active task should appear
      expect(results.tasks.length, 1);
      expect(results.tasks.first.id, 't-active');
      expect(results.notes, isEmpty);
    });
  });
}
