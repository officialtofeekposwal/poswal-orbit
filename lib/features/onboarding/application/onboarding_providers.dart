import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

const String kOnboardingCompletedKey = 'orbit_onboarding_completed';

class OnboardingNotifier extends Notifier<bool> {
  final AppDatabase? _injectedDb;

  OnboardingNotifier([this._injectedDb]);

  @override
  bool build() {
    final db = _injectedDb ?? _resolveDb();
    _load(db);
    return false;
  }

  AppDatabase? _resolveDb() {
    try {
      return ref.watch(databaseProvider);
    } catch (_) {
      return null;
    }
  }

  Future<void> _load(AppDatabase? db) async {
    if (db == null) return;
    try {
      final query = db.select(db.appSettingsTable)
        ..where((tbl) => tbl.key.equals(kOnboardingCompletedKey));
      final row = await query.getSingleOrNull();
      if (row != null) {
        state = row.value == 'true';
      }
    } catch (_) {}
  }

  Future<void> completeOnboarding() async {
    state = true;
    final db = _injectedDb ?? _resolveDb();
    if (db == null) return;
    try {
      await db.into(db.appSettingsTable).insertOnConflictUpdate(
        AppSettingsTableCompanion.insert(
          key: kOnboardingCompletedKey,
          value: 'true',
          updatedAt: DateTime.now(),
        ),
      );
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    state = false;
    final db = _injectedDb ?? _resolveDb();
    if (db == null) return;
    try {
      await db.into(db.appSettingsTable).insertOnConflictUpdate(
        AppSettingsTableCompanion.insert(
          key: kOnboardingCompletedKey,
          value: 'false',
          updatedAt: DateTime.now(),
        ),
      );
    } catch (_) {}
  }

  void setCompleted(bool completed) {
    state = completed;
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
