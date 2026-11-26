import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';

/// Floating-chrome Liquid Glass surface.
///
/// Uses a single [BackdropFilter] (sigma 24) with saturation boost, gradient rim,
/// inner highlight, soft shadow, and [RepaintBoundary] isolation.
/// Falls back to a solid elevated surface when `reduceTransparency` or OLED mode
/// is active.
class LiquidGlass extends ConsumerStatefulWidget {
  static const double blurSigma = 24.0;
  static const double saturation = 1.35;
  static const double darkTintOpacity = 0.72;
  static const double lightTintOpacity = 0.78;

  /// Effective composited glass background in dark mode (over [PoswalColors.ink]).
  static Color effectiveDarkSurface() => Color.alphaBlend(
        PoswalColors.surfaceDark.withValues(alpha: darkTintOpacity),
        PoswalColors.ink,
      );

  /// Effective composited glass background in light mode (over [PoswalColors.mist]).
  static Color effectiveLightSurface() => Color.alphaBlend(
        PoswalColors.surfaceLight.withValues(alpha: lightTintOpacity),
        PoswalColors.mist,
      );

  final Widget child;
  final bool isCapsule;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? tintColor;
  final bool? reduceTransparencyOverride;

  const LiquidGlass({
    super.key,
    required this.child,
    this.isCapsule = false,
    this.borderRadius = PoswalRadii.card,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.tintColor,
    this.reduceTransparencyOverride,
  });

  @override
  ConsumerState<LiquidGlass> createState() => _LiquidGlassState();
}

class _LiquidGlassState extends ConsumerState<LiquidGlass> {
  bool _isPressed = false;

  static List<double> _saturationMatrix(double sat) {
    const lumR = 0.2126;
    const lumG = 0.7152;
    const lumB = 0.0722;
    final inv = 1.0 - sat;
    final r = lumR * inv;
    final g = lumG * inv;
    final b = lumB * inv;
    return <double>[
      r + sat, g, b, 0, 0,
      r, g + sat, b, 0, 0,
      r, g, b + sat, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  ShapeBorder _buildShape() {
    if (widget.isCapsule) {
      return const StadiumBorder();
    }
    return ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius * 1.4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appThemeModeProvider);
    final providerReduceTransparency = ref.watch(reduceTransparencyProvider);
    final reduceTransparency =
        widget.reduceTransparencyOverride ?? providerReduceTransparency;
    final reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final isDark = mode.isDark;
    final shape = _buildShape();

    final Color surfaceTint = widget.tintColor ??
        (isDark
            ? (mode.isOled
                ? const Color(0xFF121214)
                : PoswalColors.surfaceDark)
            : PoswalColors.surfaceLight);

    final bool useBlur = !reduceTransparency && !mode.isOled;

    final Color fillColor = useBlur
        ? surfaceTint.withValues(
            alpha: isDark
                ? LiquidGlass.darkTintOpacity
                : LiquidGlass.lightTintOpacity,
          )
        : (isDark
            ? (mode.isOled
                ? const Color(0xFF121214)
                : PoswalColors.surfaceDark2)
            : PoswalColors.surfaceLight);

    Widget content = Container(
      width: widget.width,
      height: widget.height,
      decoration: ShapeDecoration(
        color: fillColor,
        shape: shape,
      ),
      child: DecoratedBox(
        decoration: useBlur
            ? ShapeDecoration(
                shape: shape,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.10 : 0.45),
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: isDark ? 0.03 : 0.12),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              )
            : ShapeDecoration(shape: shape),
        child: Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: Material(
            type: MaterialType.transparency,
            child: widget.child,
          ),
        ),
      ),
    );

    if (useBlur) {
      content = ClipPath.shape(
        shape: shape,
        child: BackdropFilter(
          filter: ImageFilter.compose(
            outer: ImageFilter.blur(
              sigmaX: LiquidGlass.blurSigma,
              sigmaY: LiquidGlass.blurSigma,
            ),
            inner: ColorFilter.matrix(_saturationMatrix(LiquidGlass.saturation)),
          ),
          child: CustomPaint(
            foregroundPainter: _GradientRimPainter(
              shape: shape,
              isDark: isDark,
            ),
            child: content,
          ),
        ),
      );
    } else {
      content = ClipPath.shape(
        shape: shape,
        child: CustomPaint(
          foregroundPainter: _SolidRimPainter(
            shape: shape,
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: isDark ? 0.12 : 0.08),
          ),
          child: content,
        ),
      );
    }

    content = DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: content,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTapDown: reduceMotion
            ? null
            : (_) => setState(() => _isPressed = true),
        onTapUp: reduceMotion
            ? null
            : (_) => setState(() => _isPressed = false),
        onTapCancel: reduceMotion
            ? null
            : () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap!();
        },
        child: AnimatedScale(
          scale: (!reduceMotion && _isPressed) ? PoswalMotion.pressScale : 1.0,
          duration: reduceMotion ? Duration.zero : PoswalDurations.micro,
          curve: PoswalCurves.easeOut,
          child: content,
        ),
      );
    }

    return RepaintBoundary(child: content);
  }
}

class _GradientRimPainter extends CustomPainter {
  final ShapeBorder shape;
  final bool isDark;

  const _GradientRimPainter({
    required this.shape,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.24 : 0.85),
          Colors.white.withValues(alpha: isDark ? 0.08 : 0.35),
          Colors.white.withValues(alpha: isDark ? 0.05 : 0.20),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientRimPainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.isDark != isDark;
  }
}

class _SolidRimPainter extends CustomPainter {
  final ShapeBorder shape;
  final Color color;

  const _SolidRimPainter({
    required this.shape,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SolidRimPainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.color != color;
  }
}
