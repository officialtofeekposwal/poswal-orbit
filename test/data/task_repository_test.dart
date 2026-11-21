import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/repositories/task_repository.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TaskRepository Smart Lists, Operations & Recurrence Tests', () {
    final now = DateTime(2026, 11, 21, 14, 0); // Saturday

    test('Create, retrieve and update task with tags and project', () async {
      await repo.createProject(
        Project(
          id: 'proj-work',
          name: 'Work Sprint',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await repo.createTag(
        Tag(
          id: 'tag-urgent',
          name: 'urgent',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final task = Task(
        id: 't-1',
        title: 'Review pull request',
        notes: 'Check Impeller shader performance',
        dueAt: now,
        hasTime: true,
        priority: TaskPriority.urgent,
        projectId: 'proj-work',
        createdAt: now,
        updatedAt: now,
      );

      await repo.createTask(task, tagIds: ['tag-urgent']);

      final fetched = await repo.getTaskById('t-1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Review pull request');
      expect(fetched.priority, TaskPriority.urgent);
      expect(fetched.hasTime, isTrue);

      final tags = await repo.getTagsForTask('t-1');
      expect(tags.length, 1);
      expect(tags.first.name, 'urgent');
    });

    test('Smart lists: Today, Upcoming, and Overdue categorize tasks correctly', () async {
      final todayDue = now;
      final upcomingDue = now.add(const Duration(days: 3));
      final overdueDue = now.subtract(const Duration(days: 2));

      await repo.createTask(Task(
        id: 'task-today',
        title: 'Due today task',
        dueAt: todayDue,
        createdAt: now,
        updatedAt: now,
      ));

      await repo.createTask(Task(
        id: 'task-upcoming',
        title: 'Future task',
        dueAt: upcomingDue,
        createdAt: now,
        updatedAt: now,
      ));

      await repo.createTask(Task(
        id: 'task-overdue',
        title: 'Past due task',
        dueAt: overdueDue,
        createdAt: now,
        updatedAt: now,
      ));

      // 1. Today list: must contain today due AND overdue
      final todayList = await repo.watchTodayTasks(referenceDate: now).first;
      final todayIds = todayList.map((t) => t.id).toSet();
      expect(todayIds.contains('task-today'), isTrue);
      expect(todayIds.contains('task-overdue'), isTrue);
      expect(todayIds.contains('task-upcoming'), isFalse);

      // 2. Upcoming list: contains only future tasks
      final upcomingList = await repo.watchUpcomingTasks(referenceDate: now).first;
      expect(upcomingList.map((t) => t.id).toList(), ['task-upcoming']);

      // 3. Overdue list: contains only past due uncompleted tasks
      final overdueList = await repo.watchOverdueTasks(referenceDate: now).first;
      expect(overdueList.map((t) => t.id).toList(), ['task-overdue']);
    });

    test('Toggling complete on recurring task automatically generates next instance', () async {
      final task = Task(
        id: 'task-recur',
        title: 'Daily workout',
        dueAt: now,
        hasTime: true,
        priority: TaskPriority.medium,
        repeatRule: const TaskRepeatRule(type: TaskRepeatType.daily, interval: 1),
        createdAt: now,
        updatedAt: now,
      );

      await repo.createTask(task);

      // Complete the recurring task
      await repo.toggleTaskComplete('task-recur');

      // 1. Original task must be marked completed
      final original = await repo.getTaskById('task-recur');
      expect(original!.isCompleted, isTrue);
      expect(original.completedAt, isNotNull);

      // 2. A new uncompleted instance must be spawned with due date = tomorrow
      final all = await repo.watchAllTasks().first;
      final active = all.where((t) => !t.isCompleted).toList();
      expect(active.length, 1);
      expect(active.first.title, 'Daily workout');
      expect(active.first.dueAt, now.add(const Duration(days: 1)));
    });

    test('Subtasks query retrieves child tasks in sort order', () async {
      await repo.createTask(Task(
        id: 'parent-1',
        title: 'Plan vacation',
        createdAt: now,
        updatedAt: now,
      ));

      await repo.createTask(Task(
        id: 'sub-1',
        parentId: 'parent-1',
        title: 'Book flights',
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ));

      await repo.createTask(Task(
        id: 'sub-2',
        parentId: 'parent-1',
        title: 'Reserve hotel',
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ));

      final subtasks = await repo.watchSubtasks('parent-1').first;
      expect(subtasks.length, 2);
      expect(subtasks[0].title, 'Book flights');
      expect(subtasks[1].title, 'Reserve hotel');
    });

    test('searchTasks finds tasks by partial match in title or notes', () async {
      await repo.createTask(Task(
        id: 't-search-1',
        title: 'Meeting with design team',
        notes: 'Discuss liquid glass refraction',
        createdAt: now,
        updatedAt: now,
      ));

      await repo.createTask(Task(
        id: 't-search-2',
        title: 'Grocery shopping',
        notes: 'Buy apples and oranges',
        createdAt: now,
        updatedAt: now,
      ));

      final byTitle = await repo.searchTasks('design').first;
      expect(byTitle.length, 1);
      expect(byTitle.first.id, 't-search-1');

      final byNote = await repo.searchTasks('refraction').first;
      expect(byNote.length, 1);
      expect(byNote.first.id, 't-search-1');
    });
  });
}
