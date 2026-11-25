import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/vault/dir_vault_storage.dart';
import 'package:poswal_orbit/data/vault/vault_codec.dart';
import 'package:poswal_orbit/data/vault/vault_index.dart';
import 'package:poswal_orbit/data/vault/vault_sync_service.dart';

Future<void> _seed(AppDatabase db) async {
  final now = DateTime(2026, 11, 25, 10);
  await db.into(db.habitsTable).insert(HabitsTableCompanion.insert(
        id: 'habit-1111-aaaa',
        name: 'Morning Run',
        colorValue: 0xFF14B8A6,
        startDate: DateTime(2026, 1, 1),
        createdAt: now,
        updatedAt: now,
      ));
  await db.into(db.habitEntriesTable).insert(HabitEntriesTableCompanion.insert(
        id: 'entry-1',
        habitId: 'habit-1111-aaaa',
        entryDate: '2026-11-25',
        status: const Value('done'),
        createdAt: now,
        updatedAt: now,
      ));
  await db.into(db.tasksTable).insert(TasksTableCompanion.insert(
        id: 'task-2222-bbbb',
        title: 'Buy milk',
        createdAt: now,
        updatedAt: now,
      ));
  await db.into(db.notesTable).insert(NotesTableCompanion.insert(
        id: 'note-3333-cccc',
        title: const Value('Idea'),
        body: const Value('Hello vault'),
        createdAt: now,
        updatedAt: now,
      ));
}

VaultSyncService _svc(AppDatabase db, Directory vault, Directory idxDir) => VaultSyncService(
      db: db,
      storage: DirVaultStorage(vault),
      indexStore: VaultIndexStore(File('${idxDir.path}/index.json')),
    );

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late Directory vault;
  late Directory idxDir;
  late VaultSyncService svc;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    vault = await Directory.systemTemp.createTemp('orbit_vault_');
    idxDir = await Directory.systemTemp.createTemp('orbit_idx_');
    svc = _svc(db, vault, idxDir);
    await svc.initializeVaultIfNeeded();
  });

  tearDown(() async {
    await db.close();
    if (await vault.exists()) await vault.delete(recursive: true);
    if (await idxDir.exists()) await idxDir.delete(recursive: true);
  });

  test('export creates markdown files with check-ins', () async {
    await _seed(db);
    final r = await svc.syncNow();
    expect(r.errors, isEmpty);
    final habitFile = File('${vault.path}/habits/Morning Run.md');
    expect(habitFile.existsSync(), isTrue);
    expect(habitFile.readAsStringSync(), contains('"d":"2026-11-25"'));
    expect(File('${vault.path}/tasks/Buy milk.md').existsSync(), isTrue);
    expect(File('${vault.path}/notes/Idea.md').existsSync(), isTrue);
    expect(File('${vault.path}/.orbit/vault.json').existsSync(), isTrue);
  });

  test('reinstall: fresh database + same folder restores everything', () async {
    await _seed(db);
    await svc.syncNow();

    final db2 = AppDatabase(NativeDatabase.memory());
    final idx2 = await Directory.systemTemp.createTemp('orbit_idx2_');
    final svc2 = _svc(db2, vault, idx2);
    final r = await svc2.syncNow();

    expect(r.errors, isEmpty);
    expect((await db2.select(db2.habitsTable).get()).single.name, 'Morning Run');
    expect((await db2.select(db2.habitEntriesTable).get()).single.entryDate, '2026-11-25');
    expect((await db2.select(db2.tasksTable).get()).single.title, 'Buy milk');
    expect((await db2.select(db2.notesTable).get()).single.body, 'Hello vault');

    await db2.close();
    await idx2.delete(recursive: true);
  });

  test('external edit in Obsidian is imported', () async {
    await _seed(db);
    await svc.syncNow();
    final f = File('${vault.path}/notes/Idea.md');
    f.writeAsStringSync(f.readAsStringSync().replaceAll('Hello vault', 'Edited in Obsidian, longer text'));

    final r = await svc.syncNow();
    expect(r.imported, 1);
    final note = await (db.select(db.notesTable)..where((t) => t.id.equals('note-3333-cccc'))).getSingle();
    expect(note.body, 'Edited in Obsidian, longer text');
  });

  test('deleting a file in the vault soft-deletes the item in the app', () async {
    await _seed(db);
    await svc.syncNow();
    File('${vault.path}/notes/Idea.md').deleteSync();

    final r = await svc.syncNow();
    expect(r.deletedInApp, 1);
    final note = await (db.select(db.notesTable)..where((t) => t.id.equals('note-3333-cccc'))).getSingle();
    expect(note.deletedAt, isNotNull);
  });

  test('deleting an item in the app removes its file', () async {
    await _seed(db);
    await svc.syncNow();
    await (db.update(db.notesTable)..where((t) => t.id.equals('note-3333-cccc')))
        .write(NotesTableCompanion(deletedAt: Value(DateTime.now())));

    await svc.exportDirty();
    expect(File('${vault.path}/notes/Idea.md').existsSync(), isFalse);
  });

  test('malformed file is skipped and reported, nothing is lost', () async {
    await _seed(db);
    await svc.syncNow();
    File('${vault.path}/notes/Bad.md').writeAsStringSync('---\nfoo: [unclosed\n---\nbody');

    final r = await svc.syncNow();
    expect(r.errors, isNotEmpty);
    expect((await db.select(db.notesTable).get()).length, 1);
  });

  test('plain markdown file created in Obsidian becomes a note and gets an id', () async {
    await _seed(db);
    await svc.syncNow();
    final f = File('${vault.path}/notes/Made in Obsidian.md')..writeAsStringSync('Just text');

    await svc.syncNow();
    final notes = await db.select(db.notesTable).get();
    expect(notes.length, 2);
    final created = notes.firstWhere((n) => n.title == 'Made in Obsidian');
    expect(created.body, 'Just text');
    expect(f.readAsStringSync(), contains(created.id));
  });

  test('copying a note file (same id) creates a second note with a new id', () async {
    await _seed(db);
    await svc.syncNow();
    File('${vault.path}/notes/Idea.md').copySync('${vault.path}/notes/Idea copy.md');

    await svc.syncNow();
    final notes = await db.select(db.notesTable).get();
    expect(notes.length, 2);
    expect(notes.map((n) => n.id).toSet().length, 2);
  });

  test('habit render/parse roundtrip keeps check-ins', () async {
    await _seed(db);
    final h = await db.select(db.habitsTable).getSingle();
    final entries = await db.select(db.habitEntriesTable).get();
    final text = VaultCodec.renderHabit(h, entries);
    final parsed = VaultCodec.parseHabit(
      text,
      fallbackId: 'x',
      fallbackTitle: 'y',
      mtime: DateTime.now(),
      preferMtime: false,
    )!;
    expect(parsed.id, h.id);
    expect(parsed.title, 'Morning Run');
    expect(parsed.entries!.single.date, '2026-11-25');
    expect(parsed.entries!.single.status, 'done');
  });
}
