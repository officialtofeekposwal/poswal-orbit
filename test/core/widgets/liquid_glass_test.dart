import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/liquid_glass.dart';

void main() {
  group('LiquidGlass widget', () {
    testWidgets('renders BackdropFilter and RepaintBoundary in normal mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LiquidGlass(
                isCapsule: true,
                padding: EdgeInsets.all(12),
                child: Text('Glass Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LiquidGlass),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
    });

    testWidgets('omits BackdropFilter and uses solid fallback when reduceTransparency is on', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reduceTransparencyProvider.overrideWith(
              () => _FixedReduceTransparencyNotifier(true),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: LiquidGlass(
                padding: EdgeInsets.all(12),
                child: Text('Solid Fallback'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Solid Fallback'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('uses Duration.zero and disables press scale when disableAnimations is true', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Scaffold(
                body: LiquidGlass(
                  onTap: () => tapped = true,
                  padding: const EdgeInsets.all(12),
                  child: const Text('Tap Me'),
                ),
              ),
            ),
          ),
        ),
      );

      final animatedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(animatedScale.duration, Duration.zero);
      expect(animatedScale.scale, 1.0);

      await tester.tap(find.text('Tap Me'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}

class _FixedReduceTransparencyNotifier extends ReduceTransparencyNotifier {
  final bool initialValue;
  _FixedReduceTransparencyNotifier(this.initialValue);

  @override
  bool build() => initialValue;
}
