import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/tasks/application/task_providers.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class TaskRowCard extends ConsumerWidget {
  final Task task;
  final VoidCallback? onReorderGrab;

  const TaskRowCard({
    super.key,
    required this.task,
    this.onReorderGrab,
  });

  Future<void> _toggleComplete(BuildContext context, WidgetRef ref) async {
    unawaited(HapticFeedback.mediumImpact());
    final repo = ref.read(taskRepositoryProvider);
    await repo.toggleTaskComplete(task.id);
  }

  void _openDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final subtasksAsync = ref.watch(taskSubtasksStreamProvider(task.id));

    // Due chip metadata
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool isOverdue = false;
    bool isDueToday = false;
    String? dueFormatted;

    if (task.dueAt != null) {
      final dueDate = DateTime(task.dueAt!.year, task.dueAt!.month, task.dueAt!.day);
      if (!task.isCompleted && dueDate.isBefore(today)) {
        isOverdue = true;
      } else if (DateBoundary.isSameDay(dueDate, today)) {
        isDueToday = true;
      }

      final dateStr = isDueToday
          ? 'Today'
          : DateBoundary.isSameDay(dueDate, today.add(const Duration(days: 1)))
              ? 'Tomorrow'
              : DateFormat('MMM d').format(task.dueAt!);

      final timeStr = task.hasTime ? ' ${DateFormat('h:mm a').format(task.dueAt!)}' : '';
      dueFormatted = '$dateStr$timeStr';
    }

    return Dismissible(
      key: ValueKey('task_dismissible_${task.id}'),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
        decoration: BoxDecoration(
          color: PoswalColors.teal.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(PoswalRadii.card),
        ),
        child: const Row(
          children: [
            Icon(PhosphorIconsBold.check, color: Colors.white, size: 24),
            SizedBox(width: PoswalSpacing.sm),
            Text(
              'Complete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
        decoration: BoxDecoration(
          color: PoswalColors.danger.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(PoswalRadii.card),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: PoswalSpacing.sm),
            Icon(PhosphorIconsBold.trash, color: Colors.white, size: 24),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right: Complete
          await _toggleComplete(context, ref);
          return false; // Don't remove widget manually, stream updates it
        } else {
          // Swipe left: Delete with Undo
          final messenger = ScaffoldMessenger.of(context);
          final l10n = AppLocalizations.of(context);
          unawaited(HapticFeedback.mediumImpact());
          final repo = ref.read(taskRepositoryProvider);
          final deletedTask = task;
          await repo.deleteTask(deletedTask.id);

          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n?.taskDeletedNamed(deletedTask.title) ?? 'Task "${deletedTask.title}" deleted'),
              action: SnackBarAction(
                label: l10n?.undoButton ?? 'Undo',
                textColor: PoswalColors.teal,
                onPressed: () async {
                  await repo.restoreTask(deletedTask.id);
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          return true;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: PoswalSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
          borderRadius: BorderRadius.circular(PoswalRadii.card),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PoswalSpacing.md,
            vertical: PoswalSpacing.sm + 2,
          ),
          child: Row(
            children: [
              // 1. Checkbox Ring (Min 44x44 touch target & screen reader Semantics)
              Semantics(
                button: true,
                checked: task.isCompleted,
                label: task.isCompleted
                    ? 'Mark task ${task.title} incomplete'
                    : 'Mark task ${task.title} complete',
                child: GestureDetector(
                  key: ValueKey('task_checkbox_${task.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggleComplete(context, ref),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted
                              ? PoswalColors.teal
                              : (task.priority != TaskPriority.none
                                  ? Color(task.priority.colorValue)
                                  : (isDark ? Colors.white38 : Colors.black38)),
                          width: 2,
                        ),
                        color: task.isCompleted ? PoswalColors.teal : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? const Icon(PhosphorIconsRegular.check, size: 20, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
                const SizedBox(width: PoswalSpacing.md),

                // 2. Title, Tags & Due Date
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openDetail(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Row(
                        children: [
                          if (task.priority != TaskPriority.none && !task.isCompleted) ...[
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsetsDirectional.only(end: PoswalSpacing.xs),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(task.priority.colorValue),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: PoswalText.subheadline.copyWith(
                                color: task.isCompleted ? textMuted : textPrimary,
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Metadata Row (Due date chip, subtasks count, recurring badge)
                      if (dueFormatted != null || subtasksAsync.asData?.value.isNotEmpty == true || task.repeatRule != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (dueFormatted != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? PoswalColors.danger.withValues(alpha: 0.15)
                                      : isDueToday
                                          ? PoswalColors.teal.withValues(alpha: 0.15)
                                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                  borderRadius: BorderRadius.circular(PoswalSpacing.xs),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.calendar,
                                      size: 11,
                                      color: isOverdue
                                          ? PoswalColors.danger
                                          : isDueToday
                                              ? PoswalColors.teal
                                              : textMuted,
                                    ),
                                    const SizedBox(width: PoswalSpacing.xxs),
                                    Text(
                                      dueFormatted,
                                      style: PoswalText.caption2.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isOverdue
                                            ? PoswalColors.danger
                                            : isDueToday
                                                ? PoswalColors.teal
                                                : textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: PoswalSpacing.xs),
                            ],

                            // Subtasks count badge
                            subtasksAsync.maybeWhen(
                              data: (subtasks) {
                                if (subtasks.isEmpty) return const SizedBox.shrink();
                                final completed = subtasks.where((s) => s.isCompleted).length;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(PhosphorIconsRegular.checkSquare, size: 12, color: textMuted),
                                    const SizedBox(width: 2),
                                    Text(
                                      '$completed/${subtasks.length}',
                                      style: PoswalText.caption2.copyWith(color: textMuted),
                                    ),
                                    const SizedBox(width: PoswalSpacing.xs),
                                  ],
                                );
                              },
                              orElse: () => const SizedBox.shrink(),
                            ),

                            // Recurrence indicator
                            if (task.repeatRule != null) ...[
                              const Icon(PhosphorIconsRegular.arrowsClockwise, size: 12, color: PoswalColors.violet),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Right arrow / detail indicator
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 14,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
