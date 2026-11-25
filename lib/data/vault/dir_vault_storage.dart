import 'dart:io';

import 'package:poswal_orbit/data/vault/vault_storage.dart';

class DirVaultStorage implements VaultStorage {
  final Directory root;
  DirVaultStorage(this.root);

  File _file(String path) {
    final native = path.replaceAll('/', Platform.pathSeparator);
    return File('${root.path}${Platform.pathSeparator}$native');
  }

  @override
  Future<List<VaultFileInfo>> listAll() async {
    final out = <VaultFileInfo>[];
    if (!await root.exists()) return out;
    await for (final e in root.list(recursive: true, followLinks: false)) {
      var rel = e.path.substring(root.path.length).replaceAll(Platform.pathSeparator, '/');
      if (rel.startsWith('/')) rel = rel.substring(1);
      if (rel.isEmpty) continue;
      final hidden = rel.split('/').any((s) => s.startsWith('.') && s != '.orbit');
      if (hidden) continue;
      final stat = await e.stat();
      out.add(VaultFileInfo(
        path: rel,
        isDir: e is Directory,
        size: stat.size,
        modified: stat.modified.millisecondsSinceEpoch,
      ));
    }
    return out;
  }

  @override
  Future<String?> readText(String path) async {
    final f = _file(path);
    if (!await f.exists()) return null;
    return f.readAsString();
  }

  @override
  Future<VaultWriteResult> writeText(String path, String content) async {
    final f = _file(path);
    await f.parent.create(recursive: true);
    final tmp = File('${f.path}.orbit-tmp');
    await tmp.writeAsString(content, flush: true);
    await tmp.rename(f.path); // atomic replace
    final stat = await f.stat();
    return VaultWriteResult(size: stat.size, modified: stat.modified.millisecondsSinceEpoch);
  }

  @override
  Future<void> delete(String path) async {
    final f = _file(path);
    if (await f.exists()) await f.delete();
  }
}
