import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/services/data_safety_service.dart';
import 'package:poswal_orbit/domain/models/data_safety_models.dart';

void main() {
  late AppDatabase db;
  late Directory tempBackupDir;
  late DataSafetyService safetyService;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempBackupDir = await Directory.systemTemp.createTemp('poswal_test_backups_');
    safetyService = DataSafetyService(db, tempBackupDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempBackupDir.exists()) {
      await tempBackupDir.delete(recursive: true);
    }
  });

  group('DataSafetyService - Daily Backups & Rotation', () {
    test('safe atomic write creates backup and cleans up tmp file', () async {
      final file = await safetyService.createBackup();

      expect(await file.exists(), isTrue);
      final tmpFile = File('${file.path}.tmp');
      expect(await tmpFile.exists(), isFalse);

      final content = await file.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      expect(decoded['version'], 1);
      expect(decoded['appName'], 'Poswal Orbit');
    });

    test('daily backup rotation preserves at most 7 recent snapshots', () async {
      // Simulate 10 daily backups
      for (int i = 1; i <= 10; i++) {
        final dayStr = i.toString().padLeft(2, '0');
        final file = File('${tempBackupDir.path}${Platform.pathSeparator}backup_2026-11-$dayStr.json');
        await file.writeAsString(jsonEncode({'test': i}));
      }

      var files = tempBackupDir.listSync().whereType<File>().toList();
      expect(files.length, 10);

      await safetyService.pruneOldBackups(keepCount: 7);

      files = tempBackupDir.listSync().whereType<File>().toList();
      expect(files.length, 7);

      // Verify that the oldest backups (01, 02, 03) were pruned
      final names = files.map((f) => f.uri.pathSegments.last).toList();
      expect(names.contains('backup_2026-11-01.json'), isFalse);
      expect(names.contains('backup_2026-11-02.json'), isFalse);
      expect(names.contains('backup_2026-11-03.json'), isFalse);
      expect(names.contains('backup_2026-11-10.json'), isTrue);
    });

    test('runDailyBackupOnLaunch creates backup if today is missing and skips if present', () async {
      final createdFirst = await safetyService.runDailyBackupOnLaunch();
      expect(createdFirst, isTrue);

      final createdSecond = await safetyService.runDailyBackupOnLaunch();
      expect(createdSecond, isFalse);
    });
  });

  group('DataSafetyService - Full JSON Export & Transactional Restore', () {
    test('round-trip export and restore preserves habits, tasks, and notes', () async {
      final now = DateTime.now();
      const habitId = 'habit-uuid-1';
      const taskId = 'task-uuid-1';
      const noteId = 'note-uuid-1';

      await db.into(db.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: habitId,
          name: 'Morning Meditation',
          colorValue: 0xFF2DD4BF,
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.into(db.tasksTable).insert(
        TasksTableCompanion.insert(
          id: taskId,
          title: 'Review pull request',
          priority: const drift.Value(1), // Urgent
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.into(db.notesTable).insert(
        NotesTableCompanion.insert(
          id: noteId,
          title: const drift.Value('Architecture Ideas'),
          body: const drift.Value('# Ideas\n- Offline-first\n- Liquid glass'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. Export full snapshot
      final exportJson = await safetyService.exportFullDatabaseJson();
      expect(exportJson.contains('Morning Meditation'), isTrue);
      expect(exportJson.contains('Review pull request'), isTrue);
      expect(exportJson.contains('Architecture Ideas'), isTrue);

      // 3. Clear database
      await db.delete(db.habitsTable).go();
      await db.delete(db.tasksTable).go();
      await db.delete(db.notesTable).go();

      expect((await db.select(db.habitsTable).get()).isEmpty, isTrue);
      expect((await db.select(db.tasksTable).get()).isEmpty, isTrue);
      expect((await db.select(db.notesTable).get()).isEmpty, isTrue);

      // 4. Restore from JSON string
      final restoreRes = await safetyService.restoreFromJsonString(exportJson);
      expect(restoreRes.habitsCount, 1);
      expect(restoreRes.tasksCount, 1);
      expect(restoreRes.notesCount, 1);

      final restoredHabits = await db.select(db.habitsTable).get();
      expect(restoredHabits.first.name, 'Morning Meditation');

      final restoredTasks = await db.select(db.tasksTable).get();
      expect(restoredTasks.first.title, 'Review pull request');
      expect(restoredTasks.first.priority, 1);

      final restoredNotes = await db.select(db.notesTable).get();
      expect(restoredNotes.first.title, 'Architecture Ideas');
    });

    test('automatic safety snapshot is created before restoring or wiping data', () async {
      final now = DateTime.now();
      await db.into(db.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: 'pre-wipe-habit',
          name: 'Vital Habit',
          colorValue: 0xFF2DD4BF,
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Wipe data
      await safetyService.deleteAllData();

      // Verify safety snapshot exists
      final files = tempBackupDir.listSync().whereType<File>().toList();
      final safetySnapshots = files.where((f) => f.path.contains('safety_backup_before_restore_'));
      expect(safetySnapshots.isNotEmpty, isTrue);

      // Verify DB is indeed wiped
      final habits = await db.select(db.habitsTable).get();
      expect(habits.isEmpty, isTrue);
    });

    test('corrupt or invalid JSON is rejected safely without modifying database', () async {
      final now = DateTime.now();
      await db.into(db.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: 'safe-habit-id',
          name: 'Never Lost',
          colorValue: 0xFF2DD4BF,
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      const invalidJson = '{"not_a_valid_orbit_backup": true}';

      final preview = safetyService.inspectImportContent(invalidJson);
      expect(preview.isValid, isFalse);
      expect(preview.validationError, isNotNull);

      // Attempt restore should throw FormatException and roll back
      expect(
        () => safetyService.restoreFromJsonString(invalidJson),
        throwsA(isA<FormatException>()),
      );

      // Original data remains completely untouched
      final habits = await db.select(db.habitsTable).get();
      expect(habits.length, 1);
      expect(habits.first.name, 'Never Lost');
    });
  });

  group('DataSafetyService - Loop Habit Tracker CSV Import', () {
    test('inspects and imports Loop Habit Tracker CSV format transactionally', () async {
      const loopCsv = '''
Position,Name,Question,Color,Frequency,Days
1,Read 30 mins,Did you read?,#2DD4BF,1,2026-11-01,2026-11-02,2026-11-03
2,Daily Walk,Did you walk?,#38BDF8,1,2026-11-01
''';

      final preview = safetyService.inspectImportContent(loopCsv);
      expect(preview.isValid, isTrue);
      expect(preview.format, BackupFormat.loopHabitTrackerCsv);
      expect(preview.habitsCount, 2);
      expect(preview.entriesCount, 4);

      final result = await safetyService.importLoopCsv(loopCsv);
      expect(result.habitsCount, 2);
      expect(result.entriesCount, 4);

      final habits = await db.select(db.habitsTable).get();
      expect(habits.length, 2);
      expect(habits.any((h) => h.name == 'Read 30 mins'), isTrue);
      expect(habits.any((h) => h.name == 'Daily Walk'), isTrue);

      final entries = await db.select(db.habitEntriesTable).get();
      expect(entries.length, 4);
    });
  });

  group('DataSafetyService - CSV Export', () {
    test('exports CSV strings for habits, tasks, and notes', () async {
      final now = DateTime.now();
      await db.into(db.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: 'csv-habit-1',
          name: 'Drink Water',
          colorValue: 0xFF2DD4BF,
          startDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final habitsCsv = await safetyService.exportHabitsCsv();
      expect(habitsCsv.contains('Drink Water'), isTrue);
      expect(habitsCsv.contains('csv-habit-1'), isTrue);

      final tasksCsv = await safetyService.exportTasksCsv();
      expect(tasksCsv.contains('id,title,notes,dueAt,hasTime,priority,isCompleted,completedAt,projectId'), isTrue);

      final notesCsv = await safetyService.exportNotesCsv();
      expect(notesCsv.contains('id,title,body,colorLabel,isPinned,isJournal,journalDate,createdAt'), isTrue);
    });
  });
}
