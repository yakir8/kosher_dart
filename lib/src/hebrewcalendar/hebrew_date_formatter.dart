/*
 * Zmanim Java API
 * Copyright (C) 2011 - 2020 Eliyahu Hershfeld
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

import 'package:intl/intl.dart';
import 'package:kosher_dart/kosher_dart.dart';

/// The HebrewDateFormatter class formats a {@link JewishDate}.
///
/// The class formats Jewish dates, numbers, Daf Yomi (Bavli and Yerushalmi), the Omer, Parshas Hashavua (including special parshiyos
/// such as Shekalim, Zachor, Parah, Hachodesh), Yomim Tovim and the Molad (experimental) in Hebrew or Latin chars, and has various
/// settings. Sample full date output includes
/// (using various options):
/// <ul>
/// <li>21 Shevat, 5729</li>
/// <li>כא שבט תשכט</li>
/// <li>כ״א שבט ה׳ תשכ״ט</li>
/// <li>כ״א שבט תש״פ or כ״א שבט תש״ף</li>
/// <li>כ׳ שבט ו׳ אלפים</li>
/// </ul>
/// @author &copy; Eliyahu Hershfeld 2011 - 2020

class HebrewDateFormatter {
  ///Sets the formatter to format in Hebrew in the various formatting methods.
  bool hebrewFormat = false;

  /// When formatting a Hebrew Year, traditionally the thousands digit is omitted and output for a year such as 5729
  /// (1969 Gregorian) would be calculated for 729 and format as תשכ״ט. This method
  /// allows setting this to true to return the long format year such as ה׳ תשכ״ט for 5729/1969.
  bool useLongHebrewYears = false;

  /// Sets whether to use the Geresh ׳ and Gershayim ״ in formatting Hebrew dates and numbers. The default
  /// value is true and output would look like כ״א שבט תש״כ
  /// (or כ״א שבט תש״ך). When set to false, this output would display as כא שבט תשכ (or כא שבט תשך).
  /// Single digit days or month or years such as כ׳ שבט ו׳ אלפים show the use of the Geresh.
  bool useGershGershayim = true;

  /// Setting to control if the {@link #formatDayOfWeek(JewishDate)} will use the long format such as ראשון
  /// or short such as א when formatting the day of week in Hebrew.
  bool longWeekFormat = true;

  /// Returns whether the class is set to use the מנצפ״ך letters when
  /// formatting years ending in 20, 40, 50, 80 and 90 to produce תש״פ if false or
  /// or תש״ף if true. Traditionally non-final form letters are used, so the year
  /// 5780 would be formatted as תש״פ if the default false is used here. If this returns
  /// true, the format תש״ף would be used.
  bool useFinalFormLetters = false;

  bool longOmerFormat = false;

  bool useShortHolidayFormat = false;

  /// The [gersh](https://en.wikipedia.org/wiki/Geresh#Punctuation_mark) character is the ׳; char
  /// that is similar to a single quote and is used in formatting Hebrew numbers.
  static const String _GERESH = "׳";

  /// The [gersh](https://en.wikipedia.org/wiki/Geresh#Punctuation_mark) character is the "; char
  /// that is similar to a single quote and is used in formatting Hebrew numbers.
  static const String _GERSHAYIM = "״";

  /// Hebrew Omer prefix. By default it is the letter ב, but can be set to ל (or any other prefix).
  String hebrewOmerPrefix = "ב";

  ///day of Shabbos transliterated into Latin chars. The default uses Ashkenazi pronunciation "Shabbos".
  String transliteratedShabbosDayOfWeek = "Shabbos";
  String hebrewParshaPrefix = "פרשת ";
  String transliteratedParshaPrefix = "Parashat ";
  String hebrewShabbosStartPrefix = "כניסת שבת: ";
  String transliteratedShabbosStartPrefix = "Shabbos start at: ";
  String hebrewShabbosEndPrefix = "כניסת שבת: ";
  String transliteratedShabbosEndPrefix = "Shabbos end at: ";
  String hebrewYomTovStartPrefix = "כניסת שבת: ";
  String transliteratedYomTovStartPrefix = "Shabbos start at: ";
  String hebrewYomTovEndPrefix = "כניסת שבת: ";
  String transliteratedYomTovEndPrefix = "Shabbos end at: ";

  static const List<String> _hebrewDaysOfWeek = [
    "ראשון",
    "שני",
    "שלישי",
    "רביעי",
    "חמישי",
    "שישי",
    "שבת"
  ];

  /// List of months transliterated into Latin chars. The default list of months uses Ashkenazi
  /// pronunciation in typical American English spelling. This list has a length of 14 with 3 variations for Adar -
  /// "Adar", "Adar II", "Adar I"
  List<String> transliteratedMonths = [
    "Nissan",
    "Iyar",
    "Sivan",
    "Tammuz",
    "Av",
    "Elul",
    "Tishrei",
    "Cheshvan",
    "Kislev",
    "Teves",
    "Shevat",
    "Adar",
    "Adar II",
    "Adar I"
  ];

  List<String> hebrewMonths = [
    "ניסן",
    "אייר",
    "סיוון",
    "תמוז",
    "אב",
    "אלול",
    "תשרי",
    "חשוון",
    "כסלו",
    "טבת",
    "שבט",
    "אדר",
    "אדר ב",
    "אדר א"
  ];

  /// List of transliterated parshiyos using the default Ashkenazi pronounciation.&nbsp; The formatParsha method uses this
  /// for transliterated parsha formatting.&nbsp; This list can be overridden (for Sephardi English transliteration for
  /// example) by setting the {@link #setTransliteratedParshiosList(EnumMap)}. The list includes double and special
  /// parshiyos is set as "Bereshis, Noach, Lech Lecha, Vayera, Chayei Sara, Toldos, Vayetzei, Vayishlach, Vayeshev, Miketz,
  /// Vayigash, Vayechi, Shemos, Vaera, Bo, Beshalach, Yisro, Mishpatim, Terumah, Tetzaveh, Ki Sisa, Vayakhel, Pekudei,
  /// Vayikra, Tzav, Shmini, Tazria, Metzora, Achrei Mos, Kedoshim, Emor, Behar, Bechukosai, Bamidbar, Nasso, Beha'aloscha,
  /// Sh'lach, Korach, Chukas, Balak, Pinchas, Matos, Masei, Devarim, Vaeschanan, Eikev, Re'eh, Shoftim, Ki Seitzei, Ki Savo,
  /// Nitzavim, Vayeilech, Ha'Azinu, Vezos Habracha, Vayakhel Pekudei, Tazria Metzora, Achrei Mos Kedoshim, Behar Bechukosai,
  /// Chukas Balak, Matos Masei, Nitzavim Vayeilech, Shekalim, Zachor, Parah, Hachodesh".
  ///
  /// @see #formatParsha(JewishCalendar)
  Map<Parsha, String> transliteratedParshaMap = {
    Parsha.NONE: "",
    Parsha.BERESHIS: "Bereshis",
    Parsha.NOACH: "Noach",
    Parsha.LECH_LECHA: "Lech Lecha",
    Parsha.VAYERA: "Vayera",
    Parsha.CHAYEI_SARA: "Chayei Sara",
    Parsha.TOLDOS: "Toldos",
    Parsha.VAYETZEI: "Vayetzei",
    Parsha.VAYISHLACH: "Vayishlach",
    Parsha.VAYESHEV: "Vayeshev",
    Parsha.MIKETZ: "Miketz",
    Parsha.VAYIGASH: "Vayigash",
    Parsha.VAYECHI: "Vayechi",
    Parsha.SHEMOS: "Shemos",
    Parsha.VAERA: "Vaera",
    Parsha.BO: "Bo",
    Parsha.BESHALACH: "Beshalach",
    Parsha.YISRO: "Yisro",
    Parsha.MISHPATIM: "Mishpatim",
    Parsha.TERUMAH: "Terumah",
    Parsha.TETZAVEH: "Tetzaveh",
    Parsha.KI_SISA: "Ki Sisa",
    Parsha.VAYAKHEL: "Vayakhel",
    Parsha.PEKUDEI: "Pekudei",
    Parsha.VAYIKRA: "Vayikra",
    Parsha.TZAV: "Tzav",
    Parsha.SHMINI: "Shmini",
    Parsha.TAZRIA: "Tazria",
    Parsha.METZORA: "Metzora",
    Parsha.ACHREI_MOS: "Achrei Mos",
    Parsha.KEDOSHIM: "Kedoshim",
    Parsha.EMOR: "Emor",
    Parsha.BEHAR: "Behar",
    Parsha.BECHUKOSAI: "Bechukosai",
    Parsha.BAMIDBAR: "Bamidbar",
    Parsha.NASSO: "Nasso",
    Parsha.BEHAALOSCHA: "Beha'aloscha",
    Parsha.SHLACH: "Sh'lach",
    Parsha.KORACH: "Korach",
    Parsha.CHUKAS: "Chukas",
    Parsha.BALAK: "Balak",
    Parsha.PINCHAS: "Pinchas",
    Parsha.MATOS: "Matos",
    Parsha.MASEI: "Masei",
    Parsha.DEVARIM: "Devarim",
    Parsha.VAESCHANAN: "Vaeschanan",
    Parsha.EIKEV: "Eikev",
    Parsha.REEH: "Re'eh",
    Parsha.SHOFTIM: "Shoftim",
    Parsha.KI_SEITZEI: "Ki Seitzei",
    Parsha.KI_SAVO: "Ki Savo",
    Parsha.NITZAVIM: "Nitzavim",
    Parsha.VAYEILECH: "Vayeilech",
    Parsha.HAAZINU: "Ha'Azinu",
    Parsha.VZOS_HABERACHA: "Vezos Habracha",
    Parsha.VAYAKHEL_PEKUDEI: "Vayakhel Pekudei",
    Parsha.TAZRIA_METZORA: "Tazria Metzora",
    Parsha.ACHREI_MOS_KEDOSHIM: "Achrei Mos Kedoshim",
    Parsha.BEHAR_BECHUKOSAI: "Behar Bechukosai",
    Parsha.CHUKAS_BALAK: "Chukas Balak",
    Parsha.MATOS_MASEI: "Matos Masei",
    Parsha.NITZAVIM_VAYEILECH: "Nitzavim Vayeilech",
    Parsha.SHKALIM: "Shekalim",
    Parsha.ZACHOR: "Zachor",
    Parsha.PARA: "Parah",
    Parsha.HACHODESH: "Hachodesh",
  };

  /// list of Hebrew parshiyos.
  Map<Parsha, String> hebrewParshaMap = {
    Parsha.NONE: "",
    Parsha.BERESHIS: "בראשית",
    Parsha.NOACH: "נח",
    Parsha.LECH_LECHA: "לך לך",
    Parsha.VAYERA: "וירא",
    Parsha.CHAYEI_SARA: "חיי שרה",
    Parsha.TOLDOS: "תולדות",
    Parsha.VAYETZEI: "ויצא",
    Parsha.VAYISHLACH: "וישלח",
    Parsha.VAYESHEV: "וישב",
    Parsha.MIKETZ: "מקץ",
    Parsha.VAYIGASH: "ויגש",
    Parsha.VAYECHI: "ויחי",
    Parsha.SHEMOS: "שמות",
    Parsha.VAERA: "וארא",
    Parsha.BO: "בא",
    Parsha.BESHALACH: "בשלח",
    Parsha.YISRO: "יתרו",
    Parsha.MISHPATIM: "משפטים",
    Parsha.TERUMAH: "תרומה",
    Parsha.TETZAVEH: "תצוה",
    Parsha.KI_SISA: "כי תשא",
    Parsha.VAYAKHEL: "ויקהל",
    Parsha.PEKUDEI: "פקודי",
    Parsha.VAYIKRA: "ויקרא",
    Parsha.TZAV: "צו",
    Parsha.SHMINI: "שמיני",
    Parsha.TAZRIA: "תזריע",
    Parsha.METZORA: "מצרע",
    Parsha.ACHREI_MOS: "אחרי מות",
    Parsha.KEDOSHIM: "קדושים",
    Parsha.EMOR: "אמור",
    Parsha.BEHAR: "בהר",
    Parsha.BECHUKOSAI: "בחקתי",
    Parsha.BAMIDBAR: "במדבר",
    Parsha.NASSO: "נשא",
    Parsha.BEHAALOSCHA: "בהעלתך",
    Parsha.SHLACH: "שלח לך",
    Parsha.KORACH: "קרח",
    Parsha.CHUKAS: "חוקת",
    Parsha.BALAK: "בלק",
    Parsha.PINCHAS: "פינחס",
    Parsha.MATOS: "מטות",
    Parsha.MASEI: "מסעי",
    Parsha.DEVARIM: "דברים",
    Parsha.VAESCHANAN: "ואתחנן",
    Parsha.EIKEV: "עקב",
    Parsha.REEH: "ראה",
    Parsha.SHOFTIM: "שופטים",
    Parsha.KI_SEITZEI: "כי תצא",
    Parsha.KI_SAVO: "כי תבוא",
    Parsha.NITZAVIM: "ניצבים",
    Parsha.VAYEILECH: "וילך",
    Parsha.HAAZINU: "האזינו",
    Parsha.VZOS_HABERACHA: "וזאת הברכה",
    Parsha.VAYAKHEL_PEKUDEI: "ויקהל פקודי",
    Parsha.TAZRIA_METZORA: "תזריע מצרע",
    Parsha.ACHREI_MOS_KEDOSHIM: "אחרי מות קדושים",
    Parsha.BEHAR_BECHUKOSAI: "בהר בחקתי",
    Parsha.CHUKAS_BALAK: "חוקת בלק",
    Parsha.MATOS_MASEI: "מטות מסעי",
    Parsha.NITZAVIM_VAYEILECH: "ניצבים וילך",
    Parsha.SHKALIM: "שקלים",
    Parsha.ZACHOR: "זכור",
    Parsha.PARA: "פרה",
    Parsha.HACHODESH: "החדש",
  };

  /// List of holidays transliterated into Latin chars. This is used by the
  /// _[formatYomTov(JewishCalendar)]_ when formatting the Yom Tov String. The default list of months uses
  /// Ashkenazi pronunciation in typical American English spelling.
  List<String> transliteratedHolidays = [
    "Erev Pesach",
    "Pesach",
    "Chol Hamoed Pesach",
    "Pesach Sheni",
    "Erev Shavuos",
    "Shavuos",
    "Seventeenth of Tammuz",
    "Tishah B'Av",
    "Tu B'Av",
    "Erev Rosh Hashana",
    "Rosh Hashana",
    "Fast of Gedalyah",
    "Erev Yom Kippur",
    "Yom Kippur",
    "Erev Succos",
    "Succos",
    "Chol Hamoed Succos",
    "Hoshana Rabbah",
    "Shemini Atzeres",
    "Simchas Torah",
    "Erev Chanukah",
    "Chanukah",
    "Tenth of Teves",
    "Tu B'Shvat",
    "Fast of Esther",
    "Purim",
    "Shushan Purim",
    "Purim Katan",
    "Erev Rosh Chodesh",
    "Rosh Chodesh",
    "Yom HaShoah",
    "Yom Hazikaron",
    "Yom Ha'atzmaut",
    "Yom Yerushalayim",
    "Lag B'Omer",
    "Shushan Purim Katan"
  ];

  /// Hebrew holiday list
  final List<String> _hebrewHolidays = [
    'ערב פסח',
    'פסח',
    'חול המועד פסח',
    'פסח שני',
    'ערב שבועות',
    'שבועות',
    'שבעה עשר בתמוז',
    'תשעה באב',
    'ט״ו באב',
    'ערב ראש השנה',
    'ראש השנה',
    'צום גדליה',
    'ערב יום כיפור',
    'יום כיפור',
    'ערב סוכות',
    'סוכות',
    'חול המועד סוכות',
    'הושענא רבה',
    'שמיני עצרת',
    'שמחת תורה',
    'ערב חנוכה',
    'חנוכה',
    'עשרה בטבת',
    'ט״ו בשבט',
    'תענית אסתר',
    'פורים',
    'פורים שושן',
    'פורים קטן',
    'ערב ראש חודש',
    'ראש חודש',
    'יום השואה',
    'יום הזיכרון',
    'יום העצמאות',
    'יום ירושלים',
    'ל״ג בעומר',
    'פורים שושן קטן'
  ];

  final List<String> _hebrewShortHolidays = [
    'ער״פ',
    'פסח',
    'חוהמ״פ',
    'פ״ש',
    'ערב שבועות',
    'שבועות',
    'יז בתמוז',
    'תשעה באב',
    'ט״ו באב',
    'ער״ה',
    'ר״ה',
    'צום גדליה',
    'עיו"כ',
    'כיפור',
    'ערב סוכות',
    'סוכות',
    'חומה״ס',
    'הו״ר',
    'שמ״ע',
    'שמח״ת',
    'ערב חנוכה',
    'חנוכה',
    'עשרה בטבת',
    'ט״ו בשבט',
    'תענית אסתר',
    'פורים',
    'פורים שושן',
    'פורים קטן',
    'ער״ח	',
    'ר״ח',
    'יום השואה',
    'יום הזיכרון',
    'יום העצמאות',
    'יום ירושלים',
    'ל״ג בעומר',
    'פורים שושן קטן'
  ];

  static final List<String> _longOmerDay = [
    "הַיּוֹם יוֹם אֶחָד לָעֹמֶר:",
    "הַיּוֹם שְׁנֵי יָמִים לָעֹמֶר:",
    "הַיּוֹם שְׁלֹשָׁה יָמִים לָעֹמֶר:",
    "הַיּוֹם אַרְבָּעָה יָמִים לָעֹמֶר:",
    "הַיּוֹם חֲמִשָּׁה יָמִים לָעֹמֶר:",
    "הַיּוֹם שִׁשָּׁה יָמִים לָעֹמֶר:",
    "הַיּוֹם שִׁבְעָה יָמִים לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד:",
    "הַיּוֹם שְׁמוֹנָה יָמִים לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד ויוֹם אֶחָד:",
    "הַיּוֹם תִּשְׁעָה יָמִים לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד וּשְׁנֵי יָמִים:",
    "הַיּוֹם עֲשָׂרָה יָמִים לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד וּשְׁלֹשָׁה יָמִים:",
    "הַיּוֹם אַחַד עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד ואַרְבָּעָה יָמִים:",
    "הַיּוֹם שְׁנֵים עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד וַחֲמִשָּׁה יָמִים:",
    "הַיּוֹם שְׁלֹשָׁה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד ושִׁשָּׁה יָמִים:",
    "הַיּוֹם אַרְבָּעָה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שׁנֵי שָׁבוּעוֹת:",
    "הַיּוֹם חֲמִשָּׁה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שׁנֵי שָׁבוּעוֹת ויוֹם אֶחָד:",
    "הַיּוֹם שִׁשָּׁה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שׁנֵי שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
    "הַיּוֹם שִׁבְעָה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שׁנֵי שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
    "הַיּוֹם שְׁמוֹנָה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שׁנֵי שָׁבוּעוֹת ואַרְבָּעָה יָמִים:",
    "הַיּוֹם תִּשְׁעָה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שׁנֵי שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
    "הַיּוֹם עֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שׁנֵי שָׁבוּעוֹת ושִׁשָּׁה יָמִים:",
    "הַיּוֹם אֶחָד וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שׁלֹשָׁה שָׁבוּעוֹת:",
    "הַיּוֹם שְׁנַיִם וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שׁלֹשָׁה שָׁבוּעוֹת ויוֹם אֶחָד:",
    "הַיּוֹם שְׁלֹשָׁה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שׁלֹשָׁה שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
    "הַיּוֹם אַרְבָּעָה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שׁלֹשָׁה שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
    "הַיּוֹם חֲמִשָּׁה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שׁלֹשָׁה שָׁבוּעוֹת ואַרְבָּעָה יָמִים:",
    "הַיּוֹם שִׁשָּׁה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שׁלֹשָׁה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
    "הַיּוֹם שִׁבְעָה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שׁלֹשָׁה שָׁבוּעוֹת ושִׁשָּׁה יָמִים:",
    "הַיּוֹם שְׁמוֹנָה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת:",
    "הַיּוֹם תִּשְׁעָה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת ויוֹם אֶחָד:",
    "הַיּוֹם שׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
    "הַיּוֹם אֶחָד וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
    "הַיּוֹם שְׁנַיִם וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת ואַרְבָּעָה יָמִים:",
    "הַיּוֹם שְׁלֹשָׁה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
    "הַיּוֹם אַרְבָּעָה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת ושִׁשָּׁה יָמִים:",
    "הַיּוֹם חֲמִשָּׁה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת:",
    "הַיּוֹם שִׁשָּׁה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת ויוֹם אֶחָד:",
    "הַיּוֹם שִׁבְעָה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
    "הַיּוֹם שְׁמוֹנָה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
    "הַיּוֹם תִּשְׁעָה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת ואַרְבָּעָה יָמִים:",
    "הַיּוֹם אַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
    "הַיּוֹם אֶחָד וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת ושִׁשָּׁה יָמִים:",
    "הַיּוֹם שְׁנַיִם וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת:",
    "הַיּוֹם שְׁלֹשָׁה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת ויוֹם אֶחָד:",
    "הַיּוֹם אַרְבָּעָה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
    "הַיּוֹם חֲמִשָּׁה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
    "הַיּוֹם שִׁשָּׁה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת ואַרְבָּעָה יָמִים:",
    "הַיּוֹם שִׁבְעָה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
    "הַיּוֹם שְׁמוֹנָה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת ושִׁשָּׁה יָמִים:",
    "הַיּוֹם תִּשְׁעָה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁבְעָה שָׁבוּעוֹת:"
  ];

  /// Formats the Yom Tov (holiday) in Hebrew or transliterated Latin characters.
  ///
  /// @param jewishCalendar the JewishCalendar
  /// @return the formatted holiday or an empty String if the day is not a holiday.
  /// @see #isHebrewFormat()
  String formatYomTov(JewishCalendar jewishCalendar) {
    int index = jewishCalendar.getYomTovIndex();
    if (index == JewishCalendar.CHANUKAH) {
      int dayOfChanukah = jewishCalendar.getDayOfChanukah();
      return hebrewFormat
          ? ("${formatHebrewNumber(dayOfChanukah)} ${_hebrewHolidays[index]}")
          : ("${transliteratedHolidays[index]} $dayOfChanukah");
    }
    return index == -1
        ? ""
        : hebrewFormat
            ? (useShortHolidayFormat
                ? _hebrewShortHolidays[index]
                : _hebrewHolidays[index])
            : transliteratedHolidays[index];
  }

  /// Formats a day as Rosh Chodesh in the format of in the format of ראש חודש שבט
  /// or Rosh Chodesh Shevat. If it is not Rosh Chodesh, an empty <code>String</code> will be returned.
  /// @param jewishCalendar the JewishCalendar
  /// @return The formatted <code>String</code> in the format of ראש חודש שבט
  /// or Rosh Chodesh Shevat. If it is not Rosh Chodesh, an empty <code>String</code> will be returned.
  String formatRoshChodesh(JewishCalendar jewishCalendar) {
    if (!jewishCalendar.isRoshChodesh()) {
      return "";
    }
    String formattedRoshChodesh = "";
    int month = jewishCalendar.getJewishMonth();
    if (jewishCalendar.getJewishDayOfMonth() == 30) {
      if (month < JewishDate.ADAR ||
          (month == JewishDate.ADAR && jewishCalendar.isJewishLeapYear())) {
        month++;
      } else {
        // roll to Nissan
        month = JewishDate.NISSAN;
      }
    }

    // This method is only about formatting, so we shouldn't make any changes to the params passed in...
    jewishCalendar = jewishCalendar.clone();
    jewishCalendar.setJewishMonth(month);
    formattedRoshChodesh = hebrewFormat
        ? (useShortHolidayFormat
            ? _hebrewShortHolidays[JewishCalendar.ROSH_CHODESH]
            : _hebrewHolidays[JewishCalendar.ROSH_CHODESH])
        : transliteratedHolidays[JewishCalendar.ROSH_CHODESH];
    formattedRoshChodesh += " ${formatMonth(jewishCalendar)}";
    return formattedRoshChodesh;
  }

  /// Formats a day as Erev Rosh Chodesh in the format of in the format of ערב ראש חודש שבט
  /// or Rosh Chodesh Shevat. If it is not Erev Rosh Chodesh, an empty <code>String</code> will be returned.
  /// @param jewishCalendar the JewishCalendar
  /// @return The formatted <code>String</code> in the format of ערב ראש חודש שבט
  /// or Rosh Chodesh Shevat. If it is not Rosh Chodesh, an empty <code>String</code> will be returned.
  String formatErevRoshChodesh(JewishCalendar jewishCalendar) {
    if (!jewishCalendar.isErevRoshChodesh()) {
      return "";
    }
    String formattedErevRoshChodesh = "";
    int month = jewishCalendar.getJewishMonth();
    if (jewishCalendar.getJewishDayOfMonth() == 29) {
      if (month < JewishDate.ADAR ||
          (month == JewishDate.ADAR && jewishCalendar.isJewishLeapYear())) {
        month++;
      } else {
        // roll to Nissan
        month = JewishDate.NISSAN;
      }
    }

    // This method is only about formatting, so we shouldn't make any changes to the params passed in...
    jewishCalendar = jewishCalendar.clone();
    jewishCalendar.setJewishMonth(month);
    formattedErevRoshChodesh = hebrewFormat
        ? (useShortHolidayFormat
            ? _hebrewShortHolidays[JewishCalendar.EREV_ROSH_CHODESH]
            : _hebrewHolidays[JewishCalendar.EREV_ROSH_CHODESH])
        : transliteratedHolidays[JewishCalendar.EREV_ROSH_CHODESH];
    formattedErevRoshChodesh += " ${formatMonth(jewishCalendar)}";
    return formattedErevRoshChodesh;
  }

  /// Formats the day of week. If {@link #isHebrewFormat() Hebrew formatting} is set, it will display in the format ראשון etc.
  /// If Hebrew formatting is not in use it will return it in the format
  /// of Sunday etc. There are various formatting options that will affect the output.
  ///
  /// @param jewishDate the JewishDate Object
  /// @return the formatted day of week
  /// @see #isHebrewFormat()
  /// @see #isLongWeekFormat()
  String formatDayOfWeek(JewishDate jewishDate) {
    if (hebrewFormat) {
      if (longWeekFormat) {
        return _hebrewDaysOfWeek[jewishDate.getDayOfWeek() - 1];
      } else {
        if (jewishDate.getDayOfWeek() == 7) {
          return formatHebrewNumber(300);
        } else {
          return formatHebrewNumber(jewishDate.getDayOfWeek());
        }
      }
    } else {
      if (jewishDate.getDayOfWeek() == 7) {
        if (longWeekFormat) {
          return transliteratedShabbosDayOfWeek;
        } else {
          return transliteratedShabbosDayOfWeek.substring(0, 3);
        }
      } else {
        return DateFormat("EEE").format(jewishDate.getGregorianCalendar());
      }
    }
  }

  /// Formats the Jewish date. The default format is "day Month year", for example if the formatter is set to Hebrew
  /// it will כ״א שבט תשכ״ט, and the format "21 Shevat, 5729" if not. The format can be change by pattern variable.
  /// The following symbol are available in explicit patterns:
  ///
  ///     Symbol   Meaning                Presentation       Example
  ///     ------   -------                ------------       -------
  ///     yy       year                   (Number)           תשכ"ט
  ///     MM       month in year          (Text & Number)    שבט
  ///     dd       day in month           (Number)           כ"א
  ///     hh       hour in am/pm (1~12)   (Number)           12
  ///     HH       hour in day (0~23)     (Number)           0
  ///     mm       minute in hour         (Number)           30
  ///     ss       second in minute       (Number)           55
  ///     E        day of week            (Text)             שלישי
  ///     D        day in year            (Number)           189
  ///     a        am/pm marker           (Text)             PM
  /// @param jewishDate
  ///            the JewishDate to be formatted
  /// @param pattern
  ///             The default pattern is "dd MM yy", for example if the formatter is set to Hebrew
  ///             it will כ״א שבט תשכ״ט, and "21 Shevat, 5729" if not.
  /// @return the formatted date.
  ///             If the formatter is set to Hebrew, it will format in the form, "day Month year"
  ///             by default for example כ״א שבט תשכ״ט, and the format "21 Shevat, 5729" if not.
  String format(JewishDate jewishDate, {String pattern = 'dd MM yy'}) {
    String formatDate;
    StringBuffer stringBuffer = StringBuffer();
    RegExp exp =
        RegExp(r"(dd)|(MM)|(yy)|(yyy)|(mm)|(hh)|(HH)|(ss)|[aED]|[/\-: ]");
    Iterable<Match> matches = exp.allMatches(pattern);
    for (var element in matches) {
      stringBuffer.write(element.group(0));
    }
    formatDate = stringBuffer.toString();
    // fix for "Sivan", "Adar"
    final String pasedFormatDate = stringBuffer.toString();
    if (pasedFormatDate.contains("dd")) {
      formatDate = formatDate.replaceAll(
          "dd",
          hebrewFormat
              ? formatHebrewNumber(jewishDate.getJewishDayOfMonth())
              : '${jewishDate.getJewishDayOfMonth()}');
    }
    if (pasedFormatDate.contains("MM")) {
      formatDate = formatDate.replaceAll("MM", formatMonth(jewishDate));
    }
    if (pasedFormatDate.contains("yy")) {
      formatDate = formatDate.replaceAll(
          "yy",
          hebrewFormat
              ? formatHebrewNumber(jewishDate.getJewishYear())
              : '${jewishDate.getJewishYear()}');
    }
    if (pasedFormatDate.contains("hh")) {
      formatDate = formatDate.replaceAll(
          "hh", DateFormat("hh").format(jewishDate.getGregorianCalendar()));
    }
    if (pasedFormatDate.contains("HH")) {
      formatDate = formatDate.replaceAll(
          "HH", DateFormat("HH").format(jewishDate.getGregorianCalendar()));
    }
    if (pasedFormatDate.contains("mm")) {
      formatDate = formatDate.replaceAll(
          "mm", DateFormat("mm").format(jewishDate.getGregorianCalendar()));
    }
    if (pasedFormatDate.contains("ss")) {
      formatDate = formatDate.replaceAll(
          "ss", DateFormat("ss").format(jewishDate.getGregorianCalendar()));
    }
    if (pasedFormatDate.contains("a")) {
      formatDate = formatDate.replaceAll(
          "a", DateFormat("a").format(jewishDate.getGregorianCalendar()));
    }
    // fix for "Elul"
    if (pasedFormatDate.contains(" E ")) {
      formatDate =
          formatDate.replaceAll(" E ", ' ${formatDayOfWeek(jewishDate)} ');
    }
    if (pasedFormatDate.contains("D")) {
      formatDate = formatDate.replaceAll(
          "D", jewishDate.getDaysInJewishYear().toString());
    }

    return formatDate;
  }

  /// Returns a string of the current Hebrew month such as "Tishrei".
  /// Returns a string of the current Hebrew month such as "אדר ב׳".
  ///
  /// @param jewishDate
  ///            the JewishDate to format
  /// @return the formatted month name
  /// @see #isHebrewFormat()
  /// @see #setHebrewFormat(boolean)
  /// @see #getTransliteratedMonthList()
  /// @see #setTransliteratedMonthList(String[])
  String formatMonth(JewishDate jewishDate) {
    final int month = jewishDate.getJewishMonth();
    if (hebrewFormat) {
      if (jewishDate.isJewishLeapYear() && month == JewishDate.ADAR) {
        return hebrewMonths[13] +
            (useGershGershayim
                ? _GERESH
                : ""); // return Adar I, not Adar in a leap year
      } else if (jewishDate.isJewishLeapYear() && month == JewishDate.ADAR_II) {
        return hebrewMonths[12] + (useGershGershayim ? _GERESH : "");
      } else {
        return hebrewMonths[month - 1];
      }
    } else {
      if (jewishDate.isJewishLeapYear() && month == JewishDate.ADAR) {
        return transliteratedMonths[
            13]; // return Adar I, not Adar in a leap year
      } else {
        return transliteratedMonths[month - 1];
      }
    }
  }

  /// Returns a String of the Omer day in the form ל״ג בעומר if Hebrew Format is set,
  /// or "Omer X" or "Lag BaOmer" if not. An empty string if there is no Omer this day.
  ///
  /// @param jewishCalendar
  ///            the JewishCalendar to be formatted
  ///
  /// @return a String of the Omer day in the form or an empty string if there is no Omer this day. The default
  ///         formatting has a ב׳ prefix that would output בעומר, but this
  ///         can be set via the {@link #hebrewOmerPrefix}  to use a ל and output ל״ג לעומר.
  /// @see #isHebrewFormat()
  /// @see #getHebrewOmerPrefix()
  /// @see #setHebrewOmerPrefix(String)
  String formatOmer(JewishCalendar jewishCalendar) {
    int omer = jewishCalendar.getDayOfOmer();
    if (omer == -1) {
      return "";
    }
    if (hebrewFormat) {
      return longOmerFormat
          ? _longOmerDay[omer]
          : "${formatHebrewNumber(omer)} $hebrewOmerPrefixעומר";
    } else {
      if (omer == 33) {
        // if lag b'omer
        return transliteratedHolidays[JewishCalendar.LAG_BAOMER];
      } else {
        return "Omer $omer";
      }
    }
  }

  ///Experimental and incomplete
  ///
  ///@param moladChalakim
  ///@return the formatted molad. FIXME: define proper format in English and Hebrew.

  String formatMolad(double moladChalakim) {
    double adjustedChalakim = moladChalakim;
    const int MINUTE_CHALAKIM = 18;
    const int HOUR_CHALAKIM = 1080;
    const int DAY_CHALAKIM = 24 * HOUR_CHALAKIM;

    double days = adjustedChalakim / DAY_CHALAKIM;
    adjustedChalakim = adjustedChalakim - (days * DAY_CHALAKIM);
    int hours = ((adjustedChalakim ~/ HOUR_CHALAKIM));
    if (hours >= 6) {
      days += 1;
    }
    adjustedChalakim = adjustedChalakim - (hours * HOUR_CHALAKIM);
    int minutes = (adjustedChalakim ~/ MINUTE_CHALAKIM);
    adjustedChalakim = adjustedChalakim - minutes * MINUTE_CHALAKIM;
    return "Day:  ${days % 7} hours: $hours , minutes $minutes , chalakim: $adjustedChalakim";
  }

  /// Returns the kviah in the traditional 3 letter Hebrew format where the first letter represents the day of week of
  /// Rosh Hashana, the second letter represents the lengths of Cheshvan and Kislev ({@link JewishDate#SHELAIMIM
  /// Shelaimim} , {@link JewishDate#KESIDRAN Kesidran} or {@link JewishDate#CHASERIM Chaserim}) and the 3rd letter
  /// represents the day of week of Pesach. For example 5729 (1969) would return בשה (Rosh Hashana on
  /// Monday, Shelaimim, and Pesach on Thursday), while 5771 (2011) would return השג (Rosh Hashana on
  /// Thursday, Shelaimim, and Pesach on Tuesday).
  ///
  /// @param jewishYear
  ///            the Jewish year
  /// @return the Hebrew String such as בשה for 5729 (1969) and השג for 5771 (2011).
  String getFormattedKviah(int jewishYear) {
    JewishDate jewishDate = JewishDate.initDate(
        jewishYear: jewishYear,
        jewishMonth: JewishDate.TISHREI,
        jewishDayOfMonth: 1); // set date to Rosh Hashana
    int kviah = jewishDate.getCheshvanKislevKviah();
    int roshHashanaDayOfweek = jewishDate.getDayOfWeek();
    String returnValue = formatHebrewNumber(roshHashanaDayOfweek);
    returnValue += (kviah == JewishDate.CHASERIM
        ? "ח"
        : kviah == JewishDate.SHELAIMIM
            ? "ש"
            : "כ");
    jewishDate.setJewishDate(
        jewishYear, JewishDate.NISSAN, 15); // set to Pesach of the given year
    int pesachDayOfweek = jewishDate.getDayOfWeek();
    returnValue += formatHebrewNumber(pesachDayOfweek);
    returnValue = returnValue.replaceAll(
        _GERESH, ""); // geresh is never used in the kviah format
    // boolean isLeapYear = JewishDate.isJewishLeapYear(jewishYear);
    // for efficiency we can avoid the expensive recalculation of the pesach day of week by adding 1 day to Rosh
    // Hashana for a 353 day year, 2 for a 354 day year, 3 for a 355 or 383 day year, 4 for a 384 day year and 5 for
    // a 385 day year
    return returnValue;
  }

  ///
  /// Formats the [Daf Yomi](https://en.wikipedia.org/wiki/Daf_Yomi) Bavli in the format of
  /// "&#x05E2;&#x05D9;&#x05E8;&#x05D5;&#x05D1;&#x05D9;&#x05DF; &#x05E0;&#x05F4;&#x05D1;" in [hebrewFormat],
  /// or the transliterated format of "Eruvin 52".
  ///
  /// @param daf the Daf to be formatted.
  /// @return the formatted daf.
  ///
  String formatDafYomiBavli(Daf daf) {
    if (hebrewFormat) {
      return "${daf.getMasechta()} ${formatHebrewNumber(daf.getDaf())}";
    } else {
      return "${daf.getMasechtaTransliterated()} ${daf.getDaf()}";
    }
  }

  ///
  /// Formats the [Daf Yomi Yerushalmi](https://en.wikipedia.org/wiki/Jerusalem_Talmud#Daf_Yomi_Yerushalmi) in the format
  /// of "&#x05E2;&#x05D9;&#x05E8;&#x05D5;&#x05D1;&#x05D9;&#x05DF; &#x05E0;&#x05F4;&#x05D1;" in {@link #isHebrewFormat() Hebrew}, or
  /// the transliterated format of "Eruvin 52".
  ///
  /// @param daf the Daf to be formatted.
  /// @return the formatted daf.
  ///
  String formatDafYomiYerushalmi(Daf daf) {
    if (hebrewFormat) {
      String dafName =
          daf.getDaf() == 0 ? "" : " ${formatHebrewNumber(daf.getDaf())}";
      return daf.getYerushalmiMasechta() + dafName;
    } else {
      String dafName = daf.getDaf() == 0 ? "" : " ${daf.getDaf()}";
      return daf.getYerushlmiMasechtaTransliterated() + dafName;
    }
  }

  /// Returns a Hebrew formatted string of a number. The method can calculate from 0 - 9999.
  /// <ul>
  /// <li>Single digit numbers such as 3, 30 and 100 will be returned with a ׳ (<a
  /// href="http://en.wikipedia.org/wiki/Geresh">Geresh</a>) appended as at the end. For example ג׳, and ק׳</li>
  /// <li>multi digit numbers such as 21 and 769 will be returned with a ״ (<a href="http://en.wikipedia.org/wiki/Gershayim">Gershayim</a>)
  /// between the second to last and last letters. For example כ״א, תשכ״ט</li>
  /// <li>15 and 16 will be returned as ט״ו and ט״ז</li>
  /// <li>Single digit numbers (years assumed) such as 6000 (%1000=0) will be returned as ו׳ אלפים</li>
  /// <li>0 will return אפס</li>
  /// </ul>
  ///
  /// @param number
  ///            the number to be formatted. It will trow an IllegalArgumentException if the number is &lt; 0 or &gt; 9999.
  /// @return the Hebrew formatted number such as תשכ״ט;
  /// @see #isUseFinalFormLetters()
  /// @see #isUseGershGershayim()
  /// @see #isHebrewFormat()
  ///
  String formatHebrewNumber(int number) {
    if (number < 0) {
      throw ArgumentError("negative numbers can't be formatted");
    } else if (number > 9999) {
      throw ArgumentError("numbers > 9999 can't be formatted");
    }

    const String ALAFIM = "אלפים";
    const String EFES = "אפס";

    List<String> jHundreds = [
      "",
      "ק",
      "ר",
      "ש",
      "ת",
      "תק",
      "תר",
      "תש",
      "תת",
      "תתק"
    ];
    List<String> jTens = ["", "י", "כ", "ל", "מ", "נ", "ס", "ע", "פ", "צ"];
    List<String> jTenEnds = ["", "י", "ך", "ל", "ם", "ן", "ס", "ע", "ף", "ץ"];
    List<String> tavTaz = ["טו", "טז"];
    List<String> jOnes = ["", "א", "ב", "ג", "ד", "ה", "ו", "ז", "ח", "ט"];

    if (number == 0) {
      // do we really need this? Should it be applicable to a date?
      return EFES;
    }
    int shortNumber = number % 1000; // discard thousands
    // next check for all possible single Hebrew digit years
    bool singleDigitNumber = (shortNumber < 11 ||
        (shortNumber < 100 && shortNumber % 10 == 0) ||
        (shortNumber <= 400 && shortNumber % 100 == 0));
    int thousands = number ~/ 1000; // get # thousands
    StringBuffer sb = StringBuffer();
    // append thousands to String
    if (number % 1000 == 0) {
      // in year is 5000, 4000 etc
      sb.write(jOnes[thousands]);
      if (useGershGershayim) {
        sb.write(_GERESH);
      }
      sb.write(" ");
      sb.write(
          ALAFIM); // add # of thousands plus word thousand (overide alafim boolean)
      return sb.toString();
    } else if (useLongHebrewYears && number >= 1000) {
      // if alafim boolean display thousands
      sb.write(jOnes[thousands]);
      if (useGershGershayim) {
        sb.write(_GERESH); // write thousands quote
      }
      sb.write(" ");
    }
    number = number % 1000; // remove 1000s
    int hundreds = number ~/ 100; // # of hundreds
    sb.write(jHundreds[hundreds]); // add hundreds to String
    number = number % 100; // remove 100s
    if (number == 15) {
      // special case 15
      sb.write(tavTaz[0]);
    } else if (number == 16) {
      // special case 16
      sb.write(tavTaz[1]);
    } else {
      int tens = number ~/ 10;
      if (number % 10 == 0) {
        // if evenly divisable by 10
        if (!singleDigitNumber) {
          if (useFinalFormLetters) {
            sb.write(jTenEnds[
                tens]); // years like 5780 will end with a final form &#x05E3;
          } else {
            sb.write(jTens[
                tens]); // years like 5780 will end with a regular &#x05E4;
          }
        } else {
          sb.write(jTens[
              tens]); // standard letters so years like 5050 will end with a regular nun
        }
      } else {
        sb.write(jTens[tens]);
        number = number % 10;
        sb.write(jOnes[number]);
      }
    }
    if (useGershGershayim) {
      if (singleDigitNumber) {
        sb.write(_GERESH); // write single quote
      } else {
        // write double quote before last digit
        String str = sb.toString();
        return '${str.substring(0, str.length - 1)}$_GERSHAYIM${str.substring(str.length - 1, str.length)}';
      }
    }
    return sb.toString();
  }

  /// Returns a String with the name of the current parsha(ios). If the formatter is set to format in Hebrew, returns
  /// a string of the current parsha(ios) in Hebrew for example בראשית or ניצבים וילך or an empty string if there
  /// are none. If not set to Hebrew, it returns a string of the parsha(ios) transliterated into Latin chars. The
  /// default uses Ashkenazi pronunciation in typical American English spelling, for example Bereshis or
  /// Nitzavim Vayeilech or an empty string if there are none.
  ///
  /// @param jewishCalendar the JewishCalendar Object
  /// @return today's parsha(ios) in Hebrew for example, if the formatter is set to format in Hebrew, returns a string
  ///         of the current parsha(ios) in Hebrew for example בראשית or ניצבים וילך or an empty string if
  ///         there are none. If not set to Hebrew, it returns a string of the parsha(ios) transliterated into Latin
  ///         chars. The default uses Ashkenazi pronunciation in typical American English spelling, for example
  ///         Bereshis or Nitzavim Vayeilech or an empty string if there are none.
  String formatParsha(JewishCalendar jewishCalendar) {
    Parsha parsha = jewishCalendar.getParshah();
    return (hebrewFormat
        ? hebrewParshaMap[parsha]
        : transliteratedParshaMap[parsha])!;
  }

  /// Returns a String with the name of the current parsha(ios) on this week. If the formatter is set to format in Hebrew, returns
  /// a string of the parsha(ios) in Hebrew for example בראשית or ניצבים וילך.
  /// If not set to Hebrew, it returns a string of the parsha(ios) transliterated into Latin chars. The
  /// default uses Ashkenazi pronunciation in typical American English spelling, for example Bereshis or
  /// Nitzavim Vayeilech.
  ///
  /// @param jewishCalendar the JewishCalendar Object
  /// @return week's parsha(ios) in Hebrew for example, if the formatter is set to format in Hebrew, returns a string
  ///         of the parsha(ios) in Hebrew for example בראשית or ניצבים וילך .
  ///         If not set to Hebrew, it returns a string of the parsha(ios) transliterated into Latin
  ///         chars. The default uses Ashkenazi pronunciation in typical American English spelling, for example
  ///         Bereshis or Nitzavim Vayeilech.
  String formatWeeklyParsha(JewishCalendar jewishCalendar) {
    int delta = 7 - jewishCalendar.getDayOfWeek();
    DateTime date =
        DateTime.parse(jewishCalendar.getGregorianCalendar().toIso8601String());
    JewishCalendar shabbosDay =
        JewishCalendar.fromDateTime(date.add(Duration(days: delta)));
    shabbosDay.inIsrael = jewishCalendar.inIsrael;
    return formatParsha(shabbosDay);
  }

  /// Returns a String with the name of the current special parsha of Shekalim, Zachor, Parah or Hachodesh or an
  /// empty String for a non-special parsha. If the formatter is set to format in Hebrew, it returns a string of
  /// the current special parsha in Hebrew, for example שקלים, זכור פרה or החדש. An empty
  /// string if the date is not a special parsha. If not set to Hebrew, it returns a string of the special parsha
  /// transliterated into Latin chars. The default uses Ashkenazi pronunciation in typical American English spelling
  /// Shekalim, Zachor, Parah or Hachodesh.
  ///
  /// @param jewishCalendar the JewishCalendar Object
  /// @return today's special parsha. If the formatter is set to format in Hebrew, returns a string
  ///         of the current special parsha  in Hebrew for in the format of שקלים, זכור, פרה or החדש or an empty
  ///         string if there are none. If not set to Hebrew, it returns a string of the special parsha transliterated
  ///         into Latin chars. The default uses Ashkenazi pronunciation in typical American English spelling of Shekalim,
  ///         Zachor, Parah or Hachodesh. An empty string if there are none.
  String formatSpecialParsha(JewishCalendar jewishCalendar) {
    Parsha specialParsha = jewishCalendar.getSpecialShabbos();
    return (hebrewFormat
        ? hebrewParshaMap[specialParsha]
        : transliteratedParshaMap[specialParsha])!;
  }

  List<String> getEventsList(JewishCalendar jewishCalendar,
      ComplexZmanimCalendar complexZmanimCalendar,
      {int maxEvents = 9}) {
    List<String> events = List.empty(growable: true);
    maxEvents = maxEvents > 9 ? 9 : maxEvents;
    if (jewishCalendar.isErevYomTov()) events.add(formatYomTov(jewishCalendar));
    if (jewishCalendar.isYomTov()) events.add(formatYomTov(jewishCalendar));
    if (jewishCalendar.isTaanis() &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR) {
      events.add(formatYomTov(jewishCalendar));
    }
    if (jewishCalendar.getDayOfWeek() == 7) {
      events.add(
          (hebrewFormat ? hebrewParshaPrefix : transliteratedParshaPrefix) +
              formatParsha(jewishCalendar));
    }
    if (jewishCalendar.isErevRoshChodesh()) {
      events.add(formatErevRoshChodesh(jewishCalendar));
    }
    if (jewishCalendar.isRoshChodesh()) {
      events.add(formatRoshChodesh(jewishCalendar));
    }
    if (jewishCalendar.getJewishDayOfMonth() == 15) {
      events.add(
          hebrewFormat ? "סוף זמן קידוש הלבנה " : "Sof Zman Kidush Levana");
    }
    if (jewishCalendar.isChanukah()) events.add(formatYomTov(jewishCalendar));
    if (jewishCalendar.getDayOfOmer() != -1) {
      events.add(formatOmer(jewishCalendar));
    }
    if (jewishCalendar.getDayOfWeek() == 6 && !jewishCalendar.isErevYomTov()) {
      events.add((hebrewFormat
              ? hebrewShabbosStartPrefix
              : transliteratedShabbosStartPrefix) +
          DateFormat('HH:mm')
              .format(complexZmanimCalendar.getShabbosStartTime()));
    }
    if (jewishCalendar.getDayOfWeek() == 7 &&
        !jewishCalendar.isYomTov() &&
        !jewishCalendar.isErevYomTov()) {
      events.add((hebrewFormat
              ? hebrewShabbosEndPrefix
              : transliteratedShabbosEndPrefix) +
          DateFormat('HH:mm')
              .format(complexZmanimCalendar.getShabbosExitTime()));
    }
    if (jewishCalendar.isErevYomTov() && jewishCalendar.getDayOfWeek() != 7) {
      events.add((hebrewFormat
              ? hebrewYomTovStartPrefix
              : transliteratedYomTovStartPrefix) +
          DateFormat('HH:mm')
              .format(complexZmanimCalendar.getYomTovStartTime()));
    }
    if (jewishCalendar.isYomTov() &&
        !jewishCalendar.isCholHamoed() &&
        jewishCalendar.isChanukah() &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_HAZIKARON &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_HAATZMAUT &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_YERUSHALAYIM &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.TU_BEAV &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.TU_BESHVAT &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.PURIM &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.PESACH_SHENI &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.LAG_BAOMER &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.SHUSHAN_PURIM_KATAN &&
        jewishCalendar.getYomTovIndex() != JewishCalendar.CHANUKAH &&
        (!jewishCalendar.isTaanis() ||
            jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR)) {
      events.add((hebrewFormat
              ? hebrewYomTovEndPrefix
              : transliteratedYomTovEndPrefix) +
          DateFormat('HH:mm')
              .format(complexZmanimCalendar.getYomTovExitTime()));
    }
    return events.length > maxEvents
        ? events.getRange(0, maxEvents - 1).toList()
        : events;
  }

  String getEvent(JewishCalendar jewishCalendar) {
    if (jewishCalendar.isErevYomTov()) return formatYomTov(jewishCalendar);
    if (jewishCalendar.isYomTov()) return formatYomTov(jewishCalendar);
    if (jewishCalendar.isTaanis()) return formatYomTov(jewishCalendar);
    if (jewishCalendar.getDayOfWeek() == 7) return formatParsha(jewishCalendar);
    if (jewishCalendar.isErevRoshChodesh()) {
      return formatErevRoshChodesh(jewishCalendar);
    }
    if (jewishCalendar.isRoshChodesh()) {
      return formatRoshChodesh(jewishCalendar);
    }
    if (jewishCalendar.getJewishDayOfMonth() == 15) {
      return hebrewFormat ? "סוף זמן קידוש הלבנה " : "Sof Zman Kidush Levana";
    }
    if (jewishCalendar.isChanukah()) return formatYomTov(jewishCalendar);
    if (jewishCalendar.getDayOfOmer() != -1) return formatOmer(jewishCalendar);
    return "";
  }
}
