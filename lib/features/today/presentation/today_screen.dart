import 'package:flutter/material.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_form_sheet.dart';
import 'package:poswal_orbit/features/search/presentation/global_search_screen.dart';
import 'package:poswal_orbit/features/settings/presentation/settings_screen.dart';
import 'package:poswal_orbit/features/tasks/application/task_providers.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_row_card.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/features/today/presentation/widgets/habit_row_card.dart';
import 'package:poswal_orbit/features/today/presentation/widgets/hero_orbit_card.dart';
import 'package:poswal_orbit/features/today/presentation/widgets/week_strip.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  String _getGreeting(AppLocalizations? l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n?.greetingMorning ?? 'Good morning';
    if (hour < 17) return l10n?.greetingAfternoon ?? 'Good afternoon';
    return l10n?.greetingEvening ?? 'Good evening';
  }

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
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    final selectedDate = ref.watch(selectedDateProvider);
    final todayAsync = ref.watch(todayHabitsDataProvider);
    final tasksAsync = ref.watch(todayTasksStreamProvider);
    final formattedDate = DateFormat('EEEE, MMM d').format(selectedDate);

    return AuroraBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Bar with Safe Area Handling
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PoswalSpacing.lg,
                  vertical: PoswalSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(l10n),
                          style: PoswalText.title.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: PoswalText.caption.copyWith(color: textMuted),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          key: const ValueKey('global_search_btn'),
                          icon: const Icon(PhosphorIconsRegular.magnifyingGlass, size: 22),
                          color: textPrimary,
                          tooltip: 'Search',
                          onPressed: () => GlobalSearchScreen.push(context),
                        ),
                        IconButton(
                          key: const ValueKey('settings_btn'),
                          icon: const Icon(PhosphorIconsRegular.gear, size: 22),
                          color: textPrimary,
                          tooltip: 'Settings',
                          onPressed: () => SettingsScreen.push(context),
                        ),
                        IconButton(
                          icon: const Icon(PhosphorIconsRegular.palette, size: 22),
                          color: textPrimary,
                          tooltip: 'Design Playground',
                          onPressed: () => context.push('/playground'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Week Strip
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                child: WeekStrip(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: PoswalSpacing.lg)),

            // 3. Main Content
            todayAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: PoswalColors.teal),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error loading habits: $err',
                    style: const TextStyle(color: PoswalColors.danger),
                  ),
                ),
              ),
              data: (data) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Hero Orbit Ring Card
                      HeroOrbitCard(
                        totalDue: data.totalDue,
                        totalDone: data.totalDone,
                        completionRate: data.completionRate,
                      ),

                      const SizedBox(height: PoswalSpacing.xl),

                      // Empty State
                      if (data.allScheduled.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.xxl),
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: PoswalColors.teal.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    PhosphorIconsRegular.sparkle,
                                    color: PoswalColors.teal,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: PoswalSpacing.md),
                                Text(
                                  l10n?.yourOrbitClear ?? 'Your Orbit is Clear',
                                  style: PoswalText.headline.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: PoswalSpacing.xs),
                                Text(
                                  l10n?.noHabitsScheduled ??
                                      'No habits scheduled for this day.\nRest and recharge, or create a new habit below.',
                                  textAlign: TextAlign.center,
                                  style: PoswalText.callout.copyWith(color: textMuted),
                                ),
                                const SizedBox(height: PoswalSpacing.lg),
                                AppGlassButton(
                                  isPrimary: true,
                                  onPressed: () => _openCreateSheet(context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(PhosphorIconsBold.plus, size: 16, color: Colors.white),
                                      const SizedBox(width: PoswalSpacing.xs),
                                      Text(l10n?.addHabit ?? 'Add Habit'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Grouped Habits
                      if (data.allScheduled.isNotEmpty) ...[
                        for (final group in [
                          TimeOfDayGroup.morning,
                          TimeOfDayGroup.afternoon,
                          TimeOfDayGroup.evening,
                          TimeOfDayGroup.anytime,
                        ]) ...[
                          if (data.grouped[group]?.isNotEmpty ?? false) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                top: PoswalSpacing.md,
                                bottom: PoswalSpacing.sm,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getGroupIcon(group),
                                    color: PoswalColors.teal,
                                    size: 16,
                                  ),
                                  const SizedBox(width: PoswalSpacing.xs),
                                  Text(
                                    group.displayName,
                                    style: PoswalText.caption.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: PoswalSpacing.sm),
                                  Text(
                                    '(${data.grouped[group]!.length})',
                                    style: PoswalText.caption.copyWith(color: textMuted),
                                  ),
                                ],
                              ),
                            ),
                            for (final item in data.grouped[group]!)
                              HabitRowCard(
                                item: item,
                                onEdit: () => _openEditSheet(context, item.habit),
                              ),
                          ],
                        ],
                      ],

                      // 4. Tasks Due & Overdue Section
                      Padding(
                        padding: const EdgeInsets.only(
                          top: PoswalSpacing.xl,
                          bottom: PoswalSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              PhosphorIconsBold.checkSquare,
                              color: PoswalColors.teal,
                              size: 18,
                            ),
                            const SizedBox(width: PoswalSpacing.xs),
                            Text(
                              l10n?.tasksTitle ?? 'Tasks',
                              style: PoswalText.caption.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            tasksAsync.maybeWhen(
                              data: (tasks) {
                                final pending = tasks.where((t) => !t.isCompleted).length;
                                return Padding(
                                  padding: const EdgeInsets.only(left: PoswalSpacing.sm),
                                  child: Text(
                                    l10n?.tasksDueCount(pending) ?? '($pending due)',
                                    style: PoswalText.caption.copyWith(color: textMuted),
                                  ),
                                );
                              },
                              orElse: () => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),

                      tasksAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: PoswalSpacing.md),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: PoswalColors.teal),
                            ),
                          ),
                        ),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm),
                          child: Text(
                            'Unable to load tasks: $err',
                            style: const TextStyle(color: PoswalColors.danger, fontSize: 12),
                          ),
                        ),
                        data: (tasks) {
                          if (tasks.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.md),
                              child: Center(
                                child: Text(
                                  l10n?.allClear ?? 'All clear. Enjoy the quiet.',
                                  style: PoswalText.callout.copyWith(
                                    color: textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final task in tasks)
                                TaskRowCard(task: task),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 100), // Space for floating bottom tab bar
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGroupIcon(TimeOfDayGroup group) {
    switch (group) {
      case TimeOfDayGroup.morning:
        return PhosphorIconsRegular.sunHorizon;
      case TimeOfDayGroup.afternoon:
        return PhosphorIconsRegular.sun;
      case TimeOfDayGroup.evening:
        return PhosphorIconsRegular.moon;
      case TimeOfDayGroup.anytime:
        return PhosphorIconsRegular.clock;
    }
  }
}
