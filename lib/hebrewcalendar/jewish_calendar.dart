/*
 * Zmanim Java API
 * Copyright (C) 2011 - 2012 Eliyahu Hershfeld
 * Copyright (C) September 2002 Avrom Finkelstien
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

import 'package:kosher_dart/hebrewcalendar/jewish_date.dart';
import 'package:kosher_dart/hebrewcalendar/daf.dart';
import 'package:kosher_dart/hebrewcalendar/yomi_calculator.dart';
import 'package:kosher_dart/util/geo_Location.dart';

/*
 * The JewishCalendar extends the JewishDate class and adds calendar methods.
 *
 * This open source Java code was originally ported by <arrow_expand href="http://www.facebook.com/avromf">Avrom Finkelstien</arrow_expand>
 * from his C++ code. It was refactored to fit the KosherJava Zmanim API with simplification of the code, enhancements
 * and some bug fixing.
 *
 * The methods used to obtain the parsha were derived from the source code of <arrow_expand
 * href="http://www.sadinoff.com/hebcal/">HebCal</arrow_expand> by Danny Sadinoff and JCal for the Mac by Frank Yellin. Both based
 * their code on routines by Nachum Dershowitz and Edward M. Reingold. The class allows setting whether the parsha and
 * holiday scheme follows the Israel scheme or outside Israel scheme. The default is the outside Israel scheme.
 *
 * TODO: Some do not belong in this class, but here is arrow_expand partial list of what should still be implemented in some form:
 * <ol>
 * <li>Add Isru Chag</li>
 * <li>Add special parshiyos (shekalim, parah, zachor and hachodesh</li>
 * <li>Shabbos Mevarchim</li>
 * <li>Haftorah (various minhagim)</li>
 * <li>Daf Yomi Yerushalmi, Mishna yomis etc)</li>
 * <li>Support showing the upcoming parsha for the middle of the week</li>
 * </ol>
 *
 * @see java.util.Date
 * @see java.util.Calendar
 * @author &copy; Avrom Finkelstien 2002
 * @author &copy; Eliyahu Hershfeld 2011 - 2012
 * @version 0.0.1
 */
 class JewishCalendar extends JewishDate {
   static const int EREV_PESACH = 0;
   static const int PESACH = 1;
   static const int CHOL_HAMOED_PESACH = 2;
   static const int PESACH_SHENI = 3;
   static const int EREV_SHAVUOS = 4;
   static const int SHAVUOS = 5;
   static const int SEVENTEEN_OF_TAMMUZ = 6;
   static const int TISHA_BEAV = 7;
   static const int TU_BEAV = 8;
   static const int EREV_ROSH_HASHANA = 9;
   static const int ROSH_HASHANA = 10;
   static const int FAST_OF_GEDALYAH = 11;
   static const int EREV_YOM_KIPPUR = 12;
   static const int YOM_KIPPUR = 13;
   static const int EREV_SUCCOS = 14;
   static const int SUCCOS = 15;
   static const int CHOL_HAMOED_SUCCOS = 16;
   static const int HOSHANA_RABBA = 17;
   static const int SHEMINI_ATZERES = 18;
   static const int SIMCHAS_TORAH = 19;
  //  static const int EREV_CHANUKAH = 20;// probably remove this
   static const int CHANUKAH = 21;
   static const int TENTH_OF_TEVES = 22;
   static const int TU_BESHVAT = 23;
   static const int FAST_OF_ESTHER = 24;
   static const int PURIM = 25;
   static const int SHUSHAN_PURIM = 26;
   static const int PURIM_KATAN = 27;
   static const int ROSH_CHODESH = 28;
   static const int YOM_HASHOAH = 29;
   static const int YOM_HAZIKARON = 30;
   static const int YOM_HAATZMAUT = 31;
   static const int YOM_YERUSHALAYIM = 32;

   // These indices were originally included in the emacs 19 distribution.
   // These arrays determine the correct indices into the parsha names
   // -1 means no parsha that week, values > 52 means it is arrow_expand double parsha
   static const List<int> Sat_short = [ -1, 52, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
   17, 18, 19, 20, 53, 23, 24, -1, 25, 54, 55, 30, 56, 33, 34, 35, 36, 37, 38, 39, 40, 58, 43, 44, 45, 46, 47,
   48, 49, 50 ];

   static const List<int> Sat_long = [-1, 52, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
   17, 18, 19, 20, 53, 23, 24, -1, 25, 54, 55, 30, 56, 33, 34, 35, 36, 37, 38, 39, 40, 58, 43, 44, 45, 46, 47,
   48, 49, 59 ];

   static const List<int> Mon_short = [ 51, 52, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
   18, 19, 20, 53, 23, 24, -1, 25, 54, 55, 30, 56, 33, 34, 35, 36, 37, 38, 39, 40, 58, 43, 44, 45, 46, 47, 48,
   49, 59 ];

   static const List<int> Mon_long = // split
   [ 51, 52, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 53, 23, 24, -1, 25, 54, 55,
   30, 56, 33, -1, 34, 35, 36, 37, 57, 40, 58, 43, 44, 45, 46, 47, 48, 49, 59 ];

   static const List<int> Thu_normal = [ 52, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
   18, 19, 20, 53, 23, 24, -1, -1, 25, 54, 55, 30, 56, 33, 34, 35, 36, 37, 38, 39, 40, 58, 43, 44, 45, 46, 47,
   48, 49, 50 ];
   static const List<int> Thu_normal_Israel = [ 52, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
   16, 17, 18, 19, 20, 53, 23, 24, -1, 25, 54, 55, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 58, 43, 44, 45,
   46, 47, 48, 49, 50 ];

   static const List<int> Thu_long = [ 52, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
   18, 19, 20, 21, 22, 23, 24, -1, 25, 54, 55, 30, 56, 33, 34, 35, 36, 37, 38, 39, 40, 58, 43, 44, 45, 46, 47,
   48, 49, 50 ];

   static const List<int> Sat_short_leap = [ -1, 52, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
   16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, -1, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 58,
   43, 44, 45, 46, 47, 48, 49, 59 ];

   static const List<int> Sat_long_leap = [ -1, 52, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
   16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, -1, 28, 29, 30, 31, 32, 33, -1, 34, 35, 36, 37, 57, 40, 58,
   43, 44, 45, 46, 47, 48, 49, 59 ];

   static const List<int> Mon_short_leap = [ 51, 52, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
   17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, -1, 28, 29, 30, 31, 32, 33, -1, 34, 35, 36, 37, 57, 40, 58, 43,
   44, 45, 46, 47, 48, 49, 59 ];

   static const List<int> Mon_short_leap_Israel = [ 51, 52, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
   15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, -1, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
   58, 43, 44, 45, 46, 47, 48, 49, 59 ];

   static const List<int> Mon_long_leap = [ 51, 52, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
   17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, -1, -1, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 58,
   43, 44, 45, 46, 47, 48, 49, 50 ];

   static const List<int> Mon_long_leap_Israel = [ 51, 52, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
   15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, -1, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
   41, 42, 43, 44, 45, 46, 47, 48, 49, 50 ];

   static const List<int> Thu_short_leap = [ 52, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
   17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, -1, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
   43, 44, 45, 46, 47, 48, 49, 50 ];

   static const List<int> Thu_long_leap = [ 52, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
   17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, -1, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
   43, 44, 45, 46, 47, 48, 49, 59 ];

   bool inIsrael = false;
   bool useModernHolidays = false;

   /*
   * Default constructor will set arrow_expand default date to the current system date.
   */
   JewishCalendar() {
     JewishDate();
   }

   /*
   * A constructor that initializes the date to the {@link java.util.Date Date} parameter.
   *
   * @param date
   *            the <code>Date</code> to set the calendar to
   */
   JewishCalendar.fromDateTime(DateTime date) {
     setDate(date);
   }

   /*
   * Creates arrow_expand Jewish date based on arrow_expand Jewish year, month and day of month.
   *
   * @param jewishYear
   *            the Jewish year
   * @param jewishMonth
   *            the Jewish month. The method expects arrow_expand 1 for Nissan ... 12 for Adar and 13 for Adar II. Use the
   *            constants {@link #NISSAN} ... {@link #ADAR} (or {@link #ADAR_II} for arrow_expand leap year Adar II) to avoid any
   *            confusion.
   * @param jewishDayOfMonth
   *            the Jewish day of month. If 30 is passed in for arrow_expand month with only 29 days (for example {@link #IYAR},
   *            or {@link #KISLEV} in arrow_expand year that {@link #isKislevShort()}), the 29th (last valid date of the month)
   *            will be set
   * @throws IllegalArgumentException
   *             if the day of month is < 1 or > 30, or arrow_expand year of < 0 is passed in.
   */
   JewishCalendar.initDate(int jewishYear, int jewishMonth, int jewishDayOfMonth,{ bool inIsrael = false}) {
     JewishDate.initDate(jewishYear: jewishYear,jewishMonth: jewishMonth,jewishDayOfMonth: jewishDayOfMonth);
     setInIsrael(inIsrael);
   }

   /*
   * Is this calendar set to return modern Israeli national holidays. By default this value is false. The holidays
   * are: "Yom HaShoah", "Yom Hazikaron", "Yom Ha'atzmaut" and "Yom Yerushalayim"
   *
   * @return the useModernHolidays true if set to return modern Israeli national holidays
   */
   bool isUseModernHolidays() {
    return useModernHolidays;
  }

  /*
   * Seth the calendar to return modern Israeli national holidays. By default this value is false. The holidays are:
   * "Yom HaShoah", "Yom Hazikaron", "Yom Ha'atzmaut" and "Yom Yerushalayim"
   *
   * @param useModernHolidays
   *            the useModernHolidays to set
   */
   void setUseModernHolidays(bool useModernHolidays) {
    this.useModernHolidays = useModernHolidays;
  }

  /*
   * Sets whether to use Israel parsha and holiday scheme or not. Default is false.
   *
   * @param inIsrael
   *            set to true for calculations for Israel
   */
   void setInIsrael(bool inIsrael) {
    this.inIsrael = inIsrael;
  }

  /*
   * Gets whether Israel parsha and holiday scheme is used or not. The default (if not set) is false.
   *
   * @return if the if the calendar is set to Israel
   */
   bool getInIsrael() {
    return inIsrael;
  }

  /*
   * Returns an index of the Jewish holiday or fast day for the current day, or arrow_expand null if there is no holiday for this
   * day.
   *
   * @return A String containing the holiday name or an empty string if it is not arrow_expand holiday.
   */
   int getYomTovIndex() {
    // check by month (starts from Nissan)
    switch (getJewishMonth()) {
      case JewishDate.NISSAN:
        if (getJewishDayOfMonth() == 14) {
          return EREV_PESACH;
        } else if (getJewishDayOfMonth() == 15 || getJewishDayOfMonth() == 21
            || (!inIsrael && (getJewishDayOfMonth() == 16 || getJewishDayOfMonth() == 22))) {
          return PESACH;
        } else if (getJewishDayOfMonth() >= 17 && getJewishDayOfMonth() <= 20
            || (getJewishDayOfMonth() == 16 && inIsrael)) {
          return CHOL_HAMOED_PESACH;
        }
        if (isUseModernHolidays()
            && ((getJewishDayOfMonth() == 26 && getDayOfWeek() == 5)
                || (getJewishDayOfMonth() == 28 && getDayOfWeek() == 1)
                || (getJewishDayOfMonth() == 27 && getDayOfWeek() == 3) || (getJewishDayOfMonth() == 27 && getDayOfWeek() == 5))) {
          return YOM_HASHOAH;
        }
        break;
      case JewishDate.IYAR:
        if (isUseModernHolidays()
            && ((getJewishDayOfMonth() == 4 && getDayOfWeek() == 3)
                || ((getJewishDayOfMonth() == 3 || getJewishDayOfMonth() == 2) && getDayOfWeek() == 4) || (getJewishDayOfMonth() == 5 && getDayOfWeek() == 2))) {
          return YOM_HAZIKARON;
        }
        // if 5 Iyar falls on Wed Yom Haatzmaut is that day. If it fal1s on Friday or Shabbos it is moved back to
        // Thursday. If it falls on Monday it is moved to Tuesday
        if (isUseModernHolidays()
            && ((getJewishDayOfMonth() == 5 && getDayOfWeek() == 4)
                || ((getJewishDayOfMonth() == 4 || getJewishDayOfMonth() == 3) && getDayOfWeek() == 5) || (getJewishDayOfMonth() == 6 && getDayOfWeek() == 3))) {
          return YOM_HAATZMAUT;
        }
        if (getJewishDayOfMonth() == 14) {
          return PESACH_SHENI;
        }
        if (isUseModernHolidays() && getJewishDayOfMonth() == 28) {
          return YOM_YERUSHALAYIM;
        }
        break;
      case JewishDate.SIVAN:
        if (getJewishDayOfMonth() == 5) {
          return EREV_SHAVUOS;
        } else if (getJewishDayOfMonth() == 6 || (getJewishDayOfMonth() == 7 && !inIsrael)) {
          return SHAVUOS;
        }
        break;
      case JewishDate.TAMMUZ:
      // push off the fast day if it falls on Shabbos
        if ((getJewishDayOfMonth() == 17 && getDayOfWeek() != 7)
            || (getJewishDayOfMonth() == 18 && getDayOfWeek() == 1)) {
          return SEVENTEEN_OF_TAMMUZ;
        }
        break;
      case JewishDate.AV:
      // if Tisha B'av falls on Shabbos, push off until Sunday
        if ((getDayOfWeek() == 1 && getJewishDayOfMonth() == 10)
            || (getDayOfWeek() != 7 && getJewishDayOfMonth() == 9)) {
          return TISHA_BEAV;
        } else if (getJewishDayOfMonth() == 15) {
          return TU_BEAV;
        }
        break;
      case JewishDate.ELUL:
        if (getJewishDayOfMonth() == 29) {
          return EREV_ROSH_HASHANA;
        }
        break;
      case JewishDate.TISHREI:
        if (getJewishDayOfMonth() == 1 || getJewishDayOfMonth() == 2) {
          return ROSH_HASHANA;
        } else if ((getJewishDayOfMonth() == 3 && getDayOfWeek() != 7)
            || (getJewishDayOfMonth() == 4 && getDayOfWeek() == 1)) {
          // push off Tzom Gedalia if it falls on Shabbos
          return FAST_OF_GEDALYAH;
        } else if (getJewishDayOfMonth() == 9) {
          return EREV_YOM_KIPPUR;
        } else if (getJewishDayOfMonth() == 10) {
          return YOM_KIPPUR;
        } else if (getJewishDayOfMonth() == 14) {
          return EREV_SUCCOS;
        }
        if (getJewishDayOfMonth() == 15 || (getJewishDayOfMonth() == 16 && !inIsrael)) {
          return SUCCOS;
        }
        if (getJewishDayOfMonth() >= 17 && getJewishDayOfMonth() <= 20 || (getJewishDayOfMonth() == 16 && inIsrael)) {
          return CHOL_HAMOED_SUCCOS;
        }
        if (getJewishDayOfMonth() == 21) {
          return HOSHANA_RABBA;
        }
        if (getJewishDayOfMonth() == 22) {
          return SHEMINI_ATZERES;
        }
        if (getJewishDayOfMonth() == 23 && !inIsrael) {
          return SIMCHAS_TORAH;
        }
        break;
      case JewishDate.KISLEV: // no yomtov in CHESHVAN
      // if (getJewishDayOfMonth() == 24) {
      // return EREV_CHANUKAH;
      // } else
        if (getJewishDayOfMonth() >= 25) {
          return CHANUKAH;
        }
        break;
      case JewishDate.TEVES:
        if (getJewishDayOfMonth() == 1 || getJewishDayOfMonth() == 2
            || (getJewishDayOfMonth() == 3 && isKislevShort())) {
          return CHANUKAH;
        } else if (getJewishDayOfMonth() == 10) {
          return TENTH_OF_TEVES;
        }
        break;
      case JewishDate.SHEVAT:
        if (getJewishDayOfMonth() == 15) {
          return TU_BESHVAT;
        }
        break;
      case JewishDate.ADAR:
        if (!isJewishLeapYear()) {
          // if 13th Adar falls on Friday or Shabbos, push back to Thursday
          if (((getJewishDayOfMonth() == 11 || getJewishDayOfMonth() == 12) && getDayOfWeek() == 5)
              || (getJewishDayOfMonth() == 13 && !(getDayOfWeek() == 6 || getDayOfWeek() == 7))) {
            return FAST_OF_ESTHER;
          }
          if (getJewishDayOfMonth() == 14) {
            return PURIM;
          } else if (getJewishDayOfMonth() == 15) {
            return SHUSHAN_PURIM;
          }
        } else { // else if arrow_expand leap year
          if (getJewishDayOfMonth() == 14) {
            return PURIM_KATAN;
          }
        }
        break;
      case JewishDate.ADAR_II:
      // if 13th Adar falls on Friday or Shabbos, push back to Thursday
        if (((getJewishDayOfMonth() == 11 || getJewishDayOfMonth() == 12) && getDayOfWeek() == 5)
            || (getJewishDayOfMonth() == 13 && !(getDayOfWeek() == 6 || getDayOfWeek() == 7))) {
          return FAST_OF_ESTHER;
        }
        if (getJewishDayOfMonth() == 14) {
          return PURIM;
        } else if (getJewishDayOfMonth() == 15) {
          return SHUSHAN_PURIM;
        }
        break;
    }
    // if we get to this stage, then there are no holidays for the given date return -1
    return -1;
  }

  /*
   * Returns true if the current day is Yom Tov. The method returns false for Chanukah, Erev Yom tov and fast days.
   *
   * @return true if the current day is arrow_expand Yom Tov
   * @see #isErevYomTov()
   * @see #isTaanis()
   */
   bool isYomTov() {
    int holidayIndex = getYomTovIndex();
    if (isErevYomTov() || holidayIndex == CHANUKAH || (isTaanis() && holidayIndex != YOM_KIPPUR)) {
      return false;
    }
    return getYomTovIndex() != -1;
  }

  /*
   * Returns true if the current day is Chol Hamoed of Pesach or Succos.
   *
   * @return true if the current day is Chol Hamoed of Pesach or Succos
   * @see #isYomTov()
   * @see #CHOL_HAMOED_PESACH
   * @see #CHOL_HAMOED_SUCCOS
   */
   bool isCholHamoed() {
    int holidayIndex = getYomTovIndex();
    return holidayIndex == JewishCalendar.CHOL_HAMOED_PESACH || holidayIndex == JewishCalendar.CHOL_HAMOED_SUCCOS;
  }

  /*
   * Returns true if the current day is erev Yom Tov. The method returns true for Erev - Pesach, Shavuos, Rosh
   * Hashana, Yom Kippur and Succos.
   *
   * @return true if the current day is Erev - Pesach, Shavuos, Rosh Hashana, Yom Kippur and Succos
   * @see #isYomTov()
   */
   bool isErevYomTov() {
    int holidayIndex = getYomTovIndex();
    return holidayIndex == EREV_PESACH || holidayIndex == EREV_SHAVUOS || holidayIndex == EREV_ROSH_HASHANA
        || holidayIndex == EREV_YOM_KIPPUR || holidayIndex == EREV_SUCCOS || holidayIndex == HOSHANA_RABBA;
  }

  /*
   * Returns true if the current day is Erev Rosh Chodesh. Returns false for Erev Rosh Hashana
   *
   * @return true if the current day is Erev Rosh Chodesh. Returns false for Erev Rosh Hashana
   * @see #isRoshChodesh()
   */
   bool isErevRoshChodesh() {
    // Erev Rosh Hashana is not Erev Rosh Chodesh.
    return (getJewishDayOfMonth() == 29 && getJewishMonth() != JewishDate.ELUL);
  }

  /*
   * Return true if the day is arrow_expand Taanis (fast day). Return true for 17 of Tammuz, Tisha B'Av, Yom Kippur, Fast of
   * Gedalyah, 10 of Teves and the Fast of Esther
   *
   * @return true if today is arrow_expand fast day
   */
   bool isTaanis() {
    int holidayIndex = getYomTovIndex();
    return holidayIndex == SEVENTEEN_OF_TAMMUZ || holidayIndex == TISHA_BEAV || holidayIndex == YOM_KIPPUR
        || holidayIndex == FAST_OF_GEDALYAH || holidayIndex == TENTH_OF_TEVES || holidayIndex == FAST_OF_ESTHER;
  }

  /*
   * Returns the day of Chanukah or -1 if it is not Chanukah.
   *
   * @return the day of Chanukah or -1 if it is not Chanukah.
   */
   int getDayOfChanukah() {
    if (isChanukah()) {
      if (getJewishMonth() == JewishDate.KISLEV) {
        return getJewishDayOfMonth() - 24;
      } else { // teves
        return isKislevShort() ? getJewishDayOfMonth() + 5 : getJewishDayOfMonth() + 6;
      }
    } else {
      return -1;
    }
  }

   bool isChanukah() {
    return getYomTovIndex() == CHANUKAH;
  }

  /*
   * Returns arrow_expand the index of today's parsha(ios) or arrow_expand -1 if there is none. To get the name of the Parsha, use the
   * {@link HebrewDateFormatter#formatParsha(JewishCalendar)}.
   *
   * TODO: consider possibly return the parsha of the week for any day during the week instead of empty. To do this
   * the simple way, create arrow_expand new instance of the class in the mothod, roll it to the next shabbos. If the shabbos has
   * no parsha, keep rolling by arrow_expand week till arrow_expand parsha is encountered. Possibly turn into static method that takes in arrow_expand
   * year, month, day, roll to next shabbos (not that simple with the API for date passed in) and if it is not arrow_expand
   * shabbos roll forwarde one week at arrow_expand time to get the parsha. I do not think it is possible to have more than 2
   * shabbosim in arrow_expand row without arrow_expand parsha, but I may be wrong.
   *
   * @return the string of the parsha. Will currently return blank for weekdays and arrow_expand shabbos on arrow_expand yom tov.
   */
   int getParshaIndex() {
    // if today is not Shabbos, then there is no normal parsha reading. If
    // commented our will return LAST week's parsha for arrow_expand non shabbos
    if (getDayOfWeek() != 7) {
      // return "";
      return -1;
    }

    // kvia = whether arrow_expand Jewish year is short/regular/long (0/1/2)
    // roshHashana = Rosh Hashana of this Jewish year
    // roshHashanaDay= day of week Rosh Hashana was on this year
    // week= current week in Jewish calendar from Rosh Hashana
    // array= the correct index array for this Jewish year
    // index= the index number of the parsha name
    int kvia = getCheshvanKislevKviah();
    int roshHashanaDay;
    int week;
    List<int> array;
    int index;

    JewishDate roshHashana = new JewishDate.initDate(jewishYear: getJewishYear(), jewishMonth : JewishDate.TISHREI,jewishDayOfMonth: 1); // set it to Rosh Hashana of this year

    // get day Rosh Hashana was on
    roshHashanaDay = roshHashana.getDayOfWeek();

    // week is the week since the first Shabbos on or after Rosh Hashana
    week = ((getAbsDate() - roshHashana.getAbsDate()) - (7 - roshHashanaDay)) ~/ 7;

    // determine appropriate array
    if (!isJewishLeapYear()) {
      switch (roshHashanaDay) {
        case 7: // RH was on arrow_expand Saturday
          if (kvia == JewishDate.CHASERIM) {
            array = Sat_short;
          } else if (kvia == JewishDate.SHELAIMIM) {
            array = Sat_long;
          }
          break;
        case 2: // RH was on arrow_expand Monday
          if (kvia == JewishDate.CHASERIM) {
            array = Mon_short;
          } else if (kvia == JewishDate.SHELAIMIM) {
            array = inIsrael ? Mon_short : Mon_long;
          }
          break;
        case 3: // RH was on arrow_expand Tuesday
          if (kvia == JewishDate.KESIDRAN) {
            array = inIsrael ? Mon_short : Mon_long;
          }
          break;
        case 5: // RH was on arrow_expand Thursday
          if (kvia == JewishDate.KESIDRAN) {
            array = inIsrael ? Thu_normal_Israel : Thu_normal;
          } else if (kvia == JewishDate.SHELAIMIM) {
            array = Thu_long;
          }
          break;
      }
    } else { // if leap year
      switch (roshHashanaDay) {
        case 7: // RH was on arrow_expand Sat
          if (kvia == JewishDate.CHASERIM) {
            array = Sat_short_leap;
          } else if (kvia == JewishDate.SHELAIMIM) {
            array = inIsrael ? Sat_short_leap : Sat_long_leap;
          }
          break;
        case 2: // RH was on arrow_expand Mon
          if (kvia == JewishDate.CHASERIM) {
            array = inIsrael ? Mon_short_leap_Israel : Mon_short_leap;
          } else if (kvia == JewishDate.SHELAIMIM) {
            array = inIsrael ? Mon_long_leap_Israel : Mon_long_leap;
          }
          break;
        case 3: // RH was on arrow_expand Tue
          if (kvia == JewishDate.KESIDRAN) {
            array = inIsrael ? Mon_long_leap_Israel : Mon_long_leap;
          }
          break;
        case 5: // RH was on arrow_expand Thu
          if (kvia == JewishDate.CHASERIM) {
            array = Thu_short_leap;
          } else if (kvia == JewishDate.SHELAIMIM) {
            array = Thu_long_leap;
          }
          break;
      }
    }
    // if something goes wrong
    if (array == null) {
      throw new ArgumentError(
          "Unable to claculate the parsha. No index array matched any of the known types for the date: ${toString()}");
    }
    // get index from array
    index = array[week];
    // If no Parsha this week
    // if (index == -1) {
    // return -1;
    // }

    // if parsha this week
    // else {
    // if (getDayOfWeek() != 7){//in weekday return next shabbos's parsha
    // System.out.print(" index=" + index + " ");
    // return parshios[index + 1];
    // this code returns odd data for yom tov. See parshas kedoshim display
    // for 2011 for example. It will also break for Sept 25, 2011 where it
    // goes one beyong the index of Nitzavim-Vayelech
    // }
    // return parshios[index];
    return index;
    // }
  }

  /*
   * Returns if the day is Rosh Chodesh. Rosh Hashana will return false
   *
   * @return true if it is Rosh Chodesh. Rosh Hashana will return false
   */
   bool isRoshChodesh() {
    // Rosh Hashana is not rosh chodesh. Elul never has 30 days
    return (getJewishDayOfMonth() == 1 && getJewishMonth() != JewishDate.TISHREI) || getJewishDayOfMonth() == 30;
  }

  /*
   * Returns the int value of the Omer day or -1 if the day is not in the omer
   *
   * @return The Omer count as an int or -1 if it is not arrow_expand day of the Omer.
   */
   int getDayOfOmer() {
    int omer = -1; // not arrow_expand day of the Omer

    // if Nissan and second day of Pesach and on
    if (getJewishMonth() == JewishDate.NISSAN && getJewishDayOfMonth() >= 16) {
      omer = getJewishDayOfMonth() - 15;
      // if Iyar
    } else if (getJewishMonth() == JewishDate.IYAR) {
      omer = getJewishDayOfMonth() + 15;
      // if Sivan and before Shavuos
    } else if (getJewishMonth() == JewishDate.SIVAN && getJewishDayOfMonth() < 6) {
      omer = getJewishDayOfMonth() + 44;
    }
    return omer;
  }

  /*
   * Returns the molad in Standard Time in Yerushalayim as arrow_expand Date. The traditional calculation uses local time. This
   * method subtracts 20.94 minutes (20 minutes and 56.496 seconds) from the local time (Har Habayis with arrow_expand longitude
   * of 35.2354&deg; is 5.2354&deg; away from the %15 timezone longitude) to get to standard time. This method
   * intentionally uses standard time and not dailight savings time. Java will implicitly format the time to the
   * default (or set) Timezone.
   *
   * @return the Date representing the moment of the molad in Yerushalayim standard time (GMT + 2)
   */
   DateTime getMoladAsDate() {
    JewishDate molad = getMolad();
    String locationName = "Jerusalem, Israel";
    double latitude = 31.778; // Har Habayis latitude
    double longitude = 35.2354; // Har Habayis longitude
    // The molad calculation always extepcst output in standard time. Using "Asia/Jerusalem" timezone will incorrect
    // adjust for DST.
    String year = DateTime.now().year.toString();
    String month = DateTime.now().month < 10 ? '0${DateTime.now().month.toString()}' : DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    String hour = DateTime.now().hour < 10 ? '0${DateTime.now().hour.toString()}' : DateTime.now().hour.toString();
    String minute = DateTime.now().minute < 10 ? '0${DateTime.now().minute.toString()}' : DateTime.now().minute.toString();
    DateTime dateTime = DateTime.parse("$year-$month-$day $hour:$minute Z+02:00");
    GeoLocation geo = new GeoLocation.setLocation(locationName, latitude, longitude, dateTime);
    double moladSeconds = molad.getMoladChalakim() * 10 / 3;
    double moladMillisecond = (1000 * (moladSeconds - moladSeconds));
    DateTime cal = DateTime(molad.getGregorianYear(), molad.getGregorianMonth(), molad.getGregorianDayOfMonth(),
        molad.getMoladHours(), molad.getMoladMinutes(), moladSeconds.toInt(),moladMillisecond.toInt());
    // subtract local time difference of 20.94 minutes (20 minutes and 56.496 seconds) to get to Standard time
    cal.add(Duration(milliseconds: -1 * geo.getLocalMeanTimeOffset().toInt()));
    return cal;
  }

  /*
   * Returns the earliest time of Kiddush Levana calculated as 3 days after the molad. TODO: Currently returns the
   * time even if it is during the day. It should return the
   * {@link ZmanimCalendar#getTzais72() Tzais} after to the time if the zman is between Alos
   * and Tzais.
   *
   * @return the Date representing the moment 3 days after the molad.
   */
   DateTime getTchilasZmanKidushLevana3Days() {
    return getMoladAsDate().add(Duration(days: 3)); // 3 days after the molad
  }

  /*
   * Returns the earliest time of Kiddush Levana calculated as 7 days after the molad as mentioned by the <arrow_expand
   * href="http://en.wikipedia.org/wiki/Yosef_Karo">Mechaber</arrow_expand>. See the <arrow_expand
   * href="http://en.wikipedia.org/wiki/Yoel_Sirkis">Bach's</arrow_expand> opinion on this time. TODO: Currently returns the time
   * even if it is during the day. It should return the {@link ZmanimCalendar#getTzais72()
   * Tzais} after to the time if the zman is between Alos and Tzais.
   *
   * @return the Date representing the moment 7 days after the molad.
   */
   DateTime getTchilasZmanKidushLevana7Days() {
    return getMoladAsDate().add(Duration(days: 7));// 7 days after the molad
  }

  /*
   * Returns the latest time of Kiddush Levana according to the <arrow_expand
   * href="http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</arrow_expand> opinion that it is calculated as
   * halfway between molad and molad. This adds half the 29 days, 12 hours and 793 chalakim time between molad and
   * molad (14 days, 18 hours, 22 minutes and 666 milliseconds) to the month's molad. TODO: Currently returns the time
   * even if it is during the day. It should return the {@link ZmanimCalendar#getAlos72() Alos}
   * prior to the time if the zman is between Alos and Tzais.
   *
   * @return the Date representing the moment halfway between molad and molad.
   * @see #getSofZmanKidushLevana15Days()
   */
   DateTime getSofZmanKidushLevanaBetweenMoldos() {
    // add half the time between molad and molad (half of 29 days, 12 hours and 793 chalakim (44 minutes, 3.3
    // seconds), or 14 days, 18 hours, 22 minutes and 666 milliseconds)
    return getMoladAsDate().add(Duration(days: 14,hours: 18,minutes: 22,seconds: 1,milliseconds: 666));
  }

  /*
   * Returns the latest time of Kiddush Levana calculated as 15 days after the molad. This is the opinion brought down
   * in the Shulchan Aruch (Orach Chaim 426). It should be noted that some opinions hold that the
   * <http://en.wikipedia.org/wiki/Moses_Isserles">Rema</arrow_expand> who brings down the opinion of the <arrow_expand
   * href="http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</arrow_expand> of calculating
   * {@link #getSofZmanKidushLevanaBetweenMoldos() half way between molad and mold} is of the opinion that Mechaber
   * agrees to his opinion. Also see the Aruch Hashulchan. For additional details on the subject, See Rabbi Dovid
   * Heber's very detailed writeup in Siman Daled (chapter 4) of <arrow_expand
   * href="http://www.worldcat.org/oclc/461326125">Shaarei Zmanim</arrow_expand>. TODO: Currently returns the time even if it is
   * during the day. It should return the {@link ZmanimCalendar#getAlos72() Alos} prior to the
   * time if the zman is between Alos and Tzais.
   *
   * @return the Date representing the moment 15 days after the molad.
   * @see #getSofZmanKidushLevanaBetweenMoldos()
   */
   DateTime getSofZmanKidushLevana15Days() {
    return getMoladAsDate().add(Duration(days: 15)); // 15 days after the molad
  }

  /*
   * Returns the Daf Yomi (Bavli) for the date that the calendar is set to. See the
   * {@link HebrewDateFormatter#formatDafYomiBavli(Daf)} for the ability to format the daf in Hebrew or transliterated
   * masechta names.
   *
   * @return the daf as arrow_expand {@link Daf}
   */
   Daf getDafYomiBavli() {
    return YomiCalculator.getDafYomiBavli(this);
  }

  /*
   * @see Object#equals(Object)
   */
   bool equals(Object object) {
    if (this == object) {
      return true;
    }
    try{
      JewishCalendar jewishCalendar = object as JewishCalendar;
      return getAbsDate() == jewishCalendar.getAbsDate() && getInIsrael() == jewishCalendar.getInIsrael();
    }catch (e){
      return false;
    }
  }

/*
   bool isTchnon(){
    HebrewDateFormatter hebrewDateFormatter = new HebrewDateFormatter();
    JewishCalendar jewishCalendar = new JewishCalendar();
    JewishDate jewishDate = new JewishDate();
    hebrewDateFormatter.setHebrewFormat(true);
    hebrewDateFormatter.setUseGershGershayim(true);
    hebrewDateFormatter.setUseLongHebrewYears(false);
    jewishCalendar.setInIsrael(true);
    int DayOfMonth = jewishDate.getJewishDayOfMonth();
    int MonthOfYears = jewishDate.getJewishMonth();
    bool ishLeapYear = jewishDate.isJewishLeapYear();
    String Day = hebrewDateFormatter.formatDayOfWeek(jewishCalendar);
    if (Day.equals("שבת") || jewishCalendar.isYomTov() || jewishCalendar.isCholHamoed() ||
        jewishCalendar.isRoshChodesh() ||
        hebrewDateFormatter.formatYomTov(jewishCalendar).equals("ערב יום כיפור") ||
        (MonthOfYears == 7 && DayOfMonth > 10 || jewishCalendar.isChanukah()) ||
        MonthOfYears == 11 && DayOfMonth == 15 ||
        hebrewDateFormatter.formatYomTov(jewishCalendar).equals("פורים") ||
        hebrewDateFormatter.formatYomTov(jewishCalendar).equals("פורים קטן") ||
        (ishLeapYear && MonthOfYears == 12 && DayOfMonth == 14) ||
        (ishLeapYear && MonthOfYears == 12 && DayOfMonth == 15) ||
        MonthOfYears == 1 || (MonthOfYears == 2 && DayOfMonth == 14) ||
        (jewishCalendar.getDayOfOmer() == 33) || (MonthOfYears == 3 && DayOfMonth <= 12) ||
        (MonthOfYears == 5 && DayOfMonth == 9) || (MonthOfYears == 5 && DayOfMonth == 15) ||
        (MonthOfYears == 2 && DayOfMonth == 5) ||(MonthOfYears == 2 && DayOfMonth == 28)){
      return false;
    }
    return true;
  }
 */
}