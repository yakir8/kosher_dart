import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

/// A fixed-offset zoned date, like package:timezone's TZDateTime: its ISO
/// string carries the offset, and its fields are the zone's wall clock.
class _ZonedDateTime implements DateTime {
  _ZonedDateTime(int year, int month, int day, this.timeZoneOffset)
      : _utc = DateTime.utc(year, month, day).subtract(timeZoneOffset);

  _ZonedDateTime._(this._utc, this.timeZoneOffset);

  final DateTime _utc;

  @override
  final Duration timeZoneOffset;

  DateTime get _wall => _utc.add(timeZoneOffset);

  @override
  int get year => _wall.year;
  @override
  int get month => _wall.month;
  @override
  int get day => _wall.day;
  @override
  int get hour => _wall.hour;
  @override
  int get minute => _wall.minute;
  @override
  int get second => _wall.second;
  @override
  int get millisecond => _wall.millisecond;
  @override
  int get microsecond => _wall.microsecond;
  @override
  int get weekday => _wall.weekday;
  @override
  bool get isUtc => false;
  @override
  int get millisecondsSinceEpoch => _utc.millisecondsSinceEpoch;
  @override
  int get microsecondsSinceEpoch => _utc.microsecondsSinceEpoch;

  @override
  DateTime add(Duration duration) =>
      _ZonedDateTime._(_utc.add(duration), timeZoneOffset);
  @override
  DateTime subtract(Duration duration) =>
      _ZonedDateTime._(_utc.subtract(duration), timeZoneOffset);
  @override
  DateTime toUtc() => _utc;
  @override
  bool isAtSameMomentAs(DateTime other) => _utc.isAtSameMomentAs(other);
  @override
  bool isBefore(DateTime other) => _utc.isBefore(other);
  @override
  bool isAfter(DateTime other) => _utc.isAfter(other);
  @override
  int compareTo(DateTime other) => _utc.compareTo(other);

  @override
  String toIso8601String() {
    final wall = _wall.toIso8601String().replaceFirst('Z', '');
    final minutes = timeZoneOffset.inMinutes.abs();
    final hh = (minutes ~/ 60).toString().padLeft(2, '0');
    final mm = (minutes % 60).toString().padLeft(2, '0');
    return '$wall${timeZoneOffset.isNegative ? '-' : '+'}$hh$mm';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ComplexZmanimCalendar _calendar(
    String name, double latitude, double longitude, DateTime date) {
  return ComplexZmanimCalendar.intGeoLocation(
      GeoLocation.setLocation(name, latitude, longitude, date));
}

/// Midpoint of the sea level sunset of [date] and the sea level sunrise of the
/// next day, computed from plain UTC calendars.
int _expectedSolarMidnight(double latitude, double longitude, DateTime date) {
  final today = _calendar('ref', latitude, longitude,
      DateTime.utc(date.year, date.month, date.day));
  final tomorrow = _calendar('ref', latitude, longitude,
      DateTime.utc(date.year, date.month, date.day + 1));
  final sunset = today.getSeaLevelSunset()!.millisecondsSinceEpoch;
  final sunrise = tomorrow.getSeaLevelSunrise()!.millisecondsSinceEpoch;
  return (sunset + sunrise) ~/ 2;
}

void main() {
  const jerusalemLat = 31.778, jerusalemLng = 35.2354;

  group('getSolarMidnight with a zoned calendar date', () {
    for (final (date, offset) in [
      (DateTime.utc(2025, 1, 15), const Duration(hours: 2)),
      (DateTime.utc(2025, 7, 15), const Duration(hours: 3)),
    ]) {
      test('Jerusalem ${date.toIso8601String().substring(0, 10)}', () {
        final cal = _calendar('Jerusalem', jerusalemLat, jerusalemLng,
            _ZonedDateTime(date.year, date.month, date.day, offset));

        final midnight = cal.getSolarMidnight()!;

        expect(midnight.millisecondsSinceEpoch,
            _expectedSolarMidnight(jerusalemLat, jerusalemLng, date));
        expect(midnight.isAfter(cal.getSeaLevelSunset()!), isTrue);
        expect(
            cal.getMidday()!.millisecondsSinceEpoch,
            midnight
                .subtract(const Duration(hours: 12))
                .millisecondsSinceEpoch);
      });
    }

    test('matches the result for a UTC date', () {
      final zoned = _calendar('Jerusalem', jerusalemLat, jerusalemLng,
          _ZonedDateTime(2025, 3, 10, const Duration(hours: 2)));
      final utc = _calendar(
          'Jerusalem', jerusalemLat, jerusalemLng, DateTime.utc(2025, 3, 10));

      expect(zoned.getSolarMidnight()!.millisecondsSinceEpoch,
          utc.getSolarMidnight()!.millisecondsSinceEpoch);
    });

    test('east of the antimeridian (Apia, UTC+13)', () {
      const lat = -13.8333, lng = -171.7667;
      final cal = _calendar('Apia', lat, lng,
          _ZonedDateTime(2025, 6, 1, const Duration(hours: 13)));

      final midnight = cal.getSolarMidnight()!;

      expect(midnight.isAfter(cal.getSeaLevelSunset()!), isTrue);
      // Local mean time: solar midnight is within half an hour of 00:00.
      final lmt = midnight.toUtc().add(Duration(minutes: (lng * 4).round()));
      final minutesFromMidnight =
          (lmt.hour * 60 + lmt.minute + 720) % 1440 - 720;
      expect(minutesFromMidnight.abs(), lessThan(30));
    });
  });

  test('getSolarMidnight and getMidday return null when the sun does not set',
      () {
    final cal =
        _calendar('Tromso', 69.6492, 18.9553, DateTime.utc(2025, 6, 21));

    expect(cal.getSeaLevelSunset(), isNull);
    expect(cal.getSolarMidnight(), isNull);
    expect(cal.getMidday(), isNull);
  });

  test('getTaanisStartTime on the day after a fast returns the next fast', () {
    // Ta'anis Esther 5785 was Thursday, March 13, 2025.
    final date = _ZonedDateTime(2025, 3, 14, const Duration(hours: 2));
    final cal = _calendar('Jerusalem', jerusalemLat, jerusalemLng, date);

    expect(cal.getTaanisStartTime(inIsrael: true)!.isAfter(date), isTrue);
  });

  test('getShabbosStartTime on Shabbos returns the coming Friday', () {
    final zoned = _calendar('Jerusalem', jerusalemLat, jerusalemLng,
        _ZonedDateTime(2025, 1, 4, const Duration(hours: 2)));
    final utc = _calendar(
        'Jerusalem', jerusalemLat, jerusalemLng, DateTime.utc(2025, 1, 4));

    expect(zoned.getShabbosStartTime().millisecondsSinceEpoch,
        utc.getShabbosStartTime().millisecondsSinceEpoch);
  });
}
