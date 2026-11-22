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
    final lockState = ref.watch(biometricLockProvider);
    final isAuthenticating = lockState.isAuthenticating || _isAuthenticating;
    final lastResult = lockState.lastAuthResult;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
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
                        onPressed: isAuthenticating ? null : _triggerAuth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isAuthenticating) ...[
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
                      onPressed: isAuthenticating ? null : _triggerAuth,
                      icon: Icon(PhosphorIconsRegular.password, size: 16, color: textMuted),
                      label: Text(
                        l10n?.unlockWithPasscode ?? 'Use Device Passcode',
                        style: PoswalText.caption.copyWith(color: textMuted, fontWeight: FontWeight.w600),
                      ),
                    ),

                    // Detailed error banner if authentication failed or has issue
                    if (lastResult != null && !lastResult.isSuccess) ...[
                      const SizedBox(height: PoswalSpacing.lg),
                      Container(
                        key: const ValueKey('auth_error_container'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(PoswalSpacing.md),
                        decoration: BoxDecoration(
                          color: (lastResult.isHardwareUnavailable
                                  ? PoswalColors.danger
                                  : PoswalColors.warning)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(PoswalRadii.card),
                          border: Border.all(
                            color: (lastResult.isHardwareUnavailable
                                    ? PoswalColors.danger
                                    : PoswalColors.warning)
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  lastResult.isHardwareUnavailable
                                      ? PhosphorIconsRegular.shieldWarning
                                      : PhosphorIconsRegular.warningCircle,
                                  size: 18,
                                  color: lastResult.isHardwareUnavailable
                                      ? PoswalColors.danger
                                      : PoswalColors.warning,
                                ),
                                const SizedBox(width: PoswalSpacing.xs),
                                Expanded(
                                  child: Text(
                                    lastResult.errorMessage ?? 'Authentication failed',
                                    style: PoswalText.caption.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (lastResult.errorCode != null) ...[
                              const SizedBox(height: PoswalSpacing.xs),
                              Text(
                                'Error code: ${lastResult.errorCode}',
                                style: PoswalText.caption.copyWith(
                                  color: textMuted,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Emergency Safe-Disable Action: Allowed ONLY if authentication cannot work on this phone
                    if (lastResult?.isHardwareUnavailable == true || !lockState.isDeviceSupported) ...[
                      const SizedBox(height: PoswalSpacing.md),
                      TextButton.icon(
                        key: const ValueKey('emergency_disable_lock_btn'),
                        onPressed: () => _showEmergencyDisableDialog(context, l10n),
                        icon: const Icon(PhosphorIconsRegular.shieldSlash, size: 16, color: PoswalColors.danger),
                        label: Text(
                          l10n?.emergencyDisableLock ?? 'Turn off App Lock (Hardware Unavailable)',
                          style: PoswalText.caption.copyWith(
                            color: PoswalColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEmergencyDisableDialog(BuildContext context, AppLocalizations? l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoswalColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.card)),
        title: Text(
          l10n?.disableLockDialogTitle ?? 'Disable App Lock?',
          style: PoswalText.title.copyWith(color: PoswalColors.danger),
        ),
        content: Text(
          l10n?.disableLockDialogMessage ??
              'Device authentication is not available or not enrolled on this phone. Do you want to disable App Lock to access your data?',
          style: PoswalText.bodyText.copyWith(color: PoswalColors.textMutedDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel', style: PoswalText.callout.copyWith(color: PoswalColors.textMutedDark)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PoswalColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.emergencyDisableLock ?? 'Turn Off', style: PoswalText.callout.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(biometricLockProvider.notifier).emergencyDisableLock();
    }
  }
}
