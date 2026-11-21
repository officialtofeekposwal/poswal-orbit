import 'package:drift/drift.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/repositories/habit_repository.dart';
import 'package:poswal_orbit/data/repositories/note_repository.dart';
import 'package:poswal_orbit/data/repositories/task_repository.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/domain/models/search_models.dart';

class GlobalSearchRepository {
  final AppDatabase db;
  final HabitRepository habitRepo;
  final TaskRepository taskRepo;
  final NoteRepository noteRepo;

  GlobalSearchRepository({
    required this.db,
    required this.habitRepo,
    required this.taskRepo,
    required this.noteRepo,
  });

  /// Performs a unified global search across active habits, non-deleted tasks, and non-deleted notes.
  /// Results are scored with title matches prioritized over body and tag matches.
  Future<GroupedSearchResults> search(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      return const GroupedSearchResults();
    }

    final habitResults = await _searchHabits(clean);
    final taskResults = await _searchTasks(clean);
    final noteResults = await _searchNotes(clean);

    return GroupedSearchResults(
      habits: habitResults,
      tasks: taskResults,
      notes: noteResults,
    );
  }

  int _calculateScore({
    required String query,
    required String title,
    String? body,
    List<String> tags = const [],
    DateTime? updatedAt,
  }) {
    final titleLower = title.toLowerCase();
    final bodyLower = body?.toLowerCase() ?? '';
    int score = 0;

    // Title matches
    if (titleLower == query) {
      score += 100; // Exact title match
    } else if (titleLower.startsWith(query)) {
      score += 80; // Prefix match
    } else if (titleLower.contains(query)) {
      score += 50; // Partial title match
    }

    // Tag matches
    for (final tag in tags) {
      final tagLower = tag.toLowerCase().replaceAll('#', '');
      if (tagLower == query.replaceAll('#', '')) {
        score += 40;
      } else if (tagLower.contains(query.replaceAll('#', ''))) {
        score += 30;
      }
    }

    // Body / Description matches
    if (bodyLower.contains(query)) {
      score += 20;
    }

    // Recency boost (within last 7 days)
    if (updatedAt != null) {
      final daysAgo = DateTime.now().difference(updatedAt).inDays;
      if (daysAgo < 7) {
        score += 5;
      }
    }

    return score;
  }

  Future<List<SearchResultItem>> _searchHabits(String query) async {
    final habits = await habitRepo.watchActiveHabits().first;
    final results = <SearchResultItem>[];

    for (final habit in habits) {
      final nameLower = habit.name.toLowerCase();
      final descLower = habit.description?.toLowerCase() ?? '';

      if (nameLower.contains(query) || descLower.contains(query)) {
        final score = _calculateScore(
          query: query,
          title: habit.name,
          body: habit.description,
          updatedAt: habit.updatedAt,
        );

        results.add(SearchResultItem(
          id: habit.id,
          type: SearchResultType.habit,
          title: habit.name,
          snippet: habit.description ?? '${habit.scheduleType.name} habit',
          colorValue: habit.colorValue,
          iconName: habit.iconName,
          score: score,
          updatedAt: habit.updatedAt,
          habit: habit,
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  Future<List<SearchResultItem>> _searchTasks(String query) async {
    final tasks = await taskRepo.searchTasks(query).first;
    final results = <SearchResultItem>[];

    for (final task in tasks) {
      if (task.isDeleted) continue; // Exclude soft deleted

      final tags = await taskRepo.getTagsForTask(task.id);
      final score = _calculateScore(
        query: query,
        title: task.title,
        body: task.notes,
        tags: tags.map((t) => t.name).toList(),
        updatedAt: task.updatedAt,
      );

      results.add(SearchResultItem(
        id: task.id,
        type: SearchResultType.task,
        title: task.title,
        snippet: task.notes?.isNotEmpty == true
            ? task.notes!
            : (task.dueAt != null ? 'Due: ${task.dueAt!.toLocal()}' : 'To-do item'),
        colorValue: task.priority.colorValue,
        iconName: 'check-square',
        tags: tags.map((t) => t.name).toList(),
        score: score,
        updatedAt: task.updatedAt,
        task: task,
      ));
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  Future<List<SearchResultItem>> _searchNotes(String query) async {
    // Query SQLite notes where deleted_at IS NULL
    final pattern = '%$query%';
    final notesQuery = db.select(db.notesTable)
      ..where((tbl) =>
          tbl.deletedAt.isNull() &
          (tbl.title.like(pattern) | tbl.body.like(pattern)));

    final rows = await notesQuery.get();
    final results = <SearchResultItem>[];

    for (final row in rows) {
      final tags = await noteRepo.getNoteTags(row.id);
      final score = _calculateScore(
        query: query,
        title: row.title.isNotEmpty ? row.title : 'Untitled Note',
        body: row.body,
        tags: tags,
        updatedAt: row.updatedAt,
      );

      final snippet = row.body.trim().isNotEmpty
          ? (row.body.length > 80 ? '${row.body.substring(0, 80)}...' : row.body)
          : (row.isJournal ? 'Daily Journal' : 'Blank note');

      results.add(SearchResultItem(
        id: row.id,
        type: SearchResultType.note,
        title: row.title.isNotEmpty ? row.title : 'Untitled Note',
        snippet: snippet,
        colorValue: NoteColorLabel.toColorValue(row.colorLabel),
        iconName: row.isJournal ? 'book-open' : 'note',
        tags: tags,
        score: score,
        updatedAt: row.updatedAt,
        note: Note(
          id: row.id,
          title: row.title,
          body: row.body,
          colorLabel: row.colorLabel,
          isPinned: row.isPinned,
          isJournal: row.isJournal,
          journalDate: row.journalDate,
          linkedTaskId: row.linkedTaskId,
          linkedHabitId: row.linkedHabitId,
          tags: tags,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deletedAt: row.deletedAt,
        ),
      ));
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

