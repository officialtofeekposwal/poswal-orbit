import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/markdown_lite.dart';

void main() {
  group('RTL & Script Detection Tests (Urdu, Arabic, Hindi & English)', () {
    test('Detects Urdu text as RTL', () {
      // Urdu phrase: "آج کا دن کیسا رہا؟" (How was today?)
      const urduText = 'آج کا دن کیسا رہا؟';
      expect(MarkdownLite.isRtlText(urduText), isTrue);
      expect(MarkdownLite.detectDirection(urduText), AppTextDirection.rtl);
    });

    test('Detects Arabic text as RTL', () {
      // Arabic phrase: "بسم الله الرحمن الرحيم"
      const arabicText = 'بسم الله الرحمن الرحيم';
      expect(MarkdownLite.isRtlText(arabicText), isTrue);
      expect(MarkdownLite.detectDirection(arabicText), AppTextDirection.rtl);
    });

    test('Detects Hindi (Devanagari) as LTR and identifies script', () {
      // Hindi phrase: "आज का दिन बहुत अच्छा रहा।" (Today was a very good day.)
      const hindiText = 'आज का दिन बहुत अच्छा रहा।';
      expect(MarkdownLite.isDevanagari(hindiText), isTrue);
      expect(MarkdownLite.isRtlText(hindiText), isFalse);
      expect(MarkdownLite.detectDirection(hindiText), AppTextDirection.ltr);
    });

    test('Detects standard English as LTR', () {
      const englishText = 'Focus on deep work and mindfulness today.';
      expect(MarkdownLite.isRtlText(englishText), isFalse);
      expect(MarkdownLite.isDevanagari(englishText), isFalse);
      expect(MarkdownLite.detectDirection(englishText), AppTextDirection.ltr);
    });

    test('Ignores markdown formatting prefixes when detecting RTL', () {
      const markdownUrdu = '### - [ ] ضروری کام مکمل کریں';
      expect(MarkdownLite.isRtlText(markdownUrdu), isTrue);
    });
  });
}
