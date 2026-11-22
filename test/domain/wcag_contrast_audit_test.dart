import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';

/// Official W3C relative luminance calculation
double _relativeLuminance(Color c) {
  double channel(double v) {
    return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  // Color.r, Color.g, Color.b in modern Flutter are in 0.0..1.0 range
  final r = channel(c.r);
  final g = channel(c.g);
  final b = channel(c.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Official W3C contrast ratio: (L1 + 0.05) / (L2 + 0.05)
double _contrastRatio(Color fg, Color bg) {
  final l1 = _relativeLuminance(fg);
  final l2 = _relativeLuminance(bg);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG 2.1 Color Contrast Audit & Regression Protection', () {
    test('Dark ink on Orbit Teal action button achieves AAA compliance (>= 7.0:1)', () {
      final ratio = _contrastRatio(PoswalColors.ink, PoswalColors.teal);
      expect(ratio, greaterThanOrEqualTo(7.0), reason: 'Ink on teal must pass AAA (>= 7.0:1)');
    });

    test('Light mode accessible text tokens achieve AA compliance on surfaceLight (>= 4.5:1)', () {
      const bg = PoswalColors.surfaceLight;

      final tealLightRatio = _contrastRatio(PoswalColors.tealLight, bg);
      expect(tealLightRatio, greaterThanOrEqualTo(4.5), reason: 'tealLight on surfaceLight must pass AA (>= 4.5:1)');

      final successLightRatio = _contrastRatio(PoswalColors.successLight, bg);
      expect(successLightRatio, greaterThanOrEqualTo(4.5), reason: 'successLight on surfaceLight must pass AA (>= 4.5:1)');

      final warningLightRatio = _contrastRatio(PoswalColors.warningLight, bg);
      expect(warningLightRatio, greaterThanOrEqualTo(4.5), reason: 'warningLight on surfaceLight must pass AA (>= 4.5:1)');

      final dangerLightRatio = _contrastRatio(PoswalColors.dangerLight, bg);
      expect(dangerLightRatio, greaterThanOrEqualTo(4.5), reason: 'dangerLight on surfaceLight must pass AA (>= 4.5:1)');

      final violetLightRatio = _contrastRatio(PoswalColors.violetLight, bg);
      expect(violetLightRatio, greaterThanOrEqualTo(4.5), reason: 'violetLight on surfaceLight must pass AA (>= 4.5:1)');
    });

    test('Light mode body and muted typography achieve AA/AAA compliance on surfaceLight', () {
      const bg = PoswalColors.surfaceLight;

      final primaryRatio = _contrastRatio(PoswalColors.textOnLight, bg);
      expect(primaryRatio, greaterThanOrEqualTo(7.0), reason: 'textOnLight on surfaceLight must pass AAA (>= 7.0:1)');

      final mutedRatio = _contrastRatio(PoswalColors.textMutedLight, bg);
      expect(mutedRatio, greaterThanOrEqualTo(4.5), reason: 'textMutedLight on surfaceLight must pass AA (>= 4.5:1)');

      final highContrastMutedRatio = _contrastRatio(PoswalColors.textMutedHighContrastLight, bg);
      expect(highContrastMutedRatio, greaterThanOrEqualTo(7.0), reason: 'textMutedHighContrastLight must pass AAA (>= 7.0:1)');
    });

    test('Dark and OLED mode typography achieve AAA compliance (>= 7.0:1)', () {
      const darkBg = PoswalColors.surfaceDark2;
      const oledBg = PoswalColors.oled;

      expect(_contrastRatio(PoswalColors.textOnDark, darkBg), greaterThanOrEqualTo(7.0));
      expect(_contrastRatio(PoswalColors.textOnDark, oledBg), greaterThanOrEqualTo(7.0));

      expect(_contrastRatio(PoswalColors.textMutedDark, darkBg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.textHighContrastDark, darkBg), greaterThanOrEqualTo(7.0));
    });

    test('Dark mode semantic status accents achieve AA compliance on surfaceDark2', () {
      const bg = PoswalColors.surfaceDark2;

      expect(_contrastRatio(PoswalColors.teal, bg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.success, bg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.warning, bg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.danger, bg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.violet, bg), greaterThanOrEqualTo(3.0)); // UI element
    });
  });
}
