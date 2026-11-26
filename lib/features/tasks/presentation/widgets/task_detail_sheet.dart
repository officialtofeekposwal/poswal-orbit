import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_sheet.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/data/services/notification_service.dart';
import 'package:poswal_orbit/features/tasks/application/task_providers.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class TaskDetailSheet extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailSheet({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _newSubtaskController;

  late TaskPriority _priority;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String? _projectId;
  TaskRepeatRule? _repeatRule;
  String? _linkedHabitId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _newSubtaskController = TextEditingController();

    _priority = widget.task.priority;
    _dueDate = widget.task.dueAt;
    if (widget.task.dueAt != null && widget.task.hasTime) {
      _dueTime = TimeOfDay.fromDateTime(widget.task.dueAt!);
    }
    _projectId = widget.task.projectId;
    _repeatRule = widget.task.repeatRule;
    _linkedHabitId = widget.task.linkedHabitId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _dueTime = picked;
        _dueDate ??= DateTime.now();
      });
    }
  }

  Future<void> _addSubtask() async {
    final text = _newSubtaskController.text.trim();
    if (text.isEmpty) return;

    unawaited(HapticFeedback.lightImpact());
    final repo = ref.read(taskRepositoryProvider);
    final now = DateTime.now();

    final subtask = Task(
      id: '',
      parentId: widget.task.id,
      title: text,
      sortOrder: now.millisecondsSinceEpoch,
      createdAt: now,
      updatedAt: now,
    );

    await repo.createTask(subtask);
    _newSubtaskController.clear();
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    await HapticFeedback.mediumImpact();
    final repo = ref.read(taskRepositoryProvider);

    DateTime? finalDue;
    if (_dueDate != null) {
      if (_dueTime != null) {
        finalDue = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime!.hour,
          _dueTime!.minute,
        );
      } else {
        finalDue = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day, 9, 0);
      }
    }

    final updated = widget.task.copyWith(
      title: title,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      dueAt: finalDue,
      hasTime: _dueTime != null,
      priority: _priority,
      projectId: _projectId,
      repeatRule: _repeatRule,
      linkedHabitId: _linkedHabitId,
    );

    await repo.updateTask(updated);

    try {
      if (finalDue != null) {
        await ref.read(notificationServiceProvider).requestPermissionContextual();
      }
      await ref.read(notificationServiceProvider).refillRollingWindow();
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteTask() async {
    await HapticFeedback.mediumImpact();
    final repo = ref.read(taskRepositoryProvider);
    await repo.deleteTask(widget.task.id);

    try {
      await ref.read(notificationServiceProvider).refillRollingWindow();
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;

    final subtasksAsync = ref.watch(taskSubtasksStreamProvider(widget.task.id));
    final habitsAsync = ref.watch(activeHabitsStreamProvider);

    return AppSheet(
      isFullHeight: true,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.88,
          child: Column(
            children: [
              // Sheet App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg, vertical: PoswalSpacing.xs),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(PhosphorIconsRegular.x),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          l10n?.taskDetailsTitle ?? 'Task Details',
                          style: PoswalText.title.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: PoswalColors.teal,
                        foregroundColor: PoswalColors.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PoswalRadii.capsule),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md, vertical: 8),
                      ),
                      onPressed: _saveChanges,
                      child: Text(l10n?.saveChanges ?? 'Save Changes'),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
              child: ListView(
                padding: const EdgeInsets.all(PoswalSpacing.lg),
                children: [
                  // 1. Title Input
                  TextField(
                    controller: _titleController,
                    style: PoswalText.title3.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n?.tasksTitle ?? 'Task Title',
                      hintStyle: PoswalText.title3.copyWith(color: textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: PoswalSpacing.md),

                  // 2. Notes Input
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: PoswalText.callout.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n?.addNotesHint ?? 'Add notes or details...',
                      hintStyle: PoswalText.callout.copyWith(color: textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: PoswalSpacing.lg),

                  // 3. Priority Selector (5 options)
                  Text(
                    l10n?.priorityLabel ?? 'Priority',
                    style: PoswalText.caption.copyWith(color: textMuted, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: PoswalSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: TaskPriority.values.map((p) {
                        final isSelected = _priority == p;
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: PoswalSpacing.xs),
                          child: ChoiceChip(
                            label: Text(p.label),
                            selected: isSelected,
                            selectedColor: Color(p.colorValue).withValues(alpha: 0.25),
                            avatar: p != TaskPriority.none
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(PoswalRadii.pill),
                                      color: Color(p.colorValue),
                                    ),
                                  )
                                : null,
                            labelStyle: TextStyle(
                              color: isSelected ? textPrimary : textMuted,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _priority = p);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: PoswalSpacing.lg),

                  // 4. Due Date & Time Pickers
                  Text(
                    l10n?.dueDateLabel ?? 'Due date and time',
                    style: PoswalText.caption.copyWith(color: textMuted, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: PoswalSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(PhosphorIconsRegular.calendar, size: 20),
                          label: Text(
                            _dueDate != null ? DateFormat('EEE, MMM d, yyyy').format(_dueDate!) : (l10n?.datePickerSetDate ?? 'Set date'),
                            style: PoswalText.footnote,
                          ),
                          onPressed: _pickDueDate,
                        ),
                      ),
                      const SizedBox(width: PoswalSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(PhosphorIconsRegular.clock, size: 20),
                          label: Text(
                            _dueTime != null ? _dueTime!.format(context) : (l10n?.datePickerSetTime ?? 'Set time'),
                            style: PoswalText.footnote,
                          ),
                          onPressed: _pickDueTime,
                        ),
                      ),
                      if (_dueDate != null) ...[
                        IconButton(
                          icon: const Icon(PhosphorIconsRegular.xCircle, size: 20),
                          onPressed: () => setState(() {
                            _dueDate = null;
                            _dueTime = null;
                          }),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: PoswalSpacing.lg),

                  // 5. Subtasks Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n?.subtasksTitle ?? 'Subtasks',
                        style: PoswalText.caption.copyWith(color: textMuted, fontWeight: FontWeight.w700),
                      ),
                      subtasksAsync.maybeWhen(
                        data: (subs) => Text(
                          '${subs.where((s) => s.isCompleted).length}/${subs.length} done',
                          style: PoswalText.caption.copyWith(color: textMuted),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: PoswalSpacing.sm),

                  subtasksAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: PoswalColors.teal)),
                    error: (err, _) => Text('Error: $err'),
                    data: (subtasks) {
                      return Column(
                        children: [
                          for (final sub in subtasks) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    key: ValueKey('subtask_checkbox_${sub.id}'),
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      unawaited(HapticFeedback.lightImpact());
                                      await ref.read(taskRepositoryProvider).toggleTaskComplete(sub.id);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        sub.isCompleted ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.circle,
                                        size: 20,
                                        color: sub.isCompleted ? PoswalColors.teal : textMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: PoswalSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      sub.title,
                                      style: PoswalText.callout.copyWith(
                                        color: sub.isCompleted ? textMuted : textPrimary,
                                        decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(PhosphorIconsRegular.trash, size: 16),
                                    onPressed: () => ref.read(taskRepositoryProvider).deleteTask(sub.id),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Add subtask inline input
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newSubtaskController,
                                  style: PoswalText.callout.copyWith(color: textPrimary),
                                  decoration: InputDecoration(
                                    hintText: l10n?.addSubtaskHint ?? 'Add a subtask...',
                                    hintStyle: PoswalText.callout.copyWith(color: textMuted),
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _addSubtask(),
                                ),
                              ),
                              IconButton(
                                key: const ValueKey('add_subtask_btn'),
                                icon: const Icon(PhosphorIconsRegular.plus, color: PoswalColors.teal),
                                onPressed: _addSubtask,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: PoswalSpacing.lg),

                  // 6. Project & Habit Links
                  Text(
                    l10n?.linkedHabitLabel ?? 'Linked habit',
                    style: PoswalText.caption.copyWith(color: textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: PoswalSpacing.sm),
                  habitsAsync.maybeWhen(
                    data: (habits) {
                      return DropdownButtonFormField<String?>(
                        value: _linkedHabitId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(PoswalRadii.button)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md, vertical: 10),
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n?.noHabitLinked ?? 'No habit linked')),
                          for (final h in habits)
                            DropdownMenuItem(value: h.id, child: Text(h.name)),
                        ],
                        onChanged: (val) => setState(() => _linkedHabitId = val),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: PoswalSpacing.xl),

                  // Delete task button
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(PhosphorIconsRegular.trash, color: PoswalColors.danger),
                      label: Text(l10n?.deleteTaskBtn ?? 'Delete Task', style: const TextStyle(color: PoswalColors.danger)),
                      onPressed: _deleteTask,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
