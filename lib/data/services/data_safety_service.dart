import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/domain/logic/data_safety_codec.dart';
import 'package:poswal_orbit/domain/models/data_safety_models.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class DataSafetyService {
  final AppDatabase _db;
  final Directory? _customBackupDir;

  DataSafetyService(this._db, [this._customBackupDir]);

  Future<Directory> getBackupDirectory() async {
    if (_customBackupDir != null) {
      if (!await _customBackupDir.exists()) {
        await _customBackupDir.create(recursive: true);
      }
      return _customBackupDir;
    }

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${docsDir.path}${Platform.pathSeparator}backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      return backupDir;
    } catch (_) {
      // Fallback for test or headless environments where path_provider channel is not mocked
      final tempDir = Directory('${Directory.systemTemp.path}${Platform.pathSeparator}poswal_backups');
      if (!tempDir.existsSync()) {
        tempDir.createSync(recursive: true);
      }
      return tempDir;
    }
  }

  // --- Snapshot Creation & Safe Atomic Writing ---

  Future<File> createBackup({bool isSafetySnapshot = false, String? customNote}) async {
    final dir = await getBackupDirectory();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timestampStr = DateFormat('yyyyMMdd_HHmmss').format(now);

    final fileName = isSafetySnapshot
        ? 'safety_backup_before_restore_$timestampStr.json'
        : 'backup_$dateStr.json';

    final targetFile = File('${dir.path}${Platform.pathSeparator}$fileName');
    final tempFile = File('${dir.path}${Platform.pathSeparator}$fileName.tmp');

    // 1. Gather all database entities
    final payload = await exportFullDatabaseJson();

    // 2. Write to temp file first for atomic safety
    await tempFile.writeAsString(payload, flush: true);

    // 3. Atomic rename to target with Windows file-lock fallback
    try {
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);
    } catch (_) {
      await tempFile.copy(targetFile.path);
      try {
        await tempFile.delete();
      } catch (_) {}
    }

    // 4. Prune older backups if this was an automated daily backup
    if (!isSafetySnapshot) {
      await pruneOldBackups(keepCount: 7);
    }

    return targetFile;
  }

  Future<bool> runDailyBackupOnLaunch() async {
    try {
      final dir = await getBackupDirectory();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final expectedFile = File('${dir.path}${Platform.pathSeparator}backup_$todayStr.json');

      if (!await expectedFile.exists()) {
        await createBackup();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> pruneOldBackups({int keepCount = 7}) async {
    final dir = await getBackupDirectory();
    if (!await dir.exists()) return;

    final files = dir.listSync().whereType<File>().where((f) {
      final name = f.uri.pathSegments.last;
      return name.startsWith('backup_') && name.endsWith('.json') && !name.contains('safety_');
    }).toList();

    // Sort by name descending (which matches yyyy-MM-dd descending)
    files.sort((a, b) => b.path.compareTo(a.path));

    if (files.length > keepCount) {
      for (int i = keepCount; i < files.length; i++) {
        try {
          await files[i].delete();
        } catch (_) {}
      }
    }
  }

  Future<List<BackupFileInfo>> listBackups() async {
    final dir = await getBackupDirectory();
    if (!await dir.exists()) return [];

    final files = dir.listSync().whereType<File>().where((f) {
      final name = f.uri.pathSegments.last;
      return name.endsWith('.json');
    }).toList();

    final result = <BackupFileInfo>[];
    for (final file in files) {
      final name = file.uri.pathSegments.last;
      final stat = await file.stat();
      final isAuto = name.startsWith('backup_') && !name.contains('safety_');

      result.add(BackupFileInfo(
        filePath: file.path,
        fileName: name,
        date: stat.modified,
        sizeBytes: stat.size,
        isAutomatic: isAuto,
      ));
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  // --- Export Full Database ---

  Future<String> exportFullDatabaseJson() async {
    final habitRows = await _db.select(_db.habitsTable).get();
    final entryRows = await _db.select(_db.habitEntriesTable).get();
    final taskRows = await _db.select(_db.tasksTable).get();
    final noteRows = await _db.select(_db.notesTable).get();
    final projectRows = await _db.select(_db.projectsTable).get();
    final tagRows = await _db.select(_db.tagsTable).get();

    final habits = habitRows.map((r) {
      List<int> days = [];
      if (r.scheduleDays.isNotEmpty) {
        days = r.scheduleDays.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toList();
      }
      return Habit(
        id: r.id,
        name: r.name,
        description: r.description,
        iconName: r.iconName,
        colorValue: r.colorValue,
        habitType: HabitType.fromString(r.habitType),
        targetValue: r.targetValue,
        unit: r.unit,
        timeOfDay: TimeOfDayGroup.fromString(r.timeOfDay),
        scheduleType: ScheduleType.fromString(r.scheduleType),
        scheduleDays: days,
        targetDaysPerPeriod: r.targetDaysPerPeriod,
        everyNDaysInterval: r.everyNDaysInterval,
        startDate: r.startDate,
        endDate: r.endDate,
        isArchived: r.isArchived,
        sortOrder: r.sortOrder,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );
    }).toList();

    final entries = entryRows.map((r) => HabitEntry(
      id: r.id,
      habitId: r.habitId,
      entryDate: r.entryDate,
      status: HabitEntryStatus.fromString(r.status),
      value: r.value,
      note: r.note,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();

    final tasks = taskRows.map((r) => Task(
      id: r.id,
      parentId: r.parentId,
      title: r.title,
      notes: r.notes,
      dueAt: r.dueAt,
      hasTime: r.hasTime,
      priority: TaskPriority.fromValue(r.priority),
      projectId: r.projectId,
      repeatRule: TaskRepeatRule.fromJson(r.repeatRule),
      isCompleted: r.isCompleted,
      completedAt: r.completedAt,
      linkedHabitId: r.linkedHabitId,
      sortOrder: r.sortOrder,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();

    final notes = <Note>[];
    for (final r in noteRows) {
      final tagsQuery = _db.select(_db.noteTagsTable).join([
        innerJoin(_db.tagsTable, _db.tagsTable.id.equalsExp(_db.noteTagsTable.tagId)),
      ])..where(_db.noteTagsTable.noteId.equals(r.id));
      final tagResults = await tagsQuery.get();
      final tagNames = tagResults.map((row) => row.readTable(_db.tagsTable).name).toList();

      notes.add(Note(
        id: r.id,
        title: r.title,
        body: r.body,
        colorLabel: r.colorLabel,
        isPinned: r.isPinned,
        isJournal: r.isJournal,
        journalDate: r.journalDate,
        linkedTaskId: r.linkedTaskId,
        linkedHabitId: r.linkedHabitId,
        tags: tagNames,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      ));
    }

    final projects = projectRows.map((r) => Project(
      id: r.id,
      name: r.name,
      iconName: r.iconName,
      colorValue: r.colorValue,
      sortOrder: r.sortOrder,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();

    final tags = tagRows.map((r) => Tag(
      id: r.id,
      name: r.name,
      colorValue: r.colorValue,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();

    return DataSafetyCodec.serializeFullJson(
      habits: habits,
      entries: entries,
      tasks: tasks,
      notes: notes,
      projects: projects,
      tags: tags,
    );
  }

  // --- Restore from JSON (Transactional All-or-Nothing) ---

  Future<void> restoreFromJson(String jsonString) async {
    final preview = DataSafetyCodec.inspectAndValidate(jsonString);
    if (!preview.isValid) {
      throw FormatException(preview.errorMessage ?? 'Invalid backup file');
    }

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    // 1. Take safety snapshot before modifying database
    await createBackup(isSafetySnapshot: true);

    // 2. Transactional execution: any error triggers rollback
    await _db.transaction(() async {
      await _wipeAllDataInternal();

      // Habits
      final habitsList = (decoded['habits'] as List?) ?? [];
      for (final h in habitsList) {
        final map = h as Map<String, dynamic>;
        final scheduleDays = (map['scheduleDays'] as List?)?.map((e) => e.toString()).join(',') ?? '';
        await _db.into(_db.habitsTable).insert(
          HabitsTableCompanion.insert(
            id: map['id']?.toString() ?? '',
            name: map['name']?.toString() ?? '',
            description: Value(map['description']?.toString()),
            iconName: Value(map['iconName']?.toString() ?? 'sparkle'),
            colorValue: map['colorValue'] as int? ?? 0xFF14B8A6,
            habitType: Value(map['habitType']?.toString() ?? 'yesNo'),
            targetValue: Value((map['targetValue'] as num?)?.toDouble() ?? 1.0),
            unit: Value(map['unit']?.toString() ?? ''),
            timeOfDay: Value(map['timeOfDay']?.toString() ?? 'anytime'),
            scheduleType: Value(map['scheduleType']?.toString() ?? 'daily'),
            scheduleDays: Value(scheduleDays),
            targetDaysPerPeriod: Value(map['targetDaysPerPeriod'] as int? ?? 1),
            everyNDaysInterval: Value(map['everyNDaysInterval'] as int? ?? 1),
            startDate: DateTime.tryParse(map['startDate']?.toString() ?? '') ?? DateTime.now(),
            endDate: Value(DateTime.tryParse(map['endDate']?.toString() ?? '')),
            isArchived: Value(map['isArchived'] as bool? ?? false),
            sortOrder: Value(map['sortOrder'] as int? ?? 0),
            createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
          ),
        );
      }

      // Habit Entries
      final entriesList = (decoded['habitEntries'] as List?) ?? [];
      for (final e in entriesList) {
        final map = e as Map<String, dynamic>;
        await _db.into(_db.habitEntriesTable).insert(
          HabitEntriesTableCompanion.insert(
            id: map['id']?.toString() ?? '',
            habitId: map['habitId']?.toString() ?? '',
            entryDate: map['entryDate']?.toString() ?? '',
            status: Value(map['status']?.toString() ?? 'done'),
            value: Value((map['value'] as num?)?.toDouble() ?? 1.0),
            note: Value(map['note']?.toString()),
            createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
          ),
        );
      }

      // Projects
      final projectsList = (decoded['projects'] as List?) ?? [];
      for (final p in projectsList) {
        final map = p as Map<String, dynamic>;
        await _db.into(_db.projectsTable).insert(
          ProjectsTableCompanion.insert(
            id: map['id']?.toString() ?? '',
            name: map['name']?.toString() ?? '',
            iconName: Value(map['iconName']?.toString() ?? 'folder'),
            colorValue: Value(map['colorValue'] as int? ?? 0xFF14B8A6),
            sortOrder: Value(map['sortOrder'] as int? ?? 0),
            createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
          ),
        );
      }

      // Tasks
      final tasksList = (decoded['tasks'] as List?) ?? [];
      for (final t in tasksList) {
        final map = t as Map<String, dynamic>;
        await _db.into(_db.tasksTable).insert(
          TasksTableCompanion.insert(
            id: map['id']?.toString() ?? '',
            parentId: Value(map['parentId']?.toString()),
            title: map['title']?.toString() ?? '',
            notes: Value(map['notes']?.toString()),
            dueAt: Value(DateTime.tryParse(map['dueAt']?.toString() ?? '')),
            hasTime: Value(map['hasTime'] as bool? ?? false),
            priority: Value(map['priority'] as int? ?? 0),
            projectId: Value(map['projectId']?.toString()),
            repeatRule: Value(map['repeatRule'] != null ? jsonEncode(map['repeatRule']) : null),
            isCompleted: Value(map['isCompleted'] as bool? ?? false),
            completedAt: Value(DateTime.tryParse(map['completedAt']?.toString() ?? '')),
            linkedHabitId: Value(map['linkedHabitId']?.toString()),
            sortOrder: Value(map['sortOrder'] as int? ?? 0),
            createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
          ),
        );
      }

      // Notes
      final notesList = (decoded['notes'] as List?) ?? [];
      for (final n in notesList) {
        final map = n as Map<String, dynamic>;
        final noteId = map['id']?.toString() ?? '';
        await _db.into(_db.notesTable).insert(
          NotesTableCompanion.insert(
            id: noteId,
            title: Value(map['title']?.toString() ?? ''),
            body: Value(map['body']?.toString() ?? ''),
            colorLabel: Value(map['colorLabel'] as int? ?? 0),
            isPinned: Value(map['isPinned'] as bool? ?? false),
            isJournal: Value(map['isJournal'] as bool? ?? false),
            journalDate: Value(map['journalDate']?.toString()),
            linkedTaskId: Value(map['linkedTaskId']?.toString()),
            linkedHabitId: Value(map['linkedHabitId']?.toString()),
            createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
          ),
        );

        // Tags for note
        final tags = (map['tags'] as List?)?.map((t) => t.toString()).toList() ?? [];
        for (final tag in tags) {
          final clean = tag.trim().toLowerCase();
          if (clean.isEmpty) continue;
          final existing = await (_db.select(_db.tagsTable)..where((tbl) => tbl.name.equals(clean))).getSingleOrNull();
          final tagId = existing?.id ?? 'tag-$clean';
          if (existing == null) {
            await _db.into(_db.tagsTable).insert(
              TagsTableCompanion.insert(
                id: tagId,
                name: clean,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }
          await _db.into(_db.noteTagsTable).insert(
            NoteTagsTableCompanion.insert(noteId: noteId, tagId: tagId),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });
  }

  // --- Import Loop Habit Tracker CSV (Transactional) ---

  Future<void> importLoopHabitTrackerCsv(String csvContent) async {
    final preview = DataSafetyCodec.inspectCsv(csvContent);
    if (!preview.isValid) {
      throw FormatException(preview.errorMessage ?? 'Invalid CSV');
    }

    final lines = csvContent.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return;

    final header = lines.first.split(',').map((c) => c.trim().replaceAll('"', '')).toList();

    // 1. Take safety snapshot first
    await createBackup(isSafetySnapshot: true);

    // 2. Transactional execution
    await _db.transaction(() async {
      // Loop Checkmarks Format: Date,Habit 1,Habit 2,...
      if (header.first.toLowerCase() == 'date') {
        final habitNames = header.sublist(1);
        final habitMap = <int, String>{}; // index -> habitId

        for (int i = 0; i < habitNames.length; i++) {
          final name = habitNames[i].trim();
          if (name.isEmpty) continue;
          final habitId = 'loop-h-$i-${name.toLowerCase().replaceAll(RegExp(r'\W+'), '-')}';
          habitMap[i + 1] = habitId;

          await _db.into(_db.habitsTable).insert(
            HabitsTableCompanion.insert(
              id: habitId,
              name: name,
              iconName: const Value('sparkle'),
              colorValue: 0xFF14B8A6,
              habitType: const Value('yesNo'),
              targetValue: const Value(1.0),
              unit: const Value(''),
              timeOfDay: const Value('anytime'),
              scheduleType: const Value('daily'),
              startDate: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }

        // Parse date rows
        for (int r = 1; r < lines.length; r++) {
          final cols = lines[r].split(',').map((c) => c.trim().replaceAll('"', '')).toList();
          if (cols.isEmpty) continue;
          final dateStr = cols.first;
          if (DateTime.tryParse(dateStr) == null) continue;

          for (int c = 1; c < cols.length; c++) {
            final habitId = habitMap[c];
            if (habitId == null) continue;

            final rawVal = int.tryParse(cols[c]) ?? 0;
            if (rawVal > 0) {
              await _db.into(_db.habitEntriesTable).insert(
                HabitEntriesTableCompanion.insert(
                  id: 'loop-entry-$habitId-$dateStr',
                  habitId: habitId,
                  entryDate: dateStr,
                  status: const Value('done'),
                  value: Value(rawVal.toDouble()),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        }
      } else if (header.contains('Name') || header.contains('name')) {
        // Loop Habits with history format: Position,Name,Question,Color,Frequency,Days...
        for (int r = 1; r < lines.length; r++) {
          final cols = lines[r].split(',').map((c) => c.trim().replaceAll('"', '')).toList();
          if (cols.length < 2) continue;
          final name = cols[1].trim();
          if (name.isEmpty) continue;
          final habitId = 'loop-h-$r-${name.toLowerCase().replaceAll(RegExp(r'\W+'), '-')}';

          await _db.into(_db.habitsTable).insert(
            HabitsTableCompanion.insert(
              id: habitId,
              name: name,
              iconName: const Value('sparkle'),
              colorValue: 0xFF14B8A6,
              habitType: const Value('yesNo'),
              targetValue: const Value(1.0),
              unit: const Value(''),
              timeOfDay: const Value('anytime'),
              scheduleType: const Value('daily'),
              startDate: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrIgnore,
          );

          // Dates after index 4
          for (int c = 5; c < cols.length; c++) {
            final dateStr = cols[c].trim();
            if (DateTime.tryParse(dateStr) == null) continue;
            await _db.into(_db.habitEntriesTable).insert(
              HabitEntriesTableCompanion.insert(
                id: 'loop-entry-$habitId-$dateStr',
                habitId: habitId,
                entryDate: dateStr,
                status: const Value('done'),
                value: const Value(1.0),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        }
      }
    });
  }

  Future<List<BackupFileInfo>> listAvailableBackups() => listBackups();

  BackupPreview inspectImportContent(String content) => DataSafetyCodec.inspectAndValidate(content);

  Future<BackupPreview> restoreFromJsonFile(File file) async {
    final content = await file.readAsString();
    return restoreFromJsonString(content);
  }

  Future<BackupPreview> restoreFromJsonString(String jsonString) async {
    final preview = inspectImportContent(jsonString);
    if (!preview.isValid) {
      throw FormatException(preview.errorMessage ?? 'Invalid backup file');
    }
    await restoreFromJson(jsonString);
    return preview;
  }

  Future<BackupPreview> importLoopCsv(String csvContent) async {
    final preview = DataSafetyCodec.inspectCsv(csvContent);
    if (!preview.isValid) {
      throw FormatException(preview.errorMessage ?? 'Invalid CSV format');
    }
    await importLoopHabitTrackerCsv(csvContent);
    return preview;
  }

  Future<String> exportHabitsCsv() async {
    final habitRows = await _db.select(_db.habitsTable).get();
    final habits = habitRows.map((r) => Habit(
      id: r.id,
      name: r.name,
      description: r.description,
      iconName: r.iconName,
      colorValue: r.colorValue,
      habitType: HabitType.fromString(r.habitType),
      targetValue: r.targetValue,
      unit: r.unit,
      timeOfDay: TimeOfDayGroup.fromString(r.timeOfDay),
      scheduleType: ScheduleType.fromString(r.scheduleType),
      startDate: r.startDate,
      endDate: r.endDate,
      isArchived: r.isArchived,
      sortOrder: r.sortOrder,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
    return DataSafetyCodec.exportHabitsCsv(habits);
  }

  Future<String> exportTasksCsv() async {
    final taskRows = await _db.select(_db.tasksTable).get();
    final tasks = taskRows.map((r) => Task(
      id: r.id,
      parentId: r.parentId,
      title: r.title,
      notes: r.notes,
      dueAt: r.dueAt,
      hasTime: r.hasTime,
      priority: TaskPriority.fromValue(r.priority),
      projectId: r.projectId,
      repeatRule: TaskRepeatRule.fromJson(r.repeatRule),
      isCompleted: r.isCompleted,
      completedAt: r.completedAt,
      linkedHabitId: r.linkedHabitId,
      sortOrder: r.sortOrder,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
    return DataSafetyCodec.exportTasksCsv(tasks);
  }

  Future<String> exportNotesCsv() async {
    final noteRows = await _db.select(_db.notesTable).get();
    final notes = noteRows.map((r) => Note(
      id: r.id,
      title: r.title,
      body: r.body,
      colorLabel: r.colorLabel,
      isPinned: r.isPinned,
      isJournal: r.isJournal,
      journalDate: r.journalDate,
      linkedTaskId: r.linkedTaskId,
      linkedHabitId: r.linkedHabitId,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
    return DataSafetyCodec.exportNotesCsv(notes);
  }

  // --- Wipe All Data (with Safety Backup) ---

  Future<void> deleteAllData() async {
    // 1. Take safety backup before wiping
    await createBackup(isSafetySnapshot: true);

    // 2. Transactionally wipe all tables
    await _db.transaction(() async {
      await _wipeAllDataInternal();
    });
  }

  Future<void> _wipeAllDataInternal() async {
    await _db.delete(_db.noteTagsTable).go();
    await _db.delete(_db.notesTable).go();
    await _db.delete(_db.taskTagsTable).go();
    await _db.delete(_db.tasksTable).go();
    await _db.delete(_db.projectsTable).go();
    await _db.delete(_db.tagsTable).go();
    await _db.delete(_db.habitEntriesTable).go();
    await _db.delete(_db.remindersTable).go();
    await _db.delete(_db.habitsTable).go();
  }
}

final dataSafetyServiceProvider = Provider<DataSafetyService>((ref) {
  final db = ref.watch(databaseProvider);
  return DataSafetyService(db);
});

