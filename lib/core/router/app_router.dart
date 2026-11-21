import 'package:go_router/go_router.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_detail_screen.dart';
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
      path: '/habit/:id',
      name: 'habit_detail',
      builder: (context, state) {
        final habitId = state.pathParameters['id'] ?? '';
        return HabitDetailScreen(habitId: habitId);
      },
    ),
    GoRoute(
      path: '/playground',
      name: 'playground',
      builder: (context, state) => const DesignPlaygroundScreen(),
    ),
  ],
);
