import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/features/notes/presentation/widgets/markdown_text_editing_controller.dart';
import 'package:poswal_orbit/features/notes/presentation/widgets/note_formatting_toolbar.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

void main() {
  group('NoteFormattingToolbar Widget & Focus Tests', () {
    testWidgets('Tapping Bold button wraps selected text in TextField and preserves selection', (tester) async {
      final controller = MarkdownTextEditingController(text: 'Hello world today');
      final focusNode = FocusNode();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('test_field'),
                      controller: controller,
                      focusNode: focusNode,
                    ),
                  ),
                  NoteFormattingToolbar(
                    controller: controller,
                    focusNode: focusNode,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Focus text field and select 'world' (offset 6 to 11)
      focusNode.requestFocus();
      controller.selection = const TextSelection(baseOffset: 6, extentOffset: 11);
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);

      // Tap Bold button
      await tester.tap(find.byKey(const ValueKey('fmt_bold')));
      await tester.pumpAndSettle();

      expect(controller.text, equals('Hello **world** today'));
      // Text selection remains around 'world'
      expect(controller.selection.start, equals(8));
      expect(controller.selection.end, equals(13));
      // Focus MUST stay on the TextField!
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('Tapping Italic button wraps selected text and preserves focus', (tester) async {
      final controller = MarkdownTextEditingController(text: 'Drink water daily');
      final focusNode = FocusNode();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                    ),
                  ),
                  NoteFormattingToolbar(
                    controller: controller,
                    focusNode: focusNode,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      focusNode.requestFocus();
      controller.selection = const TextSelection(baseOffset: 6, extentOffset: 11); // 'water'
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('fmt_italic')));
      await tester.pumpAndSettle();

      expect(controller.text, equals('Drink *water* daily'));
      expect(controller.selection.start, equals(7));
      expect(controller.selection.end, equals(12));
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('Tapping Heading button cycles line prefix (# -> ## -> ### -> none)', (tester) async {
      final controller = MarkdownTextEditingController(text: 'Section Title');
      final focusNode = FocusNode();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(child: TextField(controller: controller, focusNode: focusNode)),
                  NoteFormattingToolbar(controller: controller, focusNode: focusNode),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      focusNode.requestFocus();
      controller.selection = const TextSelection.collapsed(offset: 4);
      await tester.pump();

      // Tap 1: #
      await tester.tap(find.byKey(const ValueKey('fmt_heading')));
      await tester.pumpAndSettle();
      expect(controller.text, equals('# Section Title'));
      expect(focusNode.hasFocus, isTrue);

      // Tap 2: ##
      await tester.tap(find.byKey(const ValueKey('fmt_heading')));
      await tester.pumpAndSettle();
      expect(controller.text, equals('## Section Title'));

      // Tap 3: ###
      await tester.tap(find.byKey(const ValueKey('fmt_heading')));
      await tester.pumpAndSettle();
      expect(controller.text, equals('### Section Title'));

      // Tap 4: none
      await tester.tap(find.byKey(const ValueKey('fmt_heading')));
      await tester.pumpAndSettle();
      expect(controller.text, equals('Section Title'));
    });

    testWidgets('Tapping Checklist button toggles - [ ] prefix and does not stack with bullet', (tester) async {
      final controller = MarkdownTextEditingController(text: '- Bullet item');
      final focusNode = FocusNode();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(child: TextField(controller: controller, focusNode: focusNode)),
                  NoteFormattingToolbar(controller: controller, focusNode: focusNode),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      focusNode.requestFocus();
      controller.selection = const TextSelection.collapsed(offset: 5);
      await tester.pump();

      // Tap Checklist -> replaces - with - [ ]
      await tester.tap(find.byKey(const ValueKey('fmt_checklist')));
      await tester.pumpAndSettle();

      expect(controller.text, equals('- [ ] Bullet item'));
      expect(controller.text.contains('- [ ] -'), isFalse);
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('MarkdownTextEditingController buildTextSpan renders styled spans matching plain text', (tester) async {
      final controller = MarkdownTextEditingController(
        text: '# Header\n- [ ] Task **important** and *quick*',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final span = controller.buildTextSpan(
                    context: context,
                    style: const TextStyle(fontSize: 16),
                    withComposing: false,
                  );

                  // Plain text must match exactly character-for-character
                  expect(span.toPlainText(), equals(controller.text));

                  return Text.rich(span);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });
}
