/// Tests for weekly Torah portion (parsha) formatting via [HebrewDateFormatter].
///
/// The Torah is divided into 54 portions read on Shabbat throughout the year.
/// The schedule differs between Israel and the Diaspora because Israel
/// celebrates one day of Yom Tov while the Diaspora celebrates two, causing
/// the portions to fall on different Shabbatot for several weeks each year.
///
/// [formatWeeklyParsha] returns the parsha for the upcoming Shabbat from any
/// given day, while [formatParsha] returns the parsha for the current day
/// (only non-null on Shabbat).
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  HebrewDateFormatter hdf = HebrewDateFormatter();

  // Wednesday May 25, 2022: Israel reads Bamidbar; Diaspora reads Bechukosai.
  test('formatWeeklyParsha', () async {
    DateTime dateTime = DateTime(2022, 5, 25);
    JewishCalendar jewishCalendar = JewishCalendar.fromDateTime(dateTime);
    jewishCalendar.inIsrael = true;
    print("Testing WeeklyParsha - inIsreal = true");
    expect(hdf.formatWeeklyParsha(jewishCalendar), "Bamidbar");
    print("Pass");
    print("Testing WeeklyParsha - inIsreal = false");
    jewishCalendar.inIsrael = false;
    expect(hdf.formatWeeklyParsha(jewishCalendar), "Bechukosai");
    print("Pass");
  });

  // Shabbat May 28, 2022: Israel reads Bamidbar; Diaspora reads Bechukosai.
  test('formatParsha', () async {
    DateTime dateTime = DateTime(2022, 5, 28);
    JewishCalendar jewishCalendar = JewishCalendar.fromDateTime(dateTime);
    jewishCalendar.inIsrael = true;
    print("Testing Parsha - inIsreal = true");
    expect(hdf.formatParsha(jewishCalendar), "Bamidbar");
    print("Pass");
    print("Testing Parsha - inIsreal = false");
    jewishCalendar.inIsrael = false;
    expect(hdf.formatParsha(jewishCalendar), "Bechukosai");
    print("Pass");
  });
}
