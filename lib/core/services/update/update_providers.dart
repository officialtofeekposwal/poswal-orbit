import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/services/update/app_update_service.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  final db = ref.watch(databaseProvider);
  return AppUpdateService(db);
});

class AutoUpdateCheckNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.watch(appUpdateServiceProvider).isAutoCheckEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    state = AsyncValue.data(enabled);
    await ref.read(appUpdateServiceProvider).setAutoCheckEnabled(enabled);
  }
}

final autoUpdateCheckProvider =
    AsyncNotifierProvider<AutoUpdateCheckNotifier, bool>(AutoUpdateCheckNotifier.new);
