import 'package:drift/drift.dart';
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/domain/logic/markdown_lite.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:uuid/uuid.dart';

class NoteRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  NoteRepository(this._db, [Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  Note _mapNote(NoteRow row, [List<String> tags = const []]) {
    return Note(
      id: row.id,
      title: row.title,
      body: row.body,
      colorLabel: row.colorLabel,
      isPinned: row.isPinned,
      isJournal: row.isJournal,
      journalDate: row.journalDate,
      linkedTaskId: row.linkedTaskId,
      linkedHabitId: row.linkedHabitId,
      tags: tags,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  // --- Tags Helpers ---

  Future<List<String>> getNoteTags(String noteId) async {
    final query = _db.select(_db.noteTagsTable).join([
      innerJoin(
        _db.tagsTable,
        _db.tagsTable.id.equalsExp(_db.noteTagsTable.tagId),
      ),
    ])..where(_db.noteTagsTable.noteId.equals(noteId) & _db.tagsTable.deletedAt.isNull());

    final results = await query.get();
    return results.map((row) => row.readTable(_db.tagsTable).name).toList();
  }

  Future<String> _getOrCreateTagId(String tagName) async {
    final cleanName = tagName.trim().toLowerCase().replaceAll(RegExp(r'^#'), '');
    final existing = await (_db.select(_db.tagsTable)
          ..where((tbl) => tbl.name.equals(cleanName) & tbl.deletedAt.isNull()))
        .getSingleOrNull();

    if (existing != null) {
      return existing.id;
    }

    final newId = _uuid.v4();
    final now = DateTime.now();
    await _db.into(_db.tagsTable).insert(
      TagsTableCompanion.insert(
        id: newId,
        name: cleanName,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return newId;
  }

  // --- Note Queries ---

  Future<Note?> getNoteById(String id) async {
    final query = _db.select(_db.notesTable)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final tags = await getNoteTags(row.id);
    return _mapNote(row, tags);
  }

  Stream<Note?> watchNoteById(String id) {
    final query = _db.select(_db.notesTable)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      final tags = await getNoteTags(row.id);
      return _mapNote(row, tags);
    });
  }

  Stream<List<Note>> watchNotes({
    String? tag,
    int? colorLabel,
    bool? onlyPinned,
    bool includeJournal = true,
  }) {
    final query = _db.select(_db.notesTable)
      ..where((tbl) {
        var predicate = tbl.deletedAt.isNull();
        if (onlyPinned == true) {
          predicate = predicate & tbl.isPinned.equals(true);
        }
        if (colorLabel != null && colorLabel > 0) {
          predicate = predicate & tbl.colorLabel.equals(colorLabel);
        }
        if (!includeJournal) {
          predicate = predicate & tbl.isJournal.equals(false);
        }
        return predicate;
      })
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.isPinned, mode: OrderingMode.desc),
        (tbl) => OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc),
      ]);

    return query.watch().asyncMap((rows) async {
      final cleanFilterTag = tag?.trim().toLowerCase().replaceAll(RegExp(r'^#'), '');
      final notes = <Note>[];
      for (final row in rows) {
        final tags = await getNoteTags(row.id);
        if (cleanFilterTag != null &&
            cleanFilterTag.isNotEmpty &&
            !tags.map((t) => t.toLowerCase()).contains(cleanFilterTag)) {
          continue;
        }
        notes.add(_mapNote(row, tags));
      }
      return notes;
    });
  }

  Stream<List<Note>> watchPinnedNotes() {
    return watchNotes(onlyPinned: true);
  }

  // --- Journal Notes ---

  Future<Note?> getTodayJournalNote(String dateStr) async {
    final query = _db.select(_db.notesTable)
      ..where((tbl) =>
          tbl.isJournal.equals(true) &
          tbl.journalDate.equals(dateStr) &
          tbl.deletedAt.isNull());
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final tags = await getNoteTags(row.id);
    return _mapNote(row, tags);
  }

  Future<Note> getOrCreateTodayJournalNote(String dateStr) async {
    final existing = await getTodayJournalNote(dateStr);
    if (existing != null) return existing;

    final newNote = Note(
      id: _uuid.v4(),
      title: 'Daily Journal - $dateStr',
      body: '',
      colorLabel: NoteColorLabel.teal,
      isPinned: false,
      isJournal: true,
      journalDate: dateStr,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createNote(newNote, tagNames: ['journal']);
  }

  Stream<List<Note>> watchJournalNotes() {
    final query = _db.select(_db.notesTable)
      ..where((tbl) => tbl.isJournal.equals(true) & tbl.deletedAt.isNull())
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.journalDate, mode: OrderingMode.desc),
        (tbl) => OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc),
      ]);

    return query.watch().asyncMap((rows) async {
      final notes = <Note>[];
      for (final row in rows) {
        final tags = await getNoteTags(row.id);
        notes.add(_mapNote(row, tags));
      }
      return notes;
    });
  }

  // --- Mutations ---

  Future<Note> createNote(Note note, {List<String> tagNames = const []}) async {
    final now = DateTime.now();
    final noteId = note.id.isEmpty ? _uuid.v4() : note.id;

    await _db.transaction(() async {
      await _db.into(_db.notesTable).insert(
        NotesTableCompanion.insert(
          id: noteId,
          title: Value(note.title),
          body: Value(note.body),
          colorLabel: Value(note.colorLabel),
          isPinned: Value(note.isPinned),
          isJournal: Value(note.isJournal),
          journalDate: Value(note.journalDate),
          linkedTaskId: Value(note.linkedTaskId),
          linkedHabitId: Value(note.linkedHabitId),
          createdAt: note.createdAt,
          updatedAt: now,
        ),
      );

      final allTags = {...note.tags, ...tagNames};
      for (final tag in allTags) {
        if (tag.trim().isEmpty) continue;
        final tagId = await _getOrCreateTagId(tag);
        await _db.into(_db.noteTagsTable).insert(
          NoteTagsTableCompanion.insert(noteId: noteId, tagId: tagId),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });

    final created = await getNoteById(noteId);
    return created!;
  }

  Future<void> updateNote(Note note, {List<String>? tagNames}) async {
    final now = DateTime.now();

    await _db.transaction(() async {
      await (_db.update(_db.notesTable)..where((tbl) => tbl.id.equals(note.id))).write(
        NotesTableCompanion(
          title: Value(note.title),
          body: Value(note.body),
          colorLabel: Value(note.colorLabel),
          isPinned: Value(note.isPinned),
          isJournal: Value(note.isJournal),
          journalDate: Value(note.journalDate),
          linkedTaskId: Value(note.linkedTaskId),
          linkedHabitId: Value(note.linkedHabitId),
          updatedAt: Value(now),
        ),
      );

      if (tagNames != null) {
        await (_db.delete(_db.noteTagsTable)
              ..where((tbl) => tbl.noteId.equals(note.id)))
            .go();

        for (final tag in tagNames) {
          if (tag.trim().isEmpty) continue;
          final tagId = await _getOrCreateTagId(tag);
          await _db.into(_db.noteTagsTable).insert(
            NoteTagsTableCompanion.insert(noteId: note.id, tagId: tagId),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });
  }

  Future<void> softDeleteNote(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.notesTable)..where((tbl) => tbl.id.equals(id))).write(
      NotesTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> restoreNote(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.notesTable)..where((tbl) => tbl.id.equals(id))).write(
      NotesTableCompanion(deletedAt: const Value(null), updatedAt: Value(now)),
    );
  }

  Future<void> setPinned(String id, bool isPinned) async {
    final now = DateTime.now();
    await (_db.update(_db.notesTable)..where((tbl) => tbl.id.equals(id))).write(
      NotesTableCompanion(isPinned: Value(isPinned), updatedAt: Value(now)),
    );
  }

  Future<void> setColorLabel(String id, int colorLabel) async {
    final now = DateTime.now();
    await (_db.update(_db.notesTable)..where((tbl) => tbl.id.equals(id))).write(
      NotesTableCompanion(colorLabel: Value(colorLabel), updatedAt: Value(now)),
    );
  }

  Future<void> toggleChecklist(String noteId, int lineIndex) async {
    final note = await getNoteById(noteId);
    if (note == null) return;

    final updatedBody = MarkdownLite.toggleChecklistLine(note.body, lineIndex);
    await updateNote(note.copyWith(body: updatedBody));
  }
}
