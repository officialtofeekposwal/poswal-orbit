import 'package:flutter/material.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_list_section.dart';
import 'package:poswal_orbit/core/widgets/app_search_field.dart';
import 'package:poswal_orbit/core/widgets/app_toolbar.dart';
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
            // 1. Top Bar with Safe Area Handling (AppToolbar + Inline Search)
            SliverToBoxAdapter(
              child: AppToolbar(
                title: Column(
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
                actions: [
                  IconButton(
                    key: const ValueKey('global_search_btn'),
                    icon: const Icon(PhosphorIconsRegular.magnifyingGlass, size: 20),
                    color: textPrimary,
                    tooltip: l10n?.searchTooltip ?? 'Search',
                    onPressed: () => GlobalSearchScreen.push(context),
                  ),
                  IconButton(
                    key: const ValueKey('settings_btn'),
                    icon: const Icon(PhosphorIconsRegular.gear, size: 20),
                    color: textPrimary,
                    tooltip: l10n?.settingsTooltip ?? 'Settings',
                    onPressed: () => SettingsScreen.push(context),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.palette, size: 20),
                    color: textPrimary,
                    tooltip: l10n?.designPlaygroundTooltip ?? 'Design Playground',
                    onPressed: () => context.push('/playground'),
                  ),
                ],
                showAddButton: true,
                addTooltip: 'Create new item',
                addKey: const ValueKey('app_fab_button'),
                onAddPressed: () => _openCreateSheet(context),
              ),
            ),

            // Inline Expandable Search Field (HIG Search Pattern)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  PoswalSpacing.lg,
                  0,
                  PoswalSpacing.lg,
                  PoswalSpacing.sm,
                ),
                child: AppSearchField(
                  hintText: l10n?.searchTooltip ?? 'Search habits, tasks, notes...',
                  onChanged: (val) {
                    if (val.trim().isNotEmpty) {
                      GlobalSearchScreen.push(context);
                    }
                  },
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

                      // Grouped Habits in Inset Grouped AppListSection (HIG Rule 9: Title Case Headers)
                      if (data.allScheduled.isNotEmpty) ...[
                        for (final group in [
                          TimeOfDayGroup.morning,
                          TimeOfDayGroup.afternoon,
                          TimeOfDayGroup.evening,
                          TimeOfDayGroup.anytime,
                        ]) ...[
                          if (data.grouped[group]?.isNotEmpty ?? false) ...[
                            AppListSection(
                              title: _getGroupTitle(group),
                              headerTrailing: Text(
                                '(${data.grouped[group]!.length})',
                                style: PoswalText.caption.copyWith(color: textMuted),
                              ),
                              margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
                              children: [
                                for (final item in data.grouped[group]!)
                                  HabitRowCard(
                                    item: item,
                                    inGroupedSection: true,
                                    onEdit: () => _openEditSheet(context, item.habit),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ],

                      // 4. Tasks Due & Overdue Section in Inset Grouped AppListSection
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
                          final pending = tasks.where((t) => !t.isCompleted).length;
                          return AppListSection(
                            title: l10n?.tasksTitle ?? 'Tasks',
                            headerTrailing: pending > 0
                                ? Text(
                                    l10n?.tasksDueCount(pending) ?? '($pending due)',
                                    style: PoswalText.caption.copyWith(color: textMuted),
                                  )
                                : null,
                            margin: const EdgeInsets.only(bottom: PoswalSpacing.md),
                            children: tasks.isEmpty
                                ? [
                                    Padding(
                                      padding: const EdgeInsets.all(PoswalSpacing.lg),
                                      child: Center(
                                        child: Text(
                                          l10n?.allClear ?? 'All clear. Enjoy the quiet.',
                                          style: PoswalText.callout.copyWith(
                                            color: textMuted,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                : [
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

  String _getGroupTitle(TimeOfDayGroup group) {
    switch (group) {
      case TimeOfDayGroup.morning:
        return 'Morning Habits';
      case TimeOfDayGroup.afternoon:
        return 'Afternoon Habits';
      case TimeOfDayGroup.evening:
        return 'Evening Habits';
      case TimeOfDayGroup.anytime:
        return 'Anytime Habits';
    }
  }
}
