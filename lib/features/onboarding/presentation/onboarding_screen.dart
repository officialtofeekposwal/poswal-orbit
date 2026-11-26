import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_background.dart';
import 'package:poswal_orbit/core/widgets/poswal_orbit_ring.dart';
import 'package:poswal_orbit/data/vault/vault_providers.dart';
import 'package:poswal_orbit/features/onboarding/application/onboarding_providers.dart';
import 'package:poswal_orbit/features/settings/presentation/vault_flow.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    unawaited(HapticFeedback.selectionClick());
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: PoswalDurations.sheet,
        curve: PoswalCurves.standard,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    unawaited(HapticFeedback.mediumImpact());
    ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
  }

  Future<void> _connectVault() async {
    final connected = await runVaultConnectFlow(context, ref);
    if (connected && mounted) {
      await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Skip Button
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: PoswalSpacing.lg,
                  end: PoswalSpacing.lg,
                  top: PoswalSpacing.md,
                ),
                child: Row(
                  children: [
                    if (vaultSupported)
                      TextButton.icon(
                        key: const ValueKey('onboarding_connect_vault_btn'),
                        onPressed: _connectVault,
                        icon: const Icon(PhosphorIconsRegular.folderOpen, size: 20, color: PoswalColors.teal),
                        label: Text(
                          'Connect existing vault',
                          style: PoswalText.callout.copyWith(
                            color: PoswalColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (_currentPage < 2)
                      Semantics(
                        button: true,
                        label: l10n?.skip ?? 'Skip',
                        child: TextButton(
                          key: const ValueKey('onboarding_skip_btn'),
                          style: TextButton.styleFrom(
                            splashFactory: InkRipple.splashFactory,
                            minimumSize: const Size(48, 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: PoswalSpacing.md,
                              vertical: PoswalSpacing.sm,
                            ),
                          ),
                          onPressed: _finishOnboarding,
                          child: Text(
                            l10n?.skip ?? 'Skip',
                            style: PoswalText.callout.copyWith(
                              color: textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 48),
                  ],
                ),
              ),

              // Main Page View (3 Walkthrough Pages)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    // Page 1: Habits & Momentum
                    _buildPage(
                      context: context,
                      heroVisual: _buildHabitsVisual(),
                      title: l10n?.onboardingHabitsTitle ?? 'Build Lasting Momentum',
                      description: l10n?.onboardingHabitsDesc ??
                          'Track daily rhythm with beautiful orbit rings, streaks, and zero guilt.',
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),

                    // Page 2: Tasks & Action
                    _buildPage(
                      context: context,
                      heroVisual: _buildTasksVisual(isDark, l10n),
                      title: l10n?.onboardingTasksTitle ?? 'Calm, Focused Action',
                      description: l10n?.onboardingTasksDesc ??
                          'Smart lists, natural language due dates, and simple checklists keep you clear.',
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),

                    // Page 3: Notes & Journal
                    _buildPage(
                      context: context,
                      heroVisual: _buildNotesVisual(isDark),
                      title: l10n?.onboardingNotesTitle ?? 'Private Thoughts & Journal',
                      description: l10n?.onboardingNotesDesc ??
                          'Markdown notes and daily journals stored safely on your device only.',
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                    ),
                  ],
                ),
              ),

              // Bottom Navigation & Page Indicators
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PoswalSpacing.xl,
                  vertical: PoswalSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: PoswalDurations.standard,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? PoswalColors.teal
                                : (isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(PoswalRadii.pill),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: PoswalSpacing.xl),

                    // Primary Action Button (Next / Get Started) - HIG Solid Capsule CTA
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        key: const ValueKey('onboarding_next_btn'),
                        style: FilledButton.styleFrom(
                          backgroundColor: PoswalColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PoswalRadii.capsule),
                          ),
                          elevation: 0,
                          splashFactory: InkRipple.splashFactory,
                        ),
                        onPressed: _nextPage,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == 2
                                  ? (l10n?.getStarted ?? 'Get Started')
                                  : (l10n?.next ?? 'Next'),
                              style: PoswalText.callout.copyWith(
                                color: PoswalColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: PoswalSpacing.xs),
                            const Icon(
                              PhosphorIconsRegular.caretRight,
                              color: PoswalColors.ink,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required Widget heroVisual,
    required String title,
    required String description,
    required Color textPrimary,
    required Color textMuted,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            heroVisual,
            const SizedBox(height: PoswalSpacing.xxl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: PoswalText.title1.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: PoswalSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: PoswalText.callout.copyWith(
                color: textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsVisual() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: PoswalColors.teal.withValues(alpha: 0.25),
                blurRadius: 36,
                spreadRadius: 8,
              ),
            ],
          ),
        ),
        const PoswalOrbitRing(
          progress: 0.8,
          size: 160,
          strokeWidth: 14,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsRegular.fire, color: PoswalColors.gold, size: 32),
            const SizedBox(height: 4),
            Text(
              '80%',
              style: PoswalText.headline.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTasksVisual(bool isDark, AppLocalizations? l10n) {
    return AppGlassCard(
      padding: const EdgeInsets.all(PoswalSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.checkCircle, color: PoswalColors.teal, size: 22),
              const SizedBox(width: PoswalSpacing.sm),
              Expanded(
                child: Text(
                  'Review morning rhythm',
                  style: PoswalText.callout.copyWith(
                    color: isDark ? Colors.white : PoswalColors.textOnLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: PoswalColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(PoswalRadii.chip),
                ),
                child: Text(l10n?.tabToday ?? 'Today', style: PoswalText.caption2.copyWith(color: PoswalColors.teal, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.md),
          Row(
            children: [
              const Icon(PhosphorIconsRegular.circle, color: Colors.white38, size: 22),
              const SizedBox(width: PoswalSpacing.sm),
              Expanded(
                child: Text(
                  '30-minute deep focus sprint',
                  style: PoswalText.callout.copyWith(
                    color: isDark ? Colors.white70 : PoswalColors.textSecondaryLight,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: PoswalColors.coral,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesVisual(bool isDark) {
    return AppGlassCard(
      padding: const EdgeInsets.all(PoswalSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.notebook, color: PoswalColors.violet, size: 22),
              const SizedBox(width: PoswalSpacing.sm),
              Text(
                'Daily Journal',
                style: PoswalText.callout.copyWith(
                  color: isDark ? Colors.white : PoswalColors.textOnLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(PhosphorIconsRegular.lockSimple, color: PoswalColors.teal, size: 16),
            ],
          ),
          const SizedBox(height: PoswalSpacing.sm),
          Text(
            'Calm thoughts recorded with zero cloud servers. 100% private to your device.',
            style: PoswalText.caption.copyWith(
              color: isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
