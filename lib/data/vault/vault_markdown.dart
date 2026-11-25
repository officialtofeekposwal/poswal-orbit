import 'dart:convert';

import 'package:yaml/yaml.dart';

class VaultDoc {
  final Map<String, Object?> meta;
  final String body;
  const VaultDoc(this.meta, this.body);
}

abstract final class VaultMarkdown {
  /// Writes:
  /// ---
  /// key: value
  /// ---
  ///
  /// body
  ///
  /// Strings are written as JSON strings, which is valid YAML double-quoted
  /// syntax. Lists are written as YAML block lists.
  static String encode(Map<String, Object?> meta, String body) {
    final b = StringBuffer('---\n');
    meta.forEach((key, value) {
      if (value is List) {
        if (value.isEmpty) {
          b.write('$key: []\n');
        } else {
          b.write('$key:\n');
          for (final item in value) {
            b.write('  - ${_scalar(item)}\n');
          }
        }
      } else {
        b.write('$key: ${_scalar(value)}\n');
      }
    });
    b.write('---\n\n');
    b.write(body);
    return b.toString();
  }

  static String _scalar(Object? v) {
    if (v == null) return 'null';
    if (v is bool || v is int) return v.toString();
    if (v is double) {
      if (v.isNaN || v.isInfinite) return '0';
      return v.toString();
    }
    return jsonEncode(v.toString());
  }

  /// Returns null when the frontmatter is malformed.
  /// A file without any frontmatter is valid: meta is empty, body is the text.
  static VaultDoc? decode(String raw) {
    var text = raw.replaceAll('\r\n', '\n');
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    if (!text.startsWith('---\n')) {
      return VaultDoc(const <String, Object?>{}, text);
    }
    final lines = text.split('\n');
    var close = -1;
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].trimRight() == '---') {
        close = i;
        break;
      }
    }
    if (close == -1) return null;

    final yamlText = lines.sublist(1, close).join('\n');
    var body = lines.sublist(close + 1).join('\n');
    if (body.startsWith('\n')) body = body.substring(1);

    try {
      final parsed = loadYaml(yamlText);
      final meta = <String, Object?>{};
      if (parsed is YamlMap) {
        parsed.forEach((k, v) => meta[k.toString()] = _plain(v));
      } else if (parsed != null) {
        return null;
      }
      return VaultDoc(meta, body);
    } catch (_) {
      return null;
    }
  }

  static Object? _plain(Object? v) {
    if (v is YamlMap) {
      return {for (final e in v.entries) e.key.toString(): _plain(e.value)};
    }
    if (v is YamlList) return v.map(_plain).toList();
    return v;
  }

  /// 32-bit FNV-1a hash of the text (stable across runs/devices).
  static int hash(String s) {
    var h = 0x811c9dc5;
    for (final u in s.codeUnits) {
      h ^= u;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  /// Makes a safe file name (without extension) from any text.
  static String fileStem(String raw, {String fallback = 'Untitled', int maxLen = 60}) {
    var s = raw.replaceAll(RegExp(r'[\\/:*?"<>|#^\[\]\u0000-\u001F]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s.runes.length > maxLen) {
      s = String.fromCharCodes(s.runes.take(maxLen)).trim();
    }
    while (s.endsWith('.')) {
      s = s.substring(0, s.length - 1).trimRight();
    }
    if (s.isEmpty) return fallback;
    if (s.startsWith('.')) s = '_$s';
    return s;
  }
}
