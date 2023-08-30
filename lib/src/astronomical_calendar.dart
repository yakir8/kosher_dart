/*
 * Zmanim Java API
 * Copyright (C) 2004-2020 Eliyahu Hershfeld
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 */

import 'dart:core';

import 'package:kosher_dart/src/util/astronomical_calculator.dart';
import 'package:kosher_dart/src/util/geo_location.dart';

/// A Java calendar that calculates astronomical times such as {@link #getSunrise() sunrise}, {@link #getSunset()
/// sunset} and twilight times. This class contains a {@link #getCalendar() Calendar} and can therefore use the standard
/// Calendar functionality to change dates etc... The calculation engine used to calculate the astronomical times can be
/// changed to a different implementation by implementing the abstract {@link AstronomicalCalculator} and setting it with
/// the {@link #setAstronomicalCalculator(AstronomicalCalculator)}. A number of different calculation engine
/// implementations are included in the util package.
/// <b>Note:</b> There are times when the algorithms can't calculate proper values for sunrise, sunset and twilight. This
/// is usually caused by trying to calculate times for areas either very far North or South, where sunrise / sunset never
/// happen on that date. This is common when calculating twilight with a deep dip below the horizon for locations as far
/// south of the North Pole as London, in the northern hemisphere. The sun never reaches this dip at certain times of the
/// year. When the calculations encounter this condition a null will be returned when a
/// <code>{@link java.util.Date}</code> is expected and {@link Long#MIN_VALUE} when a <code>long</code> is expected. The
/// reason that <code>Exception</code>s are not thrown in these cases is because the lack of a rise/set or twilight is
/// not an exception, but an expected condition in many parts of the world.
///
/// Here is a simple example of how to use the API to calculate sunrise.
/// First create the Calendar for the location you would like to calculate sunrise or sunset times for:
///
/// <pre>
/// String locationName = &quot;Lakewood, NJ&quot;;
/// double latitude = 40.0828; // Lakewood, NJ
/// double longitude = -74.2094; // Lakewood, NJ
/// double elevation = 20; // optional elevation correction in Meters
/// // the String parameter in getTimeZone() has to be a valid timezone listed in
/// // {@link java.util.TimeZone#getAvailableIDs()}
/// TimeZone timeZone = TimeZone.getTimeZone(&quot;America/New_York&quot;);
/// GeoLocation location = new GeoLocation(locationName, latitude, longitude, elevation, timeZone);
/// AstronomicalCalendar ac = new AstronomicalCalendar(location);
/// </pre>
///
/// To get the time of sunrise, first set the date you want (if not set, the date will default to today):
///
/// <pre>
/// ac.getCalendar().set(Calendar.MONTH, Calendar.FEBRUARY);
/// ac.getCalendar().set(Calendar.DAY_OF_MONTH, 8);
/// Date sunrise = ac.getSunrise();
/// </pre>
///
///
/// @author &copy; Eliyahu Hershfeld 2004 - 2020
class AstronomicalCalendar {
  /// 90&deg; below the vertical. Used as a basis for most calculations since the location of the sun is 90&deg; below
  /// the horizon at sunrise and sunset.
  /// <b>Note </b>: it is important to note that for sunrise and sunset the {@link AstronomicalCalculator#adjustZenith
  /// adjusted zenith} is required to account for the radius of the sun and refraction. The adjusted zenith should not
  /// be used for calculations above or below 90&deg; since they are usually calculated as an offset to 90&deg;.
  static const double GEOMETRIC_ZENITH = 90;

  /**
   * Default value for Sun's zenith and true rise/set Zenith (used in this class and subclasses) is the angle that the
   * center of the Sun makes to a line perpendicular to the Earth's surface. If the Sun were a point and the Earth
   * were without an atmosphere, true sunset and sunrise would correspond to a 90&deg; zenith. Because the Sun is not
   * a point, and because the atmosphere refracts light, this 90&deg; zenith does not, in fact, correspond to true
   * sunset or sunrise, instead the center of the Sun's disk must lie just below the horizon for the upper edge to be
   * obscured. This means that a zenith of just above 90&deg; must be used. The Sun subtends an angle of 16 minutes of
   * arc (this can be changed via the {@link #setSunRadius(double)} method , and atmospheric refraction accounts for
   * 34 minutes or so (this can be changed via the {@link #setRefraction(double)} method), giving a total of 50
   * arcminutes. The total value for ZENITH is 90+(5/6) or 90.8333333&deg; for true sunrise/sunset.
   */
  // public static double ZENITH = GEOMETRIC_ZENITH + 5.0 / 6.0;
  /// Sun's zenith at civil twilight (96&deg;). */
  static const double CIVIL_ZENITH = 96;

  /// Sun's zenith at nautical twilight (102&deg;). */
  static const double NAUTICAL_ZENITH = 102;

  /// Sun's zenith at astronomical twilight (108&deg;). */
  static const double ASTRONOMICAL_ZENITH = 108;

  /// constant for milliseconds in a minute (60,000) */
  static const double MINUTE_MILLIS = 60.0 * 1000.0;

  /// constant for milliseconds in an hour (3,600,000) */
  static const double HOUR_MILLIS = MINUTE_MILLIS * 60;

  /// The Java Calendar encapsulated by this class to track the current date used by the class
  late DateTime _calendar;

  late GeoLocation geoLocation;

  late AstronomicalCalculator astronomicalCalculator;

  /// The getSunrise method Returns a <code>Date</code> representing the
  /// {@link AstronomicalCalculator#getElevationAdjustment(double) elevation adjusted} sunrise time. The zenith used
  /// for the calculation uses {@link #GEOMETRIC_ZENITH geometric zenith} of 90&deg; plus
  /// {@link AstronomicalCalculator#getElevationAdjustment(double)}. This is adjusted by the
  /// {@link AstronomicalCalculator} to add approximately 50/60 of a degree to account for 34 archminutes of refraction
  /// and 16 archminutes for the sun's radius for a total of {@link AstronomicalCalculator#adjustZenith 90.83333&deg;}.
  /// See documentation for the specific implementation of the {@link AstronomicalCalculator} that you are using.
  ///
  /// @return the <code>Date</code> representing the exact sunrise time. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the page.
  /// @see AstronomicalCalculator#adjustZenith
  /// @see #getSeaLevelSunrise()
  /// @see AstronomicalCalendar#getUTCSunrise
  DateTime? getSunrise() {
    double sunrise = getUTCSunrise(GEOMETRIC_ZENITH);
    if (sunrise.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunrise, true);
    }
  }

  /// A method that returns the sunrise without {@link AstronomicalCalculator#getElevationAdjustment(double) elevation
  /// adjustment}. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible light,
  /// something that is not affected by elevation. This method returns sunrise calculated at sea level. This forms the
  /// base for dawn calculations that are calculated as a dip below the horizon before sunrise.
  ///
  /// @return the <code>Date</code> representing the exact sea-level sunrise time. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a null will be returned. See detailed explanation on top of the page.
  /// @see AstronomicalCalendar#getSunrise
  /// @see AstronomicalCalendar#getUTCSeaLevelSunrise
  /// @see #getSeaLevelSunset()
  DateTime? getSeaLevelSunrise() {
    double sunrise = getUTCSeaLevelSunrise(GEOMETRIC_ZENITH);
    if (sunrise.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunrise, true);
    }
  }

  /// A method that returns the beginning of civil twilight (dawn) using a zenith of {@link #CIVIL_ZENITH 96&deg;}.
  ///
  /// @return The <code>Date</code> of the beginning of civil twilight using a zenith of 96&deg;. If the calculation
  ///         can't be computed, null will be returned. See detailed explanation on top of the page.
  /// @see #CIVIL_ZENITH
  DateTime? getBeginCivilTwilight() {
    return getSunriseOffsetByDegrees(CIVIL_ZENITH);
  }

  /// A method that returns the beginning of nautical twilight using a zenith of {@link #NAUTICAL_ZENITH 102&deg;}.
  ///
  /// @return The <code>Date</code> of the beginning of nautical twilight using a zenith of 102&deg;. If the
  ///         calculation can't be computed null will be returned. See detailed explanation on top of the page.
  /// @see #NAUTICAL_ZENITH
  DateTime? getBeginNauticalTwilight() {
    return getSunriseOffsetByDegrees(NAUTICAL_ZENITH);
  }

  /// A method that returns the beginning of astronomical twilight using a zenith of {@link #ASTRONOMICAL_ZENITH
  /// 108&deg;}.
  ///
  /// @return The <code>Date</code> of the beginning of astronomical twilight using a zenith of 108&deg;. If the
  ///         calculation can't be computed, null will be returned. See detailed explanation on top of the page.
  /// @see #ASTRONOMICAL_ZENITH
  DateTime? getBeginAstronomicalTwilight() {
    return getSunriseOffsetByDegrees(ASTRONOMICAL_ZENITH);
  }

  /// The getSunset method Returns a <code>Date</code> representing the
  /// {@link AstronomicalCalculator#getElevationAdjustment(double) elevation adjusted} sunset time. The zenith used for
  /// the calculation uses {@link #GEOMETRIC_ZENITH geometric zenith} of 90&deg; plus
  /// {@link AstronomicalCalculator#getElevationAdjustment(double)}. This is adjusted by the
  /// {@link AstronomicalCalculator} to add approximately 50/60 of a degree to account for 34 archminutes of refraction
  /// and 16 archminutes for the sun's radius for a total of {@link AstronomicalCalculator#adjustZenith 90.83333&deg;}.
  /// See documentation for the specific implementation of the {@link AstronomicalCalculator} that you are using. Note:
  /// In certain cases the calculates sunset will occur before sunrise. This will typically happen when a timezone
  /// other than the local timezone is used (calculating Los Angeles sunset using a GMT timezone for example). In this
  /// case the sunset date will be incremented to the following date.
  ///
  /// @return the <code>Date</code> representing the exact sunset time. If the calculation can't be computed such as in
  ///         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the page.
  /// @see AstronomicalCalculator#adjustZenith
  /// @see #getSeaLevelSunset()
  /// @see AstronomicalCalendar#getUTCSunset
  DateTime? getSunset() {
    double sunset = getUTCSunset(GEOMETRIC_ZENITH);
    if (sunset.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunset, false);
    }
  }

  /// A method that returns the sunset without {@link AstronomicalCalculator#getElevationAdjustment(double) elevation
  /// adjustment}. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible light,
  /// something that is not affected by elevation. This method returns sunset calculated at sea level. This forms the
  /// base for dusk calculations that are calculated as a dip below the horizon after sunset.
  ///
  /// @return the <code>Date</code> representing the exact sea-level sunset time. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a null will be returned. See detailed explanation on top of the page.
  /// @see AstronomicalCalendar#getSunset
  /// @see AstronomicalCalendar#getUTCSeaLevelSunset 2see {@link #getSunset()}
  DateTime? getSeaLevelSunset() {
    double sunset = getUTCSeaLevelSunset(GEOMETRIC_ZENITH);
    if (sunset.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunset, false);
    }
  }

  /// A method that returns the end of civil twilight using a zenith of {@link #CIVIL_ZENITH 96&deg;}.
  ///
  /// @return The <code>Date</code> of the end of civil twilight using a zenith of {@link #CIVIL_ZENITH 96&deg;}. If
  ///         the calculation can't be computed, null will be returned. See detailed explanation on top of the page.
  /// @see #CIVIL_ZENITH
  DateTime? getEndCivilTwilight() {
    return getSunsetOffsetByDegrees(CIVIL_ZENITH);
  }

  /// A method that returns the end of nautical twilight using a zenith of {@link #NAUTICAL_ZENITH 102&deg;}.
  ///
  /// @return The <code>Date</code> of the end of nautical twilight using a zenith of {@link #NAUTICAL_ZENITH 102&deg;}
  ///         . If the calculation can't be computed, null will be returned. See detailed explanation on top of the
  ///         page.
  /// @see #NAUTICAL_ZENITH
  DateTime? getEndNauticalTwilight() {
    return getSunsetOffsetByDegrees(NAUTICAL_ZENITH);
  }

  /// A method that returns the end of astronomical twilight using a zenith of {@link #ASTRONOMICAL_ZENITH 108&deg;}.
  ///
  /// @return the <code>Date</code> of the end of astronomical twilight using a zenith of {@link #ASTRONOMICAL_ZENITH
  ///         108&deg;}. If the calculation can't be computed, null will be returned. See detailed explanation on top
  ///         of the page.
  /// @see #ASTRONOMICAL_ZENITH
  DateTime? getEndAstronomicalTwilight() {
    return getSunsetOffsetByDegrees(ASTRONOMICAL_ZENITH);
  }

  /// A utility method that returns a date offset by the offset time passed in. Please note that the level of light
  /// during twilight is not affected by elevation, so if this is being used to calculate an offset before sunrise or
  /// after sunset with the intent of getting a rough "level of light" calculation, the sunrise or sunset time passed
  /// to this method should be sea level sunrise and sunset.
  ///
  /// @param time
  ///            the start time
  /// @param offset
  ///            the offset in milliseconds to add to the time.
  /// @return the {@link java.util.Date} with the offset in milliseconds added to it
  static DateTime? getTimeOffset(DateTime? time, double offset) {
    if (time == null || offset == double.minPositive) {
      return null;
    }
    return DateTime.parse(
        time.add(Duration(milliseconds: offset.toInt())).toIso8601String());
  }

  /// A utility method that returns the time of an offset by degrees below or above the horizon of
  /// {@link #getSunrise() sunrise}. Note that the degree offset is from the vertical, so for a calculation of 14&deg;
  /// before sunrise, an offset of 14 + {@link #GEOMETRIC_ZENITH} = 104 would have to be passed as a parameter.
  ///
  /// @param offsetZenith
  ///            the degrees before {@link #getSunrise()} to use in the calculation. For time after sunrise use
  ///            negative numbers. Note that the degree offset is from the vertical, so for a calculation of 14&deg;
  ///            before sunrise, an offset of 14 + {@link #GEOMETRIC_ZENITH} = 104 would have to be passed as a
  ///            parameter.
  /// @return The {@link java.util.Date} of the offset after (or before) {@link #getSunrise()}. If the calculation
  ///         can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does
  ///         not rise, and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         page.
  DateTime? getSunriseOffsetByDegrees(double offsetZenith) {
    double dawn = getUTCSunrise(offsetZenith);
    if (dawn.isNaN) {
      return null;
    } else {
      return getDateFromTime(dawn, true);
    }
  }

  /// A utility method that returns the time of an offset by degrees below or above the horizon of {@link #getSunset()
  /// sunset}. Note that the degree offset is from the vertical, so for a calculation of 14&deg; after sunset, an
  /// offset of 14 + {@link #GEOMETRIC_ZENITH} = 104 would have to be passed as a parameter.
  ///
  /// @param offsetZenith
  ///            the degrees after {@link #getSunset()} to use in the calculation. For time before sunset use negative
  ///            numbers. Note that the degree offset is from the vertical, so for a calculation of 14&deg; after
  ///            sunset, an offset of 14 + {@link #GEOMETRIC_ZENITH} = 104 would have to be passed as a parameter.
  /// @return The {@link java.util.Date}of the offset after (or before) {@link #getSunset()}. If the calculation can't
  ///         be computed such as in the Arctic Circle where there is at least one day a year where the sun does not
  ///         rise, and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         page.
  DateTime? getSunsetOffsetByDegrees(double offsetZenith) {
    double sunset = getUTCSunset(offsetZenith);
    if (sunset.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunset, false);
    }
  }

  /// A constructor that takes in <a href="http://en.wikipedia.org/wiki/Geolocation">geolocation</a> information as a
  /// parameter. The default {@link AstronomicalCalculator#getDefault() AstronomicalCalculator} used for solar
  /// calculations is the the {@link net.sourceforge.zmanim.util.NOAACalculator}.
  ///
  /// @param geoLocation
  ///            The location information used for calculating astronomical sun times.
  ///
  /// @see #setAstronomicalCalculator(AstronomicalCalculator) for changing the calculator class.
  AstronomicalCalendar({GeoLocation? geoLocation}) {
    geoLocation ??= GeoLocation();
    setCalendar(geoLocation.getDateTime());
    setGeoLocation(geoLocation); // duplicate call
    setAstronomicalCalculator(AstronomicalCalculator.getDefault());
  }

  /// A method that returns the sunrise in UTC time without correction for time zone offset from GMT and without using
  /// daylight savings time.
  ///
  /// @param zenith
  ///            the degrees below the horizon. For time after sunrise use negative numbers.
  /// @return The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, {@link Double#NaN} will be returned. See detailed explanation on top of the page.
  double getUTCSunrise(double zenith) {
    return getAstronomicalCalculator()
        .getUTCSunrise(getAdjustedCalendar(), getGeoLocation(), zenith, true);
  }

  /// A method that returns the sunrise in UTC time without correction for time zone offset from GMT and without using
  /// daylight savings time. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible
  /// light, something that is not affected by elevation. This method returns UTC sunrise calculated at sea level. This
  /// forms the base for dawn calculations that are calculated as a dip below the horizon before sunrise.
  ///
  /// @param zenith
  ///            the degrees below the horizon. For time after sunrise use negative numbers.
  /// @return The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, {@link Double#NaN} will be returned. See detailed explanation on top of the page.
  /// @see AstronomicalCalendar#getUTCSunrise
  /// @see AstronomicalCalendar#getUTCSeaLevelSunset
  double getUTCSeaLevelSunrise(double zenith) {
    return getAstronomicalCalculator()
        .getUTCSunrise(getAdjustedCalendar(), getGeoLocation(), zenith, false);
  }

  /// A method that returns the sunset in UTC time without correction for time zone offset from GMT and without using
  /// daylight savings time.
  ///
  /// @param zenith
  ///            the degrees below the horizon. For time after sunset use negative numbers.
  /// @return The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, {@link Double#NaN} will be returned. See detailed explanation on top of the page.
  /// @see AstronomicalCalendar#getUTCSeaLevelSunset
  double getUTCSunset(double zenith) {
    return getAstronomicalCalculator()
        .getUTCSunset(getAdjustedCalendar(), getGeoLocation(), zenith, true);
  }

  /// A method that returns the sunset in UTC time without correction for elevation, time zone offset from GMT and
  /// without using daylight savings time. Non-sunrise and sunset calculations such as dawn and dusk, depend on the
  /// amount of visible light, something that is not affected by elevation. This method returns UTC sunset calculated
  /// at sea level. This forms the base for dusk calculations that are calculated as a dip below the horizon after
  /// sunset.
  ///
  /// @param zenith
  ///            the degrees below the horizon. For time before sunset use negative numbers.
  /// @return The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, {@link Double#NaN} will be returned. See detailed explanation on top of the page.
  /// @see AstronomicalCalendar#getUTCSunset
  /// @see AstronomicalCalendar#getUTCSeaLevelSunrise
  double getUTCSeaLevelSunset(double zenith) {
    return getAstronomicalCalculator()
        .getUTCSunset(getAdjustedCalendar(), getGeoLocation(), zenith, false);
  }

  /// A utility method that will allow the calculation of a temporal (solar) hour based on the sunrise and sunset
  /// passed as parameters to this method. An example of the use of this method would be the calculation of a
  /// non-elevation adjusted temporal hour by passing in {@link #getSeaLevelSunrise() sea level sunrise} and
  /// {@link #getSeaLevelSunset() sea level sunset} as parameters.
  ///
  /// @param startOfday
  ///            The start of the day.
  /// @param endOfDay
  ///            The end of the day.
  ///
  /// @return the <code>long</code> millisecond length of the temporal hour. If the calculation can't be computed a
  ///         {@link Long#MIN_VALUE} will be returned. See detailed explanation on top of the page.
  ///
  /// @see #getTemporalHour()
  double getTemporalHour([DateTime? startOfDay, DateTime? endOfDay]) {
    if (startOfDay == null || endOfDay == null) {
      startOfDay = getSeaLevelSunrise();
      endOfDay = getSeaLevelSunset();
    }
    return (endOfDay!.millisecondsSinceEpoch -
            startOfDay!.millisecondsSinceEpoch) /
        12;
  }

  /// A method that returns sundial or solarnoon. It occurs when the Sun is <a href
  /// ="http://en.wikipedia.org/wiki/Transit_%28astronomy%29">transiting</a> the <a
  /// href="http://en.wikipedia.org/wiki/Meridian_%28astronomy%29">celestial meridian</a>. In this class it is
  /// calculated as halfway between the sunrise and sunset passed to this method. This time can be slightly off the
  /// real transit time due to changes in declination (the lengthening or shortening day).
  ///
  /// @param startOfDay
  ///            the start of day for calculating the sun's transit. This can be sea level sunrise, visual sunrise (or
  ///            any arbitrary start of day) passed to this method.
  /// @param endOfDay
  ///            the end of day for calculating the sun's transit. This can be sea level sunset, visual sunset (or any
  ///            arbitrary end of day) passed to this method.
  ///
  /// @return the <code>Date</code> representing Sun's transit. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, null will be returned. See detailed explanation on top of the page.
  DateTime? getSunTransit([DateTime? startOfDay, DateTime? endOfDay]) {
    if (startOfDay == null || endOfDay == null) {
      startOfDay = getSeaLevelSunrise();
      endOfDay = getSeaLevelSunset();
    }
    double temporalHour = getTemporalHour(startOfDay, endOfDay);
    return getTimeOffset(startOfDay, temporalHour * 6);
  }

  /// A method that returns a <code>Date</code> from the time passed in as a parameter.
  ///
  /// @param time
  ///            The time to be set as the time for the <code>Date</code>. The time expected is in the format: 18.75
  ///            for 6:45:00 PM.time is sunrise and false if it is sunset
  /// @param isSunrise true if the
  /// @return The Date.
  DateTime? getDateFromTime(double time, bool isSunrise) {
    if (time.isNaN) {
      return null;
    }
    double calculatedTime = time;

    DateTime adjustedCalendar = getAdjustedCalendar();
    DateTime cal = DateTime(
        adjustedCalendar.year, adjustedCalendar.month, adjustedCalendar.day);
    cal = cal.add(cal.timeZoneOffset);
    int hours = calculatedTime.toInt(); // retain only the hours
    calculatedTime -= hours;
    int minutes = (calculatedTime *= 60).toInt(); // retain only the minutes
    calculatedTime -= minutes;
    int seconds = (calculatedTime *= 60).toInt(); // retain only the seconds
    calculatedTime -= seconds; // remaining milliseconds

    // Check if a date transition has occurred, or is about to occur - this indicates the date of the event is
    // actually not the target date, but the day prior or after
    int localTimeHours = getGeoLocation().getLongitude() ~/ 15;
    if (isSunrise && localTimeHours + hours > 18) {
      cal = cal.add(const Duration(days: -1));
    } else if (!isSunrise && localTimeHours + hours < 6) {
      cal = cal.add(const Duration(days: 1));
    }
    return cal.add(Duration(hours: hours, minutes: minutes, seconds: seconds));
  }

  /// Returns the dip below the horizon before sunrise that matches the offset minutes on passed in as a parameter. For
  /// example passing in 72 minutes for a calendar set to the equinox in Jerusalem returns a value close to 16.1&deg;
  /// Please note that this method is very slow and inefficient and should NEVER be used in a loop. TODO: Improve
  /// efficiency.
  ///
  /// @param minutes
  ///            offset
  /// @return the degrees below the horizon before sunrise that match the offset in minutes passed it as a parameter.
  /// @see #getSunsetSolarDipFromOffset(double)
  double getSunriseSolarDipFromOffset(double minutes) {
    DateTime? offsetByDegrees = getSeaLevelSunrise();
    DateTime? offsetByTime =
        getTimeOffset(getSeaLevelSunrise(), -(minutes * MINUTE_MILLIS));

    double degrees = 0;
    double incrementor = 0.0001;
    while (offsetByDegrees == null ||
        ((minutes < 0.0 && offsetByDegrees.isBefore(offsetByTime!)) ||
            (minutes > 0.0 && offsetByDegrees.isAfter(offsetByTime!)))) {
      if (minutes > 0.0) {
        degrees += incrementor;
      } else {
        degrees -= incrementor;
      }
      offsetByDegrees = getSunriseOffsetByDegrees(GEOMETRIC_ZENITH + degrees);
      //System.out.println("offsetByDegrees: " + offsetByDegrees);
    }
    return degrees;
  }

  /// Returns the dip below the horizon after sunset that matches the offset minutes on passed in as a parameter. For
  /// example passing in 72 minutes for a calendar set to the equinox in Jerusalem returns a value close to 16.1&deg;
  /// Please note that this method is very slow and inefficient and should NEVER be used in a loop. TODO: Improve
  /// efficiency.
  ///
  /// @param minutes
  ///            offset
  /// @return the degrees below the horizon after sunset that match the offset in minutes passed it as a parameter.
  /// @see #getSunriseSolarDipFromOffset(double)
  double getSunsetSolarDipFromOffset(double minutes) {
    DateTime? offsetByDegrees = getSeaLevelSunset();
    DateTime? offsetByTime =
        getTimeOffset(getSeaLevelSunset(), minutes * MINUTE_MILLIS);
    double degrees = 0;
    double incrementor = 0.001;
    while (offsetByDegrees == null ||
        ((minutes > 0.0 && offsetByDegrees.isBefore(offsetByTime!)) ||
            (minutes < 0.0 && offsetByDegrees.isAfter(offsetByTime!)))) {
      if (minutes > 0.0) {
        degrees += incrementor;
      } else {
        degrees -= incrementor;
      }
      offsetByDegrees = getSunsetOffsetByDegrees(GEOMETRIC_ZENITH + degrees);
    }
    return degrees;
  }

  /// Adjusts the <code>Calendar</code> to deal with edge cases where the location crosses the antimeridian.
  ///
  /// @see GeoLocation#getAntimeridianAdjustment()
  /// @return the adjusted Calendar
  DateTime getAdjustedCalendar() {
    int offset = getGeoLocation().getAntimeridianAdjustment();
    if (offset == 0) {
      return getCalendar();
    }
    DateTime adjustedCalendar = DateTime.parse(getCalendar().toIso8601String());
    adjustedCalendar.add(Duration(days: offset));
    return adjustedCalendar;
  }

/*

  /// @return an XML formatted representation of the class. It returns the default output of the
  ///         {@link net.sourceforge.zmanim.util.ZmanimFormatter#toXML(AstronomicalCalendar) toXML} method.
  /// @see net.sourceforge.zmanim.util.ZmanimFormatter#toXML(AstronomicalCalendar)
  /// @see java.lang.Object#toString()
  String toString() {
    return ZmanimFormatter.toXML(this);
  }

  /// @return a JSON formatted representation of the class. It returns the default output of the
  ///         {@link net.sourceforge.zmanim.util.ZmanimFormatter#toJSON(AstronomicalCalendar) toJSON} method.
  /// @see net.sourceforge.zmanim.util.ZmanimFormatter#toJSON(AstronomicalCalendar)
  /// @see java.lang.Object#toString()
  String toJSON() {
    return ZmanimFormatter.toJSON(this);
  }
*/
  /// @see java.lang.Object#equals(Object)
  @override
  bool operator ==(Object object) {
    if (identical(this, object)) {
      return true;
    }
    if (object is! AstronomicalCalendar) {
      return false;
    }
    AstronomicalCalendar aCal = object;
    return getCalendar().isAtSameMomentAs(aCal.getCalendar()) &&
        getGeoLocation() == aCal.getGeoLocation() &&
        getAstronomicalCalculator() == aCal.getAstronomicalCalculator();
  }

  @override
  int get hashCode {
    return getCalendar().millisecondsSinceEpoch * geoLocation.hashCode;
  }

  /// A method that returns the currently set {@link GeoLocation} which contains location information used for the
  /// astronomical calculations.
  ///
  /// @return Returns the geoLocation.
  GeoLocation getGeoLocation() {
    return geoLocation;
  }

  /// Sets the {@link GeoLocation} <code>Object</code> to be used for astronomical calculations.
  ///
  /// @param geoLocation
  ///            The geoLocation to set.
  void setGeoLocation(GeoLocation geoLocation) {
    this.geoLocation = geoLocation;
    setCalendar(geoLocation.getDateTime());
  }

  /// A method that returns the currently set AstronomicalCalculator.
  ///
  /// @return Returns the astronomicalCalculator.
  /// @see #setAstronomicalCalculator(AstronomicalCalculator)
  AstronomicalCalculator getAstronomicalCalculator() {
    return astronomicalCalculator;
  }

  /// A method to set the {@link AstronomicalCalculator} used for astronomical calculations. The Zmanim package ships
  /// with a number of different implementations of the <code>abstract</code> {@link AstronomicalCalculator} based on
  /// different algorithms, including {@link net.sourceforge.zmanim.util.SunTimesCalculator one implementation} based
  /// on the <a href = "http://aa.usno.navy.mil/">US Naval Observatory's</a> algorithm, and
  /// {@link net.sourceforge.zmanim.util.NOAACalculator another} based on <a href="http://noaa.gov">NOAA's</a>
  /// algorithm. This allows easy runtime switching and comparison of different algorithms.
  ///
  /// @param astronomicalCalculator
  ///            The astronomicalCalculator to set.
  void setAstronomicalCalculator(
      AstronomicalCalculator astronomicalCalculator) {
    this.astronomicalCalculator = astronomicalCalculator;
  }

  /// returns the Calendar object encapsulated in this class.
  ///
  /// @return Returns the calendar.
  DateTime getCalendar() {
    return _calendar;
  }

  /// @param calendar
  ///            The calendar to set.
  void setCalendar(DateTime calendar) {
    _calendar = calendar;
  }
}
