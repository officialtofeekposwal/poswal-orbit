import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/data/services/data_safety_service.dart';
import 'package:poswal_orbit/data/services/notification_service.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_form_sheet.dart';
import 'package:poswal_orbit/features/habits/presentation/habits_screen.dart';
import 'package:poswal_orbit/features/insights/presentation/insights_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/note_editor_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/notes_screen.dart';
import 'package:poswal_orbit/features/onboarding/application/onboarding_providers.dart';
import 'package:poswal_orbit/features/onboarding/presentation/onboarding_screen.dart';
import 'package:poswal_orbit/features/security/application/biometric_lock_providers.dart';
import 'package:poswal_orbit/features/security/presentation/biometric_lock_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/tasks_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_quick_add_sheet.dart';
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
    ref.read(biometricLockProvider.notifier).onAppLifecycleChanged(state);
    if (state == AppLifecycleState.resumed) {
      try {
        ref.read(notificationServiceProvider).refillRollingWindow();
      } catch (_) {}
    }
  }

  void _openCreateSheet() {
    HapticFeedback.lightImpact();
    if (_currentIndex == 2) {
      TaskQuickAddSheet.show(context);
    } else if (_currentIndex == 3) {
      NoteEditorScreen.push(context);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const HabitFormSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingDone = ref.watch(onboardingCompletedProvider);
    if (!onboardingDone) {
      return const OnboardingScreen();
    }

    final lockState = ref.watch(biometricLockProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Screen View
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

          // Floating Glass Tab Bar + FAB (shielded when locked)
          if (!lockState.isLocked)
            Positioned(
              left: PoswalSpacing.lg,
              right: PoswalSpacing.lg,
              bottom: PoswalSpacing.lg,
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // 1. Floating Glass Tab Bar
                    Expanded(
                      child: AppGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PoswalSpacing.sm,
                          vertical: PoswalSpacing.xs,
                        ),
                        borderRadius: PoswalRadii.pill,
                        child: Row(
                          children: [
                            _buildTabItem(0, PhosphorIconsRegular.circleHalfTilt, PhosphorIconsFill.circleHalfTilt, 'Today'),
                            _buildTabItem(1, PhosphorIconsRegular.target, PhosphorIconsFill.target, 'Habits'),
                            _buildTabItem(2, PhosphorIconsRegular.checkSquare, PhosphorIconsFill.checkSquare, 'Tasks'),
                            _buildTabItem(3, PhosphorIconsRegular.notepad, PhosphorIconsFill.notepad, 'Notes'),
                            _buildTabItem(4, PhosphorIconsRegular.chartLineUp, PhosphorIconsFill.chartLineUp, 'Insights'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: PoswalSpacing.sm),

                    // 2. Floating Liquid Glass '+' FAB
                    GestureDetector(
                      key: const ValueKey('app_fab_button'),
                      onTap: _openCreateSheet,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: PoswalGradients.aurora,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PoswalColors.teal.withValues(alpha: 0.40),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          PhosphorIconsBold.plus,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Biometric Lock Screen Overlay
          if (lockState.isLocked)
            const Positioned.fill(
              child: BiometricLockScreen(),
            ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 20,
                color: isSelected
                    ? PoswalColors.teal
                    : (isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: PoswalText.caption.copyWith(
                    fontSize: 10,
                    color: isSelected
                        ? PoswalColors.teal
                        : (isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
