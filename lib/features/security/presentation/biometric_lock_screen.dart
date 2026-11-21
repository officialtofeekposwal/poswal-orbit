import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/features/security/application/biometric_lock_providers.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Auto prompt authentication when lock screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAuth();
    });
  }

  Future<void> _triggerAuth() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      unawaited(HapticFeedback.lightImpact());
      final success = await ref.read(biometricLockProvider.notifier).authenticate();
      if (mounted && !success) {
        unawaited(HapticFeedback.selectionClick());
      }
    } catch (_) {
      // Ignore vibration / platform errors in headless tests
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.xl),
              child: AppGlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: PoswalSpacing.xl,
                  vertical: PoswalSpacing.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand / Security Icon with breathing aura glow
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PoswalColors.teal.withValues(alpha: 0.15),
                        border: Border.all(
                          color: PoswalColors.teal.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: PoswalColors.teal.withValues(alpha: 0.25),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          PhosphorIconsRegular.fingerprint,
                          size: 42,
                          color: PoswalColors.teal,
                        ),
                      ),
                    ),
                    const SizedBox(height: PoswalSpacing.xl),

                    // App Title
                    Text(
                      l10n?.appTitle ?? 'Poswal Orbit',
                      style: PoswalText.largeTitle.copyWith(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: PoswalSpacing.xs),

                    // Calm Security Subtitle
                    Text(
                      l10n?.unlockPrompt ?? 'Unlock Poswal Orbit to view your habits and notes',
                      textAlign: TextAlign.center,
                      style: PoswalText.callout.copyWith(color: textMuted),
                    ),
                    const SizedBox(height: PoswalSpacing.xxl),

                    // Primary Unlock Button
                    SizedBox(
                      width: double.infinity,
                      child: AppGlassButton(
                        key: const ValueKey('biometric_unlock_btn'),
                        isPrimary: true,
                        padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.md),
                        onPressed: _isAuthenticating ? null : _triggerAuth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isAuthenticating) ...[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              const SizedBox(width: PoswalSpacing.sm),
                            ] else ...[
                              const Icon(PhosphorIconsRegular.lockKeyOpen, size: 18, color: Colors.white),
                              const SizedBox(width: PoswalSpacing.sm),
                            ],
                            Text(
                              l10n?.unlockWithBiometrics ?? 'Unlock with Biometrics',
                              style: PoswalText.headline.copyWith(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: PoswalSpacing.md),

                    // Device Passcode Fallback Option
                    TextButton.icon(
                      key: const ValueKey('passcode_fallback_btn'),
                      onPressed: _isAuthenticating ? null : _triggerAuth,
                      icon: Icon(PhosphorIconsRegular.password, size: 16, color: textMuted),
                      label: Text(
                        l10n?.unlockWithPasscode ?? 'Use Device Passcode',
                        style: PoswalText.caption.copyWith(color: textMuted, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
