import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/liquid_glass.dart';

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

/// Floating Liquid Glass Menu / Popover
class AppMenu extends ConsumerWidget {
  final List<AppMenuItem> items;
  final double width;

  const AppMenu({
    super.key,
    required this.items,
    this.width = 220.0,
  });

  /// Displays a glass popover menu at [position].
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
    final isDark = mode.isDark;
    final textPrimary =
        isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final dangerColor = isDark ? PoswalColors.danger : PoswalColors.dangerLight;

    return LiquidGlass(
      width: width,
      borderRadius: PoswalRadii.card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final color = item.isDestructive ? dangerColor : textPrimary;

          return Semantics(
            button: true,
            label: item.title,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  item.onTap();
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: PoswalRowHeights.minTouchTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PoswalSpacing.md,
                      vertical: PoswalSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(item.icon, size: 20, color: color),
                          const SizedBox(width: PoswalSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            item.title,
                            style: PoswalText.callout.copyWith(
                              color: color,
                              fontWeight: item.isDestructive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
