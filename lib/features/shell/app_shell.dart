import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/widgets/app_tab_bar.dart';
import 'package:poswal_orbit/data/services/data_safety_service.dart';
import 'package:poswal_orbit/data/services/notification_service.dart';
import 'package:poswal_orbit/features/habits/presentation/habits_screen.dart';
import 'package:poswal_orbit/features/insights/presentation/insights_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/notes_screen.dart';
import 'package:poswal_orbit/features/onboarding/application/onboarding_providers.dart';
import 'package:poswal_orbit/features/onboarding/presentation/onboarding_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/tasks_screen.dart';
import 'package:poswal_orbit/features/today/presentation/today_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(dataSafetyServiceProvider).runDailyBackupOnLaunch();
      } catch (_) {}
      try {
        ref.read(notificationServiceProvider).refillRollingWindow();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        ref.read(notificationServiceProvider).refillRollingWindow();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingDone = ref.watch(onboardingCompletedProvider);
    if (!onboardingDone) {
      return const OnboardingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Content Layer: Indexed Screen Views
          IndexedStack(
            index: _currentIndex,
            children: const [
              TodayScreen(),
              HabitsScreen(),
              TasksScreen(),
              NotesScreen(),
              InsightsScreen(),
            ],
          ),

          // 2. Navigation Layer: Floating Glass Tab Bar (HIG Rule 5: Navigation Only)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppTabBar(
              currentIndex: _currentIndex,
              onTabSelected: (index) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
