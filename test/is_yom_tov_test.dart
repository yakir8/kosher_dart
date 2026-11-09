/// Tests for [JewishCalendar.isYomTov] on _Erev Yom Tov_ and the Tachanun
/// rule that depends on it.
///
/// Matches KosherJava: _Erev Yom Tov_ is not _Yom Tov_ (except
/// [JewishCalendar.HOSHANA_RABBA] and the _erev_ of the last days of
/// _Pesach_), while minor holidays such as Chanukah still are.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  JewishCalendar day(int year, int month, int dayOfMonth, {bool inIsrael = false}) =>
      JewishCalendar()
        ..inIsrael = inIsrael
        ..setJewishDate(year, month, dayOfMonth);

  group('isYomTov on Erev Yom Tov', () {
    final erevDays = {
      'Erev Pesach': day(5784, JewishDate.NISSAN, 14),
      'Erev Shavuos': day(5784, JewishDate.SIVAN, 5),
      'Erev Rosh Hashana': day(5784, JewishDate.ELUL, 29),
      'Erev Yom Kippur': day(5785, JewishDate.TISHREI, 9),
      'Erev Succos': day(5785, JewishDate.TISHREI, 14),
    };
    erevDays.forEach((name, c) {
      test('$name is Erev Yom Tov and not Yom Tov', () {
        expect(c.isErevYomTov(), isTrue);
        expect(c.isYomTov(), isFalse);
      });
    });

    test('Hoshana Rabba is both Erev Yom Tov and Yom Tov', () {
      final c = day(5785, JewishDate.TISHREI, 21);
      expect(c.isErevYomTov(), isTrue);
      expect(c.isYomTov(), isTrue);
    });

    test('20 Nisan (Erev the last days of Pesach) is still Yom Tov', () {
      final c = day(5784, JewishDate.NISSAN, 20);
      expect(c.isErevYomTov(), isTrue);
      expect(c.isYomTov(), isTrue);
    });
  });

  group('isYomTov on other days (unchanged)', () {
    test('Yom Tov days are Yom Tov', () {
      expect(day(5784, JewishDate.NISSAN, 15).isYomTov(), isTrue);
      expect(day(5785, JewishDate.TISHREI, 10).isYomTov(), isTrue);
    });

    test('minor holidays are Yom Tov, as in KosherJava', () {
      expect(day(5785, JewishDate.KISLEV, 25).isYomTov(), isTrue);
      expect(day(5784, JewishDate.IYAR, 18).isYomTov(), isTrue);
      expect(day(5784, JewishDate.AV, 15).isYomTov(), isTrue);
    });

    test('fasts other than Yom Kippur are not Yom Tov', () {
      expect(day(5784, JewishDate.TAMMUZ, 17).isYomTov(), isFalse);
    });

    test('a plain weekday is not Yom Tov', () {
      expect(day(5784, JewishDate.CHESHVAN, 10).isYomTov(), isFalse);
    });
  });

  group('Tachanun on Erev Yom Tov', () {
    final rules = TefilaRules();

    test('no Tachanun on Erev Rosh Hashana', () {
      expect(rules.isTachanunRecitedShacharis(day(5784, JewishDate.ELUL, 29)), isFalse);
    });

    test('Tachanun on a plain day in Elul', () {
      expect(rules.isTachanunRecitedShacharis(day(5784, JewishDate.ELUL, 26)), isTrue);
    });

    test('Mincha before Erev Rosh Hashana still has Tachanun', () {
      expect(rules.isTachanunRecitedMincha(day(5784, JewishDate.ELUL, 26)), isTrue);
    });
  });
}
