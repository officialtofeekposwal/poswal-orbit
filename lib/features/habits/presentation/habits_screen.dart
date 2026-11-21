import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/core/widgets/icon_helper.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_form_sheet.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HabitFormSheet(),
    );
  }

  void _openEditSheet(BuildContext context, Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitFormSheet(habitToEdit: habit),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final habitsAsync = ref.watch(activeHabitsStreamProvider);

    return AuroraBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PoswalSpacing.lg,
                  vertical: PoswalSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Habits',
                      style: PoswalText.largeTitle.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(PhosphorIconsBold.plus),
                      color: PoswalColors.teal,
                      onPressed: () => _openCreateSheet(context),
                    ),
                  ],
                ),
              ),
            ),

            habitsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: PoswalColors.teal),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
              data: (habits) {
                if (habits.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(PhosphorIconsRegular.target, size: 48, color: PoswalColors.teal),
                          const SizedBox(height: PoswalSpacing.md),
                          Text('No Habits Yet', style: PoswalText.headline.copyWith(color: textPrimary)),
                          const SizedBox(height: PoswalSpacing.xs),
                          Text(
                            'Create your first habit to begin your orbit.',
                            style: PoswalText.callout.copyWith(color: textMuted),
                          ),
                          const SizedBox(height: PoswalSpacing.lg),
                          AppGlassButton(
                            isPrimary: true,
                            onPressed: () => _openCreateSheet(context),
                            child: const Text('Add Habit'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = habits[index];
                        final habitColor = Color(habit.colorValue);
                        return Container(
                          margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
                          padding: const EdgeInsets.all(PoswalSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
                            borderRadius: BorderRadius.circular(PoswalRadii.card),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(PoswalRadii.card),
                            onTap: () => _openEditSheet(context, habit),
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
                                        style: PoswalText.headline.copyWith(
                                          color: textPrimary,
                                          fontSize: 16,
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
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: habits.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
