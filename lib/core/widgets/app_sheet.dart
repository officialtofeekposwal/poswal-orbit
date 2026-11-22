import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';

/// HIG-Compliant Inset Glass Sheet
class AppSheet extends ConsumerWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final bool isFullHeight;

  const AppSheet({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.isFullHeight = false,
  });

  /// Displays an inset half-sheet that allows parent content to peek through
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => builder(ctx),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final isDark = mode.isDark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final topInset = MediaQuery.paddingOf(context).top;

    // Sheet Corner Radius
    const outerRadius = PoswalRadii.sheet;

    Widget sheetContainer = Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height - (topInset + 32.0),
      ),
      decoration: BoxDecoration(
        color: (isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight).withValues(
          alpha: isFullHeight ? 0.98 : (isDark ? 0.88 : 0.92),
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(outerRadius),
        ),
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: isDark ? 0.16 : 0.08,
            ),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: PoswalSpacing.sm),
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(PoswalRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: PoswalSpacing.xs),

          // Optional Title Header
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PoswalSpacing.lg,
                vertical: PoswalSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title!,
                    style: PoswalText.headline.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
          ],

          // Sheet Content
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: bottomInset > 0 ? bottomInset : PoswalSpacing.md,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );

    if (!reduceTransparency && !mode.isOled) {
      final sigma = PoswalGlass.blurSigma(GlassTier.premium);
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(outerRadius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: sheetContainer,
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(outerRadius)),
      child: sheetContainer,
    );
  }
}
