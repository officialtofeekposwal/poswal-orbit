import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/data/vault/vault_markdown.dart';

class ParsedEntry {
  final String date; // YYYY-MM-DD
  final String status;
  final double value;
  final String? note;
  final DateTime updatedAt;
  const ParsedEntry({
    required this.date,
    required this.status,
    required this.value,
    required this.note,
    required this.updatedAt,
  });
}

abstract class ParsedItem {
  final String id;
  final String title;
  final bool idWasMissing;
  const ParsedItem(this.id, this.title, this.idWasMissing);
}

class ParsedHabit extends ParsedItem {
  final HabitsTableCompanion row;

  /// null => file has no check-in block: leave DB entries alone.
  final List<ParsedEntry>? entries;
  const ParsedHabit({
    required String id,
    required String title,
    required bool idWasMissing,
    required this.row,
    required this.entries,
  }) : super(id, title, idWasMissing);
}

class ParsedTask extends ParsedItem {
  final TasksTableCompanion row;
  final List<String> tags;
  const ParsedTask({
    required String id,
    required String title,
    required bool idWasMissing,
    required this.row,
    required this.tags,
  }) : super(id, title, idWasMissing);
}

class ParsedNote extends ParsedItem {
  final NotesTableCompanion row;
  final List<String> tags;
  const ParsedNote({
    required String id,
    required String title,
    required bool idWasMissing,
    required this.row,
    required this.tags,
  }) : super(id, title, idWasMissing);
}

abstract final class VaultCodec {
  // ---------- small converters ----------
  static String _iso(DateTime d) => d.toUtc().toIso8601String();

  static String? _s(Object? v) {
    if (v == null) return null;
    final t = v.toString().trim();
    return t.isEmpty ? null : t;
  }

  static int? _i(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  static double? _n(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  static bool? _b(Object? v) {
    if (v is bool) return v;
    if (v is String) {
      final t = v.trim().toLowerCase();
      if (t == 'true' || t == 'yes') return true;
      if (t == 'false' || t == 'no') return false;
    }
    return null;
  }

  static DateTime? _d(Object? v) {
    if (v is DateTime) return v.toLocal();
    if (v is String) return DateTime.tryParse(v.trim())?.toLocal();
    return null;
  }

  static List<int> _ints(Object? v) {
    if (v is List) return v.map(_i).whereType<int>().toList();
    if (v is String) {
      return v.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toList();
    }
    return const <int>[];
  }

  static List<String> _tags(Object? v) {
    final Iterable<String> raw = v is List
        ? v.map((e) => e.toString())
        : (v is String ? v.split(',') : const <String>[]);
    return raw
        .map((s) => s.trim().toLowerCase().replaceAll(RegExp(r'^#'), ''))
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  }

  /// Returns the `id` from frontmatter without fully parsing, or null.
  static String? peekId(String text) {
    final doc = VaultMarkdown.decode(text);
    return doc == null ? null : _s(doc.meta['id']);
  }

  // ---------- HABIT ----------
  static String renderHabit(HabitRow h, List<HabitEntryRow> entries) {
    final sorted = [...entries]..sort((a, b) => a.entryDate.compareTo(b.entryDate));
    final meta = <String, Object?>{
      'orbit_type': 'habit',
      'id': h.id,
      'name': h.name,
      'icon': h.iconName,
      'color': h.colorValue,
      'habit_type': h.habitType,
      'target_value': h.targetValue,
      'unit': h.unit,
      'time_of_day': h.timeOfDay,
      'schedule_type': h.scheduleType,
      'schedule_days': _ints(h.scheduleDays),
      'target_days_per_period': h.targetDaysPerPeriod,
      'every_n_days': h.everyNDaysInterval,
      'start_date': _iso(h.startDate),
      'end_date': h.endDate == null ? null : _iso(h.endDate!),
      'archived': h.isArchived,
      'sort_order': h.sortOrder,
      'created': _iso(h.createdAt),
      'updated': _iso(h.updatedAt),
    };
    final body = StringBuffer()
      ..write((h.description ?? '').trim())
      ..write('\n\n## Check-ins\n\n```jsonl\n');
    for (final e in sorted) {
      final line = <String, Object?>{
        'd': e.entryDate,
        's': e.status,
        'v': e.value,
        if (e.note != null && e.note!.isNotEmpty) 'n': e.note,
        'u': _iso(e.updatedAt),
      };
      body.write('${jsonEncode(line)}\n');
    }
    body.write('```\n');
    return VaultMarkdown.encode(meta, body.toString());
  }

  static ParsedHabit? parseHabit(
    String text, {
    required String fallbackId,
    required String fallbackTitle,
    required DateTime mtime,
    required bool preferMtime,
    String? overrideId,
  }) {
    final doc = VaultMarkdown.decode(text);
    if (doc == null) return null;
    final m = doc.meta;
    final metaId = _s(m['id']);
    final idMissing = metaId == null;
    final id = overrideId ?? (idMissing ? fallbackId : metaId);
    final name = _s(m['name']) ?? fallbackTitle;
    final updatedAt = preferMtime ? mtime : (_d(m['updated']) ?? mtime);

    var description = doc.body;
    List<ParsedEntry>? entries;
    final markers = RegExp(r'^## Check-ins[ \t]*$', multiLine: true).allMatches(doc.body).toList();
    if (markers.isNotEmpty) {
      final marker = markers.last;
      description = doc.body.substring(0, marker.start);
      final rest = doc.body.substring(marker.end);
      final fence = RegExp(r'```jsonl[ \t]*\n([\s\S]*?)```').firstMatch(rest);
      if (fence != null) {
        final list = <ParsedEntry>[];
        for (final line in fence.group(1)!.split('\n')) {
          final t = line.trim();
          if (t.isEmpty) continue;
          try {
            final map = jsonDecode(t) as Map<String, dynamic>;
            final d = map['d']?.toString() ?? '';
            if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(d)) continue;
            list.add(ParsedEntry(
              date: d,
              status: map['s']?.toString() ?? 'done',
              value: (map['v'] as num?)?.toDouble() ?? 1.0,
              note: map['n']?.toString(),
              updatedAt: DateTime.tryParse(map['u']?.toString() ?? '')?.toLocal() ?? updatedAt,
            ));
          } catch (_) {
            // skip a broken line, keep the rest
          }
        }
        entries = list;
      }
    }
    final desc = description.trim();

    final row = HabitsTableCompanion.insert(
      id: id,
      name: name,
      colorValue: _i(m['color']) ?? 0xFF14B8A6,
      startDate: _d(m['start_date']) ?? _d(m['created']) ?? updatedAt,
      createdAt: _d(m['created']) ?? updatedAt,
      updatedAt: updatedAt,
      description: Value(desc.isEmpty ? null : desc),
      iconName: Value(_s(m['icon']) ?? 'target'),
      habitType: Value(_s(m['habit_type']) ?? 'yesNo'),
      targetValue: Value(_n(m['target_value']) ?? 1.0),
      unit: Value(_s(m['unit']) ?? 'times'),
      timeOfDay: Value(_s(m['time_of_day']) ?? 'anytime'),
      scheduleType: Value(_s(m['schedule_type']) ?? 'daily'),
      scheduleDays: Value(_ints(m['schedule_days']).join(',')),
      targetDaysPerPeriod: Value(_i(m['target_days_per_period']) ?? 1),
      everyNDaysInterval: Value(_i(m['every_n_days']) ?? 1),
      endDate: Value(_d(m['end_date'])),
      isArchived: Value(_b(m['archived']) ?? false),
      sortOrder: Value(_i(m['sort_order']) ?? 0),
      deletedAt: const Value<DateTime?>(null),
    );
    return ParsedHabit(id: id, title: name, idWasMissing: idMissing, row: row, entries: entries);
  }

  // ---------- TASK ----------
  static String renderTask(TaskRow t, List<String> tagNames) {
    final tags = [...tagNames]..sort();
    final meta = <String, Object?>{
      'orbit_type': 'task',
      'id': t.id,
      'parent_id': t.parentId,
      'title': t.title,
      'status': t.isCompleted ? 'done' : 'open',
      'priority': t.priority,
      'due': t.dueAt == null ? null : _iso(t.dueAt!),
      'has_time': t.hasTime,
      'project_id': t.projectId,
      'repeat_rule': t.repeatRule,
      'completed': t.completedAt == null ? null : _iso(t.completedAt!),
      'linked_habit_id': t.linkedHabitId,
      'sort_order': t.sortOrder,
      'created': _iso(t.createdAt),
      'updated': _iso(t.updatedAt),
      'tags': tags,
    };
    return VaultMarkdown.encode(meta, t.notes ?? '');
  }

  static ParsedTask? parseTask(
    String text, {
    required String fallbackId,
    required String fallbackTitle,
    required DateTime mtime,
    required bool preferMtime,
    String? overrideId,
  }) {
    final doc = VaultMarkdown.decode(text);
    if (doc == null) return null;
    final m = doc.meta;
    final metaId = _s(m['id']);
    final idMissing = metaId == null;
    final id = overrideId ?? (idMissing ? fallbackId : metaId);
    final title = _s(m['title']) ?? fallbackTitle;
    final updatedAt = preferMtime ? mtime : (_d(m['updated']) ?? mtime);
    final status = (_s(m['status']) ?? 'open').toLowerCase();
    final done = status == 'done' || status == 'completed' || status == 'true';

    final row = TasksTableCompanion.insert(
      id: id,
      title: title,
      createdAt: _d(m['created']) ?? updatedAt,
      updatedAt: updatedAt,
      parentId: Value(_s(m['parent_id'])),
      notes: Value(doc.body.isEmpty ? null : doc.body),
      dueAt: Value(_d(m['due'])),
      hasTime: Value(_b(m['has_time']) ?? false),
      priority: Value(_i(m['priority']) ?? 4),
      projectId: Value(_s(m['project_id'])),
      repeatRule: Value(_s(m['repeat_rule'])),
      isCompleted: Value(done),
      completedAt: Value(_d(m['completed'])),
      linkedHabitId: Value(_s(m['linked_habit_id'])),
      sortOrder: Value(_i(m['sort_order']) ?? 0),
      deletedAt: const Value<DateTime?>(null),
    );
    return ParsedTask(
      id: id,
      title: title,
      idWasMissing: idMissing,
      row: row,
      tags: _tags(m['tags']),
    );
  }

  // ---------- NOTE ----------
  static String renderNote(NoteRow n, List<String> tagNames) {
    final tags = [...tagNames]..sort();
    final meta = <String, Object?>{
      'orbit_type': 'note',
      'id': n.id,
      'title': n.title,
      'color_label': n.colorLabel,
      'pinned': n.isPinned,
      'journal': n.isJournal,
      'journal_date': n.journalDate,
      'linked_task_id': n.linkedTaskId,
      'linked_habit_id': n.linkedHabitId,
      'created': _iso(n.createdAt),
      'updated': _iso(n.updatedAt),
      'tags': tags,
    };
    return VaultMarkdown.encode(meta, n.body);
  }

  static ParsedNote? parseNote(
    String text, {
    required String fallbackId,
    required String fallbackTitle,
    required DateTime mtime,
    required bool preferMtime,
    String? overrideId,
  }) {
    final doc = VaultMarkdown.decode(text);
    if (doc == null) return null;
    final m = doc.meta;
    final metaId = _s(m['id']);
    final idMissing = metaId == null;
    final id = overrideId ?? (idMissing ? fallbackId : metaId);
    // A note may legitimately have an empty title, so only fall back to the
    // file name when the key is absent altogether.
    final title = m.containsKey('title') ? (m['title']?.toString() ?? '') : fallbackTitle;
    final updatedAt = preferMtime ? mtime : (_d(m['updated']) ?? mtime);

    final row = NotesTableCompanion.insert(
      id: id,
      createdAt: _d(m['created']) ?? updatedAt,
      updatedAt: updatedAt,
      title: Value(title),
      body: Value(doc.body),
      colorLabel: Value(_i(m['color_label']) ?? 0),
      isPinned: Value(_b(m['pinned']) ?? false),
      isJournal: Value(_b(m['journal']) ?? false),
      journalDate: Value(_s(m['journal_date'])),
      linkedTaskId: Value(_s(m['linked_task_id'])),
      linkedHabitId: Value(_s(m['linked_habit_id'])),
      deletedAt: const Value<DateTime?>(null),
    );
    return ParsedNote(
      id: id,
      title: title,
      idWasMissing: idMissing,
      row: row,
      tags: _tags(m['tags']),
    );
  }

  // ---------- PROJECTS / TAGS (single json files in .orbit/) ----------
  static String renderProjects(List<ProjectRow> rows) {
    final sorted = [...rows]..sort((a, b) => a.id.compareTo(b.id));
    return const JsonEncoder.withIndent('  ').convert([
      for (final p in sorted)
        {
          'id': p.id,
          'name': p.name,
          'icon': p.iconName,
          'color': p.colorValue,
          'sort_order': p.sortOrder,
          'created': _iso(p.createdAt),
          'updated': _iso(p.updatedAt),
        },
    ]);
  }

  static List<ProjectsTableCompanion>? parseProjects(String text) {
    try {
      final list = jsonDecode(text) as List;
      final now = DateTime.now();
      final out = <ProjectsTableCompanion>[];
      for (final raw in list) {
        final m = raw as Map<String, dynamic>;
        final id = _s(m['id']);
        final name = _s(m['name']);
        if (id == null || name == null) continue;
        out.add(ProjectsTableCompanion.insert(
          id: id,
          name: name,
          createdAt: _d(m['created']) ?? now,
          updatedAt: _d(m['updated']) ?? now,
          iconName: Value(_s(m['icon']) ?? 'folder'),
          colorValue: Value(_i(m['color']) ?? 0xFF14B8A6),
          sortOrder: Value(_i(m['sort_order']) ?? 0),
          deletedAt: const Value<DateTime?>(null),
        ));
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  static String renderTags(List<TagRow> rows) {
    final sorted = [...rows]..sort((a, b) => a.id.compareTo(b.id));
    return const JsonEncoder.withIndent('  ').convert([
      for (final t in sorted)
        {
          'id': t.id,
          'name': t.name,
          'color': t.colorValue,
          'created': _iso(t.createdAt),
          'updated': _iso(t.updatedAt),
        },
    ]);
  }

  static List<TagsTableCompanion>? parseTags(String text) {
    try {
      final list = jsonDecode(text) as List;
      final now = DateTime.now();
      final out = <TagsTableCompanion>[];
      for (final raw in list) {
        final m = raw as Map<String, dynamic>;
        final id = _s(m['id']);
        final name = _s(m['name']);
        if (id == null || name == null) continue;
        out.add(TagsTableCompanion.insert(
          id: id,
          name: name,
          createdAt: _d(m['created']) ?? now,
          updatedAt: _d(m['updated']) ?? now,
          colorValue: Value(_i(m['color']) ?? 0xFF8B7CFF),
          deletedAt: const Value<DateTime?>(null),
        ));
      }
      return out;
    } catch (_) {
      return null;
    }
  }
}
