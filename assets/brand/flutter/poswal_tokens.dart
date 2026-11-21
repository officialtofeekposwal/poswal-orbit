// Poswal Orbit design tokens. Copy into lib/core/theme/poswal_tokens.dart
// Fonts are bundled locally (see pubspec_fonts_snippet.yaml). Do not use runtime Google Fonts.
import 'package:flutter/material.dart';

abstract final class PoswalColors {
  static const teal = Color(0xFF14B8A6);
  static const violet = Color(0xFF8B7CFF);
  static const coral = Color(0xFFFF7A59);
  static const gold = Color(0xFFFFC857);
  static const ink = Color(0xFF070B14);
  static const oled = Color(0xFF000000);
  static const mist = Color(0xFFF4F6FB);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);
  static const surfaceDark = Color(0xFF0F1626);
  static const surfaceDark2 = Color(0xFF151D30);
  static const textOnDark = Color(0xFFF5F7FF);
  static const textMutedDark = Color(0xFFA3AEC7);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textOnLight = Color(0xFF0B1020);
  static const textMutedLight = Color(0xFF5B667F);
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
}

abstract final class PoswalRadii {
  static const card = 24.0;
  static const sheet = 32.0;
  static const button = 16.0;
  static const pill = 999.0;
}

abstract final class PoswalSpacing {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0, xl = 24.0, xxl = 32.0, huge = 48.0;
}

/// Glass tokens. Opacity values are 0..1. Tune per device after profiling.
abstract final class PoswalGlass {
  static const darkTintOpacity = 0.12; // range 0.10 - 0.14
  static const lightTintOpacity = 0.60; // range 0.55 - 0.65
  static const darkBorderOpacity = 0.18;
  static const lightBorderOpacity = 0.70;
  static const borderWidth = 1.0;
  static const darkHighlightOpacity = 0.35;
  static const lightHighlightOpacity = 0.80;
}

abstract final class PoswalText {
  static const heading = 'PlusJakartaSans';
  static const body = 'Inter';
  static const largeTitle = TextStyle(fontFamily: heading, fontSize: 34, fontWeight: FontWeight.w700, height: 1.15);
  static const title = TextStyle(fontFamily: heading, fontSize: 22, fontWeight: FontWeight.w700, height: 1.2);
  static const headline = TextStyle(fontFamily: heading, fontSize: 17, fontWeight: FontWeight.w600, height: 1.3);
  static const bodyText = TextStyle(fontFamily: body, fontSize: 17, fontWeight: FontWeight.w400, height: 1.4);
  static const callout = TextStyle(fontFamily: body, fontSize: 15, fontWeight: FontWeight.w400, height: 1.4);
  static const caption = TextStyle(fontFamily: body, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3);
}
