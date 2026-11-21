import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/data/repositories/global_search_repository.dart';
import 'package:poswal_orbit/domain/models/search_models.dart';
import 'package:poswal_orbit/features/notes/application/note_providers.dart';
import 'package:poswal_orbit/features/tasks/application/task_providers.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

final globalSearchRepositoryProvider = Provider<GlobalSearchRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final habitRepo = ref.watch(habitRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  final noteRepo = ref.watch(noteRepositoryProvider);

  return GlobalSearchRepository(
    db: db,
    habitRepo: habitRepo,
    taskRepo: taskRepo,
    noteRepo: noteRepo,
  );
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final globalSearchResultsProvider = FutureProvider<GroupedSearchResults>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) {
    return const GroupedSearchResults();
  }
  final repo = ref.watch(globalSearchRepositoryProvider);
  return repo.search(query);
});

