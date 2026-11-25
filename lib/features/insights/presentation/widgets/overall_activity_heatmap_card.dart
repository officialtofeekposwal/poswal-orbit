import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class OverallActivityHeatmapCard extends StatefulWidget {
  final Map<String, int> dailyOverallCompletions;

  const OverallActivityHeatmapCard({
    super.key,
    required this.dailyOverallCompletions,
  });

  @override
  State<OverallActivityHeatmapCard> createState() => _OverallActivityHeatmapCardState();
}

class _OverallActivityHeatmapCardState extends State<OverallActivityHeatmapCard> {
  String? _selectedDateLabel;

  @override
  Widget build(BuildContext context) {
    const boundary = DateBoundary(dayStartHour: 4);
    final today = boundary.getAppDate(DateTime.now());

    // Build last 8 weeks (56 days) grid ending on current week's Sunday
    const weeksCount = 8;
    final int daysSinceMonday = today.weekday - 1;
    final DateTime currentWeekSunday = today.add(Duration(days: 6 - daysSinceMonday));
    const totalDays = weeksCount * 7;
    final DateTime gridStart = currentWeekSunday.subtract(const Duration(days: totalDays - 1));

    final List<List<DateTime>> columns = [];
    DateTime cursor = gridStart;
    for (int w = 0; w < weeksCount; w++) {
      final List<DateTime> week = [];
      for (int d = 0; d < 7; d++) {
        week.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
      columns.add(week);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final l10n = AppLocalizations.of(context);

    final cardBg = isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight;
    final borderColor = (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.06);
    final emptyCellColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);
    final cellBorderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.06);

    return Container(
      key: const ValueKey('insights_overall_heatmap_card'),
      padding: const EdgeInsetsDirectional.all(PoswalSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(PoswalRadii.card),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n?.overallHeatmap ?? 'Overall Activity Heatmap',
                  style: PoswalText.headline.copyWith(color: textPrimary),
                ),
              ),
              const SizedBox(width: PoswalSpacing.xs),
              Text(
                l10n?.last8Weeks ?? 'Last 8 Weeks',
                style: PoswalText.caption.copyWith(color: textMuted),
              ),
            ],
          ),

          if (_selectedDateLabel != null) ...[
            const SizedBox(height: PoswalSpacing.xs),
            Text(
              _selectedDateLabel!,
              style: PoswalText.caption.copyWith(
                color: PoswalColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: PoswalSpacing.md),

          // Heatmap with Day labels on left
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels (M, W, F)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: PoswalSpacing.xs),
                child: Column(
                  children: [
                    SizedBox(
                      height: 18,
                      child: Center(
                        child: Text(
                          l10n?.heatmapDayMon ?? 'M',
                          style: PoswalText.micro.copyWith(color: textMuted, fontSize: 9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 18,
                      child: Center(
                        child: Text(
                          l10n?.heatmapDayWed ?? 'W',
                          style: PoswalText.micro.copyWith(color: textMuted, fontSize: 9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 18,
                      child: Center(
                        child: Text(
                          l10n?.heatmapDayFri ?? 'F',
                          style: PoswalText.micro.copyWith(color: textMuted, fontSize: 9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Columns of cells
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: columns.map((week) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          children: week.map((day) {
                            final dayStr = DateBoundary.toDateString(day);
                            final count = widget.dailyOverallCompletions[dayStr] ?? 0;
                            final isFuture = day.isAfter(today);

                            Color cellColor;
                            if (isFuture) {
                              cellColor = Colors.transparent;
                            } else if (count == 0) {
                              cellColor = emptyCellColor;
                            } else if (count == 1) {
                              cellColor = PoswalColors.teal.withValues(alpha: 0.35);
                            } else if (count == 2) {
                              cellColor = PoswalColors.teal.withValues(alpha: 0.65);
                            } else {
                              cellColor = PoswalColors.teal;
                            }

                            final dateFormatted = DateFormat.MMMd().format(day);
                            final tooltipMsg = l10n?.heatmapCellTooltip(dateFormatted, count) ?? '$dateFormatted: $count completed';

                            return Tooltip(
                              message: tooltipMsg,
                              child: GestureDetector(
                                onTap: isFuture
                                    ? null
                                    : () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _selectedDateLabel = tooltipMsg;
                                        });
                                      },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 2.0),
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    borderRadius: BorderRadius.circular(PoswalRadii.xxs),
                                    border: isFuture
                                        ? null
                                        : Border.all(
                                            color: cellBorderColor,
                                            width: 0.5,
                                          ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: PoswalSpacing.sm),

          // Less -> More Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n?.heatmapLess ?? 'Less',
                style: PoswalText.micro.copyWith(color: textMuted),
              ),
              const SizedBox(width: PoswalSpacing.xs),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: emptyCellColor,
                  borderRadius: BorderRadius.circular(PoswalRadii.xxs),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: PoswalColors.teal.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(PoswalRadii.xxs),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: PoswalColors.teal.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(PoswalRadii.xxs),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: PoswalColors.teal,
                  borderRadius: BorderRadius.circular(PoswalRadii.xxs),
                ),
              ),
              const SizedBox(width: PoswalSpacing.xs),
              Text(
                l10n?.heatmapMore ?? 'More',
                style: PoswalText.micro.copyWith(color: textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
