import 'dart:async';
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

enum UpdateCheckStatus {
  upToDate,
  updateAvailable,
  skippedByUser,
  throttled,
  disabled,
  errorOfflineOrTimeout,
  errorRateLimited,
  errorInvalidResponse,
}

class UpdateCheckResult {
  final UpdateCheckStatus status;
  final AppReleaseInfo? release;

  const UpdateCheckResult({
    required this.status,
    this.release,
  });
}

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
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 10));
      headers.forEach((k, v) => request.headers.set(k, v));
      final response = await request.close().timeout(const Duration(seconds: 10));
      final body = await response.transform(utf8.decoder).join().timeout(const Duration(seconds: 10));
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

  /// Convenience wrapper returning [AppReleaseInfo] only when an update is available.
  Future<AppReleaseInfo?> checkForUpdate({bool force = false}) async {
    final res = await checkForUpdateWithStatus(force: force);
    return res.status == UpdateCheckStatus.updateAvailable ? res.release : null;
  }

  /// Checks GitHub Releases for a newer release and reports detailed status.
  Future<UpdateCheckResult> checkForUpdateWithStatus({bool force = false}) async {
    final nowMs = _now().millisecondsSinceEpoch;

    if (!force) {
      final autoEnabled = await isAutoCheckEnabled();
      if (!autoEnabled) {
        return const UpdateCheckResult(status: UpdateCheckStatus.disabled);
      }

      final lastCheck = await getLastCheckEpoch();
      if (lastCheck != null && (nowMs - lastCheck) < checkIntervalMs) {
        return const UpdateCheckResult(status: UpdateCheckStatus.throttled);
      }
    }

    const headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'Poswal-Orbit-App',
    };

    try {
      final latestResp = await _httpGet(Uri.parse('$repoReleasesUrl/latest'), headers);
      await _setSetting(keyLastCheckEpoch, nowMs.toString());

      if (latestResp.statusCode == 403 || latestResp.statusCode == 429) {
        return const UpdateCheckResult(status: UpdateCheckStatus.errorRateLimited);
      }

      AppReleaseInfo? candidate;
      if (latestResp.statusCode == 200) {
        final decoded = jsonDecode(latestResp.body);
        if (decoded is! Map<String, dynamic>) {
          return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
        }
        candidate = AppReleaseInfo.fromJson(decoded);
      } else if (latestResp.statusCode == 404) {
        // Fallback: Check all releases (includes pre-releases when /latest returns 404)
        final listResp = await _httpGet(Uri.parse(repoReleasesUrl), headers);
        if (listResp.statusCode == 403 || listResp.statusCode == 429) {
          return const UpdateCheckResult(status: UpdateCheckStatus.errorRateLimited);
        }
        if (listResp.statusCode == 404) {
          return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
        }
        if (listResp.statusCode != 200) {
          return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
        }
        final decoded = jsonDecode(listResp.body);
        if (decoded is! List) {
          return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
        }
        if (decoded.isEmpty) {
          return const UpdateCheckResult(status: UpdateCheckStatus.upToDate);
        }
        if (decoded.first is! Map<String, dynamic>) {
          return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
        }
        candidate = AppReleaseInfo.fromJson(decoded.first as Map<String, dynamic>);
      } else {
        return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
      }

      if (candidate.tagName.isEmpty) {
        return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
      }

      if (!force) {
        final skipped = await getSkippedTag();
        if (skipped == candidate.tagName) {
          return const UpdateCheckResult(status: UpdateCheckStatus.skippedByUser);
        }
      }

      final currentStr = await _versionReader();
      final currentVer = AppVersion.tryParse(currentStr);
      final remoteVer = AppVersion.tryParse(candidate.tagName);

      if (currentVer == null || remoteVer == null) {
        return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
      }

      if (remoteVer.isNewerThan(currentVer)) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.updateAvailable,
          release: candidate,
        );
      }
      return const UpdateCheckResult(status: UpdateCheckStatus.upToDate);
    } on SocketException {
      return const UpdateCheckResult(status: UpdateCheckStatus.errorOfflineOrTimeout);
    } on TimeoutException {
      return const UpdateCheckResult(status: UpdateCheckStatus.errorOfflineOrTimeout);
    } on HttpException {
      return const UpdateCheckResult(status: UpdateCheckStatus.errorOfflineOrTimeout);
    } on FormatException {
      return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
    } catch (_) {
      return const UpdateCheckResult(status: UpdateCheckStatus.errorInvalidResponse);
    }
  }
}
