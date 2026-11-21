// Pure Dart serialization, validation, and parsing for JSON and CSV data safety.
// ZERO Flutter imports.

import 'dart:convert';
import 'package:poswal_orbit/domain/models/data_safety_models.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

abstract final class DataSafetyCodec {
  static const int currentVersion = 1;

  // --- JSON Full Backup Serialization ---

  static String serializeFullJson({
    required List<Habit> habits,
    required List<HabitEntry> entries,
    required List<Task> tasks,
    required List<Note> notes,
    required List<Project> projects,
    required List<Tag> tags,
    Map<String, dynamic> appSettings = const {},
  }) {
    final payload = {
      'version': currentVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appName': 'Poswal Orbit',
      'habits': habits.map((h) => {
        'id': h.id,
        'name': h.name,
        'description': h.description,
        'iconName': h.iconName,
        'colorValue': h.colorValue,
        'habitType': h.habitType.name,
        'targetValue': h.targetValue,
        'unit': h.unit,
        'timeOfDay': h.timeOfDay.name,
        'scheduleType': h.scheduleType.name,
        'scheduleDays': h.scheduleDays,
        'targetDaysPerPeriod': h.targetDaysPerPeriod,
        'everyNDaysInterval': h.everyNDaysInterval,
        'startDate': h.startDate.toIso8601String(),
        'endDate': h.endDate?.toIso8601String(),
        'isArchived': h.isArchived,
        'sortOrder': h.sortOrder,
        'createdAt': h.createdAt.toIso8601String(),
        'updatedAt': h.updatedAt.toIso8601String(),
      }).toList(),
      'habitEntries': entries.map((e) => {
        'id': e.id,
        'habitId': e.habitId,
        'entryDate': e.entryDate,
        'status': e.status.name,
        'value': e.value,
        'note': e.note,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      }).toList(),
      'tasks': tasks.map((t) => {
        'id': t.id,
        'parentId': t.parentId,
        'title': t.title,
        'notes': t.notes,
        'dueAt': t.dueAt?.toIso8601String(),
        'hasTime': t.hasTime,
        'priority': t.priority.value,
        'projectId': t.projectId,
        'repeatRule': t.repeatRule?.toJson(),
        'isCompleted': t.isCompleted,
        'completedAt': t.completedAt?.toIso8601String(),
        'linkedHabitId': t.linkedHabitId,
        'sortOrder': t.sortOrder,
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
      }).toList(),
      'notes': notes.map((n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'colorLabel': n.colorLabel,
        'isPinned': n.isPinned,
        'isJournal': n.isJournal,
        'journalDate': n.journalDate,
        'linkedTaskId': n.linkedTaskId,
        'linkedHabitId': n.linkedHabitId,
        'tags': n.tags,
        'createdAt': n.createdAt.toIso8601String(),
        'updatedAt': n.updatedAt.toIso8601String(),
      }).toList(),
      'projects': projects.map((p) => {
        'id': p.id,
        'name': p.name,
        'iconName': p.iconName,
        'colorValue': p.colorValue,
        'sortOrder': p.sortOrder,
        'createdAt': p.createdAt.toIso8601String(),
        'updatedAt': p.updatedAt.toIso8601String(),
      }).toList(),
      'tags': tags.map((t) => {
        'id': t.id,
        'name': t.name,
        'colorValue': t.colorValue,
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
      }).toList(),
      'appSettings': appSettings,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  // --- Validation & Preview ---

  static BackupPreview inspectAndValidate(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return BackupPreview.invalid('File is empty.');
    }

    // 1. Try JSON inspection
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is! Map<String, dynamic>) {
          return BackupPreview.invalid('JSON root must be an object.');
        }

        final hasOrbitSignature = decoded['appName'] == 'Poswal Orbit' ||
            decoded.containsKey('habits') ||
            decoded.containsKey('tasks') ||
            decoded.containsKey('notes');

        if (!hasOrbitSignature) {
          return BackupPreview.invalid('Missing Poswal Orbit backup signature or content tables.');
        }

        final version = decoded['version'] as int? ?? 1;
        DateTime? exportDate;
        if (decoded['exportedAt'] != null) {
          exportDate = DateTime.tryParse(decoded['exportedAt'].toString());
        }

        final habits = (decoded['habits'] as List?)?.length ?? 0;
        final entries = (decoded['habitEntries'] as List?)?.length ?? 0;
        final tasks = (decoded['tasks'] as List?)?.length ?? 0;
        final notes = (decoded['notes'] as List?)?.length ?? 0;

        return BackupPreview(
          isValid: true,
          format: BackupFormat.jsonFull,
          habitCount: habits,
          entryCount: entries,
          taskCount: tasks,
          noteCount: notes,
          exportDate: exportDate,
          version: version,
        );
      } catch (e) {
        return BackupPreview.invalid('Malformed JSON file: $e');
      }
    }

    // 2. Try Loop Habit Tracker or CSV inspection
    if (trimmed.contains(',') || trimmed.contains('\n')) {
      return inspectCsv(trimmed);
    }

    return BackupPreview.invalid('Unrecognized backup format. Please provide a Poswal Orbit JSON or Loop Habit Tracker CSV.');
  }

  static BackupPreview inspectCsv(String csvContent) {
    final lines = csvContent.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) {
      return BackupPreview.invalid('CSV file is empty.');
    }

    final header = lines.first.split(',').map((c) => c.trim().replaceAll('"', '')).toList();

    // Loop Habit Tracker checkmarks format: "Date,Habit 1,Habit 2..."
    if (header.isNotEmpty && header.first.toLowerCase() == 'date') {
      final habitCount = header.length - 1;
      final entryCount = lines.length - 1; // Number of date rows

      return BackupPreview(
        isValid: true,
        format: BackupFormat.csvLoop,
        habitCount: habitCount,
        entryCount: entryCount,
      );
    }

    // Loop Habits definition format: "Position,Name,Question..."
    if (header.contains('Name') || header.contains('name')) {
      final habitCount = lines.length - 1;
      int entryCount = 0;
      for (int i = 1; i < lines.length; i++) {
        final cols = lines[i].split(',').map((c) => c.trim().replaceAll('"', '')).toList();
        for (int c = 5; c < cols.length; c++) {
          if (DateTime.tryParse(cols[c]) != null) {
            entryCount++;
          }
        }
      }
      return BackupPreview(
        isValid: true,
        format: BackupFormat.csvLoop,
        habitCount: habitCount,
        entryCount: entryCount,
      );
    }

    // Poswal Tasks CSV
    if (header.contains('title') && header.contains('priority')) {
      return BackupPreview(
        isValid: true,
        format: BackupFormat.csvTasks,
        taskCount: lines.length - 1,
      );
    }

    // Poswal Notes CSV
    if (header.contains('title') && header.contains('body')) {
      return BackupPreview(
        isValid: true,
        format: BackupFormat.csvNotes,
        noteCount: lines.length - 1,
      );
    }

    return BackupPreview.invalid('Unrecognized CSV format. Headers: ${header.take(4).join(", ")}');
  }

  // --- CSV Export Generation ---

  static String exportHabitsCsv(List<Habit> habits) {
    final sb = StringBuffer();
    sb.writeln('id,name,description,colorValue,iconName,habitType,targetValue,unit,timeOfDay,scheduleType,isArchived,createdAt');
    for (final h in habits) {
      sb.writeln([
        h.id,
        _escapeCsv(h.name),
        _escapeCsv(h.description ?? ''),
        h.colorValue,
        h.iconName,
        h.habitType.name,
        h.targetValue,
        _escapeCsv(h.unit),
        h.timeOfDay.name,
        h.scheduleType.name,
        h.isArchived,
        h.createdAt.toIso8601String(),
      ].join(','));
    }
    return sb.toString();
  }

  static String exportHabitEntriesCsv(List<HabitEntry> entries) {
    final sb = StringBuffer();
    sb.writeln('habitId,entryDate,status,value,note,createdAt');
    for (final e in entries) {
      sb.writeln([
        e.habitId,
        e.entryDate,
        e.status.name,
        e.value,
        _escapeCsv(e.note ?? ''),
        e.createdAt.toIso8601String(),
      ].join(','));
    }
    return sb.toString();
  }

  static String exportTasksCsv(List<Task> tasks) {
    final sb = StringBuffer();
    sb.writeln('id,title,notes,dueAt,hasTime,priority,isCompleted,completedAt,projectId');
    for (final t in tasks) {
      sb.writeln([
        t.id,
        _escapeCsv(t.title),
        _escapeCsv(t.notes ?? ''),
        t.dueAt?.toIso8601String() ?? '',
        t.hasTime,
        t.priority.value,
        t.isCompleted,
        t.completedAt?.toIso8601String() ?? '',
        t.projectId ?? '',
      ].join(','));
    }
    return sb.toString();
  }

  static String exportNotesCsv(List<Note> notes) {
    final sb = StringBuffer();
    sb.writeln('id,title,body,colorLabel,isPinned,isJournal,journalDate,createdAt');
    for (final n in notes) {
      sb.writeln([
        n.id,
        _escapeCsv(n.title),
        _escapeCsv(n.body),
        n.colorLabel,
        n.isPinned,
        n.isJournal,
        n.journalDate ?? '',
        n.createdAt.toIso8601String(),
      ].join(','));
    }
    return sb.toString();
  }

  // --- CSV Parser Helpers ---

  static String _escapeCsv(String val) {
    if (val.contains(',') || val.contains('"') || val.contains('\n')) {
      return '"${val.replaceAll('"', '""')}"';
    }
    return val;
  }
}
