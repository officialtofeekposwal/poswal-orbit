import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/features/settings/presentation/reminders_health_check_screen.dart';
import 'package:poswal_orbit/features/settings/presentation/settings_screen.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: PoswalTheme.getTheme(AppThemeMode.dark),
        home: child,
      ),
    );
  }

  group('RemindersHealthCheckScreen Widget Tests', () {
    testWidgets('renders all diagnostics sections and permissions cards correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const RemindersHealthCheckScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Reminders Health Check'), findsOneWidget);
      expect(find.text('Notification Permission'), findsOneWidget);
      expect(find.text('Exact Alarm Scheduling'), findsOneWidget);
      expect(find.text('Samsung Battery Exemption'), findsOneWidget);
      expect(find.text('Rolling 7-Day Window'), findsOneWidget);
      expect(find.byKey(const ValueKey('send_test_notification_btn')), findsOneWidget);
    });

    testWidgets('tapping Samsung battery guide opens step-by-step One UI dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const RemindersHealthCheckScreen()));
      await tester.pumpAndSettle();

      final guideBtn = find.byKey(const ValueKey('battery_guide_btn'));
      expect(guideBtn, findsOneWidget);

      await tester.tap(guideBtn);
      await tester.pumpAndSettle();

      expect(find.text('Samsung One UI Battery Guide'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();
      expect(find.text('Samsung One UI Battery Guide'), findsNothing);
    });

    testWidgets('Settings screen renders Reminders & Notifications card with deep link', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Reminders & Notifications'), findsOneWidget);
      expect(find.byKey(const ValueKey('reminders_health_check_tile')), findsOneWidget);
      expect(find.byKey(const ValueKey('settings_send_test_notif_btn')), findsOneWidget);

      // Tap to navigate to health check
      await tester.tap(find.byKey(const ValueKey('reminders_health_check_tile')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Notification Permission'), findsOneWidget);
      expect(find.text('Exact Alarm Scheduling'), findsOneWidget);
    });
  });
}
