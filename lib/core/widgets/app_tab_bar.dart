import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';

/// Provider to track scroll direction for auto-minimizing navigation bars
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

/// HIG Floating Glass Tab Bar with scroll-edge blur and auto-minimization
class AppTabBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<TabItemData> tabs;

  const AppTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.tabs = const [
      TabItemData(
        regularIcon: PhosphorIconsRegular.circleHalfTilt,
        fillIcon: PhosphorIconsFill.circleHalfTilt,
        label: 'Today',
      ),
      TabItemData(
        regularIcon: PhosphorIconsRegular.target,
        fillIcon: PhosphorIconsFill.target,
        label: 'Habits',
      ),
      TabItemData(
        regularIcon: PhosphorIconsRegular.checkSquare,
        fillIcon: PhosphorIconsFill.checkSquare,
        label: 'Tasks',
      ),
      TabItemData(
        regularIcon: PhosphorIconsRegular.notepad,
        fillIcon: PhosphorIconsFill.notepad,
        label: 'Notes',
      ),
      TabItemData(
        regularIcon: PhosphorIconsRegular.chartLineUp,
        fillIcon: PhosphorIconsFill.chartLineUp,
        label: 'Insights',
      ),
    ],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final isMinimized = ref.watch(scrollMinimizerProvider);

    final isDark = mode.isDark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // Outer radius for the floating bar
    const outerRadius = PoswalRadii.capsule;
    const barPadding = EdgeInsets.symmetric(horizontal: PoswalSpacing.sm, vertical: PoswalSpacing.xs);

    // Height calculation: standard vs minimized compact pill
    final barHeight = isMinimized ? 48.0 : PoswalRowHeights.tabBar;

    Widget barContent = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : PoswalDurations.standard,
      curve: PoswalCurves.standard,
      height: barHeight,
      padding: barPadding,
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(
          alpha: PoswalGlass.tintOpacity(GlassTier.standard, isDark: isDark),
        ),
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(
            alpha: PoswalGlass.borderOpacity(GlassTier.standard, isDark: isDark),
          ),
          width: PoswalGlass.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = index == currentIndex;

          return _TabItemButton(
            index: index,
            item: tab,
            isSelected: isSelected,
            isMinimized: isMinimized,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onTabSelected(index);
            },
          );
        }),
      ),
    );

    // Apply frosted blur filter when transparency reduction is off and not OLED true-black
    if (!reduceTransparency && !mode.isOled) {
      final sigma = PoswalGlass.blurSigma(GlassTier.standard);
      barContent = ClipRRect(
        borderRadius: BorderRadius.circular(outerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: barContent,
        ),
      );
    } else {
      barContent = ClipRRect(
        borderRadius: BorderRadius.circular(outerRadius),
        child: Container(
          color: isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight,
          child: barContent,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Soft scroll-edge blur mask underneath bar
        Container(
          height: 14,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                (isDark ? PoswalColors.ink : PoswalColors.mist).withValues(alpha: 0.6),
              ],
            ),
          ),
        ),
        // Floating glass bar with safe margin from gesture pill
        Padding(
          padding: EdgeInsets.only(
            left: PoswalSpacing.lg,
            right: PoswalSpacing.lg,
            bottom: bottomInset > 0 ? bottomInset + PoswalSpacing.xs : PoswalSpacing.md,
          ),
          child: barContent,
        ),
      ],
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
    const activeColor = PoswalColors.teal;
    final inactiveColor = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${item.label} tab',
      child: GestureDetector(
        key: ValueKey('tab_item_$index'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: PoswalDurations.micro,
          padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.16 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(PoswalRadii.capsule),
          ),
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
                  item.label,
                  maxLines: 1,
                  style: PoswalText.caption.copyWith(
                    fontSize: 11,
                    color: isSelected ? activeColor : inactiveColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
