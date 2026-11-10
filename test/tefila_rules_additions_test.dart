/// Tests for [TefilaRules.isAlHanissimRecited],
/// [TefilaRules.isYaalehVeyavoRecited] and [TefilaRules.isMizmorLesodaRecited],
/// as in KosherJava.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  JewishCalendar day(int year, int month, int dayOfMonth, {bool inIsrael = false, bool mukafChoma = false}) =>
      JewishCalendar()
        ..inIsrael = inIsrael
        ..isMukafChoma = mukafChoma
        ..setJewishDate(year, month, dayOfMonth);
  final rules = TefilaRules();

  group('isAlHanissimRecited', () {
    test('on Chanukah', () {
      expect(rules.isAlHanissimRecited(day(5785, JewishDate.KISLEV, 25)), isTrue);
      expect(rules.isAlHanissimRecited(day(5785, JewishDate.TEVES, 2)), isTrue);
    });

    test('on Purim, and on Shushan Purim in a mukaf choma only', () {
      expect(rules.isAlHanissimRecited(day(5785, JewishDate.ADAR, 14)), isTrue);
      expect(rules.isAlHanissimRecited(day(5785, JewishDate.ADAR, 15)), isFalse);
      expect(rules.isAlHanissimRecited(day(5785, JewishDate.ADAR, 14, mukafChoma: true)), isFalse);
      expect(rules.isAlHanissimRecited(day(5785, JewishDate.ADAR, 15, mukafChoma: true)), isTrue);
    });

    test('not on Purim Katan or a plain day', () {
      expect(rules.isAlHanissimRecited(day(5784, JewishDate.ADAR, 14)), isFalse);
      expect(rules.isAlHanissimRecited(day(5785, JewishDate.CHESHVAN, 10)), isFalse);
    });
  });

  group('isYaalehVeyavoRecited', () {
    test('on Rosh Chodesh and the festivals with their Chol Hamoed', () {
      for (final c in [
        day(5785, JewishDate.CHESHVAN, 1),
        day(5785, JewishDate.TISHREI, 30),
        day(5784, JewishDate.NISSAN, 15),
        day(5784, JewishDate.NISSAN, 18),
        day(5784, JewishDate.SIVAN, 6),
        day(5785, JewishDate.TISHREI, 1),
        day(5785, JewishDate.TISHREI, 10),
        day(5785, JewishDate.TISHREI, 17),
        day(5785, JewishDate.TISHREI, 21),
        day(5785, JewishDate.TISHREI, 22),
        day(5785, JewishDate.TISHREI, 23),
      ]) {
        expect(rules.isYaalehVeyavoRecited(c), isTrue, reason: '${c.getJewishDayOfMonth()}/${c.getJewishMonth()}');
      }
    });

    test('not on Chanukah, Purim, a fast, Erev Pesach or a plain day', () {
      for (final c in [
        day(5785, JewishDate.KISLEV, 26),
        day(5785, JewishDate.ADAR, 14),
        day(5784, JewishDate.TAMMUZ, 17),
        day(5784, JewishDate.NISSAN, 14),
        day(5785, JewishDate.CHESHVAN, 10),
      ]) {
        expect(rules.isYaalehVeyavoRecited(c), isFalse, reason: '${c.getJewishDayOfMonth()}/${c.getJewishMonth()}');
      }
    });
  });

  group('isMizmorLesodaRecited', () {
    final sephardi = TefilaRules(mizmorLesodaRecitedErevYomKippurAndPesach: true);

    test('on a plain weekday', () {
      expect(rules.isMizmorLesodaRecited(day(5785, JewishDate.CHESHVAN, 10)), isTrue);
    });

    test('never on Shabbos or Yom Tov', () {
      // 15 Cheshvan 5785 was a Shabbos.
      expect(day(5785, JewishDate.CHESHVAN, 15).getDayOfWeek(), 7);
      expect(sephardi.isMizmorLesodaRecited(day(5785, JewishDate.CHESHVAN, 15)), isFalse);
      expect(sephardi.isMizmorLesodaRecited(day(5784, JewishDate.NISSAN, 15)), isFalse);
    });

    test('on Erev Yom Kippur, Erev Pesach and Chol Hamoed Pesach only by the Sephardi setting', () {
      for (final c in [
        day(5785, JewishDate.TISHREI, 9),
        day(5784, JewishDate.NISSAN, 14),
        day(5784, JewishDate.NISSAN, 18),
      ]) {
        expect(rules.isMizmorLesodaRecited(c), isFalse);
        expect(sephardi.isMizmorLesodaRecited(c), isTrue);
      }
    });

    test('the default is the Ashkenazi custom', () {
      expect(TefilaRules().mizmorLesodaRecitedErevYomKippurAndPesach, isFalse);
    });
  });
}
