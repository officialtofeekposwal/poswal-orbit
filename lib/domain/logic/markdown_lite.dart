/// Pure Dart Markdown-Lite parser, checklist toggler, and RTL direction detector.
/// Zero Flutter imports for maximum testability, reliability, and speed.
library;

enum MarkdownBlockType {
  heading1,
  heading2,
  heading3,
  checklist,
  bullet,
  paragraph,
}

class MarkdownSpan {
  final String text;
  final bool isBold;
  final bool isItalic;
  final String? linkUrl;

  const MarkdownSpan({
    required this.text,
    this.isBold = false,
    this.isItalic = false,
    this.linkUrl,
  });

  bool get isLink => linkUrl != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkdownSpan &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isBold == other.isBold &&
          isItalic == other.isItalic &&
          linkUrl == other.linkUrl;

  @override
  int get hashCode =>
      text.hashCode ^ isBold.hashCode ^ isItalic.hashCode ^ linkUrl.hashCode;

  @override
  String toString() =>
      'MarkdownSpan("$text", bold: $isBold, italic: $isItalic, link: $linkUrl)';
}

class MarkdownBlock {
  final int lineIndex;
  final MarkdownBlockType type;
  final String rawText;
  final String contentText;
  final bool? isChecked; // For checklists only
  final List<MarkdownSpan> spans;

  const MarkdownBlock({
    required this.lineIndex,
    required this.type,
    required this.rawText,
    required this.contentText,
    this.isChecked,
    this.spans = const [],
  });

  @override
  String toString() =>
      'MarkdownBlock($type, line: $lineIndex, checked: $isChecked, content: "$contentText")';
}

enum AppTextDirection {
  ltr,
  rtl,
}

class MarkdownLite {
  static final RegExp _checklistUncheckedRegex = RegExp(r'^\s*[-*]\s+\[\s\]\s+(.*)$');
  static final RegExp _checklistCheckedRegex = RegExp(r'^\s*[-*]\s+\[[xX]\]\s+(.*)$');
  static final RegExp _bulletRegex = RegExp(r'^\s*[-*•]\s+(.*)$');
  static final RegExp _heading3Regex = RegExp(r'^\s*###\s+(.*)$');
  static final RegExp _heading2Regex = RegExp(r'^\s*##\s+(.*)$');
  static final RegExp _heading1Regex = RegExp(r'^\s*#\s+(.*)$');

  // Unicode character range regexes
  // Arabic / Urdu (RTL)
  static final RegExp _rtlRegex = RegExp(
    r'[\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC]',
  );
  // Devanagari (Hindi) - LTR script
  static final RegExp _devanagariRegex = RegExp(r'[\u0900-\u097F]');

  /// Parses raw markdown text into structural blocks (headings, checklists, bullets, paragraphs).
  static List<MarkdownBlock> parseBlocks(String markdown) {
    if (markdown.trim().isEmpty) return const [];
    final lines = markdown.trim().split('\n');
    final blocks = <MarkdownBlock>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        blocks.add(MarkdownBlock(
          lineIndex: i,
          type: MarkdownBlockType.paragraph,
          rawText: line,
          contentText: '',
          spans: const [],
        ));
        continue;
      }

      // Checklists
      final checkUncheckedMatch = _checklistUncheckedRegex.firstMatch(line);
      if (checkUncheckedMatch != null) {
        final content = checkUncheckedMatch.group(1) ?? '';
        blocks.add(MarkdownBlock(
          lineIndex: i,
          type: MarkdownBlockType.checklist,
          rawText: line,
          contentText: content,
          isChecked: false,
          spans: parseSpans(content),
        ));
        continue;
      }

      final checkCheckedMatch = _checklistCheckedRegex.firstMatch(line);
      if (checkCheckedMatch != null) {
        final content = checkCheckedMatch.group(1) ?? '';
        blocks.add(MarkdownBlock(
          lineIndex: i,
          type: MarkdownBlockType.checklist,
          rawText: line,
          contentText: content,
          isChecked: true,
          spans: parseSpans(content),
        ));
        continue;
      }

      // Headings
      final h3Match = _heading3Regex.firstMatch(line);
      if (h3Match != null) {
        final content = h3Match.group(1) ?? '';
        blocks.add(MarkdownBlock(
          lineIndex: i,
          type: MarkdownBlockType.heading3,
          rawText: line,
          contentText: content,
          spans: parseSpans(content),
        ));
        continue;
      }

      final h2Match = _heading2Regex.firstMatch(line);
      if (h2Match != null) {
        final content = h2Match.group(1) ?? '';
        blocks.add(MarkdownBlock(
          lineIndex: i,
          type: MarkdownBlockType.heading2,
          rawText: line,
          contentText: content,
          spans: parseSpans(content),
        ));
        continue;
      }

      final h1Match = _heading1Regex.firstMatch(line);
      if (h1Match != null) {
        final content = h1Match.group(1) ?? '';
        blocks.add(MarkdownBlock(
          lineIndex: i,
          type: MarkdownBlockType.heading1,
          rawText: line,
          contentText: content,
          spans: parseSpans(content),
        ));
        continue;
      }

      // Bullets
      final bulletMatch = _bulletRegex.firstMatch(line);
      if (bulletMatch != null) {
        final content = bulletMatch.group(1) ?? '';
        blocks.add(MarkdownBlock(
          lineIndex: i,
          type: MarkdownBlockType.bullet,
          rawText: line,
          contentText: content,
          spans: parseSpans(content),
        ));
        continue;
      }

      // Standard paragraph
      blocks.add(MarkdownBlock(
        lineIndex: i,
        type: MarkdownBlockType.paragraph,
        rawText: line,
        contentText: line,
        spans: parseSpans(line),
      ));
    }

    return blocks;
  }

  /// Parses inline styling: bold, italic, and links.
  static List<MarkdownSpan> parseSpans(String text) {
    if (text.isEmpty) return const [];

    final spans = <MarkdownSpan>[];
    // Regex for:
    // [link text](url)
    // **bold** or __bold__
    // *italic* or _italic_
    final inlineRegex = RegExp(
      r'\[([^\]]+)\]\(([^)]+)\)|\*\*([^*]+)\*\*|__([^_]+)__|(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)_([^_]+)_(?!_)',
    );

    int lastIndex = 0;
    for (final match in inlineRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(MarkdownSpan(text: text.substring(lastIndex, match.start)));
      }

      if (match.group(1) != null && match.group(2) != null) {
        // Link: [group1](group2)
        spans.add(MarkdownSpan(
          text: match.group(1)!,
          linkUrl: match.group(2)!,
        ));
      } else if (match.group(3) != null || match.group(4) != null) {
        // Bold: **group3** or __group4__
        final boldText = match.group(3) ?? match.group(4)!;
        spans.add(MarkdownSpan(
          text: boldText,
          isBold: true,
        ));
      } else if (match.group(5) != null || match.group(6) != null) {
        // Italic: *group5* or _group6_
        final italicText = match.group(5) ?? match.group(6)!;
        spans.add(MarkdownSpan(
          text: italicText,
          isItalic: true,
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(MarkdownSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }

  /// Toggles a checklist line at [lineIndex] between `- [ ] ` and `- [x] `.
  /// Preserves indentation and any following markdown text.
  static String toggleChecklistLine(String markdown, int lineIndex) {
    final lines = markdown.split('\n');
    if (lineIndex < 0 || lineIndex >= lines.length) return markdown;

    final line = lines[lineIndex];

    // Check if line is unchecked: - [ ]
    final uncheckedMatch = RegExp(r'^(\s*[-*]\s+)\[\s\](\s+.*)$').firstMatch(line);
    if (uncheckedMatch != null) {
      final prefix = uncheckedMatch.group(1)!;
      final rest = uncheckedMatch.group(2)!;
      lines[lineIndex] = '$prefix[x]$rest';
      return lines.join('\n');
    }

    // Check if line is checked: - [x] or - [X]
    final checkedMatch = RegExp(r'^(\s*[-*]\s+)\[[xX]\](\s+.*)$').firstMatch(line);
    if (checkedMatch != null) {
      final prefix = checkedMatch.group(1)!;
      final rest = checkedMatch.group(2)!;
      lines[lineIndex] = '$prefix[ ]$rest';
      return lines.join('\n');
    }

    return markdown;
  }

  /// Toggles the first checklist matching the exact [itemText].
  static String toggleChecklistByText(String markdown, String itemText) {
    final lines = markdown.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if ((trimmed.startsWith('- [ ] $itemText') || trimmed.startsWith('- [x] $itemText') ||
           trimmed.startsWith('* [ ] $itemText') || trimmed.startsWith('* [x] $itemText'))) {
        return toggleChecklistLine(markdown, i);
      }
    }
    return markdown;
  }

  /// Detects whether the text should be rendered with Right-to-Left (RTL) text direction.
  /// Urdu and Arabic are RTL scripts. Hindi (Devanagari) and English are LTR scripts.
  static bool isRtlText(String text) {
    if (text.trim().isEmpty) return false;

    // Scan for the first strong directional character, ignoring markdown symbols, numbers, punctuation
    final clean = text.replaceAll(RegExp(r'[#*\-_\[\]()!0-9\s.,:;?]'), '');
    if (clean.isEmpty) return false;

    int rtlCount = 0;
    int ltrCount = 0;

    for (final char in clean.runes) {
      final charStr = String.fromCharCode(char);
      if (_rtlRegex.hasMatch(charStr)) {
        rtlCount++;
      } else {
        ltrCount++;
      }
    }

    // If RTL characters dominate or are first strong character
    return rtlCount > ltrCount || _rtlRegex.hasMatch(clean[0]);
  }

  /// Returns whether the text contains Devanagari (Hindi) characters.
  static bool isDevanagari(String text) {
    return _devanagariRegex.hasMatch(text);
  }

  /// Returns [AppTextDirection.rtl] or [AppTextDirection.ltr].
  static AppTextDirection detectDirection(String text) {
    return isRtlText(text) ? AppTextDirection.rtl : AppTextDirection.ltr;
  }
}
