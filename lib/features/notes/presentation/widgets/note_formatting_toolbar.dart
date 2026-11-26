import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/liquid_glass.dart';
import 'package:poswal_orbit/domain/logic/markdown_editor_engine.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class NoteFormattingToolbar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const NoteFormattingToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  void _applyEdit(MarkdownEditResult Function(String text, TextSelection selection) editFn) {
    unawaited(HapticFeedback.selectionClick());
    final text = controller.text;
    final selection = controller.selection;
    final result = editFn(text, selection);

    controller.value = TextEditingValue(
      text: result.text,
      selection: result.selection,
    );

    // Keep editor focused without dismissing soft keyboard
    if (!focusNode.hasFocus) {
      focusNode.requestFocus();
    }
  }

  Future<void> _handleLinkTap(BuildContext context) async {
    unawaited(HapticFeedback.selectionClick());
    final text = controller.text;
    final selection = controller.selection;
    final hasSelection = !selection.isCollapsed &&
        selection.start >= 0 &&
        selection.end <= text.length &&
        selection.start < selection.end;
    final initialText = hasSelection ? text.substring(selection.start, selection.end) : '';

    final textController = TextEditingController(text: initialText);
    final urlController = TextEditingController(text: 'https://');

    final inserted = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
        final textSecondary =
            isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
        final fieldFill = isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight2;
        final accent = isDark ? PoswalColors.teal : PoswalColors.tealLight;

        return AlertDialog(
          backgroundColor: isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PoswalRadii.card)),
          title: Text(
            l10n?.insertLinkTooltip ?? 'Insert Link',
            style: PoswalText.title.copyWith(color: textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                autofocus: !hasSelection,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: l10n?.linkTextLabel ?? 'Link Text',
                  labelStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PoswalRadii.chip),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: PoswalSpacing.md),
              TextField(
                controller: urlController,
                autofocus: hasSelection,
                style: TextStyle(color: textPrimary),
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n?.linkUrlLabel ?? 'URL (https://...)',
                  labelStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PoswalRadii.chip),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                l10n?.cancel ?? 'Cancel',
                style: TextStyle(color: textSecondary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: () {
                final linkText = textController.text.trim();
                final url = urlController.text.trim();
                if (linkText.isNotEmpty && url.isNotEmpty && url != 'https://') {
                  Navigator.of(ctx).pop(true);
                }
              },
              child: Text(
                l10n?.proceed ?? 'Insert',
                style: TextStyle(
                  color: isDark ? PoswalColors.ink : PoswalColors.surfaceLight,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (inserted == true) {
      final linkText = textController.text.trim();
      final url = urlController.text.trim();
      if (linkText.isNotEmpty && url.isNotEmpty) {
        final result = MarkdownEditorEngine.insertLink(
          text,
          selection,
          linkText: linkText,
          url: url,
        );
        controller.value = TextEditingValue(
          text: result.text,
          selection: result.selection,
        );
      }
    }

    focusNode.requestFocus();
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
      child: LiquidGlass(
        isCapsule: true,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: PoswalSpacing.sm, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          // ExcludeFocus ensures toolbar buttons NEVER steal focus from the TextField!
          child: ExcludeFocus(
            excluding: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Heading: cycles none -> # -> ## -> ### -> none
                IconButton(
                  key: const ValueKey('fmt_heading'),
                  icon: const Icon(PhosphorIconsRegular.textH, size: 20),
                  color: iconColor,
                  tooltip: l10n?.headingTooltip ?? 'Heading',
                  onPressed: () => _applyEdit(MarkdownEditorEngine.cycleHeading),
                ),
                // Bold: wraps or toggles **
                IconButton(
                  key: const ValueKey('fmt_bold'),
                  icon: const Icon(PhosphorIconsRegular.textB, size: 20),
                  color: iconColor,
                  tooltip: l10n?.boldTooltip ?? 'Bold',
                  onPressed: () => _applyEdit(MarkdownEditorEngine.toggleBold),
                ),
                // Italic: wraps or toggles *
                IconButton(
                  key: const ValueKey('fmt_italic'),
                  icon: const Icon(PhosphorIconsRegular.textItalic, size: 20),
                  color: iconColor,
                  tooltip: l10n?.italicTooltip ?? 'Italic',
                  onPressed: () => _applyEdit(MarkdownEditorEngine.toggleItalic),
                ),
                // Bullet List: toggles or switches prefix to -
                IconButton(
                  key: const ValueKey('fmt_bullet'),
                  icon: const Icon(PhosphorIconsRegular.listBullets, size: 20),
                  color: iconColor,
                  tooltip: l10n?.bulletListTooltip ?? 'Bullet List',
                  onPressed: () => _applyEdit(MarkdownEditorEngine.toggleBullet),
                ),
                // Checklist: toggles or switches prefix to - [ ]
                IconButton(
                  key: const ValueKey('fmt_checklist'),
                  icon: const Icon(PhosphorIconsRegular.checkSquare, size: 20),
                  color: iconColor,
                  tooltip: l10n?.checklistTooltip ?? 'Checklist',
                  onPressed: () => _applyEdit(MarkdownEditorEngine.toggleChecklist),
                ),
                // Link: prompts for text and URL
                IconButton(
                  key: const ValueKey('fmt_link'),
                  icon: const Icon(PhosphorIconsRegular.linkSimple, size: 20),
                  color: iconColor,
                  tooltip: l10n?.insertLinkTooltip ?? 'Insert Link',
                  onPressed: () => _handleLinkTap(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
