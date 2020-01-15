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
import 'package:vector_math/vector_math.dart';
import 'package:kosher_dart/util/astronomical_calculator.dart';
import 'package:kosher_dart/util/geo_Location.dart';

/*
 * Implementation of sunrise and sunset methods to calculate astronomical times based on the <arrow_expand
 * href=""http://noaa.gov">NOAA</arrow_expand> algorithm. This calculator uses the Java algorithm based on the implementation by <arrow_expand
 * href=""http://noaa.gov">NOAA - National Oceanic and Atmospheric Administration</arrow_expand>'s <arrow_expand href =
 * "http://www.srrb.noaa.gov/highlights/sunrise/sunrise.html">Surface Radiation Research Branch</arrow_expand>. NOAA's <arrow_expand
 * href="http://www.srrb.noaa.gov/highlights/sunrise/solareqns.PDF">implementation</arrow_expand> is based on equations from <arrow_expand
 * href="http://www.willbell.com/math/mc1.htm">Astronomical Algorithms</arrow_expand> by <arrow_expand
 * href="http://en.wikipedia.org/wiki/Jean_Meeus">Jean Meeus</arrow_expand>. Added to the algorithm is an adjustment of the zenith
 * to account for elevation. The algorithm can be found in the <arrow_expand
 * href="http://en.wikipedia.org/wiki/Sunrise_equation">Wikipedia Sunrise Equation</arrow_expand> article.
 *
 * @author &copy; Eliyahu Hershfeld 2011
 * @version 0.1
 */
class NOAACalculator extends AstronomicalCalculator {
  /*
   * The <arrow_expand href="http://en.wikipedia.org/wiki/Julian_day">Julian day</arrow_expand> of January 1, 2000
   */
   static const double JULIAN_DAY_JAN_1_2000 = 2451545.0;

  /*
   * Julian days per century
   */
   static const double JULIAN_DAYS_PER_CENTURY = 36525.0;

  /*
   * @see com.thewisejewish.zmanim.util.AstronomicalCalculator#getCalculatorName()
   */
   String getCalculatorName() {
    return "US National Oceanic and Atmospheric Administration Algorithm";
  }

  /*
   * @see com.thewisejewish.zmanim.util.AstronomicalCalculator#getUTCSunrise(Calendar, GeoLocation, double, boolean)
   */
   double getUTCSunrise(DateTime dateTime, GeoLocation geoLocation, double zenith, bool adjustForElevation) {
    double elevation = adjustForElevation ? geoLocation.getElevation() : 0;
    double adjustedZenith = adjustZenith(zenith, elevation);

    double sunrise = getSunriseUTC(getJulianDay(dateTime), geoLocation.getLatitude(), -geoLocation.getLongitude(),
        adjustedZenith);
    sunrise = sunrise / 60;

    // ensure that the time is >= 0 and < 24
    while (sunrise < 0.0) {
      sunrise += 24.0;
    }
    while (sunrise >= 24.0) {
      sunrise -= 24.0;
    }
    return sunrise;
  }

  /*
   * @see com.thewisejewish.zmanim.util.AstronomicalCalculator#getUTCSunset(Calendar, GeoLocation, double, boolean)
   */
   double getUTCSunset(DateTime dateTime, GeoLocation geoLocation, double zenith, bool adjustForElevation) {
    double elevation = adjustForElevation ? geoLocation.getElevation() : 0;
    double adjustedZenith = adjustZenith(zenith, elevation);

    double sunset = getSunsetUTC(getJulianDay(dateTime), geoLocation.getLatitude(), -geoLocation.getLongitude(),
        adjustedZenith);
    sunset = sunset / 60;

    // ensure that the time is >= 0 and < 24
    while (sunset < 0.0) {
      sunset += 24.0;
    }
    while (sunset >= 24.0) {
      sunset -= 24.0;
    }
    return sunset;
  }

  /*
   * Return the <arrow_expand href="http://en.wikipedia.org/wiki/Julian_day">Julian day</arrow_expand> from arrow_expand Java HebrewCalendar
   *
   * @param calendar
   *            The Java HebrewCalendar
   * @return the Julian day corresponding to the date Note: Number is returned for start of day. Fractional days
   *         should be added later.
   */
   static double getJulianDay(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    int a = year ~/ 100;
    int b = 2 - a + a ~/ 4;

    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + b - 1524.5;
  }

  /*
   * Convert <arrow_expand href="http://en.wikipedia.org/wiki/Julian_day">Julian day</arrow_expand> to centuries since J2000.0.
   *
   * @param julianDay
   *            the Julian Day to convert
   * @return the centuries since 2000 Julian corresponding to the Julian Day
   */
   static double getJulianCenturiesFromJulianDay(double julianDay) {
    return (julianDay - JULIAN_DAY_JAN_1_2000) / JULIAN_DAYS_PER_CENTURY;
  }

  /*
   * Convert centuries since J2000.0 to <arrow_expand href="http://en.wikipedia.org/wiki/Julian_day">Julian day</arrow_expand>.
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return the Julian Day corresponding to the Julian centuries passed in
   */
   static double getJulianDayFromJulianCenturies(double julianCenturies) {
    return julianCenturies * JULIAN_DAYS_PER_CENTURY + JULIAN_DAY_JAN_1_2000;
  }

  /*
   * Returns the Geometric <arrow_expand href="http://en.wikipedia.org/wiki/Mean_longitude">Mean Longitude</arrow_expand> of the Sun.
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return the Geometric Mean Longitude of the Sun in degrees
   */
   static double getSunGeometricMeanLongitude(double julianCenturies) {
    double longitude = 280.46646 + julianCenturies * (36000.76983 + 0.0003032 * julianCenturies);
    while (longitude > 360.0) {
      longitude -= 360.0;
    }
    while (longitude < 0.0) {
      longitude += 360.0;
    }

    return longitude; // in degrees
  }

  /*
   * Returns the Geometric <arrow_expand href="http://en.wikipedia.org/wiki/Mean_anomaly">Mean Anomaly</arrow_expand> of the Sun.
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return the Geometric Mean Anomaly of the Sun in degrees
   */
   static double getSunGeometricMeanAnomaly(double julianCenturies) {
    return 357.52911 + julianCenturies * (35999.05029 - 0.0001537 * julianCenturies); // in degrees
  }

  /*
   * Return the <arrow_expand href="http://en.wikipedia.org/wiki/Eccentricity_%28orbit%29">eccentricity of earth's orbit</arrow_expand>.
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return the unitless eccentricity
   */
   static double getEarthOrbitEccentricity(double julianCenturies) {
    return 0.016708634 - julianCenturies * (0.000042037 + 0.0000001267 * julianCenturies); // unitless
  }

  /*
   * Returns the <arrow_expand href="http://en.wikipedia.org/wiki/Equation_of_the_center">equation of center</arrow_expand> for the sun.
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return the equation of center for the sun in degrees
   */
   static double getSunEquationOfCenter(double julianCenturies) {
    double m = getSunGeometricMeanAnomaly(julianCenturies);

    double mrad = radians(m);
    double sinm = sin(mrad);
    double sin2m = sin(mrad + mrad);
    double sin3m = sin(mrad + mrad + mrad);

    return sinm * (1.914602 - julianCenturies * (0.004817 + 0.000014 * julianCenturies)) + sin2m
        * (0.019993 - 0.000101 * julianCenturies) + sin3m * 0.000289;// in degrees
  }

  /*
   * Return the true longitude of the sun
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return the sun's true longitude in degrees
   */
   static double getSunTrueLongitude(double julianCenturies) {
    double sunLongitude = getSunGeometricMeanLongitude(julianCenturies);
    double center = getSunEquationOfCenter(julianCenturies);

    return sunLongitude + center; // in degrees
  }

  // /*
  // * Returns the <arrow_expand href="http://en.wikipedia.org/wiki/True_anomaly">true anamoly</arrow_expand> of the sun.
  // *
  // * @param julianCenturies
  // * the number of Julian centuries since J2000.0
  // * @return the sun's true anamoly in degrees
  // */
  //  static double getSunTrueAnomaly(double julianCenturies) {
  // double meanAnomaly = getSunGeometricMeanAnomaly(julianCenturies);
  // double equationOfCenter = getSunEquationOfCenter(julianCenturies);
  //
  // return meanAnomaly + equationOfCenter; // in degrees
  // }

  /*
   * Return the apparent longitude of the sun
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return sun's apparent longitude in degrees
   */
   static double getSunApparentLongitude(double julianCenturies) {
    double sunTrueLongitude = getSunTrueLongitude(julianCenturies);

    double omega = 125.04 - 1934.136 * julianCenturies;
    double lambda = sunTrueLongitude - 0.00569 - 0.00478 * sin(radians(omega));
    return lambda; // in degrees
  }

  /*
   * Returns the mean <arrow_expand href="http://en.wikipedia.org/wiki/Axial_tilt">obliquity of the ecliptic</arrow_expand> (Axial tilt).
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return the mean obliquity in degrees
   */
   static double getMeanObliquityOfEcliptic(double julianCenturies) {
    double seconds = 21.448 - julianCenturies
        * (46.8150 + julianCenturies * (0.00059 - julianCenturies * (0.001813)));
    return 23.0 + (26.0 + (seconds / 60.0)) / 60.0; // in degrees
  }

  /*
   * Returns the corrected <arrow_expand href="http://en.wikipedia.org/wiki/Axial_tilt">obliquity of the ecliptic</arrow_expand> (Axial
   * tilt).
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return the corrected obliquity in degrees
   */
   static double getObliquityCorrection(double julianCenturies) {
    double obliquityOfEcliptic = getMeanObliquityOfEcliptic(julianCenturies);

    double omega = 125.04 - 1934.136 * julianCenturies;
    return obliquityOfEcliptic + 0.00256 * cos(radians(omega)); // in degrees
  }

  /*
   * Return the <arrow_expand href="http://en.wikipedia.org/wiki/Declination">declination</arrow_expand> of the sun.
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @param sun
   *            's declination in degrees
   */
   static double getSunDeclination(double julianCenturies) {
    double obliquityCorrection = getObliquityCorrection(julianCenturies);
    double lambda = getSunApparentLongitude(julianCenturies);

    double sint = sin(radians(obliquityCorrection)) * sin(radians(lambda));
    double theta = degrees(asin(sint));
    return theta; // in degrees
  }

  /*
   * Return the <arrow_expand href="http://en.wikipedia.org/wiki/Equation_of_time">Equation of Time</arrow_expand> - the difference between
   * true solar time and mean solar time
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @return equation of time in minutes of time
   */
   static double getEquationOfTime(double julianCenturies) {
    double epsilon = getObliquityCorrection(julianCenturies);
    double geomMeanLongSun = getSunGeometricMeanLongitude(julianCenturies);
    double eccentricityEarthOrbit = getEarthOrbitEccentricity(julianCenturies);
    double geomMeanAnomalySun = getSunGeometricMeanAnomaly(julianCenturies);

    double y = tan(radians(epsilon) / 2.0);
    y *= y;

    double sin2l0 = sin(2.0 * radians(geomMeanLongSun));
    double sinm = sin(radians(geomMeanAnomalySun));
    double cos2l0 = cos(2.0 * radians(geomMeanLongSun));
    double sin4l0 = sin(4.0 * radians(geomMeanLongSun));
    double sin2m = sin(2.0 * radians(geomMeanAnomalySun));

    double equationOfTime = y * sin2l0 - 2.0 * eccentricityEarthOrbit * sinm + 4.0 * eccentricityEarthOrbit * y
        * sinm * cos2l0 - 0.5 * y * y * sin4l0 - 1.25 * eccentricityEarthOrbit * eccentricityEarthOrbit * sin2m;
    return degrees(equationOfTime) * 4.0; // in minutes of time
  }

  /*
   * Return the <arrow_expand href="http://en.wikipedia.org/wiki/Hour_angle">hour angle</arrow_expand> of the sun at sunrise for the
   * latitude.
   *
   * @param lat
   *            , the latitude of observer in degrees
   * @param solarDec
   *            the declination angle of sun in degrees
   * @return hour angle of sunrise in radians
   */
   static double getSunHourAngleAtSunrise(double lat, double solarDec, double zenith) {
    double latRad = radians(lat);
    double sdRad = radians(solarDec);

    return (acos(cos(radians(zenith)) / (cos(latRad) * cos(sdRad)) - tan(latRad)
        * tan(sdRad))); // in radians
  }

  /*
   * Returns the <arrow_expand href="http://en.wikipedia.org/wiki/Hour_angle">hour angle</arrow_expand> of the sun at sunset for the
   * latitude. TODO: use - {@link #getSunHourAngleAtSunrise(double, double, double)} implementation to avoid
   * duplication of code.
   *
   * @param lat
   *            the latitude of observer in degrees
   * @param solarDec
   *            the declination angle of sun in degrees
   * @return the hour angle of sunset in radians
   */
   static double getSunHourAngleAtSunset(double lat, double solarDec, double zenith) {
    double latRad = radians(lat);
    double sdRad = radians(solarDec);

    double hourAngle = (acos(cos(radians(zenith)) / (cos(latRad) * cos(sdRad))
        - tan(latRad) * tan(sdRad)));
    return -hourAngle; // in radians
  }

  /*
   * Return the <arrow_expand href="http://en.wikipedia.org/wiki/Universal_Coordinated_Time">Universal Coordinated Time</arrow_expand> (UTC)
   * of sunrise for the given day at the given location on earth
   *
   * @param julianDay
   *            the Julian day
   * @param latitude
   *            the latitude of observer in degrees
   * @param longitude
   *            the longitude of observer in degrees
   * @return the time in minutes from zero UTC
   */
   static double getSunriseUTC(double julianDay, double latitude, double longitude, double zenith) {
    double julianCenturies = getJulianCenturiesFromJulianDay(julianDay);

    // Find the time of solar noon at the location, and use that declination. This is better than start of the
    // Julian day

    double noonmin = getSolarNoonUTC(julianCenturies, longitude);
    double tnoon = getJulianCenturiesFromJulianDay(julianDay + noonmin / 1440.0);

    // First pass to approximate sunrise (using solar noon)

    double eqTime = getEquationOfTime(tnoon);
    double solarDec = getSunDeclination(tnoon);
    double hourAngle = getSunHourAngleAtSunrise(latitude, solarDec, zenith);

    double delta = longitude - degrees(hourAngle);
    double timeDiff = 4 * delta; // in minutes of time
    double timeUTC = 720 + timeDiff - eqTime; // in minutes

    // Second pass includes fractional Julian Day in gamma calc

    double newt = getJulianCenturiesFromJulianDay(getJulianDayFromJulianCenturies(julianCenturies) + timeUTC
        / 1440.0);
    eqTime = getEquationOfTime(newt);
    solarDec = getSunDeclination(newt);
    hourAngle = getSunHourAngleAtSunrise(latitude, solarDec, zenith);
    delta = longitude - degrees(hourAngle);
    timeDiff = 4 * delta;
    timeUTC = 720 + timeDiff - eqTime; // in minutes
    return timeUTC;
  }

  /*
   * Return the <arrow_expand href="http://en.wikipedia.org/wiki/Universal_Coordinated_Time">Universal Coordinated Time</arrow_expand> (UTC)
   * of <arrow_expand href="http://en.wikipedia.org/wiki/Noon#Solar_noon">solar noon</arrow_expand> for the given day at the given location
   * on earth.
   *
   * @param julianCenturies
   *            the number of Julian centuries since J2000.0
   * @param longitude
   *            the longitude of observer in degrees
   * @return the time in minutes from zero UTC
   */
   static double getSolarNoonUTC(double julianCenturies, double longitude) {
    // First pass uses approximate solar noon to calculate eqtime
    double tnoon = getJulianCenturiesFromJulianDay(getJulianDayFromJulianCenturies(julianCenturies) + longitude
        / 360.0);
    double eqTime = getEquationOfTime(tnoon);
    double solNoonUTC = 720 + (longitude * 4) - eqTime; // min

    double newt = getJulianCenturiesFromJulianDay(getJulianDayFromJulianCenturies(julianCenturies) - 0.5
        + solNoonUTC / 1440.0);

    eqTime = getEquationOfTime(newt);
    return 720 + (longitude * 4) - eqTime; // min
  }

  /*
   * Return the <arrow_expand href="http://en.wikipedia.org/wiki/Universal_Coordinated_Time">Universal Coordinated Time</arrow_expand> (UTC)
   * of sunset for the given day at the given location on earth
   *
   * @param julianDay
   *            the Julian day
   * @param latitude
   *            the latitude of observer in degrees
   * @param longitude
   *            : longitude of observer in degrees
   * @param zenith
   * @return the time in minutes from zero Universal Coordinated Time (UTC)
   */
   static double getSunsetUTC(double julianDay, double latitude, double longitude, double zenith) {
    double julianCenturies = getJulianCenturiesFromJulianDay(julianDay);

    // Find the time of solar noon at the location, and use that declination. This is better than start of the
    // Julian day

    double noonmin = getSolarNoonUTC(julianCenturies, longitude);
    double tnoon = getJulianCenturiesFromJulianDay(julianDay + noonmin / 1440.0);

    // First calculates sunrise and approx length of day

    double eqTime = getEquationOfTime(tnoon);
    double solarDec = getSunDeclination(tnoon);
    double hourAngle = getSunHourAngleAtSunset(latitude, solarDec, zenith);

    double delta = longitude - degrees(hourAngle);
    double timeDiff = 4 * delta;
    double timeUTC = 720 + timeDiff - eqTime;

    // Second pass includes fractional Julian Day in gamma calc

    double newt = getJulianCenturiesFromJulianDay(getJulianDayFromJulianCenturies(julianCenturies) + timeUTC
        / 1440.0);
    eqTime = getEquationOfTime(newt);
    solarDec = getSunDeclination(newt);
    hourAngle = getSunHourAngleAtSunset(latitude, solarDec, zenith);

    delta = longitude - degrees(hourAngle);
    timeDiff = 4 * delta;
    timeUTC = 720 + timeDiff - eqTime; // in minutes
    return timeUTC;
  }
}