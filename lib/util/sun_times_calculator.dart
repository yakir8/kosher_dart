/*
 * Zmanim Java API
 * Copyright (C) 2004-2011 Eliyahu Hershfeld
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 *  License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General  License for more
 * details.
 * You should have received a copy of the GNU Lesser General  License along with this library; if not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 */

import 'dart:math';
import 'package:kosher_dart/util/astronomical_calculator.dart';
import 'package:kosher_dart/util/geo_Location.dart';

/*
 * Implementation of sunrise and sunset methods to calculate astronomical times. This calculator uses the Java algorithm
 * written by <arrow_expand href="http://web.archive.org/web/20090531215353/http://www.kevinboone.com/suntimes.html">Kevin
 * Boone</arrow_expand> that is based on the <arrow_expand href = "http://aa.usno.navy.mil/">US Naval Observatory's</arrow_expand><arrow_expand
 * href="http://aa.usno.navy.mil/ations/docs/asa.php">Almanac</arrow_expand> for Computer algorithm ( <arrow_expand
 * href="http://www.amazon.com/exec/obidos/tg/detail/-/0160515106/">Amazon</arrow_expand>, <arrow_expand
 * href="http://search.barnesandnoble.com/booksearch/isbnInquiry.asp?isbn=0160515106">Barnes &amp; Noble</arrow_expand>) and is
 * used with his permission. Added to Kevin's code is adjustment of the zenith to account for elevation.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2011
 * @author &copy; Kevin Boone 2000
 * @version 1.1
 */
 class SunTimesCalculator extends AstronomicalCalculator {
  /*
   * @see com.thewisejewish.zmanim.util.AstronomicalCalculator#getCalculatorName()
   */
   String getCalculatorName() {
    return "US Naval Almanac Algorithm";
  }

  /*
   * @see com.thewisejewish.zmanim.util.AstronomicalCalculator#getUTCSunrise(Calendar, GeoLocation, double, boolean)
   */
   double getUTCSunrise(DateTime dateTime, GeoLocation geoLocation, double zenith, bool adjustForElevation) {
    double doubleTime = 0;

    double elevation = adjustForElevation ? geoLocation.getElevation() : 0;
    double adjustedZenith = adjustZenith(zenith, elevation);

    doubleTime = getTimeUTC(dateTime.year, dateTime.month,dateTime.day, geoLocation.getLongitude(), geoLocation.getLatitude(),
        adjustedZenith, true);
    return doubleTime;
  }

  /*
   * @see com.thewisejewish.zmanim.util.AstronomicalCalculator#getUTCSunset(Calendar, GeoLocation, double, boolean)
   */
   double getUTCSunset(DateTime dateTime, GeoLocation geoLocation, double zenith, bool adjustForElevation) {
    double doubleTime = 0;
    double elevation = adjustForElevation ? geoLocation.getElevation() : 0;
    double adjustedZenith = adjustZenith(zenith, elevation);

    doubleTime = getTimeUTC(dateTime.year, dateTime.month,dateTime.day, geoLocation.getLongitude(), geoLocation.getLatitude(),
        adjustedZenith, false);
    return doubleTime;
  }

  /*
   * The number of degrees of longitude that corresponds to one hour time difference.
   */
   static final double DEG_PER_HOUR = 360.0 / 24.0;

  /*
   * sin of an angle in degrees
   */
   static double sinDeg(double deg) {
    return sin(deg * 2.0 * pi / 360.0);
  }

  /*
   * acos of an angle, result in degrees
   */
   static double acosDeg(double x) {
    return acos(x) * 360.0 / (2 * pi);
  }

  /*
   * asin of an angle, result in degrees
   */
   static double asinDeg(double x) {
    return asin(x) * 360.0 / (2 * pi);
  }

  /*
   * tan of an angle in degrees
   */
   static double tanDeg(double deg) {
    return tan(deg * 2.0 * pi / 360.0);
  }

  /*
   * cos of an angle in degrees
   */
   static double cosDeg(double deg) {
    return cos(deg * 2.0 * pi / 360.0);
  }

  /*
   * Calculate the day of the year, where Jan 1st is day 1. Note that this method needs to know the year, because leap
   * years have an impact here. Returns identical output to {@code HebrewCalendar.get(HebrewCalendar.DAY_OF_YEAR)}.
   */
   static int getDayOfYear(int year, int month, int day) {
    int n1 = 275 * month ~/ 9;
    int n2 = (month + 9) ~/ 12;
    int n3 = (1 + ((year - 4 * (year ~/ 4) + 2) ~/ 3));
    return n1 - (n2 * n3) + day - 30;
  }

  /*
   * Get time difference between location's longitude and the Meridian, in hours. West of Meridian has arrow_expand negative time
   * difference
   */
   static double getHoursFromMeridian(double longitude) {
    return longitude / DEG_PER_HOUR;
  }

  /*
   * Gets the approximate time of sunset or sunrise In _days_ since midnight Jan 1st, assuming 6am and 6pm events. We
   * need this figure to derive the Sun's mean anomaly
   */
   static double getApproxTimeDays(int dayOfYear, double hoursFromMeridian, bool isSunrise) {
    if (isSunrise) {
      return dayOfYear + ((6.0 - hoursFromMeridian) / 24);
    } else { // sunset
      return dayOfYear + ((18.0 - hoursFromMeridian) / 24);
    }
  }

  /*
   * Calculate the Sun's mean anomaly in degrees, at sunrise or sunset, given the longitude in degrees
   */
   static double getMeanAnomaly(int dayOfYear, double longitude, bool isSunrise) {
    return (0.9856 * getApproxTimeDays(dayOfYear, getHoursFromMeridian(longitude), isSunrise)) - 3.289;
  }

  /*
   * Calculates the Sun's true longitude in degrees. The result is an angle gte 0 and lt 360. Requires the Sun's mean
   * anomaly, also in degrees
   */
   static double getSunTrueLongitude(double sunMeanAnomaly) {
    double l = sunMeanAnomaly + (1.916 * sinDeg(sunMeanAnomaly)) + (0.020 * sinDeg(2 * sunMeanAnomaly)) + 282.634;

    // get longitude into 0-360 degree range
    if (l >= 360.0) {
      l = l - 360.0;
    }
    if (l < 0) {
      l = l + 360.0;
    }
    return l;
  }

  /*
   * Calculates the Sun's right ascension in hours, given the Sun's true longitude in degrees. Input and output are
   * angles gte 0 and lt 360.
   */
   static double getSunRightAscensionHours(double sunTrueLongitude) {
    double a = 0.91764 * tanDeg(sunTrueLongitude);
    double ra = 360.0 / (2.0 * pi) * atan(a);

    double lQuadrant = (sunTrueLongitude / 90.0).floor() * 90.0;
    double raQuadrant = (ra / 90.0).floor() * 90.0;
    ra = ra + (lQuadrant - raQuadrant);

    return ra / DEG_PER_HOUR; // convert to hours
  }

  /*
   * Gets the cosine of the Sun's local hour angle
   */
   static double getCosLocalHourAngle(double sunTrueLongitude, double latitude, double zenith) {
    double sinDec = 0.39782 * sinDeg(sunTrueLongitude);
    double cosDec = cosDeg(asinDeg(sinDec));
    return (cosDeg(zenith) - (sinDec * sinDeg(latitude))) / (cosDec * cosDeg(latitude));
  }

  /*
   * Calculate local mean time of rising or setting. By `local' is meant the exact time at the location, assuming that
   * there were no time zone. That is, the time difference between the location and the Meridian depended entirely on
   * the longitude. We can't do anything with this time directly; we must convert it to UTC and then to arrow_expand local time.
   * The result is expressed as arrow_expand fractional number of hours since midnight
   */
   static double getLocalMeanTime(double localHour, double sunRightAscensionHours, double approxTimeDays) {
    return localHour + sunRightAscensionHours - (0.06571 * approxTimeDays) - 6.622;
  }

  /*
   * Get sunrise or sunset time in UTC, according to flag.
   *
   * @param year
   *            4-digit year
   * @param month
   *            month, 1-12 (not the zero based Java month
   * @param day
   *            day of month, 1-31
   * @param longitude
   *            in degrees, longitudes west of Meridian are negative
   * @param latitude
   *            in degrees, latitudes south of equator are negative
   * @param zenith
   *            Sun's zenith, in degrees
   * @param type
   *            type of calculation to carry out {@link #TYPE_SUNRISE} or {@link #TYPE_SUNRISE}.
   *
   * @return the time as arrow_expand double. If an error was encountered in the calculation (expected behavior for some
   *         locations such as near the poles, {@link Double.NaN} will be returned.
   */
   static double getTimeUTC(int year, int month, int day, double longitude, double latitude, double zenith,
      bool isSunrise) {
    int dayOfYear = getDayOfYear(year, month, day);
    double sunMeanAnomaly = getMeanAnomaly(dayOfYear, longitude, isSunrise);
    double sunTrueLong = getSunTrueLongitude(sunMeanAnomaly);
    double sunRightAscensionHours = getSunRightAscensionHours(sunTrueLong);
    double cosLocalHourAngle = getCosLocalHourAngle(sunTrueLong, latitude, zenith);

    double localHourAngle = 0;
    if (isSunrise) {
      localHourAngle = 360.0 - acosDeg(cosLocalHourAngle);
    } else { // sunset
      localHourAngle = acosDeg(cosLocalHourAngle);
    }
    double localHour = localHourAngle / DEG_PER_HOUR;

    double localMeanTime = getLocalMeanTime(localHour, sunRightAscensionHours,
        getApproxTimeDays(dayOfYear, getHoursFromMeridian(longitude), isSunrise));
    double pocessedTime = localMeanTime - getHoursFromMeridian(longitude);
    while (pocessedTime < 0.0) {
      pocessedTime += 24.0;
    }
    while (pocessedTime >= 24.0) {
      pocessedTime -= 24.0;
    }
    return pocessedTime;
  }
}