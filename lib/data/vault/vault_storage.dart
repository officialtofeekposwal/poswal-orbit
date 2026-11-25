/// Abstraction over "a folder with files". The sync code only talks to this
/// interface, so it works the same on Android (SAF) and in unit tests (dart:io).
class VaultFileInfo {
  /// Relative path with '/' separators, e.g. "notes/Idea.md".
  final String path;
  final bool isDir;
  final int size;

  /// Last modified time in milliseconds since epoch.
  final int modified;

  const VaultFileInfo({
    required this.path,
    required this.isDir,
    required this.size,
    required this.modified,
  });
}

class VaultWriteResult {
  final int size;
  final int modified;
  const VaultWriteResult({required this.size, required this.modified});
}

abstract class VaultStorage {
  /// Recursively lists files and folders. Hidden folders (".obsidian", ".trash"
  /// ...) are skipped, except ".orbit".
  Future<List<VaultFileInfo>> listAll();

  /// Returns null if the file does not exist.
  Future<String?> readText(String path);

  /// Creates parent folders and the file if needed, overwrites if it exists.
  Future<VaultWriteResult> writeText(String path, String content);

  /// Deletes a file. Does nothing if it does not exist.
  Future<void> delete(String path);
}
