/// Comprehensive unit tests for [GeoLocation].
///
/// Covers the following areas with a focus on edge cases:
///
/// - **Constructors** — verifies default constructor (Greenwich), named
///   constructor [GeoLocation.setLocation], and correct storage of all fields.
///
/// - **Latitude boundary validation** — accepts ±90° (North/South Pole) and
///   0° (Equator); throws [ArgumentError] for values outside [-90, 90].
///
/// - **Longitude boundary validation** — accepts 0° (Prime Meridian), ±180°
///   (antimeridian); throws [ArgumentError] for values outside [-180, 180].
///
/// - **Elevation** — accepts 0 and positive values; throws [ArgumentError]
///   for negative elevation.
///
/// - **DMS (degrees/minutes/seconds) constructor** — verifies north and south
///   latitude parsing and that an invalid direction character throws.
///
/// - **Antimeridian adjustment** — confirms typical locations (New York,
///   Jerusalem) return an adjustment of 0.
///
/// - **Geodesic (Vincenty) distance** — tests self-distance = 0, known
///   NYC–Jerusalem distance (~9130 km), symmetry, equatorial quarter-
///   circumference (~10 007 km), and the documented NaN result for exactly
///   antipodal points where Vincenty's algorithm fails to converge.
///
/// - **Rhumb-line distance** — smoke-tests self-distance = 0.
///
/// - **Clone** — verifies that [GeoLocation.clone] produces identical field values.
///
/// - **Local mean time offset** — checks that the Prime Meridian with a UTC
///   clock returns an offset of approximately 0.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // ────────────────────────────────────────────────────────────────
  // Constructor and basic accessors
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - default constructor', () {
    test('default location is Greenwich (51.4772, 0)', () {
      final g = GeoLocation();
      expect(g.getLatitude(), closeTo(51.4772, 0.0001));
      expect(g.getLongitude(), closeTo(0.0, 0.0001));
      expect(g.getLocationName(), equals('Greenwich, England'));
    });
  });

  group('GeoLocation - setLocation constructor', () {
    test('stores name, lat, lon, elevation correctly', () {
      final g = GeoLocation.setLocation(
        'Lakewood, NJ', 40.0828, -74.2094, DateTime.utc(2024, 1, 1), 20.0);
      expect(g.getLocationName(), equals('Lakewood, NJ'));
      expect(g.getLatitude(), closeTo(40.0828, 0.0001));
      expect(g.getLongitude(), closeTo(-74.2094, 0.0001));
      expect(g.getElevation(), closeTo(20.0, 0.0001));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Edge latitudes: North Pole, South Pole, Equator
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - pole and equator latitudes', () {
    test('North Pole latitude 90 is accepted', () {
      final g = GeoLocation();
      g.setLatitude(latitude: 90.0);
      expect(g.getLatitude(), equals(90.0));
    });

    test('South Pole latitude -90 is accepted', () {
      final g = GeoLocation();
      g.setLatitude(latitude: -90.0);
      expect(g.getLatitude(), equals(-90.0));
    });

    test('Equator latitude 0 is accepted', () {
      final g = GeoLocation();
      g.setLatitude(latitude: 0.0);
      expect(g.getLatitude(), equals(0.0));
    });

    test('latitude > 90 throws ArgumentError', () {
      final g = GeoLocation();
      expect(() => g.setLatitude(latitude: 90.1), throwsArgumentError);
    });

    test('latitude < -90 throws ArgumentError', () {
      final g = GeoLocation();
      expect(() => g.setLatitude(latitude: -90.1), throwsArgumentError);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Edge longitudes: Prime Meridian, Antimeridian
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - meridian longitudes', () {
    test('Prime Meridian longitude 0 is accepted', () {
      final g = GeoLocation();
      g.setLongitude(longitude: 0.0);
      expect(g.getLongitude(), equals(0.0));
    });

    test('longitude 180 (antimeridian east) is accepted', () {
      final g = GeoLocation();
      g.setLongitude(longitude: 180.0);
      expect(g.getLongitude(), equals(180.0));
    });

    test('longitude -180 (antimeridian west) is accepted', () {
      final g = GeoLocation();
      g.setLongitude(longitude: -180.0);
      expect(g.getLongitude(), equals(-180.0));
    });

    test('longitude > 180 throws ArgumentError', () {
      final g = GeoLocation();
      expect(() => g.setLongitude(longitude: 180.1), throwsArgumentError);
    });

    test('longitude < -180 throws ArgumentError', () {
      final g = GeoLocation();
      expect(() => g.setLongitude(longitude: -180.1), throwsArgumentError);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Elevation
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - elevation', () {
    test('zero elevation is accepted', () {
      final g = GeoLocation();
      g.setElevation(0.0);
      expect(g.getElevation(), equals(0.0));
    });

    test('positive elevation is accepted', () {
      final g = GeoLocation();
      g.setElevation(834.0); // Jerusalem ~834m
      expect(g.getElevation(), closeTo(834.0, 0.001));
    });

    test('negative elevation throws ArgumentError', () {
      final g = GeoLocation();
      expect(() => g.setElevation(-1.0), throwsArgumentError);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // DMS (degrees/minutes/seconds) constructor
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - DMS latitude/longitude', () {
    test('setLatitude DMS north', () {
      final g = GeoLocation();
      g.setLatitude(degrees: 40, minutes: 4, seconds: 58.0, direction: 'N');
      expect(g.getLatitude(), closeTo(40.083, 0.001));
    });

    test('setLatitude DMS south negates value', () {
      final g = GeoLocation();
      g.setLatitude(degrees: 33, minutes: 52, seconds: 0.0, direction: 'S');
      expect(g.getLatitude(), isNegative);
    });

    test('setLatitude DMS with invalid direction throws', () {
      final g = GeoLocation();
      expect(
        () => g.setLatitude(degrees: 40, minutes: 4, seconds: 0.0, direction: 'X'),
        throwsArgumentError,
      );
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Antimeridian adjustment
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - antimeridian adjustment', () {
    test('typical location returns 0 adjustment', () {
      // New York: lon -74, UTC-5 -> no antimeridian crossing
      final g = GeoLocation.setLocation(
          'New York', 40.7127, -74.0059, DateTime.utc(2024, 1, 1));
      expect(g.getAntimeridianAdjustment(), equals(0));
    });

    test('Jerusalem returns 0 adjustment', () {
      final g = GeoLocation.setLocation(
          'Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 1, 1));
      expect(g.getAntimeridianAdjustment(), equals(0));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Geodesic distance
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - geodesic distance', () {
    test('distance from a point to itself is 0', () {
      final nyc = GeoLocation.setLocation(
          'NYC', 40.7127, -74.0059, DateTime.utc(2024, 1, 1));
      final nyc2 = GeoLocation.setLocation(
          'NYC', 40.7127, -74.0059, DateTime.utc(2024, 1, 1));
      expect(nyc.getGeodesicDistance(nyc2), closeTo(0, 1));
    });

    test('distance NYC to Jerusalem is approximately 9130 km', () {
      final nyc = GeoLocation.setLocation(
          'NYC', 40.7127, -74.0059, DateTime.utc(2024, 1, 1));
      final jerusalem = GeoLocation.setLocation(
          'Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 1, 1));
      final distanceMeters = nyc.getGeodesicDistance(jerusalem);
      // ~9130 km, allow ±100 km tolerance
      expect(distanceMeters, inInclusiveRange(9000000, 9300000));
    });

    test('distance is symmetric', () {
      final a = GeoLocation.setLocation(
          'A', 51.5074, -0.1278, DateTime.utc(2024, 1, 1)); // London
      final b = GeoLocation.setLocation(
          'B', 48.8566, 2.3522, DateTime.utc(2024, 1, 1)); // Paris
      expect(a.getGeodesicDistance(b), closeTo(b.getGeodesicDistance(a), 1));
    });

    test('equatorial quarter-circumference: distance ~10 007 km', () {
      // Two points on the equator, 90 degrees apart
      // Vincenty fails for antipodal points (180° apart), so we use 90° here.
      final a = GeoLocation.setLocation('A', 0.0, 0.0, DateTime.utc(2024, 1, 1));
      final b = GeoLocation.setLocation('B', 0.0, 90.0, DateTime.utc(2024, 1, 1));
      final dist = a.getGeodesicDistance(b);
      // Quarter of Earth's circumference ~10,018 km (WGS-84 equatorial)
      expect(dist, inInclusiveRange(9900000, 10100000));
    });

    test('antipodal equatorial points return NaN (Vincenty known limitation)', () {
      // Vincenty formula does not converge for exactly antipodal points
      final a = GeoLocation.setLocation('A', 0.0, 0.0, DateTime.utc(2024, 1, 1));
      final b = GeoLocation.setLocation('B', 0.0, 180.0, DateTime.utc(2024, 1, 1));
      final dist = a.getGeodesicDistance(b);
      expect(dist.isNaN, isTrue);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Rhumb-line distance
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - rhumb line distance', () {
    test('rhumb distance from a point to itself is 0', () {
      final g = GeoLocation.setLocation(
          'Tel Aviv', 32.0853, 34.7818, DateTime.utc(2024, 1, 1));
      final g2 = GeoLocation.setLocation(
          'Tel Aviv', 32.0853, 34.7818, DateTime.utc(2024, 1, 1));
      expect(g.getRhumbLineDistance(g2), closeTo(0, 1));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Clone
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - clone', () {
    test('clone produces equal values', () {
      final original = GeoLocation.setLocation(
          'Jerusalem', 31.7964, 35.2454, DateTime.utc(2024, 3, 15), 834.0);
      final clone = original.clone();
      expect(clone.getLatitude(), equals(original.getLatitude()));
      expect(clone.getLongitude(), equals(original.getLongitude()));
      expect(clone.getLocationName(), equals(original.getLocationName()));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Local mean time offset
  // ────────────────────────────────────────────────────────────────
  group('GeoLocation - local mean time offset', () {
    test('prime meridian UTC has offset ~0', () {
      // Greenwich, longitude 0, UTC timezone
      final g = GeoLocation.setLocation(
          'Greenwich', 51.4772, 0.0, DateTime.utc(2024, 1, 1));
      // LMT offset = lon * 4 * 60000 - tzOffsetMs; at UTC, tzOffset=0
      expect(g.getLocalMeanTimeOffset(), closeTo(0, 1000));
    });
  });
}
