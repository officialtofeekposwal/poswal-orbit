import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/liquid_glass.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

/// Feature flag for alternative floating-button tab bar style.
const bool kUseFloatingButtonTabBar = false;

/// Provider to track scroll direction for auto-minimizing navigation bars.
class ScrollMinimizerNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = expanded, true = minimized

  void onScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        if (!state) state = true; // scroll down -> minimize
      } else if (notification.direction == ScrollDirection.forward) {
        if (state) state = false; // scroll up -> expand
      }
    }
  }

  void expand() {
    if (state) state = false;
  }
}

final scrollMinimizerProvider =
    NotifierProvider<ScrollMinimizerNotifier, bool>(ScrollMinimizerNotifier.new);

class TabItemData {
  final IconData regularIcon;
  final IconData fillIcon;
  final String label;

  const TabItemData({
    required this.regularIcon,
    required this.fillIcon,
    required this.label,
  });
}

class _SpringCurve extends Curve {
  final SpringSimulation _sim;

  _SpringCurve()
      : _sim = SpringSimulation(
          const SpringDescription(mass: 1.0, stiffness: 320.0, damping: 24.0),
          0.0,
          1.0,
          0.0,
        );

  @override
  double transformInternal(double t) => _sim.x(t).clamp(0.0, 1.15);
}

/// Floating Liquid Glass Tab Bar with sliding spring lens indicator.
class AppTabBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<TabItemData>? tabs;

  const AppTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.tabs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(appThemeModeProvider);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final isMinimized = ref.watch(scrollMinimizerProvider);

    final effectiveTabs = tabs ??
        [
          TabItemData(
            regularIcon: PhosphorIconsRegular.circleHalfTilt,
            fillIcon: PhosphorIconsFill.circleHalfTilt,
            label: l10n?.tabToday ?? 'Today',
          ),
          TabItemData(
            regularIcon: PhosphorIconsRegular.target,
            fillIcon: PhosphorIconsFill.target,
            label: l10n?.tabHabits ?? 'Habits',
          ),
          TabItemData(
            regularIcon: PhosphorIconsRegular.checkSquare,
            fillIcon: PhosphorIconsFill.checkSquare,
            label: l10n?.tabTasks ?? 'Tasks',
          ),
          TabItemData(
            regularIcon: PhosphorIconsRegular.notepad,
            fillIcon: PhosphorIconsFill.notepad,
            label: l10n?.tabNotes ?? 'Notes',
          ),
          TabItemData(
            regularIcon: PhosphorIconsRegular.chartLineUp,
            fillIcon: PhosphorIconsFill.chartLineUp,
            label: l10n?.tabInsights ?? 'Insights',
          ),
        ];

    final isDark = mode.isDark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final barHeight = isMinimized ? 50.0 : PoswalRowHeights.tabBar;
    final clampedIndex = currentIndex.clamp(0, effectiveTabs.length - 1);

    if (kUseFloatingButtonTabBar) {
      return _buildFloatingButtonBar(
        context: context,
        effectiveTabs: effectiveTabs,
        clampedIndex: clampedIndex,
        isDark: isDark,
        bottomInset: bottomInset,
      );
    }

    final activeAccent = isDark ? PoswalColors.teal : PoswalColors.tealLight;

    final Widget barContent = LiquidGlass(
      isCapsule: true,
      height: barHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: PoswalSpacing.xs,
        vertical: PoswalSpacing.xs,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = effectiveTabs.length;
          final slotWidth = constraints.maxWidth / count;
          final lensLeft = slotWidth * clampedIndex;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: reduceMotion ? Curves.linear : _SpringCurve(),
                left: lensLeft,
                top: 0,
                bottom: 0,
                width: slotWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: activeAccent.withValues(alpha: isDark ? 0.18 : 0.14),
                    borderRadius: BorderRadius.circular(PoswalRadii.capsule),
                  ),
                ),
              ),
              Row(
                children: List.generate(count, (index) {
                  return Expanded(
                    child: _TabItemButton(
                      index: index,
                      item: effectiveTabs[index],
                      isSelected: index == clampedIndex,
                      isMinimized: isMinimized,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTabSelected(index);
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 14,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                (isDark ? PoswalColors.ink : PoswalColors.mist)
                    .withValues(alpha: 0.6),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: PoswalSpacing.lg,
            right: PoswalSpacing.lg,
            bottom:
                bottomInset > 0 ? bottomInset + PoswalSpacing.xs : PoswalSpacing.md,
          ),
          child: barContent,
        ),
      ],
    );
  }

  Widget _buildFloatingButtonBar({
    required BuildContext context,
    required List<TabItemData> effectiveTabs,
    required int clampedIndex,
    required bool isDark,
    required double bottomInset,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: PoswalSpacing.lg,
        right: PoswalSpacing.lg,
        bottom:
            bottomInset > 0 ? bottomInset + PoswalSpacing.xs : PoswalSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(effectiveTabs.length, (index) {
          return LiquidGlass(
            isCapsule: true,
            width: PoswalRowHeights.minTouchTarget + 8,
            height: PoswalRowHeights.minTouchTarget + 8,
            child: _TabItemButton(
              index: index,
              item: effectiveTabs[index],
              isSelected: index == clampedIndex,
              isMinimized: true,
              isDark: isDark,
              onTap: () {
                HapticFeedback.selectionClick();
                onTabSelected(index);
              },
            ),
          );
        }),
      ),
    );
  }
}

class _TabItemButton extends StatelessWidget {
  final int index;
  final TabItemData item;
  final bool isSelected;
  final bool isMinimized;
  final bool isDark;
  final VoidCallback onTap;

  const _TabItemButton({
    required this.index,
    required this.item,
    required this.isSelected,
    required this.isMinimized,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? PoswalColors.teal : PoswalColors.tealLight;
    final inactiveColor =
        isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final l10n = AppLocalizations.of(context);
    final String label = switch (index) {
      0 => l10n?.tabToday ?? item.label,
      1 => l10n?.tabHabits ?? item.label,
      2 => l10n?.tabTasks ?? item.label,
      3 => l10n?.tabNotes ?? item.label,
      4 => l10n?.tabInsights ?? item.label,
      _ => item.label,
    };

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label tab',
      child: GestureDetector(
        key: ValueKey('tab_item_$index'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: PoswalRowHeights.minTouchTarget,
            minHeight: PoswalRowHeights.minTouchTarget,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? item.fillIcon : item.regularIcon,
                  size: isMinimized ? 20 : 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                if (!isMinimized) ...[
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PoswalText.caption2.copyWith(
                      color: isSelected ? activeColor : inactiveColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
