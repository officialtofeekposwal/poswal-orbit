import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/features/onboarding/application/onboarding_providers.dart';
import 'package:poswal_orbit/features/onboarding/presentation/onboarding_screen.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

void main() {
  Widget buildTestableOnboarding({Locale locale = const Locale('en')}) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
  }

  group('OnboardingScreen Widget Tests', () {
    testWidgets('Renders Page 1 with habits momentum title and skip button', (tester) async {
      await tester.pumpWidget(buildTestableOnboarding());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey('onboarding_skip_btn')), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding_next_btn')), findsOneWidget);
      expect(find.text('Build Lasting Momentum'), findsOneWidget);
    });

    testWidgets('Tapping Next navigates through all 3 pages to Get Started', (tester) async {
      await tester.pumpWidget(buildTestableOnboarding());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Page 1
      expect(find.text('Build Lasting Momentum'), findsOneWidget);

      // Tap Next to Page 2
      await tester.tap(find.byKey(const ValueKey('onboarding_next_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Calm, Focused Action'), findsOneWidget);

      // Tap Next to Page 3
      await tester.tap(find.byKey(const ValueKey('onboarding_next_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Private Thoughts & Journal'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Tapping Skip completes onboarding', (tester) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(splashFactory: InkRipple.splashFactory),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return const OnboardingScreen();
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(capturedRef.read(onboardingCompletedProvider), isFalse);

      await tester.tap(find.byKey(const ValueKey('onboarding_skip_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(capturedRef.read(onboardingCompletedProvider), isTrue);
    });

    testWidgets('Renders localized strings in Hindi and Urdu', (tester) async {
      await tester.pumpWidget(buildTestableOnboarding(locale: const Locale('hi')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('स्थायी गति बनाएं'), findsOneWidget);
      expect(find.text('छोड़ें'), findsOneWidget);
      expect(find.text('आगे'), findsOneWidget);
    });
  });
}
