import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/markdown_lite.dart';

void main() {
  group('MarkdownLite Parser & Checklist Tests', () {
    test('Parses headings H1, H2, H3 cleanly', () {
      const markdown = '''
# Large Title
## Subheading
### Section Header
Paragraph text
''';
      final blocks = MarkdownLite.parseBlocks(markdown);
      expect(blocks.length, 4);

      expect(blocks[0].type, MarkdownBlockType.heading1);
      expect(blocks[0].contentText, 'Large Title');

      expect(blocks[1].type, MarkdownBlockType.heading2);
      expect(blocks[1].contentText, 'Subheading');

      expect(blocks[2].type, MarkdownBlockType.heading3);
      expect(blocks[2].contentText, 'Section Header');

      expect(blocks[3].type, MarkdownBlockType.paragraph);
      expect(blocks[3].contentText, 'Paragraph text');
    });

    test('Parses checklists with checked and unchecked states', () {
      const markdown = '''
- [ ] Buy organic milk
- [x] Morning run completed
* [ ] Read 10 pages
* [X] Drink 2L water
''';
      final blocks = MarkdownLite.parseBlocks(markdown);
      expect(blocks.length, 4);

      expect(blocks[0].type, MarkdownBlockType.checklist);
      expect(blocks[0].isChecked, isFalse);
      expect(blocks[0].contentText, 'Buy organic milk');

      expect(blocks[1].type, MarkdownBlockType.checklist);
      expect(blocks[1].isChecked, isTrue);
      expect(blocks[1].contentText, 'Morning run completed');

      expect(blocks[2].type, MarkdownBlockType.checklist);
      expect(blocks[2].isChecked, isFalse);
      expect(blocks[2].contentText, 'Read 10 pages');

      expect(blocks[3].type, MarkdownBlockType.checklist);
      expect(blocks[3].isChecked, isTrue);
      expect(blocks[3].contentText, 'Drink 2L water');
    });

    test('Parses inline formatting: bold, italic, and links', () {
      const line = 'Check **important** note and *read* [Docs](https://poswal.org)';
      final spans = MarkdownLite.parseSpans(line);

      expect(spans.length, 6);
      expect(spans[0].text, 'Check ');
      expect(spans[0].isBold, isFalse);

      expect(spans[1].text, 'important');
      expect(spans[1].isBold, isTrue);

      expect(spans[2].text, ' note and ');

      expect(spans[3].text, 'read');
      expect(spans[3].isItalic, isTrue);

      expect(spans[4].text, ' ');

      expect(spans[5].text, 'Docs');
      expect(spans[5].linkUrl, 'https://poswal.org');
    });

    test('Toggles checklist line from unchecked to checked and back', () {
      const initial = '''
# Morning Routine
- [ ] 10 minutes meditation
- [x] Cold shower
''';

      // Toggle line 1 (meditation) -> should become [x]
      final step1 = MarkdownLite.toggleChecklistLine(initial, 1);
      expect(step1, contains('- [x] 10 minutes meditation'));
      expect(step1, contains('- [x] Cold shower'));

      // Toggle line 2 (shower) -> should become [ ]
      final step2 = MarkdownLite.toggleChecklistLine(step1, 2);
      expect(step2, contains('- [x] 10 minutes meditation'));
      expect(step2, contains('- [ ] Cold shower'));

      // Toggle line 1 back to unchecked
      final step3 = MarkdownLite.toggleChecklistLine(step2, 1);
      expect(step3, contains('- [ ] 10 minutes meditation'));
    });

    test('Toggles checklist by item text cleanly', () {
      const doc = '''
- [ ] Prep breakfast
- [ ] Daily standup meeting
''';
      final toggled = MarkdownLite.toggleChecklistByText(doc, 'Daily standup meeting');
      expect(toggled, contains('- [ ] Prep breakfast'));
      expect(toggled, contains('- [x] Daily standup meeting'));
    });

    test('Preserves indentation when toggling indented checklists', () {
      const indented = '    - [ ] Sub-item checklist';
      final toggled = MarkdownLite.toggleChecklistLine(indented, 0);
      expect(toggled, '    - [x] Sub-item checklist');
    });
  });
}
