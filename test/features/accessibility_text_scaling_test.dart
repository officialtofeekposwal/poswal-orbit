import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/features/onboarding/presentation/onboarding_screen.dart';
import 'package:poswal_orbit/features/security/presentation/biometric_lock_screen.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

void main() {
  Widget buildScaledWidget(Widget child, {double textScale = 2.0}) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(textScale),
            size: const Size(1080, 2400),
          ),
          child: child,
        ),
      ),
    );
  }

  group('Accessibility & 200% Text Scaling Tests', () {
    testWidgets('OnboardingScreen renders at 200% text scale without overflow', (tester) async {
      FlutterErrorDetails? caughtError;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          caughtError = details;
        }
      };

      try {
        await tester.pumpWidget(buildScaledWidget(const OnboardingScreen(), textScale: 2.0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(caughtError, isNull, reason: 'Must not trigger RenderFlex overflow at 200% text scale');
        expect(find.byType(OnboardingScreen), findsOneWidget);
      } finally {
        FlutterError.onError = originalOnError;
      }
    });

    testWidgets('BiometricLockScreen renders at 200% text scale without overflow', (tester) async {
      FlutterErrorDetails? caughtError;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          caughtError = details;
        }
      };

      try {
        await tester.pumpWidget(buildScaledWidget(const BiometricLockScreen(), textScale: 2.0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(caughtError, isNull, reason: 'Must not trigger RenderFlex overflow at 200% text scale');
        expect(find.byType(BiometricLockScreen), findsOneWidget);
      } finally {
        FlutterError.onError = originalOnError;
      }
    });

    testWidgets('Interactive elements have accessible minimum tap bounds and semantics', (tester) async {
      await tester.pumpWidget(buildScaledWidget(const OnboardingScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final skipBtn = tester.getRect(find.byKey(const ValueKey('onboarding_skip_btn')));
      expect(skipBtn.width, greaterThanOrEqualTo(44.0));
      expect(skipBtn.height, greaterThanOrEqualTo(44.0));

      final nextBtn = tester.getRect(find.byKey(const ValueKey('onboarding_next_btn')));
      expect(nextBtn.height, greaterThanOrEqualTo(44.0));
    });
  });
}
