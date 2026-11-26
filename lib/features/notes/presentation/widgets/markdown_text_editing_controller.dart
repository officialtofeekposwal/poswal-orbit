import 'package:flutter/material.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';

/// A custom [TextEditingController] that provides live visual formatting for Markdown-lite:
/// - Headings (#, ##, ###) appear larger and bold with dimmed markers
/// - Bold (**text**) appears bold with dimmed markers
/// - Italic (*text*) appears italic with dimmed markers
/// - Bold+Italic (***text***) appears bold and italic
/// - Checklists (- [ ] and - [x]) show styled checkbox markers and strike-through on completion
/// - Bullets (- text) show styled bullets with dimmed markers
/// - Links ([text](url)) appear styled in teal with underlines and dimmed URL syntax
///
/// Plain markdown text is 100% preserved in [text] for storage, search, and export.
/// Total text character count in spans strictly equals [value.text] to guarantee
/// perfect cursor positioning, selection integrity, and IME composing stability.
class MarkdownTextEditingController extends TextEditingController {
  final bool isDark;

  MarkdownTextEditingController({
    super.text,
    this.isDark = true,
  });

  static final RegExp _checklistCheckedRegex = RegExp(r'^(\s*[-*]\s+\[[xX]\]\s*)(.*)$');
  static final RegExp _checklistUncheckedRegex = RegExp(r'^(\s*[-*]\s+\[\s\]\s*)(.*)$');
  static final RegExp _bulletRegex = RegExp(r'^(\s*[-*•]\s*)(.*)$');
  static final RegExp _h3Regex = RegExp(r'^(\s*###\s*)(.*)$');
  static final RegExp _h2Regex = RegExp(r'^(\s*##\s*)(.*)$');
  static final RegExp _h1Regex = RegExp(r'^(\s*#\s*)(.*)$');

  static final RegExp _inlineRegex = RegExp(
    r'(\*\*\*([^*]+)\*\*\*)|(\*\*([^*]+)\*\*)|(__([^_]+)__)|((?<!\*)\*([^*]+)\*(?!\*))|((?<!_)_([^_]+)_(?!_))|(\[([^\]]+)\]\(([^)]+)\))',
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = value.text;
    if (text.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    final baseStyle = style ??
        TextStyle(
          color: isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight,
          fontSize: PoswalText.callout.fontSize ?? 16,
          height: 1.5,
        );

    final markerDimStyle = baseStyle.copyWith(
      color: (baseStyle.color ?? (isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight))
          .withValues(alpha: 0.35),
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      fontSize: (baseStyle.fontSize ?? 16) * 0.85,
    );

    const composingStyle = TextStyle(decoration: TextDecoration.underline);
    final hasComposing = withComposing && value.isComposingRangeValid;
    final compStart = hasComposing ? value.composing.start : -1;
    final compEnd = hasComposing ? value.composing.end : -1;

    final lines = text.split('\n');
    final allSpans = <TextSpan>[];
    int currentGlobalOffset = 0;

    for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      final line = lines[lineIdx];

      // Format current line into child spans
      _formatLine(
        line: line,
        lineStartOffset: currentGlobalOffset,
        baseStyle: baseStyle,
        markerDimStyle: markerDimStyle,
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: allSpans,
      );

      currentGlobalOffset += line.length;

      // Add newline separator between lines (preserving exact character length)
      if (lineIdx < lines.length - 1) {
        allSpans.add(TextSpan(text: '\n', style: baseStyle));
        currentGlobalOffset += 1;
      }
    }

    return TextSpan(style: baseStyle, children: allSpans);
  }

  void _formatLine({
    required String line,
    required int lineStartOffset,
    required TextStyle baseStyle,
    required TextStyle markerDimStyle,
    required int compStart,
    required int compEnd,
    required TextStyle composingStyle,
    required List<TextSpan> outputSpans,
  }) {
    if (line.isEmpty) return;

    // 1. Heading 1
    final h1Match = _h1Regex.firstMatch(line);
    if (h1Match != null) {
      final prefix = h1Match.group(1)!;
      final content = h1Match.group(2)!;
      _emitSpan(
        text: prefix,
        startOffset: lineStartOffset,
        style: markerDimStyle.copyWith(
          color: PoswalColors.teal.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
        ),
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      final headingStyle = baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 16) + 6,
        fontWeight: FontWeight.bold,
      );
      _formatInline(
        text: content,
        contentStartOffset: lineStartOffset + prefix.length,
        currentStyle: headingStyle,
        markerDimStyle: markerDimStyle,
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      return;
    }

    // 2. Heading 2
    final h2Match = _h2Regex.firstMatch(line);
    if (h2Match != null) {
      final prefix = h2Match.group(1)!;
      final content = h2Match.group(2)!;
      _emitSpan(
        text: prefix,
        startOffset: lineStartOffset,
        style: markerDimStyle.copyWith(
          color: PoswalColors.teal.withValues(alpha: 0.65),
          fontWeight: FontWeight.bold,
        ),
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      final headingStyle = baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 16) + 3,
        fontWeight: FontWeight.bold,
      );
      _formatInline(
        text: content,
        contentStartOffset: lineStartOffset + prefix.length,
        currentStyle: headingStyle,
        markerDimStyle: markerDimStyle,
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      return;
    }

    // 3. Heading 3
    final h3Match = _h3Regex.firstMatch(line);
    if (h3Match != null) {
      final prefix = h3Match.group(1)!;
      final content = h3Match.group(2)!;
      _emitSpan(
        text: prefix,
        startOffset: lineStartOffset,
        style: markerDimStyle.copyWith(
          color: PoswalColors.teal.withValues(alpha: 0.65),
          fontWeight: FontWeight.bold,
        ),
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      final headingStyle = baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 16) + 1,
        fontWeight: FontWeight.bold,
      );
      _formatInline(
        text: content,
        contentStartOffset: lineStartOffset + prefix.length,
        currentStyle: headingStyle,
        markerDimStyle: markerDimStyle,
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      return;
    }

    // 4. Checked Checklist: - [x]
    final checkedMatch = _checklistCheckedRegex.firstMatch(line);
    if (checkedMatch != null) {
      final prefix = checkedMatch.group(1)!;
      final content = checkedMatch.group(2)!;
      _emitSpan(
        text: prefix,
        startOffset: lineStartOffset,
        style: baseStyle.copyWith(
          color: PoswalColors.teal,
          fontWeight: FontWeight.bold,
        ),
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      final strikeStyle = baseStyle.copyWith(
        decoration: TextDecoration.lineThrough,
        color: (baseStyle.color ?? PoswalColors.textSecondaryDark).withValues(alpha: 0.45),
      );
      _formatInline(
        text: content,
        contentStartOffset: lineStartOffset + prefix.length,
        currentStyle: strikeStyle,
        markerDimStyle: markerDimStyle,
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      return;
    }

    // 5. Unchecked Checklist: - [ ]
    final uncheckMatch = _checklistUncheckedRegex.firstMatch(line);
    if (uncheckMatch != null) {
      final prefix = uncheckMatch.group(1)!;
      final content = uncheckMatch.group(2)!;
      _emitSpan(
        text: prefix,
        startOffset: lineStartOffset,
        style: baseStyle.copyWith(
          color: PoswalColors.teal,
          fontWeight: FontWeight.bold,
        ),
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      _formatInline(
        text: content,
        contentStartOffset: lineStartOffset + prefix.length,
        currentStyle: baseStyle,
        markerDimStyle: markerDimStyle,
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      return;
    }

    // 6. Bullet: - item
    final bulletMatch = _bulletRegex.firstMatch(line);
    if (bulletMatch != null) {
      final prefix = bulletMatch.group(1)!;
      final content = bulletMatch.group(2)!;
      _emitSpan(
        text: prefix,
        startOffset: lineStartOffset,
        style: baseStyle.copyWith(
          color: PoswalColors.teal,
          fontWeight: FontWeight.bold,
        ),
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      _formatInline(
        text: content,
        contentStartOffset: lineStartOffset + prefix.length,
        currentStyle: baseStyle,
        markerDimStyle: markerDimStyle,
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
      return;
    }

    // 7. Regular paragraph line
    _formatInline(
      text: line,
      contentStartOffset: lineStartOffset,
      currentStyle: baseStyle,
      markerDimStyle: markerDimStyle,
      compStart: compStart,
      compEnd: compEnd,
      composingStyle: composingStyle,
      outputSpans: outputSpans,
    );
  }

  void _formatInline({
    required String text,
    required int contentStartOffset,
    required TextStyle currentStyle,
    required TextStyle markerDimStyle,
    required int compStart,
    required int compEnd,
    required TextStyle composingStyle,
    required List<TextSpan> outputSpans,
  }) {
    if (text.isEmpty) return;

    int lastIdx = 0;
    for (final match in _inlineRegex.allMatches(text)) {
      if (match.start > lastIdx) {
        final plain = text.substring(lastIdx, match.start);
        _emitSpan(
          text: plain,
          startOffset: contentStartOffset + lastIdx,
          style: currentStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
      }

      final matchedText = match.group(0)!;
      final matchStart = contentStartOffset + match.start;

      // Group 1: ***bold+italic***
      if (match.group(1) != null) {
        final innerText = match.group(2)!;
        _emitSpan(
          text: '***',
          startOffset: matchStart,
          style: markerDimStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
        _emitSpan(
          text: innerText,
          startOffset: matchStart + 3,
          style: currentStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
        _emitSpan(
          text: '***',
          startOffset: matchStart + 3 + innerText.length,
          style: markerDimStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
      }
      // Group 3 or 5: **bold** or __bold__
      else if (match.group(3) != null || match.group(5) != null) {
        final marker = match.group(3) != null ? '**' : '__';
        final innerText = match.group(4) ?? match.group(6)!;
        _emitSpan(
          text: marker,
          startOffset: matchStart,
          style: markerDimStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
        _emitSpan(
          text: innerText,
          startOffset: matchStart + 2,
          style: currentStyle.copyWith(fontWeight: FontWeight.bold),
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
        _emitSpan(
          text: marker,
          startOffset: matchStart + 2 + innerText.length,
          style: markerDimStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
      }
      // Group 7 or 9: *italic* or _italic_
      else if (match.group(7) != null || match.group(9) != null) {
        final marker = match.group(7) != null ? '*' : '_';
        final innerText = match.group(8) ?? match.group(10)!;
        _emitSpan(
          text: marker,
          startOffset: matchStart,
          style: markerDimStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
        _emitSpan(
          text: innerText,
          startOffset: matchStart + 1,
          style: currentStyle.copyWith(fontStyle: FontStyle.italic),
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
        _emitSpan(
          text: marker,
          startOffset: matchStart + 1 + innerText.length,
          style: markerDimStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
      }
      // Group 11: [link text](url)
      else if (match.group(11) != null) {
        final linkLabel = match.group(12)!;
        final linkUrl = match.group(13)!;

        // '['
        _emitSpan(
          text: '[',
          startOffset: matchStart,
          style: markerDimStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
        // linkLabel
        _emitSpan(
          text: linkLabel,
          startOffset: matchStart + 1,
          style: currentStyle.copyWith(
            color: PoswalColors.teal,
            decoration: TextDecoration.underline,
          ),
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
        // '](' + linkUrl + ')'
        final closeMarker = ']($linkUrl)';
        _emitSpan(
          text: closeMarker,
          startOffset: matchStart + 1 + linkLabel.length,
          style: markerDimStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
      } else {
        // Fallback for safety
        _emitSpan(
          text: matchedText,
          startOffset: matchStart,
          style: currentStyle,
          compStart: compStart,
          compEnd: compEnd,
          composingStyle: composingStyle,
          outputSpans: outputSpans,
        );
      }

      lastIdx = match.end;
    }

    if (lastIdx < text.length) {
      final trailing = text.substring(lastIdx);
      _emitSpan(
        text: trailing,
        startOffset: contentStartOffset + lastIdx,
        style: currentStyle,
        compStart: compStart,
        compEnd: compEnd,
        composingStyle: composingStyle,
        outputSpans: outputSpans,
      );
    }
  }

  void _emitSpan({
    required String text,
    required int startOffset,
    required TextStyle style,
    required int compStart,
    required int compEnd,
    required TextStyle composingStyle,
    required List<TextSpan> outputSpans,
  }) {
    if (text.isEmpty) return;

    final endOffset = startOffset + text.length;

    // Check if this span intersects with IME composing region
    if (compStart >= 0 && compEnd > compStart && startOffset < compEnd && endOffset > compStart) {
      final effectiveStyle = style.merge(composingStyle);
      outputSpans.add(TextSpan(text: text, style: effectiveStyle));
    } else {
      outputSpans.add(TextSpan(text: text, style: style));
    }
  }
}
