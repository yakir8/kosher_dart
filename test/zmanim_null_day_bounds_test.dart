import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

ComplexZmanimCalendar _calendar(double lat, double lon, DateTime date) {
  final calendar = ComplexZmanimCalendar.intGeoLocation(
      GeoLocation.setLocation('test', lat, lon, date));
  calendar.setCalendar(date);
  return calendar;
}

void main() {
  group('day bound that does not occur', () {
    // 16.1° tzais does not occur in London around the summer solstice.
    final london = _calendar(51.5074, -0.1278, DateTime.utc(2025, 6, 21));

    test('MGA 16.1° zmanim are null instead of the GRA zman', () {
      expect(london.getTzais16Point1Degrees(), isNull);
      expect(london.getSofZmanShmaMGA16Point1Degrees(), isNull);
      expect(london.getSofZmanTfilaMGA16Point1Degrees(), isNull);
      expect(london.getMinchaGedola16Point1Degrees(), isNull);
      expect(london.getMinchaKetana16Point1Degrees(), isNull);
      expect(london.getPlagHamincha16Point1Degrees(), isNull);
      expect(london.getSofZmanBiurChametzMGA16Point1Degrees(), isNull);
      expect(london.getShaahZmanis16Point1Degrees(), double.minPositive);
      expect(london.getSofZmanShmaGRA(), isNotNull);
    });
  });

  group('polar day without sunset', () {
    final longyearbyen = _calendar(78.2232, 15.6267, DateTime.utc(2025, 6, 21));

    test('GRA and MGA zmanim return null', () {
      expect(longyearbyen.getSeaLevelSunset(), isNull);
      expect(longyearbyen.getSofZmanShmaGRA(), isNull);
      expect(longyearbyen.getSofZmanShmaMGA(), isNull);
      expect(longyearbyen.getSofZmanTfilaGRA(), isNull);
      expect(longyearbyen.getMinchaGedola(), isNull);
      expect(longyearbyen.getMinchaKetana(), isNull);
      expect(longyearbyen.getPlagHamincha(), isNull);
      expect(longyearbyen.getMinchaGedola72Minutes(), isNull);
      expect(longyearbyen.getChatzos(), isNull);
      expect(longyearbyen.getSolarMidnight(), isNull);
      expect(longyearbyen.getShaahZmanisGra(), double.minPositive);
      expect(longyearbyen.getTemporalHour(), double.minPositive);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  group('generic methods', () {
    final jerusalem = _calendar(31.778, 35.2354, DateTime.utc(2025, 3, 20));
    final sunrise = jerusalem.getElevationAdjustedSunrise();
    final sunset = jerusalem.getElevationAdjustedSunset();

    test('return null for an explicit null start or end of day', () {
      expect(jerusalem.getSofZmanShma(null, sunset), isNull);
      expect(jerusalem.getSofZmanTfila(sunrise, null), isNull);
      expect(jerusalem.getMinchaGedola(sunrise, null), isNull);
      expect(jerusalem.getMinchaKetana(null, sunset), isNull);
      expect(jerusalem.getPlagHamincha(null, null), isNull);
      expect(jerusalem.getShaahZmanisBasedZman(null, sunset, 3), isNull);
      expect(jerusalem.getSunTransit(null, null), isNull);
      expect(jerusalem.getTemporalHour(sunrise, null), double.minPositive);
    });

    test('no-argument forms keep returning the GRA zman', () {
      int? millis(DateTime? time) => time?.millisecondsSinceEpoch;
      expect(millis(jerusalem.getMinchaGedola()), 1742465820416);
      expect(millis(jerusalem.getMinchaKetana()), 1742476736916);
      expect(millis(jerusalem.getPlagHamincha()), 1742481285458);
      expect(millis(jerusalem.getSofZmanShmaGRA()), 1742453084500);
      expect(millis(jerusalem.getSofZmanTfilaGRA()), 1742456723333);
      expect(millis(jerusalem.getSunTransit()), 1742464001000);
      expect(jerusalem.getTemporalHour(), 3638833.3333333335);
      expect(jerusalem.getMinchaGedola(sunrise, sunset),
          jerusalem.getMinchaGedola());
    });
  });
}
