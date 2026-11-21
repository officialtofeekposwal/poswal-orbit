// Pure Dart models for Data Safety, Backups, and Import/Export
import 'dart:io';

enum BackupFormat {
  jsonFull('Poswal Orbit JSON Snapshot'),
  csvLoop('Loop Habit Tracker CSV'),
  csvHabits('Habits & Check-ins CSV'),
  csvTasks('Tasks & Subtasks CSV'),
  csvNotes('Notes CSV'),
  unknown('Unknown Format');

  final String label;
  const BackupFormat(this.label);

  static const loopHabitTrackerCsv = BackupFormat.csvLoop;

  static BackupFormat fromExtension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.json')) return BackupFormat.jsonFull;
    if (lower.endsWith('.csv')) return BackupFormat.csvHabits;
    return BackupFormat.unknown;
  }
}

class BackupPreview {
  final bool isValid;
  final BackupFormat format;
  final int habitCount;
  final int entryCount;
  final int taskCount;
  final int noteCount;
  final String? errorMessage;
  final DateTime? exportDate;
  final int version;

  const BackupPreview({
    required this.isValid,
    required this.format,
    this.habitCount = 0,
    this.entryCount = 0,
    this.taskCount = 0,
    this.noteCount = 0,
    this.errorMessage,
    this.exportDate,
    this.version = 1,
  });

  String? get validationError => errorMessage;
  int get habitsCount => habitCount;
  int get entriesCount => entryCount;
  int get tasksCount => taskCount;
  int get notesCount => noteCount;

  String get summary {
    if (!isValid) return errorMessage ?? 'Invalid backup file';
    final parts = <String>[];
    if (habitCount > 0) parts.add('$habitCount habits');
    if (entryCount > 0) parts.add('$entryCount check-ins');
    if (taskCount > 0) parts.add('$taskCount tasks');
    if (noteCount > 0) parts.add('$noteCount notes');
    if (parts.isEmpty) return 'Empty snapshot';
    return parts.join(', ');
  }

  factory BackupPreview.invalid(String error) {
    return BackupPreview(
      isValid: false,
      format: BackupFormat.unknown,
      errorMessage: error,
    );
  }
}

class BackupFileInfo {
  final String filePath;
  final String fileName;
  final DateTime date;
  final int sizeBytes;
  final bool isAutomatic;

  const BackupFileInfo({
    required this.filePath,
    required this.fileName,
    required this.date,
    required this.sizeBytes,
    this.isAutomatic = true,
  });

  String get name => fileName;
  File get file => File(filePath);

  String get formattedDate {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
