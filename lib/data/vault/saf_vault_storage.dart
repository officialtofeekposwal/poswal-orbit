import 'package:flutter/services.dart';
import 'package:poswal_orbit/data/vault/vault_storage.dart';

/// Android folder access through the Storage Access Framework.
/// The matching native code is in android/.../MainActivity.kt.
class SafVaultStorage implements VaultStorage {
  static const MethodChannel _channel = MethodChannel('com.poswal.orbit/vault');

  final String treeUri;
  const SafVaultStorage(this.treeUri);

  /// Opens the system folder picker. Returns the tree uri, or null if cancelled.
  /// Android keeps the permission across app restarts.
  static Future<String?> pickTree() => _channel.invokeMethod<String>('pickTree');

  static Future<bool> hasPermission(String treeUri) async {
    final ok = await _channel.invokeMethod<bool>('hasPermission', {'treeUri': treeUri});
    return ok ?? false;
  }

  static Future<void> releasePermission(String treeUri) async {
    await _channel.invokeMethod<void>('releasePermission', {'treeUri': treeUri});
  }

  @override
  Future<List<VaultFileInfo>> listAll() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('listAll', {'treeUri': treeUri}) ?? const [];
    return raw.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return VaultFileInfo(
        path: m['path'] as String,
        isDir: m['isDir'] as bool,
        size: (m['size'] as num).toInt(),
        modified: (m['modified'] as num).toInt(),
      );
    }).toList();
  }

  @override
  Future<String?> readText(String path) {
    return _channel.invokeMethod<String>('readText', {'treeUri': treeUri, 'path': path});
  }

  @override
  Future<VaultWriteResult> writeText(String path, String content) async {
    final m = await _channel.invokeMethod<Map<dynamic, dynamic>>('writeText', {
      'treeUri': treeUri,
      'path': path,
      'content': content,
    });
    return VaultWriteResult(
      size: (m?['size'] as num?)?.toInt() ?? content.length,
      modified: (m?['modified'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> delete(String path) async {
    await _channel.invokeMethod<void>('delete', {'treeUri': treeUri, 'path': path});
  }
}
