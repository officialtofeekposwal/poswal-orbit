import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_toolbar.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/core/widgets/icon_helper.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_form_sheet.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_heatmap.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_month_calendar.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_stats_charts.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
  });

  void _openEditSheet(BuildContext context, Habit habit) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitFormSheet(habitToEdit: habit),
    );
  }

  Future<void> _toggleArchive(BuildContext context, WidgetRef ref, Habit habit) async {
    await HapticFeedback.mediumImpact();
    final repo = ref.read(habitRepositoryProvider);
    final willArchive = !habit.isArchived;

    await repo.archiveHabit(habit.id, willArchive);
    ref.invalidate(todayHabitsDataProvider);
    ref.invalidate(habitDetailStatsProvider(habit.id));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(willArchive ? 'Habit archived' : 'Habit restored to active'),
          duration: const Duration(seconds: 2),
        ),
      );
      if (willArchive) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    final habitAsync = ref.watch(singleHabitStreamProvider(habitId));
    final statsAsync = ref.watch(habitDetailStatsProvider(habitId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: habitAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: PoswalColors.teal),
            ),
            error: (err, _) => Center(
              child: Text('Error loading habit: $err', style: const TextStyle(color: PoswalColors.danger)),
            ),
            data: (habit) {
              if (habit == null) {
                return Center(
                  child: Text(l10n?.habitNotFound ?? 'Habit not found', style: PoswalText.title.copyWith(color: textPrimary)),
                );
              }

              final habitColor = Color(habit.colorValue);
              final scheduleDesc = ScheduleEngine.formatScheduleDescription(habit);

              return CustomScrollView(
                slivers: [
                  // App Bar with HIG Glass AppToolbar
                  SliverToBoxAdapter(
                    child: AppToolbar(
                      leading: IconButton(
                        icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 20),
                        color: textPrimary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: Text(
                        'Habit Orbit',
                        style: PoswalText.title.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 18),
                          color: textPrimary,
                          onPressed: () => _openEditSheet(context, habit),
                        ),
                        IconButton(
                          icon: Icon(
                            habit.isArchived ? PhosphorIconsRegular.archiveBox : PhosphorIconsRegular.archive,
                            size: 18,
                            color: habit.isArchived ? PoswalColors.teal : textMuted,
                          ),
                          onPressed: () => _toggleArchive(context, ref, habit),
                        ),
                      ],
                    ),
                  ),

                  // Habit Hero Identity
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                      child: Column(
                        children: [
                          const SizedBox(height: PoswalSpacing.md),
                          Hero(
                            tag: 'habit_icon_${habit.id}',
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: habitColor.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: habitColor.withValues(alpha: 0.45),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: habitColor.withValues(alpha: 0.25),
                                    blurRadius: 18,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  HabitIconHelper.getIcon(habit.iconName),
                                  color: habitColor,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: PoswalSpacing.md),
                          Text(
                            habit.name,
                            textAlign: TextAlign.center,
                            style: PoswalText.largeTitle.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: PoswalSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${habit.timeOfDay.displayName} • $scheduleDesc',
                                style: PoswalText.callout.copyWith(color: textMuted),
                              ),
                              if (habit.isArchived) ...[
                                const SizedBox(width: PoswalSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: PoswalColors.gold.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(PoswalRadii.xs),
                                  ),
                                  child: Text(
                                    l10n?.habitsArchived ?? 'Archived',
                                    style: PoswalText.micro.copyWith(
                                      color: PoswalColors.gold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: PoswalSpacing.lg),
                        ],
                      ),
                    ),
                  ),

                  // Stats & Analytics Sections
                  statsAsync.when(
                    loading: () => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(PoswalSpacing.xxl),
                        child: Center(child: CircularProgressIndicator(color: PoswalColors.teal)),
                      ),
                    ),
                    error: (err, _) => SliverToBoxAdapter(
                      child: Text('Error calculating stats: $err', style: const TextStyle(color: PoswalColors.danger)),
                    ),
                    data: (stats) {
                      if (stats == null) return const SliverToBoxAdapter(child: SizedBox());

                      final scorePercent = (stats.habitScore * 100).toInt();
                      final ratePercent = (stats.completionRate * 100).toInt();

                      // Collect notes entries
                      final notesEntries = stats.entries
                          .where((e) => e.note != null && e.note!.trim().isNotEmpty)
                          .toList()
                          .reversed
                          .toList();

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // 1. 2x2 Hero Stats Grid (Solid surfaces on content layer, HIG Rule 2)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildHeroStatCard(
                                    title: l10n?.currentStreakLabel.toUpperCase() ?? 'CURRENT STREAK',
                                    value: '${stats.currentStreak}d',
                                    icon: PhosphorIconsFill.fire,
                                    color: PoswalColors.gold,
                                    subtitle: l10n?.habitConsecutiveOccurrences ?? 'consecutive occurrences',
                                    textPrimary: textPrimary,
                                    textMuted: textMuted,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: PoswalSpacing.sm),
                                Expanded(
                                  child: _buildHeroStatCard(
                                    title: l10n?.bestStreakLabel.toUpperCase() ?? 'BEST STREAK',
                                    value: '${stats.bestStreak}d',
                                    icon: PhosphorIconsFill.trophy,
                                    color: PoswalColors.violet,
                                    subtitle: l10n?.habitHistoricalRecord ?? 'historical record',
                                    textPrimary: textPrimary,
                                    textMuted: textMuted,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: PoswalSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildHeroStatCard(
                                    title: l10n?.habitScoreLabel.toUpperCase() ?? 'HABIT SCORE',
                                    value: '$scorePercent%',
                                    icon: PhosphorIconsFill.chartLineUp,
                                    color: PoswalColors.teal,
                                    subtitle: l10n?.habitEwmaConsistency ?? '14-day EWMA consistency',
                                    textPrimary: textPrimary,
                                    textMuted: textMuted,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: PoswalSpacing.sm),
                                Expanded(
                                  child: _buildHeroStatCard(
                                    title: l10n?.completionRateLabel.toUpperCase() ?? 'COMPLETION RATE',
                                    value: '$ratePercent%',
                                    icon: PhosphorIconsFill.checkCircle,
                                    color: PoswalColors.coral,
                                    subtitle: '${stats.totalCompleted}/${stats.totalScheduled} scheduled',
                                    textPrimary: textPrimary,
                                    textMuted: textMuted,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: PoswalSpacing.lg),

                            // 2. GitHub-Style Heatmap
                            HabitHeatmap(
                              habit: habit,
                              entries: stats.entries,
                              weeksToShow: 14,
                            ),

                            const SizedBox(height: PoswalSpacing.lg),

                            // 3. Monthly Calendar (Interactive Past Day Editor)
                            HabitMonthCalendar(
                              habit: habit,
                              entries: stats.entries,
                            ),

                            const SizedBox(height: PoswalSpacing.lg),

                            // 4. Weekly Performance Bars
                            HabitWeeklyBars(
                              habit: habit,
                              weekdayCompletions: stats.weekdayCompletions,
                            ),

                            const SizedBox(height: PoswalSpacing.lg),

                            // 5. 30-Day Consistency Trend Curve
                            HabitTrendLine(
                              habit: habit,
                              entries: stats.entries,
                            ),

                            const SizedBox(height: PoswalSpacing.lg),

                            // 6. Check-in Notes History (Solid semi-solid surface, no glass on content)
                            Container(
                              padding: const EdgeInsets.all(PoswalSpacing.lg),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'CHECK-IN NOTES',
                                        style: PoswalText.caption.copyWith(
                                          color: textMuted,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      Text(
                                        '${notesEntries.length} total',
                                        style: PoswalText.caption.copyWith(color: textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: PoswalSpacing.md),
                                  if (notesEntries.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.md),
                                      child: Center(
                                        child: Text(
                                          'No notes added yet.\nLong-press any day to add check-in reflections.',
                                          textAlign: TextAlign.center,
                                          style: PoswalText.callout.copyWith(color: textMuted),
                                        ),
                                      ),
                                    )
                                  else
                                    for (final entry in notesEntries) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.xs),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(top: 4),
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: habitColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: PoswalSpacing.sm),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    entry.entryDate,
                                                    style: PoswalText.caption.copyWith(
                                                      color: textMuted,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    entry.note ?? '',
                                                    style: PoswalText.bodyText.copyWith(color: textPrimary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (entry != notesEntries.last)
                                        Divider(color: isDark ? Colors.white10 : Colors.black12, height: 16),
                                    ],
                                ],
                              ),
                            ),

                            const SizedBox(height: PoswalSpacing.xxl),
                          ]),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(PoswalSpacing.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: PoswalText.micro.copyWith(
                  color: textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: PoswalSpacing.xs),
          Text(
            value,
            style: PoswalText.title.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: PoswalText.micro.copyWith(color: textMuted),
          ),
        ],
      ),
    );
  }
}
