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

/// A Java calendar that calculates astronomical times such as [getSunrise], [getSunset] and twilight times. This class contains a [getCalendar] and can therefore use the standard
/// Calendar functionality to change dates etc... The calculation engine used to calculate the astronomical times can be
/// changed to a different implementation by implementing the abstract [AstronomicalCalculator] and setting it with
/// the [setAstronomicalCalculator]. A number of different calculation engine
/// implementations are included in the util package.
/// **Note:** There are times when the algorithms can't calculate proper values for sunrise, sunset and twilight. This
/// is usually caused by trying to calculate times for areas either very far North or South, where sunrise / sunset never
/// happen on that date. This is common when calculating twilight with a deep dip below the horizon for locations as far
/// south of the North Pole as London, in the northern hemisphere. The sun never reaches this dip at certain times of the
/// year. When the calculations encounter this condition a null will be returned when a
/// [DateTime] is expected and double.nan when a `long` is expected. The
/// reason that `Exception`s are not thrown in these cases is because the lack of a rise/set or twilight is
/// not an exception, but an expected condition in many parts of the world.
///
/// Here is a simple example of how to use the API to calculate sunrise.
/// First create the Calendar for the location you would like to calculate sunrise or sunset times for:
///
///
/// ```dart
///  String locationName = "Lakewood, NJ";
///  double latitude = 40.0828; // Lakewood, NJ
///  double longitude = -74.2094; // Lakewood, NJ
///  double elevation = 20; // optional elevation correction in Meters
///  // the String parameter in getTimeZone() has to be a valid timezone listed in
///  // [TimeZone.getAvailableIDs]
///  TimeZone timeZone = TimeZone.getTimeZone("America/New_York");
///  GeoLocation location = new GeoLocation(locationName, latitude, longitude, elevation, timeZone);
///  AstronomicalCalendar ac = new AstronomicalCalendar(location);
/// ```
///
/// To get the time of sunrise, first set the date you want (if not set, the date will default to today):
///
///
/// ```dart
///  ac.getCalendar().set(Calendar.MONTH, Calendar.FEBRUARY);
///  ac.getCalendar().set(Calendar.DAY_OF_MONTH, 8);
///  Date sunrise = ac.getSunrise();
/// ```
///
///
/// © Eliyahu Hershfeld 2004 - 2020
class AstronomicalCalendar {
  /// 90° below the vertical. Used as a basis for most calculations since the location of the sun is 90° below
  /// the horizon at sunrise and sunset.
  /// **Note **: it is important to note that for sunrise and sunset the [AstronomicalCalculator.adjustZenith] is required to account for the radius of the sun and refraction. The adjusted zenith should not
  /// be used for calculations above or below 90° since they are usually calculated as an offset to 90°.
  static const double GEOMETRIC_ZENITH = 90;

  /// Default value for Sun's zenith and true rise/set Zenith (used in this class and subclasses) is the angle that the
  /// center of the Sun makes to a line perpendicular to the Earth's surface. If the Sun were a point and the Earth
  /// were without an atmosphere, true sunset and sunrise would correspond to a 90° zenith. Because the Sun is not
  /// a point, and because the atmosphere refracts light, this 90° zenith does not, in fact, correspond to true
  /// sunset or sunrise, instead the center of the Sun's disk must lie just below the horizon for the upper edge to be
  /// obscured. This means that a zenith of just above 90° must be used. The Sun subtends an angle of 16 minutes of
  /// arc (this can be changed via the [setSunRadius] method , and atmospheric refraction accounts for
  /// 34 minutes or so (this can be changed via the [setRefraction] method), giving a total of 50
  /// arcminutes. The total value for ZENITH is 90+(5/6) or 90.8333333° for true sunrise/sunset.
  // public static double ZENITH = GEOMETRIC_ZENITH + 5.0 / 6.0;
  /// Sun's zenith at civil twilight (96°).
  static const double CIVIL_ZENITH = 96;

  /// Sun's zenith at nautical twilight (102°).
  static const double NAUTICAL_ZENITH = 102;

  /// Sun's zenith at astronomical twilight (108°).
  static const double ASTRONOMICAL_ZENITH = 108;

  /// constant for milliseconds in a minute (60,000)
  static const double MINUTE_MILLIS = 60.0 * 1000.0;

  /// constant for milliseconds in an hour (3,600,000)
  static const double HOUR_MILLIS = MINUTE_MILLIS * 60;

  /// The Java Calendar encapsulated by this class to track the current date used by the class
  late DateTime _calendar;

  late GeoLocation geoLocation;

  late AstronomicalCalculator astronomicalCalculator;

  /// The getSunrise method Returns a `Date` representing the
  /// [AstronomicalCalculator.getElevationAdjustment] sunrise time. The zenith used
  /// for the calculation uses [GEOMETRIC_ZENITH] of 90° plus
  /// [AstronomicalCalculator.getElevationAdjustment]. This is adjusted by the
  /// [AstronomicalCalculator] to add approximately 50/60 of a degree to account for 34 archminutes of refraction
  /// and 16 archminutes for the sun's radius for a total of [AstronomicalCalculator.adjustZenith].
  /// See documentation for the specific implementation of the [AstronomicalCalculator] that you are using.
  ///
  /// Returns the `Date` representing the exact sunrise time. If the calculation can't be computed such as
  /// in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  /// does not set, a null will be returned. See detailed explanation on top of the page.
  /// See also [AstronomicalCalculator.adjustZenith].
  /// See also [getSeaLevelSunrise].
  /// See also [AstronomicalCalendar.getUTCSunrise].
  DateTime? getSunrise() {
    double sunrise = getUTCSunrise(GEOMETRIC_ZENITH);
    if (sunrise.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunrise, true);
    }
  }

  /// A method that returns the sunrise without [AstronomicalCalculator.getElevationAdjustment]. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible light,
  /// something that is not affected by elevation. This method returns sunrise calculated at sea level. This forms the
  /// base for dawn calculations that are calculated as a dip below the horizon before sunrise.
  ///
  /// Returns the `Date` representing the exact sea-level sunrise time. If the calculation can't be computed
  /// such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  /// where it does not set, a null will be returned. See detailed explanation on top of the page.
  /// See also [AstronomicalCalendar.getSunrise].
  /// See also [AstronomicalCalendar.getUTCSeaLevelSunrise].
  /// See also [getSeaLevelSunset].
  DateTime? getSeaLevelSunrise() {
    double sunrise = getUTCSeaLevelSunrise(GEOMETRIC_ZENITH);
    if (sunrise.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunrise, true);
    }
  }

  /// A method that returns the beginning of civil twilight (dawn) using a zenith of [CIVIL_ZENITH].
  ///
  /// Returns The `Date` of the beginning of civil twilight using a zenith of 96°. If the calculation
  /// can't be computed, null will be returned. See detailed explanation on top of the page.
  /// See also [CIVIL_ZENITH].
  DateTime? getBeginCivilTwilight() {
    return getSunriseOffsetByDegrees(CIVIL_ZENITH);
  }

  /// A method that returns the beginning of nautical twilight using a zenith of [NAUTICAL_ZENITH].
  ///
  /// Returns The `Date` of the beginning of nautical twilight using a zenith of 102°. If the
  /// calculation can't be computed null will be returned. See detailed explanation on top of the page.
  /// See also [NAUTICAL_ZENITH].
  DateTime? getBeginNauticalTwilight() {
    return getSunriseOffsetByDegrees(NAUTICAL_ZENITH);
  }

  /// A method that returns the beginning of astronomical twilight using a zenith of [ASTRONOMICAL_ZENITH].
  ///
  /// Returns The `Date` of the beginning of astronomical twilight using a zenith of 108°. If the
  /// calculation can't be computed, null will be returned. See detailed explanation on top of the page.
  /// See also [ASTRONOMICAL_ZENITH].
  DateTime? getBeginAstronomicalTwilight() {
    return getSunriseOffsetByDegrees(ASTRONOMICAL_ZENITH);
  }

  /// The getSunset method Returns a `Date` representing the
  /// [AstronomicalCalculator.getElevationAdjustment] sunset time. The zenith used for
  /// the calculation uses [GEOMETRIC_ZENITH] of 90° plus
  /// [AstronomicalCalculator.getElevationAdjustment]. This is adjusted by the
  /// [AstronomicalCalculator] to add approximately 50/60 of a degree to account for 34 archminutes of refraction
  /// and 16 archminutes for the sun's radius for a total of [AstronomicalCalculator.adjustZenith].
  /// See documentation for the specific implementation of the [AstronomicalCalculator] that you are using. Note:
  /// In certain cases the calculates sunset will occur before sunrise. This will typically happen when a timezone
  /// other than the local timezone is used (calculating Los Angeles sunset using a GMT timezone for example). In this
  /// case the sunset date will be incremented to the following date.
  ///
  /// Returns the `Date` representing the exact sunset time. If the calculation can't be computed such as in
  /// the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  /// does not set, a null will be returned. See detailed explanation on top of the page.
  /// See also [AstronomicalCalculator.adjustZenith].
  /// See also [getSeaLevelSunset].
  /// See also [AstronomicalCalendar.getUTCSunset].
  DateTime? getSunset() {
    double sunset = getUTCSunset(GEOMETRIC_ZENITH);
    if (sunset.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunset, false);
    }
  }

  /// A method that returns the sunset without [AstronomicalCalculator.getElevationAdjustment]. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible light,
  /// something that is not affected by elevation. This method returns sunset calculated at sea level. This forms the
  /// base for dusk calculations that are calculated as a dip below the horizon after sunset.
  ///
  /// Returns the `Date` representing the exact sea-level sunset time. If the calculation can't be computed
  /// such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  /// where it does not set, a null will be returned. See detailed explanation on top of the page.
  /// See also [AstronomicalCalendar.getSunset].
  /// See also [AstronomicalCalendar.getUTCSeaLevelSunset 2see [getSunset]].
  DateTime? getSeaLevelSunset() {
    double sunset = getUTCSeaLevelSunset(GEOMETRIC_ZENITH);
    if (sunset.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunset, false);
    }
  }

  /// A method that returns the end of civil twilight using a zenith of [CIVIL_ZENITH].
  ///
  /// Returns The `Date` of the end of civil twilight using a zenith of [CIVIL_ZENITH]. If
  /// the calculation can't be computed, null will be returned. See detailed explanation on top of the page.
  /// See also [CIVIL_ZENITH].
  DateTime? getEndCivilTwilight() {
    return getSunsetOffsetByDegrees(CIVIL_ZENITH);
  }

  /// A method that returns the end of nautical twilight using a zenith of [NAUTICAL_ZENITH].
  ///
  /// Returns The `Date` of the end of nautical twilight using a zenith of [NAUTICAL_ZENITH]
  /// . If the calculation can't be computed, null will be returned. See detailed explanation on top of the
  /// page.
  /// See also [NAUTICAL_ZENITH].
  DateTime? getEndNauticalTwilight() {
    return getSunsetOffsetByDegrees(NAUTICAL_ZENITH);
  }

  /// A method that returns the end of astronomical twilight using a zenith of [ASTRONOMICAL_ZENITH].
  ///
  /// Returns the `Date` of the end of astronomical twilight using a zenith of [ASTRONOMICAL_ZENITH]. If the calculation can't be computed, null will be returned. See detailed explanation on top
  /// of the page.
  /// See also [ASTRONOMICAL_ZENITH].
  DateTime? getEndAstronomicalTwilight() {
    return getSunsetOffsetByDegrees(ASTRONOMICAL_ZENITH);
  }

  /// A utility method that returns a date offset by the offset time passed in. Please note that the level of light
  /// during twilight is not affected by elevation, so if this is being used to calculate an offset before sunrise or
  /// after sunset with the intent of getting a rough "level of light" calculation, the sunrise or sunset time passed
  /// to this method should be sea level sunrise and sunset.
  ///
  /// - [time]: 
  ///   the start time
  /// - [offset]: 
  ///   the offset in milliseconds to add to the time.
  /// Returns the [DateTime] with the offset in milliseconds added to it
  static DateTime? getTimeOffset(DateTime? time, double offset) {
    if (time == null || offset == double.minPositive) {
      return null;
    }
    return time.add(Duration(milliseconds: offset.toInt()));
  }

  /// A utility method that returns the time of an offset by degrees below or above the horizon of
  /// [getSunrise]. Note that the degree offset is from the vertical, so for a calculation of 14°
  /// before sunrise, an offset of 14 + [GEOMETRIC_ZENITH] = 104 would have to be passed as a parameter.
  ///
  /// - [offsetZenith]: 
  ///   the degrees before [getSunrise] to use in the calculation. For time after sunrise use
  ///   negative numbers. Note that the degree offset is from the vertical, so for a calculation of 14°
  ///   before sunrise, an offset of 14 + [GEOMETRIC_ZENITH] = 104 would have to be passed as a
  ///   parameter.
  /// Returns The [DateTime] of the offset after (or before) [getSunrise]. If the calculation
  /// can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does
  /// not rise, and one where it does not set, a null will be returned. See detailed explanation on top of the
  /// page.
  DateTime? getSunriseOffsetByDegrees(double offsetZenith) {
    double dawn = getUTCSunrise(offsetZenith);
    if (dawn.isNaN) {
      return null;
    } else {
      return getDateFromTime(dawn, true);
    }
  }

  /// A utility method that returns the time of an offset by degrees below or above the horizon of [getSunset]. Note that the degree offset is from the vertical, so for a calculation of 14° after sunset, an
  /// offset of 14 + [GEOMETRIC_ZENITH] = 104 would have to be passed as a parameter.
  ///
  /// - [offsetZenith]: 
  ///   the degrees after [getSunset] to use in the calculation. For time before sunset use negative
  ///   numbers. Note that the degree offset is from the vertical, so for a calculation of 14° after
  ///   sunset, an offset of 14 + [GEOMETRIC_ZENITH] = 104 would have to be passed as a parameter.
  /// Returns The [DateTime]of the offset after (or before) [getSunset]. If the calculation can't
  /// be computed such as in the Arctic Circle where there is at least one day a year where the sun does not
  /// rise, and one where it does not set, a null will be returned. See detailed explanation on top of the
  /// page.
  DateTime? getSunsetOffsetByDegrees(double offsetZenith) {
    double sunset = getUTCSunset(offsetZenith);
    if (sunset.isNaN) {
      return null;
    } else {
      return getDateFromTime(sunset, false);
    }
  }

  /// A constructor that takes in [geolocation](http://en.wikipedia.org/wiki/Geolocation) information as a
  /// parameter. The default [AstronomicalCalculator.getDefault] used for solar
  /// calculations is the the [NOAACalculator].
  ///
  /// - [geoLocation]: 
  ///   The location information used for calculating astronomical sun times.
  ///
  /// See also [setAstronomicalCalculator for changing the calculator class.].
  AstronomicalCalendar({GeoLocation? geoLocation}) {
    geoLocation ??= GeoLocation();
    setCalendar(geoLocation.getDateTime());
    setGeoLocation(geoLocation); // duplicate call
    setAstronomicalCalculator(AstronomicalCalculator.getDefault());
  }

  /// A method that returns the sunrise in UTC time without correction for time zone offset from GMT and without using
  /// daylight savings time.
  ///
  /// - [zenith]: 
  ///   the degrees below the horizon. For time after sunrise use negative numbers.
  /// Returns The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the
  /// Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  /// not set, double.nan will be returned. See detailed explanation on top of the page.
  double getUTCSunrise(double zenith) {
    return getAstronomicalCalculator()
        .getUTCSunrise(getAdjustedCalendar(), getGeoLocation(), zenith, true);
  }

  /// A method that returns the sunrise in UTC time without correction for time zone offset from GMT and without using
  /// daylight savings time. Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible
  /// light, something that is not affected by elevation. This method returns UTC sunrise calculated at sea level. This
  /// forms the base for dawn calculations that are calculated as a dip below the horizon before sunrise.
  ///
  /// - [zenith]: 
  ///   the degrees below the horizon. For time after sunrise use negative numbers.
  /// Returns The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the
  /// Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  /// not set, double.nan will be returned. See detailed explanation on top of the page.
  /// See also [AstronomicalCalendar.getUTCSunrise].
  /// See also [AstronomicalCalendar.getUTCSeaLevelSunset].
  double getUTCSeaLevelSunrise(double zenith) {
    return getAstronomicalCalculator()
        .getUTCSunrise(getAdjustedCalendar(), getGeoLocation(), zenith, false);
  }

  /// A method that returns the sunset in UTC time without correction for time zone offset from GMT and without using
  /// daylight savings time.
  ///
  /// - [zenith]: 
  ///   the degrees below the horizon. For time after sunset use negative numbers.
  /// Returns The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the
  /// Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  /// not set, double.nan will be returned. See detailed explanation on top of the page.
  /// See also [AstronomicalCalendar.getUTCSeaLevelSunset].
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
  /// - [zenith]: 
  ///   the degrees below the horizon. For time before sunset use negative numbers.
  /// Returns The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the
  /// Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  /// not set, double.nan will be returned. See detailed explanation on top of the page.
  /// See also [AstronomicalCalendar.getUTCSunset].
  /// See also [AstronomicalCalendar.getUTCSeaLevelSunrise].
  double getUTCSeaLevelSunset(double zenith) {
    return getAstronomicalCalculator()
        .getUTCSunset(getAdjustedCalendar(), getGeoLocation(), zenith, false);
  }

  /// A utility method that will allow the calculation of a temporal (solar) hour based on the sunrise and sunset
  /// passed as parameters to this method. An example of the use of this method would be the calculation of a
  /// non-elevation adjusted temporal hour by passing in [getSeaLevelSunrise] and
  /// [getSeaLevelSunset] as parameters.
  ///
  /// - [startOfday]: 
  ///   The start of the day.
  /// - [endOfDay]: 
  ///   The end of the day.
  ///
  /// Returns the `long` millisecond length of the temporal hour. If the calculation can't be computed a
  /// double.nan will be returned. See detailed explanation on top of the page.
  ///
  /// See also [getTemporalHour].
  double getTemporalHour([DateTime? startOfDay, DateTime? endOfDay]) {
    if (startOfDay == null || endOfDay == null) {
      startOfDay = getSeaLevelSunrise();
      endOfDay = getSeaLevelSunset();
    }
    return (endOfDay!.millisecondsSinceEpoch -
            startOfDay!.millisecondsSinceEpoch) /
        12;
  }

  /// A method that returns sundial or solarnoon. It occurs when the Sun is [transiting](http://en.wikipedia.org/wiki/Transit_%28astronomy%29) the [celestial meridian](http://en.wikipedia.org/wiki/Meridian_%28astronomy%29). In this class it is
  /// calculated as halfway between the sunrise and sunset passed to this method. This time can be slightly off the
  /// real transit time due to changes in declination (the lengthening or shortening day).
  ///
  /// - [startOfDay]: 
  ///   the start of day for calculating the sun's transit. This can be sea level sunrise, visual sunrise (or
  ///   any arbitrary start of day) passed to this method.
  /// - [endOfDay]: 
  ///   the end of day for calculating the sun's transit. This can be sea level sunset, visual sunset (or any
  ///   arbitrary end of day) passed to this method.
  ///
  /// Returns the `Date` representing Sun's transit. If the calculation can't be computed such as in the
  /// Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  /// not set, null will be returned. See detailed explanation on top of the page.
  DateTime? getSunTransit([DateTime? startOfDay, DateTime? endOfDay]) {
    if (startOfDay == null || endOfDay == null) {
      startOfDay = getSeaLevelSunrise();
      endOfDay = getSeaLevelSunset();
    }
    double temporalHour = getTemporalHour(startOfDay, endOfDay);
    return getTimeOffset(startOfDay, temporalHour * 6);
  }

  /// A method that returns a `Date` from the time passed in as a parameter.
  ///
  /// - [time]: 
  ///   The time to be set as the time for the `Date`. The time expected is in the format: 18.75
  ///   for 6:45:00 PM.time is sunrise and false if it is sunset
  /// - [isSunrise]: true if the
  /// Returns The Date.
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
  /// example passing in 72 minutes for a calendar set to the equinox in Jerusalem returns a value close to 16.1°
  /// Please note that this method is very slow and inefficient and should NEVER be used in a loop. TODO: Improve
  /// efficiency.
  ///
  /// - [minutes]: 
  ///   offset
  /// Returns the degrees below the horizon before sunrise that match the offset in minutes passed it as a parameter.
  /// See also [getSunsetSolarDipFromOffset].
  double getSunriseSolarDipFromOffset(double minutes) {
    DateTime? seaLevelSunrise = getSeaLevelSunrise();
    DateTime? offsetByTime =
        getTimeOffset(seaLevelSunrise, -(minutes * MINUTE_MILLIS));
    if (seaLevelSunrise == null || offsetByTime == null) return 0.0;

    double low = minutes > 0.0 ? 0.0 : -90.0;
    double high = minutes > 0.0 ? 90.0 : 0.0;

    while ((high - low) > 0.0001) {
      double mid = (low + high) / 2.0;
      DateTime? offsetByDegrees =
          getSunriseOffsetByDegrees(GEOMETRIC_ZENITH + mid);
      bool conditionContinues;
      if (offsetByDegrees == null) {
        conditionContinues = false;
      } else if (minutes > 0.0) {
        conditionContinues = offsetByDegrees.isAfter(offsetByTime);
      } else {
        conditionContinues = offsetByDegrees.isBefore(offsetByTime);
      }
      if (minutes > 0.0) {
        if (conditionContinues) {
          low = mid;
        } else {
          high = mid;
        }
      } else {
        if (conditionContinues) {
          high = mid;
        } else {
          low = mid;
        }
      }
    }
    return minutes > 0.0 ? high : low;
  }

  /// Returns the dip below the horizon after sunset that matches the offset minutes on passed in as a parameter. For
  /// example passing in 72 minutes for a calendar set to the equinox in Jerusalem returns a value close to 16.1°
  /// Please note that this method is very slow and inefficient and should NEVER be used in a loop. TODO: Improve
  /// efficiency.
  ///
  /// - [minutes]: 
  ///   offset
  /// Returns the degrees below the horizon after sunset that match the offset in minutes passed it as a parameter.
  /// See also [getSunriseSolarDipFromOffset].
  double getSunsetSolarDipFromOffset(double minutes) {
    DateTime? seaLevelSunset = getSeaLevelSunset();
    DateTime? offsetByTime =
        getTimeOffset(seaLevelSunset, minutes * MINUTE_MILLIS);
    if (seaLevelSunset == null || offsetByTime == null) return 0.0;

    double low = minutes > 0.0 ? 0.0 : -90.0;
    double high = minutes > 0.0 ? 90.0 : 0.0;

    while ((high - low) > 0.0001) {
      double mid = (low + high) / 2.0;
      DateTime? offsetByDegrees =
          getSunsetOffsetByDegrees(GEOMETRIC_ZENITH + mid);
      bool conditionContinues;
      if (offsetByDegrees == null) {
        conditionContinues = false;
      } else if (minutes > 0.0) {
        conditionContinues = offsetByDegrees.isBefore(offsetByTime);
      } else {
        conditionContinues = offsetByDegrees.isAfter(offsetByTime);
      }
      if (minutes > 0.0) {
        if (conditionContinues) {
          low = mid;
        } else {
          high = mid;
        }
      } else {
        if (conditionContinues) {
          high = mid;
        } else {
          low = mid;
        }
      }
    }
    return minutes > 0.0 ? high : low;
  }

  /// Adjusts the `Calendar` to deal with edge cases where the location crosses the antimeridian.
  ///
  /// See also [GeoLocation.getAntimeridianAdjustment].
  /// Returns the adjusted Calendar
  DateTime getAdjustedCalendar() {
    int offset = getGeoLocation().getAntimeridianAdjustment();
    if (offset == 0) {
      return getCalendar();
    }
    return getCalendar().add(Duration(days: offset));
  }

/*

  /// Returns an XML formatted representation of the class. It returns the default output of the
  /// [ZmanimFormatter.toXML] method.
  /// See also [ZmanimFormatter.toXML].
  /// See also [Object.toString].
  String toString() {
    return ZmanimFormatter.toXML(this);
  }

  /// Returns a JSON formatted representation of the class. It returns the default output of the
  /// [ZmanimFormatter.toJSON] method.
  /// See also [ZmanimFormatter.toJSON].
  /// See also [Object.toString].
  String toJSON() {
    return ZmanimFormatter.toJSON(this);
  }
*/
  /// See also [Object.equals].
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

  /// A method that returns the currently set [GeoLocation] which contains location information used for the
  /// astronomical calculations.
  ///
  /// Returns the geoLocation.
  GeoLocation getGeoLocation() {
    return geoLocation;
  }

  /// Sets the [GeoLocation] `Object` to be used for astronomical calculations.
  ///
  /// - [geoLocation]: 
  ///   The geoLocation to set.
  void setGeoLocation(GeoLocation geoLocation) {
    this.geoLocation = geoLocation;
    setCalendar(geoLocation.getDateTime());
  }

  /// A method that returns the currently set AstronomicalCalculator.
  ///
  /// Returns the astronomicalCalculator.
  /// See also [setAstronomicalCalculator].
  AstronomicalCalculator getAstronomicalCalculator() {
    return astronomicalCalculator;
  }

  /// A method to set the [AstronomicalCalculator] used for astronomical calculations. The Zmanim package ships
  /// with a number of different implementations of the `abstract` [AstronomicalCalculator] based on
  /// different algorithms, including [SunTimesCalculator] based
  /// on the [US Naval Observatory's](http://aa.usno.navy.mil/) algorithm, and
  /// [NOAACalculator] based on [NOAA's](http://noaa.gov)
  /// algorithm. This allows easy runtime switching and comparison of different algorithms.
  ///
  /// - [astronomicalCalculator]: 
  ///   The astronomicalCalculator to set.
  void setAstronomicalCalculator(
      AstronomicalCalculator astronomicalCalculator) {
    this.astronomicalCalculator = astronomicalCalculator;
  }

  /// returns the Calendar object encapsulated in this class.
  ///
  /// Returns the calendar.
  DateTime getCalendar() {
    return _calendar;
  }

  /// - [calendar]: 
  ///   The calendar to set.
  void setCalendar(DateTime calendar) {
    _calendar = calendar;
  }
}
