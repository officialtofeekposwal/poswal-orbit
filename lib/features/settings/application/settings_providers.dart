import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/services/data_safety_service.dart';
import 'package:poswal_orbit/data/services/notification_service.dart';
import 'package:poswal_orbit/domain/models/data_safety_models.dart';
import 'package:poswal_orbit/features/settings/domain/settings_preferences.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class SettingsNotifier extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    return const AppSettingsState();
  }

  Future<void> loadPersistedLanguage() async {
    try {
      final db = ref.read(databaseProvider);
      final row = await (db.select(db.appSettingsTable)..where((t) => t.key.equals('app_language'))).getSingleOrNull();
      if (row != null && row.value.isNotEmpty) {
        final lang = AppLanguageOption.values.firstWhere(
          (l) => l.locale?.languageCode == row.value,
          orElse: () => AppLanguageOption.system,
        );
        state = state.copyWith(language: lang);
      }
    } catch (_) {}
  }

  void updateThemeMode(ThemeModeOption mode) {
    state = state.copyWith(themeMode: mode);
    // Sync with existing theme provider
    switch (mode) {
      case ThemeModeOption.light:
        ref.read(appThemeModeProvider.notifier).setMode(AppThemeMode.light);
        break;
      case ThemeModeOption.dark:
      case ThemeModeOption.system:
        ref.read(appThemeModeProvider.notifier).setMode(AppThemeMode.dark);
        break;
      case ThemeModeOption.oled:
        ref.read(appThemeModeProvider.notifier).setMode(AppThemeMode.oled);
        break;
    }
  }

  void updateAccent(AccentColorOption accent) {
    state = state.copyWith(accent: accent);
  }

  void updateGlassIntensity(double intensity) {
    state = state.copyWith(glassIntensity: intensity.clamp(0.0, 1.0));
  }

  void updateReduceTransparency(bool reduce) {
    state = state.copyWith(reduceTransparency: reduce);
  }

  void updateDayStartHour(int hour) {
    state = state.copyWith(dayStartHour: hour.clamp(0, 23));
  }

  void updateFirstDayOfWeek(int day) {
    state = state.copyWith(firstDayOfWeek: day);
  }

  void updateHaptics(bool enabled) {
    state = state.copyWith(hapticsEnabled: enabled);
  }

  void updateLanguage(AppLanguageOption language, {AppDatabase? db}) {
    state = state.copyWith(language: language);
    final langCode = language.locale?.languageCode ?? 'en';
    final targetDb = db;
    if (targetDb != null) {
      try {
        targetDb.into(targetDb.appSettingsTable).insertOnConflictUpdate(
              AppSettingsTableCompanion.insert(
                key: 'app_language',
                value: langCode,
                updatedAt: DateTime.now(),
              ),
            );
        ref.read(notificationServiceProvider).refillRollingWindow(languageCode: langCode);
      } catch (_) {}
    }
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettingsState>(
  SettingsNotifier.new,
);

final availableBackupsProvider = FutureProvider.autoDispose<List<BackupFileInfo>>((ref) async {
  final safetyService = ref.watch(dataSafetyServiceProvider);
  return safetyService.listAvailableBackups();
});
