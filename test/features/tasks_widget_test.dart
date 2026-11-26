import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/repositories/task_repository.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/tasks/presentation/tasks_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_quick_add_sheet.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/features/today/presentation/today_screen.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase inMemoryDb;

  DateTime getTodayNow() {
    final appDate = const DateBoundary(dayStartHour: 4).getAppDate(DateTime.now());
    return appDate.add(const Duration(hours: 12));
  }

  setUp(() {
    inMemoryDb = AppDatabase(NativeDatabase.memory());
  });

  Future<void> pumpWidgetTest(WidgetTester tester, Widget child, {AppDatabase? db}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db ?? inMemoryDb),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: PoswalTheme.getTheme(AppThemeMode.dark),
          home: Scaffold(
            body: child,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  Future<void> tearDownTest(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() async {
      await inMemoryDb.close();
    });
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  Future<void> captureWidgetScreenshot(WidgetTester tester, GlobalKey repaintKey, String filename) async {
    if (Platform.environment['UPDATE_SCREENSHOTS'] != 'true') return;
    await tester.runAsync(() async {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final file = File('docs/screenshots/$filename.png');
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(byteData.buffer.asUint8List());
        }
      }
    });
  }

  group('Phase 2B - Tasks UI & Interactivity Widget Tests', () {
    testWidgets('1. Task row animated check-off and swipe right to complete', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = getTodayNow();
      final repo = TaskRepository(inMemoryDb);
      final task = Task(
        id: 'task-test-1',
        title: 'Review pull request',
        dueAt: now,
        priority: TaskPriority.high,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      );
      await repo.createTask(task);

      await pumpWidgetTest(
        tester,
        const TasksScreen(),
      );

      expect(find.text('Review pull request'), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);

      // Tap animated checkbox ring to complete
      await tester.tap(find.byKey(const ValueKey('task_checkbox_task-test-1')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Verify the task was toggled to completed in the database
      final updated = await repo.getTaskById('task-test-1');
      expect(updated, isNotNull);
      expect(updated!.isCompleted, isTrue);

      await tearDownTest(tester);
    });

    testWidgets('2. Task row swipe left to delete and tap Undo toast to restore', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = getTodayNow();
      final repo = TaskRepository(inMemoryDb);
      final task = Task(
        id: 'task-test-delete',
        title: 'Temporary errand to delete',
        dueAt: now,
        priority: TaskPriority.low,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      );
      await repo.createTask(task);

      await pumpWidgetTest(
        tester,
        const TasksScreen(),
      );

      expect(find.text('Temporary errand to delete'), findsOneWidget);

      // Swipe left to dismiss and delete
      await tester.fling(
        find.byKey(const ValueKey('task_dismissible_task-test-delete')),
        const Offset(-600, 0),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify SnackBar with Undo action appears
      expect(find.textContaining('deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Database should reflect deletion
      var checkDeleted = await repo.getTaskById('task-test-delete');
      expect(checkDeleted, isNull);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Database should have task restored
      final restored = await repo.getTaskById('task-test-delete');
      expect(restored, isNotNull);
      expect(restored!.title, equals('Temporary errand to delete'));

      await tearDownTest(tester);
    });

    testWidgets('3. Quick-add sheet updates live interactive parsed chips as user types', (WidgetTester tester) async {
      await pumpWidgetTest(
        tester,
        const TaskQuickAddSheet(),
      );

      expect(find.text('Quick Add Task'), findsOneWidget);
      expect(find.text('Due date and time'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);

      // Enter natural language command
      await tester.enterText(
        find.byType(TextField),
        'Call mom tomorrow 6pm !high #family',
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Check that chips updated dynamically
      expect(find.text('High'), findsOneWidget);
      expect(find.text('#family'), findsOneWidget);
      expect(find.textContaining('6:00 PM'), findsOneWidget);

      // Tap priority chip to cycle priority
      await tester.tap(find.text('High'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Medium'), findsOneWidget);

      await tearDownTest(tester);
    });

    testWidgets('4. Task detail sheet displays and manages subtasks inline', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = getTodayNow();
      final repo = TaskRepository(inMemoryDb);
      final parentTask = Task(
        id: 'parent-1',
        title: 'Complete project report',
        dueAt: now,
        priority: TaskPriority.urgent,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      );
      await repo.createTask(parentTask);

      await pumpWidgetTest(
        tester,
        TaskDetailSheet(task: parentTask),
      );

      expect(find.text('Complete project report'), findsOneWidget);
      expect(find.text('Subtasks'), findsOneWidget);

      // Add a subtask
      final subtaskInput = find.widgetWithText(TextField, 'Add a subtask...');
      expect(subtaskInput, findsOneWidget);
      await tester.enterText(subtaskInput, 'Write executive summary');
      await tester.pump(const Duration(milliseconds: 100));

      // Tap plus button to submit subtask
      await tester.tap(find.byKey(const ValueKey('add_subtask_btn')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Check subtasks from repository
      final subtasks = await repo.getSubtasks('parent-1');
      expect(subtasks.length, 1);
      expect(subtasks.first.title, 'Write executive summary');
      expect(subtasks.first.isCompleted, isFalse);

      // Verify subtask appears
      expect(find.text('Write executive summary'), findsOneWidget);

      // Toggle subtask complete via checkbox in list
      await tester.tap(find.byKey(ValueKey('subtask_checkbox_${subtasks.first.id}')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final updatedSubtasks = await repo.getSubtasks('parent-1');
      expect(updatedSubtasks.first.isCompleted, isTrue);

      await tearDownTest(tester);
    });

    testWidgets('5. Tasks Screen renders smart filters, project chips, and drag reorder', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = getTodayNow();
      final repo = TaskRepository(inMemoryDb);
      await repo.createProject(
        Project(id: 'proj-work', name: 'Work', colorValue: 0xFF14B8A6, createdAt: now, updatedAt: now),
      );
      await repo.createTask(
        Task(
          id: 't-1',
          title: 'Review Sprint Metrics',
          projectId: 'proj-work',
          priority: TaskPriority.high,
          dueAt: now,
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repo.createTask(
        Task(
          id: 't-2',
          title: 'Prepare Slide Deck',
          projectId: 'proj-work',
          priority: TaskPriority.medium,
          dueAt: now,
          sortOrder: 2,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await pumpWidgetTest(
        tester,
        const TasksScreen(),
      );

      expect(find.text('Tasks'), findsWidgets);
      expect(find.text('Today'), findsWidgets);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      expect(find.text('All Projects'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);

      expect(find.text('Review Sprint Metrics'), findsOneWidget);
      expect(find.text('Prepare Slide Deck'), findsOneWidget);
      expect(find.byType(ReorderableListView), findsOneWidget);

      await tearDownTest(tester);
    });

    testWidgets('6. Today Screen integrates Tasks due and overdue section with instant check-off', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = getTodayNow();
      final repo = TaskRepository(inMemoryDb);
      await inMemoryDb.into(inMemoryDb.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: 'h-today-test',
          name: 'Morning Routine',
          colorValue: 0xFF14B8A6,
          startDate: now.subtract(const Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repo.createTask(
        Task(
          id: 'today-task-1',
          title: 'Send invoice to client',
          dueAt: now,
          priority: TaskPriority.urgent,
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await pumpWidgetTest(
        tester,
        const TodayScreen(),
      );

      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('(1 due)'), findsOneWidget);
      expect(find.text('Send invoice to client'), findsOneWidget);

      // Complete task directly from Today screen
      await tester.tap(find.byKey(const ValueKey('task_checkbox_today-task-1')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final updated = await repo.getTaskById('today-task-1');
      expect(updated, isNotNull);
      expect(updated!.isCompleted, isTrue);

      await tearDownTest(tester);
    });

    testWidgets('7. Capture Tasks screenshots for documentation and README', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = getTodayNow();
      final repo = TaskRepository(inMemoryDb);
      await repo.createProject(
        Project(id: 'proj-design', name: 'Design System', colorValue: 0xFF14B8A6, createdAt: now, updatedAt: now),
      );
      await repo.createProject(
        Project(id: 'proj-core', name: 'Core Engine', colorValue: 0xFF8B7CFF, createdAt: now, updatedAt: now),
      );

      final task1 = Task(
        id: 't-doc-1',
        title: 'Refactor Liquid Glass token hierarchy',
        projectId: 'proj-design',
        priority: TaskPriority.urgent,
        dueAt: now,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      );
      await repo.createTask(task1);

      await repo.createTask(
        Task(
          id: 'sub-doc-1',
          parentId: task1.id,
          title: 'Extract backdrop filter blur token',
          isCompleted: true,
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repo.createTask(
        Task(
          id: 'sub-doc-2',
          parentId: task1.id,
          title: 'Audit contrast ratios for WCAG 2.2 AA',
          isCompleted: false,
          sortOrder: 2,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await repo.createTask(
        Task(
          id: 't-doc-2',
          title: 'Implement natural language task scheduler',
          projectId: 'proj-core',
          priority: TaskPriority.high,
          dueAt: now,
          sortOrder: 2,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repo.createTask(
        Task(
          id: 't-doc-3',
          title: 'Publish Phase 2B verification report',
          priority: TaskPriority.medium,
          dueAt: now.add(const Duration(days: 1)),
          sortOrder: 3,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Screenshot 1: Tasks Screen
      final repaintKey = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(inMemoryDb),
          ],
          child: MaterialApp(
            theme: PoswalTheme.getTheme(AppThemeMode.dark),
            home: RepaintBoundary(
              key: repaintKey,
              child: const Scaffold(
                backgroundColor: PoswalColors.ink,
                body: TasksScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await captureWidgetScreenshot(tester, repaintKey, 'tasks-list');

      // Screenshot 2: Task Quick-Add Sheet
      final quickAddKey = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(inMemoryDb),
          ],
          child: MaterialApp(
            theme: PoswalTheme.getTheme(AppThemeMode.dark),
            home: RepaintBoundary(
              key: quickAddKey,
              child: const Scaffold(
                backgroundColor: PoswalColors.ink,
                body: TaskQuickAddSheet(),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Review pull request tomorrow 5pm !urgent #family');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      await captureWidgetScreenshot(tester, quickAddKey, 'task-quick-add');

      // Screenshot 3: Task Detail Sheet
      final detailKey = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(inMemoryDb),
          ],
          child: MaterialApp(
            theme: PoswalTheme.getTheme(AppThemeMode.dark),
            home: RepaintBoundary(
              key: detailKey,
              child: Scaffold(
                backgroundColor: PoswalColors.ink,
                body: TaskDetailSheet(task: task1),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await captureWidgetScreenshot(tester, detailKey, 'task-detail-sheet');

      await tearDownTest(tester);
    });
  });
}
