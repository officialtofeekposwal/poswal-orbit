import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';

class ReduceTransparencyNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setReduce(bool value) => state = value;
}

final reduceTransparencyProvider = NotifierProvider<ReduceTransparencyNotifier, bool>(ReduceTransparencyNotifier.new);

class GlassIntensityNotifier extends Notifier<double> {
  @override
  double build() => 1.0;
  void setIntensity(double value) => state = value;
}

final glassIntensityProvider = NotifierProvider<GlassIntensityNotifier, double>(GlassIntensityNotifier.new);

class AppGlassCard extends ConsumerWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? tintColor;
  final double? width;
  final double? height;

  const AppGlassCard({
    super.key,
    required this.child,
    this.borderRadius = PoswalRadii.card,
    this.padding = const EdgeInsets.all(PoswalSpacing.lg),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.tintColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final intensity = ref.watch(glassIntensityProvider);

    final isDark = mode.isDark;
    final baseTint = tintColor ?? (isDark ? Colors.white : Colors.white);
    final tintOpacity = (isDark ? PoswalGlass.darkTintOpacity : PoswalGlass.lightTintOpacity) * intensity;
    final borderOpacity = isDark ? PoswalGlass.darkBorderOpacity : PoswalGlass.lightBorderOpacity;
    final highlightOpacity = isDark ? PoswalGlass.darkHighlightOpacity : PoswalGlass.lightHighlightOpacity;

    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: baseTint.withValues(alpha: tintOpacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.white).withValues(alpha: borderOpacity),
          width: PoswalGlass.borderWidth,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: highlightOpacity * 0.4),
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: highlightOpacity * 0.1),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );

    if (!reduceTransparency && !mode.isOled) {
      final sigma = (16.0 * intensity).toDouble();
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: cardContent,
        ),
      );
    } else {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          color: isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight,
          child: cardContent,
        ),
      );
    }

    if (margin != null) {
      cardContent = Padding(padding: margin!, child: cardContent);
    }

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress?.call();
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class AppGlassButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AppGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isPrimary = false,
    this.borderRadius = PoswalRadii.button,
    this.padding = const EdgeInsets.symmetric(
      horizontal: PoswalSpacing.xl,
      vertical: PoswalSpacing.md,
    ),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final isDark = mode.isDark;

    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: PoswalGradients.aurora,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: PoswalColors.teal.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onPressed == null
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  },
            child: Padding(
              padding: padding,
              child: Center(
                widthFactor: 1.0,
                child: DefaultTextStyle(
                  style: PoswalText.headline.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AppGlassCard(
      borderRadius: borderRadius,
      padding: padding,
      onTap: onPressed,
      child: Center(
        widthFactor: 1.0,
        child: DefaultTextStyle(
          style: PoswalText.headline.copyWith(
            color: isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight,
            fontWeight: FontWeight.w600,
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppGlassChip extends ConsumerWidget {
  final String label;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? activeColor;

  const AppGlassChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final isDark = mode.isDark;
    final color = activeColor ?? PoswalColors.teal;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: PoswalSpacing.md,
          vertical: PoswalSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.28 : 0.18)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.50)),
          borderRadius: BorderRadius.circular(PoswalRadii.chip),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: PoswalSpacing.xs),
            ],
            Text(
              label,
              style: PoswalText.caption.copyWith(
                color: isSelected
                    ? (isDark ? Colors.white : color)
                    : (isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppGlassSegmentedControl<T> extends ConsumerWidget {
  final List<T> values;
  final List<String> labels;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;

  const AppGlassSegmentedControl({
    super.key,
    required this.values,
    required this.labels,
    required this.selectedValue,
    required this.onValueChanged,
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final isDark = mode.isDark;

    return Container(
      padding: const EdgeInsets.all(PoswalSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(PoswalRadii.pill),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.60),
        ),
      ),
      child: Row(
        children: List.generate(values.length, (index) {
          final isSelected = values[index] == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onValueChanged(values[index]);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  vertical: PoswalSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(PoswalRadii.pill),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PoswalText.callout.copyWith(
                    color: isSelected
                        ? (isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight)
                        : (isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
