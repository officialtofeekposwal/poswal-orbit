import 'package:flutter/material.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';

class HabitWeeklyBars extends StatelessWidget {
  final Habit habit;
  final Map<int, int> weekdayCompletions; // 1 (Mon) -> 7 (Sun)

  const HabitWeeklyBars({
    super.key,
    required this.habit,
    required this.weekdayCompletions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final habitColor = Color(habit.colorValue);

    final int maxVal = weekdayCompletions.values.fold(0, (prev, curr) => curr > prev ? curr : prev);
    final effectiveMax = maxVal == 0 ? 1 : maxVal;

    final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY PERFORMANCE',
                style: PoswalText.caption.copyWith(
                  color: textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'By Day of Week',
                style: PoswalText.caption.copyWith(color: textMuted),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.lg),

          // Bars Row
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 1; i <= 7; i++) ...[
                  _buildBarColumn(
                    dayLabel: dayNames[i - 1],
                    count: weekdayCompletions[i] ?? 0,
                    max: effectiveMax,
                    habitColor: habitColor,
                    textMuted: textMuted,
                    textPrimary: textPrimary,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn({
    required String dayLabel,
    required int count,
    required int max,
    required Color habitColor,
    required Color textMuted,
    required Color textPrimary,
    required bool isDark,
  }) {
    final double ratio = (count / max).clamp(0.08, 1.0);
    final double barHeight = ratio * 80;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (count > 0)
          Text(
            count.toString(),
            style: PoswalText.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          )
        else
          const SizedBox(height: 14),
        const SizedBox(height: 4),

        // Bar container
        Container(
          width: 22,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                count > 0 ? habitColor : (isDark ? Colors.white10 : Colors.black12),
                count > 0 ? habitColor.withValues(alpha: 0.70) : (isDark ? Colors.white10 : Colors.black12),
              ],
            ),
            boxShadow: count > 0
                ? [
                    BoxShadow(
                      color: habitColor.withValues(alpha: 0.30),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: PoswalSpacing.xs),

        // Day label
        Text(
          dayLabel,
          style: PoswalText.caption.copyWith(
            fontSize: 11,
            color: count > 0 ? textPrimary : textMuted,
            fontWeight: count > 0 ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class HabitTrendLine extends StatelessWidget {
  final Habit habit;
  final List<HabitEntry> entries;

  const HabitTrendLine({
    super.key,
    required this.habit,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final habitColor = Color(habit.colorValue);

    // Calculate rolling 30-day completion rate trend points
    final now = DateTime.now();
    final List<double> points = [];
    final Map<String, HabitEntry> map = {for (final e in entries) e.entryDate: e};

    int runningDone = 0;
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      if (map[key]?.isDone ?? false) {
        runningDone++;
      }
      final double trendVal = (runningDone / (30 - i)).clamp(0.0, 1.0);
      points.add(trendVal);
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '30-DAY CONSISTENCY TREND',
                style: PoswalText.caption.copyWith(
                  color: textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${(points.last * 100).toInt()}% Current',
                style: PoswalText.caption.copyWith(
                  color: PoswalColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.md),

          // Custom Painted Trend Curve
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendLinePainter(
                points: points,
                lineColor: habitColor,
                fillColor: habitColor.withValues(alpha: 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color fillColor;

  _TrendLinePainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    final double stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y = size.height - (points[i] * (size.height - 16)) - 8;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final double prevX = (i - 1) * stepX;
        final double prevY = size.height - (points[i - 1] * (size.height - 16)) - 8;
        final double midX = (prevX + x) / 2;

        path.cubicTo(midX, prevY, midX, y, x, y);
        fillPath.cubicTo(midX, prevY, midX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Paint fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Paint line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Draw last point dot
    final lastX = size.width;
    final lastY = size.height - (points.last * (size.height - 16)) - 8;
    canvas.drawCircle(Offset(lastX, lastY), 4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(lastX, lastY), 2.5, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
