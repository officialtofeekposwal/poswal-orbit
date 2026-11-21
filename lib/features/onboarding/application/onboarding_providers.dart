import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String kOnboardingCompletedKey = 'orbit_onboarding_completed';

class OnboardingNotifier extends Notifier<bool> {
  final FlutterSecureStorage _storage;

  OnboardingNotifier([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    try {
      final val = await _storage.read(key: kOnboardingCompletedKey);
      if (val != null) {
        state = val == 'true';
      }
    } catch (_) {}
  }

  Future<void> completeOnboarding() async {
    state = true;
    try {
      await _storage.write(key: kOnboardingCompletedKey, value: 'true');
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    state = false;
    try {
      await _storage.write(key: kOnboardingCompletedKey, value: 'false');
    } catch (_) {}
  }

  void setCompleted(bool completed) {
    state = completed;
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
