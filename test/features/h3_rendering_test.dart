import 'dart:io';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/services/data_safety_service.dart';
import 'package:poswal_orbit/features/insights/presentation/insights_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/notes_screen.dart';
import 'package:poswal_orbit/features/onboarding/presentation/onboarding_screen.dart';
import 'package:poswal_orbit/features/settings/presentation/settings_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/tasks_screen.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/features/today/presentation/today_screen.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class _TrueReduceTransparencyNotifier extends ReduceTransparencyNotifier {
  @override
  bool build() => true;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase inMemoryDb;
  late Directory tempBackupDir;

  setUp(() async {
    inMemoryDb = AppDatabase(NativeDatabase.memory());
    tempBackupDir = await Directory.systemTemp.createTemp('h3_render_test_');
  });

  Future<void> pumpRenderApp(
    WidgetTester tester,
    Widget child, {
    AppThemeMode mode = AppThemeMode.dark,
    Size size = const Size(430, 932),
    double textScale = 1.0,
    Locale locale = const Locale('en'),
    bool highContrast = false,
    List<dynamic> additionalOverrides = const [],
  }) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(inMemoryDb),
          dataSafetyServiceProvider.overrideWithValue(DataSafetyService(inMemoryDb, tempBackupDir)),
          for (final o in additionalOverrides) o,
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: PoswalTheme.getTheme(mode, languageCode: locale.languageCode),
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
              highContrast: highContrast,
            ),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tearDownRenderTest(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.runAsync(() async {
      await inMemoryDb.close();
      try {
        if (await tempBackupDir.exists()) {
          await tempBackupDir.delete(recursive: true);
        }
      } catch (_) {}
    });
  }

  group('Gate H3 - Rendering, Locales, Viewports & Accessibility Checks', () {
    testWidgets('1. 200% text scale renders without RenderFlex overflow across key screens', (tester) async {
      FlutterErrorDetails? caughtOverflow;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          caughtOverflow = details;
        }
      };

      try {
        // TodayScreen at 200% text scale
        await pumpRenderApp(tester, const TodayScreen(), textScale: 2.0);
        expect(caughtOverflow, isNull, reason: 'TodayScreen overflowed at 200% text scale');

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));

        // TasksScreen at 200% text scale
        await pumpRenderApp(tester, const TasksScreen(), textScale: 2.0);
        expect(caughtOverflow, isNull, reason: 'TasksScreen overflowed at 200% text scale');

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));

        // NotesScreen at 200% text scale
        await pumpRenderApp(tester, const NotesScreen(), textScale: 2.0);
        expect(caughtOverflow, isNull, reason: 'NotesScreen overflowed at 200% text scale');

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));

        // SettingsScreen at 200% text scale
        await pumpRenderApp(tester, const SettingsScreen(), textScale: 2.0, size: const Size(800, 3200));
        expect(caughtOverflow, isNull, reason: 'SettingsScreen overflowed at 200% text scale');

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));

        // OnboardingScreen at 200% text scale
        await pumpRenderApp(tester, const OnboardingScreen(), textScale: 2.0);
        expect(caughtOverflow, isNull, reason: 'OnboardingScreen overflowed at 200% text scale');
      } finally {
        FlutterError.onError = originalOnError;
        await tearDownRenderTest(tester);
      }
    });

    testWidgets('2. Urdu RTL locale renders with correct RTL text direction without breakages', (tester) async {
      late BuildContext capturedCtx;
      await pumpRenderApp(
        tester,
        Builder(
          builder: (ctx) {
            capturedCtx = ctx;
            return const TodayScreen();
          },
        ),
        locale: const Locale('ur'),
      );

      expect(Directionality.of(capturedCtx), TextDirection.rtl);
      expect(find.byType(TodayScreen), findsOneWidget);
      await tearDownRenderTest(tester);
    });

    testWidgets('3. Hindi locale renders with Devanagari text correctly', (tester) async {
      late BuildContext capturedCtx;
      await pumpRenderApp(
        tester,
        Builder(
          builder: (ctx) {
            capturedCtx = ctx;
            return const TodayScreen();
          },
        ),
        locale: const Locale('hi'),
      );

      expect(Directionality.of(capturedCtx), TextDirection.ltr);
      expect(find.byType(TodayScreen), findsOneWidget);
      await tearDownRenderTest(tester);
    });

    testWidgets('4. 360dp narrow viewport renders without horizontal overflow', (tester) async {
      FlutterErrorDetails? caughtOverflow;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          caughtOverflow = details;
        }
      };

      try {
        await pumpRenderApp(tester, const TodayScreen(), size: const Size(360, 780));
        expect(caughtOverflow, isNull);

        await pumpRenderApp(tester, const TasksScreen(), size: const Size(360, 780));
        expect(caughtOverflow, isNull);

        await pumpRenderApp(tester, const NotesScreen(), size: const Size(360, 780));
        expect(caughtOverflow, isNull);

        await pumpRenderApp(tester, const InsightsScreen(), size: const Size(360, 780));
        expect(caughtOverflow, isNull);
      } finally {
        FlutterError.onError = originalOnError;
        await tearDownRenderTest(tester);
      }
    });

    testWidgets('5. Light, Dark, and OLED theme modes render cleanly', (tester) async {
      // Light Mode
      await pumpRenderApp(tester, const TodayScreen(), mode: AppThemeMode.light);
      expect(find.byType(TodayScreen), findsOneWidget);

      // Dark Mode
      await pumpRenderApp(tester, const TodayScreen(), mode: AppThemeMode.dark);
      expect(find.byType(TodayScreen), findsOneWidget);

      // OLED True Black Mode
      await pumpRenderApp(tester, const TodayScreen(), mode: AppThemeMode.oled);
      expect(find.byType(TodayScreen), findsOneWidget);

      await tearDownRenderTest(tester);
    });

    testWidgets('6. Reduce Transparency and High Contrast fallbacks render without error', (tester) async {
      await pumpRenderApp(
        tester,
        const TasksScreen(),
        additionalOverrides: [
          reduceTransparencyProvider.overrideWith(_TrueReduceTransparencyNotifier.new),
        ],
      );
      expect(find.byType(TasksScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await pumpRenderApp(
        tester,
        const TodayScreen(),
        highContrast: true,
      );
      expect(find.byType(TodayScreen), findsOneWidget);

      await tearDownRenderTest(tester);
    });
  });
}
