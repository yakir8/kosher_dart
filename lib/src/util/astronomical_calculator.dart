/*
 * Zmanim Java API
 * Copyright (C) 2004-2019 Eliyahu Hershfeld
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

import 'dart:core';
import 'dart:math';
import 'package:kosher_dart/src/util/noaa_calculator.dart';
import 'package:vector_math/vector_math.dart';
import 'package:kosher_dart/src/util/geo_location.dart';

/// An abstract class that all sun time calculating classes extend. This allows the algorithm used to be changed at
/// runtime, easily allowing comparison the results of using different algorithms.
/// TODO: Consider methods that would allow atmospheric modeling. This can currently be adjusted by {@link
/// #setRefraction(double) setting the refraction}.
///
/// © Eliyahu Hershfeld 2004 - 2019
abstract class AstronomicalCalculator {
  /// The commonly used average solar refraction. Calendrical Calculations lists a more accurate global average of
  /// 34.478885263888294
  ///
  /// See also [getRefraction].
  double _refraction = 34 / 60;

  // private double refraction = 34.478885263888294 / 60d;

  /// The commonly used average solar radius in minutes of a degree.
  ///
  /// See also [getSolarRadius].
  double _solarRadius = 16 / 60;

  /// The commonly used average earth radius in KM. At this time, this only affects elevation adjustment and not the
  /// sunrise and sunset calculations. The value currently defaults to 6356.9 KM.
  ///
  /// See also [getEarthRadius].
  /// See also [setEarthRadius].
  double _earthRadius = 6356.9; // in KM

  /// A method that returns the earth radius in KM. The value currently defaults to 6356.9 KM if not set.
  ///
  /// Returns the earthRadius the earth radius in KM.
  double getEarthRadius() {
    return _earthRadius;
  }

  /// A method that allows setting the earth's radius.
  ///
  /// - [earthRadius]: 
  ///   the earthRadius to set in KM
  void setEarthRadius(double earthRadius) {
    _earthRadius = earthRadius;
  }

  /// The zenith of astronomical sunrise and sunset. The sun is 90° from the vertical 0°
  static const double GEOMETRIC_ZENITH = 90;

  /// Returns the default class for calculating sunrise and sunset. This is currently the [NOAACalculator],
  /// but this may change.
  ///
  /// Returns AstronomicalCalculator the default class for calculating sunrise and sunset. In the current
  /// implementation the default calculator returned is the [NOAACalculator].
  static AstronomicalCalculator getDefault() {
    return NOAACalculator();
  }

  /// Returns the name of the algorithm.
  ///
  /// Returns the descriptive name of the algorithm.
  String getCalculatorName();

  /// Setter method for the descriptive name of the calculator. This will typically not have to be set
  ///
  /// - [calculatorName]: 
  ///   descriptive name of the algorithm.

  /// A method that calculates UTC sunrise as well as any time based on an angle above or below sunrise. This abstract
  /// method is implemented by the classes that extend this class.
  ///
  /// - [calendar]: 
  ///   Used to calculate day of year.
  /// - [geoLocation]: 
  ///   The location information used for astronomical calculating sun times.
  /// - [zenith]: 
  ///   the azimuth below the vertical zenith of 90 degrees. for sunrise typically the [adjustZenith] used for the calculation uses geometric zenith of 90° and [adjustZenith]
  ///   this slightly to account for solar refraction and the sun's radius. Another example would be
  ///   [AstronomicalCalendar.getBeginNauticalTwilight] that passes
  ///   [AstronomicalCalendar.NAUTICAL_ZENITH] to this method.
  /// - [adjustForElevation]: 
  ///   Should the time be adjusted for elevation
  /// Returns The UTC time of sunrise in 24 hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in
  /// the calculation (expected behavior for some locations such as near the poles,
  /// double.nan will be returned.
  /// See also [getElevationAdjustment].
  double getUTCSunrise(DateTime dateTime, GeoLocation geoLocation,
      double zenith, bool adjustForElevation);

  /// A method that calculates UTC sunset as well as any time based on an angle above or below sunset. This abstract
  /// method is implemented by the classes that extend this class.
  ///
  /// - [calendar]: 
  ///   Used to calculate day of year.
  /// - [geoLocation]: 
  ///   The location information used for astronomical calculating sun times.
  /// - [zenith]: 
  ///   the azimuth below the vertical zenith of 90°. For sunset typically the [adjustZenith] used for the calculation uses geometric zenith of 90° and [adjustZenith]
  ///   this slightly to account for solar refraction and the sun's radius. Another example would be
  ///   [AstronomicalCalendar.getEndNauticalTwilight] that passes
  ///   [AstronomicalCalendar.NAUTICAL_ZENITH] to this method.
  /// - [adjustForElevation]: 
  ///   Should the time be adjusted for elevation
  /// Returns The UTC time of sunset in 24 hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in
  /// the calculation (expected behavior for some locations such as near the poles,
  /// double.nan will be returned.
  /// See also [getElevationAdjustment].
  double getUTCSunset(DateTime dateTime, GeoLocation geoLocation, double zenith,
      bool adjustForElevation);

  /// Method to return the adjustment to the zenith required to account for the elevation. Since a person at a higher
  /// elevation can see farther below the horizon, the calculation for sunrise / sunset is calculated below the horizon
  /// used at sea level. This is only used for sunrise and sunset and not times before or after it such as
  /// [AstronomicalCalendar.getBeginNauticalTwilight] since those
  /// calculations are based on the level of available light at the given dip below the horizon, something that is not
  /// affected by elevation, the adjustment should only made if the zenith == 90° [adjustZenith]
  /// for refraction and solar radius. The algorithm used is
  ///
  ///
  /// ```dart
  ///  elevationAdjustment = Math.toDegrees(Math.acos(earthRadiusInMeters / (earthRadiusInMeters + elevationMeters)));
  /// ```
  ///
  /// The source of this algorithm is [Calendrical Calculations](http://www.calendarists.com) by Edward M.
  /// Reingold and Nachum Dershowitz. An alternate algorithm that produces an almost identical (but not accurate)
  /// result found in Ma'aglay Tzedek by Moishe Kosower and other sources is:
  ///
  ///
  /// ```dart
  ///  elevationAdjustment = 0.0347 * Math.sqrt(elevationMeters);
  /// ```
  ///
  /// - [elevation]: 
  ///   elevation in Meters.
  /// Returns the adjusted zenith
  double getElevationAdjustment(double elevation) {
    // double elevationAdjustment = 0.0347 * Math.sqrt(elevation);
    double elevationAdjustment =
        degrees(acos(_earthRadius / (_earthRadius + (elevation / 1000))));
    return elevationAdjustment;
  }

  /// Adjusts the zenith of astronomical sunrise and sunset to account for solar refraction, solar radius and
  /// elevation. The value for Sun's zenith and true rise/set Zenith (used in this class and subclasses) is the angle
  /// that the center of the Sun makes to a line perpendicular to the Earth's surface. If the Sun were a point and the
  /// Earth were without an atmosphere, true sunset and sunrise would correspond to a 90° zenith. Because the Sun
  /// is not a point, and because the atmosphere refracts light, this 90° zenith does not, in fact, correspond to
  /// true sunset or sunrise, instead the center of the Sun's disk must lie just below the horizon for the upper edge
  /// to be obscured. This means that a zenith of just above 90° must be used. The Sun subtends an angle of 16
  /// minutes of arc (this can be changed via the [setSolarRadius] method , and atmospheric refraction
  /// accounts for 34 minutes or so (this can be changed via the [setRefraction] method), giving a total
  /// of 50 arcminutes. The total value for ZENITH is 90+(5/6) or 90.8333333° for true sunrise/sunset. Since a
  /// person at an elevation can see blow the horizon of a person at sea level, this will also adjust the zenith to
  /// account for elevation if available. Note that this will only adjust the value if the zenith is exactly 90 degrees.
  /// For values below and above this no correction is done. As an example, astronomical twilight is when the sun is
  /// 18° below the horizon or [AstronomicalCalendar.ASTRONOMICAL_ZENITH]. This is traditionally calculated with none of the above mentioned adjustments. The same goes
  /// for various _tzais_ and _alos_ times such as the
  /// [ZmanimCalendar.ZENITH_16_POINT_1] dip used in
  /// [ComplexZmanimCalendar.getAlos16Point1Degrees].
  ///
  /// - [zenith]: 
  ///   the azimuth below the vertical zenith of 90°. For sunset typically the [adjustZenith] used for the calculation uses geometric zenith of 90° and [adjustZenith]
  ///   this slightly to account for solar refraction and the sun's radius. Another example would be
  ///   [AstronomicalCalendar.getEndNauticalTwilight] that passes
  ///   [AstronomicalCalendar.NAUTICAL_ZENITH] to this method.
  /// - [elevation]: 
  ///   elevation in Meters.
  /// Returns The zenith adjusted to include the [getSolarRadius], [getRefraction] and [getElevationAdjustment] adjustment. This will only be adjusted for
  /// sunrise and sunset (if the zenith == 90°)
  /// See also [getElevationAdjustment].
  double adjustZenith(double zenith, double elevation) {
    double adjustedZenith = zenith;
    if (zenith == GEOMETRIC_ZENITH) {
      // only adjust if it is exactly sunrise or sunset
      adjustedZenith = zenith +
          (getSolarRadius() +
              getRefraction() +
              getElevationAdjustment(elevation));
    }
    return adjustedZenith;
  }

  /// Method to get the refraction value to be used when calculating sunrise and sunset. The default value is 34 arc
  /// minutes. The [Errata and Notes for Calendrical Calculations: The Millennium Edition](http://emr.cs.iit.edu/home/reingold/calendar-book/second-edition/errata.pdf) by Edward M. Reingold and Nachum Dershowitz lists
  /// the actual average refraction value as 34.478885263888294 or approximately 34' 29". The refraction value as well
  /// as the solarRadius and elevation adjustment are added to the zenith used to calculate sunrise and sunset.
  ///
  /// Returns The refraction in arc minutes.
  double getRefraction() {
    return _refraction;
  }

  /// A method to allow overriding the default refraction of the calculator.
  /// TODO: At some point in the future, an AtmosphericModel or Refraction object that models the atmosphere of different
  /// locations might be used for increased accuracy.
  ///
  /// - [refraction]: 
  ///   The refraction in arc minutes.
  /// See also [getRefraction].
  void setRefraction(double refraction) {
    _refraction = refraction;
  }

  /// Method to get the sun's radius. The default value is 16 arc minutes. The sun's radius as it appears from earth is
  /// almost universally given as 16 arc minutes but in fact it differs by the time of the year. At the [perihelion](http://en.wikipedia.org/wiki/Perihelion) it has an apparent radius of 16.293, while at the
  /// [aphelion](http://en.wikipedia.org/wiki/Aphelion) it has an apparent radius of 15.755. There is little
  /// affect for most location, but at high and low latitudes the difference becomes more apparent. My Calculations for
  /// the difference at the location of the [Royal Observatory, Greenwich ](http://www.rog.nmm.ac.uk) show
  /// only a 4.494 second difference between the perihelion and aphelion radii, but moving into the arctic circle the
  /// difference becomes more noticeable. Tests for Tromso, Norway (latitude 69.672312, longitude 19.049787) show that
  /// on May 17, the rise of the midnight sun, a 2 minute 23 second difference is observed between the perihelion and
  /// aphelion radii using the USNO algorithm, but only 1 minute and 6 seconds difference using the NOAA algorithm.
  /// Areas farther north show an even greater difference. Note that these test are not real valid test cases because
  /// they show the extreme difference on days that are not the perihelion or aphelion, but are shown for illustrative
  /// purposes only.
  ///
  /// Returns The sun's radius in arc minutes.
  double getSolarRadius() {
    return _solarRadius;
  }

  /// Method to set the sun's radius.
  ///
  /// - [solarRadius]: 
  ///   The sun's radius in arc minutes.
  /// See also [getSolarRadius].
  void setSolarRadius(double solarRadius) {
    _solarRadius = solarRadius;
  }
/*
  /// See also [Object.clone].
  Object clone() {
    AstronomicalCalculator clone = null;
    try {
      clone = (AstronomicalCalculator) super.clone();
    } catch (CloneNotSupportedException cnse) {
    System.out.print("Required by the compiler. Should never be reached since we implement clone()");
    }
    return clone;
  }

 */
}
