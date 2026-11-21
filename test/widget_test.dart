import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/widgets/poswal_orbit_ring.dart';
import 'package:poswal_orbit/main.dart';

void main() {
  testWidgets('Phase 0 Design Playground smoke test', (WidgetTester tester) async {
    final repaintKey = GlobalKey();

    await tester.pumpWidget(
      ProviderScope(
        child: RepaintBoundary(
          key: repaintKey,
          child: const PoswalOrbitApp(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 1.0);
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            final file = File('docs/screenshots/playground-$name.png');
            file.parent.createSync(recursive: true);
            file.writeAsBytesSync(byteData.buffer.asUint8List());
          }
        }
      });
    }

    // Verify Playground components in view
    expect(find.text('Phase 0 Playground'), findsOneWidget);
    expect(find.text('Theme & Display Engine'), findsOneWidget);
    expect(find.text('Orbit Progress Ring'), findsOneWidget);
    expect(find.byType(PoswalOrbitRing), findsOneWidget);

    // Verify theme controls
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('OLED'), findsOneWidget);

    // Capture Dark Mode (Initial)
    await capture('dark');

    // Tap Light theme and pump
    await tester.tap(find.text('Light'));
    await tester.pump(const Duration(milliseconds: 100));
    await capture('light');

    // Tap OLED theme and pump
    await tester.tap(find.text('OLED'));
    await tester.pump(const Duration(milliseconds: 100));
    await capture('oled');
  });

  test('PoswalTheme mode check', () {
    expect(AppThemeMode.dark.isDark, isTrue);
    expect(AppThemeMode.oled.isDark, isTrue);
    expect(AppThemeMode.oled.isOled, isTrue);
    expect(AppThemeMode.light.isLight, isTrue);
  });
}
