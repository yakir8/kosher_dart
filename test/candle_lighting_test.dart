/// Tests for candle lighting times calculated by [ComplexZmanimCalendar].
///
/// Candle lighting marks the start of Shabbat or a Jewish holiday and is
/// typically 18 minutes before sunset. The time is returned only when
/// candles are actually lit (Friday evening or Yom Tov eve); the method
/// returns `null` on Shabbat itself, regular weekdays, and Chol Hamoed.
///
/// All times in these tests are formatted as "HH:mm" in local time for
/// Jerusalem (UTC+2 / UTC+3 DST), which is the fixed test location.
library;

import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // Base location: Jerusalem. Individual tests may override the GeoLocation.
  GeoLocation geoLocation = GeoLocation.setLocation(
      "Jerusalem", 31.7964453, 35.2453987, DateTime.now());
  ComplexZmanimCalendar complexZmanimCalendar =
      ComplexZmanimCalendar.intGeoLocation(geoLocation);
  // Friday (Dec 24, 2021) has candle lighting; Saturday (Dec 25) returns null.
  test('testWeekend', () async {
    // Friday
    complexZmanimCalendar.setCalendar(DateTime(2021, 12, 24));
    expect(_getCandleLighting(complexZmanimCalendar), "16:22");
    // Saturday
    complexZmanimCalendar.setCalendar(DateTime(2021, 12, 25));
    expect(_getCandleLighting(complexZmanimCalendar), null);
  });

  // Verifies candle lighting on Rosh Hashana (two-day Yom Tov), and the edge
  // case where the second Yom Tov follows immediately after Shabbat.
  // Also checks a US location to confirm time-zone handling.
  test('testYomTov', () async {
    // Rosh Hashana
    complexZmanimCalendar.setCalendar(DateTime(2021, 9, 6));
    expect(_getCandleLighting(complexZmanimCalendar), "18:38");
    // Second Yom Tov
    complexZmanimCalendar.setCalendar(DateTime(2021, 9, 7));
    expect(_getCandleLighting(complexZmanimCalendar), "19:11");
    // Second Yom Tov after Shabbat
    complexZmanimCalendar.setCalendar(DateTime(2020, 9, 19));
    expect(_getCandleLighting(complexZmanimCalendar), "18:55");

    // Second Yom Tov in US
    complexZmanimCalendar.setGeoLocation(GeoLocation.setLocation(
        "NY", 40.7127, -74.0059, DateTime.utc(2023, 4, 6)));
    expect(_getCandleLighting(complexZmanimCalendar), "02:46");
  });

 // Chanukah is not a full Yom Tov, so candle lighting time still applies on
 // Fridays during Chanukah. Nov 30, 2021 is the first day of Chanukah (a Tuesday).
 test('testChanukah', () async {
    DateTime testDate = DateTime(2021, 11, 30);
    GeoLocation testLocation = GeoLocation.setLocation(
        "Jerusalem", 31.7964453, 35.2453987, testDate); // Use test date
    complexZmanimCalendar.setGeoLocation(testLocation);
    complexZmanimCalendar.setCalendar(testDate);
    
    expect(_getCandleLighting(complexZmanimCalendar), "16:53");
});

  // Chol Hamoed (intermediate days of Sukkot) is not a candle-lighting day.
  test('testCholHamoed', () async {
    complexZmanimCalendar.setCalendar(DateTime(2021, 9, 23));
    expect(_getCandleLighting(complexZmanimCalendar), null);
  });
}

/// Formats the candle lighting time as "HH:mm", or returns `null` if there
/// is no candle lighting on the calendar's current date.
String? _getCandleLighting(ComplexZmanimCalendar complexZmanimCalendar) {
  DateFormat dateFormat = DateFormat("HH:mm");
  DateTime? candleLighting = complexZmanimCalendar.getCandleLighting();
  return candleLighting != null ? dateFormat.format(candleLighting) : null;
}
