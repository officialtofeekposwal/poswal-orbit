import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/vault/vault_codec.dart';
import 'package:poswal_orbit/data/vault/vault_index.dart';
import 'package:poswal_orbit/data/vault/vault_markdown.dart';
import 'package:poswal_orbit/data/vault/vault_storage.dart';
import 'package:uuid/uuid.dart';

class VaultException implements Exception {
  final String message;
  const VaultException(this.message);
  @override
  String toString() => message;
}

class VaultSyncReport {
  int imported = 0;
  int exported = 0;
  int removedFromVault = 0;
  int deletedInApp = 0;
  int conflicts = 0;
  final List<String> errors = [];

  bool get changedApp => imported > 0 || deletedInApp > 0;

  String summary() {
    final b = StringBuffer(
      'Imported $imported · Exported $exported · Removed $removedFromVault · Deleted in app $deletedInApp',
    );
    if (conflicts > 0) b.write(' · Conflicts $conflicts');
    if (errors.isNotEmpty) b.write(' · Errors ${errors.length}');
    return b.toString();
  }
}

class VaultInspect {
  final bool hasMarker;
  final bool valid;
  final String? error;
  final int schemaVersion;
  final String? vaultId;
  final int habitFiles;
  final int taskFiles;
  final int noteFiles;
  final bool isEmptyFolder;

  const VaultInspect({
    required this.hasMarker,
    required this.valid,
    this.error,
    this.schemaVersion = 0,
    this.vaultId,
    this.habitFiles = 0,
    this.taskFiles = 0,
    this.noteFiles = 0,
    this.isEmptyFolder = false,
  });
}

const int kVaultSchemaVersion = 1;
const String _kMarkerPath = '.orbit/vault.json';

/// Looks at a folder WITHOUT changing anything.
Future<VaultInspect> inspectVault(VaultStorage storage) async {
  final files = (await storage.listAll()).where((f) => !f.isDir).toList();
  int count(String dir) => files
      .where((f) => f.path.startsWith('$dir/') && f.path.toLowerCase().endsWith('.md'))
      .length;
  final habits = count('habits');
  final tasks = count('tasks');
  final notes = count('notes');

  final text = await storage.readText(_kMarkerPath);
  if (text == null) {
    return VaultInspect(
      hasMarker: false,
      valid: true,
      isEmptyFolder: files.isEmpty,
      habitFiles: habits,
      taskFiles: tasks,
      noteFiles: notes,
    );
  }
  try {
    final map = jsonDecode(text) as Map<String, dynamic>;
    final version = (map['schema_version'] as num?)?.toInt() ?? 0;
    if (map['app'] != 'poswal-orbit') {
      return const VaultInspect(hasMarker: true, valid: false, error: 'This is not a Poswal Orbit vault.');
    }
    if (version > kVaultSchemaVersion) {
      return VaultInspect(
        hasMarker: true,
        valid: false,
        schemaVersion: version,
        error: 'This vault was created by a newer version of the app. Please update the app.',
      );
    }
    return VaultInspect(
      hasMarker: true,
      valid: true,
      schemaVersion: version,
      vaultId: map['vault_id'] as String?,
      habitFiles: habits,
      taskFiles: tasks,
      noteFiles: notes,
    );
  } catch (_) {
    return const VaultInspect(hasMarker: true, valid: false, error: 'The vault marker file is damaged.');
  }
}

class _Current {
  final bool exists;
  final bool deleted;
  final String text;
  final String stemSource;
  const _Current({
    required this.exists,
    required this.deleted,
    required this.text,
    required this.stemSource,
  });
  const _Current.none()
      : exists = false,
        deleted = false,
        text = '',
        stemSource = '';
}

class VaultSyncService {
  VaultSyncService({
    required this.db,
    required this.storage,
    required this.indexStore,
  });

  final AppDatabase db;
  final VaultStorage storage;
  final VaultIndexStore indexStore;

  static const Uuid _uuid = Uuid();

  final Set<String> _paths = {}; // lower-cased paths that exist in the vault
  bool _primed = false;
  Future<void> _queue = Future<void>.value();

  // ---------------------------------------------------------------- locking
  Future<T> _locked<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  // ------------------------------------------------------------- public API

  /// Creates `.orbit/vault.json` if the folder has no marker yet.
  Future<void> initializeVaultIfNeeded() => _locked(() async {
        final existing = await storage.readText(_kMarkerPath);
        if (existing != null) return;
        final marker = <String, Object?>{
          'app': 'poswal-orbit',
          'schema_version': kVaultSchemaVersion,
          'vault_id': _uuid.v4(),
          'created': DateTime.now().toUtc().toIso8601String(),
        };
        await storage.writeText(_kMarkerPath, const JsonEncoder.withIndent('  ').convert(marker));
      });

  /// Import (vault -> app) first, then export (app -> vault).
  Future<VaultSyncReport> syncNow() => _locked(() => _run(doImport: true));

  /// Export only (used after local changes). Falls back to a full sync the
  /// first time it runs in this process.
  Future<VaultSyncReport> exportDirty() => _locked(() => _run(doImport: !_primed));

  // ------------------------------------------------------------------ core
  Future<({String vaultId, int version})> _readMarker() async {
    final text = await storage.readText(_kMarkerPath);
    if (text == null) {
      throw const VaultException('Vault marker (.orbit/vault.json) is missing. Choose the folder again.');
    }
    final map = jsonDecode(text) as Map<String, dynamic>;
    final version = (map['schema_version'] as num?)?.toInt() ?? 0;
    if (version > kVaultSchemaVersion) {
      throw const VaultException('This vault was created by a newer version of the app.');
    }
    final id = map['vault_id'] as String?;
    if (id == null) throw const VaultException('Vault marker has no vault_id.');
    return (vaultId: id, version: version);
  }

  Future<VaultSyncReport> _run({required bool doImport}) async {
    final report = VaultSyncReport();
    final marker = await _readMarker();

    var index = await indexStore.load();
    if (index == null || index.vaultId != marker.vaultId) {
      index = VaultIndex(vaultId: marker.vaultId);
    }

    final listing = await storage.listAll();
    final files = <String, VaultFileInfo>{
      for (final f in listing)
        if (!f.isDir) f.path: f,
    };
    _paths
      ..clear()
      ..addAll(files.keys.map((p) => p.toLowerCase()));

    if (doImport) {
      await _importAll(index, files, report);
    }
    await _exportAll(index, report);
    await indexStore.save(index);
    _primed = true;
    return report;
  }

  // ================================================================ IMPORT
  Future<void> _importAll(
    VaultIndex index,
    Map<String, VaultFileInfo> files,
    VaultSyncReport report,
  ) async {
    await _importMeta(index, files, report);

    for (final kind in const ['habit', 'task', 'note']) {
      final dir = '${kind}s/';
      final prefix = '$kind:';

      final byPath = <String, String>{}; // path -> index key
      for (final e in index.entries.entries) {
        if (e.key.startsWith(prefix)) byPath[e.value.path] = e.key;
      }

      final candidates = files.values
          .where((f) => f.path.startsWith(dir) && f.path.toLowerCase().endsWith('.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      for (final f in candidates) {
        final knownKey = byPath[f.path];
        final known = knownKey == null ? null : index.entries[knownKey];
        if (known != null && known.mtime == f.modified && known.size == f.size) {
          continue; // unchanged since last sync
        }
        try {
          await _importFile(kind, f, knownKey, known, index, files, report);
        } catch (e) {
          report.errors.add('${f.path}: $e');
        }
      }

      // Files that disappeared from the vault.
      final vanished = <String>[];
      var total = 0;
      for (final e in index.entries.entries) {
        if (!e.key.startsWith(prefix)) continue;
        total++;
        if (!files.containsKey(e.value.path)) vanished.add(e.key);
      }
      if (vanished.isEmpty) continue;
      if (total >= 6 && vanished.length * 2 > total) {
        report.errors.add(
          'Skipped deleting $kind items: ${vanished.length} of $total files are missing '
          '(folder moved or access lost?).',
        );
        continue;
      }
      for (final key in vanished) {
        await _softDelete(kind, key.substring(prefix.length));
        index.entries.remove(key);
        report.deletedInApp++;
      }
    }
  }

  Future<void> _importFile(
    String kind,
    VaultFileInfo f,
    String? knownKey,
    VaultIndexEntry? known,
    VaultIndex index,
    Map<String, VaultFileInfo> files,
    VaultSyncReport report,
  ) async {
    final text = await storage.readText(f.path);
    if (text == null) return;
    final fileHash = VaultMarkdown.hash(text);

    // Only timestamps changed (e.g. a sync tool touched the file).
    if (known != null && known.fileHash == fileHash) {
      known.mtime = f.modified;
      known.size = f.size;
      return;
    }

    final mtime = DateTime.fromMillisecondsSinceEpoch(f.modified);
    final peekId = VaultCodec.peekId(text);
    String? overrideId;
    VaultIndexEntry? existing = known;

    if (peekId == null && knownKey != null) {
      // User removed the id from the frontmatter: keep the same identity.
      overrideId = knownKey.substring(kind.length + 1);
    } else if (peekId != null && known == null) {
      final other = index.entries['$kind:$peekId'];
      if (other != null) {
        if (other.path != f.path && files.containsKey(other.path)) {
          // Same id lives in another file that still exists => this is a copy.
          overrideId = _uuid.v4();
        } else {
          existing = other; // file was renamed/moved
        }
      }
    }

    final parsed = _parse(
      kind,
      text,
      fallbackId: _uuid.v4(),
      fallbackTitle: _stemOf(f.path),
      mtime: mtime,
      preferMtime: existing != null,
      overrideId: overrideId,
    );
    if (parsed == null) {
      report.errors.add('${f.path}: invalid frontmatter, skipped');
      return;
    }
    final key = '$kind:${parsed.id}';

    final cur = await _current(kind, parsed.id);
    if (cur.exists && cur.deleted && existing != null) {
      return; // app already deleted it; export will remove the file
    }
    if (cur.exists && !cur.deleted) {
      final appHash = VaultMarkdown.hash(cur.text);
      final appChanged = existing != null ? appHash != existing.modelHash : appHash != fileHash;
      if (appChanged) {
        final short = parsed.id.length >= 8 ? parsed.id.substring(0, 8) : parsed.id;
        final cpath = '.orbit/conflicts/$kind-$short-${DateTime.now().millisecondsSinceEpoch}.md';
        await storage.writeText(cpath, cur.text);
        _paths.add(cpath.toLowerCase());
        report.conflicts++;
      }
    }

    await _apply(parsed);

    final after = await _current(kind, parsed.id);
    var fh = fileHash;
    var mtimeMs = f.modified;
    var size = f.size;
    if (parsed.idWasMissing || overrideId != null) {
      // Write the canonical file back so the id is fixed on disk.
      final res = await storage.writeText(f.path, after.text);
      fh = VaultMarkdown.hash(after.text);
      mtimeMs = res.modified;
      size = res.size;
    }

    if (knownKey != null && knownKey != key) index.entries.remove(knownKey);
    index.entries[key] = VaultIndexEntry(
      path: f.path,
      fileHash: fh,
      modelHash: after.exists ? VaultMarkdown.hash(after.text) : 0,
      mtime: mtimeMs,
      size: size,
      stem: VaultMarkdown.fileStem(after.stemSource),
    );
    report.imported++;
  }

  ParsedItem? _parse(
    String kind,
    String text, {
    required String fallbackId,
    required String fallbackTitle,
    required DateTime mtime,
    required bool preferMtime,
    String? overrideId,
  }) {
    switch (kind) {
      case 'habit':
        return VaultCodec.parseHabit(text,
            fallbackId: fallbackId,
            fallbackTitle: fallbackTitle,
            mtime: mtime,
            preferMtime: preferMtime,
            overrideId: overrideId);
      case 'task':
        return VaultCodec.parseTask(text,
            fallbackId: fallbackId,
            fallbackTitle: fallbackTitle,
            mtime: mtime,
            preferMtime: preferMtime,
            overrideId: overrideId);
      default:
        return VaultCodec.parseNote(text,
            fallbackId: fallbackId,
            fallbackTitle: fallbackTitle,
            mtime: mtime,
            preferMtime: preferMtime,
            overrideId: overrideId);
    }
  }

  Future<void> _apply(ParsedItem item) async {
    await db.transaction(() async {
      if (item is ParsedHabit) {
        await db.into(db.habitsTable).insertOnConflictUpdate(item.row);
        final entries = item.entries;
        if (entries != null) await _replaceEntries(item.id, entries);
      } else if (item is ParsedTask) {
        await db.into(db.tasksTable).insertOnConflictUpdate(item.row);
        await (db.delete(db.taskTagsTable)..where((t) => t.taskId.equals(item.id))).go();
        for (final name in item.tags) {
          final tagId = await _tagIdForName(name);
          await db.into(db.taskTagsTable).insert(
                TaskTagsTableCompanion.insert(taskId: item.id, tagId: tagId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      } else if (item is ParsedNote) {
        await db.into(db.notesTable).insertOnConflictUpdate(item.row);
        await (db.delete(db.noteTagsTable)..where((t) => t.noteId.equals(item.id))).go();
        for (final name in item.tags) {
          final tagId = await _tagIdForName(name);
          await db.into(db.noteTagsTable).insert(
                NoteTagsTableCompanion.insert(noteId: item.id, tagId: tagId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    });
  }

  Future<void> _replaceEntries(String habitId, List<ParsedEntry> entries) async {
    final existing =
        await (db.select(db.habitEntriesTable)..where((t) => t.habitId.equals(habitId))).get();
    final byDate = {for (final e in existing) e.entryDate: e};
    final wanted = {for (final e in entries) e.date: e}; // last one wins on duplicates

    for (final pe in wanted.values) {
      final cur = byDate[pe.date];
      await db.into(db.habitEntriesTable).insertOnConflictUpdate(
            HabitEntriesTableCompanion.insert(
              id: cur?.id ?? _uuid.v4(),
              habitId: habitId,
              entryDate: pe.date,
              status: Value(pe.status),
              value: Value(pe.value),
              note: Value(pe.note),
              createdAt: cur?.createdAt ?? pe.updatedAt,
              updatedAt: pe.updatedAt,
              deletedAt: const Value<DateTime?>(null),
            ),
          );
    }
    for (final e in existing) {
      if (!wanted.containsKey(e.entryDate)) {
        await (db.delete(db.habitEntriesTable)..where((t) => t.id.equals(e.id))).go();
      }
    }
  }

  Future<String> _tagIdForName(String raw) async {
    final name = raw.trim().toLowerCase().replaceAll(RegExp(r'^#'), '');
    final rows =
        await (db.select(db.tagsTable)..where((t) => t.name.equals(name) & t.deletedAt.isNull())).get();
    if (rows.isNotEmpty) return rows.first.id;
    final id = _uuid.v4();
    final now = DateTime.now();
    await db.into(db.tagsTable).insert(
          TagsTableCompanion.insert(id: id, name: name, createdAt: now, updatedAt: now),
        );
    return id;
  }

  Future<void> _softDelete(String kind, String id) async {
    final now = DateTime.now();
    switch (kind) {
      case 'habit':
        await (db.update(db.habitsTable)..where((t) => t.id.equals(id)))
            .write(HabitsTableCompanion(deletedAt: Value(now), updatedAt: Value(now)));
        break;
      case 'task':
        await (db.update(db.tasksTable)..where((t) => t.id.equals(id)))
            .write(TasksTableCompanion(deletedAt: Value(now), updatedAt: Value(now)));
        break;
      default:
        await (db.update(db.notesTable)..where((t) => t.id.equals(id)))
            .write(NotesTableCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    }
  }

  Future<void> _importMeta(
    VaultIndex index,
    Map<String, VaultFileInfo> files,
    VaultSyncReport report,
  ) async {
    try {
      if (files.containsKey('.orbit/projects.json')) {
        final text = await storage.readText('.orbit/projects.json');
        if (text != null && VaultMarkdown.hash(text) != index.projectsHash) {
          final list = VaultCodec.parseProjects(text);
          if (list != null) {
            for (final p in list) {
              await db.into(db.projectsTable).insertOnConflictUpdate(p);
            }
            final rows = await (db.select(db.projectsTable)..where((t) => t.deletedAt.isNull())).get();
            final canonical = VaultCodec.renderProjects(rows);
            await storage.writeText('.orbit/projects.json', canonical);
            index.projectsHash = VaultMarkdown.hash(canonical);
          }
        }
      }
      if (files.containsKey('.orbit/tags.json')) {
        final text = await storage.readText('.orbit/tags.json');
        if (text != null && VaultMarkdown.hash(text) != index.tagsHash) {
          final list = VaultCodec.parseTags(text);
          if (list != null) {
            for (final t in list) {
              await db.into(db.tagsTable).insertOnConflictUpdate(t);
            }
            final rows = await (db.select(db.tagsTable)..where((t) => t.deletedAt.isNull())).get();
            final canonical = VaultCodec.renderTags(rows);
            await storage.writeText('.orbit/tags.json', canonical);
            index.tagsHash = VaultMarkdown.hash(canonical);
          }
        }
      }
    } catch (e) {
      report.errors.add('meta files: $e');
    }
  }

  // ================================================================ EXPORT
  Future<void> _exportAll(VaultIndex index, VaultSyncReport report) async {
    await _exportMeta(index, report);

    // Habits (+ their check-ins)
    final habits = await db.select(db.habitsTable).get();
    final entryRows = await (db.select(db.habitEntriesTable)..where((t) => t.deletedAt.isNull())).get();
    final entriesByHabit = <String, List<HabitEntryRow>>{};
    for (final e in entryRows) {
      entriesByHabit.putIfAbsent(e.habitId, () => []).add(e);
    }
    for (final h in habits) {
      await _exportOne(
        index,
        report,
        kind: 'habit',
        id: h.id,
        deleted: h.deletedAt != null,
        stemSource: h.name,
        render: () => VaultCodec.renderHabit(h, entriesByHabit[h.id] ?? const <HabitEntryRow>[]),
      );
    }

    // Tasks
    final tasks = await db.select(db.tasksTable).get();
    final taskTags = await _tagNamesByOwner(isTask: true);
    for (final t in tasks) {
      await _exportOne(
        index,
        report,
        kind: 'task',
        id: t.id,
        deleted: t.deletedAt != null,
        stemSource: t.title,
        render: () => VaultCodec.renderTask(t, taskTags[t.id] ?? const <String>[]),
      );
    }

    // Notes
    final notes = await db.select(db.notesTable).get();
    final noteTags = await _tagNamesByOwner(isTask: false);
    for (final n in notes) {
      await _exportOne(
        index,
        report,
        kind: 'note',
        id: n.id,
        deleted: n.deletedAt != null,
        stemSource: _noteStemSource(n),
        render: () => VaultCodec.renderNote(n, noteTags[n.id] ?? const <String>[]),
      );
    }
  }

  String _noteStemSource(NoteRow n) {
    if (n.title.trim().isNotEmpty) return n.title;
    if (n.isJournal && n.journalDate != null) return 'Journal ${n.journalDate}';
    final firstLine = n.body.trim().split('\n').first.trim();
    return firstLine.isEmpty ? 'Untitled' : firstLine;
  }

  Future<Map<String, List<String>>> _tagNamesByOwner({required bool isTask}) async {
    final out = <String, List<String>>{};
    if (isTask) {
      final q = db.select(db.taskTagsTable).join([
        innerJoin(db.tagsTable, db.tagsTable.id.equalsExp(db.taskTagsTable.tagId)),
      ])
        ..where(db.tagsTable.deletedAt.isNull());
      for (final r in await q.get()) {
        out.putIfAbsent(r.readTable(db.taskTagsTable).taskId, () => []).add(r.readTable(db.tagsTable).name);
      }
    } else {
      final q = db.select(db.noteTagsTable).join([
        innerJoin(db.tagsTable, db.tagsTable.id.equalsExp(db.noteTagsTable.tagId)),
      ])
        ..where(db.tagsTable.deletedAt.isNull());
      for (final r in await q.get()) {
        out.putIfAbsent(r.readTable(db.noteTagsTable).noteId, () => []).add(r.readTable(db.tagsTable).name);
      }
    }
    return out;
  }

  Future<void> _exportMeta(VaultIndex index, VaultSyncReport report) async {
    try {
      final projects = await (db.select(db.projectsTable)..where((t) => t.deletedAt.isNull())).get();
      final pText = VaultCodec.renderProjects(projects);
      final pHash = VaultMarkdown.hash(pText);
      if (pHash != index.projectsHash || !_paths.contains('.orbit/projects.json')) {
        await storage.writeText('.orbit/projects.json', pText);
        _paths.add('.orbit/projects.json');
        index.projectsHash = pHash;
        report.exported++;
      }

      final tags = await (db.select(db.tagsTable)..where((t) => t.deletedAt.isNull())).get();
      final tText = VaultCodec.renderTags(tags);
      final tHash = VaultMarkdown.hash(tText);
      if (tHash != index.tagsHash || !_paths.contains('.orbit/tags.json')) {
        await storage.writeText('.orbit/tags.json', tText);
        _paths.add('.orbit/tags.json');
        index.tagsHash = tHash;
        report.exported++;
      }
    } catch (e) {
      report.errors.add('meta export: $e');
    }
  }

  Future<void> _exportOne(
    VaultIndex index,
    VaultSyncReport report, {
    required String kind,
    required String id,
    required bool deleted,
    required String stemSource,
    required String Function() render,
  }) async {
    final key = '$kind:$id';
    final known = index.entries[key];

    if (deleted) {
      if (known != null) {
        try {
          await storage.delete(known.path);
        } catch (e) {
          report.errors.add('delete ${known.path}: $e');
          return;
        }
        _paths.remove(known.path.toLowerCase());
        index.entries.remove(key);
        report.removedFromVault++;
      }
      return;
    }

    final text = render();
    final modelHash = VaultMarkdown.hash(text);
    if (known != null && known.modelHash == modelHash && _paths.contains(known.path.toLowerCase())) {
      return; // already up to date
    }

    final stem = VaultMarkdown.fileStem(stemSource);
    final String path;
    if (known != null && known.stem == stem) {
      path = known.path; // keep the current file (even if user renamed it in Obsidian)
    } else {
      path = _uniquePath('${kind}s', stem, id, except: known?.path);
    }

    try {
      final res = await storage.writeText(path, text);
      if (known != null && known.path != path) {
        try {
          await storage.delete(known.path);
        } catch (_) {}
        _paths.remove(known.path.toLowerCase());
      }
      _paths.add(path.toLowerCase());
      index.entries[key] = VaultIndexEntry(
        path: path,
        fileHash: VaultMarkdown.hash(text),
        modelHash: modelHash,
        mtime: res.modified,
        size: res.size,
        stem: stem,
      );
      report.exported++;
    } catch (e) {
      report.errors.add('write $path: $e');
    }
  }

  String _uniquePath(String dir, String stem, String id, {String? except}) {
    bool taken(String p) =>
        _paths.contains(p.toLowerCase()) && (except == null || p.toLowerCase() != except.toLowerCase());
    var candidate = '$dir/$stem.md';
    if (!taken(candidate)) return candidate;
    final short = id.length >= 8 ? id.substring(0, 8) : id;
    candidate = '$dir/$stem ($short).md';
    var n = 2;
    while (taken(candidate)) {
      candidate = '$dir/$stem ($short-$n).md';
      n++;
    }
    return candidate;
  }

  String _stemOf(String path) {
    final name = path.split('/').last;
    return name.toLowerCase().endsWith('.md') ? name.substring(0, name.length - 3) : name;
  }

  // ============================================================== HELPERS
  Future<_Current> _current(String kind, String id) async {
    switch (kind) {
      case 'habit':
        {
          final h = await (db.select(db.habitsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
          if (h == null) return const _Current.none();
          final entries = await (db.select(db.habitEntriesTable)
                ..where((t) => t.habitId.equals(id) & t.deletedAt.isNull()))
              .get();
          return _Current(
            exists: true,
            deleted: h.deletedAt != null,
            text: VaultCodec.renderHabit(h, entries),
            stemSource: h.name,
          );
        }
      case 'task':
        {
          final t = await (db.select(db.tasksTable)..where((x) => x.id.equals(id))).getSingleOrNull();
          if (t == null) return const _Current.none();
          final q = db.select(db.taskTagsTable).join([
            innerJoin(db.tagsTable, db.tagsTable.id.equalsExp(db.taskTagsTable.tagId)),
          ])
            ..where(db.taskTagsTable.taskId.equals(id) & db.tagsTable.deletedAt.isNull());
          final names = (await q.get()).map((r) => r.readTable(db.tagsTable).name).toList();
          return _Current(
            exists: true,
            deleted: t.deletedAt != null,
            text: VaultCodec.renderTask(t, names),
            stemSource: t.title,
          );
        }
      default:
        {
          final n = await (db.select(db.notesTable)..where((x) => x.id.equals(id))).getSingleOrNull();
          if (n == null) return const _Current.none();
          final q = db.select(db.noteTagsTable).join([
            innerJoin(db.tagsTable, db.tagsTable.id.equalsExp(db.noteTagsTable.tagId)),
          ])
            ..where(db.noteTagsTable.noteId.equals(id) & db.tagsTable.deletedAt.isNull());
          final names = (await q.get()).map((r) => r.readTable(db.tagsTable).name).toList();
          return _Current(
            exists: true,
            deleted: n.deletedAt != null,
            text: VaultCodec.renderNote(n, names),
            stemSource: _noteStemSource(n),
          );
        }
    }
  }
}
