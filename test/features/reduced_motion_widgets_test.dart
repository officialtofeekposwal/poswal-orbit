import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/core/widgets/poswal_orbit_ring.dart';

void main() {
  testWidgets('PoswalOrbitRing immediately renders final progress without AnimatedBuilder when animations are disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: PoswalOrbitRing(
              progress: 0.75,
              animateOnStart: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(PoswalOrbitRing), findsOneWidget);
    // When disableAnimations is true, AnimatedBuilder is omitted for static rendering
    expect(
      find.descendant(
        of: find.byType(PoswalOrbitRing),
        matching: find.byType(AnimatedBuilder),
      ),
      findsNothing,
    );
  });

  testWidgets('AuroraBackground disables continuous animation loop when animations are disabled', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: AuroraBackground(
                child: Text('Content'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Content'), findsOneWidget);
    // When animations are disabled, AnimatedBuilder is bypassed and static CustomPaint is rendered
    expect(
      find.descendant(
        of: find.byType(AuroraBackground),
        matching: find.byType(AnimatedBuilder),
      ),
      findsNothing,
    );
  });
}
