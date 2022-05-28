import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  HebrewDateFormatter hdf = HebrewDateFormatter();

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
