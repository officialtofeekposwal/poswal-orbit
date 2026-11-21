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
  static ThemeData getTheme(AppThemeMode mode) {
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
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
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
      fontFamily: PoswalText.body,
      textTheme: TextTheme(
        displayLarge: PoswalText.largeTitle.copyWith(color: textPrimary),
        displayMedium: PoswalText.title.copyWith(color: textPrimary),
        titleLarge: PoswalText.headline.copyWith(color: textPrimary),
        bodyLarge: PoswalText.bodyText.copyWith(color: textPrimary),
        bodyMedium: PoswalText.callout.copyWith(color: textPrimary),
        bodySmall: PoswalText.caption.copyWith(color: textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: PoswalText.headline.copyWith(color: textPrimary),
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
