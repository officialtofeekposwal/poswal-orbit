import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/repositories/note_repository.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late NoteRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = NoteRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('NoteRepository CRUD, Journal & Filtering Tests', () {
    test('Create and retrieve note with tags and custom color label', () async {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        title: 'Weekly Sprint Ideas',
        body: '# Ideas\n- [ ] Ship Phase 3A',
        colorLabel: NoteColorLabel.coral,
        createdAt: now,
        updatedAt: now,
      );

      final created = await repo.createNote(note, tagNames: ['flutter', 'orbit']);
      expect(created.id, 'note-1');
      expect(created.title, 'Weekly Sprint Ideas');
      expect(created.colorLabel, NoteColorLabel.coral);
      expect(created.tags, containsAll(['flutter', 'orbit']));

      final fetched = await repo.getNoteById('note-1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Weekly Sprint Ideas');
      expect(fetched.tags.length, 2);
    });

    test('Pinned notes appear first in watchNotes stream', () async {
      final now = DateTime.now();

      await repo.createNote(Note(
        id: 'unpinned-1',
        title: 'Regular Note',
        isPinned: false,
        createdAt: now,
        updatedAt: now,
      ));

      await repo.createNote(Note(
        id: 'pinned-1',
        title: 'High Priority Note',
        isPinned: true,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ));

      final notes = await repo.watchNotes().first;
      expect(notes.length, 2);
      expect(notes.first.id, 'pinned-1'); // Pinned comes first
      expect(notes.first.isPinned, isTrue);
      expect(notes.last.id, 'unpinned-1');
    });

    test('Filter notes by color label and tags', () async {
      final now = DateTime.now();

      await repo.createNote(
        Note(id: 'n1', title: 'Teal Note', colorLabel: NoteColorLabel.teal, createdAt: now, updatedAt: now),
        tagNames: ['work'],
      );
      await repo.createNote(
        Note(id: 'n2', title: 'Violet Note', colorLabel: NoteColorLabel.violet, createdAt: now, updatedAt: now),
        tagNames: ['personal'],
      );

      // Filter by color
      final tealNotes = await repo.watchNotes(colorLabel: NoteColorLabel.teal).first;
      expect(tealNotes.length, 1);
      expect(tealNotes.first.id, 'n1');

      // Filter by tag
      final personalNotes = await repo.watchNotes(tag: 'personal').first;
      expect(personalNotes.length, 1);
      expect(personalNotes.first.id, 'n2');
    });

    test('Daily Journal Note: getOrCreateTodayJournalNote creates today note and retrieves same instance', () async {
      const todayStr = '2026-11-21';

      // 1. First call creates the journal note
      final created = await repo.getOrCreateTodayJournalNote(todayStr);
      expect(created.isJournal, isTrue);
      expect(created.journalDate, todayStr);
      expect(created.title, 'Daily Journal - $todayStr');
      expect(created.tags, contains('journal'));

      // 2. Second call returns the existing one (does not duplicate)
      final secondFetch = await repo.getOrCreateTodayJournalNote(todayStr);
      expect(secondFetch.id, created.id);
    });

    test('Soft delete note excludes from watchNotes and restoreNote recovers it', () async {
      final now = DateTime.now();
      await repo.createNote(Note(
        id: 'del-note',
        title: 'To be deleted',
        createdAt: now,
        updatedAt: now,
      ));

      // Active
      var notes = await repo.watchNotes().first;
      expect(notes.any((n) => n.id == 'del-note'), isTrue);

      // Soft delete
      await repo.softDeleteNote('del-note');
      notes = await repo.watchNotes().first;
      expect(notes.any((n) => n.id == 'del-note'), isFalse);

      // Restore
      await repo.restoreNote('del-note');
      notes = await repo.watchNotes().first;
      expect(notes.any((n) => n.id == 'del-note'), isTrue);
    });

    test('toggleChecklist persists updated markdown in SQLite database', () async {
      final now = DateTime.now();
      await repo.createNote(Note(
        id: 'check-note',
        title: 'Checklist note',
        body: '# Tasks\n- [ ] Pack bags\n- [ ] Call taxi',
        createdAt: now,
        updatedAt: now,
      ));

      // Toggle line 1 (Pack bags)
      await repo.toggleChecklist('check-note', 1);

      final updated = await repo.getNoteById('check-note');
      expect(updated!.body, contains('- [x] Pack bags'));
      expect(updated.body, contains('- [ ] Call taxi'));
    });
  });
}
