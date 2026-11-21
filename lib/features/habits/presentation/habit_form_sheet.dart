import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/icon_helper.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class HabitFormSheet extends ConsumerStatefulWidget {
  final Habit? habitToEdit;

  const HabitFormSheet({super.key, this.habitToEdit});

  @override
  ConsumerState<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends ConsumerState<HabitFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;

  late Color _selectedColor;
  late String _selectedIcon;
  late HabitType _habitType;
  late TimeOfDayGroup _timeOfDay;
  late ScheduleType _scheduleType;
  late int _targetDaysPerPeriod;
  late int _everyNDays;

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _nameController = TextEditingController(text: h?.name ?? '');
    _targetController = TextEditingController(text: h != null ? h.targetValue.toInt().toString() : '8');
    _unitController = TextEditingController(text: h?.unit ?? 'glasses');

    _selectedColor = h != null ? Color(h.colorValue) : PoswalColors.teal;
    _selectedIcon = h?.iconName ?? 'drop';
    _habitType = h?.habitType ?? HabitType.yesNo;
    _timeOfDay = h?.timeOfDay ?? TimeOfDayGroup.morning;
    _scheduleType = h?.scheduleType ?? ScheduleType.daily;
    _targetDaysPerPeriod = h?.targetDaysPerPeriod ?? 3;
    _everyNDays = h?.everyNDaysInterval ?? 2;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await HapticFeedback.mediumImpact();
    final repo = ref.read(habitRepositoryProvider);

    final habit = Habit(
      id: widget.habitToEdit?.id ?? '',
      name: name,
      iconName: _selectedIcon,
      colorValue: _selectedColor.toARGB32(),
      habitType: _habitType,
      targetValue: double.tryParse(_targetController.text) ?? 1.0,
      unit: _unitController.text.trim().isEmpty ? 'times' : _unitController.text.trim(),
      timeOfDay: _timeOfDay,
      scheduleType: _scheduleType,
      targetDaysPerPeriod: _targetDaysPerPeriod,
      everyNDaysInterval: _everyNDays,
      startDate: widget.habitToEdit?.startDate ?? DateTime.now(),
      createdAt: widget.habitToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.habitToEdit == null) {
      await repo.createHabit(habit);
    } else {
      await repo.updateHabit(habit);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final cardBg = isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? PoswalColors.surfaceDark : PoswalColors.mist,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(PoswalRadii.sheet)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PoswalSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Header Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: PoswalSpacing.md),

              // Title Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.habitToEdit == null ? 'Create Habit' : 'Edit Habit',
                    style: PoswalText.title.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(PhosphorIconsRegular.x),
                  ),
                ],
              ),
              const SizedBox(height: PoswalSpacing.md),

              // LIVE ROW PREVIEW
              Text('Live Preview', style: PoswalText.caption.copyWith(color: textMuted)),
              const SizedBox(height: PoswalSpacing.xs),
              Container(
                padding: const EdgeInsets.all(PoswalSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(PoswalRadii.card),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        HabitIconHelper.getIcon(_selectedIcon),
                        color: _selectedColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: PoswalSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isEmpty ? 'Your Habit Name' : _nameController.text,
                            style: PoswalText.headline.copyWith(color: textPrimary, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_timeOfDay.displayName} • ${_scheduleType.name}',
                            style: PoswalText.caption.copyWith(color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _selectedColor.withValues(alpha: 0.6), width: 2),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: PoswalSpacing.lg),

              // 1. Name Input
              Text('Habit Name', style: PoswalText.headline.copyWith(color: textPrimary)),
              const SizedBox(height: PoswalSpacing.xs),
              TextField(
                controller: _nameController,
                autofocus: widget.habitToEdit == null,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Read 20 pages, Hydration, Gym',
                  hintStyle: TextStyle(color: textMuted),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PoswalRadii.button),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: PoswalSpacing.lg),

              // 2. Color Palette (10 brand colors)
              Text('Palette Color', style: PoswalText.headline.copyWith(color: textPrimary)),
              const SizedBox(height: PoswalSpacing.xs),
              Wrap(
                spacing: PoswalSpacing.md,
                runSpacing: PoswalSpacing.sm,
                children: PoswalColors.habitPalette.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedColor = color);
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(PhosphorIconsBold.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: PoswalSpacing.lg),

              // 3. Icon Selection
              Text('Icon', style: PoswalText.headline.copyWith(color: textPrimary)),
              const SizedBox(height: PoswalSpacing.xs),
              Wrap(
                spacing: PoswalSpacing.sm,
                runSpacing: PoswalSpacing.sm,
                children: HabitIconHelper.availableIconNames.map((name) {
                  final isSelected = name == _selectedIcon;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIcon = name);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor.withValues(alpha: 0.25) : cardBg,
                        borderRadius: BorderRadius.circular(PoswalRadii.chip),
                        border: Border.all(
                          color: isSelected ? _selectedColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        HabitIconHelper.getIcon(name),
                        color: isSelected ? _selectedColor : textMuted,
                        size: 20,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: PoswalSpacing.lg),

              // 4. Time of Day
              Text('Time of Day', style: PoswalText.headline.copyWith(color: textPrimary)),
              const SizedBox(height: PoswalSpacing.xs),
              AppGlassSegmentedControl<TimeOfDayGroup>(
                values: const [
                  TimeOfDayGroup.morning,
                  TimeOfDayGroup.afternoon,
                  TimeOfDayGroup.evening,
                  TimeOfDayGroup.anytime,
                ],
                labels: const ['Morning', 'Afternoon', 'Evening', 'Anytime'],
                selectedValue: _timeOfDay,
                onValueChanged: (val) => setState(() => _timeOfDay = val),
              ),

              const SizedBox(height: PoswalSpacing.lg),

              // 5. Schedule Cadence
              Text('Schedule', style: PoswalText.headline.copyWith(color: textPrimary)),
              const SizedBox(height: PoswalSpacing.xs),
              AppGlassSegmentedControl<ScheduleType>(
                values: const [
                  ScheduleType.daily,
                  ScheduleType.weekdays,
                  ScheduleType.xPerWeek,
                  ScheduleType.everyNDays,
                ],
                labels: const ['Daily', 'Weekdays', 'Weekly', 'Interval'],
                selectedValue: _scheduleType,
                onValueChanged: (val) => setState(() => _scheduleType = val),
              ),

              const SizedBox(height: PoswalSpacing.huge),

              // Submit Button
              AppGlassButton(
                isPrimary: true,
                onPressed: _saveHabit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsBold.check, size: 18, color: Colors.white),
                    const SizedBox(width: PoswalSpacing.sm),
                    Text(
                      widget.habitToEdit == null ? 'Create Habit' : 'Save Changes',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
