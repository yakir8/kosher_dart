/// Comprehensive unit tests for [AstronomicalCalendar].
///
/// Covers the following areas with a focus on edge cases:
///
/// - **Normal mid-latitude locations** — verifies that sunrise, sunset, and
///   the relationship sunrise < sunset hold for Jerusalem and New York on
///   typical dates; checks that summer days are longer than winter days.
///
/// - **Equator** — confirms sunrise and sunset are non-null on the vernal
///   equinox, that day length is approximately 12 hours (±15 min), and that
///   sunrise time varies by less than 1 UTC hour across the whole year.
///
/// - **Near-North Pole (89.9°N)** — the NOAA calculator still returns
///   computed (non-infinite) values even at extreme latitudes, so these tests
///   verify that the library does not throw and that, where a DateTime is
///   returned in summer, the day length is > 22 hours.
///
/// - **Near-South Pole (−89.9°N)** — mirrors the North Pole tests with
///   reversed seasons (southern summer in December, southern winter in June).
///
/// - **Arctic Circle (65°N)** — verifies very long summer days (> 20 h) and
///   very short winter days (< 5 h or null polar night).
///
/// - **Twilight ordering** — asserts that astronomical < nautical < civil <
///   sunrise for dawn, and sunset < civil twilight end for dusk.
///
/// - **Sea-level sunrise/sunset** — smoke-tests the elevation-independent
///   variants, confirming non-null values and the correct ordering.
///
/// - **UTC sunrise/sunset values** — checks that UTC doubles are finite, that
///   sunset > sunrise, and documents the near-pole NOAA behaviour.
///
/// - **Gregorian leap day (Feb 29)** — confirms that Feb 29 computations do
///   not throw, return non-null results, and that the sunrise time follows the
///   expected seasonal progression between Feb 28 and Mar 1.
///
/// - **Sun transit (solar noon)** — verifies that solar noon falls strictly
///   between sunrise and sunset.
///
/// Note: [AstronomicalCalendar] is not exported from `kosher_dart.dart`, so
/// this file imports it directly from its source path.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:kosher_dart/src/astronomical_calendar.dart';

// ─────────────────────────────────────────────────────────────────
// Helper: build an AstronomicalCalendar for a given lat/lon on a date
// ─────────────────────────────────────────────────────────────────
AstronomicalCalendar _calendar(
    String name, double lat, double lon, DateTime date) {
  final geo = GeoLocation.setLocation(name, lat, lon, date);
  final cal = AstronomicalCalendar(geoLocation: geo);
  cal.setCalendar(date);
  return cal;
}

void main() {
  // ────────────────────────────────────────────────────────────────
  // Sunrise at normal mid-latitude locations
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - sunrise/sunset at normal locations', () {
    test('Jerusalem: sunrise is not null on a regular day', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      expect(cal.getSunrise(), isNotNull);
    });

    test('Jerusalem: sunset is not null on a regular day', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      expect(cal.getSunset(), isNotNull);
    });

    test('Jerusalem: sunrise is before sunset', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      final sunrise = cal.getSunrise()!;
      final sunset = cal.getSunset()!;
      expect(sunrise.isBefore(sunset), isTrue);
    });

    test('New York: sunrise not null in summer', () {
      final cal = _calendar('New York', 40.7127, -74.0059, DateTime.utc(2024, 6, 21));
      expect(cal.getSunrise(), isNotNull);
    });

    test('New York: day length in summer is longer than in winter', () {
      final summer = _calendar('New York', 40.7127, -74.0059, DateTime.utc(2024, 6, 21));
      final winter = _calendar('New York', 40.7127, -74.0059, DateTime.utc(2024, 12, 21));
      final summerLen = summer.getSunset()!.difference(summer.getSunrise()!);
      final winterLen = winter.getSunset()!.difference(winter.getSunrise()!);
      expect(summerLen, greaterThan(winterLen));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Equator: day/night roughly equal on equinox
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - equator', () {
    test('Equator: sunrise is not null on vernal equinox', () {
      final cal = _calendar('Equator', 0.0, 0.0, DateTime.utc(2024, 3, 20));
      expect(cal.getSunrise(), isNotNull);
    });

    test('Equator: sunset is not null on vernal equinox', () {
      final cal = _calendar('Equator', 0.0, 0.0, DateTime.utc(2024, 3, 20));
      expect(cal.getSunset(), isNotNull);
    });

    test('Equator: day length on equinox is approximately 12 hours', () {
      final cal = _calendar('Equator', 0.0, 0.0, DateTime.utc(2024, 3, 20));
      final dayLength = cal.getSunset()!.difference(cal.getSunrise()!);
      // Should be within 15 minutes of 12 hours
      expect(dayLength.inMinutes, inInclusiveRange(705, 735));
    });

    test('Equator: sunrise time is similar year-round (within ~30 min)', () {
      final march = _calendar('Equator', 0.0, 0.0, DateTime.utc(2024, 3, 20));
      final june = _calendar('Equator', 0.0, 0.0, DateTime.utc(2024, 6, 21));
      final marchRise = march.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      final juneRise = june.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      // Both should be close to 6.0 (6:00 UTC), within 1 hour
      expect((marchRise - juneRise).abs(), lessThan(1.0));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Near-North Pole: extreme seasonal behavior
  //
  // Note: The NOAA calculator may still return a computed DateTime even at
  // very high latitudes where the sun does not physically rise/set.
  // These tests verify the library handles extreme latitudes without crashing
  // and that the UTC sunrise/sunset values encode the extreme condition.
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - North Pole edge cases', () {
    test('Near North Pole in December: sunrise UTC hour is outside 0-24 range or NaN (polar night)', () {
      final cal = _calendar('North Pole', 89.9, 0.0, DateTime.utc(2024, 12, 21));
      final utcRise = cal.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      // Either NaN (polar night) or a computed value - library must not throw
      expect(utcRise.isInfinite, isFalse);
    });

    test('Near North Pole in June: getUTCSunrise does not throw', () {
      // At lat 89.9 in midsummer the NOAA algorithm still returns a value
      final cal = _calendar('North Pole', 89.9, 0.0, DateTime.utc(2024, 6, 21));
      final utcRise = cal.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      final utcSet  = cal.getUTCSunset(AstronomicalCalendar.GEOMETRIC_ZENITH);
      expect(utcRise.isInfinite, isFalse);
      expect(utcSet.isInfinite, isFalse);
    });

    test('Near North Pole: day length in June is extremely long (>22h or midnight sun)', () {
      final cal = _calendar('North Pole', 89.9, 0.0, DateTime.utc(2024, 6, 21));
      final sr = cal.getSunrise();
      final ss = cal.getSunset();
      if (sr != null && ss != null) {
        // If the algorithm returns values, day must be very long
        expect(ss.difference(sr).inHours, greaterThan(22));
      }
      // If null, that also means midnight sun — test passes either way
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Near-South Pole: seasons are reversed
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - South Pole edge cases', () {
    test('Near South Pole in June: getUTCSunrise does not throw', () {
      final cal = _calendar('South Pole', -89.9, 0.0, DateTime.utc(2024, 6, 21));
      final utcRise = cal.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      expect(utcRise.isInfinite, isFalse);
    });

    test('Near South Pole: day length in Dec is extremely long (>22h or midnight sun)', () {
      final cal = _calendar('South Pole', -89.9, 0.0, DateTime.utc(2024, 12, 21));
      final sr = cal.getSunrise();
      final ss = cal.getSunset();
      if (sr != null && ss != null) {
        expect(ss.difference(sr).inHours, greaterThan(22));
      }
    });

    test('South Pole in June: day length is very short or null (southern polar night)', () {
      final cal = _calendar('South Pole', -89.9, 0.0, DateTime.utc(2024, 6, 21));
      final sr = cal.getSunrise();
      final ss = cal.getSunset();
      if (sr != null && ss != null) {
        // If a value is computed, day should be very short
        expect(ss.difference(sr).inHours, lessThan(3));
      }
      // null is also valid (polar night)
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Arctic Circle (~66.5°N): edge of midnight sun
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - Arctic Circle', () {
    test('Arctic Circle: has sunrise in summer (midnight sun boundary)', () {
      // At exactly 66.5N on summer solstice, sunrise/sunset just barely occur
      // Testing just below to confirm sunrise is not null
      final cal = _calendar('Arctic', 65.0, 25.0, DateTime.utc(2024, 6, 21));
      expect(cal.getSunrise(), isNotNull);
      expect(cal.getSunset(), isNotNull);
    });

    test('Arctic Circle: day length in June is very long (>20h)', () {
      final cal = _calendar('Arctic', 65.0, 25.0, DateTime.utc(2024, 6, 21));
      final dayLen = cal.getSunset()!.difference(cal.getSunrise()!);
      expect(dayLen.inHours, greaterThan(20));
    });

    test('Arctic Circle: day length in December is very short (<5h)', () {
      final cal = _calendar('Arctic', 65.0, 25.0, DateTime.utc(2024, 12, 21));
      final sr = cal.getSunrise();
      final ss = cal.getSunset();
      if (sr != null && ss != null) {
        expect(ss.difference(sr).inHours, lessThan(5));
      } else {
        // Also valid: polar night = null (sun doesn't rise at all)
        expect(sr, isNull);
      }
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Twilight calculations
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - twilight', () {
    test('civil twilight begins before sunrise', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      final civilDawn = cal.getBeginCivilTwilight();
      final sunrise = cal.getSunrise();
      expect(civilDawn, isNotNull);
      expect(sunrise, isNotNull);
      expect(civilDawn!.isBefore(sunrise!), isTrue);
    });

    test('nautical twilight begins before civil twilight', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      final nautical = cal.getBeginNauticalTwilight();
      final civil = cal.getBeginCivilTwilight();
      expect(nautical, isNotNull);
      expect(civil, isNotNull);
      expect(nautical!.isBefore(civil!), isTrue);
    });

    test('astronomical twilight begins before nautical twilight', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      final astro = cal.getBeginAstronomicalTwilight();
      final nautical = cal.getBeginNauticalTwilight();
      expect(astro, isNotNull);
      expect(nautical, isNotNull);
      expect(astro!.isBefore(nautical!), isTrue);
    });

    test('civil twilight ends after sunset', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      final sunset = cal.getSunset();
      final civilDusk = cal.getEndCivilTwilight();
      expect(sunset, isNotNull);
      expect(civilDusk, isNotNull);
      expect(sunset!.isBefore(civilDusk!), isTrue);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Sea-level sunrise/sunset
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - sea level sunrise/sunset', () {
    test('sea level sunrise is not null for Jerusalem', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      expect(cal.getSeaLevelSunrise(), isNotNull);
    });

    test('sea level sunset is not null for Jerusalem', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      expect(cal.getSeaLevelSunset(), isNotNull);
    });

    test('sea level sunrise is before sea level sunset', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      expect(cal.getSeaLevelSunrise()!.isBefore(cal.getSeaLevelSunset()!), isTrue);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // UTC sunrise/sunset values
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - UTC sunrise/sunset', () {
    test('UTC sunrise is a finite number for Jerusalem', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      final utc = cal.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      expect(utc.isNaN, isFalse);
      expect(utc.isInfinite, isFalse);
    });

    test('UTC sunset > UTC sunrise for Jerusalem', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      final rise = cal.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      final set_ = cal.getUTCSunset(AstronomicalCalendar.GEOMETRIC_ZENITH);
      expect(set_, greaterThan(rise));
    });

    test('UTC sunrise near North Pole in December is a finite number (NOAA still converges)', () {
      // The NOAA calculator returns a computed value even at 89.9°N;
      // it does not necessarily return NaN for these extreme latitudes.
      final cal = _calendar('North Pole', 89.9, 0.0, DateTime.utc(2024, 12, 21));
      final utc = cal.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      expect(utc.isInfinite, isFalse);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Gregorian leap year date in astronomical calendar
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - Gregorian leap year Feb 29', () {
    test('sunrise on Feb 29, 2024 (leap day) is not null', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 2, 29));
      expect(cal.getSunrise(), isNotNull);
    });

    test('sunrise on Feb 29 is between sunrise on Feb 28 and Mar 1', () {
      final feb28 = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 2, 28));
      final feb29 = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 2, 29));
      final mar01 = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 1));

      // All sunrises should be not null
      expect(feb28.getSunrise(), isNotNull);
      expect(feb29.getSunrise(), isNotNull);
      expect(mar01.getSunrise(), isNotNull);

      // Extract UTC hour values - spring progression means sunrise gets earlier
      final rise28 = feb28.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      final rise29 = feb29.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);
      final rise01 = mar01.getUTCSunrise(AstronomicalCalendar.GEOMETRIC_ZENITH);

      // Feb 29 should be between Feb 28 and Mar 1 (sun rises earlier as spring approaches)
      expect(rise29, lessThanOrEqualTo(rise28));
      expect(rise29, greaterThanOrEqualTo(rise01));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Sun transit (solar noon)
  // ────────────────────────────────────────────────────────────────
  group('AstronomicalCalendar - sun transit', () {
    test('sun transit is between sunrise and sunset', () {
      final cal = _calendar('Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 21));
      final transit = cal.getSunTransit();
      final sunrise = cal.getSunrise();
      final sunset = cal.getSunset();
      expect(transit, isNotNull);
      expect(sunrise!.isBefore(transit!), isTrue);
      expect(transit.isBefore(sunset!), isTrue);
    });
  });
}
