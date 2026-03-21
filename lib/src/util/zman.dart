/*
 * Zmanim Java API
 * Copyright (C) 2004-2020 Eliyahu Hershfeld
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

/// A wrapper class for a astronomical times / _zmanim_ that is mostly intended to allow sorting collections of astronomical times.
/// It has fields for both date/time and duration based _zmanim_, name / labels as well as a longer description or explanation of a
/// _zman_.
///
/// Here is an example of various ways of sorting _zmanim_.
/// First create the Calendar for the location you would like to calculate:
///
///
/// ```dart
///  String locationName = "Lakewood, NJ";
///  double latitude = 40.0828; // Lakewood, NJ
///  double longitude = -74.2094; // Lakewood, NJ
///  double elevation = 20; // optional elevation correction in Meters
///  // the String parameter in getTimeZone() has to be a valid timezone listed in [TimeZone.getAvailableIDs]
///  TimeZone timeZone = TimeZone.getTimeZone("America/New_York");
///  GeoLocation location = new GeoLocation(locationName, latitude, longitude, elevation, timeZone);
///  ComplexZmanimCalendar czc = new ComplexZmanimCalendar(location);
///  Zman sunset = new Zman(czc.getSunset(), "Sunset");
///  Zman shaah16 = new Zman(czc.getShaahZmanis16Point1Degrees(), "Shaah zmanis 16.1");
///  Zman sunrise = new Zman(czc.getSunrise(), "Sunrise");
///  Zman shaah = new Zman(czc.getShaahZmanisGra(), "Shaah zmanis GRA");
///  ArrayList<Zman> zl = new ArrayList<Zman>();
///  zl.add(sunset);
///  zl.add(shaah16);
///  zl.add(sunrise);
///  zl.add(shaah);
///  //will sort sunset, shaah 1.6, sunrise, shaah GRA
///  System.out.println(zl);
///  Collections.sort(zl, Zman.DATE_ORDER);
///  // will sort sunrise, sunset, shaah, shaah 1.6 (the last 2 are not in any specific order)
///  Collections.sort(zl, Zman.DURATION_ORDER);
///  // will sort sunrise, sunset (the first 2 are not in any specific order), shaah GRA, shaah 1.6
///  Collections.sort(zl, Zman.NAME_ORDER);
///  // will sort shaah 1.6, shaah GRA, sunrise, sunset
/// ```
///
/// © Eliyahu Hershfeld 2007-2020
/// TODO: Add secondary sorting. As of now the `Comparator`s in this class do not sort by secondary order. This means that when sorting a
/// [Collection] of _zmanim_ and using the [DATE_ORDER] `Comparator` will have the duration based _zmanim_
/// at the end, but they will not be sorted by duration. This should be N/A for label based sorting.
class Zman {
  /// The name / label of the _zman_.
  late String _label;

  /// The [Date] of the _zman_
  DateTime? _zman;

  /// The duration if the _zman_ is  a [AstronomicalCalendar.getTemporalHour] (or the various
  /// _shaah zmanis_ base times such as [ZmanimCalendar.getShaahZmanisGra] or
  /// [ComplexZmanimCalendar.getShaahZmanis16Point1Degrees]).
  double? _duration;

  /// A longer description or explanation of a _zman_.
  String? _description;

  /// The constructor setting a [Date] based _zman_ and a label.
  /// - [date]: the Date of the _zman_.
  /// - [label]: the label of the  _zman_ such as "_Sof Zman Krias Shema GRA_".
  /// See also [Zman].
  Zman(this._zman, this._label);

  /// The constructor setting a duration based _zman_ such as
  /// [AstronomicalCalendar.getTemporalHour] (or the various _shaah zmanis_ times such as
  /// [ZmanimCalendar.getShaahZmanisGra] or
  /// [ComplexZmanimCalendar.getShaahZmanis16Point1Degrees]) and label.
  /// - [duration]: a duration based _zman_ such as ([AstronomicalCalendar.getTemporalHour]
  /// - [label]: the label of the  _zman_ such as "_Shaah Zmanis GRA_".
  /// See also [Zman].
  Zman.duration(this._duration, this._label);

  /// Returns the `Date` based _zman_.
  /// Returns the _zman_.
  /// See also [setZman].
  DateTime? getZman() {
    return _zman;
  }

  /// Sets a `Date` based _zman_.
  /// - [date]: a `Date` based _zman_
  /// See also [getZman].
  void setZman(DateTime date) {
    _zman = date;
  }

  /// Returns a duration based _zman_ such as [AstronomicalCalendar.getTemporalHour]
  /// (or the various _shaah zmanis_ times such as [ZmanimCalendar.getShaahZmanisGra]
  /// or [ComplexZmanimCalendar.getShaahZmanis16Point1Degrees]).
  /// Returns the duration based _zman_.
  /// See also [setDuration].
  double? getDuration() {
    return _duration;
  }

  ///  Sets a duration based _zman_ such as [AstronomicalCalendar.getTemporalHour]
  /// (or the various _shaah zmanis_ times as [ZmanimCalendar.getShaahZmanisGra] or
  /// [ComplexZmanimCalendar.getShaahZmanis16Point1Degrees]).
  /// - [duration]: duration based _zman_ such as [AstronomicalCalendar.getTemporalHour].
  /// See also [getDuration].
  void setDuration(double duration) {
    _duration = duration;
  }

  /// Returns the name / label of the _zman_ such as "_Sof Zman Krias Shema GRA_". There are no automatically set labels
  /// and you must set them using [setLabel].
  /// Returns the name/label of the _zman_.
  /// See also [setLabel].
  String getLabel() {
    return _label;
  }

  /// Sets the the name / label of the _zman_ such as "_Sof Zman Krias Shema GRA_".
  /// - [label]: the name / label to set for the _zman_.
  /// See also [getLabel].
  void setLabel(String label) {
    _label = label;
  }

  /// Returns the longer description or explanation of a _zman_. There is no default value for this and it must be set using
  /// [setDescription]
  /// Returns the description or explanation of a _zman_.
  /// See also [setDescription].
  String? getDescription() {
    return _description;
  }

  /// Sets the longer description or explanation of a _zman_.
  /// - [description]: 
  ///   the _zman_ description to set.
  /// See also [getDescription].
  void setDescription(String description) {
    _description = description;
  }

  /// See also [Object.toString].
  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write("\nLabel:\t\t\t");
    sb.write(getLabel());
    sb.write("\nZman:\t\t\t");
    sb.write(getZman());
    sb.write("\nDuration:\t\t\t");
    sb.write(getDuration());
    sb.write("\nDescription:\t\t\t");
    sb.write(getDescription());
    return sb.toString();
  }
}
