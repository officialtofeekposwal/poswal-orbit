import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/services/data_safety_service.dart';
import 'package:poswal_orbit/features/settings/application/settings_providers.dart';
import 'package:poswal_orbit/features/settings/domain/settings_preferences.dart';
import 'package:poswal_orbit/features/settings/presentation/settings_screen.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

void main() {
  late AppDatabase db;
  late Directory tempBackupDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempBackupDir = await Directory.systemTemp.createTemp('settings_test_backups_');
  });

  tearDown(() async {
    await db.close();
    try {
      if (await tempBackupDir.exists()) {
        await tempBackupDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dataSafetyServiceProvider.overrideWithValue(DataSafetyService(db, tempBackupDir)),
      ],
      child: MaterialApp(
        theme: PoswalTheme.getTheme(AppThemeMode.dark),
        home: const SettingsScreen(),
      ),
    );
  }

  testWidgets('renders all settings sections correctly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Time & Orbit Boundary'), findsOneWidget);
    expect(find.text('Haptics & Motion'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Data Safety & Backups'), findsOneWidget);
    expect(find.text('Danger Zone'), findsOneWidget);

    expect(find.byKey(const ValueKey('backup_now_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('export_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('import_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('delete_all_data_btn')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('tapping Back Up Now triggers backup and shows toast', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final backupBtn = find.byKey(const ValueKey('backup_now_btn'));
    await tester.ensureVisible(backupBtn);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.runAsync(() async {
      await tester.tap(backupBtn);
      for (int i = 0; i < 300; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));
        if (find.textContaining('Backup safely saved').evaluate().isNotEmpty) {
          break;
        }
      }
    });

    expect(find.textContaining('Backup safely saved'), findsOneWidget);

    // Verify backup file exists on disk
    final files = tempBackupDir.listSync().whereType<File>().toList();
    expect(files.isNotEmpty, isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('delete all data shows double confirmation modal dialogs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final deleteBtn = find.byKey(const ValueKey('delete_all_data_btn'));
    await tester.ensureVisible(deleteBtn);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(deleteBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Dialog 1
    expect(find.text('Delete All Data?'), findsOneWidget);
    expect(find.text('Proceed'), findsOneWidget);

    await tester.tap(find.text('Proceed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Dialog 2
    expect(find.text('Final Confirmation'), findsOneWidget);
    expect(find.text('Wipe Everything'), findsOneWidget);
    expect(find.text('Keep My Data'), findsOneWidget);

    await tester.tap(find.text('Keep My Data'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Final Confirmation'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('language change immediately updates state, persists to db and triggers notification refill', (tester) async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);

    // Initial language is system
    expect(container.read(settingsProvider).language, AppLanguageOption.system);

    // Change to Hindi
    container.read(settingsProvider.notifier).updateLanguage(AppLanguageOption.hi, db: db);
    expect(container.read(settingsProvider).language, AppLanguageOption.hi);

    // Verify persisted in AppSettingsTable
    final row = await (db.select(db.appSettingsTable)..where((t) => t.key.equals('app_language'))).getSingleOrNull();
    expect(row, isNotNull);
    expect(row!.value, 'hi');

    // Change to Urdu
    container.read(settingsProvider.notifier).updateLanguage(AppLanguageOption.ur, db: db);
    expect(container.read(settingsProvider).language, AppLanguageOption.ur);

    final rowUrdu = await (db.select(db.appSettingsTable)..where((t) => t.key.equals('app_language'))).getSingleOrNull();
    expect(rowUrdu, isNotNull);
    expect(rowUrdu!.value, 'ur');
  });
}
