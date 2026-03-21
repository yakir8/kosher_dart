/*
 * Zmanim Dart API
 *
 * Copyright (C) 2019 - 2022 Eliyahu Hershfeld
 * Copyright (C) 2019 - 2021 Y Paritcher
 * 
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General License for more
 * details.
 * You should have received a copy of the GNU Lesser General License along with this library; if not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 * 
 * Port Author: Daniel Smith (https://github.com/DanielSmith1239)
 */

import 'package:kosher_dart/kosher_dart.dart';

/// Tefila Rules is a utility class that covers the various _halachos_ and _minhagim_ regarding
/// changes to daily _tefila_ / prayers,
/// based on the Jewish calendar. This is mostly useful for use in
/// developing _siddur_ type applications,
/// but it is also valuable for _shul_ calendars that set
/// _tefila_ times based on if [_tachanun_](https://en.wikipedia.org/wiki/Tachanun) is
/// recited that day. There are many settings in this class to cover the vast majority of _minhagim_,
/// but
/// there are likely some not covered here. The source for many of the _chasidishe minhagim_ can be found
/// in the [Minhag Yisrael Torah](https://www.nli.org.il/he/books/NNL_ALEPH001141272/NLI) on Orach
/// Chaim 131.
/// Dates used in specific communities such as specific _yahrzeits_ or a holidays like Purim Mezhbizh
/// (Medzhybizh) celebrated on 11 [JewishDate.TEVES] or [Purim Saragossa](https://en.wikipedia.org/wiki/Second_Purim#Purim_Saragossa_(18_Shevat)) celebrated on
/// the (17th or) 18th of [JewishDate.SHEVAT] are not (and likely will not be) supported by
/// this class.
/// Sample code:
///
/// ```dart
///  TefilaRules tr = new TefilaRules();
///  JewishCalendar jewishCalendar = new JewishCalendar();
///  HebrewDateFormatter hdf = new HebrewDateFormatter();
///  jewishCalendar.setJewishDate(5783,
///  JewishDate.TISHREI,
///  1); // Rosh Hashana
///  System.out.println(hdf.format(jewishCalendar) + ": " + tr.isTachanunRecitedShacharis(jd));
///  jewishCalendar.setJewishDate(5783,
///  JewishDate.ADAR,
///  17);
///  System.out.println(hdf.format(jewishCalendar) + ": " + tr.isTachanunRecitedShacharis(jewishCalendar));
///  tr.setTachanunRecitedWeekOfPurim(false);
/// System.out.println(hdf.format(jewishCalendar) + ": " + tr.isTachanunRecitedShacharis(jewishCalendar));
/// ```
///
/// ### Authors
/// - © Y. Paritcher 2019 - 2021
/// - © Eliyahu Hershfeld 2019 - 2022
///
///
/// TODO The following items may be added at a future date.
/// - *Lamnatzaiach*
/// - *Mizmor Lesoda*
/// - *Behab*
/// - *Selichos*
/// - ...
class TefilaRules {
  /// Whether or not _tachanun_ recited at the end Of [JewishDate.TISHREI].
  ///
  /// The Magen Avraham 669:1 and the Pri Chadash 131:7 state that some places to not recite
  /// _tachanun_ during this period. The Sh"UT Chasam Sofer on Choshen Mishpat 77 writes
  /// that this is the _minhag_ in Ashkenaz. The Shaarei Teshuva 131:19 quotes the
  /// Sheyarie Kneses Hagdola who also states that it should not be recited. The Aderes wanted
  /// to institute saying _tachanun_ during this period, but was dissuaded from this by Rav
  /// Shmuel Salant who did not want to change the _minhag_ in Yerushalayim. The Aruch
  /// Hashulchan is of the opinion that that this _minhag_ is incorrect, and it should be
  /// recited, and The Chazon Ish also recited _tachanun_ during this period. See the Dirshu
  /// edition of the Mishna Berurah for details.
  final bool tachanunRecitedEndOfTishrei;

  /// Is _tachanun_ recited during the week after _Shavuos_. This is the opinion of the Pri Megadim
  /// quoted by the Mishna Berurah. This is since _karbanos_ of _Shavuos_ have _tashlumim_ for
  /// 7 days, it is still considered like a Yom Tov. The Chazon Ish quoted in the Orchos Rabainu vol. 1 page 68
  /// recited _tachanun_ during this week.
  ///
  /// Returns If _tachanun_ is set to be recited during the week after Shavuos.
  /// See also [setTachanunRecitedWeekAfterShavuos].
  final bool tachanunRecitedWeekAfterShavuos;

  /// Is _tachanun_ is recited on the 13th of [JewishDate.SIVAN] ([_Yom Tov Sheni shel Galuyos_](https://en.wikipedia.org/wiki/Yom_tov_sheni_shel_galuyot) of the 7th
  /// day) outside Israel. This is brought down by the Shaarie Teshuva 131:19 quoting the [Sheyarei Kneses Hagedola 131:12](https://hebrewbooks.org/pdfpager.aspx?req=41295&st=&pgnum=39)that
  /// _tachanun_ should not be recited on this day. Rav Shlomo Zalman Orbach in Halichos Shlomo on
  /// Shavuos 12:16:25 is of the opinion that even in _chutz laaretz_ it should be recited since the <em>yemei
  /// Tashlumin</em> are counted based on Israel since that is where the _karbanos_ are brought. Both
  /// [isTachanunRecitedShacharis] and [isTachanunRecitedMincha]
  /// only return false if the location is not set to [JewishCalendar.getInIsrael] and both
  /// [tachanunRecitedWeekAfterShavuos] and [setTachanunRecited13SivanOutOfIsrael] are set to false.
  ///
  /// Returns If _tachanun_ is set to be recited on the 13th of [JewishDate.SIVAN] out of Israel.
  /// See also [setTachanunRecited13SivanOutOfIsrael].
  /// See also [isTachanunRecitedWeekAfterShavuos].
  final bool tachanunRecited13SivanOutOfIsrael;

  /// Is _tachanun_ recited on [JewishCalendar.PESACH_SHENI]. The Pri Chadash 131:7 states
  /// that _tachanun_ should not be recited. The Aruch Hashulchan states that this is the minhag of the _sephardim_.
  /// the Shaarei Efraim 10:27 also mentions that it is not recited, as does the Siddur Yaavetz (Shaar Hayesod, Chodesh Iyar).
  /// The Pri Megadim (Mishbetzes Hazahav 131:15) and the Chazon Ish (Erev Pesahc Shchal Beshabos, page 203 in [Rav Sheraya Devlitzky's](https://he.wikipedia.org/wiki/%D7%A9%D7%A8%D7%99%D7%94_%D7%93%D7%91%D7%9C%D7%99%D7%A6%D7%A7%D7%99) comments).
  ///
  /// Returns If _tachanun_ is recited on [JewishCalendar.PESACH_SHENI].
  /// See also [setTachanunRecitedPesachSheni].
  final bool tachanunRecitedPesachSheni;

  /// Is _tachanun_ recited on 15 [JewishDate.IYAR] (_sfaika deyoma_ of [JewishCalendar.PESACH_SHENI]) out of Israel. If [isTachanunRecitedPesachSheni] is `true` this will be
  /// ignored even if `false`.
  ///
  /// Returns if _tachanun_ is recited on 15 [JewishDate.IYAR]  (_sfaika deyoma_ of {@link
  /// JewishCalendar#PESACH_SHENI _Pesach Sheni_} out of Israel. If [isTachanunRecitedPesachSheni]
  /// is `true` this will be ignored even if `false`.
  /// See also [setTachanunRecited15IyarOutOfIsrael].
  /// See also [setTachanunRecitedPesachSheni].
  /// See also [isTachanunRecitedPesachSheni].
  final bool tachanunRecited15IyarOutOfIsrael;

  /// Is _tachanun_ recited on _mincha_ on _erev [JewishCalendar.LAG_BAOMER]_.
  /// Returns if _tachanun_ is recited in _mincha_ on _erev_
  /// [JewishCalendar.LAG_BAOMER].
  /// See also [setTachanunRecitedMinchaErevLagBaomer].
  final bool tachanunRecitedMinchaErevLagBaomer;

  /// Is _tachanun_ recited during the _Shivas Yemei Hamiluim_, from the 23 of {@link
  /// JewishDate#ADAR _Adar_} on a non-leap-year or [JewishDate.ADAR_II] on a
  /// leap year to the end of the month. Some _chasidishe_ communities do not say _tachanun_
  /// during this week. See [Darkei Chaim Veshalom 191](https://hebrewbooks.org/pdfpager.aspx?req=4692&st=&pgnum=70).
  /// Returns if _tachanun_ is recited during the _Shivas Yemei Hamiluim_, from the 23 of {@link
  /// JewishDate#ADAR _Adar_} on a non-leap-year or [JewishDate.ADAR_II]
  /// on a leap year to the end of the month.
  /// See also [setTachanunRecitedShivasYemeiHamiluim].
  final bool tachanunRecitedShivasYemeiHamiluim;

  /// Is _tachanun_ recited during the _sefira_ week of _Hod_ (14 - 20 [JewishDate.IYAR],
  /// or the 29th - 35th of the [JewishCalendar.getDayOfOmer]). Some _chasidishe_ communities
  /// do not recite _tachanun_ during this week. See Minhag Yisrael Torah 131:Iyar.
  /// Returns If _tachanun_ is set to be recited during the _sefira_ week of _Hod_ (14 - 20 {@link
  /// JewishDate#IYAR _Iyar_}, or the 29th - 35th of the [JewishCalendar.getDayOfOmer]).
  /// See also [setTachanunRecitedWeekOfHod].
  final bool tachanunRecitedWeekOfHod;

  /// Is _tachanun_ recited during the week of Purim, from the 11th through the 17th of {@link
  /// JewishDate#ADAR _Adar_} (on a non-leap year, or [JewishDate.ADAR_II] on a leap year). Some
  /// _chasidishe_ communities do not recite _tachanun_ during this period. See the [Minhag Yisrael Torah](https://www.nli.org.il/he/books/NNL_ALEPH001141272/NLI) 131 and [Darkei Chaim Veshalom 191](https://hebrewbooks.org/pdfpager.aspx?req=4692&st=&pgnum=70)who discuss the
  /// _minhag_ not to recite _tachanun_. Also see the [Mishmeres Shalom (Hadras Shalom)](https://hebrewbooks.org/pdfpager.aspx?req=8944&st=&pgnum=160) who discusses the
  /// _minhag_ of not reciting it on the 16th and 17th.
  /// Returns If _tachanun_ is set to be recited during the week of Purim from the 11th through the 17th of {@link
  /// JewishDate#ADAR _Adar_} (on a non-leap year, or [JewishDate.ADAR_II] on a leap year).
  /// See also [setTachanunRecitedWeekOfPurim].
  final bool tachanunRecitedWeekOfPurim;

  /// Is _tachanun_ recited on Fridays. Some _chasidishe_ communities do not recite
  /// _tachanun_ on Fridays. See [Likutei Maharich Vol 2 Seder Hanhagos Erev Shabbos](https://hebrewbooks.org/pdfpager.aspx?req=41190&st=&pgnum=10). This is also the _minhag_ in Satmar.
  /// Returns if _tachanun_ is recited on Fridays.
  /// See also [setTachanunRecitedFridays].
  final bool tachanunRecitedFridays;

  /// Is _tachanun_ recited on Sundays. Some _chasidishe_ communities do not recite
  /// _tachanun_ on Sundays. See [Likutei Maharich Vol 2 Seder Hanhagos Erev Shabbos](https://hebrewbooks.org/pdfpager.aspx?req=41190&st=&pgnum=10).
  /// Returns if _tachanun_ is recited on Sundays.
  /// See also [setTachanunRecitedSundays].
  final bool tachanunRecitedSundays;

  /// Is _tachanun_ recited in _Mincha_ the entire year. Some _chasidishe_ communities do not recite
  /// _tachanun_ by _Mincha_ all year round. See[Nemukei Orach Chaim 131:3](https://hebrewbooks.org/pdfpager.aspx?req=4751&st=&pgnum=105).
  /// Returns if _tachanun_ is recited in _Mincha_ the entire year.
  /// See also [setTachanunRecitedMinchaAllYear].
  final bool tachanunRecitedMinchaAllYear;

  TefilaRules({
    this.tachanunRecitedEndOfTishrei = true,
    this.tachanunRecitedWeekAfterShavuos = false,
    this.tachanunRecited13SivanOutOfIsrael = true,
    this.tachanunRecitedPesachSheni = false,
    this.tachanunRecited15IyarOutOfIsrael = true,
    this.tachanunRecitedMinchaErevLagBaomer = false,
    this.tachanunRecitedShivasYemeiHamiluim = true,
    this.tachanunRecitedWeekOfHod = true,
    this.tachanunRecitedWeekOfPurim = true,
    this.tachanunRecitedFridays = true,
    this.tachanunRecitedSundays = true,
    this.tachanunRecitedMinchaAllYear = true,
  });

  /// Returns if _tachanun_ is recited during _shacharis_ on the day in question. See the many
  /// _minhag_ based settings that are available in this class.
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  /// Returns if _tachanun_ is recited during _shacharis_.
  /// See also [isTachanunRecitedMincha].
  bool isTachanunRecitedShacharis(JewishCalendar jewishCalendar) {
    final holidayIndex = jewishCalendar.getYomTovIndex();
    final day = jewishCalendar.getJewishDayOfMonth();
    final month = jewishCalendar.getJewishMonth();

    final res = (jewishCalendar.getDayOfWeek() == JewishDate.saturday ||
        (!tachanunRecitedSundays &&
            jewishCalendar.getDayOfWeek() == JewishDate.sunday) ||
        (!tachanunRecitedFridays &&
            jewishCalendar.getDayOfWeek() == JewishDate.friday) ||
        month == JewishDate.NISSAN ||
        (month == JewishDate.TISHREI &&
            ((!tachanunRecitedEndOfTishrei && day > 8) ||
                (tachanunRecitedEndOfTishrei && (day > 8 && day < 22)))) ||
        (month == JewishDate.SIVAN &&
            (tachanunRecitedWeekAfterShavuos && day < 7 ||
                !tachanunRecitedWeekAfterShavuos &&
                    day <
                        (!jewishCalendar.inIsrael &&
                                !tachanunRecited13SivanOutOfIsrael
                            ? 14
                            : 13))) ||
        (jewishCalendar.isYomTov() &&
            (!jewishCalendar.isTaanis() ||
                (!tachanunRecitedPesachSheni &&
                    holidayIndex ==
                        JewishCalendar
                            .PESACH_SHENI))) // Erev YT is included in isYomTov()
        ||
        (!jewishCalendar.inIsrael &&
            !tachanunRecitedPesachSheni &&
            !tachanunRecited15IyarOutOfIsrael &&
            jewishCalendar.getJewishMonth() == JewishDate.IYAR &&
            day == 15) ||
        holidayIndex == JewishCalendar.TISHA_BEAV ||
        jewishCalendar.isIsruChag() ||
        jewishCalendar.isRoshChodesh() ||
        (!tachanunRecitedShivasYemeiHamiluim &&
            ((!jewishCalendar.isJewishLeapYear() && month == JewishDate.ADAR) ||
                (jewishCalendar.isJewishLeapYear() &&
                    month == JewishDate.ADAR_II)) &&
            day > 22) ||
        (!tachanunRecitedWeekOfPurim &&
            ((!jewishCalendar.isJewishLeapYear() && month == JewishDate.ADAR) ||
                (jewishCalendar.isJewishLeapYear() &&
                    month == JewishDate.ADAR_II)) &&
            day > 10 &&
            day < 18) ||
        (jewishCalendar.isUseModernHolidays() &&
            (holidayIndex == JewishCalendar.YOM_HAATZMAUT ||
                holidayIndex == JewishCalendar.YOM_YERUSHALAYIM)) ||
        (!tachanunRecitedWeekOfHod &&
            month == JewishDate.IYAR &&
            day > 13 &&
            day < 21));

    return !res;
  }

  /// Returns if _tachanun_ is recited during _mincha_ on the day in question.
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  /// Returns if _tachanun_ is recited during _mincha_.
  /// See also [isTachanunRecitedShacharis].
  bool isTachanunRecitedMincha(JewishCalendar jewishCalendar) {
    final tomorrow = jewishCalendar.clone();

    tomorrow.forward(Calendar.DATE, 1);

    final res = (!tachanunRecitedMinchaAllYear ||
        jewishCalendar.getDayOfWeek() == JewishDate.friday ||
        !isTachanunRecitedShacharis(jewishCalendar) ||
        (!isTachanunRecitedShacharis(tomorrow) &&
            !(tomorrow.getYomTovIndex() == JewishCalendar.EREV_ROSH_HASHANA) &&
            !(tomorrow.getYomTovIndex() == JewishCalendar.EREV_YOM_KIPPUR) &&
            !(tomorrow.getYomTovIndex() == JewishCalendar.PESACH_SHENI)) ||
        !tachanunRecitedMinchaErevLagBaomer &&
            tomorrow.getYomTovIndex() == JewishCalendar.LAG_BAOMER);

    return !res;
  }

  /// Returns if it is the Jewish day (starting the evening before) to start reciting _Vesein Tal Umatar Livracha_
  /// (_Sheailas Geshamim_). In Israel this is the 7th day of [JewishDate.CHESHVAN].
  /// Outside Israel recitation starts on the evening of December 4th (or 5th if it is the year before a civil leap year)
  /// in the 21st century and shifts a day forward every century not evenly divisible by 400. This method will return true
  /// if _vesein tal umatar_ on the current Jewish date that starts on the previous night, so Dec 5/6 will be
  /// returned by this method in the 21st century. _vesein tal umatar_ is not recited on _Shabbos_ and the
  /// start date will be delayed a day when the start day is on a _Shabbos_ (this can only occur out of Israel).
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  ///
  /// Returns true if it is the first Jewish day (starting the prior evening of reciting _Vesein Tal Umatar Livracha_
  /// (_Sheailas Geshamim_).
  ///
  /// See also [isVeseinTalUmatarStartingTonight].
  /// See also [isVeseinTalUmatarRecited].
  bool isVeseinTalUmatarStartDate(JewishCalendar jewishCalendar) {
    if (jewishCalendar.inIsrael &&
        jewishCalendar.getJewishMonth() == JewishDate.CHESHVAN &&
        jewishCalendar.getJewishDayOfMonth() == 7) {
      // The 7th Cheshvan can't occur on Shabbos, so always return true for 7 Cheshvan
      return true;
    }

    // Not recited on Friday night
    if (jewishCalendar.getDayOfWeek() == JewishDate.saturday) {
      return false;
    }

    // When starting on Sunday, it can be the start date or delayed from Shabbos
    final tted = jewishCalendar.getTekufasTishreiElapsedDays();
    return (jewishCalendar.getDayOfWeek() == JewishDate.sunday && tted == 48) ||
        (tted == 47);
  }

  /// Returns if true if tonight is the first night to start reciting _Vesein Tal Umatar Livracha_ (
  /// _Sheailas Geshamim_). In Israel this is the 7th day of [JewishDate.CHESHVAN] (so the 6th will return true). Outside Israel recitation starts on the evening
  /// of December 4th (or 5th if it is the year before a civil leap year) in the 21st century and shifts a
  /// day forward every century not evenly divisible by 400. _Vesein tal umatar_ is not recited on
  /// _Shabbos_ and the start date will be delayed a day when the start day is on a _Shabbos_
  /// (this can only occur out of Israel).
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  ///
  /// Returns true if it is the first Jewish day (starting the prior evening of reciting <em>Vesein Tal Umatar
  /// Livracha</em> (_Sheailas Geshamim_).
  ///
  /// See also [isVeseinTalUmatarStartDate].
  /// See also [isVeseinTalUmatarRecited].
  bool isVeseinTalUmatarStartingTonight(JewishCalendar jewishCalendar) {
    if (jewishCalendar.inIsrael &&
        (jewishCalendar.getJewishMonth() == JewishDate.CHESHVAN &&
            jewishCalendar.getJewishDayOfMonth() == 6)) {
      // The 7th Cheshvan can't occur on Shabbos, so always return true for 6 Cheshvan
      return true;
    }

    // Not recited on Friday night
    if (jewishCalendar.getDayOfWeek() == JewishDate.friday) {
      return false;
    }

    // When starting on motzai Shabbos, it can be the start date or delayed from Friday night
    final tted = jewishCalendar.getTekufasTishreiElapsedDays();
    return (jewishCalendar.getDayOfWeek() == JewishDate.sunday && tted == 47) ||
        (tted == 46);
  }

  /// Returns if _Vesein Tal Umatar Livracha_ (_Sheailas Geshamim_) is recited. This will return
  /// true for the entire season, even on _Shabbos_ when it is not recited.
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  ///
  /// Returns true if _Vesein Tal Umatar Livracha_ (_Sheailas Geshamim_) is recited.
  ///
  /// See also [isVeseinTalUmatarStartDate].
  /// See also [isVeseinTalUmatarStartingTonight].
  bool isVeseinTalUmatarRecited(JewishCalendar jewishCalendar) {
    if (jewishCalendar.getJewishMonth() == JewishDate.NISSAN &&
        jewishCalendar.getJewishDayOfMonth() < 15) {
      return true;
    }
    if (jewishCalendar.getJewishMonth() < JewishDate.CHESHVAN) {
      return false;
    }
    if (jewishCalendar.inIsrael) {
      return jewishCalendar.getJewishMonth() != JewishDate.CHESHVAN ||
          jewishCalendar.getJewishDayOfMonth() >= 7;
    } else {
      return jewishCalendar.getTekufasTishreiElapsedDays() >= 47;
    }
  }

  /// Returns if _Vesein Beracha_ is recited. It is recited from 15 [JewishDate.NISSAN] to the
  /// point that [isVeseinTalUmatarRecited].
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  /// Returns true if _Vesein Beracha_ is recited.
  /// See also [isVeseinTalUmatarRecited].
  bool isVeseinBerachaRecited(JewishCalendar jewishCalendar) {
    return !isVeseinTalUmatarRecited(jewishCalendar);
  }

  /// Returns if the date is the start date for reciting _Mashiv Haruach Umorid Hageshem_. The date is 22
  /// [JewishDate.TISHREI].
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  /// Returns true if the date is the start date for reciting _Mashiv Haruach Umorid Hageshem_.
  /// See also [isMashivHaruachEndDate].
  /// See also [isMashivHaruachRecited].
  bool isMashivHaruachStartDate(JewishCalendar jewishCalendar) {
    return jewishCalendar.getJewishMonth() == JewishDate.TISHREI &&
        jewishCalendar.getJewishDayOfMonth() == 22;
  }

  /// Returns if the date is the end date for reciting _Mashiv Haruach Umorid Hageshem_. The date is 15
  /// [JewishDate.NISSAN].
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  /// Returns true if the date is the end date for reciting _Mashiv Haruach Umorid Hageshem_.
  /// See also [isMashivHaruachStartDate].
  /// See also [isMashivHaruachRecited].
  bool isMashivHaruachEndDate(JewishCalendar jewishCalendar) {
    return jewishCalendar.getJewishMonth() == JewishDate.NISSAN &&
        jewishCalendar.getJewishDayOfMonth() == 15;
  }

  /// Returns if _Mashiv Haruach Umorid Hageshem_ is recited. This period starts on 22 {@link
  /// JewishDate#TISHREI _Tishrei_} and ends on the 15th day of [JewishDate.NISSAN].
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  /// Returns true if _Mashiv Haruach Umorid Hageshem_ is recited.
  /// See also [isMashivHaruachStartDate].
  /// See also [isMashivHaruachEndDate].
  bool isMashivHaruachRecited(JewishCalendar jewishCalendar) {
    JewishDate startDate = JewishDate.initDate(
        jewishYear: jewishCalendar.getJewishYear(),
        jewishMonth: JewishDate.TISHREI,
        jewishDayOfMonth: 22);

    JewishDate endDate = JewishDate.initDate(
        jewishYear: jewishCalendar.getJewishYear(),
        jewishMonth: JewishDate.NISSAN,
        jewishDayOfMonth: 15);

    return jewishCalendar.compareTo(startDate) > 0 &&
        jewishCalendar.compareTo(endDate) < 0;
  }

  /// Returns if _Morid Hatal_ (or the lack of reciting _Mashiv Haruach_ following _nussach Ashkenaz_) is
  /// recited. This period starts on the 15th day of [JewishDate.NISSAN] and ends on 22 {@link
  /// JewishDate#TISHREI _Tishrei_}.
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  ///
  /// Returns true if _Morid Hatal_ (or the lack of reciting _Mashiv Haruach_ following _nussach Ashkenaz_) is recited.
  bool isMoridHatalRecited(JewishCalendar jewishCalendar) {
    return !isMashivHaruachRecited(jewishCalendar) ||
        isMashivHaruachStartDate(jewishCalendar) ||
        isMashivHaruachEndDate(jewishCalendar);
  }

  /// Returns if _hallel_ is recited on the day in question. This will return true for both _hallel shalem_
  /// and _chatzi hallel_. See [isHallelShalemRecited] to know if the complete _hallel_
  /// is recited.
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  /// Returns if _hallel_ is recited.
  /// See also [isHallelShalemRecited].
  bool isHallelRecited(JewishCalendar jewishCalendar) {
    int day = jewishCalendar.getJewishDayOfMonth();
    int month = jewishCalendar.getJewishMonth();
    int holidayIndex = jewishCalendar.getYomTovIndex();
    bool inIsrael = jewishCalendar.inIsrael;

    if (jewishCalendar.isRoshChodesh()) {
      //RH returns false for RC
      return true;
    }
    if (jewishCalendar.isChanukah()) {
      return true;
    }
    switch (month) {
      case JewishDate.NISSAN:
        if (day >= 15 &&
            ((inIsrael && day <= 21) || (!inIsrael && day <= 22))) {
          return true;
        }
        break;
      case JewishDate.IYAR: // modern holidays
        if (jewishCalendar.isUseModernHolidays() &&
            (holidayIndex == JewishCalendar.YOM_HAATZMAUT ||
                holidayIndex == JewishCalendar.YOM_YERUSHALAYIM)) {
          return true;
        }
        break;
      case JewishDate.SIVAN:
        if (day == 6 || (!inIsrael && (day == 7))) {
          return true;
        }
        break;
      case JewishDate.TISHREI:
        if (day >= 15 && (day <= 22 || (!inIsrael && (day <= 23)))) {
          return true;
        }
    }
    return false;
  }

  /// Returns if _hallel shalem_ is recited on the day in question. This will always return false if {@link
  /// #isHallelRecited(JewishCalendar)} returns false.
  ///
  /// - [jewishCalendar]: the Jewish calendar day.
  /// Returns if _hallel shalem_ is recited.
  /// See also [isHallelRecited].
  bool isHallelShalemRecited(JewishCalendar jewishCalendar) {
    int day = jewishCalendar.getJewishDayOfMonth();
    int month = jewishCalendar.getJewishMonth();
    bool inIsrael = jewishCalendar.inIsrael;
    if (isHallelRecited(jewishCalendar)) {
      if ((jewishCalendar.isRoshChodesh() && !jewishCalendar.isChanukah()) ||
          (month == JewishDate.NISSAN &&
              ((inIsrael && day > 15) || (!inIsrael && day > 16)))) {
        return false;
      } else {
        return true;
      }
    }
    return false;
  }
}
