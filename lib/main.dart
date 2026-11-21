import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/router/app_router.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge system chrome
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(
    const ProviderScope(
      child: PoswalOrbitApp(),
    ),
  );
}

class PoswalOrbitApp extends ConsumerWidget {
  const PoswalOrbitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'Poswal Orbit',
      debugShowCheckedModeBanner: false,
      theme: PoswalTheme.getTheme(mode),
      routerConfig: appRouter,
    );
  }
}
