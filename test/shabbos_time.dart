/// Tests for Shabbat start and end times calculated by [ComplexZmanimCalendar].
///
/// Shabbat begins at candle lighting (18 minutes before sunset by default) on
/// Friday and ends at nightfall (Tzet HaKochavim) on Saturday. Both times are
/// location-dependent; the tests use Jerusalem as a fixed reference point.
///
/// The [HebrewDateFormatter] is declared but only used implicitly; it does not
/// affect the assertions.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  HebrewDateFormatter hdf = HebrewDateFormatter();
  hdf.hebrewFormat = true;

  // Verifies that the calendar returns the correct Shabbat start time for
  // Jerusalem on the Friday of the week of April 22, 2022.
  test('ShabbosStartTime', () async {
    GeoLocation geoLocation = GeoLocation.setLocation(
        "Jerusalem", 31.7964453, 35.2453987, DateTime.parse("2022-04-19"));
    ComplexZmanimCalendar complexZmanimCalendar =
        ComplexZmanimCalendar.intGeoLocation(geoLocation);
    DateTime? time = complexZmanimCalendar.getShabbosStartTime();
    expect(time, DateTime.parse("2022-04-22 18:51:44.000"));
    print("Shabbos Start at: $time");
  });

  // Verifies that the calendar returns the correct Shabbat exit (Havdalah)
  // time for Jerusalem on the Saturday of the same week.
  test('ShabbosExitTime', () async {
    GeoLocation geoLocation = GeoLocation.setLocation(
        "Jerusalem", 31.7964453, 35.2453987, DateTime.parse("2022-04-19"));
    ComplexZmanimCalendar complexZmanimCalendar =
        ComplexZmanimCalendar.intGeoLocation(geoLocation);
    DateTime? time = complexZmanimCalendar.getShabbosExitTime();
    expect(time, DateTime.parse("2022-04-23 19:52:49.000"));
    print("Shabbos Start at: $time");
  });
}
