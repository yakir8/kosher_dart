import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void main() {
  group('seventeenth of Tammuz fast day postponement', () {
    test('when 17 Tammuz falls on Shabbos, only Sunday 18 is the fast', () {
      final calendar = JewishCalendar()
        ..setJewishDate(5782, JewishDate.TAMMUZ, 17);
      expect(calendar.getDayOfWeek(), JewishDate.saturday);
      expect(
          calendar.getYomTovIndex(), isNot(JewishCalendar.SEVENTEEN_OF_TAMMUZ));
      expect(calendar.isTaanis(), isFalse);
      calendar.forward();
      expect(calendar.getJewishDayOfMonth(), 18);
      expect(calendar.getDayOfWeek(), JewishDate.sunday);
      expect(calendar.getYomTovIndex(), JewishCalendar.SEVENTEEN_OF_TAMMUZ);
      expect(calendar.isTaanis(), isTrue);
    });

    test('on a regular year, 17 Tammuz stays the fast', () {
      final calendar = JewishCalendar()
        ..setJewishDate(5784, JewishDate.TAMMUZ, 17);
      expect(calendar.getDayOfWeek(), isNot(JewishDate.saturday));
      expect(calendar.getYomTovIndex(), JewishCalendar.SEVENTEEN_OF_TAMMUZ);
      expect(calendar.isTaanis(), isTrue);
      calendar.forward();
      expect(
          calendar.getYomTovIndex(), isNot(JewishCalendar.SEVENTEEN_OF_TAMMUZ));
    });
  });
}
