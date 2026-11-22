import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';

class PoswalOrbitRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Widget? centerChild;
  final bool animateOnStart;

  const PoswalOrbitRing({
    super.key,
    required this.progress,
    this.size = 180.0,
    this.strokeWidth = 14.0,
    this.centerChild,
    this.animateOnStart = true,
  });

  @override
  State<PoswalOrbitRing> createState() => _PoswalOrbitRingState();
}

class _PoswalOrbitRingState extends State<PoswalOrbitRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PoswalDurations.slow,
    );
    _animation = Tween<double>(
      begin: widget.animateOnStart ? 0.0 : widget.progress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PoswalCurves.easeOut,
    ));

    if (widget.animateOnStart) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant PoswalOrbitRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: PoswalCurves.easeOut,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _OrbitRingPainter(
              progress: _animation.value.clamp(0.0, 1.0),
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(child: widget.centerChild),
          );
        },
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  const _OrbitRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Background Groove
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.001) return;

    // 2. Active Aurora Stroke
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final ringPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        colors: [
          PoswalColors.teal,
          PoswalColors.violet,
          PoswalColors.coral,
          PoswalColors.teal,
        ],
        stops: [0.0, 0.45, 0.85, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      ringPaint,
    );

    // 3. Glowing Orbit Dot at progress tip
    final currentAngle = startAngle + sweepAngle;
    final dotX = center.dx + radius * math.cos(currentAngle);
    final dotY = center.dy + radius * math.sin(currentAngle);
    final dotCenter = Offset(dotX, dotY);

    // Outer glow
    final glowPaint = Paint()
      ..color = PoswalColors.gold.withValues(alpha: 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(dotCenter, strokeWidth * 0.9, glowPaint);

    // Solid core dot
    final dotPaint = Paint()
      ..color = PoswalColors.gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, strokeWidth * 0.55, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth;
  }
}
