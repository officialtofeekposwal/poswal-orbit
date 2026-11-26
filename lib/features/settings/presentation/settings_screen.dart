import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/services/update/app_update_service.dart';
import 'package:poswal_orbit/core/services/update/update_providers.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_list_section.dart';
import 'package:poswal_orbit/core/widgets/app_sheet.dart';
import 'package:poswal_orbit/core/widgets/app_background.dart';
import 'package:poswal_orbit/core/widgets/update_bottom_sheet.dart';
import 'package:poswal_orbit/data/services/data_safety_service.dart';
import 'package:poswal_orbit/data/services/notification_service.dart';
import 'package:poswal_orbit/data/vault/vault_providers.dart';
import 'package:poswal_orbit/features/settings/presentation/vault_settings_section.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';
import 'package:poswal_orbit/domain/models/data_safety_models.dart';
import 'package:poswal_orbit/features/settings/application/settings_providers.dart';
import 'package:poswal_orbit/features/settings/domain/settings_preferences.dart';
import 'package:poswal_orbit/features/playground/presentation/design_playground_screen.dart';
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
  bool _isCheckingUpdate = false;
  int _versionTapCount = 0;
  String _currentVersion = '0.9.1-beta.2+2';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final v = await ref.read(appUpdateServiceProvider).getCurrentVersionDisplay();
        if (mounted && v.isNotEmpty) {
          setState(() => _currentVersion = v);
        }
      } catch (_) {}
    });
  }

  Future<void> _handleCheckUpdates() async {
    if (_isCheckingUpdate) return;
    setState(() => _isCheckingUpdate = true);
    try {
      final result = await ref.read(appUpdateServiceProvider).checkForUpdateWithStatus(force: true);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      switch (result.status) {
        case UpdateCheckStatus.updateAvailable:
          if (result.release != null) {
            await UpdateBottomSheet.show(context, result.release!);
          }
          break;
        case UpdateCheckStatus.upToDate:
          _showToast(l10n?.updateUpToDate ?? 'You are on the latest version');
          break;
        case UpdateCheckStatus.errorOfflineOrTimeout:
          _showToast(
            l10n?.updateCheckOffline ?? 'Unable to check for updates. Check your internet connection.',
            isError: true,
          );
          break;
        case UpdateCheckStatus.errorRateLimited:
          _showToast(
            l10n?.updateCheckRateLimited ?? 'GitHub rate limit reached. Please try again later.',
            isError: true,
          );
          break;
        case UpdateCheckStatus.errorInvalidResponse:
        case UpdateCheckStatus.skippedByUser:
        case UpdateCheckStatus.throttled:
        case UpdateCheckStatus.disabled:
          _showToast(
            l10n?.updateCheckFailed ?? 'Could not check for updates right now.',
            isError: true,
          );
          break;
      }
    } finally {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: PoswalText.callout.copyWith(color: PoswalColors.textOnDark),
        ),
        backgroundColor: isError ? PoswalColors.danger : PoswalColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// "Delete all data" and "Restore backup" wipe the local database. Disconnect the
  /// vault first so this can never remove the files in the user's vault folder.
  Future<void> _vaultAfterDestructiveChange() async {
    final wasConnected = await ref.read(vaultControllerProvider.notifier).disconnectAfterDestructiveChange();
    if (wasConnected) {
      _showToast('Vault disconnected for safety. Reconnect it in Settings > Vault. Your vault files were not touched.');
    }
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
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppSheet.show<bool>(
      context: context,
      builder: (ctx) => AppSheet(
        title: l10n?.restoreBackupDialogTitle ?? 'Restore from Backup?',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg, vertical: PoswalSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.restoreBackupDialogBody(backup.formattedDate) ??
                    'This will replace your current data with backup from ${backup.formattedDate}.\n\nA safety snapshot of your current database will be taken immediately before restoring so nothing is lost.',
                style: PoswalText.bodyText.copyWith(color: PoswalColors.textSecondaryDark),
              ),
              const SizedBox(height: PoswalSpacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: PoswalColors.teal,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n?.restoreSafelyBtn ?? 'Restore Safely', style: PoswalText.callout.copyWith(color: PoswalColors.ink, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: PoswalSpacing.sm),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n?.cancel ?? 'Cancel', style: PoswalText.callout.copyWith(color: PoswalColors.textSecondaryDark)),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isRestoring = true);
    try {
      final res = await ref.read(dataSafetyServiceProvider).restoreFromJsonFile(backup.file);
      await _vaultAfterDestructiveChange();
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
    final firstConfirm = await AppSheet.show<bool>(
      context: context,
      builder: (ctx) => AppSheet(
        title: l10n?.deleteAllDataDialogTitle ?? 'Delete All Data?',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg, vertical: PoswalSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.deleteAllDataDialogContent ??
                    'This will wipe all habits, entries, tasks, and notes.\n\nA safety backup snapshot will be created automatically before wiping so you can recover if needed.',
                style: PoswalText.bodyText.copyWith(color: PoswalColors.textSecondaryDark),
              ),
              const SizedBox(height: PoswalSpacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: PoswalColors.danger,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n?.proceed ?? 'Proceed', style: PoswalText.callout.copyWith(color: PoswalColors.surfaceLight, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: PoswalSpacing.sm),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n?.cancel ?? 'Cancel', style: PoswalText.callout.copyWith(color: PoswalColors.textSecondaryDark)),
              ),
            ],
          ),
        ),
      ),
    );

    if (firstConfirm != true || !mounted) return;

    final secondConfirm = await AppSheet.show<bool>(
      context: context,
      builder: (ctx) => AppSheet(
        title: l10n?.finalConfirmationTitle ?? 'Final Confirmation',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg, vertical: PoswalSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.finalConfirmationContent ?? 'Are you completely sure? This action will reset your active workspace.',
                style: PoswalText.bodyText.copyWith(color: PoswalColors.textSecondaryDark),
              ),
              const SizedBox(height: PoswalSpacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: PoswalColors.danger,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n?.wipeEverything ?? 'Wipe Everything', style: PoswalText.callout.copyWith(color: PoswalColors.surfaceLight, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: PoswalSpacing.sm),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n?.keepMyData ?? 'Keep My Data', style: PoswalText.callout.copyWith(color: PoswalColors.textSecondaryDark)),
              ),
            ],
          ),
        ),
      ),
    );

    if (secondConfirm != true || !mounted) return;

    try {
      await ref.read(dataSafetyServiceProvider).deleteAllData();
      await _vaultAfterDestructiveChange();
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
    AppSheet.show(
      context: context,
      builder: (ctx) => AppSheet(
        title: l10n?.importDialogTitle ?? 'Import Data / Loop CSV',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg, vertical: PoswalSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.importDialogContent ?? 'Paste JSON backup content or Loop Habit Tracker CSV data below:',
                style: PoswalText.bodyText.copyWith(color: PoswalColors.textSecondaryDark),
              ),
              const SizedBox(height: PoswalSpacing.md),
              Builder(
                builder: (innerCtx) {
                  final sheetDark = Theme.of(innerCtx).brightness == Brightness.dark;
                  final fieldText = sheetDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
                  final fieldSecondary = sheetDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
                  final fieldFill = sheetDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight2;
                  return TextField(
                    controller: textController,
                    maxLines: 6,
                    style: PoswalText.bodyText.copyWith(color: fieldText),
                    decoration: InputDecoration(
                      hintText: l10n?.importPlaceholder ?? 'Paste JSON backup or Loop CSV data...',
                      hintStyle: PoswalText.caption.copyWith(color: fieldSecondary),
                      filled: true,
                      fillColor: fieldFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PoswalRadii.chip),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: PoswalSpacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: PoswalColors.teal,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () async {
                  final content = textController.text.trim();
                  if (content.isEmpty) return;
                  Navigator.of(ctx).pop();
                  await _processImportContent(content);
                },
                child: Text(l10n?.inspectAndImport ?? 'Inspect & Import', style: PoswalText.callout.copyWith(color: PoswalColors.ink, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: PoswalSpacing.sm),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n?.cancel ?? 'Cancel', style: PoswalText.callout.copyWith(color: PoswalColors.textSecondaryDark)),
              ),
            ],
          ),
        ),
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

    // Show preview action sheet before applying
    final proceed = await AppSheet.show<bool>(
      context: context,
      builder: (ctx) => AppSheet(
        title: l10n?.importPreview ?? 'Import Preview',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg, vertical: PoswalSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n?.importFormat(preview.format.label) ?? 'Format: ${preview.format.label}', style: PoswalText.headline.copyWith(color: PoswalColors.teal)),
              const SizedBox(height: PoswalSpacing.xs),
              Builder(
                builder: (innerCtx) {
                  final sheetDark = Theme.of(innerCtx).brightness == Brightness.dark;
                  return Text(
                    preview.summary,
                    style: PoswalText.bodyText.copyWith(
                      color: sheetDark ? PoswalColors.textOnDark : PoswalColors.textOnLight,
                    ),
                  );
                },
              ),
              const SizedBox(height: PoswalSpacing.md),
              Text(
                l10n?.importSafetyNote ?? 'A safety backup will be created automatically before importing to protect your current database.',
                style: PoswalText.caption.copyWith(color: PoswalColors.textSecondaryDark),
              ),
              const SizedBox(height: PoswalSpacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: PoswalColors.teal,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n?.applyImport ?? 'Apply Import', style: PoswalText.callout.copyWith(color: PoswalColors.ink, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: PoswalSpacing.sm),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.capsule)),
                ),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n?.cancel ?? 'Cancel', style: PoswalText.callout.copyWith(color: PoswalColors.textSecondaryDark)),
              ),
            ],
          ),
        ),
      ),
    );

    if (proceed != true || !mounted) return;

    try {
      final res = preview.format == BackupFormat.csvLoop
          ? await safetyService.importLoopCsv(content)
          : await safetyService.restoreFromJsonString(content);
      if (preview.format != BackupFormat.csvLoop) {
        await _vaultAfterDestructiveChange();
      }
      ref.invalidate(availableBackupsProvider);
      unawaited(HapticFeedback.heavyImpact());
      _showToast(l10n?.importSuccessToast(res.habitsCount, res.tasksCount, res.notesCount) ?? 'Successfully imported ${res.habitsCount} habits, ${res.tasksCount} tasks, ${res.notesCount} notes');
    } catch (e) {
      _showToast('Import failed: $e', isError: true);
    }
  }

  void _showExportOptions() {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetTextPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final sheetTextSecondary = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final accent = isDark ? PoswalColors.teal : PoswalColors.tealLight;
    AppSheet.show(
      context: context,
      builder: (ctx) => AppSheet(
        title: l10n?.settingsExport ?? 'Export Data',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(PhosphorIconsRegular.fileCode, color: accent),
              title: Text(l10n?.backupFullJson ?? 'Full Database Snapshot (JSON)', style: PoswalText.callout.copyWith(color: sheetTextPrimary)),
              subtitle: Text(l10n?.backupFullJsonSubtitle ?? 'Complete portable backup with habits, tasks & notes', style: PoswalText.caption.copyWith(color: sheetTextSecondary)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final jsonStr = await ref.read(dataSafetyServiceProvider).exportFullDatabaseJson();
                await Clipboard.setData(ClipboardData(text: jsonStr));
                _showToast(l10n?.fullJsonCopiedToast(jsonStr.length) ?? 'Full JSON backup copied to clipboard (${jsonStr.length} bytes)');
              },
            ),
            ListTile(
              leading: Icon(PhosphorIconsRegular.table, color: accent),
              title: Text(l10n?.exportHabitsCsv ?? 'Habits & Check-ins (CSV)', style: PoswalText.callout.copyWith(color: sheetTextPrimary)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final csvStr = await ref.read(dataSafetyServiceProvider).exportHabitsCsv();
                await Clipboard.setData(ClipboardData(text: csvStr));
                _showToast(l10n?.habitsCsvCopiedToast ?? 'Habits CSV copied to clipboard');
              },
            ),
            ListTile(
              leading: Icon(PhosphorIconsRegular.checkSquare, color: accent),
              title: Text(l10n?.exportTasksCsv ?? 'Tasks & Subtasks (CSV)', style: PoswalText.callout.copyWith(color: sheetTextPrimary)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final csvStr = await ref.read(dataSafetyServiceProvider).exportTasksCsv();
                await Clipboard.setData(ClipboardData(text: csvStr));
                _showToast(l10n?.tasksCsvCopiedToast ?? 'Tasks CSV copied to clipboard');
              },
            ),
            ListTile(
              leading: Icon(PhosphorIconsRegular.note, color: accent),
              title: Text(l10n?.exportNotesCsv ?? 'Notes & Journal (CSV)', style: PoswalText.callout.copyWith(color: sheetTextPrimary)),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;

    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final intensity = ref.watch(glassIntensityProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final backupsAsync = ref.watch(availableBackupsProvider);

    return AppBackground(
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
          padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.md),
          physics: const BouncingScrollPhysics(),
          children: [
            // --- SECTION 1: APPEARANCE ---
            AppListSection(
              title: l10n?.settingsAppearance ?? 'Appearance',
              children: [
                Padding(
                  padding: const EdgeInsets.all(PoswalSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n?.settingsTheme ?? 'Theme', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
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
                              color: isSelected ? (isDark ? PoswalColors.teal : PoswalColors.tealLight) : textMuted,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (_) => settingsNotifier.updateThemeMode(mode),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: PoswalSpacing.md),
                      Text(l10n?.settingsAccentColor ?? 'Accent Color', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: PoswalSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: AccentColorOption.values.map((accent) {
                          final isSelected = settings.accent == accent;
                          return GestureDetector(
                            onTap: () => settingsNotifier.updateAccent(accent),
                            child: AnimatedContainer(
                              duration: PoswalDurations.micro,
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accent.color,
                                borderRadius: BorderRadius.circular(PoswalRadii.pill),
                                border: isSelected
                                    ? Border.all(
                                        color: textPrimary,
                                        width: 2.0,
                                      )
                                    : null,
                              ),
                              child: isSelected ? const Icon(PhosphorIconsRegular.check, size: 20, color: PoswalColors.surfaceLight) : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: PoswalSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n?.settingsGlassIntensity ?? 'Glass Intensity', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                          Text('${(intensity * 100).toInt()}%', style: PoswalText.caption.copyWith(color: isDark ? PoswalColors.teal : PoswalColors.tealLight, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Slider(
                        value: intensity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        activeColor: PoswalColors.teal,
                        inactiveColor: textMuted.withValues(alpha: 0.2),
                        onChanged: (val) {
                          ref.read(glassIntensityProvider.notifier).setIntensity(val);
                          settingsNotifier.updateGlassIntensity(val);
                        },
                      ),
                      const SizedBox(height: PoswalSpacing.xs),
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
              ],
            ),

            const SizedBox(height: PoswalSpacing.md),

            // --- SECTION 2: TIME & DAY BOUNDARY ---
            AppListSection(
              title: l10n?.settingsTimeBoundary ?? 'Time & Orbit Boundary',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n?.settingsDayStart ?? 'Day-Start Boundary', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      l10n?.dayStartBoundarySubtitle ?? 'Habit check-ins before this hour count towards previous day',
                      style: PoswalText.caption.copyWith(color: textMuted),
                    ),
                    trailing: DropdownButton<int>(
                      value: settings.dayStartHour,
                      dropdownColor: isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight,
                      underline: const SizedBox(),
                      items: [0, 3, 4, 5, 6].map((hour) {
                        final label = hour == 0 ? '12:00 AM' : '${hour.toString().padLeft(2, '0')}:00 AM${hour == 4 ? ' (Default)' : ''}';
                        return DropdownMenuItem(
                          value: hour,
                          child: Text(label, style: PoswalText.callout.copyWith(color: textPrimary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) settingsNotifier.updateDayStartHour(val);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
                  child: ListTile(
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
                ),
              ],
            ),

            const SizedBox(height: PoswalSpacing.md),

            // --- SECTION 3: FEEDBACK ---
            AppListSection(
              title: l10n?.settingsHaptics ?? 'Haptics & Motion',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n?.settingsHaptics ?? 'Haptic Feedback', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n?.hapticFeedbackSubtitle ?? 'Tactile vibration on habit rings, checkboxes and gestures', style: PoswalText.caption.copyWith(color: textMuted)),
                    value: settings.hapticsEnabled,
                    activeColor: PoswalColors.teal,
                    onChanged: (val) => settingsNotifier.updateHaptics(val),
                  ),
                ),
              ],
            ),

            const SizedBox(height: PoswalSpacing.md),

            // --- SECTION 4: REMINDERS & NOTIFICATIONS ---
            AppListSection(
              title: l10n?.settingsNotifications ?? 'Reminders & Notifications',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
                  child: ListTile(
                    key: const ValueKey('reminders_health_check_tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      PhosphorIconsRegular.heartbeat,
                      color: isDark ? PoswalColors.teal : PoswalColors.tealLight,
                      size: 20,
                    ),
                    title: Text(l10n?.settingsHealthCheck ?? 'Reminders Health Check', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n?.remindersHealthCheckSubtitle ?? 'Verify notification permissions, exact alarms & One UI battery rules', style: PoswalText.caption.copyWith(color: textMuted)),
                    trailing: Icon(PhosphorIconsRegular.caretRight, size: 20, color: textMuted),
                    onTap: () => RemindersHealthCheckScreen.push(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(PoswalSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('settings_send_test_notif_btn'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: textMuted.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                          ),
                          onPressed: () async {
                            final notifService = ref.read(notificationServiceProvider);
                            await notifService.sendTestNotification();
                            if (context.mounted) {
                              _showToast('Test notification dispatched. Check your status bar.');
                            }
                          },
                          icon: Icon(PhosphorIconsRegular.paperPlaneTilt, size: 20, color: textPrimary),
                          label: Text(l10n?.sendTestAlert ?? 'Send test alert', style: PoswalText.caption.copyWith(color: textPrimary)),
                        ),
                      ),
                      const SizedBox(width: PoswalSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('settings_refill_schedule_btn'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: textMuted.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                          ),
                          onPressed: () async {
                            final notifService = ref.read(notificationServiceProvider);
                            final count = await notifService.refillRollingWindow();
                            if (context.mounted) {
                              _showToast('Rolling window synced ($count reminders).');
                            }
                          },
                          icon: Icon(PhosphorIconsRegular.arrowsClockwise, size: 20, color: textPrimary),
                          label: Text(l10n?.syncSchedule ?? 'Sync Schedule', style: PoswalText.caption.copyWith(color: textPrimary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: PoswalSpacing.md),

            // --- SECTION 5: LANGUAGE & LOCALIZATION ---
            AppListSection(
              title: l10n?.settingsLanguage ?? 'Language',
              children: [
                Padding(
                  padding: const EdgeInsets.all(PoswalSpacing.md),
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
                                color: isSelected ? (isDark ? PoswalColors.teal : PoswalColors.tealLight) : textMuted,
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
                              settingsNotifier.updateLanguage(lang, db: ref.read(databaseProvider));
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: PoswalSpacing.md),

            const VaultSettingsSection(),

            // --- SECTION 6: DATA SAFETY & BACKUPS ---
            AppListSection(
              title: l10n?.settingsDataSafety ?? 'Data Safety & Backups',
              children: [
                Padding(
                  padding: const EdgeInsets.all(PoswalSpacing.md),
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
                                foregroundColor: PoswalColors.ink,
                                padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                              ),
                              onPressed: _isBackingUp ? null : _handleManualBackup,
                              icon: _isBackingUp
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: PoswalColors.ink))
                                  : const Icon(PhosphorIconsRegular.floppyDisk, size: 18, color: PoswalColors.ink),
                              label: Text(_isBackingUp ? (l10n?.saving ?? 'Saving...') : (l10n?.settingsBackupNow ?? 'Back Up Now'), style: PoswalText.callout.copyWith(color: PoswalColors.ink, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: PoswalSpacing.sm),
                          OutlinedButton.icon(
                            key: const ValueKey('export_btn'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: textMuted.withValues(alpha: 0.3)),
                              padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm, horizontal: PoswalSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                            ),
                            onPressed: _showExportOptions,
                            icon: Icon(PhosphorIconsRegular.export, size: 20, color: textPrimary),
                            label: Text(l10n?.settingsExport ?? 'Export', style: PoswalText.callout.copyWith(color: textPrimary)),
                          ),
                          const SizedBox(width: PoswalSpacing.sm),
                          OutlinedButton.icon(
                            key: const ValueKey('import_btn'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: textMuted.withValues(alpha: 0.3)),
                              padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.sm, horizontal: PoswalSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.chip)),
                            ),
                            onPressed: _showImportDialog,
                            icon: Icon(PhosphorIconsRegular.downloadSimple, size: 20, color: textPrimary),
                            label: Text(l10n?.settingsImport ?? 'Import', style: PoswalText.callout.copyWith(color: textPrimary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: PoswalSpacing.md),
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
                                  color: textMuted.withValues(alpha: 0.08),
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
                                          Text('${b.formattedDate} · ${b.formattedSize}', style: PoswalText.caption2.copyWith(color: textMuted)),
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
              ],
            ),

            const SizedBox(height: PoswalSpacing.md),

            // --- SECTION 7: DANGER ZONE ---
            AppListSection(
              title: l10n?.settingsDanger ?? 'Danger Zone',
              isDestructive: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(PoswalSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n?.resetOrClearData ?? 'Reset or Clear Data', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: PoswalSpacing.xs),
                      Text(
                        l10n?.deleteAllDataSubtitle ?? 'Wipes all active habits, tasks, and notes. A pre-wipe snapshot is automatically taken to guarantee data safety.',
                        style: PoswalText.caption.copyWith(color: textMuted),
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
              ],
            ),

            const SizedBox(height: PoswalSpacing.md),

            // --- SECTION 8: ABOUT & PLAYGROUND ---
            AppListSection(
              title: l10n?.settingsAbout ?? 'About',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
                  child: ListTile(
                    key: const ValueKey('settings_version_tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(PhosphorIconsRegular.atom, color: PoswalColors.teal, size: 22),
                    title: Text(l10n?.appTitle ?? 'Poswal Orbit', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      l10n?.currentVersionLabel(_currentVersion) ?? 'Current version: $_currentVersion',
                      style: PoswalText.caption.copyWith(color: textMuted),
                    ),
                    trailing: Icon(PhosphorIconsRegular.caretRight, size: 16, color: textMuted),
                    onTap: () {
                      _versionTapCount++;
                      if (_versionTapCount >= 7) {
                        _versionTapCount = 0;
                        _showToast('Design playground enabled.');
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DesignPlaygroundScreen()),
                        );
                      } else if (_versionTapCount >= 3) {
                        _showToast('${7 - _versionTapCount} more taps to open playground');
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
                  child: ListTile(
                    key: const ValueKey('settings_check_updates_tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(PhosphorIconsRegular.arrowCircleUp, color: PoswalColors.teal, size: 22),
                    title: Text(
                      l10n?.checkForUpdates ?? 'Check for updates',
                      style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w500),
                    ),
                    trailing: _isCheckingUpdate
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: PoswalColors.teal),
                          )
                        : Icon(PhosphorIconsRegular.caretRight, size: 16, color: textMuted),
                    onTap: _isCheckingUpdate ? null : _handleCheckUpdates,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
                  child: SwitchListTile(
                    key: const ValueKey('settings_auto_update_switch'),
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(PhosphorIconsRegular.arrowsClockwise, color: PoswalColors.teal, size: 22),
                    title: Text(
                      l10n?.autoUpdateChecks ?? 'Automatic update checks',
                      style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      l10n?.autoUpdateChecksSubtitle ?? 'Check GitHub Releases once a day for new versions',
                      style: PoswalText.caption.copyWith(color: textMuted),
                    ),
                    value: ref.watch(autoUpdateCheckProvider).value ?? true,
                    activeThumbColor: PoswalColors.teal,
                    onChanged: (val) => ref.read(autoUpdateCheckProvider.notifier).setEnabled(val),
                  ),
                ),
              ],
            ),

            const SizedBox(height: PoswalSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
