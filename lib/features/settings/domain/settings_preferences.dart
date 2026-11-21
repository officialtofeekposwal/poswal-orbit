import 'package:flutter/material.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';

enum ThemeModeOption {
  system('System', 'Match OS light/dark mode'),
  light('Light', 'Clean glass on bright backdrop'),
  dark('Dark', 'Deep space glass aesthetic'),
  oled('OLED', 'Pure pitch black for battery saving');

  final String label;
  final String description;
  const ThemeModeOption(this.label, this.description);
}

enum AccentColorOption {
  teal('Teal', PoswalColors.teal),
  coral('Coral', PoswalColors.coral),
  violet('Violet', PoswalColors.violet),
  gold('Gold', PoswalColors.gold),
  mint('Mint', PoswalColors.success);

  final String label;
  final Color color;
  const AccentColorOption(this.label, this.color);
}

enum AppLanguageOption {
  system('System', 'System (Auto)', null),
  en('English', 'English', Locale('en')),
  hi('हिन्दी', 'Hindi', Locale('hi')),
  ur('اردو', 'Urdu', Locale('ur'));

  final String label;
  final String nativeName;
  final Locale? locale;
  const AppLanguageOption(this.label, this.nativeName, this.locale);

  bool get isRtl => this == AppLanguageOption.ur;
}

class AppSettingsState {
  final ThemeModeOption themeMode;
  final AccentColorOption accent;
  final AppLanguageOption language;
  final double glassIntensity;
  final bool reduceTransparency;
  final int dayStartHour;
  final int firstDayOfWeek; // 1 = Monday, 7 = Sunday
  final bool hapticsEnabled;

  const AppSettingsState({
    this.themeMode = ThemeModeOption.dark,
    this.accent = AccentColorOption.teal,
    this.language = AppLanguageOption.system,
    this.glassIntensity = 0.8,
    this.reduceTransparency = false,
    this.dayStartHour = 4,
    this.firstDayOfWeek = DateTime.monday,
    this.hapticsEnabled = true,
  });

  AppSettingsState copyWith({
    ThemeModeOption? themeMode,
    AccentColorOption? accent,
    AppLanguageOption? language,
    double? glassIntensity,
    bool? reduceTransparency,
    int? dayStartHour,
    int? firstDayOfWeek,
    bool? hapticsEnabled,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      language: language ?? this.language,
      glassIntensity: glassIntensity ?? this.glassIntensity,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'accent': accent.name,
    'language': language.name,
    'glassIntensity': glassIntensity,
    'reduceTransparency': reduceTransparency,
    'dayStartHour': dayStartHour,
    'firstDayOfWeek': firstDayOfWeek,
    'hapticsEnabled': hapticsEnabled,
  };

  factory AppSettingsState.fromJson(Map<String, dynamic> json) {
    return AppSettingsState(
      themeMode: ThemeModeOption.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeModeOption.dark,
      ),
      accent: AccentColorOption.values.firstWhere(
        (e) => e.name == json['accent'],
        orElse: () => AccentColorOption.teal,
      ),
      language: AppLanguageOption.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => AppLanguageOption.system,
      ),
      glassIntensity: (json['glassIntensity'] as num?)?.toDouble() ?? 0.8,
      reduceTransparency: json['reduceTransparency'] as bool? ?? false,
      dayStartHour: json['dayStartHour'] as int? ?? 4,
      firstDayOfWeek: json['firstDayOfWeek'] as int? ?? DateTime.monday,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }
}
