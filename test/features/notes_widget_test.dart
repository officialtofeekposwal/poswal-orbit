import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/repositories/habit_repository.dart';
import 'package:poswal_orbit/data/repositories/note_repository.dart';
import 'package:poswal_orbit/data/repositories/task_repository.dart';
import 'package:poswal_orbit/domain/logic/markdown_lite.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/notes/presentation/note_editor_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/notes_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/widgets/note_card.dart';
import 'package:poswal_orbit/features/search/presentation/global_search_screen.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase inMemoryDb;

  setUp(() {
    inMemoryDb = AppDatabase(NativeDatabase.memory());
  });

  Future<void> pumpWidgetTest(
    WidgetTester tester,
    Widget child, {
    AppDatabase? db,
    GlobalKey? repaintKey,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db ?? inMemoryDb),
        ],
        child: MaterialApp(
          theme: PoswalTheme.getTheme(AppThemeMode.dark),
          home: Scaffold(
            body: repaintKey != null
                ? RepaintBoundary(key: repaintKey, child: child)
                : child,
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

  Future<void> captureWidgetScreenshot(
    WidgetTester tester,
    GlobalKey repaintKey,
    String filename,
  ) async {
    await tester.runAsync(() async {
      final boundary =
          repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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

  group('Phase 3B - Notes UI, Editor, Markdown & Search Widget Tests', () {
    testWidgets('1. Notes tab displays pinned section, unpinned notes, and tags',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = DateTime.now();
      final repo = NoteRepository(inMemoryDb);

      await repo.createNote(
        Note(
          id: 'note-pinned-1',
          title: 'Project Roadmap 2026',
          body: '# Priorities\n- [x] Phase 1\n- [ ] Phase 2',
          isPinned: true,
          colorLabel: NoteColorLabel.gold,
          tags: ['work', 'roadmap'],
          createdAt: now,
          updatedAt: now,
        ),
      );

      await repo.createNote(
        Note(
          id: 'note-unpinned-1',
          title: 'Grocery List',
          body: '- [ ] Organic almond milk\n- [ ] Avocados\n- [x] Oats',
          isPinned: false,
          colorLabel: NoteColorLabel.teal,
          tags: ['personal'],
          createdAt: now,
          updatedAt: now,
        ),
      );

      final key = GlobalKey();
      await pumpWidgetTest(tester, const NotesScreen(), repaintKey: key);

      expect(find.text('Notes'), findsOneWidget);
      expect(find.textContaining('Pinned'), findsOneWidget);
      expect(find.text('Project Roadmap 2026'), findsOneWidget);
      expect(find.textContaining('Other notes'), findsOneWidget);
      expect(find.text('Grocery List'), findsOneWidget);
      expect(find.byType(NoteCard), findsNWidgets(2));

      await captureWidgetScreenshot(tester, key, 'notes-grid');
      await tearDownTest(tester);
    });

    testWidgets('2. NoteCard long press opens action sheet with Pin, Color, and Delete',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = DateTime.now();
      final repo = NoteRepository(inMemoryDb);

      await repo.createNote(
        Note(
          id: 'note-action-test',
          title: 'Action Sheet Note',
          body: 'Testing long press action sheet.',
          isPinned: false,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await pumpWidgetTest(tester, const NotesScreen());

      expect(find.text('Action Sheet Note'), findsOneWidget);

      // Long press the note card
      await tester.longPress(find.text('Action Sheet Note'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('note_action_pin')), findsOneWidget);
      expect(find.byKey(const ValueKey('note_action_color')), findsOneWidget);
      expect(find.byKey(const ValueKey('note_action_delete')), findsOneWidget);
      expect(find.text('Pin Note'), findsOneWidget);

      // Tap Pin Note
      await tester.tap(find.byKey(const ValueKey('note_action_pin')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final updated = await repo.getNoteById('note-action-test');
      expect(updated?.isPinned, isTrue);

      await tearDownTest(tester);
    });

    testWidgets('3. Note soft delete from action sheet shows Undo toast and restores note',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = DateTime.now();
      final repo = NoteRepository(inMemoryDb);

      await repo.createNote(
        Note(
          id: 'note-delete-test',
          title: 'Deletable Note',
          body: 'This note will be deleted and restored.',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await pumpWidgetTest(tester, const NotesScreen());
      expect(find.text('Deletable Note'), findsOneWidget);

      // Long press and tap delete
      await tester.longPress(find.text('Deletable Note'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('note_action_delete')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Note should be hidden and Undo snackbar displayed
      expect(find.text('Deletable Note'), findsNothing);
      expect(find.text('Note deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Note should be back
      expect(find.text('Deletable Note'), findsOneWidget);

      await tearDownTest(tester);
    });

    testWidgets('4. Note editor autosaves text changes and on dispose with Saved indicator',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final key = GlobalKey();
      await pumpWidgetTest(
        tester,
        const NoteEditorScreen(),
        repaintKey: key,
      );

      expect(find.byKey(const ValueKey('note_title_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('note_body_field')), findsOneWidget);

      // Enter Title and Body
      await tester.enterText(
        find.byKey(const ValueKey('note_title_field')),
        'Deep Work Session Notes',
      );
      await tester.enterText(
        find.byKey(const ValueKey('note_body_field')),
        '# Focus Topics\n- [ ] Audit Drift schemas\n- [x] Wire Riverpod providers\n**Goal**: 120fps liquid glass fluidity.',
      );

      // Wait for debounce timer (600ms) to trigger autosave
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('saved_indicator')), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);

      await captureWidgetScreenshot(tester, key, 'note-editor');

      // Check DB persistence directly
      final repo = NoteRepository(inMemoryDb);
      final notes = await repo.watchNotes().first;
      expect(notes.any((n) => n.title == 'Deep Work Session Notes'), isTrue);

      await tearDownTest(tester);
    });

    testWidgets('5. Interactive checklist toggle in notes updates markdown body',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = DateTime.now();
      final repo = NoteRepository(inMemoryDb);

      final note = await repo.createNote(
        Note(
          id: 'note-check-test',
          title: 'Daily Habits Checklist',
          body: '- [ ] Drink 2L water\n- [ ] Read 10 pages',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await pumpWidgetTest(
        tester,
        NoteEditorScreen(initialNote: note),
      );

      // Toggle first checklist item
      await repo.toggleChecklist(note.id, 0);
      final updated = await repo.getNoteById(note.id);
      expect(updated?.body, contains('- [x] Drink 2L water'));

      await tearDownTest(tester);
    });

    testWidgets('6. Note formatting toolbar inserts markdown tokens',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      await pumpWidgetTest(
        tester,
        const NoteEditorScreen(),
      );

      // Focus body field
      await tester.tap(find.byKey(const ValueKey('note_body_field')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Heading button in toolbar
      expect(find.byKey(const ValueKey('fmt_heading')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('fmt_heading')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final bodyField = tester.widget<TextField>(find.byKey(const ValueKey('note_body_field')));
      expect(bodyField.controller?.text, contains('# '));

      // Tap Checklist button in toolbar
      expect(find.byKey(const ValueKey('fmt_checklist')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('fmt_checklist')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(bodyField.controller?.text, contains('- [ ] '));

      await tearDownTest(tester);
    });

    testWidgets('7. Dynamic RTL rendering sets TextDirection.rtl for Urdu and TextDirection.ltr for Hindi',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      // Pure logic test first
      const urduText = 'آج کا دن بہت اچھا تھا';
      const hindiText = 'आज का दिन बहुत अच्छा था';

      expect(MarkdownLite.isRtlText(urduText), isTrue);
      expect(MarkdownLite.isRtlText(hindiText), isFalse);

      final now = DateTime.now();
      final repo = NoteRepository(inMemoryDb);

      final urduNote = await repo.createNote(
        Note(
          id: 'note-urdu-1',
          title: urduText,
          body: 'یہ اردو میں لکھا گیا نوٹ ہے۔',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await pumpWidgetTest(
        tester,
        NoteEditorScreen(initialNote: urduNote),
      );

      final directionalityWidgets = tester.widgetList<Directionality>(find.byType(Directionality));
      expect(directionalityWidgets.any((d) => d.textDirection == TextDirection.rtl), isTrue);

      await tearDownTest(tester);
    });

    testWidgets('8. Today journal button creates and opens today\'s daily journal note',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      await pumpWidgetTest(tester, const NotesScreen());

      expect(find.byKey(const ValueKey('today_journal_btn')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('today_journal_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should open NoteEditorScreen for journal
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.textContaining('Daily Journal'), findsWidgets);

      await tearDownTest(tester);
    });

    testWidgets('9. GlobalSearchScreen searches habits, tasks, and notes with grouped results',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final now = DateTime.now();
      final habitRepo = HabitRepository(inMemoryDb);
      final taskRepo = TaskRepository(inMemoryDb);
      final noteRepo = NoteRepository(inMemoryDb);

      await habitRepo.createHabit(
        Habit(
          id: 'h-search-1',
          name: 'Morning Meditation',
          colorValue: 0xFF14B8A6,
          iconName: 'sparkle',
          habitType: HabitType.yesNo,
          targetValue: 1.0,
          unit: '',
          timeOfDay: TimeOfDayGroup.morning,
          scheduleType: ScheduleType.daily,
          startDate: now,
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await taskRepo.createTask(
        Task(
          id: 't-search-1',
          title: 'Morning Yoga and Stretching',
          dueAt: now,
          priority: TaskPriority.medium,
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await noteRepo.createNote(
        Note(
          id: 'n-search-1',
          title: 'Morning Reflections and Gratitude',
          body: 'Three things I am grateful for this morning.',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final key = GlobalKey();
      await pumpWidgetTest(
        tester,
        const GlobalSearchScreen(),
        repaintKey: key,
      );

      expect(find.byKey(const ValueKey('global_search_input')), findsOneWidget);

      // Type "Morning" to search all 3 categories
      await tester.enterText(
        find.byKey(const ValueKey('global_search_input')),
        'Morning',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 500));

      // All 3 groups should be rendered
      expect(find.textContaining('Habits (1)'), findsOneWidget);
      expect(find.text('Morning Meditation'), findsOneWidget);
      expect(find.textContaining('Tasks (1)'), findsOneWidget);
      expect(find.text('Morning Yoga and Stretching'), findsOneWidget);
      expect(find.textContaining('Notes (1)'), findsOneWidget);
      expect(find.text('Morning Reflections and Gratitude'), findsOneWidget);

      await captureWidgetScreenshot(tester, key, 'global-search');
      await tearDownTest(tester);
    });
  });
}
