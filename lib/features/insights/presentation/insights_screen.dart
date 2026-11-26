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
import 'package:poswal_orbit/core/widgets/app_toolbar.dart';
import 'package:poswal_orbit/core/widgets/app_background.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/features/insights/application/insights_providers.dart';
import 'package:poswal_orbit/features/insights/presentation/widgets/habit_insight_row.dart';
import 'package:poswal_orbit/features/insights/presentation/widgets/insights_hero_card.dart';
import 'package:poswal_orbit/features/insights/presentation/widgets/insights_segmented_tabs.dart';
import 'package:poswal_orbit/features/insights/presentation/widgets/overall_activity_heatmap_card.dart';
import 'package:poswal_orbit/features/insights/presentation/widgets/weekday_bars.dart';
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
  int _selectedTabIndex = 0; // 0: Overview, 1: Habits, 2: Timing

  Future<void> _shareStatsCard(BuildContext context) async {
    if (_isSharing) return;
    final l10n = context.mounted ? AppLocalizations.of(context) : null;
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
          text: l10n?.shareWeeklyRhythm ?? 'My weekly rhythm on Poswal Orbit',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.shareFailed(e.toString()) ?? 'Failed to share: $e',
              style: PoswalText.callout.copyWith(color: PoswalColors.surfaceLight),
            ),
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
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final l10n = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final insightsAsync = ref.watch(insightsDataProvider);

    const boundary = DateBoundary(dayStartHour: 4);
    final today = boundary.getAppDate(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Navigation / Control Layer: AppToolbar
              SliverToBoxAdapter(
                child: AppToolbar(
                  title: Text(
                    l10n?.insightsTitle ?? 'Insights',
                    style: PoswalText.largeTitle.copyWith(color: textPrimary),
                  ),
                  actions: [
                    insightsAsync.maybeWhen(
                      data: (state) => state.hasAnyData
                          ? AppGlassButton(
                              key: const ValueKey('share_insights_button'),
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: PoswalSpacing.md,
                                vertical: PoswalSpacing.xs,
                              ),
                              onPressed: () => _shareStatsCard(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isSharing)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: PoswalColors.teal,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      PhosphorIconsRegular.shareNetwork,
                                      size: 16,
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
                      child: _buildEmptyState(
                        context: context,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        l10n: l10n,
                      ),
                    );
                  }

                  return SliverMainAxisGroup(
                    slivers: [
                      // --- Hero Card (inside RepaintBoundary for share) ---
                      SliverPadding(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.lg),
                        sliver: SliverToBoxAdapter(
                          child: RepaintBoundary(
                            key: _shareBoundaryKey,
                            child: InsightsHeroCard(
                              state: state,
                              reduceMotion: reduceMotion,
                            ),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: PoswalSpacing.md)),

                      // --- Segmented Control (Overview | Habits | Timing) ---
                      SliverPadding(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.lg),
                        sliver: SliverToBoxAdapter(
                          child: InsightsSegmentedTabs(
                            selectedIndex: _selectedTabIndex,
                            onTabSelected: (idx) => setState(() => _selectedTabIndex = idx),
                            reduceMotion: reduceMotion,
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: PoswalSpacing.md)),

                      // --- Tab 0: Overview ---
                      if (_selectedTabIndex == 0) ...[
                        SliverPadding(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.lg),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                OverallActivityHeatmapCard(
                                  dailyOverallCompletions: state.dailyOverallCompletions,
                                ),
                                const SizedBox(height: PoswalSpacing.md),
                                _buildCorrelationCard(context, state, l10n, textPrimary, textMuted),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // --- Tab 1: Habits (Lazy SliverList.builder) ---
                      if (_selectedTabIndex == 1) ...[
                        if (state.habits.isNotEmpty) ...[
                          SliverPadding(
                            padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.lg),
                            sliver: SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(bottom: PoswalSpacing.sm),
                                child: Text(
                                  l10n?.habitHeatmaps ?? 'Habit Heatmaps',
                                  style: PoswalText.headline.copyWith(color: textPrimary),
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.lg),
                            sliver: SliverList.builder(
                              itemCount: state.habits.length,
                              itemBuilder: (context, index) {
                                final habit = state.habits[index];
                                final habitEntries = state.entries.where((e) => e.habitId == habit.id).toList();
                                return HabitInsightRow(
                                  key: ValueKey('habit_row_${habit.id}'),
                                  habit: habit,
                                  entries: habitEntries,
                                  referenceDate: today,
                                  reduceMotion: reduceMotion,
                                );
                              },
                            ),
                          ),
                        ],
                      ],

                      // --- Tab 2: Timing ---
                      if (_selectedTabIndex == 2) ...[
                        SliverPadding(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.lg),
                          sliver: SliverToBoxAdapter(
                            child: _buildBestTimingCard(context, state, l10n, textPrimary, textMuted, reduceMotion),
                          ),
                        ),
                      ],

                      // Bottom spacing for navigation bar
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required bool isDark,
    required Color textPrimary,
    required Color textMuted,
    required AppLocalizations? l10n,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(PoswalSpacing.xl),
        child: _buildContentCard(
          key: const ValueKey('insights_empty_state_card'),
          isDark: isDark,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsRegular.chartLineUp,
                color: isDark ? PoswalColors.teal : PoswalColors.tealLight,
                size: 24,
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
              const SizedBox(height: PoswalSpacing.lg),
              AppGlassButton(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: PoswalSpacing.lg,
                  vertical: PoswalSpacing.sm,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedTabIndex = 1);
                },
                child: Text(
                  l10n?.insightsEmptyAction ?? 'Explore habits',
                  style: PoswalText.callout.copyWith(
                    color: PoswalColors.teal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBestTimingCard(
    BuildContext context,
    InsightsState state,
    AppLocalizations? l10n,
    Color textPrimary,
    Color textMuted,
    bool reduceMotion,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timing = state.bestTiming;

    return _buildContentCard(
      key: const ValueKey('insights_best_timing_card'),
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.clock, color: PoswalColors.teal, size: 20),
              const SizedBox(width: PoswalSpacing.xs),
              Text(
                l10n?.peakMomentum ?? 'Peak Momentum',
                style: PoswalText.headline.copyWith(color: textPrimary),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.all(PoswalSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight2,
                    borderRadius: BorderRadius.circular(PoswalRadii.card),
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
                          color: isDark ? PoswalColors.teal : PoswalColors.tealLight,
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
                  padding: const EdgeInsetsDirectional.all(PoswalSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight2,
                    borderRadius: BorderRadius.circular(PoswalRadii.card),
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
                          color: isDark ? PoswalColors.teal : PoswalColors.tealLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.lg),
          WeekdayBars(
            dailyOverallCompletions: state.dailyOverallCompletions,
            bestTiming: state.bestTiming,
            reduceMotion: reduceMotion,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corr = state.correlation;

    return _buildContentCard(
      key: const ValueKey('insights_correlation_card'),
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.intersect,
                    color: isDark ? PoswalColors.teal : PoswalColors.tealLight,
                    size: 20,
                  ),
                  const SizedBox(width: PoswalSpacing.xs),
                  Text(
                    l10n?.habitTaskCorrelation ?? 'Habit & Task Correlation',
                    style: PoswalText.headline.copyWith(color: textPrimary),
                  ),
                ],
              ),
              if (corr.hasEnoughData)
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.xs, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isDark ? PoswalColors.teal : PoswalColors.tealLight).withValues(alpha: isDark ? 0.15 : 0.12),
                    borderRadius: BorderRadius.circular(PoswalRadii.pill),
                  ),
                  child: Text(
                    l10n?.observedPattern ?? 'Observed Pattern',
                    style: PoswalText.caption.copyWith(
                      color: isDark ? PoswalColors.teal : PoswalColors.tealLight,
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
              l10n?.correlationDisclaimer ??
                  'We never jump to conclusions on limited data. Keep tracking to reveal true correlations.',
              style: PoswalText.caption.copyWith(color: textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentCard({
    Key? key,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsetsDirectional.all(PoswalSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight,
        borderRadius: BorderRadius.circular(PoswalRadii.card),
      ),
      child: child,
    );
  }
}
