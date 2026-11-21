import 'dart:convert';

enum TaskPriority {
  urgent(1, 'Urgent', 0xFFFF5252),  // Red
  high(2, 'High', 0xFFFF7A59),      // Coral
  medium(3, 'Medium', 0xFFFFC857),  // Gold
  low(4, 'Low', 0xFF0284C7),        // Sky
  none(0, 'None', 0xFF94A3B8);      // Muted slate

  final int value;
  final String label;
  final int colorValue;

  const TaskPriority(this.value, this.label, this.colorValue);

  static TaskPriority fromValue(int val) {
    return TaskPriority.values.firstWhere(
      (p) => p.value == val,
      orElse: () => TaskPriority.none,
    );
  }

  static TaskPriority fromString(String str) {
    final lower = str.toLowerCase().trim();
    if (lower == 'urgent' || lower == '1') return TaskPriority.urgent;
    if (lower == 'high' || lower == '2') return TaskPriority.high;
    if (lower == 'med' || lower == 'medium' || lower == '3') return TaskPriority.medium;
    if (lower == 'low' || lower == '4') return TaskPriority.low;
    return TaskPriority.none;
  }
}

enum TaskRepeatType {
  daily,
  weekdays,
  weekly,
  monthly,
  custom,
  afterCompletion;

  static TaskRepeatType fromString(String val) {
    return TaskRepeatType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => TaskRepeatType.daily,
    );
  }
}

class TaskRepeatRule {
  final TaskRepeatType type;
  final int interval; // every N days / weeks / months
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday for custom
  final int afterDays; // for afterCompletion

  const TaskRepeatRule({
    required this.type,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.afterDays = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'afterDays': afterDays,
    };
  }

  String toJson() => jsonEncode(toMap());

  static TaskRepeatRule? fromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return TaskRepeatRule(
        type: TaskRepeatType.fromString(map['type'] as String? ?? 'daily'),
        interval: map['interval'] as int? ?? 1,
        daysOfWeek: (map['daysOfWeek'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
        afterDays: map['afterDays'] as int? ?? 1,
      );
    } catch (_) {
      return null;
    }
  }
}

class Task {
  final String id;
  final String? parentId; // null = top-level, non-null = subtask
  final String title;
  final String? notes;
  final DateTime? dueAt;
  final bool hasTime;
  final TaskPriority priority;
  final String? projectId;
  final TaskRepeatRule? repeatRule;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? linkedHabitId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Task({
    required this.id,
    this.parentId,
    required this.title,
    this.notes,
    this.dueAt,
    this.hasTime = false,
    this.priority = TaskPriority.none,
    this.projectId,
    this.repeatRule,
    this.isCompleted = false,
    this.completedAt,
    this.linkedHabitId,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isSubtask => parentId != null && parentId!.isNotEmpty;
  bool get isDeleted => deletedAt != null;

  Task copyWith({
    String? id,
    String? parentId,
    String? title,
    String? notes,
    DateTime? dueAt,
    bool? hasTime,
    TaskPriority? priority,
    String? projectId,
    TaskRepeatRule? repeatRule,
    bool? isCompleted,
    DateTime? completedAt,
    String? linkedHabitId,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Task(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueAt: dueAt ?? this.dueAt,
      hasTime: hasTime ?? this.hasTime,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      repeatRule: repeatRule ?? this.repeatRule,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      linkedHabitId: linkedHabitId ?? this.linkedHabitId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class Project {
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Project({
    required this.id,
    required this.name,
    this.iconName = 'folder',
    this.colorValue = 0xFF14B8A6,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

class Tag {
  final String id;
  final String name;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Tag({
    required this.id,
    required this.name,
    this.colorValue = 0xFF8B7CFF,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

class TaskWithSubtasks {
  final Task task;
  final List<Task> subtasks;
  final Project? project;
  final List<Tag> tags;

  const TaskWithSubtasks({
    required this.task,
    this.subtasks = const [],
    this.project,
    this.tags = const [],
  });

  int get totalSubtasks => subtasks.length;
  int get completedSubtasks => subtasks.where((s) => s.isCompleted).length;
}
