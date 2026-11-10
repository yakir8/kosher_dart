/// Tests for [JewishCalendar.isMukafChoma] and [JewishCalendar.isPurim].
///
/// Purim is on 14 Adar (Adar II in a leap year), and on 15 Adar (Shushan
/// Purim) in a city surrounded by a wall from the time of Yehoshua.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  JewishCalendar day(int year, int month, int dayOfMonth, {bool mukafChoma = false}) =>
      JewishCalendar()
        ..isMukafChoma = mukafChoma
        ..setJewishDate(year, month, dayOfMonth);

  group('isPurim', () {
    test('14 Adar is Purim outside a mukaf choma', () {
      expect(day(5785, JewishDate.ADAR, 14).isPurim(), isTrue);
      expect(day(5785, JewishDate.ADAR, 15).isPurim(), isFalse);
    });

    test('15 Adar is Purim in a mukaf choma', () {
      expect(day(5785, JewishDate.ADAR, 14, mukafChoma: true).isPurim(), isFalse);
      expect(day(5785, JewishDate.ADAR, 15, mukafChoma: true).isPurim(), isTrue);
    });

    test('in a leap year Purim is in Adar II, not Adar I', () {
      expect(day(5784, JewishDate.ADAR_II, 14).isPurim(), isTrue);
      expect(day(5784, JewishDate.ADAR, 14).isPurim(), isFalse);
      expect(day(5784, JewishDate.ADAR_II, 15, mukafChoma: true).isPurim(), isTrue);
      expect(day(5784, JewishDate.ADAR, 15, mukafChoma: true).isPurim(), isFalse);
    });

    test('isMukafChoma defaults to false and is kept by clone()', () {
      expect(JewishCalendar().isMukafChoma, isFalse);
      expect(day(5785, JewishDate.ADAR, 15, mukafChoma: true).clone().isMukafChoma, isTrue);
    });
  });
}
