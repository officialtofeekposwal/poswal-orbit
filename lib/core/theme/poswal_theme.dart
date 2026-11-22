import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';

enum AppThemeMode {
  light,
  dark,
  oled;

  bool get isDark => this == AppThemeMode.dark || this == AppThemeMode.oled;
  bool get isOled => this == AppThemeMode.oled;
  bool get isLight => this == AppThemeMode.light;
}

class AppThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => AppThemeMode.dark;

  void setMode(AppThemeMode mode) => state = mode;
}

final appThemeModeProvider = NotifierProvider<AppThemeNotifier, AppThemeMode>(AppThemeNotifier.new);

class PoswalTheme {
  static ThemeData getTheme(AppThemeMode mode, {String? languageCode}) {
    switch (mode) {
      case AppThemeMode.light:
        return _buildTheme(
          brightness: Brightness.light,
          background: PoswalColors.mist,
          surface: PoswalColors.surfaceLight,
          surfaceSecondary: const Color(0xFFEBEFF7),
          textPrimary: PoswalColors.textOnLight,
          textMuted: PoswalColors.textMutedLight,
          border: Colors.black.withValues(alpha: 0.08),
          languageCode: languageCode,
        );
      case AppThemeMode.dark:
        return _buildTheme(
          brightness: Brightness.dark,
          background: PoswalColors.ink,
          surface: PoswalColors.surfaceDark,
          surfaceSecondary: PoswalColors.surfaceDark2,
          textPrimary: PoswalColors.textOnDark,
          textMuted: PoswalColors.textMutedDark,
          border: Colors.white.withValues(alpha: 0.10),
          languageCode: languageCode,
        );
      case AppThemeMode.oled:
        return _buildTheme(
          brightness: Brightness.dark,
          background: PoswalColors.oled,
          surface: const Color(0xFF080C14),
          surfaceSecondary: const Color(0xFF101522),
          textPrimary: PoswalColors.textOnDark,
          textMuted: PoswalColors.textMutedDark,
          border: Colors.white.withValues(alpha: 0.12),
          languageCode: languageCode,
        );
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceSecondary,
    required Color textPrimary,
    required Color textMuted,
    required Color border,
    String? languageCode,
  }) {
    final isDark = brightness == Brightness.dark;
    final isUrdu = languageCode == 'ur';
    final isHindi = languageCode == 'hi';

    final String headingFont = isUrdu
        ? 'NotoNastaliqUrdu'
        : (isHindi ? 'NotoSansDevanagari' : PoswalText.heading);
    final String bodyFont = isUrdu
        ? 'NotoNastaliqUrdu'
        : (isHindi ? 'NotoSansDevanagari' : PoswalText.body);

    final double urduHeightMultiplier = isUrdu ? 1.6 : 1.0;

    return ThemeData(
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: PoswalColors.teal,
        onPrimary: Colors.white,
        secondary: PoswalColors.violet,
        onSecondary: Colors.white,
        tertiary: PoswalColors.coral,
        onTertiary: Colors.white,
        error: PoswalColors.danger,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        outline: border,
      ),
      fontFamily: bodyFont,
      textTheme: TextTheme(
        displayLarge: PoswalText.localized(
          PoswalText.largeTitle.copyWith(
            color: textPrimary,
            fontFamily: headingFont,
            height: (PoswalText.largeTitle.height ?? 1.15) * urduHeightMultiplier,
          ),
          languageCode: languageCode,
        ),
        displayMedium: PoswalText.localized(
          PoswalText.title1.copyWith(
            color: textPrimary,
            fontFamily: headingFont,
            height: (PoswalText.title1.height ?? 1.2) * urduHeightMultiplier,
          ),
          languageCode: languageCode,
        ),
        displaySmall: PoswalText.localized(
          PoswalText.title.copyWith(
            color: textPrimary,
            fontFamily: headingFont,
            height: (PoswalText.title.height ?? 1.2) * urduHeightMultiplier,
          ),
          languageCode: languageCode,
        ),
        titleLarge: PoswalText.localized(
          PoswalText.headline.copyWith(
            color: textPrimary,
            fontFamily: headingFont,
            height: (PoswalText.headline.height ?? 1.3) * urduHeightMultiplier,
          ),
          languageCode: languageCode,
        ),
        titleMedium: PoswalText.localized(
          PoswalText.title3.copyWith(
            color: textPrimary,
            fontFamily: headingFont,
            height: (PoswalText.title3.height ?? 1.25) * urduHeightMultiplier,
          ),
          languageCode: languageCode,
        ),
        bodyLarge: PoswalText.localized(
          PoswalText.bodyText.copyWith(
            color: textPrimary,
            fontFamily: bodyFont,
            height: (PoswalText.bodyText.height ?? 1.4) * urduHeightMultiplier,
          ),
          languageCode: languageCode,
        ),
        bodyMedium: PoswalText.localized(
          PoswalText.callout.copyWith(
            color: textPrimary,
            fontFamily: bodyFont,
            height: (PoswalText.callout.height ?? 1.4) * urduHeightMultiplier,
          ),
          languageCode: languageCode,
        ),
        bodySmall: PoswalText.localized(
          PoswalText.caption.copyWith(
            color: textMuted,
            fontFamily: bodyFont,
            height: (PoswalText.caption.height ?? 1.3) * urduHeightMultiplier,
          ),
          languageCode: languageCode,
        ),
        labelSmall: PoswalText.localized(
          PoswalText.caption2.copyWith(
            color: textMuted,
            fontFamily: bodyFont,
            height: (PoswalText.caption2.height ?? 1.2) * urduHeightMultiplier,
          ),
          languageCode: languageCode,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: PoswalText.headline.copyWith(
          color: textPrimary,
          fontFamily: headingFont,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PoswalRadii.card),
          side: BorderSide(color: border),
        ),
      ),
    );
  }
}
