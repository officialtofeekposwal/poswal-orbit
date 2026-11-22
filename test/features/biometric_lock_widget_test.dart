import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/services/biometric_lock_service.dart';
import 'package:poswal_orbit/domain/logic/biometric_lock_engine.dart';
import 'package:poswal_orbit/features/security/application/biometric_lock_providers.dart';
import 'package:poswal_orbit/features/security/presentation/biometric_lock_screen.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class MockBiometricLockService extends BiometricLockService {
  BiometricAuthResult authResult = const BiometricAuthResult(status: BiometricAuthStatus.success);
  int authCallCount = 0;
  bool emergencyDisableCalled = false;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> isBiometricEnabled() async => true;

  @override
  Future<LockTimeout> getLockTimeout() async => LockTimeout.immediate;

  @override
  Future<bool> isHideContentInRecents() async => false;

  @override
  Future<BiometricAuthResult> authenticateDetailed({
    String localizedReason = 'Unlock Poswal Orbit to view your habits and notes',
  }) async {
    authCallCount++;
    return authResult;
  }

  @override
  Future<bool> authenticate({
    String localizedReason = 'Unlock Poswal Orbit to view your habits and notes',
  }) async {
    final res = await authenticateDetailed(localizedReason: localizedReason);
    return res.isSuccess;
  }

  @override
  Future<void> emergencyDisableLock() async {
    emergencyDisableCalled = true;
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

    testWidgets('Displays detailed error banner and code on failed authentication', (tester) async {
      final mockService = MockBiometricLockService();
      mockService.authResult = const BiometricAuthResult(
        status: BiometricAuthStatus.failed,
        errorCode: 'AUTH_FAILED',
        errorMessage: 'Authentication was not successful.',
      );

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

      await tester.tap(find.byKey(const ValueKey('biometric_unlock_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const ValueKey('auth_error_container')), findsOneWidget);
      expect(find.text('Authentication was not successful.'), findsOneWidget);
      expect(find.text('Error code: AUTH_FAILED'), findsOneWidget);
      // Emergency disable should NOT be shown for normal failures
      expect(find.byKey(const ValueKey('emergency_disable_lock_btn')), findsNothing);
    });

    testWidgets('Displays emergency disable button when hardware/enrollment is unavailable', (tester) async {
      final mockService = MockBiometricLockService();
      mockService.authResult = const BiometricAuthResult(
        status: BiometricAuthStatus.notEnrolled,
        errorCode: 'NotEnrolled',
        errorMessage: 'No fingerprint or biometric credentials are enrolled on this phone.',
      );

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

      await tester.tap(find.byKey(const ValueKey('biometric_unlock_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const ValueKey('emergency_disable_lock_btn')), findsOneWidget);

      // Tap emergency disable
      await tester.tap(find.byKey(const ValueKey('emergency_disable_lock_btn')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Disable App Lock?'), findsOneWidget);

      // Confirm disable
      final disableBtn = find.widgetWithText(FilledButton, 'Turn off App Lock (Hardware Unavailable)');
      expect(disableBtn, findsOneWidget);
      await tester.tap(disableBtn);
      await tester.pumpAndSettle();

      expect(mockService.emergencyDisableCalled, isTrue);
    });

    testWidgets('Authentication retry does not remain stuck in authenticating state', (tester) async {
      final mockService = MockBiometricLockService();
      mockService.authResult = const BiometricAuthResult(
        status: BiometricAuthStatus.canceled,
        errorCode: 'UserCanceled',
        errorMessage: 'Authentication was canceled.',
      );

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

      // Tap once
      await tester.tap(find.byKey(const ValueKey('biometric_unlock_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(mockService.authCallCount, equals(2)); // initial postframe + 1 tap

      // Tap second time (must not be blocked by stuck flag)
      await tester.tap(find.byKey(const ValueKey('biometric_unlock_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(mockService.authCallCount, equals(3));
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
