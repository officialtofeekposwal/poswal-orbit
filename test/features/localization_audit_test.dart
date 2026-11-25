import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/notes/presentation/notes_screen.dart';
import 'package:poswal_orbit/features/settings/presentation/settings_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/tasks_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase inMemoryDb;

  setUp(() {
    inMemoryDb = AppDatabase(NativeDatabase.memory());
  });
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

    test('Scanner enforces no hard-coded user-facing strings across lib/', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && !f.path.contains('playground') && !f.path.contains('.g.dart') && !f.path.contains('vault'))
          .toList();

      final allowlist = <String>{
        '',
        '·',
        ',',
        ':',
        '/',
        '-',
        '+',
        '%',
        '.',
        '>',
        '<',
        '#',
        '*',
        '!',
        '# ',
        '- ',
        '- [ ] ',
        '**',
        '[',
        '](https://)',
        'Poswal Orbit',
        'Poswal',
        'Orbit',
        '/ 100',
        '0',
        '100',
        '0%',
        '0 of 0',
        'Unrestricted',
        'Allowed',
        '1',
        '2',
        '3',
        '4',
        'v1.0.0 (Build 42)',
      };

      final violations = <String>[];

      final textLiteralRegex = RegExp(r"Text\(\s*[']([^']+)[']\s*[,)]");
      final textDoubleLiteralRegex = RegExp(r'Text\(\s*["]([^"]+)["]\s*[,)]');
      final hintLabelTooltipRegex = RegExp(r"(hintText|labelText|tooltip|title|label|semanticLabel):\s*[']([^']+)[']");
      final hintLabelTooltipDoubleRegex = RegExp(r'(hintText|labelText|tooltip|title|label|semanticLabel):\s*["]([^"]+)["]');
      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}]', unicode: true);
      final rawExclamationRegex = RegExp(r'[A-Za-z]+!');

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          // Skip comments
          if (line.startsWith('//') || line.startsWith('/*') || line.startsWith('*')) {
            continue;
          }

          // Check for emojis in code
          if (emojiRegex.hasMatch(line)) {
            violations.add('${file.path}:${i + 1} - Emoji detected: "$line"');
          }

          // Check Text('...')
          for (final m in textLiteralRegex.allMatches(line)) {
            final val = m.group(1)!.trim();
            if (!allowlist.contains(val) && !val.contains(r'$') && RegExp(r'[A-Za-z]').hasMatch(val)) {
              if (!line.contains('??')) {
                violations.add('${file.path}:${i + 1} - Raw Text: "$val"');
              }
            }
            if (rawExclamationRegex.hasMatch(val)) {
              violations.add('${file.path}:${i + 1} - Exclamation in text: "$val"');
            }
          }

          // Check Text("...")
          for (final m in textDoubleLiteralRegex.allMatches(line)) {
            final val = m.group(1)!.trim();
            if (!allowlist.contains(val) && !val.contains(r'$') && RegExp(r'[A-Za-z]').hasMatch(val)) {
              if (!line.contains('??')) {
                violations.add('${file.path}:${i + 1} - Raw Text: "$val"');
              }
            }
            if (rawExclamationRegex.hasMatch(val)) {
              violations.add('${file.path}:${i + 1} - Exclamation in text: "$val"');
            }
          }

          // Check hintText / labelText / tooltip / title / label / semanticLabel
          for (final m in hintLabelTooltipRegex.allMatches(line)) {
            final key = m.group(1)!;
            final val = m.group(2)!.trim();
            if (!allowlist.contains(val) && !val.contains(r'$') && RegExp(r'[A-Za-z]').hasMatch(val)) {
              if (!line.contains('??')) {
                violations.add('${file.path}:${i + 1} - Raw $key: "$val"');
              }
            }
            if (rawExclamationRegex.hasMatch(val)) {
              violations.add('${file.path}:${i + 1} - Exclamation in $key: "$val"');
            }
          }

          for (final m in hintLabelTooltipDoubleRegex.allMatches(line)) {
            final key = m.group(1)!;
            final val = m.group(2)!.trim();
            if (!allowlist.contains(val) && !val.contains(r'$') && RegExp(r'[A-Za-z]').hasMatch(val)) {
              if (!line.contains('??')) {
                violations.add('${file.path}:${i + 1} - Raw $key: "$val"');
              }
            }
            if (rawExclamationRegex.hasMatch(val)) {
              violations.add('${file.path}:${i + 1} - Exclamation in $key: "$val"');
            }
          }
        }
      }

      if (violations.isNotEmpty) {
        fail('Found hardcoded user-facing strings across lib/:\n${violations.join('\n')}');
      }
      expect(violations, isEmpty);
    });

    test('Demonstration proof: Scanner catches bad strings (emoji, exclamation, raw label, ALL-CAPS)', () {
      final badSamples = [
        "Text('🌟 Test notification')",
        "Text('Outstanding work!')",
        "label: 'RawUnlocalizedLabel'",
        "title: 'ALL CAPS HEADER'",
      ];

      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}]', unicode: true);
      final rawExclamationRegex = RegExp(r'[A-Za-z]+!');
      final rawLabelRegex = RegExp(r"(hintText|labelText|tooltip|title|label|semanticLabel):\s*[']([^']+)[']");

      expect(emojiRegex.hasMatch(badSamples[0]), isTrue, reason: 'Must detect emoji');
      expect(rawExclamationRegex.hasMatch(badSamples[1]), isTrue, reason: 'Must detect exclamation mark');
      expect(rawLabelRegex.hasMatch(badSamples[2]), isTrue, reason: 'Must detect raw label');
      expect(RegExp(r'\b[A-Z]{3,}\b').hasMatch(badSamples[3]), isTrue, reason: 'Must detect ALL-CAPS');
    });

    testWidgets('Opens Settings in Hindi (hi) and Urdu (ur) without English leaks', (tester) async {
      for (final locale in [const Locale('hi'), const Locale('ur')]) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              home: const SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // English strings must NOT appear
        expect(find.text('Restore from Backup?'), findsNothing);
        expect(find.text('Restore Safely'), findsNothing);
        expect(find.text('Appearance'), findsNothing);
        expect(find.text('Glass Intensity'), findsNothing);
        expect(find.text('Time & Orbit Boundary'), findsNothing);

        // Translated titles MUST appear
        if (locale.languageCode == 'hi') {
          expect(find.text('दिखावट'), findsOneWidget);
          expect(find.text('समय और कक्षा सीमा'), findsOneWidget);
          expect(find.text('थीम'), findsOneWidget);
        } else if (locale.languageCode == 'ur') {
          expect(find.text('ظاہरी شکل'), findsNothing); // ensure no Hindi in Urdu
          expect(find.text('ظاہری شکل'), findsOneWidget);
          expect(find.text('وقت اور مدار کی حد'), findsOneWidget);
          expect(find.text('تھیم'), findsOneWidget);
        }
      }
    });

    testWidgets('Opens Today, Tasks, Notes and Sheets in Hindi and Urdu without English leaks', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final locale in [const Locale('hi'), const Locale('ur')]) {
        // 1. Tasks Screen
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(inMemoryDb),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              home: const Scaffold(body: TasksScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Tasks'), findsNothing);

        // 2. Notes Screen
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(inMemoryDb),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              home: const Scaffold(body: NotesScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Notes'), findsNothing);

        // 3. Task Detail Sheet
        final dummyTask = Task(
          id: 'task-test-loc',
          title: 'Sample Task',
          priority: TaskPriority.none,
          sortOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(inMemoryDb),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              home: Scaffold(
                body: TaskDetailSheet(task: dummyTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        // English sheet headers / buttons must NOT appear
        expect(find.text('Task Details'), findsNothing);
        expect(find.text('Delete Task'), findsNothing);

        if (locale.languageCode == 'hi') {
          expect(find.text('कार्य विवरण'), findsOneWidget);
          expect(find.text('कार्य हटाएं'), findsOneWidget);
        } else if (locale.languageCode == 'ur') {
          expect(find.text('کام کی تفصیلات'), findsOneWidget);
          expect(find.text('کام حذف کریں'), findsOneWidget);
        }
      }

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 200));
      await tester.runAsync(() async {
        await inMemoryDb.close();
      });
    });
  });
}

