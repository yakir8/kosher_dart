/*
 * Zmanim Java API
 * Copyright (C) 2004-2011 Eliyahu Hershfeld
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

/// A class that represents a numeric time. Times that represent a time of day are stored as {@link java.util.Date}s in
/// this API. The time class is used to represent numeric time such as the time in hours, minutes, seconds and
/// milliseconds of a {@link net.sourceforge.zmanim.AstronomicalCalendar#getTemporalHour() temporal hour}.
///
/// @author &copy; Eliyahu Hershfeld 2004 - 2011
/// @version 0.9.0
class Time {
  ///  milliseconds in a second.
  static const int _SECOND_MILLIS = 1000;

  /// milliseconds in a minute.
  static const int _MINUTE_MILLIS = _SECOND_MILLIS * 60;

  /// milliseconds in an hour.
  static const int _HOUR_MILLIS = _MINUTE_MILLIS * 60;

  int hours = 0;

  int minutes = 0;

  int seconds = 0;

  int milliseconds = 0;

  bool _isNegative = false;

  /// Constructor with parameters for the hours, minutes, seconds and millisecods.
  ///
  /// @param hours the hours to set
  /// @param minutes the minutes to set
  /// @param seconds the seconds to set
  /// @param milliseconds the milliseconds to set
  Time(this.hours, this.minutes, this.seconds, this.milliseconds);

  /// A constructor that sets the time by milliseconds. The milliseconds are converted to hours, minutes, seconds
  /// and milliseconds. If the milliseconds are negative it will call {@link #setIsNegative(boolean)}.
  /// @param millis the milliseconds to set.
  Time.millis(double millis) {
    double adjustedMillis = millis;
    if (adjustedMillis < 0) {
      _isNegative = true;
      adjustedMillis = adjustedMillis.abs();
    }
    hours = adjustedMillis ~/ _HOUR_MILLIS;
    adjustedMillis = adjustedMillis - hours * _HOUR_MILLIS;

    minutes = adjustedMillis ~/ _MINUTE_MILLIS;
    adjustedMillis = adjustedMillis - minutes * _MINUTE_MILLIS;

    seconds = adjustedMillis ~/ _SECOND_MILLIS;
    adjustedMillis = adjustedMillis - seconds * _SECOND_MILLIS;

    milliseconds = adjustedMillis.toInt();
  }

  /// Set this to represent a negative time.
  /// @param isNegative that the Time represents negative time
  bool isNegative() {
    return _isNegative;
  }

  void setIsNegative(bool isNegative) {
    _isNegative = isNegative;
  }

  /// @return Returns the hour.
  int getHours() {
    return hours;
  }

  /// @param hours
  ///            The hours to set.
  void setHours(int hours) {
    this.hours = hours;
  }

  /// @return Returns the minutes.
  int getMinutes() {
    return minutes;
  }

  /// @param minutes
  ///            The minutes to set.
  void setMinutes(int minutes) {
    this.minutes = minutes;
  }

  /// @return Returns the seconds.
  int getSeconds() {
    return seconds;
  }

  /// @param seconds
  ///            The seconds to set.
  void setSeconds(int seconds) {
    this.seconds = seconds;
  }

  /// @return Returns the milliseconds.
  int getMilliseconds() {
    return milliseconds;
  }

  /// @param milliseconds
  ///            The milliseconds to set.
  void setMilliseconds(int milliseconds) {
    this.milliseconds = milliseconds;
  }

  ///Returns the time in milliseconds by converting hours, minutes and seconds into milliseconds.
  ///@return the time in milliseconds
  double getTime() {
    double hourMillis = (hours * _HOUR_MILLIS).toDouble();
    double minutesMillis = (minutes * _MINUTE_MILLIS).toDouble();
    double secondsMillis = (seconds * _SECOND_MILLIS).toDouble();
    return (hourMillis + minutesMillis + secondsMillis + milliseconds)
        .toDouble();
  }

  @override
  String toString() {
    return "$hours:$minutes:$seconds:$milliseconds";
  }
}
