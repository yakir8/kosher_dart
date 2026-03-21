/*
 * Zmanim Java API
 * Copyright (C) 2011 - 2019 Eliyahu Hershfeld
 * Copyright (C) September 2002 Avrom Finkelstien
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
import 'package:intl/intl.dart';
import 'package:kosher_dart/src/hebrewcalendar/hebrew_date_formatter.dart';

/// The JewishDate is the base calendar class, that supports maintenance of a [DateTime]
/// instance along with the corresponding Jewish date. This class does not have a concept of a time
/// (which the [DateTime] class does). Please note that the calendar does not currently support dates
/// prior to 1/1/1 Gregorian. Also keep in mind that the Gregorian calendar started on October 15, 1582,
/// so any calculations prior to that are suspect (at least from a Gregorian perspective). While 1/1/1
/// Gregorian and forward are technically supported, any calculations prior to
/// [Hillel II (Hakatan)](http://en.wikipedia.org/wiki/Hillel_II)'s calendar (4119 in the Jewish
/// Calendar / 359 CE Julian as recorded by [Rav Hai Gaon](http://en.wikipedia.org/wiki/Hai_Gaon))
/// would be just an approximation.
///
/// This open source Dart code was ported from the KosherJava Zmanim library originally written by
/// [Avrom Finkelstien](http://www.facebook.com/avromf) in C++ and refactored to Java by Eliyahu
/// Hershfeld, with simplification of the code, enhancements and some bug fixing.
///
/// Some of Avrom's original C++ code was translated from
/// [C/C++ code](https://web.archive.org/web/20120124134148/http://emr.cs.uiuc.edu/~reingold/calendar.C) in
/// [Calendrical Calculations](http://www.calendarists.com) by Nachum Dershowitz and Edward M.
/// Reingold, Software-- Practice & Experience, vol. 20, no. 9 (September, 1990), pp. 899-928. Any
/// method marked "ND+ER" indicates that the method was taken from this source with minor modifications.
///
/// If you are looking for a class that implements a Jewish calendar version of the calendar, one is
/// available from the ICU (International Components for Unicode) project, formerly part of
/// IBM's DeveloperWorks.
///
/// See also [JewishCalendar].
/// See also [HebrewDateFormatter].
/// See also [DateTime].
/// © Avrom Finkelstien 2002
/// © Eliyahu Hershfeld 2011 - 2019

enum Calendar { DATE, MONTH, YEAR }

class JewishDate implements Comparable<JewishDate> {
  /// Value of the month field indicating Nissan, the first numeric month of the year in the Jewish calendar. With the
  /// year starting at [TISHREI], it would actually be the 7th (or 8th in a [isJewishLeapYear]) month of the year.
  static const int NISSAN = 1;

  /// Value of the month field indicating Iyar, the second numeric month of the year in the Jewish calendar. With the
  /// year starting at [TISHREI], it would actually be the 8th (or 9th in a [isJewishLeapYear]) month of the year.
  static const int IYAR = 2;

  /// Value of the month field indicating Sivan, the third numeric month of the year in the Jewish calendar. With the
  /// year starting at [TISHREI], it would actually be the 9th (or 10th in a [isJewishLeapYear]) month of the year.
  static const int SIVAN = 3;

  /// Value of the month field indicating Tammuz, the fourth numeric month of the year in the Jewish calendar. With the
  /// year starting at [TISHREI], it would actually be the 10th (or 11th in a [isJewishLeapYear]) month of the year.
  static const int TAMMUZ = 4;

  /// Value of the month field indicating Av, the fifth numeric month of the year in the Jewish calendar. With the year
  /// starting at [TISHREI], it would actually be the 11th (or 12th in a [isJewishLeapYear])
  /// month of the year.
  static const int AV = 5;

  /// Value of the month field indicating Elul, the sixth numeric month of the year in the Jewish calendar. With the
  /// year starting at [TISHREI], it would actually be the 12th (or 13th in a [isJewishLeapYear]) month of the year.
  static const int ELUL = 6;

  /// Value of the month field indicating Tishrei, the seventh numeric month of the year in the Jewish calendar. With
  /// the year starting at this month, it would actually be the 1st month of the year.
  static const int TISHREI = 7;

  /// Value of the month field indicating Cheshvan/marcheshvan, the eighth numeric month of the year in the Jewish
  /// calendar. With the year starting at [TISHREI], it would actually be the 2nd month of the year.
  static const int CHESHVAN = 8;

  /// Value of the month field indicating Kislev, the ninth numeric month of the year in the Jewish calendar. With the
  /// year starting at [TISHREI], it would actually be the 3rd month of the year.
  static const int KISLEV = 9;

  /// Value of the month field indicating Teves, the tenth numeric month of the year in the Jewish calendar. With the
  /// year starting at [TISHREI], it would actually be the 4th month of the year.
  static const int TEVES = 10;

  /// Value of the month field indicating Shevat, the eleventh numeric month of the year in the Jewish calendar. With
  /// the year starting at [TISHREI], it would actually be the 5th month of the year.
  static const int SHEVAT = 11;

  /// Value of the month field indicating Adar (or Adar I in a [isJewishLeapYear]), the twelfth
  /// numeric month of the year in the Jewish calendar. With the year starting at [TISHREI], it would actually
  /// be the 6th month of the year.
  static const int ADAR = 12;

  /// Value of the month field indicating Adar II, the leap (intercalary or embolismic) thirteenth (Undecimber) numeric
  /// month of the year added in Jewish [isJewishLeapYear]). The leap years are years 3, 6, 8, 11,
  /// 14, 17 and 19 of a 19 year cycle. With the year starting at [TISHREI], it would actually be the 7th month
  /// of the year.
  static const int ADAR_II = 13;

  static const int sunday = 1;
  static const int monday = 2;
  static const int tuesday = 3;
  static const int wednesday = 4;
  static const int thursday = 5;
  static const int friday = 6;
  static const int saturday = 7;

  /// the Jewish epoch using the RD (Rata Die/Fixed Date or Reingold Dershowitz) day used in Calendrical Calculations.
  /// Day 1 is January 1, 0001 Gregorian
  static const int _JEWISH_EPOCH = -1373429;

  /// The number  of _chalakim_ (18) in a minute.
  static const int _CHALAKIM_PER_MINUTE = 18;

  /// The number  of _chalakim_ (1080) in an hour.
  static const int _CHALAKIM_PER_HOUR = 1080;

  /// The number of _chalakim_ (25,920) in a 24 hour day.
  static const int _CHALAKIM_PER_DAY = 25920; // 24 * 1080
  /// The number  of _chalakim_ in an average Jewish month. A month has 29 days, 12 hours and 793
  /// _chalakim_ (44 minutes and 3.3 seconds) for a total of 765,433 _chalakim_
  static const double _CHALAKIM_PER_MONTH =
      765433; // (29 * 24 + 12) * 1080 + 793
  /// Days from the beginning of Sunday till molad BaHaRaD. Calculated as 1 day, 5 hours and 204 chalakim = (24 + 5) *
  /// 1080 + 204 = 31524
  static const int _CHALAKIM_MOLAD_TOHU = 31524;

  /// A short year where both [CHESHVAN] and [KISLEV] are 29 days.
  ///
  /// See also [getCheshvanKislevKviah].
  /// See also [HebrewDateFormatter.getFormattedKviah].
  static const int CHASERIM = 0;

  /// An ordered year where [CHESHVAN] is 29 days and [KISLEV] is 30 days.
  ///
  /// See also [getCheshvanKislevKviah].
  /// See also [HebrewDateFormatter.getFormattedKviah].
  static const int KESIDRAN = 1;

  /// A long year where both [CHESHVAN] and [KISLEV] are 30 days.
  ///
  /// See also [getCheshvanKislevKviah].
  /// See also [HebrewDateFormatter.getFormattedKviah].
  static const int SHELAIMIM = 2;

  /// the internal Jewish month.
  late int _jewishMonth;

  /// the internal Jewish day.
  late int _jewishDay;

  /// the internal Jewish year.
  late int _jewishYear;

  /// the internal count of _molad_ hours.
  late int _moladHours;

  /// the internal count of _molad_ minutes.
  late int _moladMinutes;

  /// the internal count of _molad_ _chalakim_.
  late int _moladChalakim;

  int? _hour;
  int? _minute;
  int? _second;

  /// The month, where 1 == January, 2 == February, etc. Note that the public API uses 0-based months
  /// (0 == January) to match legacy behavior, but this internal field uses 1-based months.
  late int _gregorianMonth;

  /// The day of the Gregorian month
  late int _gregorianDayOfMonth;

  /// The Gregorian year
  late int _gregorianYear;

  /// 1 == Sunday, 2 == Monday, etc...
  late int _dayOfWeek;

  /// Returns the absolute date (days since January 1, 0001 on the Gregorian calendar).
  /// See also [getAbsDate].
  /// See also [absDateToJewishDate].
  late int _gregorianAbsDate;

  /// Default constructor will set a default date to the current system date.
  JewishDate() {
    resetDate();
  }

  /// Creates a Jewish date based on a Jewish year, month and day of month.
  ///
  /// - [jewishYear]:
  ///   the Jewish year
  /// - [jewishMonth]:
  ///   the Jewish month. The method expects a 1 for Nissan ... 12 for Adar and 13 for Adar II. Use the
  ///   constants [NISSAN] ... [ADAR] (or [ADAR_II] for a leap year Adar II) to avoid any
  ///   confusion.
  /// - [jewishDayOfMonth]:
  ///   the Jewish day of month. If 30 is passed in for a month with only 29 days (for example [IYAR],
  ///   or [KISLEV] in a year that [isKislevShort]), the 29th (last valid date of the month)
  ///   will be set
  /// Throws [ArgumentError]
  ///             if the day of month is < 1 or > 30, or a year of < 0 is passed in.
  JewishDate.initDate(
      {required int jewishYear,
      required int jewishMonth,
      required int jewishDayOfMonth,
      int hour = 12,
      int minute = 0,
      int second = 0}) {
    _hour = hour;
    _minute = _minute;
    _second = second;
    setJewishDate(jewishYear, jewishMonth, jewishDayOfMonth);
  }

  /// A constructor that initializes the date to the [DateTime] parameter.
  ///
  /// - [dateTime]:
  ///   the [DateTime] to set the calendar to
  /// Throws [ArgumentError]
  ///             if the date would fall prior to the January 1, 1 AD
  JewishDate.fromDateTime(DateTime dateTime) {
    setDate(dateTime);
  }

  /// Constructor that creates a JewishDate based on a molad passed in. The molad would be the number of chalakim/parts
  /// starting at the beginning of Sunday prior to the molad Tohu BeHaRaD (Be = Monday, Ha= 5 hours and Rad =204
  /// chalakim/parts) - prior to the start of the Jewish calendar. BeHaRaD is 23:11:20 on Sunday night(5 hours 204/1080
  /// chalakim after sunset on Sunday evening).
  ///
  /// - [molad]: the number of chalakim since the beginning of Sunday prior to BaHaRaD
  JewishDate.fromMolad(double molad) {
    _absDateToDate(_moladToAbsDate(molad));
    // long chalakimSince = getChalakimSinceMoladTohu(year, TISHREI);// tishrei
    int conjunctionDay = molad ~/ _CHALAKIM_PER_DAY;
    int conjunctionParts = (molad - conjunctionDay * _CHALAKIM_PER_DAY).toInt();
    _setMoladTime(conjunctionParts);
  }

  /// Returns the molad hours. Only a JewishDate object populated with [getMolad],
  /// [setJewishDate] or [setMoladHours] will have this field
  /// populated. A regular JewishDate object will have this field set to 0.
  ///
  /// Returns the molad hours
  /// See also [setMoladHours].
  /// See also [getMolad].
  /// See also [setJewishDate].
  int getMoladHours() {
    return _moladHours;
  }

  /// Sets the molad hours.
  ///
  /// - [moladHours]:
  ///   the molad hours to set
  /// See also [getMoladHours].
  /// See also [getMolad].
  /// See also [setJewishDate].
  ///
  void setMoladHours(int moladHours) {
    _moladHours = moladHours;
  }

  /// Returns the molad minutes. Only an object populated with [getMolad],
  /// [setJewishDate] or or [setMoladMinutes] will have these fields
  /// populated. A regular JewishDate object will have this field set to 0.
  ///
  /// Returns the molad minutes
  /// See also [setMoladMinutes].
  /// See also [getMolad].
  /// See also [setJewishDate].
  int getMoladMinutes() {
    return _moladMinutes;
  }

  /// Sets the molad minutes. The expectation is that the traditional minute-less chalakim will be broken out to
  /// minutes and [setMoladChalakim] , so 793 (TaShTZaG) parts would have the minutes set to
  /// 44 and chalakim to 1.
  ///
  /// - [moladMinutes]:
  ///   the molad minutes to set
  /// See also [getMoladMinutes].
  /// See also [setMoladChalakim].
  /// See also [getMolad].
  /// See also [setJewishDate].
  ///
  void setMoladMinutes(int moladMinutes) {
    _moladMinutes = moladMinutes;
  }

  /// Sets the molad chalakim/parts. The expectation is that the traditional minute-less chalakim will be broken out to
  /// [setMoladMinutes] and chalakim, so 793 (TaShTZaG) parts would have the minutes set to 44 and
  /// chalakim to 1.
  ///
  /// - [moladChalakim]:
  ///   the molad chalakim/parts to set
  /// See also [getMoladChalakim].
  /// See also [setMoladMinutes].
  /// See also [getMolad].
  /// See also [setJewishDate].
  ///
  void setMoladChalakim(int moladChalakim) {
    _moladChalakim = moladChalakim;
  }

  /// Returns the molad chalakim/parts. Only an object populated with [getMolad],
  /// [setJewishDate] or or [setMoladChalakim] will have these fields
  /// populated. A regular JewishDate object will have this field set to 0.
  ///
  /// Returns the molad chalakim/parts
  /// See also [setMoladChalakim].
  /// See also [getMolad].
  /// See also [setJewishDate].
  int getMoladChalakim() {
    return _moladChalakim;
  }

  /// Returns the last day in a gregorian month
  ///
  /// - [month]:
  ///   the Gregorian month
  /// Returns the last day of the Gregorian month
  int getLastDayOfGregorianMonth(int month) {
    return _getLastDayOfGregorianMonth(month, _gregorianYear);
  }

  /// Returns the number of days in a given month in a given month and year.
  ///
  /// - [month]:
  ///   the month. As with other cases in this class, this is 1-based, not zero-based.
  /// - [year]:
  ///   the year (only impacts February)
  /// Returns the number of days in the month in the given year
  static int _getLastDayOfGregorianMonth(int month, int year) {
    switch (month) {
      case 2:
        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
          return 29;
        } else {
          return 28;
        }
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }

  /// Computes the Gregorian date from the absolute date. ND+ER
  /// - [absDate]: the absolute date
  void _absDateToDate(int absDate) {
    int year =
        absDate ~/ 366; // Search forward year by year from approximate year
    while (absDate >= _gregorianDateToAbsDate(year + 1, 1, 1)) {
      year++;
    }

    int month = 1; // Search forward month by month from January
    while (absDate >
        _gregorianDateToAbsDate(
            year, month, _getLastDayOfGregorianMonth(month, year))) {
      month++;
    }

    int dayOfMonth = absDate - _gregorianDateToAbsDate(year, month, 1) + 1;
    _setInternalGregorianDate(year, month, dayOfMonth);
  }

  /// Returns the absolute date (days since January 1, 0001 on the Gregorian calendar).
  ///
  /// Returns the number of days since January 1, 1
  int getAbsDate() {
    return _gregorianAbsDate;
  }

  /// Computes the absolute date from a Gregorian date. ND+ER
  ///
  /// - [year]:
  ///   the Gregorian year
  /// - [month]:
  ///   the Gregorian month. Unlike the Java Calendar where January has the value of 0,This expects a 1 for
  ///   January
  /// - [dayOfMonth]:
  ///   the day of the month (1st, 2nd, etc...)
  /// Returns the absolute Gregorian day
  static int _gregorianDateToAbsDate(int year, int month, int dayOfMonth) {
    int absDate = dayOfMonth;
    for (int m = month - 1; m > 0; m--) {
      absDate += _getLastDayOfGregorianMonth(
          m, year); // days in prior months of the year
    }
    return absDate // days this year
        +
        365 * (year - 1) // days in previous years ignoring leap days
        +
        (year - 1) ~/ 4 // Julian leap days before this year
        -
        (year - 1) ~/ 100 // minus prior century years
        +
        (year - 1) ~/ 400; // plus prior years divisible by 400
  }

  /// Returns if the year is a Jewish leap year. Years 3, 6, 8, 11, 14, 17 and 19 in the 19 year cycle are leap years.
  ///
  /// - [year]:
  ///   the Jewish year.
  /// Returns true if it is a leap year
  /// See also [isJewishLeapYear].
  static bool _isJewishLeapYear(int year) {
    return ((7 * year) + 1) % 19 < 7;
  }

  /// Returns if the year the calendar is set to is a Jewish leap year. Years 3, 6, 8, 11, 14, 17 and 19 in the 19 year
  /// cycle are leap years.
  ///
  /// Returns true if it is a leap year
  /// See also [isJewishLeapYear].
  bool isJewishLeapYear() {
    return _isJewishLeapYear(getJewishYear());
  }

  /// Returns the last month of a given Jewish year. This will be 12 on a non [isJewishLeapYear]
  /// or 13 on a leap year.
  ///
  /// - [year]:
  ///   the Jewish year.
  /// Returns 12 on a non leap year or 13 on a leap year
  /// See also [isJewishLeapYear].
  static int _getLastMonthOfJewishYear(int year) {
    return _isJewishLeapYear(year) ? ADAR_II : ADAR;
  }

  /// Returns the number of days elapsed from the Sunday prior to the start of the Jewish calendar to the mean
  /// conjunction of Tishri of the Jewish year.
  ///
  /// - [year]:
  ///   the Jewish year
  /// Returns the number of days elapsed from prior to the molad Tohu BaHaRaD (Be = Monday, Ha= 5 hours and Rad =204
  /// chalakim/parts) prior to the start of the Jewish calendar, to the mean conjunction of Tishri of the
  /// Jewish year. BeHaRaD is 23:11:20 on Sunday night(5 hours 204/1080 chalakim after sunset on Sunday
  /// evening).
  static int getJewishCalendarElapsedDays(int year) {
    double chalakimSince = _getChalakimSinceMoladTohu(year, TISHREI);
    int moladDay = chalakimSince ~/ _CHALAKIM_PER_DAY;
    int moladParts = (chalakimSince - moladDay * _CHALAKIM_PER_DAY).toInt();
    // delay Rosh Hashana for the 4 dechiyos
    return _addDechiyos(year, moladDay, moladParts);
  }

  // private static int getJewishCalendarElapsedDaysOLD(int year) {
  // // Jewish lunar month = 29 days, 12 hours and 793 chalakim
  // // Molad Tohu = BeHaRaD - Monday, 5 hours (11 PM) and 204 chalakim
  // final int chalakimTashTZag = 793; // chalakim in a lunar month
  // final int chalakimTohuRaD = 204; // chalakim from original molad Tohu BeHaRaD
  // final int hoursTohuHa = 5; // hours from original molad Tohu BeHaRaD
  // final int dayTohu = 1; // Monday (0 based)
  //
  // int monthsElapsed = (235 * ((year - 1) / 19)) // Months in complete 19 year lunar (Metonic) cycles so far
  // + (12 * ((year - 1) % 19)) // Regular months in this cycle
  // + ((7 * ((year - 1) % 19) + 1) / 19); // Leap months this cycle
  // // start with Molad Tohu BeHaRaD
  // // start with RaD of BeHaRaD and add TaShTzaG (793) chalakim plus elapsed chalakim
  // int partsElapsed = chalakimTohuRaD + chalakimTashTZag * (monthsElapsed % 1080);
  // // start with Ha hours of BeHaRaD, add 12 hour remainder of lunar month add hours elapsed
  // int hoursElapsed = hoursTohuHa + 12 * monthsElapsed + 793 * (monthsElapsed / 1080) + partsElapsed / 1080;
  // // start with Monday of BeHaRaD = 1 (0 based), add 29 days of the lunar months elapsed
  // int conjunctionDay = dayTohu + 29 * monthsElapsed + hoursElapsed / 24;
  // int conjunctionParts = 1080 * (hoursElapsed % 24) + partsElapsed % 1080;
  // return addDechiyos(year, conjunctionDay, conjunctionParts);
  // }

  /// Adds the 4 dechiyos for molad Tishrei. These are:
  ///
  /// - Lo ADU Rosh - Rosh Hashana can't fall on a Sunday, Wednesday or Friday. If the molad fell on one of these
  ///   days, Rosh Hashana is delayed to the following day.
  /// - Molad Zaken - If the molad of Tishrei falls after 12 noon, Rosh Hashana is delayed to the following day. If
  ///   the following day is ADU, it will be delayed an additional day.
  /// - GaTRaD - If on a non leap year the molad of Tishrei falls on a Tuesday (Ga) on or after 9 hours (T) and 204
  ///   chalakim (TRaD) it is delayed till Thursday (one day delay, plus one day for Lo ADU Rosh).
  /// - BeTuTaKFoT - if the year following a leap year falls on a Monday (Be) on or after 15 hours (Tu) and 589
  ///   chalakim (TaKFoT) it is delayed till Tuesday.
  ///
  ///
  /// - [year]: the year
  /// - [moladDay]: the molad day
  /// - [moladParts]: the molad parts
  /// Returns the number of elapsed days in the JewishCalendar adjusted for the 4 dechiyos.
  static int _addDechiyos(int year, int moladDay, int moladParts) {
    int roshHashanaDay = moladDay; // if no dechiyos
    // delay Rosh Hashana for the dechiyos of the Molad - new moon 1 - Molad Zaken, 2- GaTRaD 3- BeTuTaKFoT
    if ((moladParts >=
            19440) // Dechiya of Molad Zaken - molad is >= midday (18 hours * 1080 chalakim)
        ||
        (((moladDay % 7) == 2) // start Dechiya of GaTRaD - Ga = is a Tuesday
            &&
            (moladParts >=
                9924) // TRaD = 9 hours, 204 parts or later (9 * 1080 + 204)
            &&
            !_isJewishLeapYear(
                year)) // of a non-leap year - end Dechiya of GaTRaD
        ||
        (((moladDay % 7) ==
                1) // start Dechiya of BeTuTaKFoT - Be = is on a Monday
            &&
            (moladParts >=
                16789) // TRaD = 15 hours, 589 parts or later (15 * 1080 + 589)
            &&
            (_isJewishLeapYear(year - 1)))) {
      // in a year following a leap year - end Dechiya of BeTuTaKFoT
      roshHashanaDay += 1; // Then postpone Rosh HaShanah one day
    }
    // start 4th Dechiya - Lo ADU Rosh - Rosh Hashana can't occur on A- sunday, D- Wednesday, U - Friday
    if (((roshHashanaDay % 7) == 0) // If Rosh HaShanah would occur on Sunday,
        ||
        ((roshHashanaDay % 7) == 3) // or Wednesday,
        ||
        ((roshHashanaDay % 7) == 5)) {
      // or Friday - end 4th Dechiya - Lo ADU Rosh
      roshHashanaDay = roshHashanaDay + 1; // Then postpone it one (more) day
    }
    return roshHashanaDay;
  }

  /// Returns the number of chalakim (parts - 1080 to the hour) from the original hypothetical Molad Tohu to the year
  /// and month passed in.
  ///
  /// - [year]:
  ///   the Jewish year
  /// - [month]:
  ///   the Jewish month the Jewish month, with the month numbers starting from Nisan. Use the JewishDate
  ///   constants such as [JewishDate.TISHREI].
  /// Returns the number of chalakim (parts - 1080 to the hour) from the original hypothetical Molad Tohu
  static double _getChalakimSinceMoladTohu(int year, int month) {
    // Jewish lunar month = 29 days, 12 hours and 793 chalakim
    // chalakim since Molad Tohu BeHaRaD - 1 day, 5 hours and 204 chalakim
    int monthOfYear = _getJewishMonthOfYear(year, month);
    int monthsElapsed = ((235 *
            ((year - 1) ~/
                19)) // Months in complete 19 year lunar (Metonic) cycles so far
        +
        (12 * ((year - 1) % 19)) // Regular months in this cycle
        +
        ((7 * ((year - 1) % 19) + 1) ~/ 19) // Leap months this cycle
        +
        (monthOfYear -
            1)); // add elapsed months till the start of the molad of the month
    // return chalakim prior to BeHaRaD + number of chalakim since
    return _CHALAKIM_MOLAD_TOHU + (_CHALAKIM_PER_MONTH * monthsElapsed);
  }

  /// Returns the number of chalakim (parts - 1080 to the hour) from the original hypothetical Molad Tohu to the Jewish
  /// year and month that this Object is set to.
  ///
  /// Returns the number of chalakim (parts - 1080 to the hour) from the original hypothetical Molad Tohu
  double getChalakimSinceMoladTohu() {
    return _getChalakimSinceMoladTohu(_jewishYear, _jewishMonth);
  }

  /// Converts the [JewishDate.NISSAN] based constants used by this class to numeric month starting from
  /// [JewishDate.TISHREI]. This is required for Molad claculations.
  ///
  /// - [year]:
  ///   The Jewish year
  /// - [month]:
  ///   The Jewish Month
  /// Returns the Jewish month of the year starting with Tishrei
  static int _getJewishMonthOfYear(int year, int month) {
    bool isLeapYear = _isJewishLeapYear(year);
    return (month + (isLeapYear ? 6 : 5)) % (isLeapYear ? 13 : 12) + 1;
  }

  /// Validates the components of a Jewish date for validity. It will throw an [ArgumentError] if the
  /// Jewish date is earlier than 18 Teves, 3761 (1/1/1 Gregorian), a month < 1 or > 12 (or 13 on a
  /// [isJewishLeapYear]), the day of month is < 1 or > 30, an hour < 0 or > 23, a minute < 0
  /// or > 59 or chalakim < 0 or > 17. For a larger number of chalakim such as 793 (TaShTzaG) break the chalakim into
  /// minutes (18 chalakim per minute, so it would be 44 minutes and 1 chelek in the case of 793/TaShTzaG).
  ///
  /// - [year]:
  ///   the Jewish year to validate. It will reject any year <= 3761 (lower than the year 1 Gregorian).
  /// - [month]:
  ///   the Jewish month to validate. It will reject a month < 1 or > 12 (or 13 on a leap year) .
  /// - [dayOfMonth]:
  ///   the day of the Jewish month to validate. It will reject any value < 1 or > 30 TODO: check calling
  ///   methods to see if there is any reason that the class can validate that 30 is invalid for some months.
  /// - [hours]:
  ///   the hours (for molad calculations). It will reject an hour < 0 or > 23
  /// - [minutes]:
  ///   the minutes (for molad calculations). It will reject a minute < 0 or > 59
  /// - [chalakim]:
  ///   the chalakim/parts (for molad calculations). It will reject a chalakim < 0 or > 17. For larger numbers
  ///   such as 793 (TaShTzaG) break the chalakim into minutes (18 chalakim per minutes, so it would be 44
  ///   minutes and 1 chelek in the case of 793/TaShTzaG)
  ///
  /// Throws [ArgumentError]
  ///             if a A Jewish date earlier than 18 Teves, 3761 (1/1/1 Gregorian), a month < 1 or > 12 (or 13 on a
  ///             leap year), the day of month is < 1 or > 30, an hour < 0 or > 23, a minute < 0 or > 59 or
  ///             chalakim < 0 or > 17. For larger a larger number of chalakim such as 793 (TaShTzaG) break the chalakim
  ///             into minutes (18 chalakim per minutes, so it would be 44 minutes and 1 chelek in the case of 793 (TaShTzaG).
  static void _validateJewishDate(int year, int month, int dayOfMonth,
      int hours, int minutes, int chalakim) {
    if (month < NISSAN || month > _getLastMonthOfJewishYear(year)) {
      throw ArgumentError(
          "The Jewish month has to be between 1 and 12 (or 13 on a leap year). $month is invalid for the year $year.");
    }
    if (dayOfMonth < 1 || dayOfMonth > 30) {
      throw ArgumentError(
          "The Jewish day of month can't be < 1 or > 30.  $dayOfMonth is invalid.");
    }
    // reject dates prior to 18 Teves, 3761 (1/1/1 AD). This restriction can be relaxed if the date coding is
    // changed/corrected
    if ((year < 3761) ||
        (year == 3761 && (month >= TISHREI && month < TEVES)) ||
        (year == 3761 && month == TEVES && dayOfMonth < 18)) {
      throw ArgumentError(
          "A Jewish date earlier than 18 Teves, 3761 (1/1/1 Gregorian) can't be set. $year , $month, $dayOfMonth  is invalid.");
    }
    if (hours < 0 || hours > 23) {
      throw ArgumentError("Hours < 0 or > 23 can't be set. $hours is invalid.");
    }

    if (minutes < 0 || minutes > 59) {
      throw ArgumentError(
          "Minutes < 0 or > 59 can't be set. $minutes is invalid.");
    }

    if (chalakim < 0 || chalakim > 17) {
      throw ArgumentError(
          "Chalakim/parts < 0 or > 17 can't be set. $chalakim is invalid. For larger numbers such as "
          "793 (TaShTzaG) break the chalakim into minutes (18 chalakim per minutes, so it would be "
          "44 minutes and 1 chelek in the case of 793 (TaShTzaG)");
    }
  }

  /// Validates the components of a Gregorian date for validity. It will throw an [ArgumentError] if a
  /// year of < 1, a month < 0 or > 11 or a day of month < 1 is passed in.
  ///
  /// - [year]:
  ///   the Gregorian year to validate. It will reject any year < 1.
  /// - [month]:
  ///   the Gregorian month number to validate. It will enforce that the month is between 0 - 11
  ///   (0 = January), matching the legacy 0-based month convention used by this class.
  /// - [dayOfMonth]:
  ///   the day of the Gregorian month to validate. It will reject any value < 1, but will allow values > 31
  ///   since calling methods will simply set it to the maximum for that month.
  /// Throws [ArgumentError]
  ///             if a year of < 1, a month < 0 or > 11 or a day of month < 1 is passed in
  /// See also [validateGregorianYear].
  /// See also [validateGregorianMonth].
  /// See also [validateGregorianDayOfMonth].
  static void _validateGregorianDate(int year, int month, int dayOfMonth) {
    _validateGregorianMonth(month);
    _validateGregorianDayOfMonth(dayOfMonth);
    _validateGregorianYear(year);
  }

  /// Validates a Gregorian month for validity.
  ///
  /// - [month]:
  ///   the Gregorian month number to validate. It will enforce that the month is between 0 - 11
  ///   (0 = January), matching the legacy 0-based month convention used by this class.
  static void _validateGregorianMonth(int month) {
    if (month > 11 || month < 0) {
      throw ArgumentError(
          "The Gregorian month has to be between 0 - 11. $month is invalid.");
    }
  }

  /// Validates a Gregorian day of month for validity.
  ///
  /// - [dayOfMonth]:
  ///   the day of the Gregorian month to validate. It will reject any value < 1, but will allow values > 31
  ///   since calling methods will simply set it to the maximum for that month. TODO: check calling methods to
  ///   see if there is any reason that the class needs days > the maximum.
  static void _validateGregorianDayOfMonth(int dayOfMonth) {
    if (dayOfMonth <= 0) {
      throw ArgumentError(
          "The day of month can't be less than 1. $dayOfMonth  is invalid.");
    }
  }

  /// Validates a Gregorian year for validity.
  ///
  /// - [year]:
  ///   the Gregorian year to validate. It will reject any year < 1.
  static void _validateGregorianYear(int year) {
    if (year < 1) {
      throw ArgumentError("Years < 1 can't be claculated.  $year  is invalid.");
    }
  }

  /// Returns the number of days for a given Jewish year. ND+ER
  ///
  /// - [year]:
  ///   the Jewish year
  /// Returns the number of days for a given Jewish year.
  /// See also [isCheshvanLong].
  /// See also [isKislevShort].
  static int _getDaysInJewishYear(int year) {
    return getJewishCalendarElapsedDays(year + 1) -
        getJewishCalendarElapsedDays(year);
  }

  /// Returns the number of days for the current year that the calendar is set to.
  ///
  /// Returns the number of days for the Object's current Jewish year.
  /// See also [isCheshvanLong].
  /// See also [isKislevShort].
  /// See also [isJewishLeapYear].
  int getDaysInJewishYear() {
    return _getDaysInJewishYear(getJewishYear());
  }

  /// Returns if Cheshvan is long in a given Jewish year. The method name isLong is done since in a Kesidran (ordered)
  /// year Cheshvan is short. ND+ER
  ///
  /// - [year]:
  ///   the year
  /// Returns true if Cheshvan is long in Jewish year.
  /// See also [isCheshvanLong].
  /// See also [getCheshvanKislevKviah].
  static bool _isCheshvanLong(int year) {
    return _getDaysInJewishYear(year) % 10 == 5;
  }

  /// Returns if Cheshvan is long (30 days VS 29 days) for the current year that the calendar is set to. The method
  /// name isLong is done since in a Kesidran (ordered) year Cheshvan is short.
  ///
  /// Returns true if Cheshvan is long for the current year that the calendar is set to
  /// See also [isCheshvanLong].
  bool isCheshvanLong() {
    return _isCheshvanLong(getJewishYear());
  }

  /// Returns if Kislev is short (29 days VS 30 days) in a given Jewish year. The method name isShort is done since in
  /// a Kesidran (ordered) year Kislev is long. ND+ER
  ///
  /// - [year]:
  ///   the Jewish year
  /// Returns true if Kislev is short for the given Jewish year.
  /// See also [isKislevShort].
  /// See also [getCheshvanKislevKviah].
  static bool _isKislevShort(int year) {
    return _getDaysInJewishYear(year) % 10 == 3;
  }

  /// Returns if the Kislev is short for the year that this class is set to. The method name isShort is done since in a
  /// Kesidran (ordered) year Kislev is long.
  ///
  /// Returns true if Kislev is short for the year that this class is set to
  bool isKislevShort() {
    return _isKislevShort(getJewishYear());
  }

  /// Returns the Cheshvan and Kislev kviah (whether a Jewish year is short, regular or long). It will return
  /// [SHELAIMIM] if both cheshvan and kislev are 30 days, [KESIDRAN] if Cheshvan is 29 days and Kislev
  /// is 30 days and [CHASERIM] if both are 29 days.
  ///
  /// Returns [SHELAIMIM] if both cheshvan and kislev are 30 days, [KESIDRAN] if Cheshvan is 29 days and
  /// Kislev is 30 days and [CHASERIM] if both are 29 days.
  /// See also [isCheshvanLong].
  /// See also [isKislevShort].
  int getCheshvanKislevKviah() {
    if (isCheshvanLong() && !isKislevShort()) {
      return SHELAIMIM;
    } else if (!isCheshvanLong() && isKislevShort()) {
      return CHASERIM;
    } else {
      return KESIDRAN;
    }
  }

  /// Returns the number of days of a Jewish month for a given month and year.
  ///
  /// - [month]:
  ///   the Jewish month
  /// - [year]:
  ///   the Jewish Year
  /// Returns the number of days for a given Jewish month
  static int _getDaysInJewishMonth(int month, int year) {
    if ((month == IYAR) ||
        (month == TAMMUZ) ||
        (month == ELUL) ||
        ((month == CHESHVAN) && !(_isCheshvanLong(year))) ||
        ((month == KISLEV) && _isKislevShort(year)) ||
        (month == TEVES) ||
        ((month == ADAR) && !(_isJewishLeapYear(year))) ||
        (month == ADAR_II)) {
      return 29;
    } else {
      return 30;
    }
  }

  /// Returns the number of days of the Jewish month that the calendar is currently set to.
  ///
  /// Returns the number of days for the Jewish month that the calendar is currently set to.
  int getDaysInJewishMonth() {
    return _getDaysInJewishMonth(getJewishMonth(), getJewishYear());
  }

  /// Computes the Jewish date from the absolute date.
  void _absDateToJewishDate() {
    // Approximation from below
    _jewishYear = (_gregorianAbsDate - _JEWISH_EPOCH) ~/ 366;
    // Search forward for year from the approximation
    while (_gregorianAbsDate >=
        _jewishDateToAbsDate(_jewishYear + 1, TISHREI, 1)) {
      _jewishYear++;
    }
    // Search forward for month from either Tishri or Nisan.
    if (_gregorianAbsDate < _jewishDateToAbsDate(_jewishYear, NISSAN, 1)) {
      _jewishMonth = TISHREI; // Start at Tishri
    } else {
      _jewishMonth = NISSAN; // Start at Nisan
    }
    while (_gregorianAbsDate >
        _jewishDateToAbsDate(
            _jewishYear, _jewishMonth, getDaysInJewishMonth())) {
      _jewishMonth++;
    }
    // Calculate the day by subtraction
    _jewishDay = _gregorianAbsDate -
        _jewishDateToAbsDate(_jewishYear, _jewishMonth, 1) +
        1;
  }

  /// Returns the absolute date of Jewish date. ND+ER
  ///
  /// - [year]:
  ///   the Jewish year. The year can't be negative
  /// - [month]:
  ///   the Jewish month starting with Nisan. Nisan expects a value of 1 etc till Adar with a value of 12. For
  ///   a leap year, 13 will be the expected value for Adar II. Use the constants [JewishDate.NISSAN]
  ///   etc.
  /// - [dayOfMonth]:
  ///   the Jewish day of month. valid values are 1-30. If the day of month is set to 30 for a month that only
  ///   has 29 days, the day will be set as 29.
  /// Returns the absolute date of the Jewish date.
  static int _jewishDateToAbsDate(int year, int month, int dayOfMonth) {
    int elapsed = _getDaysSinceStartOfJewishYear(year, month, dayOfMonth);
    // add elapsed days this year + Days in prior years + Days elapsed before absolute year 1
    return elapsed + getJewishCalendarElapsedDays(year) + _JEWISH_EPOCH;
  }

  /// Returns the molad for a given year and month. Returns a JewishDate [Object] set to the date of the molad
  /// with the [getMoladHours], [getMoladMinutes] and [getMoladChalakim] set. In the current implementation, it sets the molad time based on a midnight date rollover. This
  /// means that Rosh Chodesh Adar II, 5771 with a molad of 7 chalakim past midnight on Shabbos 29 Adar I / March 5,
  /// 2011 12:00 AM and 7 chalakim, will have the following values: hours: 0, minutes: 0, Chalakim: 7.
  ///
  /// Returns a JewishDate [Object] set to the date of the molad with the [getMoladHours],
  /// [getMoladMinutes] and [getMoladChalakim] set.
  JewishDate getMolad() {
    JewishDate moladDate = JewishDate.fromMolad(getChalakimSinceMoladTohu());
    if (moladDate.getMoladHours() >= 6) {
      moladDate.forward(Calendar.DATE, 1);
    }
    moladDate.setMoladHours((moladDate.getMoladHours() + 18) % 24);
    return moladDate;
  }

  /// Returns the number of days from the Jewish epoch from the number of chalakim from the epoch passed in.
  ///
  /// - [chalakim]:
  ///   the number of chalakim since the beginning of Sunday prior to BaHaRaD
  /// Returns the number of days from the Jewish epoch
  static int _moladToAbsDate(double chalakim) {
    return ((chalakim / _CHALAKIM_PER_DAY) + _JEWISH_EPOCH).toInt();
  }

  /// Sets the molad time (hours minutes and chalakim) based on the number of chalakim since the start of the day.
  ///
  /// - [chalakim]:
  ///   the number of chalakim since the start of the day.
  void _setMoladTime(int chalakim) {
    int adjustedChalakim = chalakim;
    setMoladHours(adjustedChalakim ~/ _CHALAKIM_PER_HOUR);
    adjustedChalakim =
        adjustedChalakim - (getMoladHours() * _CHALAKIM_PER_HOUR);
    setMoladMinutes(adjustedChalakim ~/ _CHALAKIM_PER_MINUTE);
    setMoladChalakim(adjustedChalakim - _moladMinutes * _CHALAKIM_PER_MINUTE);
  }

  /// returns the number of days from Rosh Hashana of the date passed in, to the full date passed in.
  ///
  /// - [year]:
  ///   the Jewish year
  /// - [month]:
  ///   the Jewish month
  /// - [dayOfMonth]:
  ///   the day in the Jewish month
  /// Returns the number of days
  static int _getDaysSinceStartOfJewishYear(
      int year, int month, int dayOfMonth) {
    int elapsedDays = dayOfMonth;
    // Before Tishrei (from Nissan to Tishrei), add days in prior months
    if (month < TISHREI) {
      // this year before and after Nisan.
      for (int m = TISHREI; m <= _getLastMonthOfJewishYear(year); m++) {
        elapsedDays += _getDaysInJewishMonth(m, year);
      }
      for (int m = NISSAN; m < month; m++) {
        elapsedDays += _getDaysInJewishMonth(m, year);
      }
    } else {
      // Add days in prior months this year
      for (int m = TISHREI; m < month; m++) {
        elapsedDays += _getDaysInJewishMonth(m, year);
      }
    }
    return elapsedDays;
  }

  /// returns the number of days from Rosh Hashana of the date passed in, to the full date passed in.
  ///
  /// Returns the number of days
  int getDaysSinceStartOfJewishYear() {
    return _getDaysSinceStartOfJewishYear(
        getJewishYear(), getJewishMonth(), getJewishDayOfMonth());
  }

  /// Sets the date based on a [DateTime] object. Modifies the Jewish date as well.
  ///
  /// - [dateTime]:
  ///   the [DateTime] to set the calendar to
  /// Throws [ArgumentError]
  ///             if the date is in the BC era
  void setDate(DateTime dateTime) {
    if (DateFormat('G').format(dateTime) == 'BC') {
      throw ArgumentError(
          "Calendars with arrow_expand BC era are not supported. The year ${dateTime.year}  BC is invalid.");
    }
    _gregorianMonth = dateTime.month;
    _gregorianDayOfMonth = dateTime.day;
    _gregorianYear = dateTime.year;
    _hour = dateTime.hour;
    _minute = dateTime.minute;
    _second = dateTime.second;
    _gregorianAbsDate = _gregorianDateToAbsDate(
        _gregorianYear, _gregorianMonth, _gregorianDayOfMonth); // init the date
    _absDateToJewishDate();

    _dayOfWeek = (_gregorianAbsDate % 7).abs() + 1; // set day of week
  }

  /// Sets the Gregorian Date, and updates the Jewish date accordingly. A value of 0 is expected
  /// for January (0-based months).
  ///
  /// - [year]:
  ///   the Gregorian year
  /// - [month]:
  ///   the Gregorian month. This class expects 0 for January (0-based)
  /// - [dayOfMonth]:
  ///   the Gregorian day of month. If this is > the number of days in the month/year, the last valid date of
  ///   the month will be set
  /// Throws [ArgumentError]
  ///             if a year of < 1, a month < 0 or > 11 or a day of month < 1 is passed in
  void setGregorianDate(int year, int month, int dayOfMonth) {
    _validateGregorianDate(year, month, dayOfMonth);
    _setInternalGregorianDate(year, month + 1, dayOfMonth);
  }

  /// Sets the hidden internal representation of the Gregorian date and updates the Jewish date accordingly. While
  /// public getters and setters have 0-based months (0 = January), this class internally represents the Gregorian
  /// month starting at 1. When this is called it will not adjust the month to the 0-based convention.
  ///
  /// - [year]: the year
  /// - [month]: the month
  /// - [dayOfMonth]: the day of month
  void _setInternalGregorianDate(int year, int month, int dayOfMonth) {
    // make sure date is a valid date for the given month, if not, set to last day of month
    if (dayOfMonth > _getLastDayOfGregorianMonth(month, year)) {
      dayOfMonth = _getLastDayOfGregorianMonth(month, year);
    }
    // init month, date, year
    _gregorianMonth = month;
    _gregorianDayOfMonth = dayOfMonth;
    _gregorianYear = year;

    _gregorianAbsDate = _gregorianDateToAbsDate(
        _gregorianYear, _gregorianMonth, _gregorianDayOfMonth); // init date
    _absDateToJewishDate();

    _dayOfWeek = (_gregorianAbsDate % 7).abs() + 1; // set day of week
  }

  /// Sets the Jewish Date and updates the Gregorian date accordingly.
  ///
  /// - [year]:
  ///   the Jewish year. The year can't be negative
  /// - [month]:
  ///   the Jewish month starting with Nisan. A value of 1 is expected for Nissan ... 12 for Adar and 13 for
  ///   Adar II. Use the constants [NISSAN] ... [ADAR] (or [ADAR_II] for a leap year Adar
  ///   II) to avoid any confusion.
  /// - [dayOfMonth]:
  ///   the Jewish day of month. valid values are 1-30. If the day of month is set to 30 for a month that only
  ///   has 29 days, the day will be set as 29.
  ///
  /// - [hours]:
  ///   the hour of the day. Used for Molad calculations
  /// - [minutes]:
  ///   the minutes. Used for Molad calculations
  /// - [chalakim]:
  ///   the chalakim/parts. Used for Molad calculations. The chalakim should not exceed 17. Minutes should be
  ///   used for larger numbers.
  ///
  /// Throws [ArgumentError]
  ///             if a A Jewish date earlier than 18 Teves, 3761 (1/1/1 Gregorian), a month < 1 or > 12 (or 13 on a
  ///             leap year), the day of month is < 1 or > 30, an hour < 0 or > 23, a minute < 0 > 59 or chalakim < 0 >
  ///             17. For larger a larger number of chalakim such as 793 (TaShTzaG) break the chalakim into minutes (18
  ///             chalakim per minutes, so it would be 44 minutes and 1 chelek in the case of 793 (TaShTzaG).
  void setJewishDate(int year, int month, int dayOfMonth,
      [int hours = 0, int minutes = 0, int chalakim = 0]) {
    _validateJewishDate(year, month, dayOfMonth, hours, minutes, chalakim);

    // if 30 is passed for a month that only has 29 days (for example by rolling the month from a month that had 30
    // days to a month that only has 29) set the date to 29th
    if (dayOfMonth > _getDaysInJewishMonth(month, year)) {
      dayOfMonth = _getDaysInJewishMonth(month, year);
    }

    _jewishMonth = month;
    _jewishDay = dayOfMonth;
    _jewishYear = year;
    _moladHours = hours;
    _moladMinutes = minutes;
    _moladChalakim = chalakim;

    _gregorianAbsDate = _jewishDateToAbsDate(
        _jewishYear, _jewishMonth, _jewishDay); // reset Gregorian date
    _absDateToDate(_gregorianAbsDate);

    _dayOfWeek = (_gregorianAbsDate % 7).abs() + 1; // reset day of week
  }

  /// Returns this object's date as a [DateTime] object.
  ///
  /// Returns The [DateTime]
  DateTime getGregorianCalendar() {
    return DateTime.utc(getGregorianYear(), getGregorianMonth(),
        getGregorianDayOfMonth(), _hour ?? 12, _minute ?? 0, _second ?? 0);
  }

  /// Resets this date to the current system date.
  void resetDate() {
    setDate(DateTime.now());
  }

  /// Returns a string containing the Jewish date in the form, "day Month, year" e.g. "21 Shevat, 5729". For more
  /// complex formatting, use the formatter classes.
  ///
  /// Returns the Jewish date in the form "day Month, year" e.g. "21 Shevat, 5729"
  /// See also [HebrewDateFormatter.format].
  @override
  String toString() {
    return HebrewDateFormatter().format(this);
  }

  /// Rolls the date, month or year forward by the amount passed in. It modifies both the Gregorian and Jewish
  /// dates accordingly. If manipulation beyond the fields supported here is required, use [DateTime] arithmetic
  /// and pass the result back via [setDate]. For example:
  ///
  /// ```dart
  /// DateTime cal = jewishDate.getGregorianCalendar();
  /// cal = DateTime(cal.year, cal.month + 3, cal.day); // add 3 Gregorian months
  /// jewishDate.setDate(cal); // set the updated calendar back to this class
  /// ```
  ///
  /// - [field]: the calendar field to be forwarded. Must be [Calendar.DATE], [Calendar.MONTH] or [Calendar.YEAR]
  /// - [amount]: the positive amount to move forward
  /// Throws [ArgumentError] if the field is anything besides [Calendar.DATE], [Calendar.MONTH] or [Calendar.YEAR]
  /// or if the amount is less than 1
  ///
  /// See also [back].
  void forward([Calendar field = Calendar.DATE, int amount = 1]) {
    if (field != Calendar.DATE &&
        field != Calendar.MONTH &&
        field != Calendar.YEAR) {
      throw ArgumentError(
          "Unsupported field was passed to Forward. Only Calendar.DATE, Calendar.MONTH or Calendar.YEAR are supported.");
    }
    if (amount < 1) {
      throw ArgumentError(
          "JewishDate.forward() does not support amounts less than 1. See JewishDate.back()");
    }
    if (field == Calendar.DATE) {
      // Change Gregorian date
      for (int i = 0; i < amount; i++) {
        if (_gregorianDayOfMonth ==
            _getLastDayOfGregorianMonth(_gregorianMonth, _gregorianYear)) {
          _gregorianDayOfMonth = 1;
          // if last day of year
          if (_gregorianMonth == 12) {
            _gregorianYear++;
            _gregorianMonth = 1;
          } else {
            _gregorianMonth++;
          }
        } else {
          // if not last day of month
          _gregorianDayOfMonth++;
        }

        // Change the Jewish Date
        if (_jewishDay == getDaysInJewishMonth()) {
          // if it last day of elul (i.e. last day of Jewish year)
          if (_jewishMonth == ELUL) {
            _jewishYear++;
            _jewishMonth++;
            _jewishDay = 1;
          } else if (_jewishMonth == _getLastMonthOfJewishYear(_jewishYear)) {
            // if it is the last day of Adar, or Adar II as case may be
            _jewishMonth = NISSAN;
            _jewishDay = 1;
          } else {
            _jewishMonth++;
            _jewishDay = 1;
          }
        } else {
          // if not last date of month
          _jewishDay++;
        }

        if (_dayOfWeek == 7) {
          // if last day of week, loop back to Sunday
          _dayOfWeek = 1;
        } else {
          _dayOfWeek++;
        }

        _gregorianAbsDate++; // increment the absolute date
      }
    } else if (field == Calendar.MONTH) {
      _forwardJewishMonth(amount);
    } else if (field == Calendar.YEAR) {
      setJewishYear(getJewishYear() + amount);
    }
  }

  /// Forward the Jewish date by the number of months passed in.
  /// FIXME: Deal with forwarding a date such as 30 Nisan by a month. 30 Iyar does not exist. This should be dealt with similar to
  /// the way that the Java Calendar behaves (not that simple since there is a difference between add() or roll().
  ///
  /// Throws [ArgumentError] if the amount is less than 1
  /// - [amount]: the number of months to roll the month forward
  void _forwardJewishMonth(int amount) {
    if (amount < 1) {
      throw ArgumentError(
          "the amount of months to forward has to be greater than zero.");
    }
    for (int i = 0; i < amount; i++) {
      if (getJewishMonth() == ELUL) {
        setJewishMonth(TISHREI);
        setJewishYear(getJewishYear() + 1);
      } else if ((!isJewishLeapYear() && getJewishMonth() == ADAR) ||
          (isJewishLeapYear() && getJewishMonth() == ADAR_II)) {
        setJewishMonth(NISSAN);
      } else {
        setJewishMonth(getJewishMonth() + 1);
      }
    }
  }

  /// Rolls the Jewish date back by the number of months passed in.
  /// This modifies both the Gregorian and Jewish dates accordingly.
  /// If the day of the month is invalid for the new month (e.g., 30 Tishrei rolling back to 30 Elul,
  /// which has 29 days), the day is adjusted to the last valid day of the new month.
  ///
  /// - [amount]: the number of months to roll the month backward
  /// Throws [ArgumentError] if the amount is less than 1
  void _backwardJewishMonth(int amount) {
    if (amount < 1) {
      throw ArgumentError(
          "the amount of months to backward has to be greater than zero.");
    }
    for (int i = 0; i < amount; i++) {
      if (getJewishMonth() == TISHREI) {
        // If Tishrei, move to Elul of the previous year
        setJewishYear(getJewishYear() - 1);
        setJewishMonth(ELUL);
      } else if (getJewishMonth() == NISSAN) {
        // If Nissan, move to Adar (non-leap year) or Adar II (leap year)
        setJewishMonth(_getLastMonthOfJewishYear(getJewishYear()));
      } else {
        // Otherwise, move to the previous month
        setJewishMonth(getJewishMonth() - 1);
      }
    }
  }

  /// Rolls the date back by the specified field and amount. Supports [Calendar.DATE] (default),
  /// [Calendar.MONTH], and [Calendar.YEAR].
  ///
  /// When rolling back by [Calendar.DATE], it modifies both the Gregorian and Jewish dates accordingly.
  /// When rolling back by [Calendar.MONTH], it calls [_backwardJewishMonth].
  /// When rolling back by [Calendar.YEAR], it decrements the Jewish year.
  ///
  /// - [field]: the calendar field to roll back. Must be [Calendar.DATE], [Calendar.MONTH], or [Calendar.YEAR]
  /// - [amount]: the positive number of units to roll back (defaults to 1)
  /// Throws [ArgumentError] if the field is unsupported or the amount is less than 1
  ///
  /// See also [forward].
  void back([Calendar field = Calendar.DATE, int amount = 1]) {
    if (field == Calendar.MONTH) {
      _backwardJewishMonth(amount);
      return;
    } else if (field == Calendar.YEAR) {
      setJewishYear(getJewishYear() - amount);
      return;
    } else if (field != Calendar.DATE) {
      throw ArgumentError(
          "Unsupported field was passed to back(). Only Calendar.DATE, Calendar.MONTH or Calendar.YEAR are supported.");
    }
    if (amount < 1) {
      throw ArgumentError(
          "JewishDate.back() does not support amounts less than 1. See JewishDate.forward()");
    }
    for (int i = 0; i < amount; i++) {
      // Change Gregorian date
      if (_gregorianDayOfMonth == 1) {
        // if first day of month
        if (_gregorianMonth == 1) {
          // if first day of year
          _gregorianMonth = 12;
          _gregorianYear--;
        } else {
          _gregorianMonth--;
        }
        // change to last day of previous month
        _gregorianDayOfMonth =
            _getLastDayOfGregorianMonth(_gregorianMonth, _gregorianYear);
      } else {
        _gregorianDayOfMonth--;
      }
      // change Jewish date
      if (_jewishDay == 1) {
        // if first day of the Jewish month
        if (_jewishMonth == NISSAN) {
          _jewishMonth = _getLastMonthOfJewishYear(_jewishYear);
        } else if (_jewishMonth == TISHREI) {
          // if Rosh Hashana
          _jewishYear--;
          _jewishMonth--;
        } else {
          _jewishMonth--;
        }
        _jewishDay = getDaysInJewishMonth();
      } else {
        _jewishDay--;
      }

      if (_dayOfWeek == 1) {
        // if first day of week, loop back to Saturday
        _dayOfWeek = 7;
      } else {
        _dayOfWeek--;
      }
      _gregorianAbsDate--; // change the absolute date
    }
  }

  /// Two [JewishDate] objects are equal if they represent the same absolute date.
  @override
  bool operator ==(Object object) {
    if (identical(this, object)) {
      return true;
    }
    if (object is! JewishDate) {
      return false;
    }
    JewishDate jewishDate = object;
    return _gregorianAbsDate == jewishDate.getAbsDate();
  }

  /// Compares two dates as per the compareTo() method in the Comparable interface. Returns a value less than 0 if this
  /// date is "less than" (before) the date, greater than 0 if this date is "greater than" (after) the date, or 0 if
  /// they are equal.
  @override
  int compareTo(JewishDate jewishDate) {
    return _gregorianAbsDate < jewishDate.getAbsDate()
        ? -1
        : _gregorianAbsDate > jewishDate.getAbsDate()
            ? 1
            : 0;
  }

  /// Returns the Gregorian month (between 0-11).
  ///
  /// Returns the Gregorian month (between 0-11). Note: this class uses 0-based months (0 = January)
  /// for its public API, unlike [DateTime] which uses 1-based months.
  int getGregorianMonth() {
    return _gregorianMonth;
  }

  /// Returns the Gregorian day of the month.
  ///
  /// Returns the Gregorian day of the mont
  int getGregorianDayOfMonth() {
    return _gregorianDayOfMonth;
  }

  /// Returns the Gregorian year.
  ///
  /// Returns the Gregorian year
  int getGregorianYear() {
    return _gregorianYear;
  }

  /// Returns the Jewish month 1-12 (or 13 years in a leap year). The month count starts with 1 for Nisan and goes to
  /// 13 for Adar II
  ///
  /// Returns the Jewish month from 1 to 12 (or 13 years in a leap year). The month count starts with 1 for Nisan and
  /// goes to 13 for Adar II
  int getJewishMonth() {
    return _jewishMonth;
  }

  /// Returns the Jewish day of month.
  ///
  /// Returns the Jewish day of the month
  int getJewishDayOfMonth() {
    return _jewishDay;
  }

  /// Returns the Jewish year.
  ///
  /// Returns the Jewish year
  int getJewishYear() {
    return _jewishYear;
  }

  /// Returns the day of the week as a number between 1-7.
  ///
  /// Returns the day of the week as a number between 1-7.
  int getDayOfWeek() {
    return _dayOfWeek;
  }

  /// Sets the Gregorian month.
  ///
  /// - [month]:
  ///   the Gregorian month
  ///
  /// Throws [ArgumentError]
  ///             if a month < 0 or > 11 is passed in
  void setGregorianMonth(int month) {
    _validateGregorianMonth(month);
    _setInternalGregorianDate(_gregorianYear, month + 1, _gregorianDayOfMonth);
  }

  /// sets the Gregorian year.
  ///
  /// - [year]:
  ///   the Gregorian year.
  /// Throws [ArgumentError]
  ///             if a year of < 1 is passed in
  void setGregorianYear(int year) {
    _validateGregorianYear(year);
    _setInternalGregorianDate(year, _gregorianMonth, _gregorianDayOfMonth);
  }

  /// sets the Gregorian Day of month.
  ///
  /// - [dayOfMonth]:
  ///   the Gregorian Day of month.
  /// Throws [ArgumentError]
  ///             if the day of month of < 1 is passed in
  void setGregorianDayOfMonth(int dayOfMonth) {
    _validateGregorianDayOfMonth(dayOfMonth);
    _setInternalGregorianDate(_gregorianYear, _gregorianMonth, dayOfMonth);
  }

  /// sets the Jewish month.
  ///
  /// - [month]:
  ///   the Jewish month from 1 to 12 (or 13 years in a leap year). The month count starts with 1 for Nisan
  ///   and goes to 13 for Adar II
  /// Throws [ArgumentError]
  ///             if a month < 1 or > 12 (or 13 on a leap year) is passed in
  void setJewishMonth(int month) {
    setJewishDate(_jewishYear, month, _jewishDay);
  }

  /// sets the Jewish year.
  ///
  /// - [year]:
  ///   the Jewish year
  /// Throws [ArgumentError]
  ///             if a year of < 3761 is passed in. The same will happen if the year is 3761 and the month and day
  ///             previously set are < 18 Teves (prior to Jan 1, 1 AD)
  void setJewishYear(int year) {
    setJewishDate(year, _jewishMonth, _jewishDay);
  }

  /// sets the Jewish day of month.
  ///
  /// - [dayOfMonth]:
  ///   the Jewish day of month
  /// Throws [ArgumentError]
  ///             if the day of month is < 1 or > 30 is passed in
  void setJewishDayOfMonth(int dayOfMonth) {
    setJewishDate(_jewishYear, _jewishMonth, dayOfMonth);
  }

  /// Returns is the year passed in is a [Gregorian leap year](https://en.wikipedia.org/wiki/Leap_year#Gregorian_calendar).
  /// - [year]: the Gregorian year
  /// Returns if the year in question is a leap year.
  bool isGregorianLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Creates a [deep copy](http://en.wikipedia.org/wiki/Object_copy#Deep_copy) of this object.
  JewishDate clone() {
    JewishDate clone = JewishDate();
    clone.setGregorianDate(
        _gregorianYear, _gregorianMonth - 1, _gregorianDayOfMonth);
    return clone;
  }

  /// Returns a hash code based on the absolute Gregorian date.
  @override
  int get hashCode {
    int result = 17;
    result = 37 * result +
        runtimeType
            .hashCode; // needed or this and subclasses will return identical hash
    result += 37 * result + _gregorianAbsDate;
    return result;
  }
}
