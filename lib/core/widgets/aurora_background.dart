import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';

/// Plain system background wrapper for dark, light, and OLED modes.
class AuroraBackground extends ConsumerWidget {
  final Widget child;

  const AuroraBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeMode mode = ref.watch(appThemeModeProvider);

    final Color bgColor;
    switch (mode) {
      case AppThemeMode.light:
        bgColor = PoswalColors.mist;
      case AppThemeMode.dark:
        bgColor = PoswalColors.ink;
      case AppThemeMode.oled:
        bgColor = PoswalColors.oled;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: child,
    );
  }
}
