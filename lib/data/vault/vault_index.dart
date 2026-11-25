import 'dart:convert';
import 'dart:io';

class VaultIndexEntry {
  String path;
  int fileHash; // hash of the file text as last seen/written
  int modelHash; // hash of the canonical render of the DB row at last sync
  int mtime; // file modified (ms) at last sync
  int size;
  String stem; // file-name stem derived from the title at last sync

  VaultIndexEntry({
    required this.path,
    required this.fileHash,
    required this.modelHash,
    required this.mtime,
    required this.size,
    required this.stem,
  });

  Map<String, Object?> toJson() => {
        'path': path,
        'fileHash': fileHash,
        'modelHash': modelHash,
        'mtime': mtime,
        'size': size,
        'stem': stem,
      };

  factory VaultIndexEntry.fromJson(Map<String, dynamic> j) => VaultIndexEntry(
        path: j['path'] as String,
        fileHash: (j['fileHash'] as num).toInt(),
        modelHash: (j['modelHash'] as num).toInt(),
        mtime: (j['mtime'] as num).toInt(),
        size: (j['size'] as num).toInt(),
        stem: (j['stem'] as String?) ?? '',
      );
}

class VaultIndex {
  String vaultId;
  int projectsHash = 0;
  int tagsHash = 0;

  /// key = `habit:<id>` | `task:<id>` | `note:<id>`
  final Map<String, VaultIndexEntry> entries = {};

  VaultIndex({required this.vaultId});

  Map<String, Object?> toJson() => {
        'vaultId': vaultId,
        'projectsHash': projectsHash,
        'tagsHash': tagsHash,
        'entries': {for (final e in entries.entries) e.key: e.value.toJson()},
      };

  factory VaultIndex.fromJson(Map<String, dynamic> j) {
    final idx = VaultIndex(vaultId: j['vaultId'] as String);
    idx.projectsHash = (j['projectsHash'] as num?)?.toInt() ?? 0;
    idx.tagsHash = (j['tagsHash'] as num?)?.toInt() ?? 0;
    final raw = (j['entries'] as Map<String, dynamic>?) ?? const {};
    raw.forEach((k, v) {
      idx.entries[k] = VaultIndexEntry.fromJson(v as Map<String, dynamic>);
    });
    return idx;
  }
}

class VaultIndexStore {
  final File file;
  VaultIndexStore(this.file);

  /// Returns null when missing or corrupt (=> full rescan).
  Future<VaultIndex?> load() async {
    try {
      if (!await file.exists()) return null;
      final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return VaultIndex.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(VaultIndex index) async {
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(index.toJson()), flush: true);
    await tmp.rename(file.path);
  }

  Future<void> clear() async {
    if (await file.exists()) await file.delete();
  }
}
