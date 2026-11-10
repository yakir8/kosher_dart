import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void main() {
  group('HebrewDateFormatter patterns', () {
    final gregorian = JewishDate.initDate(
      jewishYear: 5784,
      jewishMonth: JewishDate.SIVAN,
      jewishDayOfMonth: 5,
    );

    test('formats the default date without consuming month-name letters', () {
      final formatter = HebrewDateFormatter();
      expect(formatter.format(gregorian), '5 Sivan 5784');
    });

    test('time token must not replace a within Sivan', () {
      final formatter = HebrewDateFormatter();
      final text = formatter.format(gregorian, pattern: 'MM a');
      expect(text.split(' ').first, 'Sivan');
      expect(text.startsWith('Sivan '), isTrue);
    });

    test('standalone weekday token E is expanded', () {
      final formatter = HebrewDateFormatter()..hebrewFormat = true;
      expect(
        formatter.format(gregorian, pattern: 'E'),
        formatter.formatDayOfWeek(gregorian),
      );
    });

    test('D is the Hebrew year ordinal, starting at 1 on Rosh Hashana', () {
      final startOfYear = JewishDate.initDate(
        jewishYear: 5784,
        jewishMonth: JewishDate.TISHREI,
        jewishDayOfMonth: 1,
      );
      final formatter = HebrewDateFormatter();
      expect(formatter.format(startOfYear, pattern: 'D'), '1');
      startOfYear.forward();
      expect(formatter.format(startOfYear, pattern: 'D'), '2');
    });

    test('a four-letter year pattern writes the year once', () {
      final formatter = HebrewDateFormatter();
      expect(formatter.format(gregorian, pattern: 'yyy'), '5784');
      expect(formatter.format(gregorian, pattern: 'yyyy'), '5784');
    });

    test('minute token must not replace mm within Tammuz', () {
      final tammuz = JewishDate.initDate(
        jewishYear: 5784,
        jewishMonth: JewishDate.TAMMUZ,
        jewishDayOfMonth: 1,
      );
      final formatter = HebrewDateFormatter();
      expect(formatter.format(tammuz, pattern: 'MM mm'), startsWith('Tammuz '));
    });

    test('Hebrew default formatting preserves date and month', () {
      final formatter = HebrewDateFormatter()..hebrewFormat = true;
      final output = formatter.format(gregorian);
      expect(output, 'ה׳ סיוון תשפ״ד');
    });
  });
}
