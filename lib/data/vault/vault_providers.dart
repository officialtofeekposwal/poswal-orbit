import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show TableUpdate, TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/services/notification_service.dart';
import 'package:poswal_orbit/data/vault/saf_vault_storage.dart';
import 'package:poswal_orbit/data/vault/vault_index.dart';
import 'package:poswal_orbit/data/vault/vault_sync_service.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

const String kVaultTreeUriKey = 'vault_tree_uri';

/// The vault feature uses Android's folder picker, so it is Android-only for now.
bool get vaultSupported => Platform.isAndroid;

/// "content://.../tree/primary%3ADocuments%2FPoswalOrbit" -> "Internal storage/Documents/PoswalOrbit"
String vaultDisplayName(String treeUri) {
  try {
    final last = treeUri.split('/tree/').last;
    return Uri.decodeComponent(last).replaceFirst('primary:', 'Internal storage/');
  } catch (_) {
    return treeUri;
  }
}

class VaultState {
  final bool loaded;
  final String? treeUri;
  final bool connected;
  final bool needsReconnect;
  final bool busy;
  final DateTime? lastSync;
  final String? message;

  const VaultState({
    this.loaded = false,
    this.treeUri,
    this.connected = false,
    this.needsReconnect = false,
    this.busy = false,
    this.lastSync,
    this.message,
  });

  VaultState copyWith({
    bool? loaded,
    String? treeUri,
    bool? connected,
    bool? needsReconnect,
    bool? busy,
    DateTime? lastSync,
    String? message,
    bool clearMessage = false,
  }) {
    return VaultState(
      loaded: loaded ?? this.loaded,
      treeUri: treeUri ?? this.treeUri,
      connected: connected ?? this.connected,
      needsReconnect: needsReconnect ?? this.needsReconnect,
      busy: busy ?? this.busy,
      lastSync: lastSync ?? this.lastSync,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class VaultPickResult {
  final String treeUri;
  final VaultInspect inspect;
  const VaultPickResult(this.treeUri, this.inspect);
}

class VaultController extends Notifier<VaultState> {
  VaultSyncService? _service;
  StreamSubscription<Set<TableUpdate>>? _watch;
  Timer? _debounce;
  DateTime? _lastResumeSync;
  late Future<void> _ready;

  @override
  VaultState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _watch?.cancel();
    });
    _ready = Future<void>.microtask(_load);
    return const VaultState();
  }

  // ------------------------------------------------------------- settings
  Future<String?> _readSetting(String key) async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(db.appSettingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeSetting(String key, String? value) async {
    final db = ref.read(databaseProvider);
    if (value == null) {
      await (db.delete(db.appSettingsTable)..where((t) => t.key.equals(key))).go();
      return;
    }
    await db.into(db.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(key: key, value: value, updatedAt: DateTime.now()),
        );
  }

  Future<VaultIndexStore> _indexStore() async {
    final dir = await getApplicationSupportDirectory();
    return VaultIndexStore(File('${dir.path}${Platform.pathSeparator}vault_index.json'));
  }

  Future<VaultSyncService> _buildService(String treeUri) async {
    return VaultSyncService(
      db: ref.read(databaseProvider),
      storage: SafVaultStorage(treeUri),
      indexStore: await _indexStore(),
    );
  }

  // ----------------------------------------------------------------- load
  Future<void> _load() async {
    try {
      if (!vaultSupported) {
        state = state.copyWith(loaded: true);
        return;
      }
      final uri = await _readSetting(kVaultTreeUriKey);
      if (uri == null) {
        state = state.copyWith(loaded: true);
        return;
      }
      final ok = await SafVaultStorage.hasPermission(uri);
      if (!ok) {
        state = state.copyWith(
          loaded: true,
          treeUri: uri,
          connected: false,
          needsReconnect: true,
          message: 'Access to the vault folder was lost. Choose the folder again. Nothing was deleted.',
        );
        return;
      }
      _service = await _buildService(uri);
      state = state.copyWith(loaded: true, treeUri: uri, connected: true, needsReconnect: false);
      _startWatching();
    } catch (_) {
      // never crash the app because of the vault
    }
  }

  // --------------------------------------------------------- connect flow
  /// Step 1: system folder picker + look inside (no changes). null = cancelled.
  Future<VaultPickResult?> pickFolder() async {
    if (!vaultSupported) return null;
    final uri = await SafVaultStorage.pickTree();
    if (uri == null) return null;
    final inspect = await inspectVault(SafVaultStorage(uri));
    return VaultPickResult(uri, inspect);
  }

  /// Step 2: after the user confirmed. Creates the vault marker if needed,
  /// imports what is in the folder, then exports what is only in the app.
  Future<VaultSyncReport?> connect(String treeUri) async {
    state = state.copyWith(busy: true, clearMessage: true);
    try {
      await _writeSetting(kVaultTreeUriKey, treeUri);
      final store = await _indexStore();
      await store.clear(); // fresh index for this folder
      final service = await _buildService(treeUri);
      await service.initializeVaultIfNeeded();
      final report = await service.syncNow();
      _service = service;
      state = state.copyWith(
        loaded: true,
        treeUri: treeUri,
        connected: true,
        needsReconnect: false,
        busy: false,
        lastSync: DateTime.now(),
        message: report.summary(),
      );
      _startWatching();
      await _afterImport(report);
      return report;
    } catch (e) {
      if (!state.connected) await _writeSetting(kVaultTreeUriKey, null);
      state = state.copyWith(busy: false, message: 'Vault error: $e');
      return null;
    }
  }

  Future<void> syncNow() async {
    final service = _service;
    if (service == null || state.busy) return;
    state = state.copyWith(busy: true, clearMessage: true);
    try {
      final report = await service.syncNow();
      state = state.copyWith(busy: false, lastSync: DateTime.now(), message: report.summary());
      await _afterImport(report);
    } catch (e) {
      state = state.copyWith(busy: false, message: 'Vault sync failed: $e');
    }
  }

  Future<void> syncOnLaunch() async {
    await _ready;
    if (!state.connected) return;
    await syncNow();
  }

  Future<void> syncOnResume() async {
    await _ready;
    if (!state.connected) return;
    final last = _lastResumeSync;
    if (last != null && DateTime.now().difference(last) < const Duration(seconds: 20)) return;
    _lastResumeSync = DateTime.now();
    final uri = state.treeUri;
    if (uri != null && !await SafVaultStorage.hasPermission(uri)) {
      state = state.copyWith(
        connected: false,
        needsReconnect: true,
        message: 'Access to the vault folder was lost. Choose the folder again. Nothing was deleted.',
      );
      return;
    }
    await syncNow();
  }

  Future<void> _afterImport(VaultSyncReport report) async {
    if (!report.changedApp) return;
    try {
      await ref.read(notificationServiceProvider).refillRollingWindow();
    } catch (_) {}
  }

  // ----------------------------------------------------- auto export watcher
  void _startWatching() {
    _watch?.cancel();
    final db = ref.read(databaseProvider);
    _watch = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            db.habitsTable,
            db.habitEntriesTable,
            db.tasksTable,
            db.notesTable,
            db.noteTagsTable,
            db.taskTagsTable,
            db.tagsTable,
            db.projectsTable,
          ]),
        )
        .listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 3), _exportQuietly);
    });
  }

  Future<void> _exportQuietly() async {
    final service = _service;
    if (service == null || state.busy) return;
    try {
      final r = await service.exportDirty();
      if (r.exported + r.removedFromVault + r.imported > 0) {
        state = state.copyWith(lastSync: DateTime.now());
      }
      if (r.errors.isNotEmpty) {
        state = state.copyWith(message: 'Vault: ${r.errors.length} problem(s). ${r.errors.first}');
      }
    } catch (e) {
      state = state.copyWith(message: 'Vault sync failed: $e');
    }
  }

  // ---------------------------------------------------------- disconnect
  /// Stops syncing. The files in the folder are NOT touched.
  Future<void> disconnect() async {
    final uri = state.treeUri;
    _debounce?.cancel();
    await _watch?.cancel();
    _watch = null;
    _service = null;
    await _writeSetting(kVaultTreeUriKey, null);
    final store = await _indexStore();
    await store.clear();
    if (uri != null) {
      try {
        await SafVaultStorage.releasePermission(uri);
      } catch (_) {}
    }
    state = const VaultState(loaded: true);
  }

  /// Called after "Delete all data" / "Restore backup". Those wipe the local DB;
  /// to make sure that can never delete the vault files, we disconnect first.
  /// Returns true if a vault was connected.
  Future<bool> disconnectAfterDestructiveChange() async {
    if (!state.connected && state.treeUri == null) return false;
    await disconnect();
    return true;
  }
}

final vaultControllerProvider = NotifierProvider<VaultController, VaultState>(VaultController.new);
