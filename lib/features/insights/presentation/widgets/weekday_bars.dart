import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/domain/logic/insights_engine.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class WeekdayBars extends StatelessWidget {
  final Map<String, int> dailyOverallCompletions;
  final BestTimeResult bestTiming;
  final bool reduceMotion;

  const WeekdayBars({
    super.key,
    required this.dailyOverallCompletions,
    required this.bestTiming,
    this.reduceMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final l10n = AppLocalizations.of(context);

    // Sum completions by weekday (1 = Monday ... 7 = Sunday)
    final Map<int, int> weekdayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (final entry in dailyOverallCompletions.entries) {
      final parsed = DateTime.tryParse(entry.key);
      if (parsed != null) {
        weekdayCounts[parsed.weekday] = (weekdayCounts[parsed.weekday] ?? 0) + entry.value;
      }
    }

    final maxCount = math.max(1, weekdayCounts.values.fold(0, math.max));

    final dayLabels = [
      (day: 1, label: l10n?.dayShortMon ?? 'Mon'),
      (day: 2, label: l10n?.dayShortTue ?? 'Tue'),
      (day: 3, label: l10n?.dayShortWed ?? 'Wed'),
      (day: 4, label: l10n?.dayShortThu ?? 'Thu'),
      (day: 5, label: l10n?.dayShortFri ?? 'Fri'),
      (day: 6, label: l10n?.dayShortSat ?? 'Sat'),
      (day: 7, label: l10n?.dayShortSun ?? 'Sun'),
    ];

    const double maxHeight = 60.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.timingDistributionTitle ?? 'Completions by Weekday',
          style: PoswalText.caption.copyWith(
            color: textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PoswalSpacing.md),
        SizedBox(
          height: maxHeight + 28,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayLabels.map((item) {
              final count = weekdayCounts[item.day] ?? 0;
              final isBest = bestTiming.bestWeekdayName.toLowerCase().contains(item.label.toLowerCase());
              final barHeight = math.max(4.0, (count / maxCount) * maxHeight);

              final barColor = isBest
                  ? PoswalColors.teal
                  : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.12));

              final tooltip = '${item.label}: $count';

              return Expanded(
                child: Tooltip(
                  message: tooltip,
                  child: InkWell(
                    onTap: () => HapticFeedback.selectionClick(),
                    borderRadius: BorderRadius.circular(PoswalRadii.xs),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isBest)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: const BoxDecoration(
                              color: PoswalColors.teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                        AnimatedContainer(
                          duration: reduceMotion ? Duration.zero : PoswalDurations.micro,
                          curve: Curves.easeOut,
                          width: 14,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(PoswalRadii.xxs),
                            boxShadow: isBest
                                ? [
                                    BoxShadow(
                                      color: PoswalColors.teal.withValues(alpha: 0.35),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: PoswalSpacing.xs),
                        Text(
                          item.label,
                          style: PoswalText.micro.copyWith(
                            color: isBest
                                ? PoswalColors.teal
                                : textMuted,
                            fontWeight: isBest ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
