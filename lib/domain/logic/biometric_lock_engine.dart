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

class BiometricLockEngine {
  bool isEnabled;
  LockTimeout timeout;
  bool hideContentInRecents;
  bool isLocked;
  DateTime? _pausedAt;

  BiometricLockEngine({
    this.isEnabled = false,
    this.timeout = LockTimeout.immediate,
    this.hideContentInRecents = false,
    this.isLocked = false,
    DateTime? initialPausedAt,
  }) : _pausedAt = initialPausedAt;

  DateTime? get pausedAt => _pausedAt;

  /// Call when app enters background (paused / inactive)
  void onAppPaused({DateTime? now}) {
    if (!isEnabled) return;
    _pausedAt = now ?? DateTime.now();
    if (timeout.seconds == 0) {
      isLocked = true;
    }
  }

  /// Call when app returns to foreground (resumed)
  bool onAppResumed({DateTime? now}) {
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
  }

  /// Lock immediately (e.g. manual lock)
  void lock() {
    if (isEnabled) {
      isLocked = true;
    }
  }
}
