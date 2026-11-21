import 'package:drift/drift.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/task_repeat_engine.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  TaskRepository(this._db);

  // Mappers
  Task _mapTask(TaskRow row) {
    return Task(
      id: row.id,
      parentId: row.parentId,
      title: row.title,
      notes: row.notes,
      dueAt: row.dueAt,
      hasTime: row.hasTime,
      priority: TaskPriority.fromValue(row.priority),
      projectId: row.projectId,
      repeatRule: TaskRepeatRule.fromJson(row.repeatRule),
      isCompleted: row.isCompleted,
      completedAt: row.completedAt,
      linkedHabitId: row.linkedHabitId,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  Project _mapProject(ProjectRow row) {
    return Project(
      id: row.id,
      name: row.name,
      iconName: row.iconName,
      colorValue: row.colorValue,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  Tag _mapTag(TagRow row) {
    return Tag(
      id: row.id,
      name: row.name,
      colorValue: row.colorValue,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  // --- Task Queries ---

  Future<Task?> getTaskById(String id) async {
    final query = _db.select(_db.tasksTable)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    final row = await query.getSingleOrNull();
    return row != null ? _mapTask(row) : null;
  }

  Stream<Task?> watchTaskById(String id) {
    final query = _db.select(_db.tasksTable)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    return query.watchSingleOrNull().map((r) => r != null ? _mapTask(r) : null);
  }

  Stream<List<Task>> watchSubtasks(String parentId) {
    final query = _db.select(_db.tasksTable)
      ..where((tbl) => tbl.parentId.equals(parentId) & tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.sortOrder)]);
    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  Future<List<Task>> getSubtasks(String parentId) async {
    final query = _db.select(_db.tasksTable)
      ..where((tbl) => tbl.parentId.equals(parentId) & tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.sortOrder)]);
    final rows = await query.get();
    return rows.map(_mapTask).toList();
  }

  DateTime _getEffectiveRefDate(DateTime ref, int dayStartHour) {
    if (ref.hour == 0 && ref.minute == 0 && ref.second == 0 && ref.millisecond == 0) {
      return ref;
    }
    return DateBoundary.getEffectiveDate(ref, dayStartHour: dayStartHour);
  }

  // Smart Lists
  Stream<List<Task>> watchTodayTasks({DateTime? referenceDate, int dayStartHour = 4}) {
    final ref = referenceDate ?? DateTime.now();
    final effective = _getEffectiveRefDate(ref, dayStartHour);
    final startOfToday = DateTime(effective.year, effective.month, effective.day);
    final endOfToday = DateTime(effective.year, effective.month, effective.day, 23, 59, 59, 999);

    final query = _db.select(_db.tasksTable)
      ..where((tbl) =>
          tbl.deletedAt.isNull() &
          tbl.parentId.isNull() &
          (
            // Due today or earlier (and not done), OR completed today
            (tbl.isCompleted.equals(false) & tbl.dueAt.isSmallerOrEqualValue(endOfToday)) |
            (tbl.isCompleted.equals(true) & tbl.completedAt.isBiggerOrEqualValue(startOfToday) & tbl.completedAt.isSmallerOrEqualValue(endOfToday))
          ))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.isCompleted),
        (tbl) => OrderingTerm(expression: tbl.priority),
        (tbl) => OrderingTerm(expression: tbl.dueAt),
        (tbl) => OrderingTerm(expression: tbl.sortOrder),
      ]);

    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  Stream<List<Task>> watchUpcomingTasks({DateTime? referenceDate, int dayStartHour = 4}) {
    final ref = referenceDate ?? DateTime.now();
    final effective = _getEffectiveRefDate(ref, dayStartHour);
    final endOfToday = DateTime(effective.year, effective.month, effective.day, 23, 59, 59, 999);

    final query = _db.select(_db.tasksTable)
      ..where((tbl) =>
          tbl.deletedAt.isNull() &
          tbl.parentId.isNull() &
          tbl.isCompleted.equals(false) &
          tbl.dueAt.isBiggerThanValue(endOfToday))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.dueAt),
        (tbl) => OrderingTerm(expression: tbl.priority),
      ]);

    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  Stream<List<Task>> watchOverdueTasks({DateTime? referenceDate, int dayStartHour = 4}) {
    final ref = referenceDate ?? DateTime.now();
    final effective = _getEffectiveRefDate(ref, dayStartHour);
    final startOfToday = DateTime(effective.year, effective.month, effective.day);

    final query = _db.select(_db.tasksTable)
      ..where((tbl) =>
          tbl.deletedAt.isNull() &
          tbl.parentId.isNull() &
          tbl.isCompleted.equals(false) &
          tbl.dueAt.isSmallerThanValue(startOfToday))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.dueAt),
        (tbl) => OrderingTerm(expression: tbl.priority),
      ]);

    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  Stream<List<Task>> watchFlaggedTasks() {
    final query = _db.select(_db.tasksTable)
      ..where((tbl) =>
          tbl.deletedAt.isNull() &
          tbl.parentId.isNull() &
          tbl.isCompleted.equals(false) &
          (tbl.priority.equals(TaskPriority.urgent.value) | tbl.priority.equals(TaskPriority.high.value)))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.dueAt),
        (tbl) => OrderingTerm(expression: tbl.sortOrder),
      ]);

    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  Stream<List<Task>> watchCompletedTasks() {
    final query = _db.select(_db.tasksTable)
      ..where((tbl) =>
          tbl.deletedAt.isNull() &
          tbl.parentId.isNull() &
          tbl.isCompleted.equals(true))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.completedAt, mode: OrderingMode.desc),
      ]);

    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  Stream<List<Task>> watchAllTasks() {
    final query = _db.select(_db.tasksTable)
      ..where((tbl) => tbl.deletedAt.isNull() & tbl.parentId.isNull())
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.isCompleted),
        (tbl) => OrderingTerm(expression: tbl.priority),
        (tbl) => OrderingTerm(expression: tbl.dueAt),
        (tbl) => OrderingTerm(expression: tbl.sortOrder),
      ]);

    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  Stream<List<Task>> searchTasks(String queryText) {
    final trimmed = queryText.trim().toLowerCase();
    if (trimmed.isEmpty) return watchAllTasks();

    final query = _db.select(_db.tasksTable)
      ..where((tbl) =>
          tbl.deletedAt.isNull() &
          (tbl.title.lower().contains(trimmed) |
           tbl.notes.lower().contains(trimmed)))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.dueAt)]);

    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  // --- Task Mutations ---

  Future<void> createTask(Task task, {List<String>? tagIds}) async {
    final now = DateTime.now();
    final taskId = task.id.isEmpty ? _uuid.v4() : task.id;

    await _db.transaction(() async {
      await _db.into(_db.tasksTable).insert(
        TasksTableCompanion.insert(
          id: taskId,
          parentId: Value(task.parentId),
          title: task.title,
          notes: Value(task.notes),
          dueAt: Value(task.dueAt),
          hasTime: Value(task.hasTime),
          priority: Value(task.priority.value),
          projectId: Value(task.projectId),
          repeatRule: Value(task.repeatRule?.toJson()),
          isCompleted: Value(task.isCompleted),
          completedAt: Value(task.completedAt),
          linkedHabitId: Value(task.linkedHabitId),
          sortOrder: Value(task.sortOrder),
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (tagIds != null && tagIds.isNotEmpty) {
        for (final tagId in tagIds) {
          await _db.into(_db.taskTagsTable).insert(
            TaskTagsTableCompanion.insert(taskId: taskId, tagId: tagId),
          );
        }
      }
    });
  }

  Future<void> updateTask(Task task, {List<String>? tagIds}) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.tasksTable)..where((tbl) => tbl.id.equals(task.id))).write(
        TasksTableCompanion(
          parentId: Value(task.parentId),
          title: Value(task.title),
          notes: Value(task.notes),
          dueAt: Value(task.dueAt),
          hasTime: Value(task.hasTime),
          priority: Value(task.priority.value),
          projectId: Value(task.projectId),
          repeatRule: Value(task.repeatRule?.toJson()),
          isCompleted: Value(task.isCompleted),
          completedAt: Value(task.completedAt),
          linkedHabitId: Value(task.linkedHabitId),
          sortOrder: Value(task.sortOrder),
          updatedAt: Value(now),
        ),
      );

      if (tagIds != null) {
        await (_db.delete(_db.taskTagsTable)..where((tbl) => tbl.taskId.equals(task.id))).go();
        for (final tagId in tagIds) {
          await _db.into(_db.taskTagsTable).insert(
            TaskTagsTableCompanion.insert(taskId: task.id, tagId: tagId),
          );
        }
      }
    });
  }

  Future<void> toggleTaskComplete(String taskId, {bool? completed}) async {
    final now = DateTime.now();
    final task = await getTaskById(taskId);
    if (task == null) return;

    final willBeCompleted = completed ?? !task.isCompleted;

    await _db.transaction(() async {
      await (_db.update(_db.tasksTable)..where((tbl) => tbl.id.equals(taskId))).write(
        TasksTableCompanion(
          isCompleted: Value(willBeCompleted),
          completedAt: Value(willBeCompleted ? now : null),
          updatedAt: Value(now),
        ),
      );

      // Handle recurrence when completing
      if (willBeCompleted && task.repeatRule != null && task.dueAt != null) {
        final nextDue = TaskRepeatEngine.calculateNextDueDate(
          rule: task.repeatRule!,
          currentDue: task.dueAt!,
          completionDate: now,
        );

        if (nextDue != null) {
          // Create next recurring instance
          await _db.into(_db.tasksTable).insert(
            TasksTableCompanion.insert(
              id: _uuid.v4(),
              parentId: Value(task.parentId),
              title: task.title,
              notes: Value(task.notes),
              dueAt: Value(nextDue),
              hasTime: Value(task.hasTime),
              priority: Value(task.priority.value),
              projectId: Value(task.projectId),
              repeatRule: Value(task.repeatRule?.toJson()),
              isCompleted: const Value(false),
              completedAt: const Value(null),
              linkedHabitId: Value(task.linkedHabitId),
              sortOrder: Value(task.sortOrder),
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }
    });
  }

  Future<void> deleteTask(String taskId, {bool soft = true}) async {
    final now = DateTime.now();
    if (soft) {
      await (_db.update(_db.tasksTable)..where((tbl) => tbl.id.equals(taskId))).write(
        TasksTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      // Soft delete subtasks too
      await (_db.update(_db.tasksTable)..where((tbl) => tbl.parentId.equals(taskId))).write(
        TasksTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    } else {
      await (_db.delete(_db.taskTagsTable)..where((tbl) => tbl.taskId.equals(taskId))).go();
      await (_db.delete(_db.tasksTable)..where((tbl) => tbl.parentId.equals(taskId))).go();
      await (_db.delete(_db.tasksTable)..where((tbl) => tbl.id.equals(taskId))).go();
    }
  }

  Future<void> restoreTask(String taskId) async {
    final now = DateTime.now();
    await (_db.update(_db.tasksTable)..where((tbl) => tbl.id.equals(taskId))).write(
      TasksTableCompanion(deletedAt: const Value(null), updatedAt: Value(now)),
    );
    await (_db.update(_db.tasksTable)..where((tbl) => tbl.parentId.equals(taskId))).write(
      TasksTableCompanion(deletedAt: const Value(null), updatedAt: Value(now)),
    );
  }

  Future<void> reorderTasks(List<String> taskIds) async {
    await _db.batch((batch) {
      for (int i = 0; i < taskIds.length; i++) {
        batch.update(
          _db.tasksTable,
          TasksTableCompanion(
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now()),
          ),
          where: (tbl) => tbl.id.equals(taskIds[i]),
        );
      }
    });
  }

  // --- Projects & Tags ---

  Stream<List<Project>> watchProjects() {
    final query = _db.select(_db.projectsTable)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.sortOrder)]);
    return query.watch().map((rows) => rows.map(_mapProject).toList());
  }

  Future<void> createProject(Project project) async {
    final now = DateTime.now();
    await _db.into(_db.projectsTable).insert(
      ProjectsTableCompanion.insert(
        id: project.id.isEmpty ? _uuid.v4() : project.id,
        name: project.name,
        iconName: Value(project.iconName),
        colorValue: Value(project.colorValue),
        sortOrder: Value(project.sortOrder),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Stream<List<Tag>> watchTags() {
    final query = _db.select(_db.tagsTable)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)]);
    return query.watch().map((rows) => rows.map(_mapTag).toList());
  }

  Future<void> createTag(Tag tag) async {
    final now = DateTime.now();
    await _db.into(_db.tagsTable).insert(
      TagsTableCompanion.insert(
        id: tag.id.isEmpty ? _uuid.v4() : tag.id,
        name: tag.name,
        colorValue: Value(tag.colorValue),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<List<Tag>> getTagsForTask(String taskId) async {
    final query = _db.select(_db.taskTagsTable).join([
      innerJoin(_db.tagsTable, _db.tagsTable.id.equalsExp(_db.taskTagsTable.tagId)),
    ])..where(_db.taskTagsTable.taskId.equals(taskId) & _db.tagsTable.deletedAt.isNull());

    final rows = await query.get();
    return rows.map((r) => _mapTag(r.readTable(_db.tagsTable))).toList();
  }
}
