import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/liquid_glass.dart';

/// Grouped Liquid Glass toolbar for screen headers.
class AppToolbar extends ConsumerWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget> actions;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final String? addTooltip;
  final Key? addKey;

  const AppToolbar({
    super.key,
    this.leading,
    this.title,
    this.actions = const [],
    this.showAddButton = false,
    this.onAddPressed,
    this.addTooltip,
    this.addKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PoswalSpacing.lg,
        vertical: PoswalSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ?leading,
          if (title != null) Expanded(child: title!),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actions.isNotEmpty) AppToolbarButtonGroup(buttons: actions),
              if (showAddButton && onAddPressed != null) ...[
                const SizedBox(width: PoswalSpacing.sm),
                AppToolbarAddButton(
                  buttonKey: addKey,
                  onPressed: onAddPressed!,
                  tooltip: addTooltip ?? 'Add Item',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A cluster of icon buttons encased in a unified Liquid Glass capsule.
class AppToolbarButtonGroup extends ConsumerWidget {
  final List<Widget> buttons;

  const AppToolbarButtonGroup({
    super.key,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LiquidGlass(
      isCapsule: true,
      height: PoswalRowHeights.minTouchTarget,
      padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: buttons,
      ),
    );
  }
}

/// Top trailing Liquid Glass "+" button with 44x44 minimum touch target.
class AppToolbarAddButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final Key? buttonKey;

  const AppToolbarAddButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Add',
    this.buttonKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final isDark = mode.isDark;
    final accent = isDark ? PoswalColors.teal : PoswalColors.tealLight;

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: LiquidGlass(
          key: buttonKey ?? const ValueKey('app_toolbar_add_btn'),
          isCapsule: true,
          width: PoswalRowHeights.minTouchTarget,
          height: PoswalRowHeights.minTouchTarget,
          tintColor: accent.withValues(alpha: isDark ? 0.24 : 0.16),
          onTap: onPressed,
          child: Center(
            child: Icon(
              PhosphorIconsRegular.plus,
              color: accent,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
