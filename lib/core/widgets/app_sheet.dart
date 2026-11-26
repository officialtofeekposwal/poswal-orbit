import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/liquid_glass.dart';

/// Standard sheet detents.
enum AppSheetDetent {
  medium,
  large,
}

/// Inset sheet with Liquid Glass header/grabber and medium/large detents.
class AppSheet extends ConsumerWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final bool isFullHeight;
  final AppSheetDetent detent;

  const AppSheet({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.isFullHeight = false,
    this.detent = AppSheetDetent.medium,
  });

  /// Displays a modal sheet that allows parent content to peek through.
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
    final isDark = mode.isDark;
    final textPrimary =
        isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final topInset = MediaQuery.paddingOf(context).top;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final effectiveDetent =
        isFullHeight ? AppSheetDetent.large : detent;
    final double maxSheetHeight = effectiveDetent == AppSheetDetent.large
        ? screenHeight - (topInset + PoswalSpacing.xxl)
        : (screenHeight * 0.62).clamp(320.0, screenHeight - topInset - 32.0);

    final Color surfaceColor = isDark
        ? (mode.isOled ? const Color(0xFF0C0C0E) : PoswalColors.surfaceDark)
        : PoswalColors.surfaceLight;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(PoswalRadii.sheet),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(PoswalRadii.sheet),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glass header and grabber
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PoswalSpacing.md,
                  PoswalSpacing.sm,
                  PoswalSpacing.md,
                  PoswalSpacing.xs,
                ),
                child: LiquidGlass(
                  borderRadius: PoswalRadii.card,
                  padding: EdgeInsets.symmetric(
                    horizontal: PoswalSpacing.md,
                    vertical: title != null ? PoswalSpacing.sm : PoswalSpacing.xs,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? PoswalColors.textSecondaryDark
                                    : PoswalColors.textSecondaryLight)
                                .withValues(alpha: 0.45),
                            borderRadius:
                                BorderRadius.circular(PoswalRadii.pill),
                          ),
                        ),
                      ),
                      if (title != null) ...[
                        const SizedBox(height: PoswalSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title!,
                                style: PoswalText.headline.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ?trailing,
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

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
        ),
      ),
    );
  }
}
