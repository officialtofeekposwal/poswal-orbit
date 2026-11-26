/// Semantic version parser and comparator supporting SemVer 2.0 pre-releases
/// (e.g. `v0.9.1-beta.2`, `0.9.1-beta.3+4`) and build numbers.
class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;
  final List<String> preReleaseParts;
  final int? buildNumber;

  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.preReleaseParts = const [],
    this.buildNumber,
  });

  bool get isPreRelease => preReleaseParts.isNotEmpty;

  static AppVersion? tryParse(String raw) {
    var trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('v') || trimmed.startsWith('V')) {
      trimmed = trimmed.substring(1);
    }

    int? buildNumber;
    final plusIndex = trimmed.indexOf('+');
    if (plusIndex != -1) {
      final buildStr = trimmed.substring(plusIndex + 1).trim();
      buildNumber = int.tryParse(buildStr);
      trimmed = trimmed.substring(0, plusIndex);
    }

    List<String> preParts = const [];
    final dashIndex = trimmed.indexOf('-');
    if (dashIndex != -1) {
      final preStr = trimmed.substring(dashIndex + 1).trim();
      if (preStr.isNotEmpty) {
        preParts = preStr.split('.');
      }
      trimmed = trimmed.substring(0, dashIndex);
    }

    final coreParts = trimmed.split('.');
    if (coreParts.isEmpty || coreParts.length > 3) return null;

    final major = int.tryParse(coreParts[0]);
    final minor = coreParts.length > 1 ? int.tryParse(coreParts[1]) : 0;
    final patch = coreParts.length > 2 ? int.tryParse(coreParts[2]) : 0;

    if (major == null || minor == null || patch == null) return null;

    return AppVersion(
      major: major,
      minor: minor,
      patch: patch,
      preReleaseParts: preParts,
      buildNumber: buildNumber,
    );
  }

  bool isNewerThan(AppVersion other) => compareTo(other) > 0;

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);

    // Stable > pre-release
    if (!isPreRelease && other.isPreRelease) return 1;
    if (isPreRelease && !other.isPreRelease) return -1;

    if (isPreRelease && other.isPreRelease) {
      final minLen = preReleaseParts.length < other.preReleaseParts.length
          ? preReleaseParts.length
          : other.preReleaseParts.length;

      for (int i = 0; i < minLen; i++) {
        final a = preReleaseParts[i];
        final b = other.preReleaseParts[i];
        if (a == b) continue;

        final aNum = int.tryParse(a);
        final bNum = int.tryParse(b);

        if (aNum != null && bNum != null) {
          return aNum.compareTo(bNum);
        }
        // Numeric identifiers have lower precedence than non-numeric identifiers
        if (aNum != null && bNum == null) return -1;
        if (aNum == null && bNum != null) return 1;
        return a.compareTo(b);
      }

      if (preReleaseParts.length != other.preReleaseParts.length) {
        return preReleaseParts.length.compareTo(other.preReleaseParts.length);
      }
    }

    // Build number comparison when core and pre-release match
    if (buildNumber != null && other.buildNumber != null) {
      return buildNumber!.compareTo(other.buildNumber!);
    }

    return 0;
  }
}
