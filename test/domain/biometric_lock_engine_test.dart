import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/biometric_lock_engine.dart';

void main() {
  group('BiometricLockEngine Domain Logic Tests', () {
    test('Disabled engine never locks on pause or resume', () {
      final engine = BiometricLockEngine(isEnabled: false);
      expect(engine.isLocked, isFalse);

      engine.onAppPaused(now: DateTime(2026, 11, 21, 10, 0, 0));
      expect(engine.isLocked, isFalse);

      final didLock = engine.onAppResumed(now: DateTime(2026, 11, 21, 12, 0, 0));
      expect(didLock, isFalse);
      expect(engine.isLocked, isFalse);
    });

    test('Immediate timeout locks as soon as app is paused', () {
      final engine = BiometricLockEngine(
        isEnabled: true,
        timeout: LockTimeout.immediate,
      );

      final pauseTime = DateTime(2026, 11, 21, 10, 0, 0);
      engine.onAppPaused(now: pauseTime);
      expect(engine.isLocked, isTrue);

      final didLock = engine.onAppResumed(now: pauseTime.add(const Duration(seconds: 1)));
      expect(didLock, isTrue);
      expect(engine.isLocked, isTrue);
    });

    test('Configured timeout (30s) does not lock if resumed before timeout', () {
      final engine = BiometricLockEngine(
        isEnabled: true,
        timeout: LockTimeout.thirtySeconds,
      );

      final pauseTime = DateTime(2026, 11, 21, 10, 0, 0);
      engine.onAppPaused(now: pauseTime);
      expect(engine.isLocked, isFalse); // Not locked yet during grace period

      final resumeTime = pauseTime.add(const Duration(seconds: 15));
      final didLock = engine.onAppResumed(now: resumeTime);
      expect(didLock, isFalse);
      expect(engine.isLocked, isFalse);
    });

    test('Configured timeout (30s) locks when resumed after timeout has elapsed', () {
      final engine = BiometricLockEngine(
        isEnabled: true,
        timeout: LockTimeout.thirtySeconds,
      );

      final pauseTime = DateTime(2026, 11, 21, 10, 0, 0);
      engine.onAppPaused(now: pauseTime);
      expect(engine.isLocked, isFalse);

      final resumeTime = pauseTime.add(const Duration(seconds: 35));
      final didLock = engine.onAppResumed(now: resumeTime);
      expect(didLock, isTrue);
      expect(engine.isLocked, isTrue);
    });

    test('Engine locks on initial app start if enabled and never paused', () {
      final engine = BiometricLockEngine(
        isEnabled: true,
        timeout: LockTimeout.fiveMinutes,
      );

      expect(engine.isLocked, isFalse);
      final didLock = engine.onAppResumed(now: DateTime(2026, 11, 21, 10, 0, 0));
      expect(didLock, isTrue);
      expect(engine.isLocked, isTrue);
    });

    test('Unlock resets lock state and clears paused timestamp', () {
      final engine = BiometricLockEngine(
        isEnabled: true,
        timeout: LockTimeout.immediate,
        isLocked: true,
        initialPausedAt: DateTime(2026, 11, 21, 10, 0, 0),
      );

      expect(engine.isLocked, isTrue);
      expect(engine.pausedAt, isNotNull);

      engine.unlock();
      expect(engine.isLocked, isFalse);
      expect(engine.pausedAt, isNull);
    });

    test('Manual lock explicitly locks when enabled', () {
      final engine = BiometricLockEngine(isEnabled: true);
      expect(engine.isLocked, isFalse);

      engine.lock();
      expect(engine.isLocked, isTrue);
    });

    test('LockTimeout enum helper maps seconds accurately with fallback', () {
      expect(LockTimeout.fromSeconds(0), equals(LockTimeout.immediate));
      expect(LockTimeout.fromSeconds(30), equals(LockTimeout.thirtySeconds));
      expect(LockTimeout.fromSeconds(60), equals(LockTimeout.oneMinute));
      expect(LockTimeout.fromSeconds(300), equals(LockTimeout.fiveMinutes));
      expect(LockTimeout.fromSeconds(999), equals(LockTimeout.immediate));
    });

    test('Lifecycle changes are ignored while isPromptActive is true', () {
      final engine = BiometricLockEngine(
        isEnabled: true,
        timeout: LockTimeout.immediate,
        isPromptActive: true,
      );

      final pauseTime = DateTime(2026, 11, 21, 10, 0, 0);
      engine.onAppPaused(now: pauseTime);
      // Because prompt is active, it must not lock or record pause timestamp
      expect(engine.isLocked, isFalse);
      expect(engine.pausedAt, isNull);

      final didLock = engine.onAppResumed(now: pauseTime.add(const Duration(seconds: 10)));
      expect(didLock, isFalse);
      expect(engine.isLocked, isFalse);
    });

    test('safeDisable resets isEnabled, isLocked, pausedAt and isPromptActive', () {
      final engine = BiometricLockEngine(
        isEnabled: true,
        timeout: LockTimeout.immediate,
        isLocked: true,
        isPromptActive: true,
        initialPausedAt: DateTime(2026, 11, 21, 10, 0, 0),
      );

      engine.safeDisable();
      expect(engine.isEnabled, isFalse);
      expect(engine.isLocked, isFalse);
      expect(engine.isPromptActive, isFalse);
      expect(engine.pausedAt, isNull);
    });

    test('BiometricAuthResult.fromException maps PlatformException codes properly', () {
      final notAvailable = BiometricAuthResult.fromException(
        PlatformException(code: 'NotAvailable', message: 'Not available'),
      );
      expect(notAvailable.status, equals(BiometricAuthStatus.notAvailable));
      expect(notAvailable.isHardwareUnavailable, isTrue);

      final notEnrolled = BiometricAuthResult.fromException(
        PlatformException(code: 'NotEnrolled', message: 'Not enrolled'),
      );
      expect(notEnrolled.status, equals(BiometricAuthStatus.notEnrolled));
      expect(notEnrolled.isHardwareUnavailable, isTrue);

      final passcodeNotSet = BiometricAuthResult.fromException(
        PlatformException(code: 'PasscodeNotSet', message: 'Passcode not set'),
      );
      expect(passcodeNotSet.status, equals(BiometricAuthStatus.passcodeNotSet));
      expect(passcodeNotSet.isHardwareUnavailable, isTrue);

      final lockedOut = BiometricAuthResult.fromException(
        PlatformException(code: 'LockedOut', message: 'Too many attempts'),
      );
      expect(lockedOut.status, equals(BiometricAuthStatus.lockedOut));
      expect(lockedOut.isHardwareUnavailable, isFalse);

      final canceled = BiometricAuthResult.fromException(
        PlatformException(code: 'UserCanceled', message: 'Canceled by user'),
      );
      expect(canceled.status, equals(BiometricAuthStatus.canceled));
      expect(canceled.isHardwareUnavailable, isFalse);

      final genericError = BiometricAuthResult.fromException(
        PlatformException(code: 'CustomCode', message: 'Custom failure message'),
      );
      expect(genericError.status, equals(BiometricAuthStatus.error));
      expect(genericError.errorCode, equals('CustomCode'));
      expect(genericError.errorMessage, equals('Custom failure message'));
      expect(genericError.isHardwareUnavailable, isFalse);
    });
  });
}
