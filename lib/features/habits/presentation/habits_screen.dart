import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_toolbar.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/core/widgets/icon_helper.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_detail_screen.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_form_sheet.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  int _selectedTab = 0; // 0 = Active, 1 = Archived

  void _openCreateSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HabitFormSheet(),
    );
  }

  void _openEditSheet(BuildContext context, Habit habit) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitFormSheet(habitToEdit: habit),
    );
  }

  void _openDetail(BuildContext context, Habit habit) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HabitDetailScreen(habitId: habit.id),
      ),
    );
  }

  Future<void> _restoreHabit(BuildContext context, Habit habit) async {
    await HapticFeedback.mediumImpact();
    final repo = ref.read(habitRepositoryProvider);
    await repo.archiveHabit(habit.id, false);
    ref.invalidate(todayHabitsDataProvider);
    ref.invalidate(archivedHabitsStreamProvider);
    ref.invalidate(activeHabitsStreamProvider);

    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.habitRestored(habit.name) ?? 'Restored "${habit.name}" to Active Habits')),
      );
    }
  }

  Future<void> _deleteHabit(BuildContext context, Habit habit) async {
    await HapticFeedback.heavyImpact();
    final repo = ref.read(habitRepositoryProvider);
    await repo.deleteHabit(habit.id);
    ref.invalidate(todayHabitsDataProvider);
    ref.invalidate(archivedHabitsStreamProvider);

    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.habitDeleted(habit.name) ?? 'Permanently deleted "${habit.name}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    final activeHabitsAsync = ref.watch(activeHabitsStreamProvider);
    final archivedHabitsAsync = ref.watch(archivedHabitsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with AppToolbar (Apple HIG Rule 6)
              AppToolbar(
                title: Text(
                  l10n?.allHabits ?? 'Habits',
                  style: PoswalText.largeTitle.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                showAddButton: true,
                addTooltip: l10n?.addHabit ?? 'Add Habit',
                addKey: const ValueKey('habits_toolbar_add_btn'),
                onAddPressed: () => _openCreateSheet(context),
              ),

              // Segmented Filter (Active vs Archived)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                child: AppGlassSegmentedControl<int>(
                  values: const [0, 1],
                  labels: [
                    activeHabitsAsync.maybeWhen(
                      data: (list) => '${l10n?.habitsActive ?? "Active"} (${list.length})',
                      orElse: () => l10n?.habitsActive ?? 'Active',
                    ),
                    archivedHabitsAsync.maybeWhen(
                      data: (list) => '${l10n?.habitsArchived ?? "Archived"} (${list.length})',
                      orElse: () => l10n?.habitsArchived ?? 'Archived',
                    ),
                  ],
                  selectedValue: _selectedTab,
                  onValueChanged: (val) {
                    setState(() => _selectedTab = val);
                  },
                ),
              ),
              const SizedBox(height: PoswalSpacing.md),

              // Streak Freeze Banner (Solid semi-solid surface on content, HIG Rule 2)
              if (_selectedTab == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PoswalSpacing.md,
                      vertical: PoswalSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
                      borderRadius: BorderRadius.circular(PoswalRadii.card),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: PoswalColors.gold.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(PhosphorIconsFill.shieldCheck, color: PoswalColors.gold, size: 18),
                        ),
                        const SizedBox(width: PoswalSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.streakFreezeActive ?? '1 Streak Freeze Active',
                                style: PoswalText.caption.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                l10n?.streakFreezeDescription ?? 'Protects one missed scheduled day per month.',
                                style: PoswalText.micro.copyWith(color: textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: PoswalSpacing.sm),

              // List View (Active Reorderable OR Archived)
              Expanded(
                child: _selectedTab == 0
                    ? _buildActiveReorderableList(activeHabitsAsync, isDark, textPrimary, textMuted)
                    : _buildArchivedList(archivedHabitsAsync, isDark, textPrimary, textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveReorderableList(
    AsyncValue<List<Habit>> habitsAsync,
    bool isDark,
    Color textPrimary,
    Color textMuted,
  ) {
    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: PoswalColors.teal)),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: PoswalColors.danger))),
      data: (habits) {
        if (habits.isEmpty) {
          final l10n = AppLocalizations.of(context);
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(PhosphorIconsRegular.target, size: 48, color: PoswalColors.teal),
                const SizedBox(height: PoswalSpacing.md),
                Text(l10n?.noHabitsYet ?? 'No Habits Yet', style: PoswalText.headline.copyWith(color: textPrimary)),
                const SizedBox(height: PoswalSpacing.xs),
                Text(
                  l10n?.noHabitsYetSubtitle ?? 'Create your first habit to begin your orbit.',
                  style: PoswalText.callout.copyWith(color: textMuted),
                ),
                const SizedBox(height: PoswalSpacing.lg),
                AppGlassButton(
                  isPrimary: true,
                  onPressed: () => _openCreateSheet(context),
                  child: Text(l10n?.addHabit ?? 'Add Habit'),
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.only(
            left: PoswalSpacing.lg,
            right: PoswalSpacing.lg,
            top: PoswalSpacing.xs,
            bottom: 100,
          ),
          itemCount: habits.length,
          onReorder: (oldIndex, newIndex) async {
            await HapticFeedback.selectionClick();
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final list = List<Habit>.from(habits);
            final item = list.removeAt(oldIndex);
            list.insert(newIndex, item);

            final repo = ref.read(habitRepositoryProvider);
            await repo.reorderHabits(list.map((h) => h.id).toList());
            ref.invalidate(activeHabitsStreamProvider);
          },
          itemBuilder: (context, index) {
            final habit = habits[index];
            final habitColor = Color(habit.colorValue);

            return Container(
              key: ValueKey(habit.id),
              margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
                borderRadius: BorderRadius.circular(PoswalRadii.card),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(PoswalRadii.card),
                onTap: () => _openDetail(context, habit),
                child: Padding(
                  padding: const EdgeInsets.all(PoswalSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: habitColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          HabitIconHelper.getIcon(habit.iconName),
                          color: habitColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: PoswalSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: PoswalText.callout.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${habit.timeOfDay.displayName} • ${ScheduleEngine.formatScheduleDescription(habit)}',
                              style: PoswalText.caption.copyWith(color: textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 18),
                        color: textMuted,
                        onPressed: () => _openEditSheet(context, habit),
                      ),
                      const SizedBox(width: 4),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(PhosphorIconsRegular.dotsSixVertical, color: Colors.grey, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArchivedList(
    AsyncValue<List<Habit>> archivedAsync,
    bool isDark,
    Color textPrimary,
    Color textMuted,
  ) {
    return archivedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: PoswalColors.teal)),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: PoswalColors.danger))),
      data: (habits) {
        final l10n = AppLocalizations.of(context);
        if (habits.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(PhosphorIconsRegular.archiveBox, size: 48, color: PoswalColors.violet),
                const SizedBox(height: PoswalSpacing.md),
                Text(l10n?.noArchivedHabits ?? 'No Archived Habits', style: PoswalText.headline.copyWith(color: textPrimary)),
                const SizedBox(height: PoswalSpacing.xs),
                Text(
                  l10n?.noArchivedHabitsSubtitle ??
                      'Archived habits are stored safely here without cluttering your daily view.',
                  textAlign: TextAlign.center,
                  style: PoswalText.callout.copyWith(color: textMuted),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: PoswalSpacing.lg,
            right: PoswalSpacing.lg,
            top: PoswalSpacing.xs,
            bottom: 100,
          ),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            final habitColor = Color(habit.colorValue);

            return Container(
              margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
              padding: const EdgeInsets.all(PoswalSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? PoswalColors.surfaceDark2.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(PoswalRadii.card),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      HabitIconHelper.getIcon(habit.iconName),
                      color: habitColor.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: PoswalSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: PoswalText.callout.copyWith(
                            color: textMuted,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n?.archivedTapToRestore ?? 'Archived • Tap restore to reactivate',
                          style: PoswalText.caption.copyWith(color: textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.arrowCounterClockwise, size: 20),
                    color: PoswalColors.teal,
                    tooltip: l10n?.restoreHabitTooltip ?? 'Restore Habit',
                    onPressed: () => _restoreHabit(context, habit),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.trash, size: 20),
                    color: PoswalColors.danger,
                    tooltip: l10n?.deletePermanentlyTooltip ?? 'Delete Permanently',
                    onPressed: () => _deleteHabit(context, habit),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
