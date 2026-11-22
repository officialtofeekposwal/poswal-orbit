import 'package:flutter/services.dart';

class MarkdownEditResult {
  final String text;
  final TextSelection selection;

  const MarkdownEditResult({
    required this.text,
    required this.selection,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkdownEditResult &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          selection == other.selection;

  @override
  int get hashCode => text.hashCode ^ selection.hashCode;

  @override
  String toString() => 'MarkdownEditResult(text: "$text", selection: $selection)';
}

abstract final class MarkdownEditorEngine {
  /// Regular expressions for recognizing prefixes at line starts
  static final RegExp _checklistPrefixRegex = RegExp(r'^(\s*[-*]\s+\[[\sxX]\]\s*)');
  static final RegExp _bulletPrefixRegex = RegExp(r'^(\s*[-*•]\s*)');
  static final RegExp _heading3PrefixRegex = RegExp(r'^(\s*###\s*)');
  static final RegExp _heading2PrefixRegex = RegExp(r'^(\s*##\s*)');
  static final RegExp _heading1PrefixRegex = RegExp(r'^(\s*#\s*)');
  static final RegExp _quotePrefixRegex = RegExp(r'^(\s*>\s*)');

  /// Toggles Bold styling (`**`) on selection or at cursor.
  static MarkdownEditResult toggleBold(String text, TextSelection selection) {
    return toggleInlineStyle(text, selection, marker: '**');
  }

  /// Toggles Italic styling (`*`) on selection or at cursor.
  static MarkdownEditResult toggleItalic(String text, TextSelection selection) {
    return toggleInlineStyle(text, selection, marker: '*');
  }

  /// Pure Dart logic for toggling inline markers (bold `**` or italic `*`).
  /// - If text is selected:
  ///   - If selection is wrapped inside or outside by marker, remove it.
  ///   - Else, wrap selection with marker.
  /// - If selection is collapsed (cursor only):
  ///   - If cursor is inside a marked span on current line, remove the enclosing markers.
  ///   - Else, insert marker pair and place cursor between them (`**|**`).
  static MarkdownEditResult toggleInlineStyle(
    String text,
    TextSelection selection, {
    required String marker,
  }) {
    final start = selection.start;
    final end = selection.end;
    final mLen = marker.length;

    // --- CASE 1: Non-empty selection ---
    if (!selection.isCollapsed && start >= 0 && end <= text.length && start < end) {
      final selected = text.substring(start, end);

      // Check if selected text itself starts and ends with marker
      if (selected.length >= mLen * 2 && selected.startsWith(marker) && selected.endsWith(marker)) {
        final unwrapped = selected.substring(mLen, selected.length - mLen);
        final newText = text.replaceRange(start, end, unwrapped);
        final newSelection = TextSelection(
          baseOffset: start,
          extentOffset: start + unwrapped.length,
        );
        return MarkdownEditResult(text: newText, selection: newSelection);
      }

      // Check if text immediately outside selection is wrapped with marker
      if (start >= mLen && end + mLen <= text.length) {
        final before = text.substring(start - mLen, start);
        final after = text.substring(end, end + mLen);
        if (before == marker && after == marker) {
          final newText = text.substring(0, start - mLen) + selected + text.substring(end + mLen);
          final newSelection = TextSelection(
            baseOffset: start - mLen,
            extentOffset: end - mLen,
          );
          return MarkdownEditResult(text: newText, selection: newSelection);
        }
      }

      // Neither -> wrap selection with marker
      final replacement = '$marker$selected$marker';
      final newText = text.replaceRange(start, end, replacement);
      final newSelection = TextSelection(
        baseOffset: start + mLen,
        extentOffset: start + mLen + selected.length,
      );
      return MarkdownEditResult(text: newText, selection: newSelection);
    }

    // --- CASE 2: Collapsed selection (cursor only) ---
    final cursor = (start >= 0 && start <= text.length) ? start : text.length;

    // Find current line bounds
    final lineStart = text.lastIndexOf('\n', cursor > 0 ? cursor - 1 : 0);
    final actualLineStart = lineStart == -1 ? 0 : lineStart + 1;
    final lineEnd = text.indexOf('\n', cursor);
    final actualLineEnd = lineEnd == -1 ? text.length : lineEnd;

    final line = text.substring(actualLineStart, actualLineEnd);
    final relCursor = cursor - actualLineStart;

    // Search for enclosing marker pair on this line
    final enclosing = _findEnclosingMarker(line, relCursor, marker);
    if (enclosing != null) {
      // Toggle off: remove closing and opening markers
      final openPos = actualLineStart + enclosing.$1;
      final closePos = actualLineStart + enclosing.$2;

      // Remove closing first, then opening
      final textWithoutClose = text.replaceRange(closePos, closePos + mLen, '');
      final newText = textWithoutClose.replaceRange(openPos, openPos + mLen, '');

      int newCursor = cursor;
      if (cursor > closePos) {
        newCursor -= mLen * 2;
      } else if (cursor > openPos) {
        newCursor -= mLen;
      }
      newCursor = newCursor.clamp(0, newText.length);

      return MarkdownEditResult(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    }

    // Not inside marker: insert empty marker pair and place cursor between them
    final newText = text.replaceRange(cursor, cursor, '$marker$marker');
    return MarkdownEditResult(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + mLen),
    );
  }

  /// Helper to find enclosing marker pair indices (open, close) around [relCursor] on [line].
  static (int, int)? _findEnclosingMarker(String line, int relCursor, String marker) {
    int searchIdx = 0;
    while (searchIdx < line.length) {
      final openIdx = line.indexOf(marker, searchIdx);
      if (openIdx == -1) break;

      // Ensure marker distinction (e.g. '*' should not match '**')
      if (marker == '*') {
        final isPrecededByStar = openIdx > 0 && line[openIdx - 1] == '*';
        final isFollowedByStar = openIdx + 1 < line.length && line[openIdx + 1] == '*';
        if (isPrecededByStar || isFollowedByStar) {
          searchIdx = openIdx + (isFollowedByStar ? 2 : 1);
          continue;
        }
      }

      final closeIdx = line.indexOf(marker, openIdx + marker.length);
      if (closeIdx == -1) break;

      if (marker == '*') {
        final isPrecededByStar = closeIdx > 0 && line[closeIdx - 1] == '*';
        final isFollowedByStar = closeIdx + 1 < line.length && line[closeIdx + 1] == '*';
        if (isPrecededByStar || isFollowedByStar) {
          searchIdx = openIdx + 1;
          continue;
        }
      }

      // Check if relCursor is inside this span
      if (relCursor > openIdx && relCursor <= closeIdx + marker.length) {
        return (openIdx, closeIdx);
      }

      searchIdx = closeIdx + marker.length;
    }
    return null;
  }

  /// Cycles heading on the current line(s): none -> # -> ## -> ### -> none.
  /// Replaces any existing checklist or bullet prefix so prefixes NEVER stack.
  static MarkdownEditResult cycleHeading(String text, TextSelection selection) {
    return _applyLinePrefixTransformation(text, selection, (line) {
      // Determine existing prefix
      if (line.startsWith('### ')) {
        // Cycle from ### -> none
        return line.substring(4);
      } else if (line.startsWith('## ')) {
        // Cycle from ## -> ###
        return '### ${line.substring(3)}';
      } else if (line.startsWith('# ')) {
        // Cycle from # -> ##
        return '## ${line.substring(2)}';
      }

      // Strip any other list prefix (bullet, checklist, quote)
      final cleanLine = _stripAnyLinePrefix(line);
      return '# $cleanLine';
    });
  }

  /// Toggles bullet list on current line(s).
  /// - If line already has a bullet, toggles it off.
  /// - If line has checklist or heading, replaces it with `- `.
  /// - Else, prepends `- `.
  static MarkdownEditResult toggleBullet(String text, TextSelection selection) {
    return _applyLinePrefixTransformation(text, selection, (line) {
      final bulletMatch = _bulletPrefixRegex.firstMatch(line);
      if (bulletMatch != null && !_checklistPrefixRegex.hasMatch(line)) {
        // Toggle off
        return line.substring(bulletMatch.group(1)!.length);
      }

      // Strip any checklist, heading or quote prefix
      final cleanLine = _stripAnyLinePrefix(line);
      return '- $cleanLine';
    });
  }

  /// Toggles checklist on current line(s).
  /// - If line already has a checklist (`- [ ] ` or `- [x] `), toggles it off.
  /// - If line has bullet or heading, replaces it with `- [ ] `.
  /// - Else, prepends `- [ ] `.
  static MarkdownEditResult toggleChecklist(String text, TextSelection selection) {
    return _applyLinePrefixTransformation(text, selection, (line) {
      final checkMatch = _checklistPrefixRegex.firstMatch(line);
      if (checkMatch != null) {
        // Toggle off
        return line.substring(checkMatch.group(1)!.length);
      }

      // Strip any bullet, heading or quote prefix
      final cleanLine = _stripAnyLinePrefix(line);
      return '- [ ] $cleanLine';
    });
  }

  /// Toggles checklist state (`[ ]` <-> `[x]`) if cursor is on the checkbox of a line.
  /// Returns updated result if toggled, or null if cursor is not on a checkbox.
  static MarkdownEditResult? toggleChecklistStateAtCursor(String text, int cursorOffset) {
    if (cursorOffset < 0 || cursorOffset > text.length) return null;

    final lineStart = text.lastIndexOf('\n', cursorOffset > 0 ? cursorOffset - 1 : 0);
    final actualLineStart = lineStart == -1 ? 0 : lineStart + 1;
    final lineEnd = text.indexOf('\n', cursorOffset);
    final actualLineEnd = lineEnd == -1 ? text.length : lineEnd;

    final line = text.substring(actualLineStart, actualLineEnd);
    final relOffset = cursorOffset - actualLineStart;

    // Check if line is unchecked: - [ ]
    final uncheckedRegex = RegExp(r'^(\s*[-*]\s+)\[\s\](\s+.*)$');
    final uncheckMatch = uncheckedRegex.firstMatch(line);
    if (uncheckMatch != null) {
      // Must be tapping near the prefix (within first 8 characters)
      if (relOffset <= 8) {
        final prefix = uncheckMatch.group(1)!;
        final rest = uncheckMatch.group(2)!;
        final newLine = '$prefix[x]$rest';
        final newText = text.replaceRange(actualLineStart, actualLineEnd, newLine);
        return MarkdownEditResult(
          text: newText,
          selection: TextSelection.collapsed(offset: actualLineStart + prefix.length + 3),
        );
      }
    }

    // Check if line is checked: - [x] or - [X]
    final checkedRegex = RegExp(r'^(\s*[-*]\s+)\[[xX]\](\s+.*)$');
    final checkMatch = checkedRegex.firstMatch(line);
    if (checkMatch != null) {
      if (relOffset <= 8) {
        final prefix = checkMatch.group(1)!;
        final rest = checkMatch.group(2)!;
        final newLine = '$prefix[ ]$rest';
        final newText = text.replaceRange(actualLineStart, actualLineEnd, newLine);
        return MarkdownEditResult(
          text: newText,
          selection: TextSelection.collapsed(offset: actualLineStart + prefix.length + 3),
        );
      }
    }

    return null;
  }

  /// Inserts a markdown link `[linkText](url)`.
  /// If [selection] spans text, replaces selection with link; places cursor after the link.
  static MarkdownEditResult insertLink(
    String text,
    TextSelection selection, {
    required String linkText,
    required String url,
  }) {
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final replacement = '[$linkText]($url)';
    final newText = text.replaceRange(start, end, replacement);
    final newOffset = start + replacement.length;

    return MarkdownEditResult(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Handles Smart Enter in lists:
  /// - Empty checklist `- [ ] ` on Enter: exits checklist (removes prefix).
  /// - Non-empty checklist `- [ ] item` on Enter: continues next item `- [ ] `.
  /// - Empty bullet `- ` on Enter: exits bullet list.
  /// - Non-empty bullet `- item` on Enter: continues next bullet `- `.
  static MarkdownEditResult? handleSmartEnter(String text, TextSelection selection) {
    if (selection.start <= 0 || text.isEmpty) return null;
    final cursor = selection.start;

    int lineStart;
    int lineEnd;
    String currentLine;

    if (cursor > 0 && text[cursor - 1] == '\n') {
      // User just entered a newline at cursor - 1
      final beforeNewline = text.substring(0, cursor - 1);
      final prevNewline = beforeNewline.lastIndexOf('\n');
      lineStart = prevNewline == -1 ? 0 : prevNewline + 1;
      lineEnd = cursor - 1;
      currentLine = text.substring(lineStart, lineEnd);
    } else {
      final lastNewline = text.lastIndexOf('\n', cursor > 0 ? cursor - 1 : 0);
      lineStart = lastNewline == -1 ? 0 : lastNewline + 1;
      lineEnd = cursor;
      currentLine = text.substring(lineStart, lineEnd);
    }

    // Checklist
    final checkMatch = RegExp(r'^(\s*[-*]\s+\[[\sxX]\]\s*)(.*)$').firstMatch(currentLine);
    if (checkMatch != null) {
      final prefix = checkMatch.group(1)!;
      final content = checkMatch.group(2)!.trim();

      if (content.isEmpty) {
        // Exit list: delete the empty prefix line and newline
        final deleteEnd = (cursor < text.length && text[cursor] == '\n') ? cursor + 1 : cursor;
        final newText = text.replaceRange(lineStart, deleteEnd, '');
        return MarkdownEditResult(
          text: newText,
          selection: TextSelection.collapsed(offset: lineStart),
        );
      } else {
        // Continue list with clean unchecked item
        final basePrefix = prefix.contains('[') ? '- [ ] ' : prefix;
        if (cursor > 0 && text[cursor - 1] == '\n') {
          final newText = text.replaceRange(cursor, cursor, basePrefix);
          return MarkdownEditResult(
            text: newText,
            selection: TextSelection.collapsed(offset: cursor + basePrefix.length),
          );
        } else {
          final newText = text.replaceRange(cursor, cursor, '\n$basePrefix');
          return MarkdownEditResult(
            text: newText,
            selection: TextSelection.collapsed(offset: cursor + 1 + basePrefix.length),
          );
        }
      }
    }

    // Bullet
    final bulletMatch = RegExp(r'^(\s*[-*•]\s+)(.*)$').firstMatch(currentLine);
    if (bulletMatch != null) {
      final prefix = bulletMatch.group(1)!;
      final content = bulletMatch.group(2)!.trim();

      if (content.isEmpty) {
        // Exit bullet list
        final deleteEnd = (cursor < text.length && text[cursor] == '\n') ? cursor + 1 : cursor;
        final newText = text.replaceRange(lineStart, deleteEnd, '');
        return MarkdownEditResult(
          text: newText,
          selection: TextSelection.collapsed(offset: lineStart),
        );
      } else {
        // Continue bullet list
        if (cursor > 0 && text[cursor - 1] == '\n') {
          final newText = text.replaceRange(cursor, cursor, prefix);
          return MarkdownEditResult(
            text: newText,
            selection: TextSelection.collapsed(offset: cursor + prefix.length),
          );
        } else {
          final newText = text.replaceRange(cursor, cursor, '\n$prefix');
          return MarkdownEditResult(
            text: newText,
            selection: TextSelection.collapsed(offset: cursor + 1 + prefix.length),
          );
        }
      }
    }

    return null;
  }

  /// Strips any known line prefix (heading, bullet, checklist, quote).
  static String _stripAnyLinePrefix(String line) {
    // Checklists first (since - [ ] contains - )
    final checkMatch = _checklistPrefixRegex.firstMatch(line);
    if (checkMatch != null) {
      return line.substring(checkMatch.group(1)!.length);
    }
    final bulletMatch = _bulletPrefixRegex.firstMatch(line);
    if (bulletMatch != null) {
      return line.substring(bulletMatch.group(1)!.length);
    }
    final h3Match = _heading3PrefixRegex.firstMatch(line);
    if (h3Match != null) {
      return line.substring(h3Match.group(1)!.length);
    }
    final h2Match = _heading2PrefixRegex.firstMatch(line);
    if (h2Match != null) {
      return line.substring(h2Match.group(1)!.length);
    }
    final h1Match = _heading1PrefixRegex.firstMatch(line);
    if (h1Match != null) {
      return line.substring(h1Match.group(1)!.length);
    }
    final quoteMatch = _quotePrefixRegex.firstMatch(line);
    if (quoteMatch != null) {
      return line.substring(quoteMatch.group(1)!.length);
    }
    return line;
  }

  /// Applies a line transformation to all lines spanned by [selection].
  static MarkdownEditResult _applyLinePrefixTransformation(
    String text,
    TextSelection selection,
    String Function(String line) transformLine,
  ) {
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    // Find starting line
    final lineStart = text.lastIndexOf('\n', start > 0 ? start - 1 : 0);
    final actualLineStart = lineStart == -1 ? 0 : lineStart + 1;

    // Find ending line
    final lineEnd = text.indexOf('\n', end);
    final actualLineEnd = lineEnd == -1 ? text.length : lineEnd;

    final blockText = text.substring(actualLineStart, actualLineEnd);
    final lines = blockText.split('\n');

    final transformedLines = lines.map(transformLine).toList();
    final newBlockText = transformedLines.join('\n');

    final newText = text.replaceRange(actualLineStart, actualLineEnd, newBlockText);

    // Calculate adjusted cursor/selection position
    final diff = newBlockText.length - blockText.length;
    final newEnd = (end + diff).clamp(actualLineStart, newText.length);
    final newStart = selection.isCollapsed
        ? newEnd
        : (start + (transformedLines.first.length - lines.first.length)).clamp(actualLineStart, newEnd);

    return MarkdownEditResult(
      text: newText,
      selection: TextSelection(
        baseOffset: newStart,
        extentOffset: newEnd,
      ),
    );
  }
}
