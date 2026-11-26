import 'dart:ui' show Tristate;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_tab_bar.dart';
import 'package:poswal_orbit/core/widgets/liquid_glass.dart';

void main() {
  group('AppTabBar widget', () {
    testWidgets('renders 5 tabs with >= 44px touch targets and Semantics', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppTabBar(
                currentIndex: 0,
                onTabSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LiquidGlass), findsOneWidget);

      for (var i = 0; i < 5; i++) {
        final keyFinder = find.byKey(ValueKey('tab_item_$i'));
        expect(keyFinder, findsOneWidget);

        final size = tester.getSize(keyFinder);
        expect(
          size.width,
          greaterThanOrEqualTo(PoswalRowHeights.minTouchTarget),
          reason: 'tab_item_$i width must be >= 44dp',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(PoswalRowHeights.minTouchTarget),
          reason: 'tab_item_$i height must be >= 44dp',
        );
      }

      final todaySemantics = tester.getSemantics(find.byKey(const ValueKey('tab_item_0')));
      expect(todaySemantics.flagsCollection.isButton, isTrue);
      expect(todaySemantics.flagsCollection.isSelected, Tristate.isTrue);
      expect(todaySemantics.label, contains('Today'));

      final habitsSemantics = tester.getSemantics(find.byKey(const ValueKey('tab_item_1')));
      expect(habitsSemantics.flagsCollection.isButton, isTrue);
      expect(habitsSemantics.flagsCollection.isSelected, Tristate.isFalse);
      expect(habitsSemantics.label, contains('Habits'));
    });

    testWidgets('tapping a tab calls onTabSelected with the tapped index', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  bottomNavigationBar: AppTabBar(
                    currentIndex: selectedIndex,
                    onTabSelected: (idx) => setState(() => selectedIndex = idx),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('tab_item_2')));
      await tester.pumpAndSettle();
      expect(selectedIndex, 2);

      await tester.tap(find.byKey(const ValueKey('tab_item_4')));
      await tester.pumpAndSettle();
      expect(selectedIndex, 4);
    });
  });
}
