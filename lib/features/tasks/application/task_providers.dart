import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/data/repositories/task_repository.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

enum TaskSmartFilter {
  today('Today'),
  upcoming('Upcoming'),
  all('All'),
  completed('Completed'),
  overdue('Overdue'),
  flagged('Flagged');

  final String label;
  const TaskSmartFilter(this.label);
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TaskRepository(db);
});

// State Notifiers for Riverpod 3 architecture
class TaskFilterNotifier extends Notifier<TaskSmartFilter> {
  @override
  TaskSmartFilter build() => TaskSmartFilter.today;
  void setFilter(TaskSmartFilter filter) => state = filter;
}

final selectedTaskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskSmartFilter>(
  TaskFilterNotifier.new,
);

class SelectedProjectNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

final selectedProjectIdProvider = NotifierProvider<SelectedProjectNotifier, String?>(
  SelectedProjectNotifier.new,
);

class SelectedTagNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

final selectedTagIdProvider = NotifierProvider<SelectedTagNotifier, String?>(
  SelectedTagNotifier.new,
);

class TaskSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String q) => state = q;
}

final taskSearchQueryProvider = NotifierProvider<TaskSearchQueryNotifier, String>(
  TaskSearchQueryNotifier.new,
);

// Smart List Stream Providers
final todayTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return repo.watchTodayTasks(referenceDate: selectedDate);
});

final upcomingTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return repo.watchUpcomingTasks(referenceDate: selectedDate);
});

final overdueTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return repo.watchOverdueTasks(referenceDate: selectedDate);
});

final flaggedTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchFlaggedTasks();
});

final completedTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchCompletedTasks();
});

final allTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAllTasks();
});

final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchProjects();
});

final tagsStreamProvider = StreamProvider<List<Tag>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTags();
});

final taskSubtasksStreamProvider = StreamProvider.family<List<Task>, String>((ref, parentId) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchSubtasks(parentId);
});

final singleTaskStreamProvider = StreamProvider.family<Task?, String>((ref, taskId) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTaskById(taskId);
});
