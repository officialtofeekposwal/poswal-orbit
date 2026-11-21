import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/features/settings/application/settings_providers.dart';
import 'package:poswal_orbit/features/settings/domain/settings_preferences.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

void main() {
  group('Localization & RTL Verification Tests', () {
    testWidgets('1. Urdu locale renders with RTL text direction and translated strings', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ur'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: PoswalTheme.getTheme(AppThemeMode.dark, languageCode: 'ur'),
          home: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              final l10n = AppLocalizations.of(ctx)!;
              return Scaffold(
                appBar: AppBar(title: Text(l10n.appTitle)),
                body: Column(
                  children: [
                    Text(l10n.tabToday),
                    Text(l10n.tabHabits),
                    Text(l10n.tabTasks),
                    Text(l10n.tabNotes),
                    Text(l10n.tabInsights),
                    Text(l10n.settingsTitle),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Directionality is RTL
      expect(Directionality.of(capturedContext), TextDirection.rtl);

      // Verify Urdu translated text appears
      expect(find.text('پوسوال مدار'), findsOneWidget);
      expect(find.text('آج'), findsOneWidget);
      expect(find.text('عادات'), findsOneWidget);
      expect(find.text('کام'), findsOneWidget);
      expect(find.text('نوٹس'), findsOneWidget);
      expect(find.text('بصیرت'), findsOneWidget);
      expect(find.text('ترتیبات'), findsOneWidget);
    });

    testWidgets('2. Hindi locale renders with LTR text direction and Devanagari strings', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hi'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: PoswalTheme.getTheme(AppThemeMode.dark, languageCode: 'hi'),
          home: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              final l10n = AppLocalizations.of(ctx)!;
              return Scaffold(
                appBar: AppBar(title: Text(l10n.appTitle)),
                body: Column(
                  children: [
                    Text(l10n.tabToday),
                    Text(l10n.tabHabits),
                    Text(l10n.tabTasks),
                    Text(l10n.tabNotes),
                    Text(l10n.tabInsights),
                    Text(l10n.settingsTitle),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Directionality is LTR for Hindi
      expect(Directionality.of(capturedContext), TextDirection.ltr);

      // Verify Hindi Devanagari text appears
      expect(find.text('पोसवाल ऑर्बिट'), findsOneWidget);
      expect(find.text('आज'), findsOneWidget);
      expect(find.text('आदतें'), findsOneWidget);
      expect(find.text('कार्य'), findsOneWidget);
      expect(find.text('नोट्स'), findsOneWidget);
      expect(find.text('अंतर्दृष्टि'), findsOneWidget);
      expect(find.text('सेटिंग्स'), findsOneWidget);
    });

    testWidgets('3. SettingsNotifier updates language preference and derives correct locale', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);
      expect(container.read(settingsProvider).language, AppLanguageOption.system);
      expect(container.read(settingsProvider).language.locale, isNull);

      notifier.updateLanguage(AppLanguageOption.ur);
      expect(container.read(settingsProvider).language, AppLanguageOption.ur);
      expect(container.read(settingsProvider).language.locale, const Locale('ur'));
      expect(container.read(settingsProvider).language.isRtl, isTrue);

      notifier.updateLanguage(AppLanguageOption.hi);
      expect(container.read(settingsProvider).language, AppLanguageOption.hi);
      expect(container.read(settingsProvider).language.locale, const Locale('hi'));
      expect(container.read(settingsProvider).language.isRtl, isFalse);

      notifier.updateLanguage(AppLanguageOption.en);
      expect(container.read(settingsProvider).language, AppLanguageOption.en);
      expect(container.read(settingsProvider).language.locale, const Locale('en'));
    });
  });
}
