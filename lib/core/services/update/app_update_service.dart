import 'dart:convert';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:poswal_orbit/core/services/update/app_release_info.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/domain/logic/app_version.dart';

typedef UpdateHttpGet = Future<({int statusCode, String body})> Function(
  Uri uri,
  Map<String, String> headers,
);

typedef CurrentVersionReader = Future<String> Function();

class AppUpdateService {
  static const String repoReleasesUrl =
      'https://api.github.com/repos/officialtofeekposwal/poswal-orbit/releases';

  static const String keyLastCheckEpoch = 'update_last_check_epoch';
  static const String keySkippedTag = 'update_skipped_tag';
  static const String keyAutoCheckEnabled = 'update_auto_check_enabled';

  static const int checkIntervalMs = 86400000; // 24 hours

  final AppDatabase _db;
  final UpdateHttpGet _httpGet;
  final CurrentVersionReader _versionReader;
  final DateTime Function() _now;

  AppUpdateService(
    this._db, {
    UpdateHttpGet? httpGet,
    CurrentVersionReader? versionReader,
    DateTime Function()? now,
  })  : _httpGet = httpGet ?? _defaultHttpGet,
        _versionReader = versionReader ?? _defaultVersionReader,
        _now = now ?? DateTime.now;

  static Future<({int statusCode, String body})> _defaultHttpGet(
    Uri uri,
    Map<String, String> headers,
  ) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(uri);
      headers.forEach((k, v) => request.headers.set(k, v));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      return (statusCode: response.statusCode, body: body);
    } finally {
      client.close();
    }
  }

  static Future<String> _defaultVersionReader() async {
    final info = await PackageInfo.fromPlatform();
    if (info.buildNumber.isNotEmpty) {
      return '${info.version}+${info.buildNumber}';
    }
    return info.version;
  }

  Future<String?> _getSetting(String key) async {
    final row = await (_db.select(_db.appSettingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _setSetting(String key, String value) async {
    await _db.into(_db.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(
            key: key,
            value: value,
            updatedAt: _now(),
          ),
        );
  }

  Future<bool> isAutoCheckEnabled() async {
    final val = await _getSetting(keyAutoCheckEnabled);
    return val != 'false';
  }

  Future<void> setAutoCheckEnabled(bool enabled) async {
    await _setSetting(keyAutoCheckEnabled, enabled ? 'true' : 'false');
  }

  Future<int?> getLastCheckEpoch() async {
    final val = await _getSetting(keyLastCheckEpoch);
    return val == null ? null : int.tryParse(val);
  }

  Future<String?> getSkippedTag() async {
    return _getSetting(keySkippedTag);
  }

  Future<void> skipVersion(String tagName) async {
    await _setSetting(keySkippedTag, tagName);
  }

  Future<String> getCurrentVersionDisplay() async {
    return _versionReader();
  }

  /// Checks GitHub Releases for a newer release.
  /// Returns [AppReleaseInfo] if a newer non-skipped release is available, otherwise null.
  Future<AppReleaseInfo?> checkForUpdate({bool force = false}) async {
    final nowMs = _now().millisecondsSinceEpoch;

    if (!force) {
      final autoEnabled = await isAutoCheckEnabled();
      if (!autoEnabled) return null;

      final lastCheck = await getLastCheckEpoch();
      if (lastCheck != null && (nowMs - lastCheck) < checkIntervalMs) {
        return null;
      }
    }

    const headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'Poswal-Orbit-App',
    };

    try {
      final latestResp = await _httpGet(Uri.parse('$repoReleasesUrl/latest'), headers);
      await _setSetting(keyLastCheckEpoch, nowMs.toString());

      AppReleaseInfo? candidate;
      if (latestResp.statusCode == 200) {
        final decoded = jsonDecode(latestResp.body);
        if (decoded is Map<String, dynamic>) {
          candidate = AppReleaseInfo.fromJson(decoded);
        }
      } else {
        // Fallback: Check all releases (includes pre-releases when /latest returns 404)
        final listResp = await _httpGet(Uri.parse(repoReleasesUrl), headers);
        if (listResp.statusCode == 200) {
          final decoded = jsonDecode(listResp.body);
          if (decoded is List && decoded.isNotEmpty && decoded.first is Map<String, dynamic>) {
            candidate = AppReleaseInfo.fromJson(decoded.first as Map<String, dynamic>);
          }
        }
      }

      if (candidate == null || candidate.tagName.isEmpty) return null;

      if (!force) {
        final skipped = await getSkippedTag();
        if (skipped == candidate.tagName) return null;
      }

      final currentStr = await _versionReader();
      final currentVer = AppVersion.tryParse(currentStr);
      final remoteVer = AppVersion.tryParse(candidate.tagName);

      if (currentVer == null || remoteVer == null) return null;

      return remoteVer.isNewerThan(currentVer) ? candidate : null;
    } catch (_) {
      return null;
    }
  }
}
