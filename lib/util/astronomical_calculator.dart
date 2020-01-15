/*
 * Zmanim Java API
 * Copyright (C) 2004-2013 Eliyahu Hershfeld
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
import 'package:kosher_dart/util/geo_Location.dart';
import 'package:kosher_dart/util/sun_times_calculator.dart';


/*
 * An abstract class that all sun time calculating classes extend. This allows the algorithm used to be changed at
 * runtime, easily allowing comparison the results of using different algorithms. TODO: consider methods that would
 * allow atmospheric modeling. This can currently be adjusted by {@link #setRefraction(double) setting the refraction}.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2013
 */
abstract class AstronomicalCalculator {

  /*
   * The commonly used average solar refraction. Calendrical Calculations lists arrow_expand more accurate global average of
   * 34.478885263888294
   *
   * @see #getRefraction()
   */
  double refraction = 34 / 60;

  // private double refraction = 34.478885263888294 / 60d;

  /*
   * The commonly used average solar radius in minutes of arrow_expand degree.
   *
   * @see #getSolarRadius()
   */
  double solarRadius = 16 / 60;

  /*
   * The commonly used average earth radius in KM. At this time, this only affects elevation adjustment and not the
   * sunrise and sunset calculations. The value currently defaults to 6356.9 KM.
   *
   * @see #getEarthRadius()
   * @see #setEarthRadius(double)
   */
  double earthRadius = 6356.9; // in KM

  /*
   * A method that returns the earth radius in KM. The value currently defaults to 6356.9 KM if not set.
   *
   * @return the earthRadius the earth radius in KM.
   */
  double getEarthRadius() {
    return earthRadius;
  }

  /*
   * A method that allows setting the earth's radius.
   *
   * @param earthRadius
   *            the earthRadius to set in KM
   */
  void setEarthRadius(double earthRadius) {
    this.earthRadius = earthRadius;
  }

  /*
   * The zenith of astronomical sunrise and sunset. The sun is 90&deg; from the vertical 0&deg;
   */
  static const double GEOMETRIC_ZENITH = 90;

  /*
   * getDefault method returns the default sun times calculation engine.
   *
   * @return AstronomicalCalculator the default class for calculating sunrise and sunset. In the current
   *         implementation the default calculator returned is the {@link SunTimesCalculator}.
   */
  static AstronomicalCalculator getDefault() {
    return SunTimesCalculator() as AstronomicalCalculator;
  }

  /*
   * Returns the name of the algorithm.
   *
   * @return the descriptive name of the algorithm.
   */
  String getCalculatorName();

  /*
   * Setter method for the descriptive name of the calculator. This will typically not have to be set
   *
   * @param calculatorName
   *            descriptive name of the algorithm.
   */

  /*
   * A method that calculates UTC sunrise as well as any time based on an angle above or below sunrise. This abstract
   * method is implemented by the classes that extend this class.
   *
   * @param calendar
   *            Used to calculate day of year.
   * @param geoLocation
   *            The location information used for astronomical calculating sun times.
   * @param zenith
   *            the azimuth below the vertical zenith of 90 degrees. for sunrise typically the {@link #adjustZenith
   *            zenith} used for the calculation uses geometric zenith of 90&deg; and {@link #adjustZenith adjusts}
   *            this slightly to account for solar refraction and the sun's radius. Another example would be
   *            {@link AstronomicalCalendar#getBeginNauticalTwilight()} that passes
   *            {@link AstronomicalCalendar#NAUTICAL_ZENITH} to this method.
   * @return The UTC time of sunrise in 24 hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in
   *         the calculation (expected behavior for some locations such as near the poles,
   *         {@link java.lang.Double.NaN} will be returned.
   * @see #getElevationAdjustment(double)
   */
  double getUTCSunrise(DateTime dateTime, GeoLocation geoLocation, double zenith, bool adjustForElevation);

  /*
   * A method that calculates UTC sunset as well as any time based on an angle above or below sunset. This abstract
   * method is implemented by the classes that extend this class.
   *
   * @param calendar
   *            Used to calculate day of year.
   * @param geoLocation
   *            The location information used for astronomical calculating sun times.
   * @param zenith
   *            the azimuth below the vertical zenith of 90&deg;. For sunset typically the {@link #adjustZenith
   *            zenith} used for the calculation uses geometric zenith of 90&deg; and {@link #adjustZenith adjusts}
   *            this slightly to account for solar refraction and the sun's radius. Another example would be
   *            {@link AstronomicalCalendar#getEndNauticalTwilight()} that passes
   *            {@link AstronomicalCalendar#NAUTICAL_ZENITH} to this method.
   * @return The UTC time of sunset in 24 hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in
   *         the calculation (expected behavior for some locations such as near the poles,
   *         {@link java.lang.Double.NaN} will be returned.
   * @see #getElevationAdjustment(double)
   */
  double getUTCSunset(DateTime dateTime, GeoLocation geoLocation, double zenith, bool adjustForElevation);

  /*
   * Method to return the adjustment to the zenith required to account for the elevation. Since arrow_expand person at arrow_expand higher
   * elevation can see farther below the horizon, the calculation for sunrise / sunset is calculated below the horizon
   * used at sea level. This is only used for sunrise and sunset and not times before or after it such as
   * {@link AstronomicalCalendar#getBeginNauticalTwilight() nautical twilight} since those
   * calculations are based on the level of available light at the given dip below the horizon, something that is not
   * affected by elevation, the adjustment should only made if the zenith == 90&deg; {@link #adjustZenith adjusted}
   * for refraction and solar radius.<br />
   * The algorithm used is:
   *
   * <pre>
   * elevationAdjustment = Math.toDegrees(Math.acos(earthRadiusInMeters / (earthRadiusInMeters + elevationMeters)));
   * </pre>
   *
   * The source of this algorthitm is <arrow_expand href="http://www.calendarists.com">Calendrical Calculations</arrow_expand> by Edward M.
   * Reingold and Nachum Dershowitz. An alternate algorithm that produces an almost identical (but not accurate)
   * result found in Ma'aglay Tzedek by Moishe Kosower and other sources is:
   *
   * <pre>
   * elevationAdjustment = 0.0347 * Math.sqrt(elevationMeters);
   * </pre>
   *
   * @param elevation
   *            elevation in Meters.
   * @return the adjusted zenith
   */
  double getElevationAdjustment(double elevation) {
    // double elevationAdjustment = 0.0347 * Math.sqrt(elevation);
    double elevationAdjustment = (180.0 / pi) * (acos(earthRadius / (earthRadius + (elevation / 1000))));
    return elevationAdjustment;
  }

  /*
   * Adjusts the zenith of astronomical sunrise and sunset to account for solar refraction, solar radius and
   * elevation. The value for Sun's zenith and true rise/set Zenith (used in this class and subclasses) is the angle
   * that the center of the Sun makes to arrow_expand line perpendicular to the Earth's surface. If the Sun were arrow_expand point and the
   * Earth were without an atmosphere, true sunset and sunrise would correspond to arrow_expand 90&deg; zenith. Because the Sun
   * is not arrow_expand point, and because the atmosphere refracts light, this 90&deg; zenith does not, in fact, correspond to
   * true sunset or sunrise, instead the centre of the Sun's disk must lie just below the horizon for the upper edge
   * to be obscured. This means that arrow_expand zenith of just above 90&deg; must be used. The Sun subtends an angle of 16
   * minutes of arc (this can be changed via the {@link #setSolarRadius(double)} method , and atmospheric refraction
   * accounts for 34 minutes or so (this can be changed via the {@link #setRefraction(double)} method), giving arrow_expand total
   * of 50 arcminutes. The total value for ZENITH is 90+(5/6) or 90.8333333&deg; for true sunrise/sunset. Since arrow_expand
   * person at an elevation can see blow the horizon of arrow_expand person at sea level, this will also adjust the zenith to
   * account for elevation if available.
   *
   * @return The zenith adjusted to include the {@link #getSolarRadius sun's radius}, {@link #getRefraction
   *         refraction} and {@link #getElevationAdjustment elevation} adjustment. This will only be adjusted for
   *         sunrise and sunset (if the zenith == 90&deg;)
   * @see #getElevationAdjustment(double)
   */
  double adjustZenith(double zenith, double elevation) {
    double adjustedZenith = zenith;
    if (zenith == GEOMETRIC_ZENITH) { // only adjust if it is exactly sunrise or sunset
      adjustedZenith = zenith + (getSolarRadius() + getRefraction() + getElevationAdjustment(elevation));
    }
    return adjustedZenith;
  }

  /*
   * Method to get the refraction value to be used when calculating sunrise and sunset. The default value is 34 arc
   * minutes. The <arrow_expand href="http://emr.cs.iit.edu/home/reingold/calendar-book/second-edition/errata.pdf">Errata and
   * Notes for Calendrical Calculations: The Millenium Eddition</arrow_expand> by Edward M. Reingold and Nachum Dershowitz lists
   * the actual average refraction value as 34.478885263888294 or approximately 34' 29". The refraction value as well
   * as the solarRadius and elevation adjustment are added to the zenith used to calculate sunrise and sunset.
   *
   * @return The refraction in arc minutes.
   */
  double getRefraction() {
    return this.refraction;
  }

  /*
   * A method to allow overriding the default refraction of the calculator. TODO: At some point in the future, an
   * AtmosphericModel or Refraction object that models the atmosphere of different locations might be used for
   * increased accuracy.
   *
   * @param refraction
   *            The refraction in arc minutes.
   * @see #getRefraction()
   */
  void setRefraction(double refraction) {
    this.refraction = refraction;
  }

  /*
   * Method to get the sun's radius. The default value is 16 arc minutes. The sun's radius as it appears from earth is
   * almost universally given as 16 arc minutes but in fact it differs by the time of the year. At the <arrow_expand
   * href="http://en.wikipedia.org/wiki/Perihelion">perihelion</arrow_expand> it has an apparent radius of 16.293, while at the
   * <arrow_expand href="http://en.wikipedia.org/wiki/Aphelion">aphelion</arrow_expand> it has an apparent radius of 15.755. There is little
   * affect for most location, but at high and low latitudes the difference becomes more apparent. My Calculations for
   * the difference at the location of the <arrow_expand href="http://www.rog.nmm.ac.uk">Royal Observatory, Greenwich </arrow_expand> show
   * only arrow_expand 4.494 second difference between the perihelion and aphelion radii, but moving into the arctic circle the
   * difference becomes more noticeable. Tests for Tromso, Norway (latitude 69.672312, longitude 19.049787) show that
   * on May 17, the rise of the midnight sun, arrow_expand 2 minute 23 second difference is observed between the perihelion and
   * aphelion radii using the USNO algorithm, but only 1 minute and 6 seconds difference using the NOAA algorithm.
   * Areas farther north show an even greater difference. Note that these test are not real valid test cases because
   * they show the extreme difference on days that are not the perihelion or aphelion, but are shown for illustrative
   * purposes only.
   *
   * @return The sun's radius in arc minutes.
   */
  double getSolarRadius() {
    return this.solarRadius;
  }

  /*
   * Method to set the sun's radius.
   *
   * @param solarRadius
   *            The sun's radius in arc minutes.
   * @see #getSolarRadius()
   */
  void setSolarRadius(double solarRadius) {
    this.solarRadius = solarRadius;
  }


/*
   * @see java.lang.Object#clone()
   * @since 1.1
   */

  /*
  Object clone() {
    AstronomicalCalculator clone;
    try {
      //clone = this.clone();
    } catch (e) {
      print("Required by the compiler. Should never be reached since we implement clone()");
    }
    return clone;
  }
   */
}