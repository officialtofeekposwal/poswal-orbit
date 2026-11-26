import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/poswal_orbit_ring.dart';
import 'package:poswal_orbit/features/insights/application/insights_providers.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class InsightsHeroCard extends StatelessWidget {
  final InsightsState state;
  final bool reduceMotion;

  const InsightsHeroCard({
    super.key,
    required this.state,
    this.reduceMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final l10n = AppLocalizations.of(context);

    final score = state.productivityScore;
    final weekly = state.weeklyReview;

    final accent = isDark ? PoswalColors.teal : PoswalColors.tealLight;
    final successColor = isDark ? PoswalColors.success : PoswalColors.successLight;
    final warningColor = isDark ? PoswalColors.warning : PoswalColors.warningLight;

    Color gradeColor;
    if (score.score >= 85) {
      gradeColor = accent;
    } else if (score.score >= 65) {
      gradeColor = successColor;
    } else if (score.score >= 40) {
      gradeColor = warningColor;
    } else {
      gradeColor = textMuted;
    }

    final cardBg = isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight;

    return Container(
      padding: const EdgeInsetsDirectional.all(PoswalSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(PoswalRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Productivity Score Header & Ring
          Container(
            key: const ValueKey('insights_productivity_score_card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.chartLineUp, color: accent, size: 20),
                        const SizedBox(width: PoswalSpacing.sm),
                        Text(
                          l10n?.productivityScore ?? 'Productivity Score',
                          style: PoswalText.headline.copyWith(color: textPrimary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: gradeColor.withValues(alpha: isDark ? 0.15 : 0.12),
                        borderRadius: BorderRadius.circular(PoswalRadii.pill),
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
                  children: [
                    PoswalOrbitRing(
                      progress: (score.score / 100).clamp(0.0, 1.0),
                      size: 96.0,
                      strokeWidth: 8.0,
                      animateOnStart: !reduceMotion,
                      centerChild: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${score.score.toInt()}',
                            style: PoswalText.title.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '/ 100',
                            style: PoswalText.micro.copyWith(color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: PoswalSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(PoswalRadii.pill),
                                ),
                              ),
                              const SizedBox(width: PoswalSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Habits: ${score.habitConsistency.toInt()}%',
                                  style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: PoswalSpacing.xs),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: textMuted,
                                  borderRadius: BorderRadius.circular(PoswalRadii.pill),
                                ),
                              ),
                              const SizedBox(width: PoswalSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Tasks: ${score.taskCompletionRate.toInt()}%',
                                  style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: PoswalSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(PoswalRadii.pill),
                            child: LinearProgressIndicator(
                              value: (score.score / 100).clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: textMuted.withValues(alpha: 0.14),
                              valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: PoswalSpacing.lg),

          // 2. Weekly Review Non-guilt Message & Stat Chips
          Container(
            key: const ValueKey('insights_weekly_review_card'),
            padding: const EdgeInsetsDirectional.all(PoswalSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight2,
              borderRadius: BorderRadius.circular(PoswalRadii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIconsRegular.calendarCheck, color: accent, size: 20),
                    const SizedBox(width: PoswalSpacing.xs),
                    Text(
                      l10n?.weeklyReviewTitle ?? 'Weekly review',
                      style: PoswalText.caption.copyWith(
                        color: textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PoswalSpacing.xs),
                Text(
                  '"${weekly.encouragingMessage}"',
                  style: PoswalText.callout.copyWith(
                    color: textPrimary,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: PoswalSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        value: '${weekly.habitsCompleted}',
                        label: l10n?.habitsDoneCount ?? 'Habits Done',
                        color: accent,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: PoswalSpacing.xs),
                    Expanded(
                      child: _buildStatChip(
                        value: '${weekly.bestStreak}d',
                        label: l10n?.bestStreakCount ?? 'Best Streak',
                        color: accent,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String value,
    required String label,
    required Color color,
    required Color textMuted,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(vertical: PoswalSpacing.sm, horizontal: PoswalSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(PoswalRadii.button),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: PoswalText.headline.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: PoswalText.micro.copyWith(color: textMuted),
          ),
        ],
      ),
    );
  }
}
