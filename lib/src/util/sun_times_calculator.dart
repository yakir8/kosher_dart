/*
 * Zmanim Java API
 * Copyright (C) 2004-2018 Eliyahu Hershfeld
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 */

import 'dart:math';
import 'package:kosher_dart/src/util/astronomical_calculator.dart';
import 'package:kosher_dart/src/util/geo_location.dart';

/// Implementation of sunrise and sunset methods to calculate astronomical times. This calculator uses the Java algorithm
/// written by [Kevin Boone](http://web.archive.org/web/20090531215353/http://www.kevinboone.com/suntimes.html) that is based on the [US Naval Observatory's](http://aa.usno.navy.mil/)[Almanac](http://aa.usno.navy.mil/publications/docs/asa.php) for Computer algorithm ( [Amazon](http://www.amazon.com/exec/obidos/tg/detail/-/0160515106/), [Barnes & Noble](http://search.barnesandnoble.com/booksearch/isbnInquiry.asp?isbn=0160515106)) and is
/// used with his permission. Added to Kevin's code is adjustment of the zenith to account for elevation.
///
/// © Eliyahu Hershfeld 2004 - 2018
/// © Kevin Boone 2000
class SunTimesCalculator extends AstronomicalCalculator {
  /// See also [AstronomicalCalculator.getCalculatorName].
  @override
  String getCalculatorName() {
    return "US Naval Almanac Algorithm";
  }

  /// See also [AstronomicalCalculator.getUTCSunrise].
  @override
  double getUTCSunrise(DateTime dateTime, GeoLocation geoLocation,
      double zenith, bool adjustForElevation) {
    double doubleTime = double.nan;
    double elevation =
        adjustForElevation ? (geoLocation.getElevation() ?? 0) : 0;
    double adjustedZenith = adjustZenith(zenith, elevation);
    doubleTime = _getTimeUTC(dateTime, geoLocation, adjustedZenith, true);
    return doubleTime;
  }

  /// See also [AstronomicalCalculator.getUTCSunset].
  @override
  double getUTCSunset(DateTime calendar, GeoLocation geoLocation, double zenith,
      bool adjustForElevation) {
    double doubleTime = double.nan;
    double elevation =
        adjustForElevation ? (geoLocation.getElevation() ?? 0) : 0;
    double adjustedZenith = adjustZenith(zenith, elevation);
    doubleTime = _getTimeUTC(calendar, geoLocation, adjustedZenith, false);
    return doubleTime;
  }

  /// The number of degrees of longitude that corresponds to one hour time difference.
  static const double DEG_PER_HOUR = 360.0 / 24.0;

  /// - [deg]: the degrees
  /// Returns sin of the angle in degrees
  static double _sinDeg(double deg) {
    return sin(deg * 2.0 * pi / 360.0);
  }

  /// - [x]: angle
  /// Returns acos of the angle in degrees
  static double _acosDeg(double x) {
    return acos(x) * 360.0 / (2 * pi);
  }

  /// - [x]: angle
  /// Returns asin of the angle in degrees
  static double _asinDeg(double x) {
    return asin(x) * 360.0 / (2 * pi);
  }

  /// - [deg]: degrees
  /// Returns tan of the angle in degrees
  static double _tanDeg(double deg) {
    return tan(deg * 2.0 * pi / 360.0);
  }

  /// Calculate cosine of the angle in degrees
  ///
  /// - [deg]: degrees
  /// Returns cosine of the angle in degrees
  static double _cosDeg(double deg) {
    return cos(deg * 2.0 * pi / 360.0);
  }

  /// Get time difference between location's longitude and the Meridian, in hours.
  ///
  /// - [longitude]: the longitude
  /// Returns time difference between the location's longitude and the Meridian, in hours. West of Meridian has a negative time difference
  static double _getHoursFromMeridian(double longitude) {
    return longitude / DEG_PER_HOUR;
  }

  /// Calculate the approximate time of sunset or sunrise in days since midnight Jan 1st, assuming 6am and 6pm events. We
  /// need this figure to derive the Sun's mean anomaly.
  ///
  /// - [dayOfYear]: the day of year
  /// - [hoursFromMeridian]: hours from the meridian
  /// - [isSunrise]: true for sunrise and false for sunset
  ///
  /// Returns the approximate time of sunset or sunrise in days since midnight Jan 1st, assuming 6am and 6pm events. We
  /// need this figure to derive the Sun's mean anomaly.
  static double _getApproxTimeDays(
      int dayOfYear, double hoursFromMeridian, bool isSunrise) {
    if (isSunrise) {
      return dayOfYear + ((6.0 - hoursFromMeridian) / 24);
    } else {
      // sunset
      return dayOfYear + ((18.0 - hoursFromMeridian) / 24);
    }
  }

  /// Calculate the Sun's mean anomaly in degrees, at sunrise or sunset, given the longitude in degrees
  ///
  /// - [dayOfYear]: the day of the year
  /// - [longitude]: longitude
  /// - [isSunrise]: true for sunrise and false for sunset
  /// Returns the Sun's mean anomaly in degrees
  static double _getMeanAnomaly(
      int dayOfYear, double longitude, bool isSunrise) {
    return (0.9856 *
            _getApproxTimeDays(
                dayOfYear, _getHoursFromMeridian(longitude), isSunrise)) -
        3.289;
  }

  /// - [sunMeanAnomaly]: the Sun's mean anomaly in degrees
  /// Returns the Sun's true longitude in degrees. The result is an angle >= 0 and <= 360.
  static double _getSunTrueLongitude(double sunMeanAnomaly) {
    double l = sunMeanAnomaly +
        (1.916 * _sinDeg(sunMeanAnomaly)) +
        (0.020 * _sinDeg(2 * sunMeanAnomaly)) +
        282.634;

    // get longitude into 0-360 degree range
    if (l >= 360.0) {
      l = l - 360.0;
    }
    if (l < 0) {
      l = l + 360.0;
    }
    return l;
  }

  /// Calculates the Sun's right ascension in hours.
  /// - [sunTrueLongitude]: the Sun's true longitude in degrees > 0 and < 360.
  /// Returns the Sun's right ascension in hours in angles > 0 and < 360.
  static double _getSunRightAscensionHours(double sunTrueLongitude) {
    double a = 0.91764 * _tanDeg(sunTrueLongitude);
    double ra = 360.0 / (2.0 * pi) * atan(a);

    double lQuadrant = (sunTrueLongitude / 90.0).floor() * 90.0;
    double raQuadrant = (ra / 90.0).floor() * 90.0;
    ra = ra + (lQuadrant - raQuadrant);

    return ra / DEG_PER_HOUR; // convert to hours
  }

  /// Calculate the cosine of the Sun's local hour angle
  ///
  /// - [sunTrueLongitude]: the sun's true longitude
  /// - [latitude]: the latitude
  /// - [zenith]: the zenith
  /// Returns the cosine of the Sun's local hour angle
  static double _getCosLocalHourAngle(
      double sunTrueLongitude, double latitude, double zenith) {
    double sinDec = 0.39782 * _sinDeg(sunTrueLongitude);
    double cosDec = _cosDeg(_asinDeg(sinDec));
    return (_cosDeg(zenith) - (sinDec * _sinDeg(latitude))) /
        (cosDec * _cosDeg(latitude));
  }

  /// Calculate local mean time of rising or setting. By 'local' is meant the exact time at the location, assuming that
  /// there were no time zone. That is, the time difference between the location and the Meridian depended entirely on
  /// the longitude. We can't do anything with this time directly; we must convert it to UTC and then to a local time.
  ///
  /// - [localHour]: the local hour
  /// - [sunRightAscensionHours]: the sun's right ascention in hours
  /// - [approxTimeDays]: approximate time days
  ///
  /// Returns the fractional number of hours since midnight as a double
  static double _getLocalMeanTime(
      double localHour, double sunRightAscensionHours, double approxTimeDays) {
    return localHour +
        sunRightAscensionHours -
        (0.06571 * approxTimeDays) -
        6.622;
  }

  /// Get sunrise or sunset time in UTC, according to flag. This time is returned as
  /// a double and is not adjusted for time-zone.
  ///
  /// - [calendar]: 
  ///   the Calendar object to extract the day of year for calculation
  /// - [geoLocation]: 
  ///   the GeoLocation object that contains the latitude and longitude
  /// - [zenith]: 
  ///   Sun's zenith, in degrees
  /// - [isSunrise]: 
  ///   True for sunrise and false for sunset.
  /// Returns the time as a double. If an error was encountered in the calculation
  /// (expected behavior for some locations such as near the poles,
  /// double.nan will be returned.
  static double _getTimeUTC(DateTime dateTime, GeoLocation geoLocation,
      double zenith, bool isSunrise) {
    int dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    double sunMeanAnomaly =
        _getMeanAnomaly(dayOfYear, geoLocation.getLongitude(), isSunrise);
    double sunTrueLong = _getSunTrueLongitude(sunMeanAnomaly);
    double sunRightAscensionHours = _getSunRightAscensionHours(sunTrueLong);
    double cosLocalHourAngle =
        _getCosLocalHourAngle(sunTrueLong, geoLocation.getLatitude(), zenith);

    double localHourAngle = 0;
    if (isSunrise) {
      localHourAngle = 360.0 - _acosDeg(cosLocalHourAngle);
    } else {
      // sunset
      localHourAngle = _acosDeg(cosLocalHourAngle);
    }
    double localHour = localHourAngle / DEG_PER_HOUR;

    double localMeanTime = _getLocalMeanTime(
        localHour,
        sunRightAscensionHours,
        _getApproxTimeDays(dayOfYear,
            _getHoursFromMeridian(geoLocation.getLongitude()), isSunrise));
    double pocessedTime =
        localMeanTime - _getHoursFromMeridian(geoLocation.getLongitude());
    while (pocessedTime < 0.0) {
      pocessedTime += 24.0;
    }
    while (pocessedTime >= 24.0) {
      pocessedTime -= 24.0;
    }
    return pocessedTime;
  }
}
