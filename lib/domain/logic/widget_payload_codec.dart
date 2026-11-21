import 'dart:convert';

class WidgetHabitItem {
  final String id;
  final String name;
  final bool isCompleted;

  const WidgetHabitItem({
    required this.id,
    required this.name,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isCompleted': isCompleted,
      };

  factory WidgetHabitItem.fromJson(Map<String, dynamic> json) => WidgetHabitItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class WidgetTaskItem {
  final String id;
  final String title;
  final int priority;

  const WidgetTaskItem({
    required this.id,
    required this.title,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority,
      };

  factory WidgetTaskItem.fromJson(Map<String, dynamic> json) => WidgetTaskItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        priority: json['priority'] as int? ?? 0,
      );
}

class WidgetPayload {
  final int totalHabits;
  final int completedHabits;
  final int progressPercent;
  final List<WidgetHabitItem> habits;
  final List<WidgetTaskItem> tasks;
  final DateTime lastUpdated;

  const WidgetPayload({
    required this.totalHabits,
    required this.completedHabits,
    required this.progressPercent,
    required this.habits,
    required this.tasks,
    required this.lastUpdated,
  });

  Map<String, String> toWidgetData() {
    return {
      'orbit_total_habits': totalHabits.toString(),
      'orbit_completed_habits': completedHabits.toString(),
      'orbit_progress_percent': progressPercent.toString(),
      'orbit_progress_label': '$completedHabits of $totalHabits',
      'orbit_habits_json': jsonEncode(habits.map((h) => h.toJson()).toList()),
      'orbit_tasks_json': jsonEncode(tasks.map((t) => t.toJson()).toList()),
      'orbit_last_updated': lastUpdated.toIso8601String(),
    };
  }

  static WidgetPayload create({
    required int totalHabits,
    required int completedHabits,
    required List<WidgetHabitItem> habits,
    required List<WidgetTaskItem> tasks,
    DateTime? now,
  }) {
    final percent = totalHabits > 0 ? ((completedHabits / totalHabits) * 100).round() : 0;
    return WidgetPayload(
      totalHabits: totalHabits,
      completedHabits: completedHabits,
      progressPercent: percent.clamp(0, 100),
      habits: habits.take(5).toList(),
      tasks: tasks.take(5).toList(),
      lastUpdated: now ?? DateTime.now(),
    );
  }
}
