import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/icon_helper.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/habit_score.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_detail_screen.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_checkin_sheet.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class HabitRowCard extends ConsumerWidget {
  final HabitWithEntry item;
  final VoidCallback? onEdit;
  final bool inGroupedSection;

  const HabitRowCard({
    super.key,
    required this.item,
    this.onEdit,
    this.inGroupedSection = false,
  });

  void _handleToggle(BuildContext context, WidgetRef ref) async {
    await HapticFeedback.mediumImpact();
    final repo = ref.read(habitRepositoryProvider);
    final selectedDate = ref.read(selectedDateProvider);
    final dateStr = DateBoundary.toDateString(selectedDate);

    final currentDone = item.isCompleted;
    final nextStatus = currentDone ? HabitEntryStatus.missed : HabitEntryStatus.done;
    final nextValue = currentDone ? 0.0 : item.habit.targetValue;

    await repo.setEntryStatus(
      habitId: item.habit.id,
      dateStr: dateStr,
      status: nextStatus,
      value: nextValue,
    );
  }

  void _openDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HabitDetailScreen(habitId: item.habit.id),
      ),
    );
  }

  void _showActionSheet(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedDateProvider);
    HabitCheckinSheet.show(
      context: context,
      habit: item.habit,
      checkinDate: selectedDate,
      initialEntry: item.entry,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textSecondary =
        isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final accent = isDark ? PoswalColors.teal : PoswalColors.tealLight;
    final successColor = isDark ? PoswalColors.success : PoswalColors.successLight;
    final warningColor = isDark ? PoswalColors.warning : PoswalColors.warningLight;
    final onStatusColor = isDark ? PoswalColors.ink : PoswalColors.surfaceLight;
    final habitColor = Color(item.habit.colorValue);
    final isDone = item.isCompleted;
    final isSkipped = item.isSkipped;

    final scheduleText = ScheduleEngine.formatScheduleDescription(item.habit);
    final scorePercent = HabitScoreCalculator.toPercentage(item.habitScore);

    return Container(
      margin: inGroupedSection
          ? EdgeInsets.zero
          : const EdgeInsets.only(bottom: PoswalSpacing.md),
      padding: const EdgeInsets.all(PoswalSpacing.md),
      decoration: inGroupedSection
          ? const BoxDecoration(color: Colors.transparent)
          : BoxDecoration(
              color: isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight,
              borderRadius: BorderRadius.circular(PoswalRadii.card),
            ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(inGroupedSection ? 0 : PoswalRadii.card),
        onTap: () => _openDetail(context),
        onLongPress: () => _showActionSheet(context, ref),
        child: Row(
          children: [
            // Raw 22 px Phosphor icon in habit color (no circular tile)
            Hero(
              tag: 'habit_icon_${item.habit.id}',
              child: Icon(
                HabitIconHelper.getIcon(item.habit.iconName),
                color: habitColor,
                size: 22,
              ),
            ),
            const SizedBox(width: PoswalSpacing.md),

            // Center: Name, Schedule, and Streak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.habit.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: PoswalText.headline.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PoswalSpacing.xxs),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          scheduleText,
                          style: PoswalText.caption.copyWith(color: textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.currentStreak > 0) ...[
                        const SizedBox(width: PoswalSpacing.xs),
                        Text(
                          '· ${item.currentStreak}d',
                          style: PoswalText.caption.copyWith(
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (scorePercent > 0) ...[
                        const SizedBox(width: PoswalSpacing.xs),
                        Text(
                          '· $scorePercent%',
                          style: PoswalText.caption.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: PoswalSpacing.sm),

            // Trailing: Check Control (Min 44x44 touch target & Semantics)
            Semantics(
              button: true,
              checked: isDone,
              label: isDone
                  ? 'Mark habit ${item.habit.name} incomplete'
                  : 'Mark habit ${item.habit.name} complete',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleToggle(context, ref),
                child: Container(
                  width: PoswalRowHeights.minTouchTarget,
                  height: PoswalRowHeights.minTouchTarget,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: reduceMotion
                        ? Duration.zero
                        : PoswalDurations.standard,
                    curve: PoswalCurves.easeOut,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone
                          ? successColor
                          : (isSkipped
                              ? warningColor.withValues(alpha: 0.20)
                              : textSecondary.withValues(alpha: 0.16)),
                      borderRadius: BorderRadius.circular(PoswalRadii.pill),
                    ),
                    child: isDone
                        ? Icon(
                            PhosphorIconsRegular.check,
                            size: 20,
                            color: onStatusColor,
                          )
                        : (isSkipped
                            ? Icon(
                                PhosphorIconsRegular.arrowBendRightDown,
                                size: 20,
                                color: warningColor,
                              )
                            : null),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
