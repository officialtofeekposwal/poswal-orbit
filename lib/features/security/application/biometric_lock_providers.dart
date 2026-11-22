import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/data/services/biometric_lock_service.dart';
import 'package:poswal_orbit/domain/logic/biometric_lock_engine.dart';

class BiometricLockState {
  final bool isEnabled;
  final bool isLocked;
  final LockTimeout timeout;
  final bool hideContentInRecents;
  final bool isDeviceSupported;
  final bool isAuthenticating;
  final bool isPromptActive;
  final BiometricAuthResult? lastAuthResult;

  const BiometricLockState({
    this.isEnabled = false,
    this.isLocked = false,
    this.timeout = LockTimeout.immediate,
    this.hideContentInRecents = false,
    this.isDeviceSupported = false,
    this.isAuthenticating = false,
    this.isPromptActive = false,
    this.lastAuthResult,
  });

  BiometricLockState copyWith({
    bool? isEnabled,
    bool? isLocked,
    LockTimeout? timeout,
    bool? hideContentInRecents,
    bool? isDeviceSupported,
    bool? isAuthenticating,
    bool? isPromptActive,
    BiometricAuthResult? Function()? lastAuthResult,
  }) {
    return BiometricLockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLocked: isLocked ?? this.isLocked,
      timeout: timeout ?? this.timeout,
      hideContentInRecents: hideContentInRecents ?? this.hideContentInRecents,
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      isPromptActive: isPromptActive ?? this.isPromptActive,
      lastAuthResult: lastAuthResult != null ? lastAuthResult() : this.lastAuthResult,
    );
  }
}

class BiometricLockNotifier extends Notifier<BiometricLockState> {
  late final BiometricLockService _service;
  late final BiometricLockEngine _engine;

  @override
  BiometricLockState build() {
    _service = ref.watch(biometricLockServiceProvider);
    _engine = BiometricLockEngine();
    _initialize();
    return const BiometricLockState();
  }

  BiometricLockEngine get engine => _engine;

  Future<void> _initialize() async {
    final supported = await _service.isDeviceSupported();
    final enabled = await _service.isBiometricEnabled();
    final timeout = await _service.getLockTimeout();
    final hideRecents = await _service.isHideContentInRecents();

    _engine.isEnabled = enabled;
    _engine.timeout = timeout;
    _engine.hideContentInRecents = hideRecents;

    // Auto-recovery rule: if lock is enabled but hardware cannot support authentication at all,
    // do not trap the user.
    if (enabled && !supported) {
      debugPrint('[BiometricLockNotifier] Auto-recovery: device does not support auth, unlocking.');
      _engine.isLocked = false;
    } else if (enabled) {
      _engine.isLocked = true;
    }

    state = BiometricLockState(
      isEnabled: enabled,
      isLocked: _engine.isLocked,
      timeout: timeout,
      hideContentInRecents: hideRecents,
      isDeviceSupported: supported,
    );

    if (hideRecents) {
      await _service.applyRecentsPrivacy(true);
    }
  }

  void onAppLifecycleChanged(AppLifecycleState lifecycle) {
    if (!state.isEnabled) return;

    // CRITICAL: Ignore lifecycle changes while the system authentication dialog is active
    if (state.isPromptActive || _engine.isPromptActive) return;

    if (lifecycle == AppLifecycleState.paused || lifecycle == AppLifecycleState.inactive) {
      _engine.onAppPaused();
      if (_engine.isLocked != state.isLocked) {
        state = state.copyWith(isLocked: _engine.isLocked);
      }
    } else if (lifecycle == AppLifecycleState.resumed) {
      final shouldLock = _engine.onAppResumed();
      if (shouldLock != state.isLocked) {
        state = state.copyWith(isLocked: shouldLock);
      }
    }
  }

  Future<bool> authenticate() async {
    if (state.isAuthenticating) return false;

    state = state.copyWith(
      isAuthenticating: true,
      isPromptActive: true,
      lastAuthResult: () => null,
    );
    _engine.isPromptActive = true;

    try {
      final result = await _service.authenticateDetailed();
      _engine.isPromptActive = false;

      if (result.isSuccess) {
        _engine.unlock();
        state = state.copyWith(
          isLocked: false,
          isAuthenticating: false,
          isPromptActive: false,
          lastAuthResult: () => result,
        );
        return true;
      } else {
        state = state.copyWith(
          isAuthenticating: false,
          isPromptActive: false,
          lastAuthResult: () => result,
        );
        return false;
      }
    } catch (e) {
      _engine.isPromptActive = false;
      final result = BiometricAuthResult.fromException(e);
      state = state.copyWith(
        isAuthenticating: false,
        isPromptActive: false,
        lastAuthResult: () => result,
      );
      return false;
    }
  }

  /// Runs real test authentication without altering app locked status
  Future<BiometricAuthResult> testAuthentication() async {
    _engine.isPromptActive = true;
    try {
      final result = await _service.authenticateDetailed(
        localizedReason: 'Test biometric and device passcode authentication for Poswal Orbit',
      );
      return result;
    } finally {
      _engine.isPromptActive = false;
    }
  }

  /// Emergency safe-disable: allowed ONLY when authentication is reported unavailable by the device
  Future<bool> emergencyDisableLock() async {
    final result = state.lastAuthResult;
    final canDisable = !state.isDeviceSupported || (result != null && result.isHardwareUnavailable);
    if (!canDisable) {
      debugPrint('[BiometricLockNotifier] Emergency disable refused: authentication hardware is available.');
      return false;
    }

    await _service.emergencyDisableLock();
    _engine.safeDisable();
    state = state.copyWith(
      isEnabled: false,
      isLocked: false,
      isAuthenticating: false,
      isPromptActive: false,
      lastAuthResult: () => null,
    );
    return true;
  }

  Future<void> toggleEnabled(bool enabled) async {
    await _service.setBiometricEnabled(enabled);
    _engine.isEnabled = enabled;
    if (!enabled) {
      _engine.unlock();
      state = state.copyWith(
        isEnabled: false,
        isLocked: false,
        lastAuthResult: () => null,
      );
    } else {
      state = state.copyWith(isEnabled: true);
    }
  }

  Future<void> updateTimeout(LockTimeout timeout) async {
    await _service.setLockTimeout(timeout);
    _engine.timeout = timeout;
    state = state.copyWith(timeout: timeout);
  }

  Future<void> toggleHideRecents(bool hide) async {
    await _service.setHideContentInRecents(hide);
    _engine.hideContentInRecents = hide;
    state = state.copyWith(hideContentInRecents: hide);
  }

  void forceLock() {
    _engine.lock();
    state = state.copyWith(isLocked: true);
  }

  void forceUnlock() {
    _engine.unlock();
    state = state.copyWith(isLocked: false);
  }
}

final biometricLockServiceProvider = Provider<BiometricLockService>((ref) {
  return BiometricLockService();
});

final biometricLockProvider = NotifierProvider<BiometricLockNotifier, BiometricLockState>(() {
  return BiometricLockNotifier();
});
