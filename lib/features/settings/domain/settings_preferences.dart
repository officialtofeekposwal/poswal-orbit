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

class AppSettingsState {
  final ThemeModeOption themeMode;
  final AccentColorOption accent;
  final double glassIntensity;
  final bool reduceTransparency;
  final int dayStartHour;
  final int firstDayOfWeek; // 1 = Monday, 7 = Sunday
  final bool hapticsEnabled;

  const AppSettingsState({
    this.themeMode = ThemeModeOption.dark,
    this.accent = AccentColorOption.teal,
    this.glassIntensity = 0.8,
    this.reduceTransparency = false,
    this.dayStartHour = 4,
    this.firstDayOfWeek = DateTime.monday,
    this.hapticsEnabled = true,
  });

  AppSettingsState copyWith({
    ThemeModeOption? themeMode,
    AccentColorOption? accent,
    double? glassIntensity,
    bool? reduceTransparency,
    int? dayStartHour,
    int? firstDayOfWeek,
    bool? hapticsEnabled,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
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
      glassIntensity: (json['glassIntensity'] as num?)?.toDouble() ?? 0.8,
      reduceTransparency: json['reduceTransparency'] as bool? ?? false,
      dayStartHour: json['dayStartHour'] as int? ?? 4,
      firstDayOfWeek: json['firstDayOfWeek'] as int? ?? DateTime.monday,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }
}
