import 'package:flutter/material.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/poswal_orbit_ring.dart';

class HeroOrbitCard extends StatelessWidget {
  final int totalDue;
  final int totalDone;
  final double completionRate;

  const HeroOrbitCard({
    super.key,
    required this.totalDue,
    required this.totalDone,
    required this.completionRate,
  });

  String _getEncouragingPhrase() {
    if (totalDue == 0) {
      return 'No habits scheduled for today. Rest and recharge.';
    }
    if (completionRate >= 1.0) {
      return '“All orbits complete today. Beautiful rhythm.”';
    }
    if (completionRate >= 0.5) {
      return '“More than halfway in orbit. Keep the rhythm calm.”';
    }
    if (totalDone > 0) {
      return '“Good start. Keep the momentum steady.”';
    }
    return '“Your day is waiting. Take the first calm step.”';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    return AppGlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today in Orbit',
                style: PoswalText.headline.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (totalDue > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: PoswalColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(PoswalRadii.pill),
                  ),
                  child: Text(
                    '${(completionRate * 100).round()}%',
                    style: PoswalText.caption.copyWith(
                      color: PoswalColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.lg),
          PoswalOrbitRing(
            progress: completionRate,
            size: 180,
            strokeWidth: 14,
            centerChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  totalDue == 0 ? '0 of 0' : '$totalDone of $totalDue',
                  style: PoswalText.largeTitle.copyWith(
                    color: textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  completionRate >= 1.0 && totalDue > 0 ? 'All done!' : 'In orbit',
                  style: PoswalText.caption.copyWith(
                    color: completionRate >= 1.0 && totalDue > 0 ? PoswalColors.teal : textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PoswalSpacing.md),
          Text(
            _getEncouragingPhrase(),
            textAlign: TextAlign.center,
            style: PoswalText.callout.copyWith(
              color: textMuted,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
