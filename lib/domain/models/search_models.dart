import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

enum SearchResultType {
  habit,
  task,
  note,
}

class SearchResultItem {
  final String id;
  final SearchResultType type;
  final String title;
  final String snippet;
  final int? colorValue;
  final String? iconName;
  final List<String> tags;
  final int score;
  final DateTime updatedAt;
  final Habit? habit;
  final Task? task;
  final Note? note;

  const SearchResultItem({
    required this.id,
    required this.type,
    required this.title,
    required this.snippet,
    this.colorValue,
    this.iconName,
    this.tags = const [],
    required this.score,
    required this.updatedAt,
    this.habit,
    this.task,
    this.note,
  });

  @override
  String toString() =>
      'SearchResultItem($type, title: "$title", score: $score)';
}

class GroupedSearchResults {
  final List<SearchResultItem> habits;
  final List<SearchResultItem> tasks;
  final List<SearchResultItem> notes;

  const GroupedSearchResults({
    this.habits = const [],
    this.tasks = const [],
    this.notes = const [],
  });

  bool get isEmpty => habits.isEmpty && tasks.isEmpty && notes.isEmpty;
  int get totalCount => habits.length + tasks.length + notes.length;
  List<SearchResultItem> get allResults {
    final list = [...habits, ...tasks, ...notes];
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }
}
