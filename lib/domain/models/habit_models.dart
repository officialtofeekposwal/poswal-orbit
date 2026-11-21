// Pure Dart domain models - ZERO Flutter imports.

enum HabitType {
  yesNo,
  numeric;

  static HabitType fromString(String val) {
    return HabitType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => HabitType.yesNo,
    );
  }
}

enum TimeOfDayGroup {
  morning,
  afternoon,
  evening,
  anytime;

  String get displayName {
    switch (this) {
      case TimeOfDayGroup.morning:
        return 'Morning';
      case TimeOfDayGroup.afternoon:
        return 'Afternoon';
      case TimeOfDayGroup.evening:
        return 'Evening';
      case TimeOfDayGroup.anytime:
        return 'Anytime';
    }
  }

  static TimeOfDayGroup fromString(String val) {
    return TimeOfDayGroup.values.firstWhere(
      (e) => e.name == val,
      orElse: () => TimeOfDayGroup.anytime,
    );
  }
}

enum ScheduleType {
  daily,
  weekdays,
  xPerWeek,
  xPerMonth,
  everyNDays;

  static ScheduleType fromString(String val) {
    return ScheduleType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => ScheduleType.daily,
    );
  }
}

enum HabitEntryStatus {
  done,
  skipped,
  missed;

  static HabitEntryStatus fromString(String val) {
    return HabitEntryStatus.values.firstWhere(
      (e) => e.name == val,
      orElse: () => HabitEntryStatus.missed,
    );
  }
}

class Habit {
  final String id;
  final String name;
  final String? description;
  final String iconName;
  final int colorValue;
  final HabitType habitType;
  final double targetValue;
  final String unit;
  final TimeOfDayGroup timeOfDay;
  final ScheduleType scheduleType;
  final List<int> scheduleDays; // 1 = Monday, 7 = Sunday
  final int targetDaysPerPeriod;
  final int everyNDaysInterval;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isArchived;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Habit({
    required this.id,
    required this.name,
    this.description,
    required this.iconName,
    required this.colorValue,
    required this.habitType,
    required this.targetValue,
    required this.unit,
    required this.timeOfDay,
    required this.scheduleType,
    this.scheduleDays = const [],
    this.targetDaysPerPeriod = 1,
    this.everyNDaysInterval = 1,
    required this.startDate,
    this.endDate,
    this.isArchived = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    int? colorValue,
    HabitType? habitType,
    double? targetValue,
    String? unit,
    TimeOfDayGroup? timeOfDay,
    ScheduleType? scheduleType,
    List<int>? scheduleDays,
    int? targetDaysPerPeriod,
    int? everyNDaysInterval,
    DateTime? startDate,
    DateTime? endDate,
    bool? isArchived,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      habitType: habitType ?? this.habitType,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      targetDaysPerPeriod: targetDaysPerPeriod ?? this.targetDaysPerPeriod,
      everyNDaysInterval: everyNDaysInterval ?? this.everyNDaysInterval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  bool get isNumeric => habitType == HabitType.numeric;
  bool get isYesNo => habitType == HabitType.yesNo;
}

class HabitEntry {
  final String id;
  final String habitId;
  final String entryDate; // YYYY-MM-DD
  final HabitEntryStatus status;
  final double value;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.entryDate,
    required this.status,
    required this.value,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isDone => status == HabitEntryStatus.done;
  bool get isSkipped => status == HabitEntryStatus.skipped;
  bool get isMissed => status == HabitEntryStatus.missed;

  HabitEntry copyWith({
    String? id,
    String? habitId,
    String? entryDate,
    HabitEntryStatus? status,
    double? value,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      entryDate: entryDate ?? this.entryDate,
      status: status ?? this.status,
      value: value ?? this.value,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class HabitWithEntry {
  final Habit habit;
  final HabitEntry? entry;
  final int currentStreak;
  final double habitScore;

  const HabitWithEntry({
    required this.habit,
    this.entry,
    this.currentStreak = 0,
    this.habitScore = 0.0,
  });

  bool get isCompleted => entry?.status == HabitEntryStatus.done;
  bool get isSkipped => entry?.status == HabitEntryStatus.skipped;
  double get currentProgress => entry?.value ?? 0.0;
}

class HabitDetailedStats {
  final Habit habit;
  final int currentStreak;
  final int bestStreak;
  final double habitScore;
  final double completionRate;
  final int totalScheduled;
  final int totalCompleted;
  final int totalSkipped;
  final List<HabitEntry> entries;
  final Map<int, int> weekdayCompletions; // 1 (Mon) -> count, 7 (Sun) -> count

  const HabitDetailedStats({
    required this.habit,
    required this.currentStreak,
    required this.bestStreak,
    required this.habitScore,
    required this.completionRate,
    required this.totalScheduled,
    required this.totalCompleted,
    required this.totalSkipped,
    required this.entries,
    required this.weekdayCompletions,
  });

  HabitDetailedStats copyWith({
    Habit? habit,
    int? currentStreak,
    int? bestStreak,
    double? habitScore,
    double? completionRate,
    int? totalScheduled,
    int? totalCompleted,
    int? totalSkipped,
    List<HabitEntry>? entries,
    Map<int, int>? weekdayCompletions,
  }) {
    return HabitDetailedStats(
      habit: habit ?? this.habit,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      habitScore: habitScore ?? this.habitScore,
      completionRate: completionRate ?? this.completionRate,
      totalScheduled: totalScheduled ?? this.totalScheduled,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalSkipped: totalSkipped ?? this.totalSkipped,
      entries: entries ?? this.entries,
      weekdayCompletions: weekdayCompletions ?? this.weekdayCompletions,
    );
  }
}

class HabitReminder {
  final String id;
  final String parentId;
  final String parentType; // 'habit' or 'task'
  final String timeString; // HH:mm
  final String daysOfWeek; // e.g. '1,2,3,4,5' or ''
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const HabitReminder({
    required this.id,
    required this.parentId,
    this.parentType = 'habit',
    required this.timeString,
    this.daysOfWeek = '',
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  HabitReminder copyWith({
    String? id,
    String? parentId,
    String? parentType,
    String? timeString,
    String? daysOfWeek,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return HabitReminder(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      parentType: parentType ?? this.parentType,
      timeString: timeString ?? this.timeString,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

