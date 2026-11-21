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

  const BiometricLockState({
    this.isEnabled = false,
    this.isLocked = false,
    this.timeout = LockTimeout.immediate,
    this.hideContentInRecents = false,
    this.isDeviceSupported = false,
  });

  BiometricLockState copyWith({
    bool? isEnabled,
    bool? isLocked,
    LockTimeout? timeout,
    bool? hideContentInRecents,
    bool? isDeviceSupported,
  }) {
    return BiometricLockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLocked: isLocked ?? this.isLocked,
      timeout: timeout ?? this.timeout,
      hideContentInRecents: hideContentInRecents ?? this.hideContentInRecents,
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
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

    // If enabled, lock on fresh start
    if (enabled) {
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
    final success = await _service.authenticate();
    if (success) {
      _engine.unlock();
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  Future<void> toggleEnabled(bool enabled) async {
    await _service.setBiometricEnabled(enabled);
    _engine.isEnabled = enabled;
    if (!enabled) {
      _engine.unlock();
      state = state.copyWith(isEnabled: false, isLocked: false);
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
