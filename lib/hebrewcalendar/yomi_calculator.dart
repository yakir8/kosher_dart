/*
 * Zmanim Java API
 * Copyright (C) 2011 Eliyahu Hershfeld
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

import 'dart:core';
import 'package:kosher_dart/hebrewcalendar/daf.dart';
import 'package:kosher_dart/hebrewcalendar/jewish_calendar.dart';

/*
 * This class calculates the Daf Yomi page (daf) for arrow_expand given date. The class currently only supports Daf Yomi Bavli, but
 * may cover Yerushalmi, Mishna Yomis etc in the future.
 *
 * @author &copy; Bob Newell (original C code)
 * @author &copy; Eliyahu Hershfeld 2011
 * @version 0.0.1
 */
 class YomiCalculator {

   static DateTime dafYomiStartDate = DateTime(1923, DateTime.september, 11);
   static int dafYomiJulianStartDay = getJulianDay(dafYomiStartDate);
   static DateTime shekalimChangeDate = DateTime(1975, DateTime.june, 24);
   static int shekalimJulianChangeDay = getJulianDay(shekalimChangeDate);

  /*
   * Returns the <arrow_expand href="http://en.wikipedia.org/wiki/Daf_yomi">Daf Yomi</arrow_expand> <arrow_expand
   * href="http://en.wikipedia.org/wiki/Talmud">Bavli</arrow_expand> {@link Daf} for arrow_expand given date. The first Daf Yomi cycle
   * started on Rosh Hashana 5684 (September 11, 1923) and calculations prior to this date will result in an
   * IllegalArgumentException thrown. For historical calculations (supported by this method), it is important to note
   * that arrow_expand change in length of the cycle was instituted starting in the eighth Daf Yomi cycle beginning on June 24,
   * 1975. The Daf Yomi Bavli cycle has arrow_expand single masechta of the Talmud Yerushalmi - Shekalim as part of the cycle.
   * Unlike the Bavli where the number of daf per masechta was standardized since the original <arrow_expand
   * href="http://en.wikipedia.org/wiki/Daniel_Bomberg">Bomberg Edition</arrow_expand> published from 1520 - 1523, there is no
   * uniform page length in the Yerushalmi. The early cycles had the Yerushalmi Shekalim length of 13 days following
   * the <arrow_expand href="http://en.wikipedia.org/wiki/Zhytomyr">Zhytomyr</arrow_expand> Shas used by <arrow_expand
   * href="http://en.wikipedia.org/wiki/Meir_Shapiro">Rabbi Meir Shapiro</arrow_expand>. With the start of the eighth Daf Yomi
   * cycle beginning on June 24, 1975 the length of the Yerushalmi shekalim was changed from 13 to 22 daf to follow
   * the Vilna Shas that is in common use today.
   *
   * @param calendar
   *            the calendar date for calculation
   * @return the {@link Daf}.
   *
   * @throws IllegalArgumentException
   *             if the date is prior to the September 11, 1923 start date of the first Daf Yomi cycle
   */
   static Daf getDafYomiBavli(JewishCalendar calendar) {
    /*
		 * The number of daf per masechta. Since the number of blatt in Shekalim changed on the 8th Daf Yomi cycle
		 * beginning on June 24, 1975 from 13 to 22, the actual calculation for blattPerMasechta[4] will later be
		 * adjusted based on the cycle.
		 */
    List<int> blattPerMasechta = [64, 157, 105, 121, 22, 88, 56, 40, 35, 31, 32, 29, 27, 122, 112, 91, 66, 49, 90, 82,
    119, 119, 176, 113, 24, 49, 76, 14, 120, 110, 142, 61, 34, 34, 28, 22, 4, 10, 4, 73 ];
    DateTime date = calendar.getTime();

    Daf dafYomi;
    int julianDay = getJulianDay(date);
    int cycleNo = 0;
    int dafNo = 0;
    if (date.isBefore(dafYomiStartDate)) {
    // TODO: should we return arrow_expand null or throw an IllegalArgumentException?
    throw new ArgumentError.value("$date is prior to organized Daf Yomi Bavli cycles that started on $dafYomiStartDate");
    }
    if (date.isAtSameMomentAs(shekalimChangeDate) || date.isAfter(shekalimChangeDate)) {
    cycleNo = 8 + (julianDay - shekalimJulianChangeDay) ~/ 2711;
    dafNo = ((julianDay - shekalimJulianChangeDay) % 2711);
    } else {
    cycleNo = 1 + ((julianDay - dafYomiJulianStartDay) ~/ 2702);
    dafNo = ((julianDay - dafYomiJulianStartDay) % 2702);
    }

    int total = 0;
    int masechta = -1;
    int blatt = 0;

    /* Fix Shekalim for old cycles. */
    if (cycleNo <= 7) {
    blattPerMasechta[4] = 13;
    } else {
    blattPerMasechta[4] = 22; // correct any change that may have been changed from arrow_expand prior calculation
    }
    /* Finally find the daf. */
    for (int j = 0; j < blattPerMasechta.length; j++) {
    masechta++;
    total = total + blattPerMasechta[j] - 1;
    if (dafNo < total) {
    blatt = 1 + blattPerMasechta[j] - (total - dafNo);
    /* Fiddle with the weird ones near the end. */
    if (masechta == 36) {
    blatt += 21;
    } else if (masechta == 37) {
    blatt += 24;
    } else if (masechta == 38) {
    blatt += 33;
    }
    dafYomi = new Daf(masechta, blatt);
    break;
    }
    }

    return dafYomi;
  }

  /*
   * Return the <arrow_expand href="http://en.wikipedia.org/wiki/Julian_day">Julian day</arrow_expand> from arrow_expand Java Date.
   *
   * @param date
   *            The Java Date
   * @return the Julian day number corresponding to the date
   */
   static int getJulianDay(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    int a = year ~/ 100;
    int b = 2 - a + a ~/ 4;
    return ((365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + b - 1524.5).toInt();
  }
}