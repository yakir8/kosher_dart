import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  HebrewDateFormatter hdf = HebrewDateFormatter();
  hdf.hebrewFormat = true;

  test('ShabbosStartTime', () async {
    GeoLocation geoLocation = GeoLocation.setLocation(
        "Jerusalem", 31.7964453, 35.2453987, DateTime.parse("2022-04-19"));
    ComplexZmanimCalendar complexZmanimCalendar =
        ComplexZmanimCalendar.intGeoLocation(geoLocation);
    DateTime? time = complexZmanimCalendar.getShabbosStartTime();
    expect(time, DateTime.parse("2022-04-22 18:51:44.000"));
    print("Shabbos Start at: $time");
  });

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
