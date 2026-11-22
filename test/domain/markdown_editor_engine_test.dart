import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/markdown_editor_engine.dart';

void main() {
  group('MarkdownEditorEngine Pure Dart Domain Tests', () {
    // --- 1. BOLD & ITALIC TESTS ---
    test('Bold on selection wraps text with ** and sets selection around content', () {
      const text = 'Drink water daily';
      const selection = TextSelection(baseOffset: 6, extentOffset: 11); // 'water'
      final result = MarkdownEditorEngine.toggleBold(text, selection);

      expect(result.text, equals('Drink **water** daily'));
      expect(result.selection.start, equals(8));
      expect(result.selection.end, equals(13));
      expect(result.text.substring(result.selection.start, result.selection.end), equals('water'));
    });

    test('Bold toggle off when selection includes ** markers', () {
      const text = 'Drink **water** daily';
      const selection = TextSelection(baseOffset: 6, extentOffset: 15); // '**water**'
      final result = MarkdownEditorEngine.toggleBold(text, selection);

      expect(result.text, equals('Drink water daily'));
      expect(result.selection.start, equals(6));
      expect(result.selection.end, equals(11));
      expect(result.text.substring(result.selection.start, result.selection.end), equals('water'));
    });

    test('Bold toggle off when selection is inside outer ** markers', () {
      const text = 'Drink **water** daily';
      const selection = TextSelection(baseOffset: 8, extentOffset: 13); // 'water'
      final result = MarkdownEditorEngine.toggleBold(text, selection);

      expect(result.text, equals('Drink water daily'));
      expect(result.selection.start, equals(6));
      expect(result.selection.end, equals(11));
    });

    test('Bold on empty selection inserts **** and places cursor between markers', () {
      const text = 'Hello ';
      const selection = TextSelection.collapsed(offset: 6);
      final result = MarkdownEditorEngine.toggleBold(text, selection);

      expect(result.text, equals('Hello ****'));
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.start, equals(8)); // between ** and **
    });

    test('Bold toggle off when cursor is inside already bold word', () {
      const text = 'Drink **water** daily';
      const selection = TextSelection.collapsed(offset: 10); // inside 'water'
      final result = MarkdownEditorEngine.toggleBold(text, selection);

      expect(result.text, equals('Drink water daily'));
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.start, equals(8));
    });

    test('Italic on selection wraps text with * and sets selection around content', () {
      const text = 'Drink water daily';
      const selection = TextSelection(baseOffset: 6, extentOffset: 11); // 'water'
      final result = MarkdownEditorEngine.toggleItalic(text, selection);

      expect(result.text, equals('Drink *water* daily'));
      expect(result.selection.start, equals(7));
      expect(result.selection.end, equals(12));
    });

    test('Italic toggle off on wrapped selection', () {
      const text = 'Drink *water* daily';
      const selection = TextSelection(baseOffset: 6, extentOffset: 13); // '*water*'
      final result = MarkdownEditorEngine.toggleItalic(text, selection);

      expect(result.text, equals('Drink water daily'));
      expect(result.selection.start, equals(6));
      expect(result.selection.end, equals(11));
    });

    test('Nested Bold + Italic together: wrapping italic in bold yields ***', () {
      const text = 'Drink *water* daily';
      const selection = TextSelection(baseOffset: 6, extentOffset: 13); // '*water*'
      final boldResult = MarkdownEditorEngine.toggleBold(text, selection);

      expect(boldResult.text, equals('Drink ***water*** daily'));

      // Toggling bold off unwraps the ** leaving *water*
      final unboldResult = MarkdownEditorEngine.toggleBold(boldResult.text, boldResult.selection);
      expect(unboldResult.text, equals('Drink *water* daily'));
    });

    // --- 2. HEADING CYCLE TESTS ---
    test('Heading cycles: none -> # -> ## -> ### -> none', () {
      const initial = 'Note title';
      const sel = TextSelection.collapsed(offset: 4);

      // 1. none -> #
      final h1 = MarkdownEditorEngine.cycleHeading(initial, sel);
      expect(h1.text, equals('# Note title'));

      // 2. # -> ##
      final h2 = MarkdownEditorEngine.cycleHeading(h1.text, h1.selection);
      expect(h2.text, equals('## Note title'));

      // 3. ## -> ###
      final h3 = MarkdownEditorEngine.cycleHeading(h2.text, h2.selection);
      expect(h3.text, equals('### Note title'));

      // 4. ### -> none
      final none = MarkdownEditorEngine.cycleHeading(h3.text, h3.selection);
      expect(none.text, equals('Note title'));
    });

    test('Heading replaces existing bullet or checklist prefix without stacking', () {
      const bulletText = '- Bullet item';
      const checkText = '- [ ] Checklist item';
      const sel = TextSelection.collapsed(offset: 8);

      final fromBullet = MarkdownEditorEngine.cycleHeading(bulletText, sel);
      expect(fromBullet.text, equals('# Bullet item'));
      expect(fromBullet.text.contains('-'), isFalse);

      final fromChecklist = MarkdownEditorEngine.cycleHeading(checkText, sel);
      expect(fromChecklist.text, equals('# Checklist item'));
      expect(fromChecklist.text.contains('- [ ]'), isFalse);
    });

    // --- 3. BULLET & CHECKLIST TOGGLE TESTS ---
    test('Bullet toggle prepends - and toggles off on repeated press', () {
      const text = 'Morning stretch';
      const sel = TextSelection.collapsed(offset: 5);

      final bullet = MarkdownEditorEngine.toggleBullet(text, sel);
      expect(bullet.text, equals('- Morning stretch'));

      final untoggled = MarkdownEditorEngine.toggleBullet(bullet.text, bullet.selection);
      expect(untoggled.text, equals('Morning stretch'));
    });

    test('Checklist toggle prepends - [ ] and toggles off on repeated press', () {
      const text = 'Buy groceries';
      const sel = TextSelection.collapsed(offset: 5);

      final check = MarkdownEditorEngine.toggleChecklist(text, sel);
      expect(check.text, equals('- [ ] Buy groceries'));

      final untoggled = MarkdownEditorEngine.toggleChecklist(check.text, check.selection);
      expect(untoggled.text, equals('Buy groceries'));
    });

    test('Switching bullet <-> checklist replaces prefix without stacking (- [ ] - never produced)', () {
      const bulletLine = '- My task';
      const sel = TextSelection.collapsed(offset: 5);

      final checklist = MarkdownEditorEngine.toggleChecklist(bulletLine, sel);
      expect(checklist.text, equals('- [ ] My task'));
      expect(checklist.text.contains('- [ ] -'), isFalse);

      final backToBullet = MarkdownEditorEngine.toggleBullet(checklist.text, checklist.selection);
      expect(backToBullet.text, equals('- My task'));
      expect(backToBullet.text.contains('- [ ]'), isFalse);
    });

    // --- 4. MULTI-LINE SELECTION ---
    test('Multi-line selection applies checklist prefix to all selected lines', () {
      const multi = 'Item one\nItem two\nItem three';
      // Select spanning item one and item two
      const sel = TextSelection(baseOffset: 2, extentOffset: 12);
      final result = MarkdownEditorEngine.toggleChecklist(multi, sel);

      expect(result.text, equals('- [ ] Item one\n- [ ] Item two\nItem three'));
    });

    // --- 5. LINK INSERTION TESTS ---
    test('Link insertion with selected text uses it as link label and appends URL', () {
      const text = 'Visit Orbit website';
      const sel = TextSelection(baseOffset: 6, extentOffset: 11); // 'Orbit'
      final result = MarkdownEditorEngine.insertLink(
        text,
        sel,
        linkText: 'Orbit',
        url: 'https://orbit.app',
      );

      expect(result.text, equals('Visit [Orbit](https://orbit.app) website'));
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.start, equals(32)); // right after link
    });

    test('Link insertion without selection inserts [label](url) at cursor', () {
      const text = 'Visit ';
      const sel = TextSelection.collapsed(offset: 6);
      final result = MarkdownEditorEngine.insertLink(
        text,
        sel,
        linkText: 'Google',
        url: 'https://google.com',
      );

      expect(result.text, equals('Visit [Google](https://google.com)'));
      expect(result.selection.start, equals(34));
    });

    // --- 6. HINDI, URDU, RTL & EMOJI SUPPORT ---
    test('Bold works accurately with Hindi (Devanagari) script', () {
      const hindi = 'आज मैंने पानी पिया';
      final start = hindi.indexOf('पानी');
      final end = start + 'पानी'.length;
      final sel = TextSelection(baseOffset: start, extentOffset: end);
      final result = MarkdownEditorEngine.toggleBold(hindi, sel);

      expect(result.text, equals('आज मैंने **पानी** पिया'));

      final untoggled = MarkdownEditorEngine.toggleBold(result.text, result.selection);
      expect(untoggled.text, equals(hindi));
    });

    test('Bold works accurately with Urdu (RTL) script', () {
      const urdu = 'آج کا دن اچھا تھا';
      final start = urdu.indexOf('دن');
      final end = start + 'دن'.length;
      final sel = TextSelection(baseOffset: start, extentOffset: end);
      final result = MarkdownEditorEngine.toggleBold(urdu, sel);

      expect(result.text, equals('آج کا **دن** اچھا تھا'));

      final untoggled = MarkdownEditorEngine.toggleBold(result.text, result.selection);
      expect(untoggled.text, equals(urdu));
    });

    test('Bold works with Unicode emoji', () {
      const text = 'Hydrate 💧 everyday';
      const sel = TextSelection(baseOffset: 8, extentOffset: 10); // '💧'
      final result = MarkdownEditorEngine.toggleBold(text, sel);

      expect(result.text, equals('Hydrate **💧** everyday'));
    });

    // --- 7. SMART ENTER IN LISTS ---
    test('Smart Enter continues checklist on new line when item is non-empty', () {
      const text = '- [ ] First task\n';
      const sel = TextSelection.collapsed(offset: 17); // after newline
      final result = MarkdownEditorEngine.handleSmartEnter(text, sel);

      expect(result, isNotNull);
      expect(result!.text, equals('- [ ] First task\n- [ ] '));
    });

    test('Smart Enter exits checklist when current item is empty', () {
      const text = '- [ ] ';
      const sel = TextSelection.collapsed(offset: 6);
      final result = MarkdownEditorEngine.handleSmartEnter(text, sel);

      expect(result, isNotNull);
      expect(result!.text, equals(''));
      expect(result.selection.start, equals(0));
    });

    test('Smart Enter continues bullet list on new line when item is non-empty', () {
      const text = '- First bullet';
      const sel = TextSelection.collapsed(offset: 14);
      final result = MarkdownEditorEngine.handleSmartEnter(text, sel);

      expect(result, isNotNull);
      expect(result!.text, equals('- First bullet\n- '));
    });

    test('Smart Enter exits bullet list when bullet is empty', () {
      const text = '- ';
      const sel = TextSelection.collapsed(offset: 2);
      final result = MarkdownEditorEngine.handleSmartEnter(text, sel);

      expect(result, isNotNull);
      expect(result!.text, equals(''));
    });

    // --- 8. DIRECT CHECKBOX TAP TOGGLE ---
    test('toggleChecklistStateAtCursor toggles [ ] to [x] when tapping checkbox prefix', () {
      const text = '- [ ] Drink 2L water';
      final result = MarkdownEditorEngine.toggleChecklistStateAtCursor(text, 3); // tapped on [ ]

      expect(result, isNotNull);
      expect(result!.text, equals('- [x] Drink 2L water'));
    });

    test('toggleChecklistStateAtCursor toggles [x] to [ ] when tapping checked checkbox', () {
      const text = '- [x] Drink 2L water';
      final result = MarkdownEditorEngine.toggleChecklistStateAtCursor(text, 3);

      expect(result, isNotNull);
      expect(result!.text, equals('- [ ] Drink 2L water'));
    });

    test('toggleChecklistStateAtCursor returns null when tapping body text away from checkbox', () {
      const text = '- [ ] Drink 2L water';
      final result = MarkdownEditorEngine.toggleChecklistStateAtCursor(text, 14); // tapped on 'water'

      expect(result, isNull);
    });
  });
}
