import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/services/update/app_update_service.dart';
import 'package:poswal_orbit/data/database/database.dart';

void main() {
  late AppDatabase db;
  late DateTime fakeNow;
  late int networkCalls;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fakeNow = DateTime(2026, 11, 26, 12, 0);
    networkCalls = 0;
  });

  tearDown(() async {
    await db.close();
  });

  String releaseJson(String tag, {String name = 'Release'}) => jsonEncode({
        'tag_name': tag,
        'name': name,
        'body': 'Bug fixes and improvements',
        'html_url': 'https://github.com/officialtofeekposwal/poswal-orbit/releases/tag/$tag',
        'published_at': '2026-11-26T10:00:00Z',
        'assets': [
          {
            'name': 'poswal-orbit-$tag.apk',
            'browser_download_url':
                'https://github.com/officialtofeekposwal/poswal-orbit/releases/download/$tag/poswal-orbit-$tag.apk',
          }
        ],
      });

  AppUpdateService createService({
    required String currentVersion,
    required String remoteTag,
  }) {
    return AppUpdateService(
      db,
      now: () => fakeNow,
      versionReader: () async => currentVersion,
      httpGet: (uri, headers) async {
        networkCalls++;
        if (uri.path.endsWith('/latest')) {
          return (statusCode: 200, body: releaseJson(remoteTag, name: 'Beta 3 $remoteTag'));
        }
        return (statusCode: 200, body: jsonEncode([jsonDecode(releaseJson(remoteTag))]));
      },
    );
  }

  group('AppUpdateService', () {
    test('detects newer pre-release beta.3 over beta.2 and persists last check', () async {
      final service = createService(
        currentVersion: '0.9.1-beta.2+2',
        remoteTag: 'v0.9.1-beta.3',
      );

      final update = await service.checkForUpdate();
      expect(update, isNotNull);
      expect(update!.tagName, 'v0.9.1-beta.3');
      expect(networkCalls, 1);

      final lastCheck = await service.getLastCheckEpoch();
      expect(lastCheck, fakeNow.millisecondsSinceEpoch);
    });

    test('throttles automatic checks within 24 hours without network call', () async {
      final service = createService(
        currentVersion: '0.9.1-beta.2+2',
        remoteTag: 'v0.9.1-beta.3',
      );

      await service.checkForUpdate();
      expect(networkCalls, 1);

      // 6 hours later: throttled
      fakeNow = fakeNow.add(const Duration(hours: 6));
      final second = await service.checkForUpdate();
      expect(second, isNull);
      expect(networkCalls, 1);

      // Manual force bypasses throttle
      final forced = await service.checkForUpdate(force: true);
      expect(forced, isNotNull);
      expect(networkCalls, 2);
    });

    test('respects skipped tag on automatic check, shows on manual check', () async {
      final service = createService(
        currentVersion: '0.9.1-beta.2+2',
        remoteTag: 'v0.9.1-beta.3',
      );

      await service.skipVersion('v0.9.1-beta.3');
      expect(await service.getSkippedTag(), 'v0.9.1-beta.3');

      final autoCheck = await service.checkForUpdate();
      expect(autoCheck, isNull);

      final manualCheck = await service.checkForUpdate(force: true);
      expect(manualCheck, isNotNull);
      expect(manualCheck!.tagName, 'v0.9.1-beta.3');
    });

    test('disables automatic check when auto_check_enabled is false', () async {
      final service = createService(
        currentVersion: '0.9.1-beta.2+2',
        remoteTag: 'v0.9.1-beta.3',
      );

      await service.setAutoCheckEnabled(false);
      expect(await service.isAutoCheckEnabled(), isFalse);

      final autoCheck = await service.checkForUpdate();
      expect(autoCheck, isNull);
      expect(networkCalls, 0);

      // Manual check still works
      final manualCheck = await service.checkForUpdate(force: true);
      expect(manualCheck, isNotNull);
      expect(networkCalls, 1);
    });

    test('returns errorOfflineOrTimeout on SocketException and TimeoutException', () async {
      final offlineService = AppUpdateService(
        db,
        now: () => fakeNow,
        versionReader: () async => '0.9.1-beta.2+2',
        httpGet: (_, _) async => throw const SocketException('No internet'),
      );
      final offlineRes = await offlineService.checkForUpdateWithStatus(force: true);
      expect(offlineRes.status, UpdateCheckStatus.errorOfflineOrTimeout);
      expect(await offlineService.checkForUpdate(), isNull);

      final timeoutService = AppUpdateService(
        db,
        now: () => fakeNow,
        versionReader: () async => '0.9.1-beta.2+2',
        httpGet: (_, _) async => throw TimeoutException('Timed out'),
      );
      final timeoutRes = await timeoutService.checkForUpdateWithStatus(force: true);
      expect(timeoutRes.status, UpdateCheckStatus.errorOfflineOrTimeout);
    });

    test('returns errorRateLimited on HTTP 403 and 429', () async {
      for (final code in [403, 429]) {
        final rateLimitService = AppUpdateService(
          db,
          now: () => fakeNow,
          versionReader: () async => '0.9.1-beta.2+2',
          httpGet: (_, _) async => (statusCode: code, body: 'Rate limit exceeded'),
        );
        final res = await rateLimitService.checkForUpdateWithStatus(force: true);
        expect(res.status, UpdateCheckStatus.errorRateLimited);
        expect(await rateLimitService.checkForUpdate(), isNull);
      }
    });

    test('returns errorInvalidResponse on HTTP 404 and invalid JSON', () async {
      final notFoundService = AppUpdateService(
        db,
        now: () => fakeNow,
        versionReader: () async => '0.9.1-beta.2+2',
        httpGet: (_, _) async => (statusCode: 404, body: '{"message": "Not Found"}'),
      );
      final notFoundRes = await notFoundService.checkForUpdateWithStatus(force: true);
      expect(notFoundRes.status, UpdateCheckStatus.errorInvalidResponse);

      final invalidJsonService = AppUpdateService(
        db,
        now: () => fakeNow,
        versionReader: () async => '0.9.1-beta.2+2',
        httpGet: (_, _) async => (statusCode: 200, body: '{not valid json'),
      );
      final invalidJsonRes = await invalidJsonService.checkForUpdateWithStatus(force: true);
      expect(invalidJsonRes.status, UpdateCheckStatus.errorInvalidResponse);
      expect(await invalidJsonService.checkForUpdate(), isNull);
    });
  });
}
