/*
 * Zmanim Java API
 * Copyright (C) 2011 - 2019 Eliyahu Hershfeld
 * Copyright (C) September 2002 Avrom Finkelstien
 * Copyright (C) 2019 Y Paritcher
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

import 'package:kosher_dart/src/hebrewcalendar/jewish_date.dart';
import 'package:kosher_dart/src/hebrewcalendar/daf.dart';
import 'package:kosher_dart/src/hebrewcalendar/yerushalmi_yomi_calculator.dart';
import 'package:kosher_dart/src/hebrewcalendar/yomi_calculator.dart';
import 'package:kosher_dart/src/util/geo_Location.dart';

/// The JewishCalendar extends the JewishDate class and adds calendar methods.
///
/// This open source Java code was originally ported by <a href="http://www.facebook.com/avromf">Avrom Finkelstien</a>
/// from his C++ code. It was refactored to fit the KosherJava Zmanim API with simplification of the code, enhancements
/// and some bug fixing. The class allows setting whether the holiday and parsha scheme follows the Israel scheme or outside Israel
/// scheme. The default is the outside Israel scheme.
/// The parsha code was ported by Y Paritcher from his <a href="https://github.com/yparitcher/libzmanim">libzmanim</a> code.
///
/// @todo Some do not belong in this class, but here is a partial list of what should still be implemented in some form:
/// <ol>
/// <li>Add Isru Chag</li>
/// <li>Mishna yomis etc</li>
/// </ol>
///
/// @see java.util.Date
/// @see java.util.Calendar
/// @author &copy; Y Paritcher 2019
/// @author &copy; Avrom Finkelstien 2002
/// @author &copy; Eliyahu Hershfeld 2011 - 2019

/// The {@link #VZOS_HABERACHA} enum exists for consistency, but is not currently used.
///
enum Parsha {
  NONE,
  BERESHIS,
  NOACH,
  LECH_LECHA,
  VAYERA,
  CHAYEI_SARA,
  TOLDOS,
  VAYETZEI,
  VAYISHLACH,
  VAYESHEV,
  MIKETZ,
  VAYIGASH,
  VAYECHI,
  SHEMOS,
  VAERA,
  BO,
  BESHALACH,
  YISRO,
  MISHPATIM,
  TERUMAH,
  TETZAVEH,
  KI_SISA,
  VAYAKHEL,
  PEKUDEI,
  VAYIKRA,
  TZAV,
  SHMINI,
  TAZRIA,
  METZORA,
  ACHREI_MOS,
  KEDOSHIM,
  EMOR,
  BEHAR,
  BECHUKOSAI,
  BAMIDBAR,
  NASSO,
  BEHAALOSCHA,
  SHLACH,
  KORACH,
  CHUKAS,
  BALAK,
  PINCHAS,
  MATOS,
  MASEI,
  DEVARIM,
  VAESCHANAN,
  EIKEV,
  REEH,
  SHOFTIM,
  KI_SEITZEI,
  KI_SAVO,
  NITZAVIM,
  VAYEILECH,
  HAAZINU,
  VZOS_HABERACHA,
  VAYAKHEL_PEKUDEI,
  TAZRIA_METZORA,
  ACHREI_MOS_KEDOSHIM,
  BEHAR_BECHUKOSAI,
  CHUKAS_BALAK,
  MATOS_MASEI,
  NITZAVIM_VAYEILECH,
  SHKALIM,
  ZACHOR,
  PARA,
  HACHODESH
}
enum DayOfWeek {
  SUNDAY,
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY
}

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

  // static const int EREV_CHANUKAH = 20;// probably remove this
  static const int CHANUKAH = 21;
  static const int TENTH_OF_TEVES = 22;
  static const int TU_BESHVAT = 23;
  static const int FAST_OF_ESTHER = 24;
  static const int PURIM = 25;
  static const int SHUSHAN_PURIM = 26;
  static const int PURIM_KATAN = 27;
  static const int EREV_ROSH_CHODESH = 28;
  static const int ROSH_CHODESH = 29;
  static const int YOM_HASHOAH = 30;
  static const int YOM_HAZIKARON = 31;
  static const int YOM_HAATZMAUT = 32;
  static const int YOM_YERUSHALAYIM = 33;
  static const int LAG_BAOMER = 34;
  static const int SHUSHAN_PURIM_KATAN = 35;

  bool _inIsrael = false;
  bool _useModernHolidays = false;

  static const List<List<Parsha>> parshalist = [
    [
      Parsha.NONE,
      Parsha.VAYEILECH,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL_PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.NONE,
      Parsha.SHMINI,
      Parsha.TAZRIA_METZORA,
      Parsha.ACHREI_MOS_KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR_BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ],
    [
      Parsha.NONE,
      Parsha.VAYEILECH,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL_PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.NONE,
      Parsha.SHMINI,
      Parsha.TAZRIA_METZORA,
      Parsha.ACHREI_MOS_KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR_BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NONE,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS_BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ],
    [
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL_PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.SHMINI,
      Parsha.TAZRIA_METZORA,
      Parsha.ACHREI_MOS_KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR_BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM
    ],
    [
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.NONE,
      Parsha.SHMINI,
      Parsha.TAZRIA_METZORA,
      Parsha.ACHREI_MOS_KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR_BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM
    ],
    [
      Parsha.NONE,
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL_PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.NONE,
      Parsha.SHMINI,
      Parsha.TAZRIA_METZORA,
      Parsha.ACHREI_MOS_KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR_BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM
    ],
    [
      Parsha.NONE,
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL_PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.NONE,
      Parsha.SHMINI,
      Parsha.TAZRIA_METZORA,
      Parsha.ACHREI_MOS_KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR_BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ],
    [
      Parsha.NONE,
      Parsha.VAYEILECH,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.SHMINI,
      Parsha.TAZRIA,
      Parsha.METZORA,
      Parsha.NONE,
      Parsha.ACHREI_MOS,
      Parsha.KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NONE,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS_BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ],
    [
      Parsha.NONE,
      Parsha.VAYEILECH,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.SHMINI,
      Parsha.TAZRIA,
      Parsha.METZORA,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.ACHREI_MOS,
      Parsha.KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM
    ],
    [
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.SHMINI,
      Parsha.TAZRIA,
      Parsha.METZORA,
      Parsha.ACHREI_MOS,
      Parsha.NONE,
      Parsha.KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS,
      Parsha.MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM
    ],
    [
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.SHMINI,
      Parsha.TAZRIA,
      Parsha.METZORA,
      Parsha.ACHREI_MOS,
      Parsha.NONE,
      Parsha.KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS,
      Parsha.MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ],
    [
      Parsha.NONE,
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.SHMINI,
      Parsha.TAZRIA,
      Parsha.METZORA,
      Parsha.NONE,
      Parsha.ACHREI_MOS,
      Parsha.KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ],
    [
      Parsha.NONE,
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.SHMINI,
      Parsha.TAZRIA,
      Parsha.METZORA,
      Parsha.NONE,
      Parsha.ACHREI_MOS,
      Parsha.KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NONE,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS_BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ],
    [
      Parsha.NONE,
      Parsha.VAYEILECH,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL_PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.NONE,
      Parsha.SHMINI,
      Parsha.TAZRIA_METZORA,
      Parsha.ACHREI_MOS_KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR_BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ],
    [
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL_PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.NONE,
      Parsha.SHMINI,
      Parsha.TAZRIA_METZORA,
      Parsha.ACHREI_MOS_KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM
    ],
    [
      Parsha.NONE,
      Parsha.VAYEILECH,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.SHMINI,
      Parsha.TAZRIA,
      Parsha.METZORA,
      Parsha.NONE,
      Parsha.ACHREI_MOS,
      Parsha.KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ],
    [
      Parsha.NONE,
      Parsha.VAYEILECH,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.SHMINI,
      Parsha.TAZRIA,
      Parsha.METZORA,
      Parsha.NONE,
      Parsha.ACHREI_MOS,
      Parsha.KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS,
      Parsha.MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM
    ],
    [
      Parsha.NONE,
      Parsha.NONE,
      Parsha.HAAZINU,
      Parsha.NONE,
      Parsha.NONE,
      Parsha.BERESHIS,
      Parsha.NOACH,
      Parsha.LECH_LECHA,
      Parsha.VAYERA,
      Parsha.CHAYEI_SARA,
      Parsha.TOLDOS,
      Parsha.VAYETZEI,
      Parsha.VAYISHLACH,
      Parsha.VAYESHEV,
      Parsha.MIKETZ,
      Parsha.VAYIGASH,
      Parsha.VAYECHI,
      Parsha.SHEMOS,
      Parsha.VAERA,
      Parsha.BO,
      Parsha.BESHALACH,
      Parsha.YISRO,
      Parsha.MISHPATIM,
      Parsha.TERUMAH,
      Parsha.TETZAVEH,
      Parsha.KI_SISA,
      Parsha.VAYAKHEL,
      Parsha.PEKUDEI,
      Parsha.VAYIKRA,
      Parsha.TZAV,
      Parsha.SHMINI,
      Parsha.TAZRIA,
      Parsha.METZORA,
      Parsha.NONE,
      Parsha.ACHREI_MOS,
      Parsha.KEDOSHIM,
      Parsha.EMOR,
      Parsha.BEHAR,
      Parsha.BECHUKOSAI,
      Parsha.BAMIDBAR,
      Parsha.NASSO,
      Parsha.BEHAALOSCHA,
      Parsha.SHLACH,
      Parsha.KORACH,
      Parsha.CHUKAS,
      Parsha.BALAK,
      Parsha.PINCHAS,
      Parsha.MATOS_MASEI,
      Parsha.DEVARIM,
      Parsha.VAESCHANAN,
      Parsha.EIKEV,
      Parsha.REEH,
      Parsha.SHOFTIM,
      Parsha.KI_SEITZEI,
      Parsha.KI_SAVO,
      Parsha.NITZAVIM_VAYEILECH
    ]
  ];

  /// Is this calendar set to return modern Israeli national holidays. By default this value is false. The holidays
  /// are: "Yom HaShoah", "Yom Hazikaron", "Yom Ha'atzmaut" and "Yom Yerushalayim"
  ///
  /// @return the useModernHolidays true if set to return modern Israeli national holidays
  bool isUseModernHolidays() {
    return _useModernHolidays;
  }

  /// Seth the calendar to return modern Israeli national holidays. By default this value is false. The holidays are:
  /// "Yom HaShoah", "Yom Hazikaron", "Yom Ha'atzmaut" and "Yom Yerushalayim"
  ///
  /// @param useModernHolidays
  ///            the useModernHolidays to set
  void setUseModernHolidays(bool useModernHolidays) {
    this._useModernHolidays = useModernHolidays;
  }

  /// Default constructor will set a default date to the current system date.
  JewishCalendar() : super();

  /// A constructor that initializes the date to the {@link java.util.Date Date} parameter.
  ///
  /// @param date
  ///            the <code>Date</code> to set the calendar to
  JewishCalendar.fromDateTime(DateTime dateTime) : super.fromDateTime(dateTime);

  /// Creates a Jewish date based on a Jewish date and whether in Israel
  ///
  /// @param jewishYear
  ///            the Jewish year
  /// @param jewishMonth
  ///            the Jewish month. The method expects a 1 for Nissan ... 12 for Adar and 13 for Adar II. Use the
  ///            constants {@link #NISSAN} ... {@link #ADAR} (or {@link #ADAR_II} for a leap year Adar II) to avoid any
  ///            confusion.
  /// @param jewishDayOfMonth
  ///            the Jewish day of month. If 30 is passed in for a month with only 29 days (for example {@link #IYAR},
  ///            or {@link #KISLEV} in a year that {@link #isKislevShort()}), the 29th (last valid date of the month)
  ///            will be set
  /// @param inIsrael
  ///            whether in Israel. This affects Yom Tov calculations
  JewishCalendar.initDate(int jewishYear, int jewishMonth, int jewishDayOfMonth,
      {bool inIsrael = false})
      : super.initDate(
            jewishYear: jewishYear,
            jewishMonth: jewishMonth,
            jewishDayOfMonth: jewishDayOfMonth) {
    setInIsrael(inIsrael);
  }

  /// Sets whether to use Israel holiday scheme or not. Default is false.
  ///
  /// @param inIsrael
  ///            set to true for calculations for Israel
  void setInIsrael(bool inIsrael) {
    this._inIsrael = inIsrael;
  }

  /// Gets whether Israel holiday scheme is used or not. The default (if not set) is false.
  ///
  /// @return if the if the calendar is set to Israel
  bool getInIsrael() {
    return _inIsrael;
  }

  /// <a href="https://en.wikipedia.org/wiki/Birkat_Hachama">Birkas Hachamah</a> is recited every 28 years based on
  /// Tekufas Shmulel (Julian years) that a year is 365.25 days. The <a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a>
  /// in <a href="http://hebrewbooks.org/pdfpager.aspx?req=14278&amp;st=&amp;pgnum=323">Hilchos Kiddush Hachodesh 9:3</a> states that
  /// tekufas Nisan of year 1 was 7 days + 9 hours before molad Nisan. This is calculated as every 10,227 days (28 * 365.25).
  /// @return true for a day that Birkas Hachamah is recited.
  bool isBirkasHachamah() {
    int elapsedDays = JewishDate.getJewishCalendarElapsedDays(
        getJewishYear()); //elapsed days since molad ToHu
    elapsedDays = elapsedDays +
        getDaysSinceStartOfJewishYear(); //elapsed days to the current calendar date

    /* Molad Nisan year 1 was 177 days after molad tohu of Tishrei. We multiply 29.5 day months * 6 months from Tishrei
		 * to Nisan = 177. Subtract 7 days since tekufas Nisan was 7 days and 9 hours before the molad as stated in the Rambam
		 * and we are now at 170 days. Because getJewishCalendarElapsedDays and getDaysSinceStartOfJewishYear use the value for
		 * Rosh Hashana as 1, we have to add 1 day days for a total of 171. To this add a day since the tekufah is on a Tuesday
		 * night and we push off the bracha to Wednesday AM resulting in the 172 used in the calculation.
		 */
    if (elapsedDays % (28 * 365.25) == 172) {
      // 28 years of 365.25 days + the offset from molad tohu mentioned above
      return true;
    }
    return false;
  }

  /// Return the type of year for parsha calculations. The algorithm follows the
  /// <a href="http://hebrewbooks.org/pdfpager.aspx?req=14268&amp;st=&amp;pgnum=222">Luach Arba'ah Shearim</a> in the Tur Ohr Hachaim.
  /// @return the type of year for parsha calculations.
  int _getParshaYearType() {
    int roshHashanaDayOfWeek = (JewishDate.getJewishCalendarElapsedDays(
                getJewishYear()) +
            1) %
        7; // plus one to the original Rosh Hashana of year 1 to get a week starting on Sunday
    if (roshHashanaDayOfWeek == 0) {
      roshHashanaDayOfWeek = 7; // convert 0 to 7 for Shabbos for readability
    }
    if (isJewishLeapYear()) {
      switch (DayOfWeek.values[roshHashanaDayOfWeek - 1]) {
        case DayOfWeek.MONDAY:
          if (isKislevShort()) {
            //BaCh
            if (getInIsrael()) {
              return 14;
            }
            return 6;
          }
          if (isCheshvanLong()) {
            //BaSh
            if (getInIsrael()) {
              return 15;
            }
            return 7;
          }
          break;
        case DayOfWeek.TUESDAY: //Gak
          if (getInIsrael()) {
            return 15;
          }
          return 7;
        case DayOfWeek.THURSDAY:
          if (isKislevShort()) {
            //HaCh
            return 8;
          }
          if (isCheshvanLong()) {
            //HaSh
            return 9;
          }
          break;
        case DayOfWeek.SATURDAY:
          if (isKislevShort()) {
            //ZaCh
            return 10;
          }
          if (isCheshvanLong()) {
            //ZaSh
            if (getInIsrael()) {
              return 16;
            }
            return 11;
          }
          break;
        default:
          return -1;
      }
    } else {
      //not a leap year
      switch (DayOfWeek.values[roshHashanaDayOfWeek - 1]) {
        case DayOfWeek.MONDAY:
          if (isKislevShort()) {
            //BaCh
            return 0;
          }
          if (isCheshvanLong()) {
            //BaSh
            if (getInIsrael()) {
              return 12;
            }
            return 1;
          }
          break;
        case DayOfWeek.TUESDAY: //GaK
          if (getInIsrael()) {
            return 12;
          }
          return 1;
        case DayOfWeek.THURSDAY:
          if (isCheshvanLong()) {
            //HaSh
            return 3;
          }
          if (!isKislevShort()) {
            //Hak
            if (getInIsrael()) {
              return 13;
            }
            return 2;
          }
          break;
        case DayOfWeek.SATURDAY:
          if (isKislevShort()) {
            //ZaCh
            return 4;
          }
          if (isCheshvanLong()) {
            //ZaSh
            return 5;
          }
          break;
        default:
          return -1;
      }
    }
    return -1; //keep the compiler happy
  }

  /// Returns this week's {@link Parsha} if it is Shabbos.
  /// returns Parsha.NONE if a weekday or if there is no parshah that week (for example Yomtov is on Shabbos)
  /// @return the current parsha
  Parsha getParshah() {
    if (DayOfWeek.values[getDayOfWeek() - 1] != DayOfWeek.SATURDAY) {
      return Parsha.NONE;
    }

    int yearType = _getParshaYearType();
    int roshHashanaDayOfWeek =
        JewishDate.getJewishCalendarElapsedDays(getJewishYear()) % 7;
    int day = roshHashanaDayOfWeek + getDaysSinceStartOfJewishYear();

    if (yearType >= 0) {
      // negative year should be impossible, but lets cover all bases
      return parshalist[yearType][day ~/ 7];
    }
    return Parsha.NONE; //keep the compiler happy
  }

  /// Returns a parsha enum if the Shabbos is one of the four parshiyos of Parsha.SHKALIM, Parsha.ZACHOR, Parsha.PARA,
  /// Parsha.HACHODESH or Parsha.NONE for a regular Shabbos (or any weekday).
  /// @return one of the four parshiyos of Parsha.SHKALIM, Parsha.ZACHOR, Parsha.PARA, Parsha.HACHODESH or Parsha.NONE.
  Parsha getSpecialShabbos() {
    if (DayOfWeek.values[getDayOfWeek() - 1] == DayOfWeek.SATURDAY) {
      if ((getJewishMonth() == JewishDate.SHEVAT && !isJewishLeapYear()) ||
          (getJewishMonth() == JewishDate.ADAR && isJewishLeapYear())) {
        if (getJewishDayOfMonth() == 25 ||
            getJewishDayOfMonth() == 27 ||
            getJewishDayOfMonth() == 29) {
          return Parsha.SHKALIM;
        }
      }
      if ((getJewishMonth() == JewishDate.ADAR && !isJewishLeapYear()) ||
          getJewishMonth() == JewishDate.ADAR_II) {
        if (getJewishDayOfMonth() == 1) {
          return Parsha.SHKALIM;
        }
        if (getJewishDayOfMonth() == 8 ||
            getJewishDayOfMonth() == 9 ||
            getJewishDayOfMonth() == 11 ||
            getJewishDayOfMonth() == 13) {
          return Parsha.ZACHOR;
        }
        if (getJewishDayOfMonth() == 18 ||
            getJewishDayOfMonth() == 20 ||
            getJewishDayOfMonth() == 22 ||
            getJewishDayOfMonth() == 23) {
          return Parsha.PARA;
        }
        if (getJewishDayOfMonth() == 25 ||
            getJewishDayOfMonth() == 27 ||
            getJewishDayOfMonth() == 29) {
          return Parsha.HACHODESH;
        }
      }
      if (getJewishMonth() == JewishDate.NISSAN && getJewishDayOfMonth() == 1) {
        return Parsha.HACHODESH;
      }
    }
    return Parsha.NONE;
  }

  /// Returns an index of the Jewish holiday or fast day for the current day, or a -1 if there is no holiday for this
  /// day. There are constants in this class representing each Yom Tov. Formatting of the Yomim tovim is done in the
  /// ZmanimFormatter#
  /// @todo consider using enums instead of the constant ints.
  /// @return the index of the holiday such as the constant {@link #LAG_BAOMER} or {@link #YOM_KIPPUR} or a -1 if it is not a holiday.
  /// @see com.kosherjava.zmanim.hebrewcalendar.HebreDateFormatter
  int getYomTovIndex() {
    final int day = getJewishDayOfMonth();
    final int dayOfWeek = getDayOfWeek();

    // check by month (starting from Nissan)
    switch (getJewishMonth()) {
      case JewishDate.NISSAN:
        if (day == 14) {
          return EREV_PESACH;
        }
        if (day == 15 ||
            day == 21 ||
            (!_inIsrael && (day == 16 || day == 22))) {
          return PESACH;
        }
        if (day >= 17 && day <= 20 || (day == 16 && _inIsrael)) {
          return CHOL_HAMOED_PESACH;
        }
        if (isUseModernHolidays() &&
            ((day == 26 && dayOfWeek == 5) ||
                (day == 28 && dayOfWeek == 2) ||
                (day == 27 && dayOfWeek != 1 && dayOfWeek != 6))) {
          return YOM_HASHOAH;
        }
        break;
      case JewishDate.IYAR:
        if (isUseModernHolidays() &&
            ((day == 4 && dayOfWeek == 3) ||
                ((day == 3 || day == 2) && dayOfWeek == 4) ||
                (day == 5 && dayOfWeek == 2))) {
          return YOM_HAZIKARON;
        }
        // if 5 Iyar falls on Wed Yom Haatzmaut is that day. If it fal1s on Friday or Shabbos it is moved back to
        // Thursday. If it falls on Monday it is moved to Tuesday
        if (isUseModernHolidays() &&
            ((day == 5 && dayOfWeek == 4) ||
                ((day == 4 || day == 3) && dayOfWeek == 5) ||
                (day == 6 && dayOfWeek == 3))) {
          return YOM_HAATZMAUT;
        }
        if (day == 14) {
          return PESACH_SHENI;
        }
        if (day == 18) {
          return LAG_BAOMER;
        }
        if (isUseModernHolidays() && day == 28) {
          return YOM_YERUSHALAYIM;
        }
        break;
      case JewishDate.SIVAN:
        if (day == 5) {
          return EREV_SHAVUOS;
        }
        if (day == 6 || (day == 7 && !_inIsrael)) {
          return SHAVUOS;
        }
        break;
      case JewishDate.TAMMUZ:
        // push off the fast day if it falls on Shabbos
        if ((day == 17 && dayOfWeek != 7) || (day == 18 && dayOfWeek == 1)) {
          return SEVENTEEN_OF_TAMMUZ;
        }
        break;
      case JewishDate.AV:
        // if Tisha B'av falls on Shabbos, push off until Sunday
        if ((dayOfWeek == 1 && day == 10) || (dayOfWeek != 7 && day == 9)) {
          return TISHA_BEAV;
        }
        if (day == 15) {
          return TU_BEAV;
        }
        break;
      case JewishDate.ELUL:
        if (day == 29) {
          return EREV_ROSH_HASHANA;
        }
        break;
      case JewishDate.TISHREI:
        if (day == 1 || day == 2) {
          return ROSH_HASHANA;
        }
        if ((day == 3 && dayOfWeek != 7) || (day == 4 && dayOfWeek == 1)) {
          // push off Tzom Gedalia if it falls on Shabbos
          return FAST_OF_GEDALYAH;
        }
        if (day == 9) {
          return EREV_YOM_KIPPUR;
        }
        if (day == 10) {
          return YOM_KIPPUR;
        }
        if (day == 14) {
          return EREV_SUCCOS;
        }
        if (day == 15 || (day == 16 && !_inIsrael)) {
          return SUCCOS;
        }
        if (day >= 17 && day <= 20 || (day == 16 && _inIsrael)) {
          return CHOL_HAMOED_SUCCOS;
        }
        if (day == 21) {
          return HOSHANA_RABBA;
        }
        if (day == 22) {
          return SHEMINI_ATZERES;
        }
        if (day == 23 && !_inIsrael) {
          return SIMCHAS_TORAH;
        }
        break;
      case JewishDate.KISLEV: // no yomtov in CHESHVAN
        // if (day == 24) {
        // return EREV_CHANUKAH;
        // } else
        if (day >= 25) {
          return CHANUKAH;
        }
        break;
      case JewishDate.TEVES:
        if (day == 1 || day == 2 || (day == 3 && isKislevShort())) {
          return CHANUKAH;
        }
        if (day == 10) {
          return TENTH_OF_TEVES;
        }
        break;
      case JewishDate.SHEVAT:
        if (day == 15) {
          return TU_BESHVAT;
        }
        break;
      case JewishDate.ADAR:
        if (!isJewishLeapYear()) {
          // if 13th Adar falls on Friday or Shabbos, push back to Thursday
          if (((day == 11 || day == 12) && dayOfWeek == 5) ||
              (day == 13 && !(dayOfWeek == 6 || dayOfWeek == 7))) {
            return FAST_OF_ESTHER;
          }
          if (day == 14) {
            return PURIM;
          }
          if (day == 15) {
            return SHUSHAN_PURIM;
          }
        } else {
          // else if a leap year
          if (day == 14) {
            return PURIM_KATAN;
          }
          if (day == 15) {
            return SHUSHAN_PURIM_KATAN;
          }
        }
        break;
      case JewishDate.ADAR_II:
        // if 13th Adar falls on Friday or Shabbos, push back to Thursday
        if (((day == 11 || day == 12) && dayOfWeek == 5) ||
            (day == 13 && !(dayOfWeek == 6 || dayOfWeek == 7))) {
          return FAST_OF_ESTHER;
        }
        if (day == 14) {
          return PURIM;
        }
        if (day == 15) {
          return SHUSHAN_PURIM;
        }
        break;
    }
    // if we get to this stage, then there are no holidays for the given date return -1
    return -1;
  }

  /// Returns true if the current day is Yom Tov. The method returns true even for holidays such as {@link #CHANUKAH} and minor
  /// ones such as {@link #TU_BEAV} and {@link #PESACH_SHENI}. Erev Yom Tov (with the exception of {@link #HOSHANA_RABBA},
  /// Erev the second days of Pesach) returns false, as do {@link #isTaanis() fast days} besides {@link #YOM_KIPPUR}. Use
  /// {@link #isAssurBemelacha()} to find the days that have a prohibition of work.
  ///
  ///  @see #getYomTovIndex()
  /// @return true if the current day is a Yom Tov
  /// @see #isErevYomTov()
  /// @see #isErevYomTovSheni()
  /// @see #isTaanis()
  /// @see #isAssurBemelacha()
  /// @see #isCholHamoed()
  bool isYomTov() {
    int holidayIndex = getYomTovIndex();
    if ((isErevYomTov() &&
            (holidayIndex != HOSHANA_RABBA &&
                (holidayIndex == CHOL_HAMOED_PESACH &&
                    getJewishDayOfMonth() != 20))) ||
        (isTaanis() && holidayIndex != YOM_KIPPUR)) {
      return false;
    }
    return getYomTovIndex() != -1;
  }

  /// Returns true if the <em>Yom Tov</em> day has a <em>melacha</em> (work)  prohibition. This method will return false for a
  /// non-<em>Yom Tov</em> day, even if it is <em>Shabbos</em>.
  ///
  /// @return if the <em>Yom Tov</em> day has a <em>melacha</em> (work)  prohibition.
  bool isYomTovAssurBemelacha() {
    int holidayIndex = getYomTovIndex();
    return holidayIndex == PESACH ||
        holidayIndex == SHAVUOS ||
        holidayIndex == SUCCOS ||
        holidayIndex == SHEMINI_ATZERES ||
        holidayIndex == SIMCHAS_TORAH ||
        holidayIndex == ROSH_HASHANA ||
        holidayIndex == YOM_KIPPUR;
  }

  /// Returns true if it is <em>Shabbos</em> or if it is a <em>Yom Tov</em> day that has a <em>melacha</em> (work)  prohibition.
  /// This method will return false for a.
  /// @return if the day is a <em>Yom Tov</em> that is <em>assur bemlacha</em> or <em>Shabbos</em>
  bool isAssurBemelacha() {
    return DayOfWeek.values[getDayOfWeek() - 1] == DayOfWeek.SATURDAY ||
        isYomTovAssurBemelacha();
  }

  /// Returns true if the day has candle lighting. This will return true on erev <em>Shabbos</em>, erev <em>Yom Tov</em>, the
  /// first day of <em>Rosh Hashana</em> and the first days of <em>Yom Tov</em> out of Israel. It is identical
  /// to calling {@link #isTomorrowShabbosOrYomTov()}.
  ///
  /// @return if the day has candle lighting
  bool hasCandleLighting() {
    return isTomorrowShabbosOrYomTov();
  }

  /// Returns true if tomorrow is <em>Shabbos</em> or <em>Yom Tov</em>. This will return true on erev <em>Shabbos</em>, erev
  /// <em>Yom Tov</em>, the first day of <em>Rosh Hashana</em> and <em>erev</em> the first days of <em>Yom Tov</em> out of
  /// Israel. It is identical to calling {@link #hasCandleLighting()}.
  /// @return will return if the next day is <em>Shabbos</em> or <em>Yom Tov</em>
  bool isTomorrowShabbosOrYomTov() {
    return DayOfWeek.values[getDayOfWeek() - 1] == DayOfWeek.FRIDAY ||
        isErevYomTov() ||
        isErevYomTovSheni();
  }

  /// Returns true if the day is the second day of <em>Yom Tov</em>. This impacts the second day of <em>Rosh Hashana</em> everywhere and
  /// the second days of Yom Tov in <em>chutz laaretz</em> (out of Israel).
  ///
  /// @return  if the day is the second day of <em>Yom Tov</em>.
  bool isErevYomTovSheni() {
    return (getJewishMonth() == JewishDate.TISHREI &&
            (getJewishDayOfMonth() == 1)) ||
        (!getInIsrael() &&
            ((getJewishMonth() == JewishDate.NISSAN &&
                    (getJewishDayOfMonth() == 15 ||
                        getJewishDayOfMonth() == 21)) ||
                (getJewishMonth() == JewishDate.TISHREI &&
                    (getJewishDayOfMonth() == 15 ||
                        getJewishDayOfMonth() == 22)) ||
                (getJewishMonth() == JewishDate.SIVAN &&
                    getJewishDayOfMonth() == 6)));
  }

  /// Returns true if the current day is <em>Aseret Yemei Teshuva</em>.
  ///
  /// @return if the current day is <em>Aseret Yemei Teshuvah</em>
  bool isAseresYemeiTeshuva() {
    return getJewishMonth() == JewishDate.TISHREI &&
        getJewishDayOfMonth() <= 10;
  }

  /// Returns true if the current day is <em>Chol Hamoed</em> of <em>Pesach</em> or <em>Succos</em>.
  ///
  /// @return true if the current day is <em>Chol Hamoed</em> of <em>Pesach</em> or <em>Succos</em>
  /// @see #isYomTov()
  /// @see #CHOL_HAMOED_PESACH
  /// @see #CHOL_HAMOED_SUCCOS
  bool isCholHamoed() {
    return isCholHamoedPesach() || isCholHamoedSuccos();
  }

  /// Returns true if the current day is <em>Chol Hamoed</em> of <em>Pesach</em>.
  ///
  /// @return true if the current day is <em>Chol Hamoed</em> of <em>Pesach</em>
  /// @see #isYomTov()
  /// @see #CHOL_HAMOED_PESACH
  bool isCholHamoedPesach() {
    int holidayIndex = getYomTovIndex();
    return holidayIndex == CHOL_HAMOED_PESACH;
  }

  /// Returns true if the current day is <em>Chol Hamoed</em> of <em>Succos</em>.
  ///
  /// @return true if the current day is <em>Chol Hamoed</em> of <em>Succos</em>
  /// @see #isYomTov()
  /// @see #CHOL_HAMOED_SUCCOS
  bool isCholHamoedSuccos() {
    int holidayIndex = getYomTovIndex();
    return holidayIndex == CHOL_HAMOED_SUCCOS;
  }

  /// Returns true if the current day is erev Yom Tov. The method returns true for Erev - Pesach (first and last days),
  /// Shavuos, Rosh Hashana, Yom Kippur and Succos and Hoshana Rabba.
  ///
  /// @return true if the current day is Erev - Pesach, Shavuos, Rosh Hashana, Yom Kippur and Succos
  /// @see #isYomTov()
  /// @see #isErevYomTovSheni()
  bool isErevYomTov() {
    int holidayIndex = getYomTovIndex();
    return holidayIndex == EREV_PESACH ||
        holidayIndex == EREV_SHAVUOS ||
        holidayIndex == EREV_ROSH_HASHANA ||
        holidayIndex == EREV_YOM_KIPPUR ||
        holidayIndex == EREV_SUCCOS ||
        holidayIndex == HOSHANA_RABBA ||
        (holidayIndex == CHOL_HAMOED_PESACH && getJewishDayOfMonth() == 20);
  }

  /// Returns true if the current day is Erev Rosh Chodesh. Returns false for Erev Rosh Hashana
  ///
  /// @return true if the current day is Erev Rosh Chodesh. Returns false for Erev Rosh Hashana
  /// @see #isRoshChodesh()
  bool isErevRoshChodesh() {
    // Erev Rosh Hashana is not Erev Rosh Chodesh.
    return (getJewishDayOfMonth() == 29 && getJewishMonth() != JewishDate.ELUL);
  }

  /// Return true if the day is a Taanis (fast day). Return true for 17 of Tammuz, Tisha B'Av, Yom Kippur, Fast of
  /// Gedalyah, 10 of Teves and the Fast of Esther
  ///
  /// @return true if today is a fast day
  bool isTaanis() {
    int holidayIndex = getYomTovIndex();
    return holidayIndex == SEVENTEEN_OF_TAMMUZ ||
        holidayIndex == TISHA_BEAV ||
        holidayIndex == YOM_KIPPUR ||
        holidayIndex == FAST_OF_GEDALYAH ||
        holidayIndex == TENTH_OF_TEVES ||
        holidayIndex == FAST_OF_ESTHER;
  }

  /// Returns the day of Chanukah or -1 if it is not Chanukah.
  ///
  /// @return the day of Chanukah or -1 if it is not Chanukah.
  int getDayOfChanukah() {
    final int day = getJewishDayOfMonth();
    if (isChanukah()) {
      if (getJewishMonth() == JewishDate.KISLEV) {
        return day - 24;
      } else {
        // teves
        return isKislevShort() ? day + 5 : day + 6;
      }
    } else {
      return -1;
    }
  }

  bool isChanukah() {
    return getYomTovIndex() == CHANUKAH;
  }

  /// Returns if the day is Rosh Chodesh. Rosh Hashana will return false
  ///
  /// @return true if it is Rosh Chodesh. Rosh Hashana will return false
  bool isRoshChodesh() {
    // Rosh Hashana is not rosh chodesh. Elul never has 30 days
    return (getJewishDayOfMonth() == 1 &&
            getJewishMonth() != JewishDate.TISHREI) ||
        getJewishDayOfMonth() == 30;
  }

  /// Returns if the day is Shabbos and sunday is Rosh Chodesh.
  ///
  /// @return true if it is Shabbos and sunday is Rosh Chodesh.
  bool isMacharChodesh() {
    return (DayOfWeek.values[getDayOfWeek() - 1] == DayOfWeek.SATURDAY &&
        (getJewishDayOfMonth() == 30 || getJewishDayOfMonth() == 29));
  }

  /// Returns if the day is Shabbos Mevorchim.
  ///
  /// @return true if it is Shabbos Mevorchim.
  bool isShabbosMevorchim() {
    return (DayOfWeek.values[getDayOfWeek() - 1] == DayOfWeek.SATURDAY &&
        getJewishDayOfMonth() >= 23 &&
        getJewishDayOfMonth() <= 29 &&
        getJewishMonth() != JewishDate.ELUL);
  }

  /// Returns the int value of the Omer day or -1 if the day is not in the omer
  ///
  /// @return The Omer count as an int or -1 if it is not a day of the Omer.
  int getDayOfOmer() {
    int omer = -1; // not a day of the Omer
    int month = getJewishMonth();
    int day = getJewishDayOfMonth();

    // if Nissan and second day of Pesach and on
    if (month == JewishDate.NISSAN && day >= 16) {
      omer = day - 15;
      // if Iyar
    } else if (month == JewishDate.IYAR) {
      omer = day + 15;
      // if Sivan and before Shavuos
    } else if (month == JewishDate.SIVAN && day < 6) {
      omer = day + 44;
    }
    return omer;
  }

  /// Returns the molad in Standard Time in Yerushalayim as a Date. The traditional calculation uses local time. This
  /// method subtracts 20.94 minutes (20 minutes and 56.496 seconds) from the local time (Har Habayis with a longitude
  /// of 35.2354&deg; is 5.2354&deg; away from the %15 timezone longitude) to get to standard time. This method
  /// intentionally uses standard time and not dailight savings time. Java will implicitly format the time to the
  /// default (or set) Timezone.
  ///
  /// @return the Date representing the moment of the molad in Yerushalayim standard time (GMT + 2)
  DateTime getMoladAsDateTime() {
    JewishDate molad = getMolad();
    String locationName = "Jerusalem, Israel";

    double latitude = 31.778; // Har Habayis latitude
    double longitude = 35.2354; // Har Habayis longitude

    // The raw molad Date (point in time) must be generated using standard time. Using "Asia/Jerusalem" timezone will result in the time
    // being incorrectly off by an hour in the summer due to DST. Proper adjustment for the actual time in DST will be done by the date
    // formatter class used to display the Date.
    String year = DateTime.now().year.toString();
    String month = DateTime.now().month < 10
        ? '0${DateTime.now().month.toString()}'
        : DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    String hour = DateTime.now().hour < 10
        ? '0${DateTime.now().hour.toString()}'
        : DateTime.now().hour.toString();
    String minute = DateTime.now().minute < 10
        ? '0${DateTime.now().minute.toString()}'
        : DateTime.now().minute.toString();
    DateTime dateTime =
        DateTime.parse("$year-$month-$day $hour:$minute Z+02:00");
    GeoLocation geo =
        GeoLocation.setLocation(locationName, latitude, longitude, dateTime);

    double moladSeconds = molad.getMoladChalakim() * 10 / 3;
    double moladMillisecond = (1000 * (moladSeconds - moladSeconds));
    DateTime cal = DateTime(
        molad.getGregorianYear(),
        molad.getGregorianMonth(),
        molad.getGregorianDayOfMonth(),
        molad.getMoladHours(),
        molad.getMoladMinutes(),
        moladSeconds.toInt(),
        moladMillisecond.toInt());
    // subtract local time difference of 20.94 minutes (20 minutes and 56.496 seconds) to get to Standard time
    cal.add(Duration(milliseconds: -1 * geo.getLocalMeanTimeOffset().toInt()));
    return cal;
  }

  /// Returns the earliest time of <em>Kiddush Levana</em> calculated as 3 days after the molad. This method returns the time
  /// even if it is during the day when <em>Kiddush Levana</em> can't be said. Callers of this method should consider
  /// displaying the next <em>tzais</em> if the zman is between <em>alos</em> and <em>tzais</em>.
  ///
  /// @return the Date representing the moment 3 days after the molad.
  ///
  /// @see net.sourceforge.zmanim.ComplexZmanimCalendar#getTchilasZmanKidushLevana3Days()
  /// @see net.sourceforge.zmanim.ComplexZmanimCalendar#getTchilasZmanKidushLevana3Days(Date, Date)
  DateTime getTchilasZmanKidushLevana3Days() {
    return getMoladAsDateTime()
        .add(Duration(days: 3)); // 3 days after the molad
  }

  /// Returns the earliest time of Kiddush Levana calculated as 7 days after the molad as mentioned by the <a
  /// href="http://en.wikipedia.org/wiki/Yosef_Karo">Mechaber</a>. See the <a
  /// href="http://en.wikipedia.org/wiki/Yoel_Sirkis">Bach's</a> opinion on this time. This method returns the time
  /// even if it is during the day when <em>Kiddush Levana</em> can't be said. Callers of this method should consider
  /// displaying the next <em>tzais</em> if the zman is between <em>alos</em> and <em>tzais</em>.
  ///
  /// @return the Date representing the moment 7 days after the molad.
  ///
  /// @see net.sourceforge.zmanim.ComplexZmanimCalendar#getTchilasZmanKidushLevana7Days()
  /// @see net.sourceforge.zmanim.ComplexZmanimCalendar#getTchilasZmanKidushLevana7Days(Date, Date)
  DateTime getTchilasZmanKidushLevana7Days() {
    return getMoladAsDateTime()
        .add(Duration(days: 7)); // 7 days after the molad
  }

  /// Returns the latest time of Kiddush Levana according to the <a
  /// href="http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> opinion that it is calculated as
  /// halfway between molad and molad. This adds half the 29 days, 12 hours and 793 chalakim time between molad and
  /// molad (14 days, 18 hours, 22 minutes and 666 milliseconds) to the month's molad. This method returns the time
  /// even if it is during the day when <em>Kiddush Levana</em> can't be said. Callers of this method should consider
  /// displaying <em>alos</em> before this time if the zman is between <em>alos</em> and <em>tzais</em>.
  ///
  /// @return the Date representing the moment halfway between molad and molad.
  /// @see #getSofZmanKidushLevana15Days()
  /// @see net.sourceforge.zmanim.ComplexZmanimCalendar#getSofZmanKidushLevanaBetweenMoldos()
  /// @see net.sourceforge.zmanim.ComplexZmanimCalendar#getSofZmanKidushLevanaBetweenMoldos(Date, Date)
  DateTime getSofZmanKidushLevanaBetweenMoldos() {
    // add half the time between molad and molad (half of 29 days, 12 hours and 793 chalakim (44 minutes, 3.3
    // seconds), or 14 days, 18 hours, 22 minutes and 666 milliseconds)
    return getMoladAsDateTime().add(Duration(
        days: 14, hours: 18, minutes: 22, seconds: 1, milliseconds: 666));
  }

  /// Returns the latest time of Kiddush Levana calculated as 15 days after the molad. This is the opinion brought down
  /// in the Shulchan Aruch (Orach Chaim 426). It should be noted that some opinions hold that the
  /// <a href="http://en.wikipedia.org/wiki/Moses_Isserles">Rema</a> who brings down the opinion of the <a
  /// href="http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin">Maharil's</a> of calculating
  /// {@link #getSofZmanKidushLevanaBetweenMoldos() half way between molad and mold} is of the opinion that Mechaber
  /// agrees to his opinion. Also see the Aruch Hashulchan. For additional details on the subject, See Rabbi Dovid
  /// Heber's very detailed writeup in Siman Daled (chapter 4) of <a
  /// href="http://www.worldcat.org/oclc/461326125">Shaarei Zmanim</a>. This method returns the time even if it is during
  /// the day when <em>Kiddush Levana</em> can't be said. Callers of this method should consider displaying <em>alos</em>
  /// before this time if the zman is between <em>alos</em> and <em>tzais</em>.
  ///
  /// @return the Date representing the moment 15 days after the molad.
  /// @see #getSofZmanKidushLevanaBetweenMoldos()
  /// @see net.sourceforge.zmanim.ComplexZmanimCalendar#getSofZmanKidushLevana15Days()
  /// @see net.sourceforge.zmanim.ComplexZmanimCalendar#getSofZmanKidushLevana15Days(Date, Date)
  DateTime getSofZmanKidushLevana15Days() {
    return getMoladAsDateTime()
        .add(Duration(days: 15)); // 15 days after the molad
  }

  /// Returns the Daf Yomi (Bavli) for the date that the calendar is set to. See the
  /// {@link HebrewDateFormatter#formatDafYomiBavli(Daf)} for the ability to format the daf in Hebrew or transliterated
  /// masechta names.
  ///
  /// @return the daf as a {@link Daf}
  Daf getDafYomiBavli() {
    return YomiCalculator.getDafYomiBavli(this);
  }

  /// Returns the Daf Yomi (Yerushalmi) for the date that the calendar is set to. See the
  /// {@link HebrewDateFormatter#formatDafYomiYerushalmi(Daf)} for the ability to format the daf in Hebrew or transliterated
  /// masechta names.
  ///
  /// @return the daf as a {@link Daf}
  Daf getDafYomiYerushalmi() {
    return YerushalmiYomiCalculator.getDafYomiYerushalmi(this);
  }

/*
/// @see Object#equals(Object)
bool equals(Object object) {
  if (this == object) {
    return true;
  }
  if (!(object instanceof JewishCalendar)) {
    return false;
  }
  JewishCalendar jewishCalendar = (JewishCalendar) object;
  return getAbsDate() == jewishCalendar.getAbsDate() && getInIsrael() == jewishCalendar.getInIsrael();
}

/// @see Object#hashCode()
int hashCode() {
  int result = 17;
  result = 37 * result + getClass().hashCode(); // needed or this and subclasses will return identical hash
  result += 37 * result + getAbsDate() + (getInIsrael() ? 1 : 3);
  return result;
}

 */

  /// A method that creates a <a href="http://en.wikipedia.org/wiki/Object_copy#Deep_copy">deep copy</a> of the object.
  ///
  /// @see Object#clone()
  JewishCalendar clone() => JewishCalendar.initDate(
      getJewishYear(), getJewishMonth(), getJewishDayOfMonth());
}
