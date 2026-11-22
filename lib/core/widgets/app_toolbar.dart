import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';

/// HIG Grouped Glass Toolbar for screen headers
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
              if (actions.isNotEmpty)
                AppToolbarButtonGroup(buttons: actions),
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

/// A cluster of icon buttons encased in a single unified glass capsule
class AppToolbarButtonGroup extends ConsumerWidget {
  final List<Widget> buttons;

  const AppToolbarButtonGroup({
    super.key,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final isDark = mode.isDark;

    Widget container = Container(
      height: PoswalRowHeights.minTouchTarget,
      padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.xs),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(
          alpha: PoswalGlass.tintOpacity(GlassTier.standard, isDark: isDark),
        ),
        borderRadius: BorderRadius.circular(PoswalRadii.capsule),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(
            alpha: PoswalGlass.borderOpacity(GlassTier.standard, isDark: isDark),
          ),
          width: PoswalGlass.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: buttons,
      ),
    );

    if (!reduceTransparency && !mode.isOled) {
      final sigma = PoswalGlass.blurSigma(GlassTier.standard);
      return ClipRRect(
        borderRadius: BorderRadius.circular(PoswalRadii.capsule),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: container,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(PoswalRadii.capsule),
      child: Container(
        color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
        child: container,
      ),
    );
  }
}

/// HIG-Aligned Top Trailing Frosted Glass "+" Button
class AppToolbarAddButton extends ConsumerStatefulWidget {
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
  ConsumerState<AppToolbarAddButton> createState() => _AppToolbarAddButtonState();
}

class _AppToolbarAddButtonState extends ConsumerState<AppToolbarAddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) {
      if (mounted) _controller.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appThemeModeProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final isDark = mode.isDark;

    Widget buttonContent = Container(
      width: PoswalRowHeights.minTouchTarget,
      height: PoswalRowHeights.minTouchTarget,
      decoration: BoxDecoration(
        color: PoswalColors.teal.withValues(alpha: isDark ? 0.22 : 0.15),
        borderRadius: BorderRadius.circular(PoswalRadii.capsule),
        border: Border.all(
          color: PoswalColors.teal.withValues(alpha: isDark ? 0.40 : 0.30),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: Icon(
          PhosphorIconsBold.plus,
          color: PoswalColors.teal,
          size: 20,
        ),
      ),
    );

    if (!reduceTransparency && !mode.isOled) {
      final sigma = PoswalGlass.blurSigma(GlassTier.premium);
      buttonContent = ClipRRect(
        borderRadius: BorderRadius.circular(PoswalRadii.capsule),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: buttonContent,
        ),
      );
    }

    return Semantics(
      button: true,
      label: widget.tooltip,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          key: widget.buttonKey ?? const ValueKey('app_toolbar_add_btn'),
          onTap: _handleTap,
          behavior: HitTestBehavior.opaque,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
