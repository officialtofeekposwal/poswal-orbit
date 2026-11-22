import 'dart:io';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_list_section.dart';
import 'package:poswal_orbit/core/widgets/app_search_field.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/services/data_safety_service.dart';
import 'package:poswal_orbit/features/insights/presentation/insights_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/note_editor_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/notes_screen.dart';
import 'package:poswal_orbit/features/playground/presentation/design_playground_screen.dart';
import 'package:poswal_orbit/features/settings/presentation/settings_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/tasks_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_quick_add_sheet.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/features/today/presentation/today_screen.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class _TrueReduceTransparencyNotifier extends ReduceTransparencyNotifier {
  @override
  bool build() => true;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase inMemoryDb;
  late Directory tempBackupDir;

  setUp(() async {
    inMemoryDb = AppDatabase(NativeDatabase.memory());
    tempBackupDir = await Directory.systemTemp.createTemp('h3_design_test_');
  });

  Future<void> pumpApp(
    WidgetTester tester,
    Widget child, {
    AppThemeMode mode = AppThemeMode.dark,
    Size size = const Size(430, 932),
    bool highContrast = false,
    List<dynamic> additionalOverrides = const [],
  }) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(inMemoryDb),
          dataSafetyServiceProvider.overrideWithValue(DataSafetyService(inMemoryDb, tempBackupDir)),
          for (final o in additionalOverrides) o,
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: PoswalTheme.getTheme(mode),
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              highContrast: highContrast,
            ),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tearDownTest(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.runAsync(() async {
      await inMemoryDb.close();
      try {
        if (await tempBackupDir.exists()) {
          await tempBackupDir.delete(recursive: true);
        }
      } catch (_) {}
    });
  }

  group('Gate H3 - Design System & Component Verification', () {
    testWidgets('1. Top trailing "+" on TasksScreen opens TaskQuickAddSheet', (tester) async {
      await pumpApp(tester, const TasksScreen());

      final addBtnFinder = find.byKey(const ValueKey('tasks_toolbar_add_btn'));
      expect(addBtnFinder, findsOneWidget);

      await tester.tap(addBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(TaskQuickAddSheet), findsOneWidget);
      await tearDownTest(tester);
    });

    testWidgets('2. Top trailing "+" on NotesScreen navigates to NoteEditorScreen', (tester) async {
      await pumpApp(tester, const NotesScreen());

      final addBtnFinder = find.byKey(const ValueKey('notes_toolbar_add_btn'));
      expect(addBtnFinder, findsOneWidget);

      await tester.tap(addBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(NoteEditorScreen), findsOneWidget);
      await tearDownTest(tester);
    });

    testWidgets('3. No FloatingActionButton exists on TasksScreen', (tester) async {
      await pumpApp(tester, const TasksScreen());
      expect(find.byType(FloatingActionButton), findsNothing);
      await tearDownTest(tester);
    });

    testWidgets('4. No FloatingActionButton exists on NotesScreen', (tester) async {
      await pumpApp(tester, const NotesScreen());
      expect(find.byType(FloatingActionButton), findsNothing);
      await tearDownTest(tester);
    });

    testWidgets('5. No FloatingActionButton exists on InsightsScreen', (tester) async {
      await pumpApp(tester, const InsightsScreen());
      expect(find.byType(FloatingActionButton), findsNothing);
      await tearDownTest(tester);
    });

    testWidgets('6. No FloatingActionButton exists on TodayScreen', (tester) async {
      await pumpApp(tester, const TodayScreen());
      expect(find.byType(FloatingActionButton), findsNothing);
      await tearDownTest(tester);
    });

    testWidgets('7. Inline AppSearchField expands, accepts input, clears, and collapses', (tester) async {
      await pumpApp(tester, const TasksScreen());

      // Initially search field is collapsed
      expect(find.byType(AppSearchField), findsNothing);

      // Tap search toggle button
      final searchToggleFinder = find.byKey(const ValueKey('tasks_search_toggle_btn'));
      expect(searchToggleFinder, findsOneWidget);
      await tester.tap(searchToggleFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now AppSearchField is visible
      expect(find.byType(AppSearchField), findsOneWidget);

      // Enter search query
      final inputFinder = find.byKey(const ValueKey('app_search_input'));
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'Buy milk');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Buy milk'), findsOneWidget);

      // Dismiss focus before collapse
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 50));

      // Tap search toggle again to collapse
      await tester.tap(searchToggleFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppSearchField), findsNothing);
      await tearDownTest(tester);
    });

    testWidgets('8. Settings screen shows NO playground_btn in visible UI list', (tester) async {
      await pumpApp(tester, const SettingsScreen(), size: const Size(800, 2400));
      expect(find.byKey(const ValueKey('playground_btn')), findsNothing);
      expect(find.text('Design Playground'), findsNothing);
      await tearDownTest(tester);
    });

    testWidgets('9. 7 taps on version tile unlocks Design Playground screen', (tester) async {
      await pumpApp(tester, const SettingsScreen(), size: const Size(800, 2400));

      final versionTileFinder = find.byKey(const ValueKey('settings_version_tile'));
      expect(versionTileFinder, findsOneWidget);

      for (int i = 0; i < 7; i++) {
        await tester.tap(versionTileFinder);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DesignPlaygroundScreen), findsOneWidget);
      await tearDownTest(tester);
    });

    testWidgets('10. Settings screen renders AppListSection with Title Case headers', (tester) async {
      await pumpApp(tester, const SettingsScreen(), size: const Size(800, 2400));

      expect(find.byType(AppListSection), findsWidgets);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Time & Orbit Boundary'), findsOneWidget);
      expect(find.text('Haptic Feedback'), findsWidgets);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Data Safety & Backups'), findsOneWidget);
      expect(find.text('Danger Zone'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      await tearDownTest(tester);
    });

    testWidgets('11. ReduceTransparency = true: Tasks and Notes render without error', (tester) async {
      await pumpApp(
        tester,
        const TasksScreen(),
        additionalOverrides: [
          reduceTransparencyProvider.overrideWith(_TrueReduceTransparencyNotifier.new),
        ],
      );
      expect(find.byType(TasksScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await pumpApp(
        tester,
        const NotesScreen(),
        additionalOverrides: [
          reduceTransparencyProvider.overrideWith(_TrueReduceTransparencyNotifier.new),
        ],
      );
      expect(find.byType(NotesScreen), findsOneWidget);
      await tearDownTest(tester);
    });

    testWidgets('12. High contrast media query: TodayScreen renders without error', (tester) async {
      await pumpApp(tester, const TodayScreen(), highContrast: true);
      expect(find.byType(TodayScreen), findsOneWidget);
      await tearDownTest(tester);
    });
  });
}
