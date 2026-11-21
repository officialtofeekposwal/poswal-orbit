import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/data/repositories/note_repository.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NoteRepository(db);
});

class NoteFilterTagNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setTag(String? tag) => state = tag;
}

final noteFilterTagProvider = NotifierProvider<NoteFilterTagNotifier, String?>(
  NoteFilterTagNotifier.new,
);

class NoteFilterColorNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setColor(int? color) => state = color;
}

final noteFilterColorProvider = NotifierProvider<NoteFilterColorNotifier, int?>(
  NoteFilterColorNotifier.new,
);

final notesStreamProvider = StreamProvider<List<Note>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  final tag = ref.watch(noteFilterTagProvider);
  final color = ref.watch(noteFilterColorProvider);

  return repo.watchNotes(tag: tag, colorLabel: color);
});

final pinnedNotesStreamProvider = StreamProvider<List<Note>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.watchPinnedNotes();
});

final todayJournalNoteProvider = FutureProvider<Note>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final dateStr = DateBoundary.toDateString(selectedDate);
  return repo.getOrCreateTodayJournalNote(dateStr);
});

final noteDetailStreamProvider = StreamProvider.family<Note?, String>((ref, id) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.watchNoteById(id);
});

