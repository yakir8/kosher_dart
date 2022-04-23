/*
 * Zmanim Java API
 * Copyright (C) 2017 - 2018 Eliyahu Hershfeld
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

import 'package:kosher_dart/src/hebrewcalendar/daf.dart';
import 'package:kosher_dart/src/hebrewcalendar/jewish_calendar.dart';

/// This class calculates the [Talmud Yerusalmi](https://en.wikipedia.org/wiki/Jerusalem_Talmud) [Daf Yomi]
/// (https://en.wikipedia.org/wiki/Daf_Yomi) page ({@link Daf}) for the a given date.
///
/// @author &copy; elihaidv
/// @author &copy; Eliyahu Hershfeld 2017 - 2018
class YerushalmiYomiCalculator {
  /// The start date of the first Daf Yomi Yerushalmi cycle of February 2, 1980 / 15 Shevat, 5740.

  static final DateTime dafYomiStartDay = DateTime(1980, 2, 2);

  /// The number of milliseconds in a day.
  static const int DAY_MILIS = 1000 * 60 * 60 * 24;

  /// he number of pages in the Talmud Yerushalmi.
  static const int WHOLE_SHAS_DAFS = 1554;

  /// The number of pages per <em>masechta</em> (tractate).
  static const List<int> BLATT_PER_MASSECTA = [
    68,
    37,
    34,
    44,
    31,
    59,
    26,
    33,
    28,
    20,
    13,
    92,
    65,
    71,
    22,
    22,
    42,
    26,
    26,
    33,
    34,
    22,
    19,
    85,
    72,
    47,
    40,
    47,
    54,
    48,
    44,
    37,
    34,
    44,
    9,
    57,
    37,
    19,
    13
  ];

  /// Returns the [Daf Yomi](https://en.wikipedia.org/wiki/Daf_Yomi)
  /// [Yerusalmi](https://en.wikipedia.org/wiki/Jerusalem_Talmud) page ({@link Daf}) for a given date.
  /// The first Daf Yomi cycle started on 15 Shevat (Tu Bishvat), 5740 (February, 2, 1980) and calculations
  /// prior to this date will result in an IllegalArgumentException thrown.
  ///
  /// @param calendar
  ///            the calendar date for calculation
  /// @return the {@link Daf}.
  ///
  /// @throws IllegalArgumentException
  ///             if the date is prior to the September 11, 1923 start date of the first Daf Yomi cycle
  static Daf getDafYomiYerushalmi(JewishCalendar calendar) {
    DateTime nextCycle = DateTime.now();
    DateTime prevCycle = DateTime.now();
    DateTime requested = calendar.getGregorianCalendar();
    int masechta = 0;
    Daf dafYomi = Daf(0, 0);

    // There isn't Daf Yomi in Yom Kippur and Tisha Beav.
    if (calendar.getYomTovIndex() == JewishCalendar.YOM_KIPPUR ||
        calendar.getYomTovIndex() == JewishCalendar.TISHA_BEAV) {
      return Daf(39, 0);
    }

    if (requested.isBefore(dafYomiStartDay)) {
      // TODO: should we return a null or throw an IllegalArgumentException?
      throw ArgumentError(
          "$requested is prior to organized Daf Yomi Yerushlmi cycles that started on $dafYomiStartDay");
    }

    // Start to calculate current cycle. init the start day
    nextCycle = DateTime.parse(dafYomiStartDay.toIso8601String());

    // Go cycle by cycle, until we get the next cycle
    while (requested.isAfter(nextCycle)) {
      prevCycle = DateTime.parse(nextCycle.toIso8601String());

      // Adds the number of whole shas dafs. and the number of days that not have daf.
      nextCycle = nextCycle.add(const Duration(days: WHOLE_SHAS_DAFS));
      nextCycle = nextCycle
          .add(Duration(days: _getNumOfSpecialDays(prevCycle, nextCycle)));
    }

    // Get the number of days from cycle start until request.
    int dafNo = (_getDiffBetweenDays(prevCycle, requested)).toInt();

    // Get the number of special day to subtract
    int specialDays = _getNumOfSpecialDays(prevCycle, requested);
    int total = dafNo - specialDays;

    // Finally find the daf.
    for (int j = 0; j < BLATT_PER_MASSECTA.length; j++) {
      if (total <= BLATT_PER_MASSECTA[j]) {
        dafYomi = Daf(masechta, total + 1);
        break;
      }
      total -= BLATT_PER_MASSECTA[j];
      masechta++;
    }

    return dafYomi;
  }

  /// Return the number of special days (Yom Kippur and Tisha Beav) That there is no Daf in this days.
  /// From the last given number of days until given date
  ///
  /// @param start start date to calculate
  /// @param end end date to calculate
  /// @return the number of special days
  static int _getNumOfSpecialDays(DateTime start, DateTime end) {
    // Find the start and end Jewish years
    int startYear = JewishCalendar.fromDateTime(start).getJewishYear();
    int endYear = JewishCalendar.fromDateTime(end).getJewishYear();

    // Value to return
    int specialDays = 0;

    //Instant of special Dates
    JewishCalendar yomKippur = JewishCalendar.initDate(5770, 7, 10);
    JewishCalendar tishaBeav = JewishCalendar.initDate(5770, 5, 9);

    // Go over the years and find special dates
    for (int i = startYear; i <= endYear; i++) {
      yomKippur.setJewishYear(i);
      tishaBeav.setJewishYear(i);

      if (_isBetween(start, yomKippur.getGregorianCalendar(), end)) {
        specialDays++;
      }
      if (_isBetween(start, tishaBeav.getGregorianCalendar(), end)) {
        specialDays++;
      }
    }

    return specialDays;
  }

  /// Return if the date is between two dates
  ///
  /// @param start the start date
  /// @param date the date being compared
  /// @param end the end date
  /// @return if the date is between the start and end dates
  static bool _isBetween(DateTime start, DateTime date, DateTime end) {
    return start.isBefore(date) && end.isAfter(date);
  }

  /// Return the number of days between the dates passed in
  /// @param start the start date
  /// @param end the end date
  /// @return the number of days between the start and end dates
  static double _getDiffBetweenDays(DateTime start, DateTime end) {
    return end.difference(start).inMilliseconds / DAY_MILIS;
  }
}
