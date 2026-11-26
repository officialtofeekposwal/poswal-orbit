import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/services/update/app_release_info.dart';
import 'package:poswal_orbit/core/services/update/update_providers.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_sheet.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateBottomSheet extends ConsumerWidget {
  final AppReleaseInfo release;

  const UpdateBottomSheet({
    super.key,
    required this.release,
  });

  static Future<void> show(BuildContext context, AppReleaseInfo release) {
    return AppSheet.show<void>(
      context: context,
      builder: (_) => UpdateBottomSheet(release: release),
    );
  }

  Future<void> _launchDownload(BuildContext context) async {
    await HapticFeedback.lightImpact();
    final target = release.apkDownloadUrl.isNotEmpty
        ? release.apkDownloadUrl
        : (release.htmlUrl.isNotEmpty
            ? release.htmlUrl
            : 'https://github.com/officialtofeekposwal/poswal-orbit/releases/tag/${release.tagName}');
    final uri = Uri.tryParse(target);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final accentColor = isDark ? PoswalColors.teal : PoswalColors.tealLight;

    return AppSheet(
      title: l10n?.updateAvailableTitle ?? 'Update available',
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: PoswalSpacing.lg,
          vertical: PoswalSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsRegular.arrowCircleUp, color: accentColor, size: 24),
                const SizedBox(width: PoswalSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        release.title,
                        style: PoswalText.headline.copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: PoswalSpacing.xxs),
                      Text(
                        l10n?.updateVersionSubtitle(release.tagName) ??
                            'Version ${release.tagName} is ready to download',
                        style: PoswalText.caption.copyWith(color: textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (release.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: PoswalSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Text(
                    release.releaseNotes,
                    style: PoswalText.callout.copyWith(color: textMuted),
                  ),
                ),
              ),
            ],
            const SizedBox(height: PoswalSpacing.lg),
            FilledButton(
              key: const ValueKey('update_download_btn'),
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: isDark ? PoswalColors.ink : PoswalColors.surfaceLight,
                minimumSize: const Size.fromHeight(PoswalRowHeights.standard),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PoswalRadii.button),
                ),
              ),
              onPressed: () => _launchDownload(context),
              child: Text(
                l10n?.updateDownloadBtn ?? 'Download update',
                style: PoswalText.callout.copyWith(
                  color: isDark ? PoswalColors.ink : PoswalColors.surfaceLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: PoswalSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('update_later_btn'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(PoswalRowHeights.compact),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PoswalRadii.button),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      l10n?.updateLaterBtn ?? 'Later',
                      style: PoswalText.callout.copyWith(color: textPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: PoswalSpacing.sm),
                Expanded(
                  child: TextButton(
                    key: const ValueKey('update_skip_btn'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(PoswalRowHeights.compact),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(PoswalRadii.button),
                      ),
                    ),
                    onPressed: () async {
                      await ref.read(appUpdateServiceProvider).skipVersion(release.tagName);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      l10n?.updateSkipVersionBtn ?? 'Skip this version',
                      style: PoswalText.callout.copyWith(color: textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
