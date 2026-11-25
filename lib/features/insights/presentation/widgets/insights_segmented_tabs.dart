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
    final borderColor = (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.06);

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
        color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
        borderRadius: BorderRadius.circular(PoswalRadii.capsule),
        border: Border.all(color: borderColor, width: 1.0),
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
                        ? PoswalColors.teal.withValues(alpha: isDark ? 0.22 : 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(PoswalRadii.capsule),
                    border: isSelected
                        ? Border.all(color: PoswalColors.teal.withValues(alpha: 0.4), width: 1.0)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isSelected
                            ? PoswalColors.teal
                            : (isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight),
                      ),
                      const SizedBox(width: PoswalSpacing.xs),
                      Text(
                        tab.label,
                        style: PoswalText.caption.copyWith(
                          color: isSelected
                              ? (isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight)
                              : (isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight),
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
