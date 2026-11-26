import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_sheet.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class HabitCheckinSheet extends ConsumerStatefulWidget {
  final Habit habit;
  final DateTime checkinDate;
  final HabitEntry? initialEntry;

  const HabitCheckinSheet({
    super.key,
    required this.habit,
    required this.checkinDate,
    this.initialEntry,
  });

  static Future<void> show({
    required BuildContext context,
    required Habit habit,
    required DateTime checkinDate,
    HabitEntry? initialEntry,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitCheckinSheet(
        habit: habit,
        checkinDate: checkinDate,
        initialEntry: initialEntry,
      ),
    );
  }

  @override
  ConsumerState<HabitCheckinSheet> createState() => _HabitCheckinSheetState();
}

class _HabitCheckinSheetState extends ConsumerState<HabitCheckinSheet> {
  late HabitEntryStatus _status;
  late double _value;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _status = widget.initialEntry?.status ?? HabitEntryStatus.done;
    _value = widget.initialEntry?.value ?? (widget.habit.isNumeric ? widget.habit.targetValue : 1.0);
    _noteController = TextEditingController(text: widget.initialEntry?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveCheckin() async {
    await HapticFeedback.mediumImpact();
    final repo = ref.read(habitRepositoryProvider);
    final dateStr = DateBoundary.toDateString(widget.checkinDate);

    await repo.setEntryStatus(
      habitId: widget.habit.id,
      dateStr: dateStr,
      status: _status,
      value: _value,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    // Refresh today's habits data and detail stats
    ref.invalidate(todayHabitsDataProvider);
    ref.invalidate(habitDetailStatsProvider(widget.habit.id));

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
    final habitColor = Color(widget.habit.colorValue);
    final dateFormatted = DateFormat('EEEE, MMM d, yyyy').format(widget.checkinDate);

    return AppSheet(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: PoswalSpacing.lg,
          right: PoswalSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + PoswalSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: habitColor,
                      borderRadius: BorderRadius.circular(PoswalRadii.pill),
                    ),
                  ),
                  const SizedBox(width: PoswalSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.name,
                          style: PoswalText.title.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          dateFormatted,
                          style: PoswalText.caption.copyWith(color: textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(PhosphorIconsRegular.x),
                  ),
                ],
              ),

              const SizedBox(height: PoswalSpacing.lg),

              // Status Selector (Done, Skip, Missed)
              Text(
                'Check-in status',
                style: PoswalText.caption.copyWith(
                  color: textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: PoswalSpacing.xs),
              Row(
                children: [
                  _buildStatusButton(
                    status: HabitEntryStatus.done,
                    label: l10n?.checkinStatusDone ?? 'Done',
                    icon: PhosphorIconsFill.checkCircle,
                    color: isDark ? PoswalColors.teal : PoswalColors.tealLight,
                  ),
                  const SizedBox(width: PoswalSpacing.xs),
                  _buildStatusButton(
                    status: HabitEntryStatus.skipped,
                    label: l10n?.checkinStatusSkip ?? 'Skip',
                    icon: PhosphorIconsFill.shieldStar,
                    color: isDark ? PoswalColors.warning : PoswalColors.warningLight,
                  ),
                  const SizedBox(width: PoswalSpacing.xs),
                  _buildStatusButton(
                    status: HabitEntryStatus.missed,
                    label: l10n?.checkinStatusMissed ?? 'Missed',
                    icon: PhosphorIconsFill.xCircle,
                    color: isDark ? PoswalColors.danger : PoswalColors.dangerLight,
                  ),
                ],
              ),

              if (_status == HabitEntryStatus.skipped) ...[
                const SizedBox(height: PoswalSpacing.xs),
                Row(
                  children: [
                    Icon(PhosphorIconsRegular.info, size: 20, color: isDark ? PoswalColors.warning : PoswalColors.warningLight),
                    const SizedBox(width: PoswalSpacing.xs),
                    Expanded(
                      child: Text(
                        'Skipped days do not break your streak, preserving your habit momentum.',
                        style: PoswalText.caption.copyWith(color: isDark ? PoswalColors.warning : PoswalColors.warningLight),
                      ),
                    ),
                  ],
                ),
              ],

              // Numeric Value Editor
              if (widget.habit.isNumeric && _status == HabitEntryStatus.done) ...[
                const SizedBox(height: PoswalSpacing.lg),
                Text(
                  l10n?.recordProgressTitle(widget.habit.unit) ?? 'Record progress (${widget.habit.unit})',
                  style: PoswalText.caption.copyWith(
                    color: textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PoswalSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PoswalSpacing.md,
                    vertical: PoswalSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight2,
                    borderRadius: BorderRadius.circular(PoswalRadii.card),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _value = (_value - 1.0).clamp(0.0, 999.0);
                          });
                        },
                        icon: const Icon(PhosphorIconsRegular.minusCircle, size: 24),
                        color: isDark ? PoswalColors.teal : PoswalColors.tealLight,
                      ),
                      Column(
                        children: [
                          Text(
                            _value % 1 == 0 ? _value.toInt().toString() : _value.toStringAsFixed(1),
                            style: PoswalText.largeTitle.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Target: ${widget.habit.targetValue.toInt()} ${widget.habit.unit}',
                            style: PoswalText.caption.copyWith(color: textMuted),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _value = (_value + 1.0).clamp(0.0, 999.0);
                          });
                        },
                        icon: const Icon(PhosphorIconsRegular.plusCircle, size: 24),
                        color: isDark ? PoswalColors.teal : PoswalColors.tealLight,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: PoswalSpacing.lg),

              // Note Field
              Text(
                'Check-in note (optional)',
                style: PoswalText.caption.copyWith(
                  color: textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: PoswalSpacing.xs),
              TextField(
                controller: _noteController,
                style: PoswalText.bodyText.copyWith(color: textPrimary),
                decoration: InputDecoration(
                  hintText: l10n?.habitNotePlaceholder ?? 'e.g. Felt great today, did 20 extra minutes',
                  hintStyle: PoswalText.callout.copyWith(color: textMuted),
                  filled: true,
                  fillColor: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight2,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: PoswalSpacing.md,
                    vertical: PoswalSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PoswalRadii.button),
                    borderSide: BorderSide(
                      color: textMuted.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: PoswalSpacing.xl),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                child: AppGlassButton(
                  isPrimary: true,
                  onPressed: _saveCheckin,
                  child: Center(
                    child: Text(l10n?.saveChanges ?? 'Save Check-in'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildStatusButton({
    required HabitEntryStatus status,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _status == status;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _status = status);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.20)
                : (isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight2),
            borderRadius: BorderRadius.circular(PoswalRadii.button),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight).withValues(alpha: 0.25),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : (isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight), size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: PoswalText.caption.copyWith(
                  color: isSelected ? color : (isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
