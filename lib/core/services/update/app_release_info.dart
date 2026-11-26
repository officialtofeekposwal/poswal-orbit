class AppReleaseInfo {
  final String tagName;
  final String title;
  final String releaseNotes;
  final String apkDownloadUrl;
  final String htmlUrl;
  final DateTime publishedAt;

  const AppReleaseInfo({
    required this.tagName,
    required this.title,
    required this.releaseNotes,
    required this.apkDownloadUrl,
    required this.htmlUrl,
    required this.publishedAt,
  });

  factory AppReleaseInfo.fromJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String? ?? '';
    final htmlUrl = json['html_url'] as String? ?? '';

    String apkUrl = '';
    final assets = json['assets'] as List<dynamic>? ?? const [];
    for (final rawAsset in assets) {
      if (rawAsset is Map<String, dynamic>) {
        final name = rawAsset['name'] as String? ?? '';
        if (name.endsWith('.apk') && !name.contains('debug')) {
          apkUrl = rawAsset['browser_download_url'] as String? ?? '';
          break;
        }
      }
    }
    if (apkUrl.isEmpty) {
      for (final rawAsset in assets) {
        if (rawAsset is Map<String, dynamic>) {
          final name = rawAsset['name'] as String? ?? '';
          if (name.endsWith('.apk')) {
            apkUrl = rawAsset['browser_download_url'] as String? ?? '';
            break;
          }
        }
      }
    }

    return AppReleaseInfo(
      tagName: tagName,
      title: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : tagName,
      releaseNotes: (json['body'] as String? ?? '').trim(),
      apkDownloadUrl: apkUrl,
      htmlUrl: htmlUrl,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
