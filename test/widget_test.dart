import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_detail_screen.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_form_sheet.dart';
import 'package:poswal_orbit/features/habits/presentation/habits_screen.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_checkin_sheet.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_heatmap.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_month_calendar.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_stats_charts.dart';
import 'package:poswal_orbit/features/onboarding/application/onboarding_providers.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/features/today/presentation/today_screen.dart';
import 'package:poswal_orbit/features/today/presentation/widgets/hero_orbit_card.dart';
import 'package:poswal_orbit/main.dart';

class _MockOnboardingNotifier extends OnboardingNotifier {
  @override
  bool build() => true;
}

void main() {
  late AppDatabase inMemoryDb;

  Future<void> seedDatabase(AppDatabase db) async {
    const boundary = DateBoundary(dayStartHour: 4);
    final logicalToday = boundary.getAppDate(DateTime.now());
    final now = logicalToday.add(const Duration(hours: 12));
    final todayStr = DateBoundary.toDateString(logicalToday);

    // Habit 1: Morning Meditation (Done today)
    await db.into(db.habitsTable).insert(
      HabitsTableCompanion.insert(
        id: 'h-meditation',
        name: 'Morning Meditation',
        iconName: const Value('sparkle'),
        colorValue: 0xFF14B8A6,
        habitType: const Value('yesNo'),
        timeOfDay: const Value('morning'),
        scheduleType: const Value('daily'),
        startDate: now.subtract(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await db.into(db.habitEntriesTable).insert(
      HabitEntriesTableCompanion.insert(
        id: 'entry-meditation',
        habitId: 'h-meditation',
        entryDate: todayStr,
        status: const Value('done'),
        value: const Value(1.0),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Habit 2: Drink 8 Glasses (Numeric, 4/8 done)
    await db.into(db.habitsTable).insert(
      HabitsTableCompanion.insert(
        id: 'h-water',
        name: 'Drink Water',
        iconName: const Value('drop'),
        colorValue: 0xFF0284C7,
        habitType: const Value('numeric'),
        targetValue: const Value(8.0),
        unit: const Value('glasses'),
        timeOfDay: const Value('anytime'),
        scheduleType: const Value('daily'),
        startDate: now.subtract(const Duration(days: 3)),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Habit 3: Read 20 Mins (Evening, Pending)
    await db.into(db.habitsTable).insert(
      HabitsTableCompanion.insert(
        id: 'h-read',
        name: 'Read 20 Mins',
        iconName: const Value('book'),
        colorValue: 0xFF8B7CFF,
        habitType: const Value('yesNo'),
        timeOfDay: const Value('evening'),
        scheduleType: const Value('daily'),
        startDate: now.subtract(const Duration(days: 10)),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    inMemoryDb = AppDatabase(NativeDatabase.memory());
    await seedDatabase(inMemoryDb);
  });

  Future<GlobalKey> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    final repaintKey = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(inMemoryDb),
          onboardingCompletedProvider.overrideWith(_MockOnboardingNotifier.new),
        ],
        child: RepaintBoundary(
          key: repaintKey,
          child: const PoswalOrbitApp(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    return repaintKey;
  }

  Future<void> tearDownApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() async {
      await inMemoryDb.close();
    });
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  Future<void> capture(WidgetTester tester, GlobalKey repaintKey, String name) async {
    if (Platform.environment['UPDATE_SCREENSHOTS'] != 'true') return;
    await tester.runAsync(() async {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final file = File('docs/screenshots/$name.png');
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(byteData.buffer.asUint8List());
        }
      }
    });
  }

  group('Poswal Orbit Widget Test Suite', () {
    testWidgets('1. Today Screen displays habit cards, progress ring and floating tab bar', (WidgetTester tester) async {
      final key = await pumpApp(tester);

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.byType(HeroOrbitCard), findsOneWidget);
      expect(find.text('Morning Meditation'), findsOneWidget);
      expect(find.text('Drink Water'), findsOneWidget);
      expect(find.text('Read 20 Mins'), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Tasks'), findsWidgets);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Insights'), findsOneWidget);

      await capture(tester, key, 'today-dark');
      await tearDownApp(tester);
    });

    testWidgets('2. Long press habit card opens HabitCheckinSheet with status, stepper & notes', (WidgetTester tester) async {
      final key = await pumpApp(tester);

      await tester.longPress(find.text('Drink Water'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(HabitCheckinSheet), findsOneWidget);
      expect(find.text('Check-in status'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Missed'), findsOneWidget);

      await capture(tester, key, 'habit-checkin-sheet');

      // Close sheet
      await tester.tap(find.byIcon(PhosphorIconsRegular.x));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(HabitCheckinSheet), findsNothing);
      await tearDownApp(tester);
    });

    testWidgets('3. Tapping habit card navigates to HabitDetailScreen with stats, heatmap, calendar & charts', (WidgetTester tester) async {
      final key = await pumpApp(tester);

      await tester.tap(find.text('Morning Meditation'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(HabitDetailScreen), findsOneWidget);
      expect(find.text('Current streak'), findsOneWidget);
      expect(find.text('Best streak'), findsOneWidget);
      expect(find.text('Habit score'), findsOneWidget);
      expect(find.byType(HabitHeatmap), findsOneWidget);
      expect(find.byType(HabitMonthCalendar), findsOneWidget);

      await capture(tester, key, 'habit-detail-dark');

      // Scroll down to reveal Weekly Performance Bars and Trend Line
      await tester.drag(find.byType(HabitDetailScreen), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.byType(HabitWeeklyBars), findsOneWidget);
      expect(find.byType(HabitTrendLine), findsOneWidget);

      // Scroll back up and navigate back
      await tester.drag(find.byType(HabitDetailScreen), const Offset(0, 600));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(PhosphorIconsRegular.arrowLeft));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(HabitDetailScreen), findsNothing);
      expect(find.byType(TodayScreen), findsOneWidget);
      await tearDownApp(tester);
    });

    testWidgets('4. FAB button opens HabitFormSheet create flow with live preview', (WidgetTester tester) async {
      final key = await pumpApp(tester);

      await tester.tap(find.byKey(const ValueKey('app_fab_button')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(HabitFormSheet), findsOneWidget);
      expect(find.text('Create Habit'), findsAtLeastNWidgets(1));
      expect(find.text('Live Preview'), findsOneWidget);

      await capture(tester, key, 'habit-create-sheet');

      await tester.tap(find.byIcon(PhosphorIconsRegular.x));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(HabitFormSheet), findsNothing);
      await tearDownApp(tester);
    });

    testWidgets('5. Habits screen supports Active vs Archived segmented filtering', (WidgetTester tester) async {
      final key = await pumpApp(tester);

      await tester.tap(find.text('Habits'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(HabitsScreen), findsOneWidget);
      expect(find.textContaining('Active ('), findsOneWidget);
      expect(find.textContaining('Archived ('), findsOneWidget);
      await capture(tester, key, 'habits-list');

      // Switch to Archived tab
      await tester.tap(find.textContaining('Archived ('));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('No Archived Habits'), findsOneWidget);

      // Switch back to Active tab
      await tester.tap(find.textContaining('Active ('));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Morning Meditation'), findsOneWidget);

      await tearDownApp(tester);
    });

    testWidgets('6. Dynamic theme switching toggles between Dark and Light mode', (WidgetTester tester) async {
      final key = await pumpApp(tester);

      final element = tester.element(find.byType(PoswalOrbitApp));
      final container = ProviderScope.containerOf(element);
      container.read(appThemeModeProvider.notifier).setMode(AppThemeMode.light);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      await capture(tester, key, 'today-light');

      // Verify still rendered properly in Light theme
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.text('Morning Meditation'), findsOneWidget);

      await tearDownApp(tester);
    });
  });
}
