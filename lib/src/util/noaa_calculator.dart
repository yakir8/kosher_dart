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
import 'package:vector_math/vector_math.dart';
import 'package:kosher_dart/src/util/astronomical_calculator.dart';
import 'package:kosher_dart/src/util/geo_location.dart';

/// Implementation of sunrise and sunset methods to calculate astronomical times based on the [NOAA](http://noaa.gov) algorithm. This calculator uses the Java algorithm based on the implementation by [NOAA - National Oceanic and Atmospheric Administration](http://noaa.gov)'s [Surface Radiation Research Branch](http://www.srrb.noaa.gov/highlights/sunrise/sunrise.html). NOAA's [implementation](http://www.srrb.noaa.gov/highlights/sunrise/solareqns.PDF) is based on equations from [Astronomical Algorithms](http://www.willbell.com/math/mc1.htm) by [Jean Meeus](http://en.wikipedia.org/wiki/Jean_Meeus). Added to the algorithm is an adjustment of the zenith
/// to account for elevation. The algorithm can be found in the [Wikipedia Sunrise Equation](http://en.wikipedia.org/wiki/Sunrise_equation) article.
///
/// © Eliyahu Hershfeld 2011 - 2018
class NOAACalculator extends AstronomicalCalculator {
  /// The [Julian day](http://en.wikipedia.org/wiki/Julian_day) of January 1, 2000
  static const double _JULIAN_DAY_JAN_1_2000 = 2451545.0;

  /// Julian days per century
  static const double _JULIAN_DAYS_PER_CENTURY = 36525.0;

  /// See also [AstronomicalCalculator.getCalculatorName].
  @override
  String getCalculatorName() {
    return "US National Oceanic and Atmospheric Administration Algorithm";
  }

  /// See also [AstronomicalCalculator.getUTCSunrise].
  @override
  double getUTCSunrise(DateTime dateTime, GeoLocation geoLocation,
      double zenith, bool adjustForElevation) {
    double elevation =
        adjustForElevation ? (geoLocation.getElevation() ?? 0) : 0;
    double adjustedZenith = adjustZenith(zenith, elevation);

    double sunrise = _getSunriseUTC(_getJulianDay(dateTime),
        geoLocation.getLatitude(), -geoLocation.getLongitude(), adjustedZenith);
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

  /// See also [AstronomicalCalculator.getUTCSunset].
  @override
  double getUTCSunset(DateTime dateTime, GeoLocation geoLocation, double zenith,
      bool adjustForElevation) {
    double elevation =
        adjustForElevation ? (geoLocation.getElevation() ?? 0) : 0;
    double adjustedZenith = adjustZenith(zenith, elevation);

    double sunset = _getSunsetUTC(_getJulianDay(dateTime),
        geoLocation.getLatitude(), -geoLocation.getLongitude(), adjustedZenith);
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

  /// Return the [Julian day](http://en.wikipedia.org/wiki/Julian_day) from a Java Calendar
  ///
  /// - [calendar]: 
  ///   The Java Calendar
  /// Returns the Julian day corresponding to the date Note: Number is returned for start of day. Fractional days
  /// should be added later.
  static double _getJulianDay(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    int a = year ~/ 100;
    int b = 2 - a + a ~/ 4;

    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }

  /// Convert [Julian day](http://en.wikipedia.org/wiki/Julian_day) to centuries since J2000.0.
  ///
  /// - [julianDay]: 
  ///   the Julian Day to convert
  /// Returns the centuries since 2000 Julian corresponding to the Julian Day
  static double _getJulianCenturiesFromJulianDay(double julianDay) {
    return (julianDay - _JULIAN_DAY_JAN_1_2000) / _JULIAN_DAYS_PER_CENTURY;
  }

  /// Convert centuries since J2000.0 to [Julian day](http://en.wikipedia.org/wiki/Julian_day).
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns the Julian Day corresponding to the Julian centuries passed in
  static double _getJulianDayFromJulianCenturies(double julianCenturies) {
    return julianCenturies * _JULIAN_DAYS_PER_CENTURY + _JULIAN_DAY_JAN_1_2000;
  }

  /// Returns the Geometric [Mean Longitude](http://en.wikipedia.org/wiki/Mean_longitude) of the Sun.
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns the Geometric Mean Longitude of the Sun in degrees
  static double _getSunGeometricMeanLongitude(double julianCenturies) {
    double longitude = 280.46646 +
        julianCenturies * (36000.76983 + 0.0003032 * julianCenturies);
    while (longitude > 360.0) {
      longitude -= 360.0;
    }
    while (longitude < 0.0) {
      longitude += 360.0;
    }

    return longitude; // in degrees
  }

  /// Returns the Geometric [Mean Anomaly](http://en.wikipedia.org/wiki/Mean_anomaly) of the Sun.
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns the Geometric Mean Anomaly of the Sun in degrees
  static double _getSunGeometricMeanAnomaly(double julianCenturies) {
    return 357.52911 +
        julianCenturies *
            (35999.05029 - 0.0001537 * julianCenturies); // in degrees
  }

  /// Return the [eccentricity of earth's orbit](http://en.wikipedia.org/wiki/Eccentricity_%28orbit%29).
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns the unitless eccentricity
  static double _getEarthOrbitEccentricity(double julianCenturies) {
    return 0.016708634 -
        julianCenturies *
            (0.000042037 + 0.0000001267 * julianCenturies); // unitless
  }

  /// Returns the [equation of center](http://en.wikipedia.org/wiki/Equation_of_the_center) for the sun.
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns the equation of center for the sun in degrees
  static double _getSunEquationOfCenter(double julianCenturies) {
    double m = _getSunGeometricMeanAnomaly(julianCenturies);

    double mrad = radians(m);
    double sinm = sin(mrad);
    double sin2m = sin(mrad + mrad);
    double sin3m = sin(mrad + mrad + mrad);

    return sinm *
            (1.914602 -
                julianCenturies * (0.004817 + 0.000014 * julianCenturies)) +
        sin2m * (0.019993 - 0.000101 * julianCenturies) +
        sin3m * 0.000289; // in degrees
  }

  /// Return the true longitude of the sun
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns the sun's true longitude in degrees
  static double _getSunTrueLongitude(double julianCenturies) {
    double sunLongitude = _getSunGeometricMeanLongitude(julianCenturies);
    double center = _getSunEquationOfCenter(julianCenturies);

    return sunLongitude + center; // in degrees
  }

  //   ///   // * Returns the <a href="http://en.wikipedia.org/wiki/True_anomaly">true anamoly</a> of the sun.
  ///   // *
  ///   // * @param julianCenturies
  ///   // * the number of Julian centuries since J2000.0
  ///   // * @return the sun's true anamoly in degrees
  ///   //
  // private static double getSunTrueAnomaly(double julianCenturies) {
  // double meanAnomaly = getSunGeometricMeanAnomaly(julianCenturies);
  // double equationOfCenter = getSunEquationOfCenter(julianCenturies);
  //
  // return meanAnomaly + equationOfCenter; // in degrees
  // }

  /// Return the apparent longitude of the sun
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns sun's apparent longitude in degrees
  static double _getSunApparentLongitude(double julianCenturies) {
    double sunTrueLongitude = _getSunTrueLongitude(julianCenturies);

    double omega = 125.04 - 1934.136 * julianCenturies;
    double lambda = sunTrueLongitude - 0.00569 - 0.00478 * sin(radians(omega));
    return lambda; // in degrees
  }

  /// Returns the mean [obliquity of the ecliptic](http://en.wikipedia.org/wiki/Axial_tilt) (Axial tilt).
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns the mean obliquity in degrees
  static double _getMeanObliquityOfEcliptic(double julianCenturies) {
    double seconds = 21.448 -
        julianCenturies *
            (46.8150 +
                julianCenturies * (0.00059 - julianCenturies * (0.001813)));
    return 23.0 + (26.0 + (seconds / 60.0)) / 60.0; // in degrees
  }

  /// Returns the corrected [obliquity of the ecliptic](http://en.wikipedia.org/wiki/Axial_tilt) (Axial
  /// tilt).
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns the corrected obliquity in degrees
  static double _getObliquityCorrection(double julianCenturies) {
    double obliquityOfEcliptic = _getMeanObliquityOfEcliptic(julianCenturies);

    double omega = 125.04 - 1934.136 * julianCenturies;
    return obliquityOfEcliptic + 0.00256 * cos(radians(omega)); // in degrees
  }

  /// Return the [declination](http://en.wikipedia.org/wiki/Declination) of the sun.
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// @return
  ///            the sun's declination in degrees
  static double _getSunDeclination(double julianCenturies) {
    double obliquityCorrection = _getObliquityCorrection(julianCenturies);
    double lambda = _getSunApparentLongitude(julianCenturies);

    double sint = sin(radians(obliquityCorrection)) * sin(radians(lambda));
    double theta = degrees(asin(sint));
    return theta; // in degrees
  }

  /// Return the [Equation of Time](http://en.wikipedia.org/wiki/Equation_of_time) - the difference between
  /// true solar time and mean solar time
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// Returns equation of time in minutes of time
  static double _getEquationOfTime(double julianCenturies) {
    double epsilon = _getObliquityCorrection(julianCenturies);
    double geomMeanLongSun = _getSunGeometricMeanLongitude(julianCenturies);
    double eccentricityEarthOrbit = _getEarthOrbitEccentricity(julianCenturies);
    double geomMeanAnomalySun = _getSunGeometricMeanAnomaly(julianCenturies);

    double y = tan(radians(epsilon) / 2.0);
    y *= y;

    double sin2l0 = sin(2.0 * radians(geomMeanLongSun));
    double sinm = sin(radians(geomMeanAnomalySun));
    double cos2l0 = cos(2.0 * radians(geomMeanLongSun));
    double sin4l0 = sin(4.0 * radians(geomMeanLongSun));
    double sin2m = sin(2.0 * radians(geomMeanAnomalySun));

    double equationOfTime = y * sin2l0 -
        2.0 * eccentricityEarthOrbit * sinm +
        4.0 * eccentricityEarthOrbit * y * sinm * cos2l0 -
        0.5 * y * y * sin4l0 -
        1.25 * eccentricityEarthOrbit * eccentricityEarthOrbit * sin2m;
    return degrees(equationOfTime) * 4.0; // in minutes of time
  }

  /// Return the [hour angle](http://en.wikipedia.org/wiki/Hour_angle) of the sun at sunrise for the
  /// latitude.
  ///
  /// - [lat]: 
  ///   , the latitude of observer in degrees
  /// - [solarDec]: 
  ///   the declination angle of sun in degrees
  /// - [zenith]: 
  ///   the zenith
  /// Returns hour angle of sunrise in radians
  static double _getSunHourAngleAtSunrise(
      double lat, double solarDec, double zenith) {
    double latRad = radians(lat);
    double sdRad = radians(solarDec);
    double x = (cos(radians(zenith)) / (cos(latRad) * cos(sdRad)) -
        tan(latRad) * tan(sdRad));
    x = max(min(1, x), -1);
    return acos(x); // in radians
  }

  /// Returns the [hour angle](http://en.wikipedia.org/wiki/Hour_angle) of the sun at sunset for the
  /// latitude. TODO: use - [getSunHourAngleAtSunrise] implementation to avoid
  /// duplication of code.
  ///
  /// - [lat]: 
  ///   the latitude of observer in degrees
  /// - [solarDec]: 
  ///   the declination angle of sun in degrees
  /// - [zenith]: 
  ///   the zenith
  /// Returns the hour angle of sunset in radians
  static double _getSunHourAngleAtSunset(
      double lat, double solarDec, double zenith) {
    double latRad = radians(lat);
    double sdRad = radians(solarDec);

    double hourAngle = (acos(cos(radians(zenith)) / (cos(latRad) * cos(sdRad)) -
        tan(latRad) * tan(sdRad)));
    return -hourAngle; // in radians
  }

  /// Return the [Solar Elevation](http://en.wikipedia.org/wiki/Celestial_coordinate_system) for the
  /// horizontal coordinate system at the given location at the given time. Can be negative if the sun is below the
  /// horizon. Not corrected for altitude.
  ///
  /// - [cal]: 
  ///   time of calculation
  /// - [lat]: 
  ///   latitude of location for calculation
  /// - [lon]: 
  ///   longitude of location for calculation
  /// Returns solar elevation in degrees - horizon is 0 degrees, civil twilight is -6 degrees

  static double getSolarElevation(DateTime dateTime, double lat, double lon) {
    double julianDay = _getJulianDay(dateTime);
    double julianCenturies = _getJulianCenturiesFromJulianDay(julianDay);

    double eot = _getEquationOfTime(julianCenturies);

    double longitude = (dateTime.hour + 12.0) +
        (dateTime.minute + eot + dateTime.second / 60.0) / 60.0;

    longitude = -(longitude * 360.0 / 24.0) % 360.0;
    double hourAngleRad = radians(lon - longitude);
    double declination = _getSunDeclination(julianCenturies);
    double decRad = radians(declination);
    double latRad = radians(lat);
    return degrees(asin((sin(latRad) * sin(decRad)) +
        (cos(latRad) * cos(decRad) * cos(hourAngleRad))));
  }

  /// Return the [Solar Azimuth](http://en.wikipedia.org/wiki/Celestial_coordinate_system) for the
  /// horizontal coordinate system at the given location at the given time. Not corrected for altitude. True south is 0
  /// degrees.
  ///
  /// - [cal]: 
  ///   time of calculation
  /// - [lat]: 
  ///   latitude of location for calculation
  /// - [lon]: 
  ///   longitude of location for calculation
  /// Returns FIXME

  static double getSolarAzimuth(DateTime dateTime, double lat, double lon) {
    double julianDay = _getJulianDay(dateTime);
    double julianCenturies = _getJulianCenturiesFromJulianDay(julianDay);

    double eot = _getEquationOfTime(julianCenturies);

    double longitude = (dateTime.hour + 12.0) +
        (dateTime.minute + eot + dateTime.second / 60.0) / 60.0;

    longitude = -(longitude * 360.0 / 24.0) % 360.0;
    double hourAngleRad = radians(lon - longitude);
    double declination = _getSunDeclination(julianCenturies);
    double decRad = radians(declination);
    double latRad = radians(lat);

    return degrees(atan(sin(hourAngleRad) /
            ((cos(hourAngleRad) * sin(latRad)) -
                (tan(decRad) * cos(latRad))))) +
        180;
  }

  /// Return the [Universal Coordinated Time](http://en.wikipedia.org/wiki/Universal_Coordinated_Time) (UTC)
  /// of sunrise for the given day at the given location on earth
  ///
  /// - [julianDay]: 
  ///   the Julian day
  /// - [latitude]: 
  ///   the latitude of observer in degrees
  /// - [longitude]: 
  ///   the longitude of observer in degrees
  /// - [zenith]: 
  ///   the zenith
  /// Returns the time in minutes from zero UTC
  static double _getSunriseUTC(
      double julianDay, double latitude, double longitude, double zenith) {
    double julianCenturies = _getJulianCenturiesFromJulianDay(julianDay);

    // Find the time of solar noon at the location, and use that declination. This is better than start of the
    // Julian day

    double noonmin = _getSolarNoonUTC(julianCenturies, longitude);
    double tnoon =
        _getJulianCenturiesFromJulianDay(julianDay + noonmin / 1440.0);

    // First pass to approximate sunrise (using solar noon)

    double eqTime = _getEquationOfTime(tnoon);
    double solarDec = _getSunDeclination(tnoon);
    double hourAngle = _getSunHourAngleAtSunrise(latitude, solarDec, zenith);

    double delta = longitude - degrees(hourAngle);
    double timeDiff = 4 * delta; // in minutes of time
    double timeUTC = 720 + timeDiff - eqTime; // in minutes

    // Second pass includes fractional Julian Day in gamma calc

    double newt = _getJulianCenturiesFromJulianDay(
        _getJulianDayFromJulianCenturies(julianCenturies) + timeUTC / 1440.0);
    eqTime = _getEquationOfTime(newt);
    solarDec = _getSunDeclination(newt);
    hourAngle = _getSunHourAngleAtSunrise(latitude, solarDec, zenith);
    delta = longitude - degrees(hourAngle);
    timeDiff = 4 * delta;
    timeUTC = 720 + timeDiff - eqTime; // in minutes
    return timeUTC;
  }

  /// Return the [Universal Coordinated Time](http://en.wikipedia.org/wiki/Universal_Coordinated_Time) (UTC)
  /// of [solar noon](http://en.wikipedia.org/wiki/Noon#Solar_noon) for the given day at the given location
  /// on earth.
  ///
  /// - [julianCenturies]: 
  ///   the number of Julian centuries since J2000.0
  /// - [longitude]: 
  ///   the longitude of observer in degrees
  /// Returns the time in minutes from zero UTC
  static double _getSolarNoonUTC(double julianCenturies, double longitude) {
    // First pass uses approximate solar noon to calculate eqtime
    double tnoon = _getJulianCenturiesFromJulianDay(
        _getJulianDayFromJulianCenturies(julianCenturies) + longitude / 360.0);
    double eqTime = _getEquationOfTime(tnoon);
    double solNoonUTC = 720 + (longitude * 4) - eqTime; // min

    double newt = _getJulianCenturiesFromJulianDay(
        _getJulianDayFromJulianCenturies(julianCenturies) -
            0.5 +
            solNoonUTC / 1440.0);

    eqTime = _getEquationOfTime(newt);
    return 720 + (longitude * 4) - eqTime; // min
  }

  /// Return the [Universal Coordinated Time](http://en.wikipedia.org/wiki/Universal_Coordinated_Time) (UTC)
  /// of sunset for the given day at the given location on earth
  ///
  /// - [julianDay]: 
  ///   the Julian day
  /// - [latitude]: 
  ///   the latitude of observer in degrees
  /// - [longitude]: 
  ///   longitude of observer in degrees
  /// - [zenith]: 
  ///   zenith
  /// Returns the time in minutes from zero Universal Coordinated Time (UTC)
  static double _getSunsetUTC(
      double julianDay, double latitude, double longitude, double zenith) {
    double julianCenturies = _getJulianCenturiesFromJulianDay(julianDay);

    // Find the time of solar noon at the location, and use that declination. This is better than start of the
    // Julian day

    double noonmin = _getSolarNoonUTC(julianCenturies, longitude);
    double tnoon =
        _getJulianCenturiesFromJulianDay(julianDay + noonmin / 1440.0);

    // First calculates sunrise and approx length of day

    double eqTime = _getEquationOfTime(tnoon);
    double solarDec = _getSunDeclination(tnoon);
    double hourAngle = _getSunHourAngleAtSunset(latitude, solarDec, zenith);

    double delta = longitude - degrees(hourAngle);
    double timeDiff = 4 * delta;
    double timeUTC = 720 + timeDiff - eqTime;

    // Second pass includes fractional Julian Day in gamma calc

    double newt = _getJulianCenturiesFromJulianDay(
        _getJulianDayFromJulianCenturies(julianCenturies) + timeUTC / 1440.0);
    eqTime = _getEquationOfTime(newt);
    solarDec = _getSunDeclination(newt);
    hourAngle = _getSunHourAngleAtSunset(latitude, solarDec, zenith);

    delta = longitude - degrees(hourAngle);
    timeDiff = 4 * delta;
    timeUTC = 720 + timeDiff - eqTime; // in minutes
    return timeUTC;
  }
}
