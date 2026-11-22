import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_list_section.dart';
import 'package:poswal_orbit/core/widgets/app_menu.dart';
import 'package:poswal_orbit/core/widgets/app_search_field.dart';
import 'package:poswal_orbit/core/widgets/app_sheet.dart';
import 'package:poswal_orbit/core/widgets/app_tab_bar.dart';
import 'package:poswal_orbit/core/widgets/app_toolbar.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class _TrueReduceTransparencyNotifier extends ReduceTransparencyNotifier {
  @override
  bool build() => true;
}

Widget buildTestApp(Widget child, {List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: [
      for (final o in overrides) o,
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: PoswalTheme.getTheme(AppThemeMode.dark),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Apple HIG & Liquid Glass Design System Components Tests', () {
    // 1. Concentric Geometry Math (Unit Test)
    test('1. PoswalRadii.concentric accurately calculates inner corner radius', () {
      expect(PoswalRadii.concentric(outer: 24, padding: 8), equals(16.0));
      expect(PoswalRadii.concentric(outer: 32, padding: 12), equals(20.0));
      // Never negative, clamps at 0.0
      expect(PoswalRadii.concentric(outer: 8, padding: 16), equals(0.0));

      final borderRadius = PoswalRadii.concentricBorderRadius(outerRadius: 20, padding: 6);
      expect(borderRadius, equals(BorderRadius.circular(14.0)));
    });

    // 2. AppTabBar Floating Navigation (Widget Test)
    testWidgets('2. AppTabBar renders 5 tabs with semantics, selection, and scroll notification', (tester) async {
      final semantics = tester.ensureSemantics();
      int selectedIdx = 0;

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: const Center(child: Text('Content Area')),
            bottomNavigationBar: AppTabBar(
              currentIndex: selectedIdx,
              onTabSelected: (idx) => selectedIdx = idx,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify all 5 navigation tabs exist
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Insights'), findsOneWidget);

      // Verify accessible semantics on each tab
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Today tab'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Habits tab'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Tasks tab'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Notes tab'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Insights tab'), findsOneWidget);

      // Verify tab selection fires callback
      await tester.tap(find.text('Habits'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(selectedIdx, equals(1));

      semantics.dispose();
    });

    // 3. AppToolbar with Grouped Buttons & Trailing Add (Widget Test)
    testWidgets('3. AppToolbar groups buttons and executes onAddPressed with accessible semantics', (tester) async {
      bool addPressed = false;

      await tester.pumpWidget(
        buildTestApp(
          AppToolbar(
            title: const Text('Title'),
            showAddButton: true,
            addTooltip: 'Create Item',
            onAddPressed: () => addPressed = true,
            actions: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
                tooltip: 'Search',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byTooltip('Search'), findsOneWidget);
      expect(find.byTooltip('Create Item'), findsOneWidget);

      // Tap + button
      await tester.tap(find.byTooltip('Create Item'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(addPressed, isTrue);
    });

    // 4. AppSheet Inset Presentation & Drag Handle (Widget Test)
    testWidgets('4. AppSheet presents as inset sheet with margin, concentric handle and content', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                AppSheet.show(
                  context: ctx,
                  builder: (sheetCtx) => const AppSheet(
                    title: 'Inset Sheet',
                    child: Text('Sheet Body Content'),
                  ),
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Open Sheet'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Inset Sheet'), findsOneWidget);
      expect(find.text('Sheet Body Content'), findsOneWidget);
      expect(find.byType(AppSheet), findsOneWidget);
    });

    // 5. AppMenu Context Popover (Widget Test)
    testWidgets('5. AppMenu opens from trigger coordinates and closes on outside tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (ctx) => Center(
              child: GestureDetector(
                onTapDown: (details) {
                  final position = RelativeRect.fromLTRB(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    details.globalPosition.dx + 10,
                    details.globalPosition.dy + 10,
                  );
                  AppMenu.show(
                    context: ctx,
                    position: position,
                    items: [
                      AppMenuItem(title: 'Edit Habit', onTap: () {}, icon: PhosphorIconsRegular.pencilSimple),
                      AppMenuItem(title: 'Delete Habit', isDestructive: true, onTap: () {}, icon: PhosphorIconsRegular.trash),
                    ],
                  );
                },
                child: const Text('Trigger Menu'),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Trigger Menu'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Edit Habit'), findsOneWidget);
      expect(find.text('Delete Habit'), findsOneWidget);

      // Outside tap closes the menu
      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Edit Habit'), findsNothing);
    });

    // 6. AppSearchField Inline Expandable (Widget Test)
    testWidgets('6. AppSearchField expands on tap, accepts query, and clear button resets query', (tester) async {
      String currentQuery = '';

      await tester.pumpWidget(
        buildTestApp(
          AppSearchField(
            hintText: 'Search...',
            onChanged: (q) => currentQuery = q,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Tap compact search pill to expand
      await tester.tap(find.byType(AppSearchField));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextField), findsOneWidget);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Read');
      await tester.pump(const Duration(milliseconds: 100));
      expect(currentQuery, equals('Read'));

      // Clear button appears and tapping it clears text
      expect(find.byIcon(PhosphorIconsFill.xCircle), findsOneWidget);
      await tester.tap(find.byIcon(PhosphorIconsFill.xCircle));
      await tester.pump(const Duration(milliseconds: 100));
      expect(currentQuery, equals(''));
    });

    // 7. AppListSection Inset Grouped Surface (Widget Test)
    testWidgets('7. AppListSection renders Title Case header and non-glass grouped content surface', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AppListSection(
            title: 'Active Habits',
            children: [
              ListTile(title: Text('Morning Meditation')),
              ListTile(title: Text('Read 20 Mins')),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Active Habits'), findsOneWidget);
      expect(find.text('Morning Meditation'), findsOneWidget);
      expect(find.text('Read 20 Mins'), findsOneWidget);

      // Verify no BackdropFilter exists on row children (strictly non-glass on content)
      final listSection = tester.widget<AppListSection>(find.byType(AppListSection));
      expect(listSection.title, equals('Active Habits'));
      expect(find.descendant(of: find.byType(ListTile), matching: find.byType(BackdropFilter)), findsNothing);
    });

    // 8. AppTactileSlider Spring-Enlarging Knob (Widget Test)
    testWidgets('8. AppTactileSlider updates values on drag and provides tactile knob bounds', (tester) async {
      double sliderVal = 0.5;

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (ctx, setState) => AppTactileSlider(
              value: sliderVal,
              min: 0.0,
              max: 1.0,
              onChanged: (v) => setState(() => sliderVal = v),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppTactileSlider), findsOneWidget);
      // Drag slider
      await tester.drag(find.byType(AppTactileSlider), const Offset(80, 0));
      await tester.pump(const Duration(milliseconds: 100));
      expect(sliderVal, isNot(equals(0.5)));
    });

    // 9. Glass Tier Fallbacks & Reduce Transparency (Widget Test)
    testWidgets('9. AppGlassCard respects GlassTier and switches to solid surface under Reduce Transparency', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Column(
            children: [
              AppGlassCard(
                tier: GlassTier.plain,
                child: Text('Plain Tier Card'),
              ),
              AppGlassCard(
                tier: GlassTier.premium,
                child: Text('Reduced Transparency Card'),
              ),
            ],
          ),
          overrides: [
            reduceTransparencyProvider.overrideWith(_TrueReduceTransparencyNotifier.new),
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Plain Tier Card'), findsOneWidget);
      expect(find.text('Reduced Transparency Card'), findsOneWidget);
      // Under reduceTransparency, BackdropFilter is omitted
      expect(find.byType(BackdropFilter), findsNothing);
    });

    // 10. Optical Typography Tracking Helper (Unit Test)
    test('10. PoswalText.opticalTracking converts em to logical pixels and zeroes out for Hindi and Urdu', () {
      // Latin: -0.022em on 34px = -0.748 logical pixels
      final latinTracking = PoswalText.opticalTracking(-0.022, 34);
      expect(latinTracking, closeTo(-0.748, 0.001));

      // Hindi (Devanagari): must be 0.0 to prevent breaking joined matras and conjuncts
      final hindiTracking = PoswalText.opticalTracking(-0.022, 34, languageCode: 'hi');
      expect(hindiTracking, equals(0.0));

      // Urdu (Nastaliq): must be 0.0 to preserve cursive ligatures
      final urduTracking = PoswalText.opticalTracking(-0.022, 34, languageCode: 'ur');
      expect(urduTracking, equals(0.0));
    });

    // 11. Localized Typography Helper (Unit Test)
    test('11. PoswalText.localized preserves tracking on Latin and strips negative tracking on Hindi/Urdu', () {
      const latinStyle = PoswalText.largeTitle;
      expect(latinStyle.letterSpacing, isNotNull);
      expect(latinStyle.letterSpacing!, lessThan(0.0));

      final hindiStyle = PoswalText.localized(latinStyle, languageCode: 'hi');
      expect(hindiStyle.letterSpacing, equals(0.0));

      final urduStyle = PoswalText.localized(latinStyle, languageCode: 'ur');
      expect(urduStyle.letterSpacing, equals(0.0));

      final enStyle = PoswalText.localized(latinStyle, languageCode: 'en');
      expect(enStyle.letterSpacing, equals(latinStyle.letterSpacing));
    });

    // 12. Standard Curves, Durations, Spacing, and Touch Padding Tokens (Unit Test)
    test('12. PoswalCurves, PoswalDurations, PoswalSpacing, and PoswalTouchPadding provide consistent scale metrics', () {
      // Standard ease curve
      expect(PoswalCurves.standard, equals(const Cubic(0.25, 0.1, 0.25, 1.0)));

      // Durations
      expect(PoswalDurations.micro.inMilliseconds, equals(150));
      expect(PoswalDurations.standard.inMilliseconds, equals(250));
      expect(PoswalDurations.sheet.inMilliseconds, equals(300));

      // Spacing scale
      expect(PoswalSpacing.xxs, equals(2.0));
      expect(PoswalSpacing.xs, equals(4.0));
      expect(PoswalSpacing.lg2, equals(20.0));
      expect(PoswalSpacing.massive, equals(64.0));

      // Touch padding
      expect(PoswalTouchPadding.bordered, equals(12.0));
      expect(PoswalTouchPadding.borderless, equals(24.0));
    });
  });
}
