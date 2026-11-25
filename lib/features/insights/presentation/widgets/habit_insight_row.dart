import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/logic/streak_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_heatmap.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class HabitInsightRow extends StatefulWidget {
  final Habit habit;
  final List<HabitEntry> entries;
  final DateTime referenceDate;
  final bool initiallyExpanded;
  final bool reduceMotion;

  const HabitInsightRow({
    super.key,
    required this.habit,
    required this.entries,
    required this.referenceDate,
    this.initiallyExpanded = false,
    this.reduceMotion = false,
  });

  @override
  State<HabitInsightRow> createState() => _HabitInsightRowState();
}

class _HabitInsightRowState extends State<HabitInsightRow> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final l10n = AppLocalizations.of(context);
    final habitColor = Color(widget.habit.colorValue);

    final streak = StreakEngine.calculate(
      habit: widget.habit,
      entries: widget.entries,
      referenceDate: widget.referenceDate,
    );

    // Compute 30-day rate
    final Map<String, HabitEntry> entryMap = {
      for (final e in widget.entries) e.entryDate: e,
    };

    int scheduledCount = 0;
    int completedCount = 0;
    final List<bool> last28DaysDone = [];

    for (int i = 27; i >= 0; i--) {
      final day = widget.referenceDate.subtract(Duration(days: i));
      final isScheduled = ScheduleEngine.isScheduledOn(widget.habit, day);
      final dStr = DateBoundary.toDateString(day);
      final e = entryMap[dStr];
      final isDone = e != null && e.isDone;

      if (isScheduled) {
        scheduledCount++;
        if (isDone) completedCount++;
      }
      last28DaysDone.add(isDone);
    }

    final int completionRate = scheduledCount == 0
        ? 0
        : ((completedCount / scheduledCount) * 100).round().clamp(0, 100);

    final cardBg = isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight;
    final borderColor = (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.06);

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: PoswalSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(PoswalRadii.card),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: _isExpanded
                ? (l10n?.habitHeatmapCollapse ?? 'Tap to collapse heatmap')
                : (l10n?.habitHeatmapExpand ?? 'Tap to expand heatmap'),
            child: InkWell(
              borderRadius: BorderRadius.circular(PoswalRadii.card),
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isExpanded = !_isExpanded);
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.all(PoswalSpacing.md),
                child: Row(
                  children: [
                    // Color Dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: habitColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: habitColor.withValues(alpha: 0.35),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: PoswalSpacing.sm),

                    // Habit Name & Streak
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.habit.name,
                            style: PoswalText.callout.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                l10n?.habitStreakDays(streak.currentStreak) ?? '${streak.currentStreak}d streak',
                                style: PoswalText.micro.copyWith(color: textMuted),
                              ),
                              const SizedBox(width: PoswalSpacing.xs),
                              Text('·', style: PoswalText.micro.copyWith(color: textMuted)),
                              const SizedBox(width: PoswalSpacing.xs),
                              Text(
                                l10n?.habitThirtyDayRate(completionRate) ?? '$completionRate% in 30d',
                                style: PoswalText.micro.copyWith(
                                  color: completionRate >= 70 ? PoswalColors.teal : textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: PoswalSpacing.sm),

                    // Mini 4-week micro-strip (4 columns x 7 rows or 28 dots in 4 groups of 7)
                    Row(
                      children: List.generate(4, (col) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: 2),
                          child: Column(
                            children: List.generate(7, (row) {
                              final idx = col * 7 + row;
                              final isDone = idx < last28DaysDone.length && last28DaysDone[idx];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 1.0),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? habitColor
                                      : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                                  borderRadius: BorderRadius.circular(1.0),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: PoswalSpacing.sm),

                    // Expand / Collapse Chevron
                    Icon(
                      _isExpanded ? PhosphorIconsRegular.caretUp : PhosphorIconsRegular.caretDown,
                      size: 16,
                      color: textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Inline Expanded Heatmap
          if (_isExpanded) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.06 : 0.04),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.all(PoswalSpacing.sm),
              child: HabitHeatmap(
                key: ValueKey('habit_heatmap_${widget.habit.id}'),
                habit: widget.habit,
                entries: widget.entries,
                weeksToShow: 10,
                showHabitName: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
