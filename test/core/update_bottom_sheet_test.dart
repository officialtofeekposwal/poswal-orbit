import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/services/update/app_release_info.dart';
import 'package:poswal_orbit/core/services/update/app_update_service.dart';
import 'package:poswal_orbit/core/services/update/update_providers.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/widgets/update_bottom_sheet.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('UpdateBottomSheet renders release details and Skip persists tag', (tester) async {
    final service = AppUpdateService(db, versionReader: () async => '0.9.1-beta.2+2');
    final release = AppReleaseInfo(
      tagName: 'v0.9.1-beta.3',
      title: 'Beta 3 v0.9.1-beta.3',
      releaseNotes: 'Fixes and performance improvements.',
      apkDownloadUrl: 'https://example.com/app.apk',
      htmlUrl: 'https://example.com/release',
      publishedAt: DateTime(2026, 11, 26),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          appUpdateServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          theme: PoswalTheme.getTheme(AppThemeMode.dark),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UpdateBottomSheet.show(context, release),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('Beta 3 v0.9.1-beta.3'), findsOneWidget);
    expect(find.text('Fixes and performance improvements.'), findsOneWidget);
    expect(find.byKey(const ValueKey('update_download_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('update_later_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('update_skip_btn')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('update_skip_btn')));
    await tester.pumpAndSettle();

    expect(await service.getSkippedTag(), 'v0.9.1-beta.3');
  });
}
