import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';

class AppMenuItem {
  final IconData? icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const AppMenuItem({
    this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// HIG Floating Glass Menu / Popover
class AppMenu extends ConsumerWidget {
  final List<AppMenuItem> items;
  final double width;

  const AppMenu({
    super.key,
    required this.items,
    this.width = 220.0,
  });

  /// Displays a glass popover menu originating from a source [targetOffset]
  static Future<void> show({
    required BuildContext context,
    required RelativeRect position,
    required List<AppMenuItem> items,
  }) {
    HapticFeedback.lightImpact();
    return showMenu(
      context: context,
      position: position,
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PoswalRadii.card),
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: AppMenu(items: items),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final isDark = mode.isDark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;

    const outerRadius = PoswalRadii.card;

    Widget menuContent = Container(
      width: width,
      decoration: BoxDecoration(
        color: (isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight).withValues(
          alpha: isDark ? 0.85 : 0.92,
        ),
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(
            alpha: isDark ? 0.16 : 0.10,
          ),
          width: PoswalGlass.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(outerRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final color = item.isDestructive ? PoswalColors.danger : textPrimary;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  item.onTap();
                },
                child: Container(
                  height: PoswalRowHeights.compact,
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
                  decoration: BoxDecoration(
                    border: index < items.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                              width: 0.5,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        Icon(item.icon, size: 18, color: color),
                        const SizedBox(width: PoswalSpacing.sm),
                      ],
                      Expanded(
                        child: Text(
                          item.title,
                          style: PoswalText.callout.copyWith(
                            color: color,
                            fontWeight: item.isDestructive ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );

    if (!reduceTransparency && !mode.isOled) {
      final sigma = PoswalGlass.blurSigma(GlassTier.premium);
      return ClipRRect(
        borderRadius: BorderRadius.circular(outerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: menuContent,
        ),
      );
    }

    return menuContent;
  }
}
