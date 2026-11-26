import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_checkin_sheet.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class HabitHeatmap extends StatelessWidget {
  final Habit habit;
  final List<HabitEntry> entries;
  final int weeksToShow;

  /// When true the card header shows the habit's name (with its color dot)
  /// instead of the generic "Consistency heatmap" title. Used on the Insights
  /// screen where many heatmaps are stacked.
  final bool showHabitName;

  const HabitHeatmap({
    super.key,
    required this.habit,
    required this.entries,
    this.weeksToShow = 14,
    this.showHabitName = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final habitColor = Color(widgetColor);

    // Map entries by date string
    final Map<String, HabitEntry> entryMap = {
      for (final e in entries) e.entryDate: e,
    };

    const boundary = DateBoundary(dayStartHour: 4);
    final today = boundary.getAppDate(DateTime.now());
    final todayStr = DateBoundary.toDateString(today);

    // Build grid days: 14 weeks * 7 days ending on current week's Sunday
    final int daysSinceMonday = today.weekday - 1; // 0 = Mon, 6 = Sun
    final DateTime currentWeekSunday = today.add(Duration(days: 6 - daysSinceMonday));
    final int totalDays = weeksToShow * 7;
    final DateTime gridStart = currentWeekSunday.subtract(Duration(days: totalDays - 1));

    final List<List<DateTime>> columns = [];
    DateTime cursor = gridStart;

    for (int w = 0; w < weeksToShow; w++) {
      final List<DateTime> weekDays = [];
      for (int d = 0; d < 7; d++) {
        weekDays.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
      columns.add(weekDays);
    }

    final cardBg = isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight;
    final warningColor = isDark ? PoswalColors.warning : PoswalColors.warningLight;

    return Container(
      padding: const EdgeInsets.all(PoswalSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(PoswalRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: showHabitName
                    ? Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: habitColor,
                              borderRadius: BorderRadius.circular(PoswalRadii.pill),
                            ),
                          ),
                          const SizedBox(width: PoswalSpacing.xs),
                          Flexible(
                            child: Text(
                              habit.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: PoswalText.callout.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        l10n?.consistencyHeatmapHeader ?? 'Consistency heatmap',
                        style: PoswalText.caption.copyWith(
                          color: textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: PoswalSpacing.sm),
              Text(
                'Past $weeksToShow weeks',
                style: PoswalText.caption.copyWith(color: textMuted),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.md),

          // Heatmap Grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Scroll to recent days by default
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Labels (Mon, Wed, Fri)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6, top: 2),
                  child: Column(
                    children: [
                      _buildDayLabel('M', textMuted),
                      const SizedBox(height: 4),
                      _buildDayLabel('', textMuted),
                      const SizedBox(height: 4),
                      _buildDayLabel('W', textMuted),
                      const SizedBox(height: 4),
                      _buildDayLabel('', textMuted),
                      const SizedBox(height: 4),
                      _buildDayLabel('F', textMuted),
                      const SizedBox(height: 4),
                      _buildDayLabel('', textMuted),
                      const SizedBox(height: 4),
                      _buildDayLabel('S', textMuted),
                    ],
                  ),
                ),

                // Heatmap Weeks
                for (final week in columns)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Column(
                      children: [
                        for (final day in week)
                          _buildDayCell(
                            context: context,
                            day: day,
                            todayStr: todayStr,
                            entry: entryMap[DateBoundary.toDateString(day)],
                            habitColor: habitColor,
                            isDark: isDark,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: PoswalSpacing.md),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(l10n?.heatmapLess ?? 'Less', style: PoswalText.micro.copyWith(color: textMuted)),
              const SizedBox(width: PoswalSpacing.xs),
              _buildLegendBox(textMuted.withValues(alpha: 0.14)),
              const SizedBox(width: PoswalSpacing.xxs),
              _buildLegendBox(habitColor.withValues(alpha: 0.35)),
              const SizedBox(width: PoswalSpacing.xxs),
              _buildLegendBox(habitColor.withValues(alpha: 0.70)),
              const SizedBox(width: PoswalSpacing.xxs),
              _buildLegendBox(habitColor),
              const SizedBox(width: PoswalSpacing.xs),
              Text(l10n?.heatmapMore ?? 'More', style: PoswalText.micro.copyWith(color: textMuted)),
              const SizedBox(width: PoswalSpacing.md),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: warningColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(PoswalRadii.xxs),
                ),
              ),
              const SizedBox(width: 4),
              Text(l10n?.heatmapSkipped ?? 'Skipped', style: PoswalText.micro.copyWith(color: textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  int get widgetColor => habit.colorValue;

  Widget _buildDayLabel(String text, Color color) {
    return SizedBox(
      height: 14,
      child: Center(
        child: Text(
          text,
          style: PoswalText.micro.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PoswalRadii.xxs),
      ),
    );
  }

  Widget _buildDayCell({
    required BuildContext context,
    required DateTime day,
    required String todayStr,
    required HabitEntry? entry,
    required Color habitColor,
    required bool isDark,
  }) {
    final dateStr = DateBoundary.toDateString(day);
    final isToday = dateStr == todayStr;
    final isFuture = day.isAfter(DateTime.now());
    final isScheduled = ScheduleEngine.isScheduledOn(habit, day);

    final textSecondary = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final warningColor = isDark ? PoswalColors.warning : PoswalColors.warningLight;
    final accent = isDark ? PoswalColors.teal : PoswalColors.tealLight;

    Color cellColor = textSecondary.withValues(alpha: 0.12);

    if (entry != null && entry.isDone) {
      if (habit.isNumeric && habit.targetValue > 0) {
        final ratio = (entry.value / habit.targetValue).clamp(0.2, 1.0);
        cellColor = habitColor.withValues(alpha: ratio);
      } else {
        cellColor = habitColor;
      }
    } else if (entry != null && entry.isSkipped) {
      cellColor = warningColor.withValues(alpha: 0.40);
    } else if (isScheduled && !isFuture && day.isAfter(habit.startDate.subtract(const Duration(days: 1)))) {
      // Scheduled past day missed
      cellColor = textSecondary.withValues(alpha: 0.22);
    } else if (isToday) {
      cellColor = accent.withValues(alpha: 0.30);
    }

    return GestureDetector(
      onTap: isFuture
          ? null
          : () {
              HabitCheckinSheet.show(
                context: context,
                habit: habit,
                checkinDate: day,
                initialEntry: entry,
              );
            },
      child: Tooltip(
        message: '${DateFormat('MMM d, yyyy').format(day)}: ${entry?.status.name ?? (isScheduled ? 'missed' : 'unscheduled')}',
        child: Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: BorderRadius.circular(PoswalRadii.xxs),
          ),
        ),
      ),
    );
  }
}
