import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_heatmap.dart';
import 'package:poswal_orbit/features/insights/application/insights_providers.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  final GlobalKey _shareBoundaryKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareStatsCard(BuildContext context) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    unawaited(HapticFeedback.mediumImpact());

    try {
      final boundary = _shareBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Render boundary unavailable');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to encode PNG image');
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/orbit_weekly_stats_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'My weekly rhythm on Poswal Orbit 🚀',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e', style: PoswalText.callout.copyWith(color: Colors.white)),
            backgroundColor: PoswalColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final l10n = AppLocalizations.of(context);

    final insightsAsync = ref.watch(insightsDataProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Header Bar
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
                        l10n?.insightsTitle ?? 'Insights',
                        style: PoswalText.largeTitle.copyWith(color: textPrimary),
                      ),
                      insightsAsync.maybeWhen(
                        data: (state) => state.hasAnyData
                            ? AppGlassButton(
                                key: const ValueKey('share_insights_button'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PoswalSpacing.md,
                                  vertical: PoswalSpacing.sm,
                                ),
                                onPressed: () => _shareStatsCard(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isSharing)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: PoswalColors.teal,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        PhosphorIconsRegular.shareNetwork,
                                        size: 18,
                                        color: PoswalColors.teal,
                                      ),
                                    const SizedBox(width: PoswalSpacing.xs),
                                    Text(
                                      l10n?.shareCard ?? 'Share',
                                      style: PoswalText.caption.copyWith(
                                        color: PoswalColors.teal,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Main Content
              insightsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: PoswalColors.teal),
                  ),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Failed to load insights: $err',
                      style: const TextStyle(color: PoswalColors.danger),
                    ),
                  ),
                ),
                data: (state) {
                  if (!state.hasAnyData) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(PoswalSpacing.xl),
                          child: AppGlassCard(
                            key: const ValueKey('insights_empty_state_card'),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: PoswalGradients.aurora,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: PoswalColors.teal.withValues(alpha: 0.3),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    PhosphorIconsRegular.chartLineUp,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: PoswalSpacing.lg),
                                Text(
                                  l10n?.insightsEmptyTitle ?? 'Your insights will grow as you go',
                                  textAlign: TextAlign.center,
                                  style: PoswalText.title.copyWith(color: textPrimary),
                                ),
                                const SizedBox(height: PoswalSpacing.xs),
                                Text(
                                  l10n?.insightsEmptySubtitle ??
                                      'Complete habits and check off tasks to unlock personalized patterns, weekly review cards, and productivity scores.',
                                  textAlign: TextAlign.center,
                                  style: PoswalText.callout.copyWith(color: textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // --- Shareable Block: Weekly Review & Score ---
                        RepaintBoundary(
                          key: _shareBoundaryKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildWeeklyReviewCard(context, state, l10n, textPrimary, textMuted),
                              const SizedBox(height: PoswalSpacing.md),
                              _buildProductivityScoreCard(context, state, l10n, textPrimary, textMuted),
                            ],
                          ),
                        ),

                        const SizedBox(height: PoswalSpacing.md),

                        // --- Best Day & Best Time ---
                        _buildBestTimingCard(context, state, l10n, textPrimary, textMuted),

                        const SizedBox(height: PoswalSpacing.md),

                        // --- Habit vs Task Correlation ---
                        _buildCorrelationCard(context, state, l10n, textPrimary, textMuted),

                        const SizedBox(height: PoswalSpacing.md),

                        // --- Overall Heatmap ---
                        _buildOverallHeatmapCard(context, state, l10n, textPrimary, textMuted),

                        const SizedBox(height: PoswalSpacing.md),

                        // --- Per-Habit Heatmaps ---
                        if (state.habits.isNotEmpty) ...[
                          Text(
                            l10n?.habitHeatmaps ?? 'Habit Heatmaps',
                            style: PoswalText.headline.copyWith(color: textPrimary),
                          ),
                          const SizedBox(height: PoswalSpacing.sm),
                          ...state.habits.map((habit) {
                            final habitEntries = state.entries.where((e) => e.habitId == habit.id).toList();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: PoswalSpacing.md),
                              child: HabitHeatmap(
                                habit: habit,
                                entries: habitEntries,
                                weeksToShow: 10,
                              ),
                            );
                          }),
                        ],

                        // Extra bottom spacing for floating tab bar
                        const SizedBox(height: 100),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyReviewCard(
    BuildContext context,
    InsightsState state,
    AppLocalizations? l10n,
    Color textPrimary,
    Color textMuted,
  ) {
    return AppGlassCard(
      key: const ValueKey('insights_weekly_review_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PoswalSpacing.xs),
                decoration: BoxDecoration(
                  gradient: PoswalGradients.aurora,
                  borderRadius: BorderRadius.circular(PoswalRadii.chip),
                ),
                child: const Icon(PhosphorIconsRegular.sparkle, color: Colors.white, size: 18),
              ),
              const SizedBox(width: PoswalSpacing.sm),
              Text(
                l10n?.weeklyReviewTitle ?? 'Weekly Review',
                style: PoswalText.headline.copyWith(color: textPrimary),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.md),
          Text(
            '"${state.weeklyReview.encouragingMessage}"',
            style: PoswalText.callout.copyWith(
              color: textPrimary,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: PoswalSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildMetricColumn(
                  '${state.weeklyReview.habitsCompleted}',
                  'Habits Done',
                  PoswalColors.teal,
                  textMuted,
                ),
              ),
              Expanded(
                child: _buildMetricColumn(
                  '${state.weeklyReview.tasksCompleted}',
                  'Tasks Finished',
                  PoswalColors.violet,
                  textMuted,
                ),
              ),
              Expanded(
                child: _buildMetricColumn(
                  '${state.weeklyReview.bestStreak}d',
                  'Best Streak',
                  PoswalColors.coral,
                  textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label, Color accentColor, Color textMuted) {
    return Column(
      children: [
        Text(
          value,
          style: PoswalText.largeTitle.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: PoswalText.caption.copyWith(color: textMuted),
        ),
      ],
    );
  }

  Widget _buildProductivityScoreCard(
    BuildContext context,
    InsightsState state,
    AppLocalizations? l10n,
    Color textPrimary,
    Color textMuted,
  ) {
    final score = state.productivityScore;
    Color gradeColor;
    if (score.score >= 85) {
      gradeColor = PoswalColors.teal;
    } else if (score.score >= 65) {
      gradeColor = PoswalColors.violet;
    } else if (score.score >= 40) {
      gradeColor = PoswalColors.gold;
    } else {
      gradeColor = textMuted;
    }

    return AppGlassCard(
      key: const ValueKey('insights_productivity_score_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.productivityScore ?? 'Productivity Score',
                style: PoswalText.headline.copyWith(color: textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(PoswalRadii.pill),
                  border: Border.all(color: gradeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  score.grade,
                  style: PoswalText.caption.copyWith(
                    color: gradeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${score.score.toInt()}',
                style: PoswalText.largeTitle.copyWith(
                  color: gradeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                ),
              ),
              const SizedBox(width: PoswalSpacing.xs),
              Text(
                '/ 100',
                style: PoswalText.title.copyWith(color: textMuted),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(PoswalRadii.pill),
            child: LinearProgressIndicator(
              value: (score.score / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
            ),
          ),
          const SizedBox(height: PoswalSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Habits: ${score.habitConsistency.toInt()}% (60% weight)',
                  style: PoswalText.caption.copyWith(color: textMuted),
                ),
              ),
              const SizedBox(width: PoswalSpacing.xs),
              Expanded(
                child: Text(
                  'Tasks: ${score.taskCompletionRate.toInt()}% (40% weight)',
                  textAlign: TextAlign.end,
                  style: PoswalText.caption.copyWith(color: textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestTimingCard(
    BuildContext context,
    InsightsState state,
    AppLocalizations? l10n,
    Color textPrimary,
    Color textMuted,
  ) {
    final timing = state.bestTiming;

    return AppGlassCard(
      key: const ValueKey('insights_best_timing_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.clock, color: PoswalColors.teal, size: 20),
              const SizedBox(width: PoswalSpacing.xs),
              Text(
                'Peak Momentum',
                style: PoswalText.headline.copyWith(color: textPrimary),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(PoswalSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(PoswalRadii.card),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.bestDayOfWeek ?? 'Best Day of Week',
                        style: PoswalText.caption.copyWith(color: textMuted),
                      ),
                      const SizedBox(height: PoswalSpacing.xs),
                      Text(
                        timing.bestWeekdayName,
                        style: PoswalText.callout.copyWith(
                          color: PoswalColors.teal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: PoswalSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(PoswalSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(PoswalRadii.card),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.bestTimeOfDay ?? 'Best Time of Day',
                        style: PoswalText.caption.copyWith(color: textMuted),
                      ),
                      const SizedBox(height: PoswalSpacing.xs),
                      Text(
                        timing.bestTimeOfDayRange,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PoswalText.callout.copyWith(
                          color: PoswalColors.violet,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationCard(
    BuildContext context,
    InsightsState state,
    AppLocalizations? l10n,
    Color textPrimary,
    Color textMuted,
  ) {
    final corr = state.correlation;

    return AppGlassCard(
      key: const ValueKey('insights_correlation_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(PhosphorIconsRegular.intersect, color: PoswalColors.coral, size: 20),
                  const SizedBox(width: PoswalSpacing.xs),
                  Text(
                    l10n?.habitTaskCorrelation ?? 'Habit & Task Correlation',
                    style: PoswalText.headline.copyWith(color: textPrimary),
                  ),
                ],
              ),
              if (corr.hasEnoughData)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.xs, vertical: 2),
                  decoration: BoxDecoration(
                    color: PoswalColors.coral.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(PoswalRadii.pill),
                  ),
                  child: Text(
                    'Observed Pattern',
                    style: PoswalText.caption.copyWith(
                      color: PoswalColors.coral,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.sm),
          Text(
            corr.insightText,
            style: PoswalText.callout.copyWith(color: textPrimary, height: 1.4),
          ),
          if (!corr.hasEnoughData) ...[
            const SizedBox(height: PoswalSpacing.xs),
            Text(
              'We never jump to conclusions on limited data. Keep tracking to reveal true correlations.',
              style: PoswalText.caption.copyWith(color: textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallHeatmapCard(
    BuildContext context,
    InsightsState state,
    AppLocalizations? l10n,
    Color textPrimary,
    Color textMuted,
  ) {
    const boundary = DateBoundary(dayStartHour: 4);
    final today = boundary.getAppDate(DateTime.now());

    // Build last 8 weeks (56 days) grid
    const weeksCount = 8;
    final int daysSinceMonday = today.weekday - 1;
    final DateTime currentWeekSunday = today.add(Duration(days: 6 - daysSinceMonday));
    const totalDays = weeksCount * 7;
    final DateTime gridStart = currentWeekSunday.subtract(const Duration(days: totalDays - 1));

    final List<List<DateTime>> columns = [];
    DateTime cursor = gridStart;
    for (int w = 0; w < weeksCount; w++) {
      final List<DateTime> week = [];
      for (int d = 0; d < 7; d++) {
        week.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
      columns.add(week);
    }

    return AppGlassCard(
      key: const ValueKey('insights_overall_heatmap_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Overall Activity Heatmap',
                  style: PoswalText.headline.copyWith(color: textPrimary),
                ),
              ),
              const SizedBox(width: PoswalSpacing.xs),
              Text(
                'Last 8 Weeks',
                style: PoswalText.caption.copyWith(color: textMuted),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: columns.map((week) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Column(
                    children: week.map((day) {
                      final dayStr = DateBoundary.toDateString(day);
                      final count = state.dailyOverallCompletions[dayStr] ?? 0;
                      final isFuture = day.isAfter(today);

                      Color cellColor;
                      if (isFuture) {
                        cellColor = Colors.transparent;
                      } else if (count == 0) {
                        cellColor = Colors.white.withValues(alpha: 0.05);
                      } else if (count == 1) {
                        cellColor = PoswalColors.teal.withValues(alpha: 0.35);
                      } else if (count == 2) {
                        cellColor = PoswalColors.teal.withValues(alpha: 0.65);
                      } else {
                        cellColor = PoswalColors.teal;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(3),
                          border: isFuture
                              ? null
                              : Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  width: 0.5,
                                ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: PoswalSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: PoswalText.caption.copyWith(color: textMuted, fontSize: 10)),
              const SizedBox(width: PoswalSpacing.xs),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 2),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: PoswalColors.teal.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 2),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: PoswalColors.teal.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 2),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: PoswalColors.teal, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: PoswalSpacing.xs),
              Text('More', style: PoswalText.caption.copyWith(color: textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
