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

final reduceTransparencyProvider =
    NotifierProvider<ReduceTransparencyNotifier, bool>(ReduceTransparencyNotifier.new);

class GlassIntensityNotifier extends Notifier<double> {
  @override
  double build() => 1.0;
  void setIntensity(double value) => state = value;
}

final glassIntensityProvider =
    NotifierProvider<GlassIntensityNotifier, double>(GlassIntensityNotifier.new);

/// Core HIG Liquid Glass Container for Floating Controls & Toolbars
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
  final GlassTier tier;

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
    this.tier = GlassTier.standard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final intensity = ref.watch(glassIntensityProvider);

    final isDark = mode.isDark;
    final effectiveTier = reduceTransparency ? GlassTier.plain : tier;

    final baseTint = tintColor ?? (isDark ? Colors.white : Colors.white);
    final tintOpacity = PoswalGlass.tintOpacity(effectiveTier, isDark: isDark) * intensity;
    final borderOpacity = PoswalGlass.borderOpacity(effectiveTier, isDark: isDark);
    final highlightOpacity = isDark ? PoswalGlass.darkHighlightOpacity : PoswalGlass.lightHighlightOpacity;

    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: baseTint.withValues(alpha: tintOpacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: borderOpacity),
          width: PoswalGlass.borderWidth,
        ),
        gradient: effectiveTier == GlassTier.plain
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: highlightOpacity * 0.35),
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: highlightOpacity * 0.08),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );

    if (!reduceTransparency && !mode.isOled && effectiveTier != GlassTier.plain) {
      final sigma = PoswalGlass.blurSigma(effectiveTier) * intensity;
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

/// HIG Large Action Button (Capsule Shape)
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
    this.borderRadius = PoswalRadii.capsule,
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
        height: PoswalRowHeights.standard,
        decoration: BoxDecoration(
          color: PoswalColors.teal,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
              blurRadius: 12,
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

/// HIG Glass Filter Chip
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

/// HIG Segmented Control with spring sliding capsule
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
      padding: const EdgeInsets.all(PoswalSpacing.xxs),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(PoswalRadii.capsule),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.10 : 0.06),
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
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  vertical: PoswalSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(PoswalRadii.capsule),
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

/// Tactile Slider with spring glass knob feedback on touch
class AppTactileSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;

  const AppTactileSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
  });

  @override
  State<AppTactileSlider> createState() => _AppTactileSliderState();
}

class _AppTactileSliderState extends State<AppTactileSlider> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 6.0,
        activeTrackColor: PoswalColors.teal,
        inactiveTrackColor: Colors.white12,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: _isDragging ? 12.0 : 9.0,
          elevation: _isDragging ? 6.0 : 2.0,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 22.0),
      ),
      child: Slider(
        value: widget.value,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        onChangeStart: (_) {
          HapticFeedback.lightImpact();
          setState(() => _isDragging = true);
        },
        onChangeEnd: (_) {
          HapticFeedback.selectionClick();
          setState(() => _isDragging = false);
        },
        onChanged: widget.onChanged,
      ),
    );
  }
}
