import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void main() {
  group('formatHebrewNumber', () {
    test('default settings match established spellings', () {
      final formatter = HebrewDateFormatter();
      final expected = <int, String>{
        0: 'אפס',
        1: 'א׳',
        10: 'י׳',
        15: 'ט״ו',
        16: 'ט״ז',
        33: 'ל״ג',
        100: 'ק׳',
        400: 'ת׳',
        715: 'תשט״ו',
        780: 'תש״פ',
        999: 'תתקצ״ט',
        5784: 'תשפ״ד',
        6000: 'ו׳ אלפים',
      };
      expected.forEach((number, label) {
        expect(formatter.formatHebrewNumber(number), label, reason: '$number');
      });
    });

    test('formatter options change only their own instance', () {
      final plain = HebrewDateFormatter()..useGershGershayim = false;
      final finalLong = HebrewDateFormatter()
        ..useFinalFormLetters = true
        ..useLongHebrewYears = true;
      final standard = HebrewDateFormatter();

      expect(plain.formatHebrewNumber(5784), 'תשפד');
      expect(plain.formatHebrewNumber(15), 'טו');
      expect(finalLong.formatHebrewNumber(5780), 'ה׳ תש״ף');
      expect(finalLong.formatHebrewNumber(50), 'נ׳');
      expect(standard.formatHebrewNumber(5780), 'תש״פ');
      expect(standard.formatHebrewNumber(15), 'ט״ו');
    });

    test('rejects numbers outside 0..9999', () {
      final formatter = HebrewDateFormatter();
      expect(() => formatter.formatHebrewNumber(-1), throwsArgumentError);
      expect(() => formatter.formatHebrewNumber(10000), throwsArgumentError);
    });
  });
}
