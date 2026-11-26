import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/data/services/notification_service.dart';
import 'package:poswal_orbit/domain/models/notification_models.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class RemindersHealthCheckScreen extends ConsumerStatefulWidget {
  const RemindersHealthCheckScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RemindersHealthCheckScreen()),
    );
  }

  @override
  ConsumerState<RemindersHealthCheckScreen> createState() => _RemindersHealthCheckScreenState();
}

class _RemindersHealthCheckScreenState extends ConsumerState<RemindersHealthCheckScreen> {
  bool _isLoading = true;
  NotificationPermissionStatus? _status;
  int _pendingCount = 0;
  bool _isSendingTest = false;

  @override
  void initState() {
    super.initState();
    _loadHealthStatus();
  }

  Future<void> _loadHealthStatus() async {
    setState(() => _isLoading = true);
    final service = ref.read(notificationServiceProvider);
    await service.initialize();

    final status = await service.checkPermissionStatus();

    int pending = 0;
    try {
      final list = await service.plugin.pendingNotificationRequests();
      pending = list.length;
    } catch (_) {}

    if (mounted) {
      setState(() {
        _status = status;
        _pendingCount = pending;
        _isLoading = false;
      });
    }
  }

  Future<void> _openSystemNotificationSettings() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidImpl = ref
          .read(notificationServiceProvider)
          .plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.openAppNotificationSettings();
    }
    // Refresh after returning from settings
    await Future.delayed(PoswalDurations.medium);
    await _loadHealthStatus();
  }

  Future<void> _requestExactAlarms() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidImpl = ref
          .read(notificationServiceProvider)
          .plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestExactAlarmsPermission();
    }
    await Future.delayed(PoswalDurations.medium);
    await _loadHealthStatus();
  }

  Future<void> _sendTest() async {
    setState(() => _isSendingTest = true);
    final l10n = AppLocalizations.of(context);
    final service = ref.read(notificationServiceProvider);
    await service.sendTestNotification(
      title: l10n?.testNotificationTitle,
      body: l10n?.testNotificationBody,
    );

    if (mounted) {
      setState(() => _isSendingTest = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PoswalColors.surfaceDark,
          content: Text(
            l10n?.testNotificationSent ?? 'Test notification sent. Check your shade and test "Mark Done" or "Snooze 10m".',
            style: PoswalText.caption.copyWith(color: PoswalColors.teal),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _refillWindow() async {
    setState(() => _isLoading = true);
    final service = ref.read(notificationServiceProvider);
    final count = await service.refillRollingWindow();
    await _loadHealthStatus();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PoswalColors.surfaceDark,
          content: Text(
            'Refilled 7-day schedule with $count active triggers.',
            style: PoswalText.caption.copyWith(color: PoswalColors.teal),
          ),
        ),
      );
    }
  }

  void _showBatteryGuideDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoswalColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.card)),
        title: Text(l10n?.samsungGuideTitle ?? 'Samsung One UI Battery Guide', style: PoswalText.title.copyWith(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.samsungGuideIntro ?? 'Samsung phones aggressively close background apps to preserve battery. To prevent missing habit streaks:',
              style: PoswalText.bodyText.copyWith(color: PoswalColors.textSecondaryDark),
            ),
            const SizedBox(height: PoswalSpacing.md),
            _guideStep('1', 'Go to phone Settings → Apps → Poswal Orbit.'),
            const SizedBox(height: PoswalSpacing.xs),
            _guideStep('2', 'Tap on Battery.'),
            const SizedBox(height: PoswalSpacing.xs),
            _guideStep('3', 'Select "Unrestricted" (instead of Optimized).'),
            const SizedBox(height: PoswalSpacing.xs),
            _guideStep('4', 'Under Alarms & reminders, ensure "Allowed" is ON.'),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PoswalColors.teal),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.understood ?? 'Understood', style: PoswalText.callout.copyWith(color: PoswalColors.ink)),
          ),
        ],
      ),
    );
  }

  Widget _guideStep(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: PoswalColors.teal,
            shape: BoxShape.circle,
          ),
          child: Text(num, style: PoswalText.caption2.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: PoswalSpacing.sm),
        Expanded(child: Text(text, style: PoswalText.caption.copyWith(color: Colors.white))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.caretLeft, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.remindersHealthCheckTitle ?? 'Reminders Health Check',
          style: PoswalText.title.copyWith(color: textPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PoswalColors.teal))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md, vertical: PoswalSpacing.sm),
              children: [
                Text(
                  l10n?.remindersHealthCheckSubtitle ?? 'Verify system permissions and Samsung One UI background rules to ensure 100% reliable streak reminders.',
                  style: PoswalText.bodyText.copyWith(color: textMuted),
                ),
                const SizedBox(height: PoswalSpacing.lg),

                // Card 1: Notification Permission
                _buildCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(PhosphorIconsRegular.bell, color: PoswalColors.teal, size: 20),
                              const SizedBox(width: PoswalSpacing.sm),
                              Text(l10n?.notificationPermissionTitle ?? 'Notification Permission', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          _buildBadge(_status?.notificationsGranted == true, l10n),
                        ],
                      ),
                      const SizedBox(height: PoswalSpacing.xs),
                      Text(
                        l10n?.notificationPermissionSubtitle ?? 'Allows Poswal Orbit to display alerts in your status bar and lock screen.',
                        style: PoswalText.caption.copyWith(color: textMuted),
                      ),
                      const SizedBox(height: PoswalSpacing.sm),
                      OutlinedButton.icon(
                        key: const ValueKey('open_notification_settings_btn'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                        ),
                        onPressed: _openSystemNotificationSettings,
                        icon: const Icon(PhosphorIconsRegular.gear, size: 16, color: Colors.white),
                        label: Text(l10n?.openNotificationSettings ?? 'Open Notification Settings', style: PoswalText.caption.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: PoswalSpacing.md),

                // Card 2: Exact Alarm Permission
                _buildCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(PhosphorIconsRegular.clockAfternoon, color: PoswalColors.gold, size: 20),
                              const SizedBox(width: PoswalSpacing.sm),
                              Text(l10n?.exactAlarmSchedulingTitle ?? 'Exact Alarm Scheduling', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          _buildBadge(_status?.exactAlarmsAllowed == true, l10n),
                        ],
                      ),
                      const SizedBox(height: PoswalSpacing.xs),
                      Text(
                        l10n?.exactAlarmSchedulingSubtitle ?? 'Allows reminders to fire at the exact minute rather than being batched or delayed by Android battery management.',
                        style: PoswalText.caption.copyWith(color: textMuted),
                      ),
                      const SizedBox(height: PoswalSpacing.sm),
                      OutlinedButton.icon(
                        key: const ValueKey('request_exact_alarms_btn'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                        ),
                        onPressed: _requestExactAlarms,
                        icon: const Icon(PhosphorIconsRegular.shieldCheck, size: 16, color: Colors.white),
                        label: Text(l10n?.manageAlarmPermission ?? 'Manage Alarm Permission', style: PoswalText.caption.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: PoswalSpacing.md),

                // Card 3: Samsung One UI Battery Optimization
                _buildCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(PhosphorIconsRegular.batteryCharging, color: PoswalColors.violet, size: 20),
                          const SizedBox(width: PoswalSpacing.sm),
                          Text(l10n?.samsungBatteryExemptionTitle ?? 'Samsung Battery Exemption', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: PoswalSpacing.xs),
                      Text(
                        l10n?.samsungBatteryExemptionSubtitle ?? 'One UI automatically sleeps apps not used for a few days. Exempting Orbit guarantees streak prompts survive.',
                        style: PoswalText.caption.copyWith(color: textMuted),
                      ),
                      const SizedBox(height: PoswalSpacing.sm),
                      OutlinedButton.icon(
                        key: const ValueKey('battery_guide_btn'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                        ),
                        onPressed: _showBatteryGuideDialog,
                        icon: const Icon(PhosphorIconsRegular.info, size: 16, color: Colors.white),
                        label: Text(l10n?.howToSetUnrestricted ?? 'How to set "Unrestricted"', style: PoswalText.caption.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: PoswalSpacing.md),

                // Card 4: Rolling Window Status
                _buildCard(
                  isDark: isDark,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(PoswalSpacing.xs),
                        decoration: BoxDecoration(
                          color: PoswalColors.teal.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(PhosphorIconsRegular.calendarCheck, color: PoswalColors.teal, size: 20),
                      ),
                      const SizedBox(width: PoswalSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n?.rollingWindowStatusTitle ?? 'Rolling 7-Day Window', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                            Text(l10n?.rollingWindowStatusSubtitle(_pendingCount) ?? '$_pendingCount scheduled reminders active in OS queue.', style: PoswalText.caption.copyWith(color: textMuted)),
                          ],
                        ),
                      ),
                      TextButton(
                        key: const ValueKey('refill_schedule_btn'),
                        onPressed: _refillWindow,
                        child: Text(l10n?.refillBtn ?? 'Refill', style: PoswalText.caption.copyWith(color: PoswalColors.teal, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: PoswalSpacing.lg),

                // Card 5: Send Test Notification
                FilledButton.icon(
                  key: const ValueKey('send_test_notification_btn'),
                  style: FilledButton.styleFrom(
                    backgroundColor: PoswalColors.teal,
                    padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                  ),
                  onPressed: _isSendingTest ? null : _sendTest,
                  icon: _isSendingTest
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: PoswalColors.ink))
                      : const Icon(PhosphorIconsRegular.paperPlaneTilt, color: PoswalColors.ink),
                  label: Text(
                    _isSendingTest ? (l10n?.dispatching ?? 'Dispatching...') : (l10n?.sendTestNotificationBtn ?? 'Send Test Notification'),
                    style: PoswalText.callout.copyWith(color: PoswalColors.ink, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: PoswalSpacing.xl),
              ],
            ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(PoswalSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
        borderRadius: BorderRadius.circular(PoswalRadii.card),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.06),
          width: 1.0,
        ),
      ),
      child: child,
    );
  }

  Widget _buildBadge(bool isGranted, AppLocalizations? l10n) {
    final color = isGranted ? PoswalColors.teal : PoswalColors.danger;
    final label = isGranted ? (l10n?.granted ?? 'Granted') : (l10n?.restricted ?? 'Restricted');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(PoswalRadii.chip),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: PoswalText.caption2.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
