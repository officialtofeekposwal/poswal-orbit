import 'package:drift/drift.dart' show driftRuntimeOptions, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/features/insights/presentation/insights_screen.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase inMemoryDb;

  setUp(() {
    inMemoryDb = AppDatabase(NativeDatabase.memory());
  });

  Future<void> pumpInsightsTest(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(inMemoryDb),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: PoswalTheme.getTheme(AppThemeMode.dark),
          home: const Scaffold(
            body: InsightsScreen(),
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

  group('Insights Screen Widget Tests', () {
    testWidgets('1. Insights tab renders calm friendly empty state when there is no activity', (tester) async {
      await pumpInsightsTest(tester);

      expect(find.byKey(const ValueKey('insights_empty_state_card')), findsOneWidget);
      expect(find.text('Your insights will grow as you go'), findsOneWidget);
      expect(find.byKey(const ValueKey('share_insights_button')), findsNothing);

      await tearDownTest(tester);
    });

    testWidgets('2. Insights tab renders full weekly review, productivity score and momentum cards when data exists', (tester) async {
      final now = DateTime.now();

      // Seed a habit
      await inMemoryDb.into(inMemoryDb.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: 'habit_1',
          name: 'Morning Meditation',
          colorValue: 0xFF14B8A6,
          startDate: DateTime(now.year, now.month, now.day - 7),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Seed a completed habit entry
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await inMemoryDb.into(inMemoryDb.habitEntriesTable).insert(
        HabitEntriesTableCompanion.insert(
          id: 'entry_1',
          habitId: 'habit_1',
          entryDate: todayStr,
          status: const Value('done'),
          value: const Value(1.0),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Seed a completed task
      await inMemoryDb.into(inMemoryDb.tasksTable).insert(
        TasksTableCompanion.insert(
          id: 'task_1',
          title: 'Ship Phase 5A',
          isCompleted: const Value(true),
          completedAt: Value(now),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await pumpInsightsTest(tester);

      // Verify that full data view rendered on Overview tab
      expect(find.byKey(const ValueKey('insights_weekly_review_card')), findsOneWidget);
      expect(find.byKey(const ValueKey('insights_productivity_score_card')), findsOneWidget);
      expect(find.byKey(const ValueKey('insights_correlation_card')), findsOneWidget);
      expect(find.byKey(const ValueKey('insights_overall_heatmap_card')), findsOneWidget);
      expect(find.byKey(const ValueKey('share_insights_button')), findsOneWidget);

      // Tap Timing tab to verify timing card
      await tester.tap(find.byKey(const ValueKey('insights_tab_timing')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('insights_best_timing_card')), findsOneWidget);

      await tearDownTest(tester);
    });

    testWidgets('3. Weekly review card shows non-guilt encouraging message and metrics', (tester) async {
      final now = DateTime.now();
      await inMemoryDb.into(inMemoryDb.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: 'h2',
          name: 'Evening Reading',
          colorValue: 0xFF8B7CFF,
          startDate: DateTime(now.year, now.month, now.day - 5),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await inMemoryDb.into(inMemoryDb.habitEntriesTable).insert(
        HabitEntriesTableCompanion.insert(
          id: 'e2',
          habitId: 'h2',
          entryDate: todayStr,
          status: const Value('done'),
          value: const Value(1.0),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await pumpInsightsTest(tester);

      expect(find.text('Weekly review'), findsOneWidget);
      expect(find.text('Productivity Score'), findsOneWidget);

      // Tap Timing tab to inspect timing details
      await tester.tap(find.byKey(const ValueKey('insights_tab_timing')));
      await tester.pumpAndSettle();
      expect(find.text('Best Day of Week'), findsOneWidget);

      await tearDownTest(tester);
    });

    testWidgets('4. Insights tab renders per-habit heatmaps with habit names as titles', (tester) async {
      final now = DateTime.now();
      await inMemoryDb.into(inMemoryDb.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: 'habit_run',
          name: 'Morning Run',
          colorValue: 0xFF14B8A6,
          startDate: DateTime(now.year, now.month, now.day - 7),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await inMemoryDb.into(inMemoryDb.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: 'habit_read',
          name: 'Read Philosophy',
          colorValue: 0xFF3B82F6,
          startDate: DateTime(now.year, now.month, now.day - 7),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await inMemoryDb.into(inMemoryDb.habitEntriesTable).insert(
        HabitEntriesTableCompanion.insert(
          id: 'e_run',
          habitId: 'habit_run',
          entryDate: todayStr,
          status: const Value('done'),
          value: const Value(1.0),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await pumpInsightsTest(tester);

      // Tap Habits tab
      await tester.tap(find.byKey(const ValueKey('insights_tab_habits')));
      await tester.pumpAndSettle();

      expect(find.text('Habit Heatmaps'), findsOneWidget);
      expect(find.text('Morning Run'), findsOneWidget);

      // Expand Morning Run row to reveal heatmap
      await tester.tap(find.byKey(const ValueKey('habit_row_habit_run')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('habit_heatmap_habit_run')), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Read Philosophy'), findsOneWidget);

      // Expand Read Philosophy row to reveal heatmap
      await tester.tap(find.byKey(const ValueKey('habit_row_habit_read')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('habit_heatmap_habit_read')), findsOneWidget);

      await tearDownTest(tester);
    });
  });
}
