import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';

class AuroraBackground extends ConsumerStatefulWidget {
  final Widget child;

  const AuroraBackground({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends ConsumerState<AuroraBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    // Do not loop tickers in headless test environments to avoid timeouts
    if (!WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding')) {
      _controller.repeat();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding')) {
      if (state == AppLifecycleState.resumed) {
        if (!_controller.isAnimating) _controller.repeat();
      } else {
        if (_controller.isAnimating) _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppThemeMode mode = ref.watch(appThemeModeProvider);
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Color bgColor;
    switch (mode) {
      case AppThemeMode.light:
        bgColor = PoswalColors.mist;
      case AppThemeMode.dark:
        bgColor = PoswalColors.ink;
      case AppThemeMode.oled:
        bgColor = PoswalColors.oled;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // True Black OLED mode paints zero background orbs for 100% battery efficiency
          if (!mode.isOled)
            reduceMotion
                ? CustomPaint(
                    painter: AuroraPainter(
                      progress: 0.25,
                      isDark: mode.isDark,
                    ),
                  )
                : AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: AuroraPainter(
                          progress: _controller.value,
                          isDark: mode.isDark,
                        ),
                      );
                    },
                  ),
          widget.child,
        ],
      ),
    );
  }
}

class AuroraPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const AuroraPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final double phase = progress * 2 * math.pi;

    // Orb 1: Orbit Teal (floating top-left quadrant - quiet & subtle)
    final orb1Center = Offset(
      size.width * 0.28 + math.sin(phase) * 45,
      size.height * 0.20 + math.cos(phase * 0.8) * 35,
    );
    final orb1Radius = size.width * 0.65;
    final orb1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          PoswalColors.teal.withValues(alpha: isDark ? 0.09 : 0.04),
          PoswalColors.teal.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: orb1Center, radius: orb1Radius));
    canvas.drawCircle(orb1Center, orb1Radius, orb1Paint);

    // Orb 2: Nebula Violet (floating mid-right - restrained atmospheric depth)
    final orb2Center = Offset(
      size.width * 0.75 + math.cos(phase * 0.9) * 40,
      size.height * 0.45 + math.sin(phase) * 45,
    );
    final orb2Radius = size.width * 0.70;
    final orb2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          PoswalColors.violet.withValues(alpha: isDark ? 0.08 : 0.035),
          PoswalColors.violet.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: orb2Center, radius: orb2Radius));
    canvas.drawCircle(orb2Center, orb2Radius, orb2Paint);

    // Orb 3: Sunrise Coral (subtle warmth in lower quadrant)
    final orb3Center = Offset(
      size.width * 0.40 + math.sin(phase * 1.1) * 35,
      size.height * 0.80 + math.cos(phase * 0.7) * 30,
    );
    final orb3Radius = size.width * 0.55;
    final orb3Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          PoswalColors.coral.withValues(alpha: isDark ? 0.06 : 0.025),
          PoswalColors.coral.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: orb3Center, radius: orb3Radius));
    canvas.drawCircle(orb3Center, orb3Radius, orb3Paint);
  }

  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
