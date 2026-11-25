import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/data/vault/vault_providers.dart';

/// Folder picker -> confirm dialog -> connect + first sync.
/// Returns true if a vault is connected at the end.
Future<bool> runVaultConnectFlow(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(vaultControllerProvider.notifier);
  final messenger = ScaffoldMessenger.of(context);

  final pick = await controller.pickFolder();
  if (pick == null) return false;
  if (!context.mounted) return false;

  final info = pick.inspect;
  if (info.hasMarker && !info.valid) {
    messenger.showSnackBar(SnackBar(content: Text(info.error ?? 'This folder cannot be used as a vault.')));
    return false;
  }

  final String title;
  final String body;
  final String action;
  if (info.hasMarker) {
    title = 'Connect existing vault?';
    body = 'Found a Poswal Orbit vault with ${info.habitFiles} habits, ${info.taskFiles} tasks '
        'and ${info.noteFiles} notes.\n\n'
        'The app will load everything from this folder. If an item differs from the app, the vault '
        'version wins and the app\'s version is saved in .orbit/conflicts.';
    action = 'Connect';
  } else if (info.isEmptyFolder) {
    title = 'Create vault here?';
    body = 'This folder is empty. The app will create habits/, tasks/, notes/ and .orbit/ and save '
        'all your current data there as Markdown files.';
    action = 'Create vault';
  } else {
    title = 'Use this folder?';
    body = 'This folder already has files. The app will only add habits/, tasks/, notes/ and .orbit/ '
        'and will never change your other files.';
    action = 'Use folder';
  }

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
      ],
    ),
  );
  if (ok != true) return false;

  final report = await controller.connect(pick.treeUri);
  if (report == null) {
    final msg = ref.read(vaultControllerProvider).message ?? 'Vault connection failed.';
    messenger.showSnackBar(SnackBar(content: Text(msg)));
    return false;
  }
  messenger.showSnackBar(SnackBar(content: Text('Vault connected. ${report.summary()}')));
  return true;
}
