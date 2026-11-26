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
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final habitColor = Color(item.habit.colorValue);
    final isDone = item.isCompleted;
    final isSkipped = item.isSkipped;

    final scheduleText = ScheduleEngine.formatScheduleDescription(item.habit);
    final scorePercent = HabitScoreCalculator.toPercentage(item.habitScore);

    return Container(
      margin: inGroupedSection ? EdgeInsets.zero : const EdgeInsets.only(bottom: PoswalSpacing.md),
      padding: const EdgeInsets.all(PoswalSpacing.md),
      decoration: inGroupedSection
          ? const BoxDecoration(color: Colors.transparent)
          : BoxDecoration(
              color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
              borderRadius: BorderRadius.circular(PoswalRadii.card),
              border: Border.all(
                color: isDone
                    ? PoswalColors.teal.withValues(alpha: 0.35)
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      child: InkWell(
        borderRadius: BorderRadius.circular(inGroupedSection ? 0 : PoswalRadii.card),
        onTap: () => _openDetail(context),
        onLongPress: () => _showActionSheet(context, ref),
        child: Row(
          children: [
            // Left: Icon Circle with Shared-Element Hero
            Hero(
              tag: 'habit_icon_${item.habit.id}',
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: isDark ? 0.22 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  HabitIconHelper.getIcon(item.habit.iconName),
                  color: habitColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: PoswalSpacing.md),

            // Center: Name, Schedule, and Streak Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.habit.name,
                    style: PoswalText.headline.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.none : null,
                    ),
                  ),
                  const SizedBox(height: PoswalSpacing.xxs),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          scheduleText,
                          style: PoswalText.caption.copyWith(color: textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.currentStreak > 0) ...[
                        const SizedBox(width: PoswalSpacing.xs),
                        Text(
                          '•',
                          style: PoswalText.caption.copyWith(color: textMuted),
                        ),
                        const SizedBox(width: PoswalSpacing.xxs),
                        const Icon(
                          PhosphorIconsFill.flame,
                          size: 12,
                          color: PoswalColors.gold,
                        ),
                        const SizedBox(width: PoswalSpacing.xxs),
                        Text(
                          '${item.currentStreak}d',
                          style: PoswalText.caption.copyWith(
                            color: PoswalColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (scorePercent > 0) ...[
                        const SizedBox(width: PoswalSpacing.xs),
                        Text(
                          '• $scorePercent%',
                          style: PoswalText.caption.copyWith(
                            color: PoswalColors.teal,
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

            // Trailing: Animated Check Ring (Min 44x44 touch target & screen reader Semantics)
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
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: PoswalDurations.standard,
                    curve: PoswalCurves.standard,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: isDone ? PoswalGradients.aurora : null,
                      color: isSkipped
                          ? PoswalColors.violet.withValues(alpha: 0.25)
                          : (isDone ? null : Colors.transparent),
                      shape: BoxShape.circle,
                      border: isDone
                          ? null
                          : Border.all(
                              color: isSkipped
                                  ? PoswalColors.violet
                                  : (isDark ? Colors.white30 : Colors.black26),
                              width: 2,
                            ),
                    ),
                    child: isDone
                        ? const Icon(PhosphorIconsBold.check, size: 16, color: Colors.white)
                        : (isSkipped
                            ? const Icon(PhosphorIconsBold.arrowBendRightDown, size: 14, color: Colors.white)
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
