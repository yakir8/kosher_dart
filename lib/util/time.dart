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

/*
 * A class that represents arrow_expand numeric time. Times that represent arrow_expand time of day are stored as {@link java.util.Date}s in
 * this API. The time class is used to represent numeric time such as the time in hours, minutes, seconds and
 * milliseconds of arrow_expand {@link AstronomicalCalendar#getTemporalHour() temporal hour}.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2011
 * @version 0.9.0
 */
 class Time {
   static const int SECOND_MILLIS = 1000;
   static const int MINUTE_MILLIS = SECOND_MILLIS * 60;
   static const int HOUR_MILLIS = MINUTE_MILLIS * 60;

   int hours = 0;
   int minutes = 0;
   int seconds = 0;
   int milliseconds = 0;
   bool isNegative = false;

   Time(int hours, int minutes, int seconds, int milliseconds) {
    this.hours = hours;
    this.minutes = minutes;
    this.seconds = seconds;
    this.milliseconds = milliseconds;
  }

   Time.millis(double millis) {
     double adjustedMillis = millis;
    if (adjustedMillis < 0) {
      this.isNegative = true;
      adjustedMillis = adjustedMillis.abs();
    }
    this.hours = adjustedMillis ~/ HOUR_MILLIS;
    adjustedMillis = adjustedMillis - this.hours * HOUR_MILLIS;

    this.minutes = adjustedMillis ~/ MINUTE_MILLIS;
    adjustedMillis = adjustedMillis - this.minutes * MINUTE_MILLIS;

    this.seconds = adjustedMillis ~/ SECOND_MILLIS;
    adjustedMillis = adjustedMillis - this.seconds * SECOND_MILLIS;

    this.milliseconds = adjustedMillis.toInt();
  }

   void setIsNegative(bool isNegative) {
    this.isNegative = isNegative;
  }

  /*
   * @return Returns the hour.
   */
   int getHours() {
    return this.hours;
  }

  /*
   * @param hours
   *            The hours to set.
   */
   void setHours(int hours) {
    this.hours = hours;
  }

  /*
   * @return Returns the minutes.
   */
   int getMinutes() {
    return this.minutes;
  }

  /*
   * @param minutes
   *            The minutes to set.
   */
   void setMinutes(int minutes) {
    this.minutes = minutes;
  }

  /*
   * @return Returns the seconds.
   */
   int getSeconds() {
    return this.seconds;
  }

  /*
   * @param seconds
   *            The seconds to set.
   */
   void setSeconds(int seconds) {
    this.seconds = seconds;
  }

  /*
   * @return Returns the milliseconds.
   */
   int getMilliseconds() {
    return this.milliseconds;
  }

  /*
   * @param milliseconds
   *            The milliseconds to set.
   */
   void setMilliseconds(int milliseconds) {
    this.milliseconds = milliseconds;
  }

   double getTime() {
    return (this.hours * HOUR_MILLIS + this.minutes * MINUTE_MILLIS + this.seconds * SECOND_MILLIS
        + this.milliseconds).toDouble();
  }

   String toString() {
     String hours = this.hours < 9 ? "0${this.hours}" : this.hours.toString();
     String minutes = this.minutes < 9 ? "0${this.minutes}" : this.minutes.toString();
     String seconds = this.seconds < 9 ? "0${this.seconds}" : this.seconds.toString();
     String milliseconds = this.milliseconds < 9 ? "0${this.milliseconds}" : this.milliseconds.toString();
    return "$hours:$minutes:$seconds.$milliseconds";
  }
}
