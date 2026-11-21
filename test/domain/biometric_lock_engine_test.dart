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
  });
}
