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
import 'package:poswal_orbit/features/habits/presentation/habit_form_sheet.dart';
import 'package:poswal_orbit/features/habits/presentation/habits_screen.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/features/today/presentation/today_screen.dart';
import 'package:poswal_orbit/features/today/presentation/widgets/hero_orbit_card.dart';
import 'package:poswal_orbit/main.dart';

void main() {
  late AppDatabase inMemoryDb;

  setUp(() async {
    inMemoryDb = AppDatabase(NativeDatabase.memory());

    // Seed test habits for Today Screen
    final now = DateTime.now();
    final todayStr = DateBoundary.toDateString(now);

    // Habit 1: Morning Meditation (Done today)
    await inMemoryDb.into(inMemoryDb.habitsTable).insert(
      HabitsTableCompanion.insert(
        id: 'h-meditation',
        name: 'Morning Meditation',
        iconName: const Value('sparkle'),
        colorValue: 0xFF14B8A6, // Teal
        habitType: const Value('yesNo'),
        timeOfDay: const Value('morning'),
        scheduleType: const Value('daily'),
        startDate: now.subtract(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await inMemoryDb.into(inMemoryDb.habitEntriesTable).insert(
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
    await inMemoryDb.into(inMemoryDb.habitsTable).insert(
      HabitsTableCompanion.insert(
        id: 'h-water',
        name: 'Drink Water',
        iconName: const Value('drop'),
        colorValue: 0xFF0284C7, // Sky
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
    await inMemoryDb.into(inMemoryDb.habitsTable).insert(
      HabitsTableCompanion.insert(
        id: 'h-read',
        name: 'Read 20 Mins',
        iconName: const Value('book'),
        colorValue: 0xFF8B7CFF, // Violet
        habitType: const Value('yesNo'),
        timeOfDay: const Value('evening'),
        scheduleType: const Value('daily'),
        startDate: now.subtract(const Duration(days: 10)),
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() async {
    // Database lifecycle managed within test via runAsync
  });

  testWidgets('Phase 1 AppShell, Today Screen, Habits & Screenshots', (WidgetTester tester) async {
    // Set fixed portrait screen size matching modern mobile viewport (1080 x 2400 @ 2.0 ratio = 540 x 1200)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repaintKey = GlobalKey();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(inMemoryDb),
        ],
        child: RepaintBoundary(
          key: repaintKey,
          child: const PoswalOrbitApp(),
        ),
      ),
    );

    // Allow async DB streams and animations to settle
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    Future<void> capture(String name) async {
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

    // 1. Verify Today Screen Components
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(HeroOrbitCard), findsOneWidget);
    expect(find.text('Morning Meditation'), findsOneWidget);
    expect(find.text('Drink Water'), findsOneWidget);
    expect(find.text('Read 20 Mins'), findsOneWidget);

    // Verify Habit Progress "1 of 3"
    expect(find.text('1 of 3'), findsOneWidget);

    // Verify Floating Glass Tab Bar
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);

    // Capture Dark Mode Today Screen
    await capture('today-dark');

    // 2. Open Create Habit Sheet via Floating '+' FAB
    await tester.tap(find.byKey(const ValueKey('app_fab_button')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify Create Habit Sheet is visible
    expect(find.byType(HabitFormSheet), findsOneWidget);
    expect(find.text('Create Habit'), findsAtLeastNWidgets(1));
    expect(find.text('Live Preview'), findsOneWidget);

    // Capture Create Habit Sheet
    await capture('habit-create-sheet');

    // Close the sheet
    await tester.tap(find.byIcon(PhosphorIconsRegular.x));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // 3. Switch to Habits Tab (Tab 1)
    await tester.tap(find.text('Habits'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(HabitsScreen), findsOneWidget);
    await capture('habits-list');

    // 4. Test Light Mode
    final element = tester.element(find.byType(PoswalOrbitApp));
    final container = ProviderScope.containerOf(element);
    container.read(appThemeModeProvider.notifier).setMode(AppThemeMode.light);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Switch back to Today tab
    await tester.tap(find.text('Today'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await capture('today-light');

    // Cleanly unmount and drain stream query timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() async {
      await inMemoryDb.close();
    });
  });
}
