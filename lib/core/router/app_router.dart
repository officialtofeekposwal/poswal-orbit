import 'package:go_router/go_router.dart';
import 'package:poswal_orbit/features/playground/presentation/design_playground_screen.dart';
import 'package:poswal_orbit/features/shell/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: '/playground',
      name: 'playground',
      builder: (context, state) => const DesignPlaygroundScreen(),
    ),
  ],
);
