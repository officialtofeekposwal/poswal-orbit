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
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class HabitRowCard extends ConsumerWidget {
  final HabitWithEntry item;
  final VoidCallback? onEdit;

  const HabitRowCard({
    super.key,
    required this.item,
    this.onEdit,
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

  void _showActionSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = ref.read(habitRepositoryProvider);
    final selectedDate = ref.read(selectedDateProvider);
    final dateStr = DateBoundary.toDateString(selectedDate);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PoswalRadii.sheet)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(PoswalSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(item.habit.colorValue).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        HabitIconHelper.getIcon(item.habit.iconName),
                        color: Color(item.habit.colorValue),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: PoswalSpacing.md),
                    Expanded(
                      child: Text(
                        item.habit.name,
                        style: PoswalText.headline.copyWith(
                          color: isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PoswalSpacing.lg),

                // 1. Mark as Done / Undo
                ListTile(
                  leading: const Icon(PhosphorIconsBold.checkCircle, color: PoswalColors.teal),
                  title: Text(item.isCompleted ? 'Mark Incomplete' : 'Mark as Done'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleToggle(context, ref);
                  },
                ),

                // 2. Mark as Skipped (Preserves streak)
                ListTile(
                  leading: const Icon(PhosphorIconsRegular.arrowBendRightDown, color: PoswalColors.violet),
                  title: const Text('Mark as Skipped (Excused)'),
                  subtitle: const Text('Preserves your streak without adding to it'),
                  onTap: () async {
                    Navigator.pop(context);
                    await repo.setEntryStatus(
                      habitId: item.habit.id,
                      dateStr: dateStr,
                      status: HabitEntryStatus.skipped,
                      value: 0.0,
                      note: 'Excused skip',
                    );
                  },
                ),

                // 3. Edit Habit
                if (onEdit != null)
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.pencilSimple, color: PoswalColors.coral),
                    title: const Text('Edit Habit Details'),
                    onTap: () {
                      Navigator.pop(context);
                      onEdit!();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final habitColor = Color(item.habit.colorValue);
    final isDone = item.isCompleted;
    final isSkipped = item.isSkipped;

    final scheduleText = ScheduleEngine.formatScheduleDescription(item.habit);
    final scorePercent = HabitScoreCalculator.toPercentage(item.habitScore);

    return Container(
      margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
      padding: const EdgeInsets.all(PoswalSpacing.md),
      decoration: BoxDecoration(
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
        borderRadius: BorderRadius.circular(PoswalRadii.card),
        onTap: () => _handleToggle(context, ref),
        onLongPress: () => _showActionSheet(context, ref),
        child: Row(
          children: [
            // Left: Icon Circle
            Container(
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.none : null,
                    ),
                  ),
                  const SizedBox(height: 3),
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
                          '• 🔥 ${item.currentStreak}d',
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

            // Trailing: Animated Check Ring
            GestureDetector(
              onTap: () => _handleToggle(context, ref),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
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
          ],
        ),
      ),
    );
  }
}
