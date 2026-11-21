import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class NoteFormattingToolbar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const NoteFormattingToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  void _insertAtCursor(String textToInsert, {int cursorOffset = 0}) {
    HapticFeedback.selectionClick();
    final text = controller.text;
    final selection = controller.selection;

    if (selection.start < 0) {
      // Append if no selection
      final newText = text + textToInsert;
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
      return;
    }

    final newText = text.replaceRange(selection.start, selection.end, textToInsert);
    final newOffset = selection.start + textToInsert.length + cursorOffset;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset.clamp(0, newText.length)),
    );
  }

  void _wrapSelection(String prefix, String suffix) {
    HapticFeedback.selectionClick();
    final text = controller.text;
    final selection = controller.selection;

    if (selection.start < 0 || selection.start == selection.end) {
      _insertAtCursor('$prefix$suffix', cursorOffset: -suffix.length);
      return;
    }

    final selected = text.substring(selection.start, selection.end);
    final replacement = '$prefix$selected$suffix';
    final newText = text.replaceRange(selection.start, selection.end, replacement);

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + selected.length,
      ),
    );
  }

  void _toggleLinePrefix(String prefix) {
    HapticFeedback.selectionClick();
    final text = controller.text;
    final selection = controller.selection;
    final cursor = selection.start >= 0 ? selection.start : text.length;

    // Find the start of the current line
    final lineStart = text.lastIndexOf('\n', cursor > 0 ? cursor - 1 : 0);
    final start = lineStart == -1 ? 0 : lineStart + 1;

    // Insert prefix at start of line
    final newText = text.replaceRange(start, start, prefix);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: PoswalSpacing.md,
        vertical: PoswalSpacing.xs,
      ),
      child: AppGlassCard(
        borderRadius: PoswalRadii.pill,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.sm, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Heading
              IconButton(
                key: const ValueKey('fmt_heading'),
                icon: const Icon(PhosphorIconsRegular.textH, size: 20),
                color: iconColor,
                tooltip: l10n?.headingTooltip ?? 'Heading',
                onPressed: () => _toggleLinePrefix('# '),
              ),
              // Bold
              IconButton(
                key: const ValueKey('fmt_bold'),
                icon: const Icon(PhosphorIconsRegular.textB, size: 20),
                color: iconColor,
                tooltip: l10n?.boldTooltip ?? 'Bold',
                onPressed: () => _wrapSelection('**', '**'),
              ),
              // Italic
              IconButton(
                key: const ValueKey('fmt_italic'),
                icon: const Icon(PhosphorIconsRegular.textItalic, size: 20),
                color: iconColor,
                tooltip: l10n?.italicTooltip ?? 'Italic',
                onPressed: () => _wrapSelection('*', '*'),
              ),
              // Bullet List
              IconButton(
                key: const ValueKey('fmt_bullet'),
                icon: const Icon(PhosphorIconsRegular.listBullets, size: 20),
                color: iconColor,
                tooltip: l10n?.bulletListTooltip ?? 'Bullet List',
                onPressed: () => _toggleLinePrefix('- '),
              ),
              // Checklist
              IconButton(
                key: const ValueKey('fmt_checklist'),
                icon: const Icon(PhosphorIconsRegular.checkSquare, size: 20),
                color: iconColor,
                tooltip: l10n?.checklistTooltip ?? 'Checklist',
                onPressed: () => _toggleLinePrefix('- [ ] '),
              ),
              // Link
              IconButton(
                key: const ValueKey('fmt_link'),
                icon: const Icon(PhosphorIconsRegular.linkSimple, size: 20),
                color: iconColor,
                tooltip: l10n?.insertLinkTooltip ?? 'Insert Link',
                onPressed: () => _wrapSelection('[', '](https://)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
