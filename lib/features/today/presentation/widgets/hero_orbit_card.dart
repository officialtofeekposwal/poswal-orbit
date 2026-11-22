import 'package:flutter/material.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
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

    final cardBg = isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.all(PoswalSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(PoswalRadii.card),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Today in Orbit',
                  style: PoswalText.headline.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (totalDue > 0) ...[
                const SizedBox(width: PoswalSpacing.xs),
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
            ],
          ),
          const SizedBox(height: PoswalSpacing.lg),
          PoswalOrbitRing(
            progress: completionRate,
            size: 180,
            strokeWidth: 14,
            centerChild: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
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
