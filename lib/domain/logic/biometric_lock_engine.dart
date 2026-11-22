import 'package:flutter/services.dart';

enum LockTimeout {
  immediate(0, 'Immediately'),
  thirtySeconds(30, 'After 30 seconds'),
  oneMinute(60, 'After 1 minute'),
  fiveMinutes(300, 'After 5 minutes');

  final int seconds;
  final String label;

  const LockTimeout(this.seconds, this.label);

  static LockTimeout fromSeconds(int seconds) {
    for (final t in LockTimeout.values) {
      if (t.seconds == seconds) return t;
    }
    return LockTimeout.immediate;
  }
}

enum BiometricAuthStatus {
  success,
  failed,
  canceled,
  notAvailable,
  notEnrolled,
  passcodeNotSet,
  lockedOut,
  error,
}

class BiometricAuthResult {
  final BiometricAuthStatus status;
  final String? errorCode;
  final String? errorMessage;

  const BiometricAuthResult({
    required this.status,
    this.errorCode,
    this.errorMessage,
  });

  bool get isSuccess => status == BiometricAuthStatus.success;

  /// True when the device hardware or system settings completely prevent authentication.
  /// Safe-disable is ONLY permitted in this state to prevent trapping the user.
  bool get isHardwareUnavailable =>
      status == BiometricAuthStatus.notAvailable ||
      status == BiometricAuthStatus.notEnrolled ||
      status == BiometricAuthStatus.passcodeNotSet;

  static BiometricAuthResult fromException(dynamic e) {
    if (e is PlatformException) {
      final code = e.code.toLowerCase();
      if (code.contains('notavailable') || code.contains('not_available')) {
        return BiometricAuthResult(
          status: BiometricAuthStatus.notAvailable,
          errorCode: e.code,
          errorMessage: 'Biometric or device credentials are not available on this device.',
        );
      } else if (code.contains('notenrolled') || code.contains('not_enrolled')) {
        return BiometricAuthResult(
          status: BiometricAuthStatus.notEnrolled,
          errorCode: e.code,
          errorMessage: 'No fingerprint or biometric credentials are enrolled on this phone.',
        );
      } else if (code.contains('passcodenotset') || code.contains('passcode_not_set')) {
        return BiometricAuthResult(
          status: BiometricAuthStatus.passcodeNotSet,
          errorCode: e.code,
          errorMessage: 'No screen lock PIN, pattern, or password is set on this phone.',
        );
      } else if (code.contains('lockedout') || code.contains('locked_out')) {
        return BiometricAuthResult(
          status: BiometricAuthStatus.lockedOut,
          errorCode: e.code,
          errorMessage: 'Authentication is temporarily locked out due to too many failed attempts.',
        );
      } else if (code.contains('canceled') || code.contains('usercanceled')) {
        return BiometricAuthResult(
          status: BiometricAuthStatus.canceled,
          errorCode: e.code,
          errorMessage: 'Authentication was canceled.',
        );
      }
      return BiometricAuthResult(
        status: BiometricAuthStatus.error,
        errorCode: e.code,
        errorMessage: e.message ?? 'Authentication error occurred.',
      );
    }
    return BiometricAuthResult(
      status: BiometricAuthStatus.error,
      errorCode: 'UNKNOWN',
      errorMessage: e.toString(),
    );
  }
}

class BiometricLockEngine {
  bool isEnabled;
  LockTimeout timeout;
  bool hideContentInRecents;
  bool isLocked;
  bool isPromptActive;
  DateTime? _pausedAt;

  BiometricLockEngine({
    this.isEnabled = false,
    this.timeout = LockTimeout.immediate,
    this.hideContentInRecents = false,
    this.isLocked = false,
    this.isPromptActive = false,
    DateTime? initialPausedAt,
  }) : _pausedAt = initialPausedAt;

  DateTime? get pausedAt => _pausedAt;

  /// Call when app enters background (paused / inactive).
  /// Lifecycle events are ignored while an authentication prompt is in progress.
  void onAppPaused({DateTime? now}) {
    if (!isEnabled || isPromptActive) return;
    _pausedAt = now ?? DateTime.now();
    if (timeout.seconds == 0) {
      isLocked = true;
    }
  }

  /// Call when app returns to foreground (resumed).
  bool onAppResumed({DateTime? now}) {
    if (isPromptActive) return isLocked;

    if (!isEnabled) {
      isLocked = false;
      _pausedAt = null;
      return false;
    }

    if (isLocked) {
      // Already locked
      return true;
    }

    if (_pausedAt == null) {
      // If enabled and no previous pause record, lock on start
      isLocked = true;
      return true;
    }

    final currentTime = now ?? DateTime.now();
    final elapsed = currentTime.difference(_pausedAt!).inSeconds;

    if (elapsed >= timeout.seconds) {
      isLocked = true;
      return true;
    }

    return false;
  }

  /// Call upon successful biometric or passcode authentication
  void unlock() {
    isLocked = false;
    _pausedAt = null;
    isPromptActive = false;
  }

  /// Lock immediately (e.g. manual lock)
  void lock() {
    if (isEnabled) {
      isLocked = true;
    }
  }

  /// Disables lock state safely when authentication is completely unavailable
  void safeDisable() {
    isEnabled = false;
    isLocked = false;
    _pausedAt = null;
    isPromptActive = false;
  }
}
