import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/services/biometric_lock_service.dart';
import 'package:poswal_orbit/domain/logic/biometric_lock_engine.dart';
import 'package:poswal_orbit/features/security/application/biometric_lock_providers.dart';
import 'package:poswal_orbit/features/security/presentation/biometric_lock_screen.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class MockBiometricLockService extends BiometricLockService {
  bool authReturnValue = true;
  int authCallCount = 0;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> isBiometricEnabled() async => true;

  @override
  Future<LockTimeout> getLockTimeout() async => LockTimeout.immediate;

  @override
  Future<bool> isHideContentInRecents() async => false;

  @override
  Future<bool> authenticate({
    String localizedReason = 'Unlock Poswal Orbit to view your habits and notes',
  }) async {
    authCallCount++;
    return authReturnValue;
  }
}

void main() {
  group('BiometricLockScreen Widget Tests', () {
    testWidgets('Renders lock screen with Poswal Orbit branding and action buttons', (tester) async {
      final mockService = MockBiometricLockService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            biometricLockServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp(
            theme: ThemeData(splashFactory: InkRipple.splashFactory),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BiometricLockScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BiometricLockScreen), findsOneWidget);
      expect(find.text('Poswal Orbit'), findsOneWidget);
      expect(find.byKey(const ValueKey('biometric_unlock_btn')), findsOneWidget);
      expect(find.byKey(const ValueKey('passcode_fallback_btn')), findsOneWidget);
    });

    testWidgets('Tapping unlock button triggers authentication', (tester) async {
      final mockService = MockBiometricLockService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            biometricLockServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp(
            theme: ThemeData(splashFactory: InkRipple.splashFactory),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BiometricLockScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final initialCalls = mockService.authCallCount;

      await tester.tap(find.byKey(const ValueKey('biometric_unlock_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(mockService.authCallCount, greaterThan(initialCalls));
    });

    testWidgets('Tapping passcode fallback button also triggers authentication with passcode fallback', (tester) async {
      final mockService = MockBiometricLockService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            biometricLockServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp(
            theme: ThemeData(splashFactory: InkRipple.splashFactory),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BiometricLockScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final initialCalls = mockService.authCallCount;

      await tester.tap(find.byKey(const ValueKey('passcode_fallback_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(mockService.authCallCount, greaterThan(initialCalls));
    });
  });
}
