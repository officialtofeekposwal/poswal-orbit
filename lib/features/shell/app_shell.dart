import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/features/habits/presentation/habit_form_sheet.dart';
import 'package:poswal_orbit/features/habits/presentation/habits_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/note_editor_screen.dart';
import 'package:poswal_orbit/features/notes/presentation/notes_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/tasks_screen.dart';
import 'package:poswal_orbit/features/tasks/presentation/widgets/task_quick_add_sheet.dart';
import 'package:poswal_orbit/features/today/presentation/today_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

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

  Widget _buildPlaceholderScreen(String title, String phase) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PoswalSpacing.xl),
        child: AppGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  gradient: PoswalGradients.aurora,
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsRegular.sparkle, color: Colors.white, size: 28),
              ),
              const SizedBox(height: PoswalSpacing.md),
              Text(
                title,
                style: PoswalText.title.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: PoswalSpacing.xs),
              Text(
                'Coming in $phase of Poswal Orbit.',
                textAlign: TextAlign.center,
                style: PoswalText.callout.copyWith(color: textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Screen View
          IndexedStack(
            index: _currentIndex,
            children: [
              const TodayScreen(),
              const HabitsScreen(),
              const TasksScreen(),
              const NotesScreen(),
              _buildPlaceholderScreen('Productivity Insights', 'Phase 5'),
            ],
          ),

          // Floating Glass Tab Bar + FAB
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
