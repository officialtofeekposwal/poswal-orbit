import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_list_section.dart';
import 'package:poswal_orbit/data/vault/vault_providers.dart';
import 'package:poswal_orbit/features/settings/presentation/vault_flow.dart';

class VaultSettingsSection extends ConsumerWidget {
  const VaultSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!vaultSupported) return const SizedBox.shrink();
    final vault = ref.watch(vaultControllerProvider);
    if (!vault.loaded) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final controller = ref.read(vaultControllerProvider.notifier);

    final children = <Widget>[];

    if (vault.connected && vault.treeUri != null) {
      children.addAll([
        Text('Vault connected', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: PoswalSpacing.xxs),
        Text(vaultDisplayName(vault.treeUri!), style: PoswalText.caption.copyWith(color: textMuted)),
        const SizedBox(height: PoswalSpacing.xs),
        Text(
          vault.lastSync == null
              ? 'Not synced yet'
              : 'Last sync: ${DateFormat('MMM d, HH:mm').format(vault.lastSync!)}',
          style: PoswalText.caption.copyWith(color: textMuted),
        ),
        if (vault.message != null) ...[
          const SizedBox(height: PoswalSpacing.xxs),
          Text(vault.message!, style: PoswalText.caption.copyWith(color: textMuted)),
        ],
        const SizedBox(height: PoswalSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('vault_sync_now_btn'),
                onPressed: vault.busy ? null : controller.syncNow,
                child: Text(vault.busy ? 'Syncing…' : 'Sync now'),
              ),
            ),
            const SizedBox(width: PoswalSpacing.sm),
            Expanded(
              child: TextButton(
                key: const ValueKey('vault_disconnect_btn'),
                onPressed: vault.busy ? null : () => _confirmDisconnect(context, controller),
                child: const Text('Disconnect'),
              ),
            ),
          ],
        ),
        const SizedBox(height: PoswalSpacing.xs),
        Text(
          'Your habits, tasks and notes are saved as Markdown files in this folder. '
          'Open it in Obsidian as a vault. Uninstalling the app does not delete this folder.',
          style: PoswalText.caption.copyWith(color: textMuted),
        ),
      ]);
    } else {
      children.addAll([
        Text(
          vault.needsReconnect ? 'Vault folder needs to be reconnected' : 'Keep your data in a folder you own',
          style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: PoswalSpacing.xs),
        Text(
          vault.needsReconnect
              ? (vault.message ?? 'Access to the folder was lost. Choose it again. Nothing was deleted.')
              : 'Choose a folder (for example Documents/PoswalOrbit). The app saves habits, tasks and notes '
                  'there as Markdown files, Obsidian style. If you uninstall the app, the folder stays. '
                  'After reinstalling, connect the same folder and everything comes back.',
          style: PoswalText.caption.copyWith(color: textMuted),
        ),
        const SizedBox(height: PoswalSpacing.md),
        FilledButton(
          key: const ValueKey('vault_choose_btn'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: PoswalColors.teal,
          ),
          onPressed: vault.busy ? null : () => runVaultConnectFlow(context, ref),
          child: Text(vault.needsReconnect ? 'Reconnect folder' : 'Choose vault folder'),
        ),
      ]);
    }

    return Column(
      children: [
        AppListSection(
          title: 'Vault (Obsidian-style folder)',
          children: [
            Padding(
              padding: const EdgeInsets.all(PoswalSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
        const SizedBox(height: PoswalSpacing.md),
      ],
    );
  }

  Future<void> _confirmDisconnect(BuildContext context, VaultController controller) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect vault?'),
        content: const Text(
          'The app stops syncing with the folder. The files in the folder are NOT deleted, '
          'and the data stays in the app. You can connect the folder again anytime.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Disconnect')),
        ],
      ),
    );
    if (ok == true) await controller.disconnect();
  }
}
