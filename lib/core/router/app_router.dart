import 'package:go_router/go_router.dart';
import 'package:poswal_orbit/features/playground/presentation/design_playground_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'playground',
      builder: (context, state) => const DesignPlaygroundScreen(),
    ),
  ],
);
