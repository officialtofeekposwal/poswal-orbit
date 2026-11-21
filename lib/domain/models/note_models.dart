class NoteColorLabel {
  static const int none = 0;
  static const int teal = 1;
  static const int violet = 2;
  static const int coral = 3;
  static const int gold = 4;
  static const int blue = 5;
  static const int pink = 6;
  static const int lime = 7;

  static const List<int> values = [
    none,
    teal,
    violet,
    coral,
    gold,
    blue,
    pink,
    lime,
  ];

  static int toColorValue(int label) {
    switch (label) {
      case teal:
        return 0xFF14B8A6;
      case violet:
        return 0xFF8B7CFF;
      case coral:
        return 0xFFFF7A59;
      case gold:
        return 0xFFFFC857;
      case blue:
        return 0xFF3B82F6;
      case pink:
        return 0xFFEC4899;
      case lime:
        return 0xFF84CC16;
      case none:
      default:
        return 0x00000000;
    }
  }

  static String toName(int label) {
    switch (label) {
      case teal:
        return 'Teal';
      case violet:
        return 'Violet';
      case coral:
        return 'Coral';
      case gold:
        return 'Gold';
      case blue:
        return 'Blue';
      case pink:
        return 'Pink';
      case lime:
        return 'Lime';
      case none:
      default:
        return 'Default';
    }
  }
}

class Note {
  final String id;
  final String title;
  final String body;
  final int colorLabel;
  final bool isPinned;
  final bool isJournal;
  final String? journalDate; // YYYY-MM-DD
  final String? linkedTaskId;
  final String? linkedHabitId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Note({
    required this.id,
    this.title = '',
    this.body = '',
    this.colorLabel = NoteColorLabel.none,
    this.isPinned = false,
    this.isJournal = false,
    this.journalDate,
    this.linkedTaskId,
    this.linkedHabitId,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Note copyWith({
    String? id,
    String? title,
    String? body,
    int? colorLabel,
    bool? isPinned,
    bool? isJournal,
    String? journalDate,
    String? linkedTaskId,
    String? linkedHabitId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      colorLabel: colorLabel ?? this.colorLabel,
      isPinned: isPinned ?? this.isPinned,
      isJournal: isJournal ?? this.isJournal,
      journalDate: journalDate ?? this.journalDate,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
      linkedHabitId: linkedHabitId ?? this.linkedHabitId,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'colorLabel': colorLabel,
      'isPinned': isPinned,
      'isJournal': isJournal,
      'journalDate': journalDate,
      'linkedTaskId': linkedTaskId,
      'linkedHabitId': linkedHabitId,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      colorLabel: (map['colorLabel'] as int?) ?? NoteColorLabel.none,
      isPinned: (map['isPinned'] as bool?) ?? false,
      isJournal: (map['isJournal'] as bool?) ?? false,
      journalDate: map['journalDate'] as String?,
      linkedTaskId: map['linkedTaskId'] as String?,
      linkedHabitId: map['linkedHabitId'] as String?,
      tags: List<String>.from((map['tags'] as List?) ?? const []),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'] as String)
          : null,
    );
  }
}
