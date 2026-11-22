import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_sheet.dart';
import 'package:poswal_orbit/domain/logic/task_nlp_parser.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/tasks/application/task_providers.dart';

class TaskQuickAddSheet extends ConsumerStatefulWidget {
  const TaskQuickAddSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TaskQuickAddSheet(),
    );
  }

  @override
  ConsumerState<TaskQuickAddSheet> createState() => _TaskQuickAddSheetState();
}

class _TaskQuickAddSheetState extends ConsumerState<TaskQuickAddSheet> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  ParsedTaskResult _parsed = const ParsedTaskResult(cleanTitle: '');
  DateTime? _overrideDueAt;
  bool? _overrideHasTime;
  TaskPriority? _overridePriority;
  String? _overrideProject;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    setState(() {
      _parsed = TaskNlpParser.parse(text);
    });
  }

  DateTime? get _effectiveDueAt => _overrideDueAt ?? _parsed.dueAt;
  bool get _effectiveHasTime => _overrideHasTime ?? _parsed.hasTime;
  TaskPriority get _effectivePriority => _overridePriority ?? _parsed.priority;
  String? get _effectiveProject => _overrideProject ?? _parsed.projectName;

  void _cyclePriority() {
    HapticFeedback.selectionClick();
    setState(() {
      final current = _effectivePriority;
      switch (current) {
        case TaskPriority.none:
          _overridePriority = TaskPriority.urgent;
          break;
        case TaskPriority.urgent:
          _overridePriority = TaskPriority.high;
          break;
        case TaskPriority.high:
          _overridePriority = TaskPriority.medium;
          break;
        case TaskPriority.medium:
          _overridePriority = TaskPriority.low;
          break;
        case TaskPriority.low:
          _overridePriority = TaskPriority.none;
          break;
      }
    });
  }

  Future<void> _pickDate() async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveDueAt ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (picked != null) {
      setState(() {
        final current = _effectiveDueAt;
        if (current != null && _effectiveHasTime) {
          _overrideDueAt = DateTime(picked.year, picked.month, picked.day, current.hour, current.minute);
        } else {
          _overrideDueAt = DateTime(picked.year, picked.month, picked.day, 9, 0);
          _overrideHasTime = false;
        }
      });
    }
  }

  Future<void> _submitTask() async {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) return;

    final title = _parsed.cleanTitle.isNotEmpty ? _parsed.cleanTitle : rawText;

    await HapticFeedback.mediumImpact();
    final repo = ref.read(taskRepositoryProvider);
    final now = DateTime.now();

    final task = Task(
      id: '',
      title: title,
      dueAt: _effectiveDueAt,
      hasTime: _effectiveHasTime,
      priority: _effectivePriority,
      projectId: _effectiveProject,
      sortOrder: now.millisecondsSinceEpoch,
      createdAt: now,
      updatedAt: now,
    );

    await repo.createTask(task);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    final due = _effectiveDueAt;
    final hasTime = _effectiveHasTime;
    final priority = _effectivePriority;
    final project = _effectiveProject;

    return AppSheet(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: PoswalSpacing.lg,
            right: PoswalSpacing.lg,
            top: PoswalSpacing.xs,
            bottom: MediaQuery.of(context).viewInsets.bottom + PoswalSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Add Task',
                    style: PoswalText.title.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.x),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: PoswalSpacing.xs),

            // Text input
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              style: PoswalText.headline.copyWith(color: textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n?.quickAddTaskHint ?? 'e.g. Call mom tomorrow 6pm !high #family',
                hintStyle: PoswalText.callout.copyWith(color: textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: PoswalSpacing.xs),
              ),
              onSubmitted: (_) => _submitTask(),
            ),
            const SizedBox(height: PoswalSpacing.md),

            // Live Parsed Interactive Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 1. Due Date Chip
                  ActionChip(
                    avatar: Icon(
                      PhosphorIconsRegular.calendar,
                      size: 14,
                      color: due != null ? PoswalColors.teal : textMuted,
                    ),
                    label: Text(
                      due != null
                          ? '${DateFormat('EEE, MMM d').format(due)}${hasTime ? ' ${DateFormat('h:mm a').format(due)}' : ''}'
                          : (l10n?.dueDateLabel ?? 'Due Date'),
                      style: TextStyle(
                        color: due != null ? PoswalColors.teal : textMuted,
                        fontWeight: due != null ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: due != null
                        ? PoswalColors.teal.withValues(alpha: 0.15)
                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    onPressed: _pickDate,
                  ),
                  const SizedBox(width: PoswalSpacing.xs),

                  // 2. Priority Chip
                  ActionChip(
                    avatar: priority != TaskPriority.none
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Color(priority.colorValue)),
                          )
                        : Icon(PhosphorIconsRegular.flag, size: 14, color: textMuted),
                    label: Text(
                      priority != TaskPriority.none ? priority.label : (l10n?.priorityLabel ?? 'Priority'),
                      style: TextStyle(
                        color: priority != TaskPriority.none ? Color(priority.colorValue) : textMuted,
                        fontWeight: priority != TaskPriority.none ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: priority != TaskPriority.none
                        ? Color(priority.colorValue).withValues(alpha: 0.15)
                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    onPressed: _cyclePriority,
                  ),
                  const SizedBox(width: PoswalSpacing.xs),

                  // 3. Project / Tag Chip
                  if (project != null) ...[
                    Chip(
                      avatar: const Icon(PhosphorIconsRegular.tag, size: 14, color: PoswalColors.violet),
                      label: Text(
                        '#$project',
                        style: const TextStyle(color: PoswalColors.violet, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      backgroundColor: PoswalColors.violet.withValues(alpha: 0.15),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: PoswalSpacing.lg),

            // Add button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppGlassButton(
                  isPrimary: true,
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.xl, vertical: PoswalSpacing.md),
                  onPressed: _submitTask,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsBold.plus, size: 16),
                      const SizedBox(width: PoswalSpacing.xs),
                      Text(l10n?.addTask ?? 'Add Task'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
