/// Tests for candle lighting times calculated by [ComplexZmanimCalendar].
///
/// Candle lighting marks the start of Shabbat or a Jewish holiday and is
/// typically 18 minutes before sunset. The time is returned only when
/// candles are actually lit (Friday evening or Yom Tov eve); the method
/// returns `null` on Shabbat itself, regular weekdays, and Chol Hamoed.
///
/// [ComplexZmanimCalendar.getCandleLighting] returns a `DateTime` that is correct as an
/// instant but is not flagged UTC, so formatting it directly renders it in whatever zone
/// the machine running the test happens to be in. These tests therefore format through
/// [DateTime.toUtc] and state their expectations in UTC, with the local time of the
/// location in a comment. The instants asserted are the same ones this file always
/// asserted; only the rendering is now the same everywhere.
library;

import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // Base location: Jerusalem. Individual tests may override the GeoLocation.
  // The DateTime is UTC so that nothing here depends on the machine's own zone.
  GeoLocation geoLocation = GeoLocation.setLocation(
      "Jerusalem", 31.7964453, 35.2453987, DateTime.utc(2021, 1, 1));
  ComplexZmanimCalendar complexZmanimCalendar =
      ComplexZmanimCalendar.intGeoLocation(geoLocation);

  // Friday (Dec 24, 2021) has candle lighting; Saturday (Dec 25) returns null.
  test('testWeekend', () async {
    // Friday - 16:22 in Jerusalem, which keeps UTC+2 in December.
    complexZmanimCalendar.setCalendar(DateTime.utc(2021, 12, 24));
    expect(_getCandleLighting(complexZmanimCalendar), "14:22");
    // Saturday
    complexZmanimCalendar.setCalendar(DateTime.utc(2021, 12, 25));
    expect(_getCandleLighting(complexZmanimCalendar), null);
  });

  // Verifies candle lighting on Rosh Hashana (two-day Yom Tov), and the edge
  // case where the second Yom Tov follows immediately after Shabbat.
  // Also checks a US location, which is the one case here where the location's
  // own offset differs from Jerusalem's.
  test('testYomTov', () async {
    // Rosh Hashana - 18:38 in Jerusalem, on UTC+3 summer time.
    complexZmanimCalendar.setCalendar(DateTime.utc(2021, 9, 6));
    expect(_getCandleLighting(complexZmanimCalendar), "15:38");
    // Second Yom Tov - 19:11 local.
    complexZmanimCalendar.setCalendar(DateTime.utc(2021, 9, 7));
    expect(_getCandleLighting(complexZmanimCalendar), "16:11");
    // Second Yom Tov after Shabbat - 18:55 local.
    complexZmanimCalendar.setCalendar(DateTime.utc(2020, 9, 19));
    expect(_getCandleLighting(complexZmanimCalendar), "15:55");

    // Second Yom Tov in US - 19:46 in New York, which is on UTC-4 in April.
    complexZmanimCalendar.setGeoLocation(GeoLocation.setLocation(
        "NY", 40.7127, -74.0059, DateTime.utc(2023, 4, 6)));
    expect(_getCandleLighting(complexZmanimCalendar), "23:46");
  });

  // Chanukah is not a full Yom Tov, so candle lighting time still applies on
  // Fridays during Chanukah. Nov 30, 2021 is the first day of Chanukah (a Tuesday).
  test('testChanukah', () async {
    DateTime testDate = DateTime.utc(2021, 11, 30);
    GeoLocation testLocation = GeoLocation.setLocation(
        "Jerusalem", 31.7964453, 35.2453987, testDate); // Use test date
    complexZmanimCalendar.setGeoLocation(testLocation);
    complexZmanimCalendar.setCalendar(testDate);

    // 16:53 in Jerusalem.
    expect(_getCandleLighting(complexZmanimCalendar), "14:53");
  });

  // Chol Hamoed (intermediate days of Sukkot) is not a candle-lighting day.
  test('testCholHamoed', () async {
    complexZmanimCalendar.setCalendar(DateTime.utc(2021, 9, 23));
    expect(_getCandleLighting(complexZmanimCalendar), null);
  });
}

/// Formats the candle lighting time as "HH:mm" in UTC, or returns `null` if
/// there is no candle lighting on the calendar's current date.
///
/// The conversion to UTC is what makes the result the same on every machine:
/// the returned `DateTime` carries the right instant but is not flagged UTC,
/// so formatting it as it comes renders it in the machine's own time zone.
String? _getCandleLighting(ComplexZmanimCalendar complexZmanimCalendar) {
  DateFormat dateFormat = DateFormat("HH:mm");
  DateTime? candleLighting = complexZmanimCalendar.getCandleLighting();
  return candleLighting != null ? dateFormat.format(candleLighting.toUtc()) : null;
}
