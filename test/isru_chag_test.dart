import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void main() {
  JewishCalendar onDate(int year, int month, int day,
      {required bool inIsrael}) {
    return JewishCalendar()
      ..inIsrael = inIsrael
      ..setJewishDate(year, month, day);
  }

  group('Isru Chag in Israel and the diaspora', () {
    for (final inIsrael in [true, false]) {
      final place = inIsrael ? 'Israel' : 'diaspora';

      test('the day after the last day of Pesach in $place', () {
        final festival = onDate(5784, JewishDate.NISSAN, inIsrael ? 21 : 22,
            inIsrael: inIsrael);
        final isru = onDate(5784, JewishDate.NISSAN, inIsrael ? 22 : 23,
            inIsrael: inIsrael);
        expect(festival.getYomTovIndex(), JewishCalendar.PESACH);
        expect(festival.isIsruChag(), isFalse);
        expect(isru.getYomTovIndex(), JewishCalendar.ISRU_CHAG);
        expect(isru.isIsruChag(), isTrue);
        expect(isru.isYomTovAssurBemelacha(), isFalse);
        expect(isru.isYomTov(), isFalse);
      });

      test('the day after Shavuos in $place', () {
        final isru = onDate(5784, JewishDate.SIVAN, inIsrael ? 7 : 8,
            inIsrael: inIsrael);
        expect(isru.getYomTovIndex(), JewishCalendar.ISRU_CHAG);
        expect(isru.isIsruChag(), isTrue);
        expect(isru.isYomTov(), isFalse);
      });

      test('the day after Shemini Atzeres/Simchas Torah in $place', () {
        final isru = onDate(5785, JewishDate.TISHREI, inIsrael ? 23 : 24,
            inIsrael: inIsrael);
        expect(isru.getYomTovIndex(), JewishCalendar.ISRU_CHAG);
        expect(isru.isIsruChag(), isTrue);
        expect(isru.isYomTovAssurBemelacha(), isFalse);
      });

      test('the first day in $place is not Isru Chag', () {
        final festival = onDate(5784, JewishDate.SIVAN, 6, inIsrael: inIsrael);
        expect(festival.getYomTovIndex(), JewishCalendar.SHAVUOS);
        expect(festival.isIsruChag(), isFalse);
      });
    }

    test('Shushan Purim Katan does not collide with Isru Chag', () {
      final calendar = onDate(5784, JewishDate.ADAR, 15, inIsrael: true);
      expect(calendar.getYomTovIndex(), JewishCalendar.SHUSHAN_PURIM_KATAN);
      expect(calendar.getYomTovIndex(), isNot(JewishCalendar.ISRU_CHAG));
      expect(calendar.isIsruChag(), isFalse);
    });

    test('the new holiday index has English, Hebrew and short labels', () {
      final calendar = onDate(5784, JewishDate.NISSAN, 22, inIsrael: true);
      final formatter = HebrewDateFormatter();
      expect(formatter.formatYomTov(calendar), 'Isru Chag');
      formatter.hebrewFormat = true;
      expect(formatter.formatYomTov(calendar), 'אסרו חג');
      formatter.useShortHolidayFormat = true;
      expect(formatter.formatYomTov(calendar), 'אסרו חג');
    });
  });
}
