import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/data/vault/vault_markdown.dart';

void main() {
  test('encode/decode roundtrip keeps types, unicode and body', () {
    final meta = <String, Object?>{
      'id': 'abc',
      'title': 'He said "hi": नमस्ते',
      'n': 3,
      'x': 1.5,
      'ok': true,
      'none': null,
      'tags': ['a', 'b c'],
      'empty': <String>[],
    };
    final text = VaultMarkdown.encode(meta, 'Line1\n\nLine3');
    final doc = VaultMarkdown.decode(text)!;
    expect(doc.meta['title'], 'He said "hi": नमस्ते');
    expect(doc.meta['n'], 3);
    expect(doc.meta['x'], 1.5);
    expect(doc.meta['ok'], true);
    expect(doc.meta['none'], isNull);
    expect(doc.meta['tags'], ['a', 'b c']);
    expect(doc.meta['empty'], isEmpty);
    expect(doc.body, 'Line1\n\nLine3');
  });

  test('file without frontmatter is all body', () {
    final doc = VaultMarkdown.decode('Just text\nmore')!;
    expect(doc.meta, isEmpty);
    expect(doc.body, 'Just text\nmore');
  });

  test('Obsidian-style frontmatter (unquoted values, block list) parses', () {
    final doc = VaultMarkdown.decode('---\ntitle: Hello\ntags:\n  - one\n  - two\n---\nBody')!;
    expect(doc.meta['title'], 'Hello');
    expect(doc.meta['tags'], ['one', 'two']);
    expect(doc.body, 'Body');
  });

  test('CRLF files are handled', () {
    final doc = VaultMarkdown.decode('---\r\ntitle: Hi\r\n---\r\n\r\nBody\r\n')!;
    expect(doc.meta['title'], 'Hi');
    expect(doc.body, 'Body\n');
  });

  test('broken frontmatter returns null instead of throwing', () {
    expect(VaultMarkdown.decode('---\nfoo: [unclosed\n---\nx'), isNull);
    expect(VaultMarkdown.decode('---\nnever closed\n'), isNull);
  });

  test('fileStem sanitizes names', () {
    expect(VaultMarkdown.fileStem('a/b:c*?'), 'a b c');
    expect(VaultMarkdown.fileStem('   '), 'Untitled');
    expect(VaultMarkdown.fileStem('.hidden'), '_.hidden');
    expect(VaultMarkdown.fileStem('x' * 100).length, 60);
  });

  test('hash is stable and differs for different text', () {
    expect(VaultMarkdown.hash('abc'), VaultMarkdown.hash('abc'));
    expect(VaultMarkdown.hash('abc'), isNot(VaultMarkdown.hash('abd')));
  });
}
