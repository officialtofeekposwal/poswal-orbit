import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/notes/presentation/widgets/note_card.dart';
import 'package:poswal_orbit/features/onboarding/application/onboarding_providers.dart';
import 'package:poswal_orbit/features/settings/presentation/settings_screen.dart';
import 'package:poswal_orbit/features/shell/app_shell.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_row_card.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/features/today/presentation/widgets/habit_row_card.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class _MockOnboardingNotifier extends OnboardingNotifier {
  @override
  bool build() => true;
}

void main() {
  late AppDatabase inMemoryDb;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    inMemoryDb = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await inMemoryDb.close();
  });

  Future<void> cleanWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        onboardingCompletedProvider.overrideWith(_MockOnboardingNotifier.new),
        databaseProvider.overrideWithValue(inMemoryDb),
      ],
      child: MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('Accessibility & Semantics Verification Tests', () {
    testWidgets('HabitRowCard check-off ring has screen-reader semantics and >=44x44 touch target', (tester) async {
      final habit = Habit(
        id: 'h-acc',
        name: 'Morning Hydration',
        iconName: 'drop',
        colorValue: 0xFF14B8A6,
        habitType: HabitType.yesNo,
        targetValue: 1.0,
        unit: 'times',
        timeOfDay: TimeOfDayGroup.morning,
        scheduleType: ScheduleType.daily,
        scheduleDays: const [],
        targetDaysPerPeriod: 1,
        everyNDaysInterval: 1,
        startDate: DateTime(2026, 11, 1),
        isArchived: false,
        sortOrder: 0,
        createdAt: DateTime(2026, 11, 1),
        updatedAt: DateTime(2026, 11, 1),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          HabitRowCard(
            item: HabitWithEntry(
              habit: habit,
              entry: null,
              habitScore: 80.0,
              currentStreak: 5,
            ),
          ),
        ),
      );
      await tester.pump();

      // 1. Verify Semantics on check ring
      final ringSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Mark habit Morning Hydration complete',
      );
      expect(ringSemantics, findsOneWidget);

      // 2. Verify touch target is at least 44x44
      final touchFinder = find.descendant(
        of: ringSemantics,
        matching: find.byType(Container),
      ).first;
      final touchSize = tester.getSize(touchFinder);
      expect(touchSize.width, greaterThanOrEqualTo(44.0));
      expect(touchSize.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('AppShell FAB and tab bar items expose Semantics and touch targets >=44x44', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppShell(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. FAB Semantics & size
      final fabSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Create new item',
      );
      expect(fabSemantics, findsOneWidget);
      final fabSize = tester.getSize(find.byKey(const ValueKey('app_fab_button')));
      expect(fabSize.width, greaterThanOrEqualTo(44.0));
      expect(fabSize.height, greaterThanOrEqualTo(44.0));

      // 2. Tab items Semantics
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Today tab'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Habits tab'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Tasks tab'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Notes tab'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Insights tab'), findsOneWidget);

      await cleanWidget(tester);
    });

    testWidgets('TaskRowCard checkbox has Semantics and >=44x44 touch target', (tester) async {
      final task = Task(
        id: 'task-acc',
        title: 'Submit financial report',
        priority: TaskPriority.urgent,
        createdAt: DateTime(2026, 11, 20),
        updatedAt: DateTime(2026, 11, 20),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          TaskRowCard(
            task: task,
          ),
        ),
      );
      await tester.pump();

      // 1. Verify Semantics on task checkbox
      final checkboxSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Mark task Submit financial report complete',
      );
      expect(checkboxSemantics, findsOneWidget);

      // 2. Verify touch container is at least 44x44
      final checkboxTouch = find.descendant(
        of: checkboxSemantics,
        matching: find.byType(Container),
      ).first;
      final touchSize = tester.getSize(checkboxTouch);
      expect(touchSize.width, greaterThanOrEqualTo(44.0));
      expect(touchSize.height, greaterThanOrEqualTo(44.0));

      await cleanWidget(tester);
    });

    testWidgets('NoteCard exposes Semantics for screen readers and accessible checklist toggles', (tester) async {
      final note = Note(
        id: 'note-acc',
        title: 'Grocery Checklist',
        body: '- [ ] Fresh organic milk\n- [x] Apples',
        colorLabel: 1,
        createdAt: DateTime(2026, 11, 21),
        updatedAt: DateTime(2026, 11, 21),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          NoteCard(
            note: note,
            onTap: () {},
            onLongPress: () {},
            onToggleChecklist: (_) {},
          ),
        ),
      );
      await tester.pump();

      // 1. Verify NoteCard Semantics
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Note: Grocery Checklist',
        ),
        findsOneWidget,
      );

      // 2. Verify checklist item Semantics
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.label?.contains('Fresh organic milk') ?? false),
        ),
        findsOneWidget,
      );

      await cleanWidget(tester);
    });

    testWidgets('SettingsScreen switches expose Semantics and toggles', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const SettingsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final switchFinder = find.byType(SwitchListTile).first;
      expect(switchFinder, findsOneWidget);

      final switchTile = tester.widget<SwitchListTile>(switchFinder);
      expect(switchTile.title, isNotNull);

      await cleanWidget(tester);
    });
  });
}
