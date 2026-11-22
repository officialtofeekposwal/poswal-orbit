import 'package:flutter/material.dart';

/// Poswal Orbit Core Color Tokens
/// Includes standard, dark, light, and increased-contrast variants.
abstract final class PoswalColors {
  // Brand Identity Accents
  static const teal = Color(0xFF14B8A6);
  static const tealHover = Color(0xFF0D9488);
  static const violet = Color(0xFF8B7CFF);
  static const coral = Color(0xFFFF7A59);
  static const gold = Color(0xFFFFC857);

  // Background Surfaces
  static const ink = Color(0xFF070B14);
  static const oled = Color(0xFF000000);
  static const mist = Color(0xFFF4F6FB);

  // Semantic Status
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);

  // Surface Tiers
  static const surfaceDark = Color(0xFF0F1626);
  static const surfaceDark2 = Color(0xFF151D30);
  static const surfaceDark3 = Color(0xFF1C263D);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceLight2 = Color(0xFFF8FAFC);
  static const surfaceLight3 = Color(0xFFEDF2F7);

  // Text Hierarchies
  static const textOnDark = Color(0xFFF5F7FF);
  static const textMutedDark = Color(0xFFA3AEC7);
  static const textSecondaryDark = Color(0xFF6B7280);
  static const textOnLight = Color(0xFF0B1020);
  static const textMutedLight = Color(0xFF5B667F);
  static const textSecondaryLight = Color(0xFF94A3B8);

  // Increased-Contrast Variants (WCAG AAA)
  static const textHighContrastDark = Color(0xFFFFFFFF);
  static const textHighContrastLight = Color(0xFF000000);
  static const textMutedHighContrastDark = Color(0xFFCBD5E1);
  static const textMutedHighContrastLight = Color(0xFF334155);
  static const tealHighContrast = Color(0xFF0D9488);
  static const borderHighContrastDark = Color(0x7FFFFFFF);
  static const borderHighContrastLight = Color(0x66000000);

  // Discrete Habit Color Palette
  static const habitPalette = <Color>[
    Color(0xFF14B8A6),
    Color(0xFF3B82F6),
    Color(0xFF8B7CFF),
    Color(0xFFEC4899),
    Color(0xFFFF7A59),
    Color(0xFFFFC857),
    Color(0xFF84CC16),
    Color(0xFF22D3EE),
    Color(0xFFA78BFA),
    Color(0xFFF472B6),
  ];
}

abstract final class PoswalGradients {
  static const aurora = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [PoswalColors.teal, PoswalColors.violet, PoswalColors.coral],
  );

  static const ringGradient = SweepGradient(
    colors: [PoswalColors.teal, PoswalColors.violet, PoswalColors.coral, PoswalColors.teal],
    stops: [0.0, 0.45, 0.85, 1.0],
  );
}

/// HIG Concentric Radius Scale & Geometry Calculations
abstract final class PoswalRadii {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 22.0;

  // Semantic Radii
  static const chip = 10.0;
  static const button = 14.0;
  static const card = 20.0;
  static const section = 24.0;
  static const sheet = 32.0;
  static const capsule = 999.0;
  static const pill = 999.0;

  /// Concentric Geometry Rule: inner radius = max(0.0, outer - padding)
  /// Guarantees that nested rounded corners curve harmoniously with their container.
  static double concentric({required double outer, required double padding}) {
    final inner = outer - padding;
    return inner > 0.0 ? inner : 0.0;
  }

  /// Calculates a concentric [BorderRadius] for an element placed inside an [outerRadius]
  /// with uniform or directional [padding].
  static BorderRadius concentricBorderRadius({
    required double outerRadius,
    required double padding,
  }) {
    return BorderRadius.circular(concentric(outer: outerRadius, padding: padding));
  }
}

/// HIG Standard Spacing Scale
abstract final class PoswalSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 48.0;
}

/// HIG Standard Row & Touch Target Heights
abstract final class PoswalRowHeights {
  /// Minimum accessible touch target per HIG (44dp)
  static const minTouchTarget = 44.0;
  static const compact = 44.0;
  static const standard = 52.0;
  static const prominent = 60.0;
  static const toolbar = 48.0;
  static const tabBar = 62.0;
}

/// Glass Fallback Tiers per HIG Rule 13
enum GlassTier {
  /// Full specular liquid glass with blur sigma=18, highlights, and subtle border
  premium,

  /// Standard frosted glass with blur sigma=12
  standard,

  /// Light frosted material with blur sigma=6, higher tint
  frosted,

  /// Solid opaque material with zero blur (Reduce Transparency & low GPU fallback)
  plain,
}

/// Glass Layer Opacities and Material Metrics
abstract final class PoswalGlass {
  // Base opacities for standard frosted glass
  static const darkTintOpacity = 0.12;
  static const lightTintOpacity = 0.65;
  static const darkBorderOpacity = 0.16;
  static const lightBorderOpacity = 0.60;
  static const borderWidth = 1.0;
  static const darkHighlightOpacity = 0.30;
  static const lightHighlightOpacity = 0.70;

  // Tiered Blur Sigmas
  static double blurSigma(GlassTier tier) {
    switch (tier) {
      case GlassTier.premium:
        return 18.0;
      case GlassTier.standard:
        return 12.0;
      case GlassTier.frosted:
        return 6.0;
      case GlassTier.plain:
        return 0.0;
    }
  }

  // Tiered Tint Opacity
  static double tintOpacity(GlassTier tier, {required bool isDark}) {
    switch (tier) {
      case GlassTier.premium:
        return isDark ? 0.10 : 0.60;
      case GlassTier.standard:
        return isDark ? 0.14 : 0.68;
      case GlassTier.frosted:
        return isDark ? 0.22 : 0.80;
      case GlassTier.plain:
        return 1.0; // Fully solid surface
    }
  }

  // Tiered Border Opacity
  static double borderOpacity(GlassTier tier, {required bool isDark}) {
    switch (tier) {
      case GlassTier.premium:
        return isDark ? 0.20 : 0.50;
      case GlassTier.standard:
        return isDark ? 0.16 : 0.40;
      case GlassTier.frosted:
        return isDark ? 0.12 : 0.30;
      case GlassTier.plain:
        return isDark ? 0.08 : 0.15;
    }
  }
}

/// Typography Scale (HIG Hierarchy with Scalable System Metrics)
abstract final class PoswalText {
  static const heading = 'PlusJakartaSans';
  static const body = 'Inter';

  static const largeTitle = TextStyle(
    fontFamily: heading,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.8,
  );

  static const title = TextStyle(
    fontFamily: heading,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const headline = TextStyle(
    fontFamily: heading,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const bodyText = TextStyle(
    fontFamily: body,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const callout = TextStyle(
    fontFamily: body,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static const subheadline = TextStyle(
    fontFamily: body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const footnote = TextStyle(
    fontFamily: body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.25,
  );

  static const caption = TextStyle(
    fontFamily: body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.2,
  );
}
