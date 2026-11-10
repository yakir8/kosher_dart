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
import 'package:kosher_dart/src/hebrewcalendar/jewish_date.dart';

/// This class calculates the [Talmud Yerusalmi](https://en.wikipedia.org/wiki/Jerusalem_Talmud) [Daf Yomi]
/// (https://en.wikipedia.org/wiki/Daf_Yomi) page ([Daf]) for the a given date.
///
/// © elihaidv
/// © Eliyahu Hershfeld 2017 - 2018
class YerushalmiYomiCalculator {
  /// The start date of the first Daf Yomi Yerushalmi cycle of February 2, 1980 / 15 Shevat, 5740.

  static final DateTime dafYomiStartDay = DateTime(1980, 2, 2);

  // Use UTC calendar dates internally, independent of the device timezone
  // and daylight-saving transitions. Keep the public startDay unchanged.
  static final DateTime _startDayUtc = DateTime.utc(1980, 2, 2);

  /// The number of milliseconds in a day.
  static const int DAY_MILIS = 1000 * 60 * 60 * 24;

  /// he number of pages in the Talmud Yerushalmi.
  static const int WHOLE_SHAS_DAFS = 1554;

  /// The number of pages per _masechta_ (tractate).
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
  /// [Yerusalmi](https://en.wikipedia.org/wiki/Jerusalem_Talmud) page ([Daf]) for a given date.
  /// The first Daf Yomi cycle started on 15 Shevat (Tu Bishvat), 5740 (February, 2, 1980) and calculations
  /// prior to this date will result in an IllegalArgumentException thrown.
  ///
  /// - [calendar]:
  ///   the calendar date for calculation
  /// Returns the [Daf].
  ///
  /// Throws [ArgumentError]
  ///             if the date is prior to the September 11, 1923 start date of the first Daf Yomi cycle
  static Daf getDafYomiYerushalmi(JewishCalendar calendar) {
    final requested = DateTime.utc(calendar.getGregorianYear(),
        calendar.getGregorianMonth(), calendar.getGregorianDayOfMonth());

    // There is no Daf Yomi Yerushalmi on Yom Kippur or the observed
    // Tisha B'Av fast (10 Av if 9 Av falls on Shabbos).
    final holiday = calendar.getYomTovIndex();
    if (holiday == JewishCalendar.YOM_KIPPUR ||
        holiday == JewishCalendar.TISHA_BEAV) {
      return Daf(39, 0);
    }

    if (requested.isBefore(_startDayUtc)) {
      throw ArgumentError(
          "$requested is prior to organized Daf Yomi Yerushalmi cycles that started on $dafYomiStartDay");
    }

    var cycleStart = _startDayUtc;
    while (true) {
      var cycleEnd = cycleStart.add(const Duration(days: WHOLE_SHAS_DAFS));

      // Each skipped fast extends the cycle by one civil day. Recount until
      // stable because an extension can itself include another skipped day.
      while (true) {
        // Include a fast that falls exactly on the tentative cycle boundary:
        // it is a skipped day, not the first daf of the next cycle.
        final skipped = _getNumOfSpecialDays(
            cycleStart, cycleEnd.add(const Duration(days: 1)));
        final correctedEnd =
            cycleStart.add(Duration(days: WHOLE_SHAS_DAFS + skipped));
        if (correctedEnd.isAtSameMomentAs(cycleEnd)) {
          break;
        }
        cycleEnd = correctedEnd;
      }
      if (requested.isBefore(cycleEnd)) {
        break;
      }
      cycleStart = cycleEnd;
    }

    var remaining = requested.difference(cycleStart).inDays -
        _getNumOfSpecialDays(cycleStart, requested);
    for (var tractate = 0; tractate < BLATT_PER_MASSECTA.length; tractate++) {
      final pages = BLATT_PER_MASSECTA[tractate];
      if (remaining < pages) {
        return Daf(tractate, remaining + 1);
      }
      remaining -= pages;
    }
    throw StateError('Yerushalmi daf index is outside the cycle');
  }

  /// Return the number of special days (Yom Kippur and Tisha Beav) That there is no Daf in this days.
  /// From the last given number of days until given date
  ///
  /// - [start]: start date to calculate
  /// - [end]: end date to calculate
  /// Returns the number of special days
  static int _getNumOfSpecialDays(DateTime start, DateTime end) {
    final startYear = JewishCalendar.fromDateTime(start).getJewishYear();
    final endYear = JewishCalendar.fromDateTime(end).getJewishYear();
    var skipped = 0;

    // initDate fixes the time at noon, so _isBetween counts the start day.
    final yomKippur =
        JewishCalendar.initDate(startYear, JewishDate.TISHREI, 10);
    final tishaBeav = JewishCalendar.initDate(startYear, JewishDate.AV, 9);
    for (var year = startYear; year <= endYear; year++) {
      yomKippur.setJewishDate(year, JewishDate.TISHREI, 10);
      tishaBeav.setJewishDate(year, JewishDate.AV, 9);
      // The Daf is studied on 9 Av when it is Shabbos, but not on
      // the deferred fast of 10 Av.
      if (tishaBeav.getDayOfWeek() == JewishDate.saturday) {
        tishaBeav.forward();
      }
      if (_isBetween(start, yomKippur.getGregorianCalendar(), end)) {
        skipped++;
      }
      if (_isBetween(start, tishaBeav.getGregorianCalendar(), end)) {
        skipped++;
      }
    }
    return skipped;
  }

  /// Return if the date is between two dates
  ///
  /// - [start]: the start date
  /// - [date]: the date being compared
  /// - [end]: the end date
  /// Returns if the date is between the start and end dates
  static bool _isBetween(DateTime start, DateTime date, DateTime end) {
    return start.isBefore(date) && end.isAfter(date);
  }
}
