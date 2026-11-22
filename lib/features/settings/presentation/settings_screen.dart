import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/data/services/data_safety_service.dart';
import 'package:poswal_orbit/data/services/notification_service.dart';
import 'package:poswal_orbit/domain/logic/biometric_lock_engine.dart';
import 'package:poswal_orbit/domain/models/data_safety_models.dart';
import 'package:poswal_orbit/features/security/application/biometric_lock_providers.dart';
import 'package:poswal_orbit/features/settings/application/settings_providers.dart';
import 'package:poswal_orbit/features/settings/domain/settings_preferences.dart';
import 'package:poswal_orbit/features/settings/presentation/reminders_health_check_screen.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: PoswalText.callout.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? PoswalColors.danger : PoswalColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleManualBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final file = await ref.read(dataSafetyServiceProvider).createBackup();
      ref.invalidate(availableBackupsProvider);
      unawaited(HapticFeedback.mediumImpact());
      _showToast('Backup safely saved: ${file.path.split(RegExp(r'[\\/]')).last}');
    } catch (e) {
      _showToast('Failed to create backup: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _handleRestoreBackup(BackupFileInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoswalColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.card)),
        title: Text(
          'Restore from Backup?',
          style: PoswalText.title.copyWith(color: Colors.white),
        ),
        content: Text(
          'This will replace your current data with backup from ${backup.formattedDate}.\n\nA safety snapshot of your current database will be taken immediately before restoring so nothing is lost.',
          style: PoswalText.bodyText.copyWith(color: PoswalColors.textMutedDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: PoswalText.callout.copyWith(color: PoswalColors.textMutedDark)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PoswalColors.teal),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Restore Safely', style: PoswalText.callout.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isRestoring = true);
    try {
      final res = await ref.read(dataSafetyServiceProvider).restoreFromJsonFile(backup.file);
      ref.invalidate(availableBackupsProvider);
      unawaited(HapticFeedback.heavyImpact());
      _showToast('Restored successfully (${res.habitsCount} habits, ${res.tasksCount} tasks, ${res.notesCount} notes)');
    } catch (e) {
      _showToast('Restore failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _handleDeleteAllData() async {
    final l10n = AppLocalizations.of(context);
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoswalColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.card)),
        title: Text(
          l10n?.deleteAllDataDialogTitle ?? 'Delete All Data?',
          style: PoswalText.title.copyWith(color: PoswalColors.danger),
        ),
        content: Text(
          l10n?.deleteAllDataDialogContent ?? 'This will wipe all habits, entries, tasks, and notes.\n\nA safety backup snapshot will be created automatically before wiping so you can recover if needed.',
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
            child: Text(l10n?.proceed ?? 'Proceed', style: PoswalText.callout.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (firstConfirm != true || !mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoswalColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.card)),
        title: Text(
          l10n?.finalConfirmationTitle ?? 'Final Confirmation',
          style: PoswalText.title.copyWith(color: PoswalColors.danger),
        ),
        content: Text(
          l10n?.finalConfirmationContent ?? 'Are you completely sure? This action will reset your active workspace.',
          style: PoswalText.bodyText.copyWith(color: PoswalColors.textMutedDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.keepMyData ?? 'Keep My Data', style: PoswalText.callout.copyWith(color: PoswalColors.textMutedDark)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PoswalColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.wipeEverything ?? 'Wipe Everything', style: PoswalText.callout.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (secondConfirm != true || !mounted) return;

    try {
      await ref.read(dataSafetyServiceProvider).deleteAllData();
      ref.invalidate(availableBackupsProvider);
      unawaited(HapticFeedback.heavyImpact());
      _showToast(l10n?.allDataClearedToast ?? 'All data cleared. Pre-wipe safety snapshot was preserved in backups.');
    } catch (e) {
      _showToast('Failed to clear data: $e', isError: true);
    }
  }

  void _showImportDialog() {
    final l10n = AppLocalizations.of(context);
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoswalColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.card)),
        title: Text(l10n?.importDialogTitle ?? 'Import Data / Loop CSV', style: PoswalText.title.copyWith(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.importDialogContent ?? 'Paste JSON backup content or Loop Habit Tracker CSV data below:',
                style: PoswalText.bodyText.copyWith(color: PoswalColors.textMutedDark),
              ),
              const SizedBox(height: PoswalSpacing.md),
              TextField(
                controller: textController,
                maxLines: 6,
                style: PoswalText.bodyText.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n?.importPlaceholder ?? 'Paste JSON backup or Loop CSV data...',
                  hintStyle: PoswalText.caption.copyWith(color: PoswalColors.textMutedDark),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PoswalRadii.chip),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.cancel ?? 'Cancel', style: PoswalText.callout.copyWith(color: PoswalColors.textMutedDark)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PoswalColors.teal),
            onPressed: () async {
              final content = textController.text.trim();
              if (content.isEmpty) return;
              Navigator.of(ctx).pop();
              await _processImportContent(content);
            },
            child: Text(l10n?.inspectAndImport ?? 'Inspect & Import', style: PoswalText.callout.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _processImportContent(String content) async {
    final l10n = AppLocalizations.of(context);
    final safetyService = ref.read(dataSafetyServiceProvider);
    final preview = safetyService.inspectImportContent(content);

    if (!preview.isValid) {
      _showToast(preview.validationError ?? 'Invalid file format', isError: true);
      return;
    }

    if (!mounted) return;

    // Show preview dialog before applying
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoswalColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.card)),
        title: Text(l10n?.importPreview ?? 'Import Preview', style: PoswalText.title.copyWith(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n?.importFormat(preview.format.label) ?? 'Format: ${preview.format.label}', style: PoswalText.headline.copyWith(color: PoswalColors.teal)),
            const SizedBox(height: PoswalSpacing.xs),
            Text(preview.summary, style: PoswalText.bodyText.copyWith(color: Colors.white)),
            const SizedBox(height: PoswalSpacing.md),
            Text(
              l10n?.importSafetyNote ?? 'A safety backup will be created automatically before importing to protect your current database.',
              style: PoswalText.caption.copyWith(color: PoswalColors.textMutedDark),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel', style: PoswalText.callout.copyWith(color: PoswalColors.textMutedDark)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PoswalColors.teal),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.applyImport ?? 'Apply Import', style: PoswalText.callout.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (proceed != true || !mounted) return;

    try {
      final res = preview.format == BackupFormat.csvLoop
          ? await safetyService.importLoopCsv(content)
          : await safetyService.restoreFromJsonString(content);
      ref.invalidate(availableBackupsProvider);
      unawaited(HapticFeedback.heavyImpact());
      _showToast(l10n?.importSuccessToast(res.habitsCount, res.tasksCount, res.notesCount) ?? 'Successfully imported ${res.habitsCount} habits, ${res.tasksCount} tasks, ${res.notesCount} notes');
    } catch (e) {
      _showToast('Import failed: $e', isError: true);
    }
  }

  void _showExportOptions() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppGlassCard(
        margin: const EdgeInsets.all(PoswalSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n?.settingsExport ?? 'Export Data', style: PoswalText.headline.copyWith(color: Colors.white)),
            const SizedBox(height: PoswalSpacing.sm),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.fileCode, color: PoswalColors.teal),
              title: Text(l10n?.backupFullJson ?? 'Full Database Snapshot (JSON)', style: PoswalText.callout.copyWith(color: Colors.white)),
              subtitle: Text(l10n?.backupFullJsonSubtitle ?? 'Complete portable backup with habits, tasks & notes', style: PoswalText.caption.copyWith(color: PoswalColors.textMutedDark)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final jsonStr = await ref.read(dataSafetyServiceProvider).exportFullDatabaseJson();
                await Clipboard.setData(ClipboardData(text: jsonStr));
                _showToast(l10n?.fullJsonCopiedToast(jsonStr.length) ?? 'Full JSON backup copied to clipboard (${jsonStr.length} bytes)');
              },
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.table, color: PoswalColors.success),
              title: Text(l10n?.exportHabitsCsv ?? 'Habits & Check-ins (CSV)', style: PoswalText.callout.copyWith(color: Colors.white)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final csvStr = await ref.read(dataSafetyServiceProvider).exportHabitsCsv();
                await Clipboard.setData(ClipboardData(text: csvStr));
                _showToast(l10n?.habitsCsvCopiedToast ?? 'Habits CSV copied to clipboard');
              },
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.checkSquare, color: PoswalColors.coral),
              title: Text(l10n?.exportTasksCsv ?? 'Tasks & Subtasks (CSV)', style: PoswalText.callout.copyWith(color: Colors.white)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final csvStr = await ref.read(dataSafetyServiceProvider).exportTasksCsv();
                await Clipboard.setData(ClipboardData(text: csvStr));
                _showToast(l10n?.tasksCsvCopiedToast ?? 'Tasks CSV copied to clipboard');
              },
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.note, color: PoswalColors.violet),
              title: Text(l10n?.exportNotesCsv ?? 'Notes & Journal (CSV)', style: PoswalText.callout.copyWith(color: Colors.white)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final csvStr = await ref.read(dataSafetyServiceProvider).exportNotesCsv();
                await Clipboard.setData(ClipboardData(text: csvStr));
                _showToast(l10n?.notesCsvCopiedToast ?? 'Notes CSV copied to clipboard');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAuthTestResultDialog(BuildContext context, BiometricAuthResult result, AppLocalizations? l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoswalColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.card)),
        icon: Icon(
          result.isSuccess ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.warningCircle,
          color: result.isSuccess ? PoswalColors.teal : PoswalColors.danger,
          size: 40,
        ),
        title: Text(
          result.isSuccess
              ? (l10n?.authTestSuccessTitle ?? 'Authentication Successful')
              : (l10n?.authTestFailedTitle ?? 'Authentication Failed'),
          style: PoswalText.title.copyWith(
            color: result.isSuccess ? PoswalColors.teal : PoswalColors.danger,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.isSuccess
                  ? (l10n?.authTestSuccessMessage ?? 'Biometrics and device passcode are working properly on this phone.')
                  : (result.errorMessage ?? 'Authentication could not be completed.'),
              style: PoswalText.bodyText.copyWith(color: PoswalColors.textMutedDark),
            ),
            if (!result.isSuccess && result.errorCode != null) ...[
              const SizedBox(height: PoswalSpacing.sm),
              Text(
                'Error code: ${result.errorCode}',
                style: PoswalText.caption.copyWith(
                  color: PoswalColors.textMutedDark,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: result.isSuccess ? PoswalColors.teal : PoswalColors.surfaceDark2,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK', style: PoswalText.callout.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final intensity = ref.watch(glassIntensityProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final backupsAsync = ref.watch(availableBackupsProvider);
    final lockState = ref.watch(biometricLockProvider);

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(PhosphorIconsRegular.arrowLeft, color: textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Settings',
            style: PoswalText.headline.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg, vertical: PoswalSpacing.md),
          physics: const BouncingScrollPhysics(),
          children: [
            // --- SECTION 1: APPEARANCE ---
            _buildSectionHeader('Appearance', PhosphorIconsRegular.paintBrush, textPrimary),
            const SizedBox(height: PoswalSpacing.xs),
            AppGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: PoswalSpacing.sm),
                  Wrap(
                    spacing: PoswalSpacing.sm,
                    runSpacing: PoswalSpacing.xs,
                    children: ThemeModeOption.values.map((mode) {
                      final isSelected = settings.themeMode == mode;
                      return ChoiceChip(
                        label: Text(mode.label),
                        selected: isSelected,
                        selectedColor: PoswalColors.teal.withValues(alpha: 0.3),
                        labelStyle: PoswalText.caption.copyWith(
                          color: isSelected ? PoswalColors.teal : textMuted,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (_) => settingsNotifier.updateThemeMode(mode),
                      );
                    }).toList(),
                  ),
                  const Divider(color: Colors.white12, height: 28),
                  Text('Accent Color', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: PoswalSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: AccentColorOption.values.map((accent) {
                      final isSelected = settings.accent == accent;
                      return GestureDetector(
                        onTap: () => settingsNotifier.updateAccent(accent),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: accent.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: accent.color.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)]
                                : null,
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(color: Colors.white12, height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Glass Intensity', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                      Text('${(intensity * 100).toInt()}%', style: PoswalText.caption.copyWith(color: PoswalColors.teal, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Slider(
                    value: intensity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: PoswalColors.teal,
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      ref.read(glassIntensityProvider.notifier).setIntensity(val);
                      settingsNotifier.updateGlassIntensity(val);
                    },
                  ),
                  const Divider(color: Colors.white12, height: 28),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n?.settingsReduceTransparency ?? 'Reduce Transparency', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n?.reduceTransparencySubtitle ?? 'Solid background cards for reduced GPU load or high contrast', style: PoswalText.caption.copyWith(color: textMuted)),
                    value: reduceTransparency,
                    activeColor: PoswalColors.teal,
                    onChanged: (val) {
                      ref.read(reduceTransparencyProvider.notifier).setReduce(val);
                      settingsNotifier.updateReduceTransparency(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: PoswalSpacing.lg),

            // --- SECTION 2: TIME & DAY BOUNDARY ---
            _buildSectionHeader(l10n?.settingsTime ?? 'Time & Orbit Boundary', PhosphorIconsRegular.clock, textPrimary),
            const SizedBox(height: PoswalSpacing.xs),
            AppGlassCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n?.settingsDayStart ?? 'Day-Start Boundary', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      l10n?.dayStartBoundarySubtitle ?? 'Habit check-ins before this hour count towards previous day',
                      style: PoswalText.caption.copyWith(color: textMuted),
                    ),
                    trailing: DropdownButton<int>(
                      value: settings.dayStartHour,
                      dropdownColor: PoswalColors.surfaceDark,
                      underline: const SizedBox(),
                      items: [0, 3, 4, 5, 6].map((hour) {
                        final label = hour == 0 ? '12:00 AM' : '${hour.toString().padLeft(2, '0')}:00 AM${hour == 4 ? ' (Default)' : ''}';
                        return DropdownMenuItem(
                          value: hour,
                          child: Text(label, style: PoswalText.callout.copyWith(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) settingsNotifier.updateDayStartHour(val);
                      },
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n?.settingsFirstDayOfWeek ?? 'First Day of Week', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    trailing: SegmentedButton<int>(
                      segments: [
                        ButtonSegment(value: DateTime.monday, label: Text(l10n?.mondayShort ?? 'Mon')),
                        ButtonSegment(value: DateTime.sunday, label: Text(l10n?.sundayShort ?? 'Sun')),
                      ],
                      selected: {settings.firstDayOfWeek},
                      onSelectionChanged: (set) => settingsNotifier.updateFirstDayOfWeek(set.first),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: PoswalSpacing.lg),

            // --- SECTION 3: FEEDBACK ---
            _buildSectionHeader(l10n?.settingsHaptics ?? 'Haptics & Motion', PhosphorIconsRegular.vibrate, textPrimary),
            const SizedBox(height: PoswalSpacing.xs),
            AppGlassCard(
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n?.settingsHaptics ?? 'Haptic Feedback', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                subtitle: Text(l10n?.hapticFeedbackSubtitle ?? 'Tactile vibration on habit rings, checkboxes and gestures', style: PoswalText.caption.copyWith(color: textMuted)),
                value: settings.hapticsEnabled,
                activeColor: PoswalColors.teal,
                onChanged: (val) => settingsNotifier.updateHaptics(val),
              ),
            ),

            const SizedBox(height: PoswalSpacing.lg),

            // --- SECTION: SECURITY & APP LOCK ---
            _buildSectionHeader(l10n?.securityTitle ?? 'App Lock & Security', PhosphorIconsRegular.lockKey, textPrimary),
            const SizedBox(height: PoswalSpacing.xs),
            AppGlassCard(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    key: const ValueKey('biometric_lock_toggle'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n?.biometricLock ?? 'Biometric Lock', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n?.biometricLockSubtitle ?? 'Require Face ID, fingerprint or device PIN on launch', style: PoswalText.caption.copyWith(color: textMuted)),
                    value: lockState.isEnabled,
                    activeColor: PoswalColors.teal,
                    onChanged: (val) async {
                      unawaited(HapticFeedback.selectionClick());
                      if (val) {
                        final result = await ref.read(biometricLockProvider.notifier).testAuthentication();
                        if (!context.mounted) return;
                        if (!result.isSuccess) {
                          _showAuthTestResultDialog(context, result, l10n);
                          return;
                        }
                        await ref.read(biometricLockProvider.notifier).toggleEnabled(true);
                      } else {
                        await ref.read(biometricLockProvider.notifier).toggleEnabled(false);
                      }
                    },
                  ),
                  if (lockState.isEnabled) ...[
                    const Divider(color: Colors.white12, height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n?.lockTimeout ?? 'Lock Timeout', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                      trailing: DropdownButton<LockTimeout>(
                        key: const ValueKey('lock_timeout_dropdown'),
                        value: lockState.timeout,
                        dropdownColor: PoswalColors.surfaceDark,
                        underline: const SizedBox(),
                        items: LockTimeout.values.map((t) {
                          String label = t.label;
                          if (l10n != null) {
                            switch (t) {
                              case LockTimeout.immediate:
                                label = l10n.lockTimeoutImmediate;
                                break;
                              case LockTimeout.thirtySeconds:
                                label = l10n.lockTimeout30s;
                                break;
                              case LockTimeout.oneMinute:
                                label = l10n.lockTimeout1m;
                                break;
                              case LockTimeout.fiveMinutes:
                                label = l10n.lockTimeout5m;
                                break;
                            }
                          }
                          return DropdownMenuItem(
                            value: t,
                            child: Text(label, style: PoswalText.callout.copyWith(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(biometricLockProvider.notifier).updateTimeout(val);
                          }
                        },
                      ),
                    ),
                  ],
                  const Divider(color: Colors.white12, height: 20),
                  SwitchListTile.adaptive(
                    key: const ValueKey('hide_recents_toggle'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n?.hideContentRecents ?? 'Hide in Recent Apps', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n?.hideContentRecentsSubtitle ?? 'Blurs or blocks app preview in OS task switcher', style: PoswalText.caption.copyWith(color: textMuted)),
                    value: lockState.hideContentInRecents,
                    activeColor: PoswalColors.teal,
                    onChanged: (val) {
                      unawaited(HapticFeedback.selectionClick());
                      ref.read(biometricLockProvider.notifier).toggleHideRecents(val);
                    },
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  ListTile(
                    key: const ValueKey('test_biometrics_tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(PoswalSpacing.xs),
                      decoration: BoxDecoration(
                        color: PoswalColors.teal.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(PhosphorIconsRegular.fingerprint, color: PoswalColors.teal, size: 20),
                    ),
                    title: Text(
                      l10n?.testBiometrics ?? 'Test Authentication',
                      style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      l10n?.testBiometricsSubtitle ?? 'Verify biometric hardware and device passcode on this phone',
                      style: PoswalText.caption.copyWith(color: textMuted),
                    ),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16, color: Colors.white54),
                    onTap: () async {
                      unawaited(HapticFeedback.selectionClick());
                      final result = await ref.read(biometricLockProvider.notifier).testAuthentication();
                      if (context.mounted) {
                        _showAuthTestResultDialog(context, result, l10n);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: PoswalSpacing.lg),

            // --- SECTION 4: REMINDERS & NOTIFICATIONS ---
            _buildSectionHeader(l10n?.settingsNotifications ?? 'Reminders & Notifications', PhosphorIconsRegular.bell, textPrimary),
            const SizedBox(height: PoswalSpacing.xs),
            AppGlassCard(
              child: Column(
                children: [
                  ListTile(
                    key: const ValueKey('reminders_health_check_tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(PoswalSpacing.xs),
                      decoration: BoxDecoration(
                        color: PoswalColors.teal.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(PhosphorIconsRegular.heartbeat, color: PoswalColors.teal, size: 20),
                    ),
                    title: Text(l10n?.settingsHealthCheck ?? 'Reminders Health Check', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n?.remindersHealthCheckSubtitle ?? 'Verify notification permissions, exact alarms & One UI battery rules', style: PoswalText.caption.copyWith(color: textMuted)),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16, color: Colors.white54),
                    onTap: () => RemindersHealthCheckScreen.push(context),
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('settings_send_test_notif_btn'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                          ),
                          onPressed: () async {
                            final notifService = ref.read(notificationServiceProvider);
                            await notifService.sendTestNotification();
                            if (context.mounted) {
                              _showToast('Test notification dispatched. Check your status bar!');
                            }
                          },
                          icon: const Icon(PhosphorIconsRegular.paperPlaneTilt, size: 16, color: Colors.white),
                          label: Text(l10n?.sendTestAlert ?? 'Send Test Alert', style: PoswalText.caption.copyWith(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: PoswalSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('settings_refill_schedule_btn'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                          ),
                          onPressed: () async {
                            final notifService = ref.read(notificationServiceProvider);
                            final count = await notifService.refillRollingWindow();
                            if (context.mounted) {
                              _showToast('Rolling window synced ($count reminders).');
                            }
                          },
                          icon: const Icon(PhosphorIconsRegular.arrowsClockwise, size: 16, color: Colors.white),
                          label: Text(l10n?.syncSchedule ?? 'Sync Schedule', style: PoswalText.caption.copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: PoswalSpacing.lg),

            // --- SECTION 5: LANGUAGE & LOCALIZATION ---
            _buildSectionHeader(l10n?.settingsLanguage ?? 'Language', PhosphorIconsRegular.globe, textPrimary),
            const SizedBox(height: PoswalSpacing.xs),
            AppGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n?.displayLanguage ?? 'Display Language', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: PoswalSpacing.xs),
                  Text(l10n?.displayLanguageSubtitle ?? 'Supports English, Hindi (हिन्दी), and Urdu (اردو) with native fonts and RTL direction', style: PoswalText.caption.copyWith(color: textMuted)),
                  const SizedBox(height: PoswalSpacing.md),
                  Wrap(
                    spacing: PoswalSpacing.sm,
                    runSpacing: PoswalSpacing.xs,
                    children: AppLanguageOption.values.map((lang) {
                      final isSelected = settings.language == lang;
                      return ChoiceChip(
                        key: ValueKey('lang_chip_${lang.name}'),
                        label: Text(
                          lang.nativeName,
                          style: PoswalText.callout.copyWith(
                            color: isSelected ? PoswalColors.teal : textMuted,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: PoswalColors.teal.withValues(alpha: 0.15),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        side: BorderSide(
                          color: isSelected ? PoswalColors.teal : Colors.white12,
                        ),
                        onSelected: (_) {
                          unawaited(HapticFeedback.selectionClick());
                          settingsNotifier.updateLanguage(lang);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: PoswalSpacing.lg),

            // --- SECTION 6: DATA SAFETY & BACKUPS ---
            _buildSectionHeader(l10n?.settingsDataSafety ?? 'Data Safety & Backups', PhosphorIconsRegular.shieldCheck, textPrimary),
            const SizedBox(height: PoswalSpacing.xs),
            AppGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(PoswalSpacing.xs),
                        decoration: BoxDecoration(
                          color: PoswalColors.teal.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(PhosphorIconsRegular.checkCircle, color: PoswalColors.teal, size: 20),
                      ),
                      const SizedBox(width: PoswalSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n?.autoDailyBackupsActive ?? 'Automatic Daily Backups Active', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                            Text(l10n?.autoDailyBackupsSubtitle ?? 'Rolling retention keeps the last 7 daily snapshots safely.', style: PoswalText.caption.copyWith(color: textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PoswalSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('backup_now_btn'),
                          style: FilledButton.styleFrom(
                            backgroundColor: PoswalColors.teal,
                            padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                          ),
                          onPressed: _isBackingUp ? null : _handleManualBackup,
                          icon: _isBackingUp
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(PhosphorIconsRegular.floppyDisk, size: 18),
                          label: Text(_isBackingUp ? (l10n?.saving ?? 'Saving...') : (l10n?.settingsBackupNow ?? 'Back Up Now'), style: PoswalText.callout.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: PoswalSpacing.sm),
                      OutlinedButton.icon(
                        key: const ValueKey('export_btn'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm, horizontal: PoswalSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                        ),
                        onPressed: _showExportOptions,
                        icon: const Icon(PhosphorIconsRegular.export, size: 18, color: Colors.white),
                        label: Text(l10n?.settingsExport ?? 'Export', style: PoswalText.callout.copyWith(color: Colors.white)),
                      ),
                      const SizedBox(width: PoswalSpacing.sm),
                      OutlinedButton.icon(
                        key: const ValueKey('import_btn'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm, horizontal: PoswalSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                        ),
                        onPressed: _showImportDialog,
                        icon: const Icon(PhosphorIconsRegular.downloadSimple, size: 18, color: Colors.white),
                        label: Text(l10n?.settingsImport ?? 'Import', style: PoswalText.callout.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white12, height: 28),

                  Text(l10n?.availableBackups ?? 'Available Backups (Last 7)', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: PoswalSpacing.xs),

                  backupsAsync.when(
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2, color: PoswalColors.teal))),
                    error: (e, _) => Text('Could not load backups: $e', style: PoswalText.caption.copyWith(color: PoswalColors.danger)),
                    data: (backups) {
                      if (backups.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.md),
                          child: Text(l10n?.noBackupsYet ?? 'No backup snapshots yet. Tap "Back Up Now" to save your first snapshot.', style: PoswalText.caption.copyWith(color: textMuted)),
                        );
                      }
                      return Column(
                        children: backups.map((b) {
                          return Container(
                            margin: const EdgeInsets.only(top: PoswalSpacing.xs),
                            padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.sm, vertical: PoswalSpacing.xs),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(PoswalRadii.chip),
                            ),
                            child: Row(
                              children: [
                                const Icon(PhosphorIconsRegular.fileArchive, size: 20, color: PoswalColors.teal),
                                const SizedBox(width: PoswalSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(b.name, style: PoswalText.caption.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                                      Text('${b.formattedDate} · ${b.formattedSize}', style: PoswalText.caption.copyWith(color: textMuted, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  key: ValueKey('restore_${b.name}'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.xs),
                                  ),
                                  onPressed: _isRestoring ? null : () => _handleRestoreBackup(b),
                                  icon: const Icon(PhosphorIconsRegular.arrowCounterClockwise, size: 16, color: PoswalColors.teal),
                                  label: Text(l10n?.restore ?? 'Restore', style: PoswalText.caption.copyWith(color: PoswalColors.teal, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: PoswalSpacing.lg),

            // --- SECTION 5: DANGER ZONE ---
            _buildSectionHeader(l10n?.settingsDanger ?? 'Danger Zone', PhosphorIconsRegular.warningOctagon, PoswalColors.danger),
            const SizedBox(height: PoswalSpacing.xs),
            AppGlassCard(
              tintColor: PoswalColors.danger,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n?.resetOrClearData ?? 'Reset or Clear Data', style: PoswalText.callout.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: PoswalSpacing.xs),
                  Text(
                    l10n?.deleteAllDataSubtitle ?? 'Wipes all active habits, tasks, and notes. A pre-wipe snapshot is automatically taken to guarantee data safety.',
                    style: PoswalText.caption.copyWith(color: PoswalColors.textMutedDark),
                  ),
                  const SizedBox(height: PoswalSpacing.md),
                  OutlinedButton.icon(
                    key: const ValueKey('delete_all_data_btn'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: PoswalColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm, horizontal: PoswalSpacing.md),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                    ),
                    onPressed: _handleDeleteAllData,
                    icon: const Icon(PhosphorIconsRegular.trash, color: PoswalColors.danger, size: 18),
                    label: Text(l10n?.settingsDeleteAll ?? 'Delete All Data', style: PoswalText.callout.copyWith(color: PoswalColors.danger, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: PoswalSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: PoswalSpacing.xs),
        Text(
          title,
          style: PoswalText.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
