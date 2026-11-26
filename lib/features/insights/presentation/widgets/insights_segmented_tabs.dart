import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class InsightsSegmentedTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool reduceMotion;

  const InsightsSegmentedTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.reduceMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final accent = isDark ? PoswalColors.teal : PoswalColors.tealLight;

    final tabs = [
      (
        key: const ValueKey('insights_tab_overview'),
        icon: PhosphorIconsRegular.chartPieSlice,
        label: l10n?.insightsTabOverview ?? 'Overview',
      ),
      (
        key: const ValueKey('insights_tab_habits'),
        icon: PhosphorIconsRegular.target,
        label: l10n?.insightsTabHabits ?? 'Habits',
      ),
      (
        key: const ValueKey('insights_tab_timing'),
        icon: PhosphorIconsRegular.clock,
        label: l10n?.insightsTabTiming ?? 'Timing',
      ),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsetsDirectional.all(PoswalSpacing.xxs),
      decoration: BoxDecoration(
        color: isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight,
        borderRadius: BorderRadius.circular(PoswalRadii.capsule),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = selectedIndex == index;

          return Expanded(
            child: Semantics(
              selected: isSelected,
              button: true,
              label: tab.label,
              child: InkWell(
                key: tab.key,
                borderRadius: BorderRadius.circular(PoswalRadii.capsule),
                onTap: () {
                  if (!isSelected) {
                    HapticFeedback.selectionClick();
                    onTabSelected(index);
                  }
                },
                child: AnimatedContainer(
                  duration: reduceMotion ? Duration.zero : PoswalDurations.micro,
                  curve: Curves.easeInOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withValues(alpha: isDark ? 0.22 : 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(PoswalRadii.capsule),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        size: 20,
                        color: isSelected
                            ? accent
                            : (isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight),
                      ),
                      const SizedBox(width: PoswalSpacing.xs),
                      Text(
                        tab.label,
                        style: PoswalText.caption.copyWith(
                          color: isSelected
                              ? (isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight)
                              : (isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
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
