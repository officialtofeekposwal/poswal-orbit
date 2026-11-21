import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

class ParsedTaskResult {
  final String cleanTitle;
  final DateTime? dueAt;
  final bool hasTime;
  final TaskPriority priority;
  final String? projectName;
  final List<String> tags;

  const ParsedTaskResult({
    required this.cleanTitle,
    this.dueAt,
    this.hasTime = false,
    this.priority = TaskPriority.none,
    this.projectName,
    this.tags = const [],
  });
}

class TaskNlpParser {
  /// Parses natural language task strings into structured fields.
  /// Example: "Call mom tomorrow 6pm !high #family"
  static ParsedTaskResult parse(
    String input, {
    DateTime? referenceDate,
    int dayStartHour = 4,
  }) {
    if (input.trim().isEmpty) {
      return const ParsedTaskResult(cleanTitle: '');
    }

    final ref = referenceDate ?? DateTime.now();
    final effectiveToday = DateBoundary.getEffectiveDate(ref, dayStartHour: dayStartHour);
    final today = DateTime(effectiveToday.year, effectiveToday.month, effectiveToday.day);

    String working = input;
    TaskPriority priority = TaskPriority.none;
    DateTime? targetDate;
    int? hour;
    int? minute;
    bool hasTime = false;
    final List<String> tags = [];

    // 1. Priority: !high, !urgent, !med, !medium, !low, !none, !1..4
    final priorityRegex = RegExp(r'!([a-zA-Z0-9]+)\b', caseSensitive: false);
    final priorityMatches = priorityRegex.allMatches(working).toList();
    for (final m in priorityMatches) {
      final val = m.group(1)?.toLowerCase();
      if (val != null) {
        if (val == '1' || val == 'urgent') {
          priority = TaskPriority.urgent;
          working = working.replaceFirst(m.group(0)!, ' ');
        } else if (val == '2' || val == 'high') {
          priority = TaskPriority.high;
          working = working.replaceFirst(m.group(0)!, ' ');
        } else if (val == '3' || val == 'med' || val == 'medium') {
          priority = TaskPriority.medium;
          working = working.replaceFirst(m.group(0)!, ' ');
        } else if (val == '4' || val == 'low') {
          priority = TaskPriority.low;
          working = working.replaceFirst(m.group(0)!, ' ');
        } else if (val == 'none') {
          priority = TaskPriority.none;
          working = working.replaceFirst(m.group(0)!, ' ');
        }
      }
    }

    // 2. Tags & Projects: #family, #work, #project
    final tagRegex = RegExp(r'#([a-zA-Z0-9_\-]+)\b');
    final tagMatches = tagRegex.allMatches(working).toList();
    for (final m in tagMatches) {
      final tag = m.group(1);
      if (tag != null && tag.isNotEmpty) {
        tags.add(tag);
        working = working.replaceFirst(m.group(0)!, ' ');
      }
    }

    // 3. Time: 6pm, 6:30pm, 18:00, 9am, 11:45am
    final time12Regex = RegExp(r'\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b', caseSensitive: false);
    final time12Match = time12Regex.firstMatch(working);
    if (time12Match != null) {
      hasTime = true;
      var h = int.parse(time12Match.group(1)!);
      final m = time12Match.group(2) != null ? int.parse(time12Match.group(2)!) : 0;
      final meridian = time12Match.group(3)!.toLowerCase();

      if (meridian == 'pm' && h < 12) h += 12;
      if (meridian == 'am' && h == 12) h = 0;

      hour = h;
      minute = m;
      working = working.replaceFirst(time12Match.group(0)!, ' ');
    } else {
      final time24Regex = RegExp(r'\b([01]?\d|2[0-3]):([0-5]\d)\b');
      final time24Match = time24Regex.firstMatch(working);
      if (time24Match != null) {
        hasTime = true;
        hour = int.parse(time24Match.group(1)!);
        minute = int.parse(time24Match.group(2)!);
        working = working.replaceFirst(time24Match.group(0)!, ' ');
      }
    }

    // 4. Relative days: "in 3 days", "in 1 day"
    final inDaysRegex = RegExp(r'\bin\s+(\d+)\s+days?\b', caseSensitive: false);
    final inDaysMatch = inDaysRegex.firstMatch(working);
    if (inDaysMatch != null) {
      final days = int.parse(inDaysMatch.group(1)!);
      targetDate = today.add(Duration(days: days));
      working = working.replaceFirst(inDaysMatch.group(0)!, ' ');
    }

    // 5. Date keywords: today, tomorrow, tmr, yesterday
    if (targetDate == null) {
      final todayRegex = RegExp(r'\btoday\b', caseSensitive: false);
      final tomorrowRegex = RegExp(r'\b(tomorrow|tmr)\b', caseSensitive: false);
      final yesterdayRegex = RegExp(r'\byesterday\b', caseSensitive: false);

      if (tomorrowRegex.hasMatch(working)) {
        targetDate = today.add(const Duration(days: 1));
        working = working.replaceFirst(tomorrowRegex, ' ');
      } else if (todayRegex.hasMatch(working)) {
        targetDate = today;
        working = working.replaceFirst(todayRegex, ' ');
      } else if (yesterdayRegex.hasMatch(working)) {
        targetDate = today.subtract(const Duration(days: 1));
        working = working.replaceFirst(yesterdayRegex, ' ');
      }
    }

    // 6. Weekday names: monday, tuesday...
    if (targetDate == null) {
      final weekdayMap = {
        'monday': 1, 'mon': 1,
        'tuesday': 2, 'tue': 2,
        'wednesday': 3, 'wed': 3,
        'thursday': 4, 'thu': 4,
        'friday': 5, 'fri': 5,
        'saturday': 6, 'sat': 6,
        'sunday': 7, 'sun': 7,
      };

      final weekdayRegex = RegExp(
        r'\b(monday|mon|tuesday|tue|wednesday|wed|thursday|thu|friday|fri|saturday|sat|sunday|sun)\b',
        caseSensitive: false,
      );
      final weekdayMatch = weekdayRegex.firstMatch(working);
      if (weekdayMatch != null) {
        final targetWeekday = weekdayMap[weekdayMatch.group(1)!.toLowerCase()]!;
        int daysAhead = targetWeekday - today.weekday;
        if (daysAhead <= 0) {
          daysAhead += 7; // Next occurrence
        }
        targetDate = today.add(Duration(days: daysAhead));
        working = working.replaceFirst(weekdayMatch.group(0)!, ' ');
      }
    }

    // Construct final DateTime if date or time was parsed
    DateTime? dueAt;
    if (targetDate != null) {
      dueAt = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        hour ?? 9,
        minute ?? 0,
      );
    } else if (hasTime && hour != null) {
      // Time specified without date -> default to today (or tomorrow if time already passed)
      final nowTime = DateTime(today.year, today.month, today.day, hour, minute ?? 0);
      if (nowTime.isBefore(ref)) {
        dueAt = nowTime.add(const Duration(days: 1));
      } else {
        dueAt = nowTime;
      }
    }

    // Clean up extra whitespace in title
    final cleanTitle = working.replaceAll(RegExp(r'\s+'), ' ').trim();

    return ParsedTaskResult(
      cleanTitle: cleanTitle,
      dueAt: dueAt,
      hasTime: hasTime,
      priority: priority,
      projectName: tags.isNotEmpty ? tags.first : null,
      tags: tags,
    );
  }
}
