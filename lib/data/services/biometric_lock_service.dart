import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:poswal_orbit/domain/logic/biometric_lock_engine.dart';

class BiometricLockService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _storage;

  static const String _keyEnabled = 'orbit_biometric_enabled';
  static const String _keyTimeout = 'orbit_lock_timeout_seconds';
  static const String _keyHideRecents = 'orbit_hide_recents_enabled';

  static const MethodChannel _securityChannel = MethodChannel('com.poswal.orbit/security');

  BiometricLockService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? storage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _storage = storage ?? const FlutterSecureStorage();

  /// Check if hardware supports biometrics or device credentials
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return isSupported || canCheck;
    } catch (e) {
      debugPrint('[BiometricLockService] isDeviceSupported error: $e');
      return false;
    }
  }

  /// Get list of available hardware biometrics (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('[BiometricLockService] getAvailableBiometrics error: $e');
      return [];
    }
  }

  /// Perform authentication prompt with device passcode fallback returning detailed result
  Future<BiometricAuthResult> authenticateDetailed({
    String localizedReason = 'Unlock Poswal Orbit to view your habits and notes',
  }) async {
    try {
      final success = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false, // Allows device PIN/passcode fallback
        persistAcrossBackgrounding: true,
      );
      if (success) {
        return const BiometricAuthResult(status: BiometricAuthStatus.success);
      } else {
        return const BiometricAuthResult(
          status: BiometricAuthStatus.failed,
          errorMessage: 'Authentication was not successful. Please try again or use your passcode.',
        );
      }
    } catch (e) {
      debugPrint('[BiometricLockService] authenticate error: $e');
      return BiometricAuthResult.fromException(e);
    }
  }

  /// Perform authentication prompt with device passcode fallback
  Future<bool> authenticate({
    String localizedReason = 'Unlock Poswal Orbit to view your habits and notes',
  }) async {
    final res = await authenticateDetailed(localizedReason: localizedReason);
    return res.isSuccess;
  }

  /// Emergency disable lock in storage when hardware is unavailable
  Future<void> emergencyDisableLock() async {
    try {
      await _storage.write(key: _keyEnabled, value: 'false');
    } catch (e) {
      debugPrint('[BiometricLockService] emergencyDisableLock error: $e');
    }
  }

  /// Read stored enabled state
  Future<bool> isBiometricEnabled() async {
    try {
      final val = await _storage.read(key: _keyEnabled);
      return val == 'true';
    } catch (e) {
      debugPrint('[BiometricLockService] isBiometricEnabled read error: $e');
      return false;
    }
  }

  /// Store enabled state
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(key: _keyEnabled, value: enabled ? 'true' : 'false');
    } catch (e) {
      debugPrint('[BiometricLockService] setBiometricEnabled error: $e');
    }
  }

  /// Read stored lock timeout
  Future<LockTimeout> getLockTimeout() async {
    try {
      final val = await _storage.read(key: _keyTimeout);
      if (val == null) return LockTimeout.immediate;
      final seconds = int.tryParse(val) ?? 0;
      return LockTimeout.fromSeconds(seconds);
    } catch (e) {
      return LockTimeout.immediate;
    }
  }

  /// Store lock timeout
  Future<void> setLockTimeout(LockTimeout timeout) async {
    try {
      await _storage.write(key: _keyTimeout, value: timeout.seconds.toString());
    } catch (e) {
      debugPrint('[BiometricLockService] setLockTimeout error: $e');
    }
  }

  /// Read stored hide content in recents setting
  Future<bool> isHideContentInRecents() async {
    try {
      final val = await _storage.read(key: _keyHideRecents);
      return val == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Store hide content in recents setting & update window flags
  Future<void> setHideContentInRecents(bool hide) async {
    try {
      await _storage.write(key: _keyHideRecents, value: hide ? 'true' : 'false');
      await applyRecentsPrivacy(hide);
    } catch (e) {
      debugPrint('[BiometricLockService] setHideContentInRecents error: $e');
    }
  }

  /// Platform channel call to enable/disable FLAG_SECURE on Android
  Future<void> applyRecentsPrivacy(bool hide) async {
    try {
      await _securityChannel.invokeMethod('setFlagSecure', {'secure': hide});
    } on MissingPluginException {
      // Ignored on platforms or test environments where channel is not registered
    } catch (e) {
      debugPrint('[BiometricLockService] applyRecentsPrivacy error: $e');
    }
  }
}
