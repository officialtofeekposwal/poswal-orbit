import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/liquid_glass.dart';

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

    test('Light mode accessible text tokens achieve AA compliance across all light surfaces (>= 4.5:1)', () {
      const lightSurfaces = [
        PoswalColors.surfaceLight,
        PoswalColors.surfaceLight2,
        PoswalColors.surfaceLight3,
      ];

      for (final bg in lightSurfaces) {
        expect(_contrastRatio(PoswalColors.tealLight, bg), greaterThanOrEqualTo(4.5), reason: 'tealLight must pass AA on $bg');
        expect(_contrastRatio(PoswalColors.successLight, bg), greaterThanOrEqualTo(4.5), reason: 'successLight must pass AA on $bg');
        expect(_contrastRatio(PoswalColors.warningLight, bg), greaterThanOrEqualTo(4.5), reason: 'warningLight must pass AA on $bg');
        expect(_contrastRatio(PoswalColors.dangerLight, bg), greaterThanOrEqualTo(4.5), reason: 'dangerLight must pass AA on $bg');
        expect(_contrastRatio(PoswalColors.violetLight, bg), greaterThanOrEqualTo(4.5), reason: 'violetLight must pass AA on $bg');
        expect(_contrastRatio(PoswalColors.textSecondaryLight, bg), greaterThanOrEqualTo(4.5), reason: 'textSecondaryLight must pass AA on $bg');
      }
    });

    test('Light mode body and muted typography achieve AA/AAA compliance across all light surfaces', () {
      const lightSurfaces = [
        PoswalColors.surfaceLight,
        PoswalColors.surfaceLight2,
        PoswalColors.surfaceLight3,
      ];

      for (final bg in lightSurfaces) {
        expect(_contrastRatio(PoswalColors.textOnLight, bg), greaterThanOrEqualTo(7.0), reason: 'textOnLight must pass AAA on $bg');
        expect(_contrastRatio(PoswalColors.textMutedLight, bg), greaterThanOrEqualTo(4.5), reason: 'textMutedLight must pass AA on $bg');
        expect(_contrastRatio(PoswalColors.textHighContrastLight, bg), greaterThanOrEqualTo(7.0), reason: 'textHighContrastLight must pass AAA on $bg');
        expect(_contrastRatio(PoswalColors.textMutedHighContrastLight, bg), greaterThanOrEqualTo(7.0), reason: 'textMutedHighContrastLight must pass AAA on $bg');
      }
    });

    test('Dark and OLED mode typography achieve AAA compliance across all dark surfaces (>= 4.5:1 / >= 7.0:1)', () {
      const darkSurfaces = [
        PoswalColors.surfaceDark,
        PoswalColors.surfaceDark2,
        PoswalColors.surfaceDark3,
        PoswalColors.oled,
      ];

      for (final bg in darkSurfaces) {
        expect(_contrastRatio(PoswalColors.textOnDark, bg), greaterThanOrEqualTo(7.0), reason: 'textOnDark must pass AAA on $bg');
        expect(_contrastRatio(PoswalColors.textMutedDark, bg), greaterThanOrEqualTo(4.5), reason: 'textMutedDark must pass AA on $bg');
        expect(_contrastRatio(PoswalColors.textSecondaryDark, bg), greaterThanOrEqualTo(4.5), reason: 'textSecondaryDark must pass AA on $bg');
        expect(_contrastRatio(PoswalColors.textHighContrastDark, bg), greaterThanOrEqualTo(7.0), reason: 'textHighContrastDark must pass AAA on $bg');
        expect(_contrastRatio(PoswalColors.textMutedHighContrastDark, bg), greaterThanOrEqualTo(7.0), reason: 'textMutedHighContrastDark must pass AAA on $bg');
      }
    });

    test('Strict hierarchy ordering and separation: primary > muted > secondary across all surfaces', () {
      const lightSurfaces = [
        PoswalColors.surfaceLight,
        PoswalColors.surfaceLight2,
        PoswalColors.surfaceLight3,
      ];
      for (final bg in lightSurfaces) {
        final p = _contrastRatio(PoswalColors.textOnLight, bg);
        final m = _contrastRatio(PoswalColors.textMutedLight, bg);
        final s = _contrastRatio(PoswalColors.textSecondaryLight, bg);

        expect(p > m, isTrue, reason: 'Light: primary contrast ($p) must exceed muted contrast ($m) on $bg');
        expect(m > s, isTrue, reason: 'Light: muted contrast ($m) must exceed secondary contrast ($s) on $bg');
        expect(s >= 4.5, isTrue, reason: 'Light: secondary contrast ($s) must pass AA on $bg');
        // Minimum contrast ratio separation between levels
        expect(p - m, greaterThanOrEqualTo(2.0), reason: 'Light: primary to muted separation must be >= 2.0:1 on $bg');
        expect(m - s, greaterThanOrEqualTo(1.0), reason: 'Light: muted to secondary separation must be >= 1.0:1 on $bg');
      }

      const darkSurfaces = [
        PoswalColors.surfaceDark,
        PoswalColors.surfaceDark2,
        PoswalColors.surfaceDark3,
        PoswalColors.oled,
      ];
      for (final bg in darkSurfaces) {
        final p = _contrastRatio(PoswalColors.textOnDark, bg);
        final m = _contrastRatio(PoswalColors.textMutedDark, bg);
        final s = _contrastRatio(PoswalColors.textSecondaryDark, bg);

        expect(p > m, isTrue, reason: 'Dark: primary contrast ($p) must exceed muted contrast ($m) on $bg');
        expect(m > s, isTrue, reason: 'Dark: muted contrast ($m) must exceed secondary contrast ($s) on $bg');
        expect(s >= 4.5, isTrue, reason: 'Dark: secondary contrast ($s) must pass AA on $bg');
        // Minimum contrast ratio separation between levels
        expect(p - m, greaterThanOrEqualTo(2.0), reason: 'Dark: primary to muted separation must be >= 2.0:1 on $bg');
        expect(m - s, greaterThanOrEqualTo(2.0), reason: 'Dark: muted to secondary separation must be >= 2.0:1 on $bg');
      }
    });

    test('Dark mode semantic status accents achieve AA compliance on surfaceDark2', () {
      const bg = PoswalColors.surfaceDark2;

      expect(_contrastRatio(PoswalColors.teal, bg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.success, bg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.warning, bg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.danger, bg), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.violet, bg), greaterThanOrEqualTo(3.0)); // UI element
    });

    test('High-contrast tokens strictly exceed normal tokens and preserve Primary > Muted > Secondary order', () {
      const darkSurfaces = [
        PoswalColors.surfaceDark,
        PoswalColors.surfaceDark2,
        PoswalColors.surfaceDark3,
        PoswalColors.oled,
      ];
      for (final bg in darkSurfaces) {
        final pNorm = _contrastRatio(PoswalColors.textOnDark, bg);
        final mNorm = _contrastRatio(PoswalColors.textMutedDark, bg);
        final sNorm = _contrastRatio(PoswalColors.textSecondaryDark, bg);

        final pHc = _contrastRatio(PoswalColors.textHighContrastDark, bg);
        final mHc = _contrastRatio(PoswalColors.textMutedHighContrastDark, bg);
        final sHc = _contrastRatio(PoswalColors.textSecondaryHighContrastDark, bg);

        // High-contrast must strictly exceed normal at every tier
        expect(pHc >= pNorm, isTrue, reason: 'Dark HC primary must be >= normal on $bg');
        expect(mHc > mNorm, isTrue, reason: 'Dark HC muted ($mHc) must strictly exceed normal ($mNorm) on $bg');
        expect(sHc > sNorm, isTrue, reason: 'Dark HC secondary ($sHc) must strictly exceed normal ($sNorm) on $bg');

        // High-contrast ordering must be preserved: Primary > Muted > Secondary
        expect(pHc > mHc, isTrue, reason: 'Dark HC primary ($pHc) must exceed HC muted ($mHc) on $bg');
        expect(mHc > sHc, isTrue, reason: 'Dark HC muted ($mHc) must exceed HC secondary ($sHc) on $bg');
        expect(sHc >= 4.5, isTrue, reason: 'Dark HC secondary must pass AA on $bg');
      }

      const lightSurfaces = [
        PoswalColors.surfaceLight,
        PoswalColors.surfaceLight2,
        PoswalColors.surfaceLight3,
      ];
      for (final bg in lightSurfaces) {
        final pNorm = _contrastRatio(PoswalColors.textOnLight, bg);
        final mNorm = _contrastRatio(PoswalColors.textMutedLight, bg);
        final sNorm = _contrastRatio(PoswalColors.textSecondaryLight, bg);

        final pHc = _contrastRatio(PoswalColors.textHighContrastLight, bg);
        final mHc = _contrastRatio(PoswalColors.textMutedHighContrastLight, bg);
        final sHc = _contrastRatio(PoswalColors.textSecondaryHighContrastLight, bg);

        // High-contrast must strictly exceed normal at every tier
        expect(pHc >= pNorm, isTrue, reason: 'Light HC primary must be >= normal on $bg');
        expect(mHc > mNorm, isTrue, reason: 'Light HC muted ($mHc) must strictly exceed normal ($mNorm) on $bg');
        expect(sHc > sNorm, isTrue, reason: 'Light HC secondary ($sHc) must strictly exceed normal ($sNorm) on $bg');

        // High-contrast ordering must be preserved: Primary > Muted > Secondary
        expect(pHc > mHc, isTrue, reason: 'Light HC primary ($pHc) must exceed HC muted ($mHc) on $bg');
        expect(mHc > sHc, isTrue, reason: 'Light HC muted ($mHc) must exceed HC secondary ($sHc) on $bg');
        expect(sHc >= 4.5, isTrue, reason: 'Light HC secondary must pass AA on $bg');
      }
    });

    test('LiquidGlass composited dark and light surfaces pass WCAG AA/AAA contrast', () {
      final darkGlass = LiquidGlass.effectiveDarkSurface();
      final lightGlass = LiquidGlass.effectiveLightSurface();

      expect(_contrastRatio(PoswalColors.textOnDark, darkGlass), greaterThanOrEqualTo(7.0));
      expect(_contrastRatio(PoswalColors.textSecondaryDark, darkGlass), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.teal, darkGlass), greaterThanOrEqualTo(4.5));

      expect(_contrastRatio(PoswalColors.textOnLight, lightGlass), greaterThanOrEqualTo(7.0));
      expect(_contrastRatio(PoswalColors.textSecondaryLight, lightGlass), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(PoswalColors.tealLight, lightGlass), greaterThanOrEqualTo(4.5));
    });
  });
}
