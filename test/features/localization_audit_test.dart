import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Localization Audit Tests', () {
    test('All ARB localization files exist and have matching keys', () {
      final enFile = File('lib/l10n/app_en.arb');
      final hiFile = File('lib/l10n/app_hi.arb');
      final urFile = File('lib/l10n/app_ur.arb');

      expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');
      expect(hiFile.existsSync(), isTrue, reason: 'app_hi.arb must exist');
      expect(urFile.existsSync(), isTrue, reason: 'app_ur.arb must exist');

      final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      final hiJson = jsonDecode(hiFile.readAsStringSync()) as Map<String, dynamic>;
      final urJson = jsonDecode(urFile.readAsStringSync()) as Map<String, dynamic>;

      // Filter out meta keys starting with '@'
      final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();
      final hiKeys = hiJson.keys.where((k) => !k.startsWith('@')).toSet();
      final urKeys = urJson.keys.where((k) => !k.startsWith('@')).toSet();

      expect(enKeys.isNotEmpty, isTrue);

      final missingInHi = enKeys.difference(hiKeys);
      final missingInUr = enKeys.difference(urKeys);

      expect(missingInHi, isEmpty, reason: 'Hindi ARB is missing keys: $missingInHi');
      expect(missingInUr, isEmpty, reason: 'Urdu ARB is missing keys: $missingInUr');

      // Verify no empty string values
      for (final key in enKeys) {
        expect((hiJson[key] as String).trim(), isNotEmpty, reason: 'Hindi key $key is empty');
        expect((urJson[key] as String).trim(), isNotEmpty, reason: 'Urdu key $key is empty');
      }
    });

    testWidgets('AppLocalizations provides valid translations across en, hi, and ur', (tester) async {
      late AppLocalizations enL10n;
      late AppLocalizations hiL10n;
      late AppLocalizations urL10n;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              enL10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('hi'),
          home: Builder(
            builder: (context) {
              hiL10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ur'),
          home: Builder(
            builder: (context) {
              urL10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(enL10n.appTitle, equals('Poswal Orbit'));
      expect(hiL10n.appTitle, equals('पोसवाल ऑर्बिट'));
      expect(urL10n.appTitle, equals('پوسوال مدار'));

      expect(enL10n.tabToday, equals('Today'));
      expect(hiL10n.tabToday, equals('आज'));
      expect(urL10n.tabToday, equals('آج'));

      expect(enL10n.tabHabits, equals('Habits'));
      expect(hiL10n.tabHabits, equals('आदतें'));
      expect(urL10n.tabHabits, equals('عادات'));

      expect(enL10n.tabTasks, equals('Tasks'));
      expect(hiL10n.tabTasks, equals('कार्य'));
      expect(urL10n.tabTasks, equals('کام'));

      expect(enL10n.tabNotes, equals('Notes'));
      expect(hiL10n.tabNotes, equals('नोट्स'));
      expect(urL10n.tabNotes, equals('نوٹس'));

      expect(enL10n.tabInsights, equals('Insights'));
      expect(hiL10n.tabInsights, equals('अंतर्दृष्टि'));
      expect(urL10n.tabInsights, equals('بصیرت'));
    });

    test('Key presentation screens import and utilize AppLocalizations', () {
      final keyFiles = [
        'lib/features/today/presentation/today_screen.dart',
        'lib/features/habits/presentation/habits_screen.dart',
        'lib/features/habits/presentation/habit_form_sheet.dart',
        'lib/features/tasks/presentation/tasks_screen.dart',
        'lib/features/notes/presentation/notes_screen.dart',
        'lib/features/notes/presentation/note_editor_screen.dart',
        'lib/features/settings/presentation/settings_screen.dart',
      ];

      for (final filePath in keyFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue, reason: '$filePath must exist');
        final content = file.readAsStringSync();
        expect(
          content.contains('app_localizations.dart') || content.contains('AppLocalizations'),
          isTrue,
          reason: '$filePath must import and use AppLocalizations',
        );
      }
    });
  });
}
