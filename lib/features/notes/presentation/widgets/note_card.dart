import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/domain/logic/markdown_lite.dart';
import 'package:poswal_orbit/domain/models/note_models.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(int lineIndex)? onToggleChecklist;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.onToggleChecklist,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;

    final colorVal = NoteColorLabel.toColorValue(note.colorLabel);
    final hasColor = note.colorLabel != NoteColorLabel.none;
    final isRtl = MarkdownLite.isRtlText(note.title.isNotEmpty ? note.title : note.body);

    // Semi-solid background for 120fps scrolling smoothness (not glass per row)
    final cardBg = isDark
        ? (hasColor
            ? Color.alphaBlend(Color(colorVal).withValues(alpha: 0.12), PoswalColors.surfaceDark2)
            : PoswalColors.surfaceDark2)
        : (hasColor
            ? Color.alphaBlend(Color(colorVal).withValues(alpha: 0.08), PoswalColors.surfaceLight)
            : PoswalColors.surfaceLight);

    final borderColor = hasColor
        ? Color(colorVal).withValues(alpha: 0.35)
        : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08));

    final blocks = MarkdownLite.parseBlocks(note.body);
    final checklistBlocks = blocks.where((b) => b.type == MarkdownBlockType.checklist).take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(PoswalRadii.card),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          button: true,
          label: note.title.isNotEmpty ? 'Note: ${note.title}' : 'Note: Untitled',
          child: InkWell(
            borderRadius: BorderRadius.circular(PoswalRadii.card),
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              onLongPress();
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.all(PoswalSpacing.md),
              child: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Top Row: Pinned & Journal Badges
                  if (note.isPinned || note.isJournal || hasColor)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: PoswalSpacing.xs),
                      child: Row(
                        children: [
                          if (note.isPinned)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: PoswalSpacing.xs),
                              child: Container(
                                padding: const EdgeInsetsDirectional.all(3),
                                decoration: BoxDecoration(
                                  color: PoswalColors.gold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(PoswalRadii.chip),
                                ),
                                child: const Icon(
                                  PhosphorIconsFill.pushPin,
                                  size: 13,
                                  color: PoswalColors.gold,
                                ),
                              ),
                            ),
                          if (note.isJournal)
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: PoswalSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: PoswalColors.teal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(PoswalRadii.chip),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    PhosphorIconsRegular.bookOpen,
                                    size: 11,
                                    color: PoswalColors.teal,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    note.journalDate ?? 'Journal',
                                    style: PoswalText.micro.copyWith(
                                      color: PoswalColors.teal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          if (hasColor)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(colorVal),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Title
                  Text(
                    note.title.isNotEmpty ? note.title : 'Untitled Note',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: PoswalText.headline.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: PoswalSpacing.xs),

                  // Body Snippet or Checklist Preview
                  if (checklistBlocks.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: checklistBlocks.map((item) {
                        final isChecked = item.isChecked == true;
                        return Padding(
                          padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Semantics(
                                button: true,
                                checked: isChecked,
                                label: 'Checklist item ${item.contentText}',
                                child: GestureDetector(
                                  onTap: onToggleChecklist != null
                                      ? () => onToggleChecklist!(item.lineIndex)
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      isChecked
                                          ? PhosphorIconsFill.checkSquare
                                          : PhosphorIconsRegular.square,
                                      size: 14,
                                      color: isChecked ? PoswalColors.teal : textMuted,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.contentText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: PoswalText.caption.copyWith(
                                    color: isChecked ? textMuted : textPrimary,
                                    decoration: isChecked ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else if (note.body.trim().isNotEmpty)
                    Text.rich(
                      buildRichPreviewSpan(
                        note.body.trim(),
                        baseStyle: PoswalText.caption.copyWith(
                          color: textMuted,
                          height: 1.35,
                        ),
                        isDark: isDark,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Tags Wrap
                  if (note.tags.isNotEmpty) ...[
                    const SizedBox(height: PoswalSpacing.sm),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: note.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: PoswalSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(PoswalRadii.chip),
                          ),
                          child: Text(
                            '#$tag',
                            style: PoswalText.micro.copyWith(
                              color: textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }

  static TextSpan buildRichPreviewSpan(
    String markdown, {
    required TextStyle baseStyle,
    required bool isDark,
  }) {
    final blocks = MarkdownLite.parseBlocks(markdown);
    if (blocks.isEmpty) return TextSpan(text: '', style: baseStyle);

    final spans = <InlineSpan>[];
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (block.contentText.isEmpty && block.rawText.isEmpty) {
        if (i < blocks.length - 1) spans.add(const TextSpan(text: '\n'));
        continue;
      }

      TextStyle blockStyle = baseStyle;
      String prefix = '';
      if (block.type == MarkdownBlockType.heading1) {
        blockStyle = baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight,
        );
      } else if (block.type == MarkdownBlockType.heading2 || block.type == MarkdownBlockType.heading3) {
        blockStyle = baseStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight,
        );
      } else if (block.type == MarkdownBlockType.bullet) {
        prefix = '• ';
      }

      if (prefix.isNotEmpty) {
        spans.add(TextSpan(
          text: prefix,
          style: blockStyle.copyWith(color: PoswalColors.teal, fontWeight: FontWeight.bold),
        ));
      }

      if (block.spans.isEmpty) {
        spans.add(TextSpan(text: block.contentText, style: blockStyle));
      } else {
        for (final s in block.spans) {
          TextStyle spanStyle = blockStyle;
          if (s.isBold && s.isItalic) {
            spanStyle = spanStyle.copyWith(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic);
          } else if (s.isBold) {
            spanStyle = spanStyle.copyWith(fontWeight: FontWeight.bold);
          } else if (s.isItalic) {
            spanStyle = spanStyle.copyWith(fontStyle: FontStyle.italic);
          } else if (s.isLink) {
            spanStyle = spanStyle.copyWith(color: PoswalColors.teal, decoration: TextDecoration.underline);
          }
          spans.add(TextSpan(text: s.text, style: spanStyle));
        }
      }

      if (i < blocks.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(style: baseStyle, children: spans);
  }
}
