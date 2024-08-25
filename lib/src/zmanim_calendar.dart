/*
 * Zmanim Java API
 * Copyright (C) 2004-2020 Eliyahu Hershfeld
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 */

import 'package:kosher_dart/src/hebrewcalendar/jewish_calendar.dart';
import 'package:kosher_dart/src/util/geo_location.dart';
import 'package:kosher_dart/src/astronomical_calendar.dart';
import 'package:kosher_dart/src/complex_zmanim_calendar.dart';
import 'package:kosher_dart/src/util/astronomical_calculator.dart';

/// The ZmanimCalendar is arrow_expand specialized calendar that can calculate sunrise and sunset and Jewish _zmanim_
/// (religious times) for prayers and other Jewish religious duties. This class contains the main functionality of the
///  <em>Zmanim</em> library. For a much more extensive list of <em>zmanim</em>, use the [ComplexZmanimCalendar] that
/// extends this class. See documentation for the {@link ComplexZmanimCalendar} and [AstronomicalCalendar] for
/// simple examples on using the API. According to Rabbi Dovid Yehudah Bursztyn in his
/// <a href="http://www.worldcat.org/oclc/659793988">Zmanim Kehilchasam (second edition published in 2007)</a> chapter 2
/// (pages 186-187) no <em>zmanim</em> besides sunrise and sunset should use elevation. However, Rabbi Yechiel Avrahom
/// Zilber in the <a href="http://hebrewbooks.org/51654">Birur Halacha Vol. 6</a> Ch. 58 Pages
/// <a href="http://hebrewbooks.org/pdfpager.aspx?req=51654&amp;pgnum=42">34</a> and
/// <a href="http://hebrewbooks.org/pdfpager.aspx?req=51654&amp;pgnum=50">42</a> is of the opinion that elevation should be
/// accounted for in <em>zmanim</em> calculations. Related to this, Rabbi Yaakov Karp in <a href=
/// "http://www.worldcat.org/oclc/919472094">Shimush Zekeinim</a>, Ch. 1, page 17 states that obstructing horizons should
///  be factored into <em>zmanim</em> calculations. The setting defaults to false (elevation will not be used for
/// <em>zmanim</em> calculations besides sunrise and sunset), unless the setting is changed to true in {@link
/// #setUseElevation(boolean)}. This will impact sunrise and sunset-based <em>zmanim<em> such as {@link #getSunrise()},
/// {@link #getSunset()}, {@link #getSofZmanShmaGRA()}, <em>alos</em>-based <em>zmanim</em> such as {@link #getSofZmanShmaMGA()}
/// that are based on a fixed offset of sunrise or sunset and <em>zmanim</em> based on a percentage of the day such as
/// {@link ComplexZmanimCalendar#getSofZmanShmaMGA90MinutesZmanis()} that are based on sunrise and sunset. Even when set to
/// true it will not impact <em>zmanim</em> that are a degree-based offset of sunrise and sunset, such as {@link
/// ComplexZmanimCalendar#getSofZmanShmaMGA16Point1Degrees()} or {@link ComplexZmanimCalendar#getSofZmanShmaBaalHatanya()}.
///
///  <p><b>Note:</b> It is important to read the technical notes on top of the {@link AstronomicalCalculator} documentation
///  before using this code.
/// <p>I would like to thank <a href="https://www.worldcat.org/search?q=au%3AShakow%2C+Yaakov">Rabbi Yaakov Shakow</a>, the
/// author of Luach Ikvei Hayom who spent a considerable amount of time reviewing, correcting and making suggestions on the
/// documentation in this library.
/// <h2>Disclaimer:</h2> I did my best to get accurate results, but please double-check before relying on these
/// <em>zmanim</em> for <em>halacha lemaaseh</em>.
///
/// @author &copy; Eliyahu Hershfeld 2004 - 2020
///
class ZmanimCalendar extends AstronomicalCalendar {
  /// Is elevation factored in for some zmanim (see [isUseElevation] for additional information).
  /// * see [isUseElevation]
  /// * see [setUseElevation]
  bool _useElevation = false;

  /// Default constructor will set a default [GeoLocation.GeoLocation], a default
  /// [AstronomicalCalculator.getDefault] AstronomicalCalculator and default the calendar to the current date.
  ///
  /// _see [AstronomicalCalendar.AstronomicalCalendar]_
  ZmanimCalendar() : super();

  /// A constructor that takes a [GeoLocation] as a parameter.
  ///
  /// [location] the location
  ZmanimCalendar.intGeolocation(GeoLocation location)
      : super(geoLocation: location);

  /// Is elevation above sea level calculated for times besides sunrise and sunset. According to Rabbi Dovid Yehuda
  /// Bursztyn in his [Zmanim Kehilchasam (second edition published in 2007)](http://www.worldcat.org/oclc/659793988)
  /// chapter 2 (pages 186-187) no zmanim besides sunrise and sunset should use elevation. However Rabbi
  /// Yechiel Avrahom Zilber in the [Birur Halacha Vol. 6](http://hebrewbooks.org/51654) Ch. 58 Pages
  /// [34](http://hebrewbooks.org/pdfpager.aspx?req=51654&amp;pgnum=42) and
  /// [42](http://hebrewbooks.org/pdfpager.aspx?req=51654&amp;pgnum=50) is of the opinion that elevation should be
  /// accounted for in zmanim calculations. Related to this, Rabbi Yaakov Karp in <a href=
  /// [Shimush Zekeinim](http://www.worldcat.org/oclc/919472094), Ch. 1, page 17 states that obstructing horizons
  /// should be factored into zmanim calculations.The setting defaults to false (elevation will not be used for zmanim
  /// calculations), unless the setting is changed to true in _[setUseElevation]_. This will impact sunrise
  /// and sunset based zmanim such as _[getSunrise()]_, _[getSunset]_, _[getSofZmanShmaGRA]_, alos based
  /// zmanim such as _[getSofZmanShmaMGA] that are based on a fixed offset of sunrise or sunset and zmanim based on
  /// a percentage of the day such as _[ComplexZmanimCalendar.getSofZmanShmaMGA90MinutesZmanis]_ that are based on
  /// sunrise and sunset. It will not impact zmanim that are a degree based offset of sunrise and sunset, such as
  /// _[ComplexZmanimCalendar.getSofZmanShmaMGA16Point1Degrees]_ or _[ComplexZmanimCalendar.getSofZmanShmaBaalHatanya]_.
  ///
  ///  __return if the use of elevation is active__
  ///
  /// see [setUseElevation]
  bool isUseElevation() => _useElevation;

  /// Sets whether elevation above sea level is factored into _zmanim_ calculations for times besides sunrise and sunset.
  /// See [isUseElevation] for more details.
  ///
  /// [useElevation] set to true to use elevation in zmanim calculations
  void setUseElevation(bool useElevation) => _useElevation = useElevation;

  /// The zenith of 16.1° below geometric zenith (90°). This calculation is used for determining _alos_
  /// (dawn) and _tzais_ (nightfall) in some opinions. It is based on the calculation that the time between dawn
  /// and sunrise (and sunset to nightfall) is 72 minutes, the time that is takes to walk 4 _mil_ at 18 minutes
  /// a mil (_[Rambam](https://en.wikipedia.org/wiki/Maimonides)_ and others). The sun's position at
  /// 72 minutes before [sunrise](getSunrise) in Jerusalem on the equinox (on March 16, about 4 days before the
  /// astronomical equinox, the day that a solar hour is 60 minutes) is 16.1° below
  /// [geometric zenith](GEOMETRIC_ZENITH).
  ///
  /// _see [getAlosHashachar]_
  /// _see [ComplexZmanimCalendar.getAlos16Point1Degrees]_
  /// _see [ComplexZmanimCalendar.getTzais16Point1Degrees]_
  /// _see [ComplexZmanimCalendar.getSofZmanShmaMGA16Point1Degrees]_
  /// _see [ComplexZmanimCalendar.getSofZmanTfilaMGA16Point1Degrees]_
  /// _see [ComplexZmanimCalendar.getMinchaGedola16Point1Degrees]_
  /// _see [ComplexZmanimCalendar.getMinchaKetana16Point1Degrees]_
  /// _see [ComplexZmanimCalendar.getPlagHamincha16Point1Degrees]_
  /// _see [ComplexZmanimCalendar.getPlagAlos16Point1ToTzaisGeonim7Point083Degrees]_
  /// _see [ComplexZmanimCalendar.getSofZmanShmaAlos16Point1ToSunset]_
  static const double ZENITH_16_POINT_1 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 16.1;

  /// The zenith of 8.5° below geometric zenith (90°). This calculation is used for calculating _alos_
  /// (dawn) and _tzais_ (nightfall) in some opinions. This calculation is based on the position of the sun 36
  /// minutes after {@link #getSunset sunset} in Jerusalem on March 16, about 4 days before the equinox, the day that a
  /// solar hour is 60 minutes, which is 8.5° below {@link #GEOMETRIC_ZENITH geometric zenith}.
  /// The _[Ohr Meir](http://www.worldcat.org/oclc/29283612)_ considers this the time that 3 small stars are visible,
  /// which is later than the required 3 medium stars.
  ///
  /// _see [getTzais]_
  /// _see [ComplexZmanimCalendar.getTzaisGeonim8Point5Degrees]_
  static const double ZENITH_8_POINT_5 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 8.5;

  /// The default _Shabbos_ candle lighting offset is 18 minutes. This can be changed via the
  /// [setCandleLightingOffset] and retrieved by the [getCandleLightingOffset].
  double _candleLightingOffset = 18;

  /// This method will return [getSeaLevelSunrise] sea level sunrise if [isUseElevation] is false
  /// (the default), or elevation adjusted [AstronomicalCalendar.getSunrise] if it is true. This allows relevant zmanim
  /// in this and extending classes (such as the [ComplexZmanimCalendar] to automatically adjust to the elevation setting.
  ///
  /// return [getSeaLevelSunrise] if [isUseElevation] is false (the default), or elevation adjusted
  ///          [AstronomicalCalendar.getSunrise] if it is true.
  /// _see [AstronomicalCalendar.getSunrise]_
  DateTime? getElevationAdjustedSunrise() {
    if (isUseElevation()) {
      return super.getSunrise();
    }
    return getSeaLevelSunrise();
  }

  /// This method will return [getSeaLevelSunrise] sea level sunrise} if [isUseElevation] is false
  /// (the default), or elevation adjusted [AstronomicalCalendar.getSunrise] if it is true. This allows relevant zmanim
  /// in this and extending classes (such as the [ComplexZmanimCalendar] to automatically adjust to the elevation setting.
  ///
  /// return [getSeaLevelSunset] if [isUseElevation] is false (the default), or elevation adjusted
  ///          [AstronomicalCalendar.getSunset] if it is true.
  /// _see [AstronomicalCalendar.getSunset]_
  DateTime? getElevationAdjustedSunset() {
    if (isUseElevation()) {
      return super.getSunset();
    }
    return getSeaLevelSunset();
  }

  /// A method that returns _tzais_ (nightfall) when the sun is [ZENITH_8_POINT_5] 8.5° below the
  /// [GEOMETRIC_ZENITH] geometric horizon (90°) after [getSunset sunset], a time that Rabbi Meir
  /// Posen in his the _[Ohr Meir](http://www.worldcat.org/oclc/29283612)_ calculated that 3 small
  /// stars are visible, which is later than the required 3 medium stars. See the [ZENITH_8_POINT_5] constant.
  ///
  /// see [ZENITH_8_POINT_5]
  ///
  /// return The <code>Date</code> of nightfall. If the calculation can't be computed such as northern and southern
  ///         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
  ///         low enough below the horizon for this calculation, a null will be returned. See detailed explanation on
  ///         top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_8_POINT_5]_
  /// [ComplexZmanimCalendar.getTzaisGeonim8Point5Degrees] that returns an identical time to this generic _tzais_
  DateTime? getTzais() => getSunsetOffsetByDegrees(ZENITH_8_POINT_5);

  /// Returns _alos_ (dawn) based on the time when the sun is [ZENITH_16_POINT_1] 16.1° below the
  /// eastern [GEOMETRIC_ZENITH] geometric horizon before [getSunrise]. This is based on the
  /// calculation that the time between dawn and sunrise (and sunset to nightfall) is 72 minutes, the time that is
  /// takes to walk 4 _mil_ at 18 minutes a mil (_[Rambam](https://en.wikipedia.org/wiki/Maimonides)_
  /// and others). The sun's position at 72 minutes before [getSunrise sunrise] in Jerusalem
  /// on the equinox (on March 16, about 4 days before the astronomical equinox, the day that a solar hour is 60
  /// minutes) is 16.1° below. See the [GEOMETRIC_ZENITH] constant.
  ///
  /// see [ZENITH_16_POINT_1]
  /// see [ComplexZmanimCalendar.getAlos16Point1Degrees]
  ///
  /// return The <code>Date</code> of dawn. If the calculation can't be computed such as northern and southern
  ///         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
  ///         low enough below the horizon for this calculation, a null will be returned. See detailed explanation on
  ///         top of the [AstronomicalCalendar] documentation.
  DateTime? getAlosHashachar() => getSunriseOffsetByDegrees(ZENITH_16_POINT_1);

  /// Method to return _alos_ (dawn) calculated using 72 minutes before [getSunrise] sunrise or
  /// [getSeaLevelSunrise] sea level sunrise (depending on the [isUseElevation] setting). This time
  /// is based on the time to walk the distance of 4 _Mil_ at 18 minutes a _Mil_. The 72 minute time (but
  /// not the concept of fixed minutes) is based on the opinion that the time of the _Neshef_ (twilight between
  /// dawn and sunrise) does not vary by the time of year or location but depends on the time it takes to walk the
  /// distance of 4 _Mil_.
  ///
  /// @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the {@link AstronomicalCalendar}
  ///         documentation.
  DateTime? getAlos72() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunrise(), -72 * AstronomicalCalendar.MINUTE_MILLIS);

  /// This method returns _chatzos_ (midday) following most opinions that _chatzos_ is the midpoint
  /// between [getSeaLevelSunrise] sea level sunrise and [getSeaLevelSunset] sea level sunset. A day
  /// starting at _alos_ and ending at _tzais_ using the same time or degree offset will also return
  /// the same time. The returned value is identical to [getSunTransit]. In reality due to lengthening or
  /// shortening of day, this is not necessarily the exact midpoint of the day, but it is very close.
  ///
  /// _see [AstronomicalCalendar.getSunTransit]_
  /// return the <code>Date</code> of chatzos. If the calculation can't be computed such as in the Arctic Circle
  ///         where there is at least one day where the sun does not rise, and one where it does not set, a null will
  ///         be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getChatzos() => getSunTransit();

  /// A generic method for calculating the latest _zman krias shema_ (time to recite shema in the morning)
  /// that is 3 * _shaos zmaniyos_ (temporal hours) after the start of the day, calculated using the start and
  /// end of the day passed to this method.
  /// The time from the start of day to the end of day are divided into 12 _shaos zmaniyos_ (temporal hours),
  /// and the latest _zman krias shema_ is calculated as 3 of those _shaos zmaniyos_ after the beginning of
  /// the day. As an example, passing {@link #getSunrise() sunrise} and {@link #getSunset sunset} or [getSeaLevelSunrise]
  /// sea level sunrise and [getSeaLevelSunset] sea level sunset (depending on the [isUseElevation]
  /// elevation setting) to this method will return _sof zman krias shema_ according to the opinion of the
  /// _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_.
  ///
  /// [startOfDay] the start of day for calculating _zman krias shema_. This can be sunrise or any alos passed to this method.
  /// [endOfDay] the end of day for calculating _zman krias shema_. This can be sunset or any tzais passed to this method.
  /// return the <code>Date</code> of the latest _zman shema_ based on the start and end of day times passed to this
  ///         method. If the calculation can't be computed such as in the Arctic Circle where there is at least one day
  ///         a year where the sun does not rise, and one where it does not set, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getSofZmanShma(DateTime? startOfDay, DateTime? endOfDay) {
    if (startOfDay != null && endOfDay != null) {
      return getShaahZmanisBasedZman(startOfDay, endOfDay, 3);
    }
    return getSofZmanShma(
        getElevationAdjustedSunrise(), getElevationAdjustedSunset());
  }

  /// This method returns the latest _zman krias shema_ (time to recite shema in the morning) that is 3 *
  /// _[getShaahZmanisGra] shaos zmaniyos_ (solar hours) after [getSunrise] sunrise or
  /// [getSeaLevelSunrise] sea level sunrise (depending on the [isUseElevation] setting), according
  /// to the _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_.
  ///  The day is calculated from [getSeaLevelSunrise] sea level sunrise to [getSeaLevelSunrise] sea level
  ///  sunset or [getSunrise] sunrise to [getSunset] sunset (depending on the [isUseElevation] setting).
  ///
  /// _see [getSofZmanShma]_
  /// _see #[getShaahZmanisGra]_
  /// _see #[isUseElevation]_
  /// _see [ComplexZmanimCalendar.getSofZmanShmaBaalHatanya]_
  /// return the <code>Date</code> of the latest zman shema according to the GRA. If the calculation can't be computed
  /// such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  /// does not set, a null will be returned. See the detailed explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getSofZmanShmaGRA() => getSofZmanShma(
      getElevationAdjustedSunrise(), getElevationAdjustedSunset());

  /// This method returns the latest _zman krias shema_ (time to recite shema in the morning) that is 3 *
  /// _[getShaahZmanisMGA] shaos zmaniyos_ (solar hours) after [getAlos72], according to the
  /// _[Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)_. The day is calculated
  /// from 72 minutes before [getSeaLevelSunrise] sea level sunrise} to 72 minutes after [getSeaLevelSunrise]
  /// sea level sunset or from 72 minutes before [getSunrise] sunrise to [getSunset] sunset
  /// (depending on the [isUseElevation] setting).
  ///
  /// return the <code>Date</code> of the latest _zman shema_. If the calculation can't be computed such as in
  ///         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getSofZmanShma]_
  /// _see [ComplexZmanimCalendar.getShaahZmanis72Minutes]_
  /// _see [getAlos72]_
  /// _see [ComplexZmanimCalendar.getSofZmanShmaMGA72Minutes]_
  DateTime? getSofZmanShmaMGA() => getSofZmanShma(getAlos72(), getTzais72());

  /// This method returns the <em>tzais</em> (nightfall) based on the opinion of <em>Rabbeinu Tam</em> that
  /// <em>tzais hakochavim</em> is calculated as 72 minutes, the time it takes to walk 4 <em>Mil</em> at 18 minutes
  /// a <em>Mil</em>. According to the [Machtzis Hashekel](https://en.wikipedia.org/wiki/Samuel_Loew) in
  /// Orach Chaim 235:3, the [Pri Megadim](https://en.wikipedia.org/wiki/Joseph_ben_Meir_Teomim) in Orach
  /// Chaim 261:2 (see the Biur Halacha) and others (see Hazmanim Bahalacha 17:3 and 17:5) the 72 minutes are standard
  /// clock minutes any time of the year in any location. Depending on the {@link #isUseElevation()} setting) a 72
  /// minute offset from  either {@link #getSunset() sunset} or {@link #getSeaLevelSunset() sea level sunset} is used.
  ///
  /// see [ComplexZmanimCalendar.getTzais16Point1Degrees]
  /// return the <code>Date</code> representing 72 minutes after sunset. If the calculation can't be
  ///         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise,
  ///         and one where it does not set, a null will be returned See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getTzais72() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunset(), 72 * AstronomicalCalendar.MINUTE_MILLIS);

  /// A method to return candle lighting time, calculated as [getCandleLightingOffset] minutes before
  /// [getSeaLevelSunset] sea level sunset for Erev Shabat & Yom Tov, and calculated as after
  /// TZEIT HACOCHAVIM for secand Yom Tov or Erev Yom Tov after Shabat. Else This method will return null.
  /// Elevation adjustments are intentionally not performed by this method, but you can calculate it by
  /// passing the elevation adjusted sunset to [getTimeOffset].
  ///
  /// return candle lighting time. If the calculation can't be computed such as in the Arctic Circle where there is at
  ///         least one day a year where the sun does not rise, and one where it does not set, a null will be returned.
  ///         See detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getSeaLevelSunset]_
  /// _see [getCandleLightingOffset]_
  /// _see [setCandleLightingOffset]_
  DateTime? getCandleLighting() {
    JewishCalendar today = JewishCalendar.fromDateTime(getCalendar());
    int dayOfWeek = today.getDayOfWeek();
    if ((dayOfWeek == 7 && today.isErevYomTov()) ||
        today.isErevYomTovSheni() ||
        (today.isChanukah() && dayOfWeek != 6)) {
      return AstronomicalCalendar.getTimeOffset(
          getSunsetOffsetByDegrees(ComplexZmanimCalendar.ZENITH_7_POINT_083),
          -13.5 * AstronomicalCalendar.MINUTE_MILLIS);
    }
    if (dayOfWeek == 6 || today.isErevYomTov()) {
      return AstronomicalCalendar.getTimeOffset(getSeaLevelSunset(),
          -getCandleLightingOffset() * AstronomicalCalendar.MINUTE_MILLIS);
    }
    return null;
  }

  /// A generic method for calculating the latest _zman tfilah_ (time to recite the morning prayers)
  /// that is 4 * _shaos zmaniyos_ (temporal hours) after the start of the day, calculated using the start and
  /// end of the day passed to this method.
  /// The time from the start of day to the end of day are divided into 12 _shaos zmaniyos_ (temporal hours),
  /// and _sof zman tfila_ is calculated as 4 of those _shaos zmaniyos_ after the beginning of the day.
  /// As an example, passing [getSunrise] sunrise and [getSunset sunset] or [getSeaLevelSunrise]
  /// sea level sunrise and [getSeaLevelSunset] sea level sunset (depending on the [isUseElevation]
  /// elevation setting) to this method will return _zman tfilah_ according to the opinion of the
  /// _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_.
  ///
  /// [startOfDay]
  ///            the start of day for calculating _zman tfilah_. This can be sunrise or any alos passed to
  ///            this method.
  /// [endOfDay]
  ///            the start of day for calculating _zman tfilah_. This can be sunset or any tzais passed to this
  ///            method.
  /// return the <code>Date</code> of the latest _zman tfilah_ based on the start and end of day times passed
  ///         to this method. If the calculation can't be computed such as in the Arctic Circle where there is at least
  ///         one day a year where the sun does not rise, and one where it does not set, a null will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getSofZmanTfila(DateTime? startOfDay, DateTime? endOfDay) {
    double shaahZmanis = getTemporalHour(startOfDay, endOfDay);
    return AstronomicalCalendar.getTimeOffset(startOfDay, shaahZmanis * 4);
  }

  /// This method returns the latest _zman tfila_ (time to recite shema in the morning) that is 4 *
  /// _[getShaahZmanisGra] shaos zmaniyos_ (solar hours) after [getSunrise] sunrise or
  /// [getSeaLevelSunrise] sea level sunrise (depending on the [isUseElevation] setting), according
  /// to the _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_.
  /// The day is calculated from [getSeaLevelSunrise] sea level sunrise to [getSeaLevelSunrise] sea level
  /// sunset or [getSunrise] sunrise to [getSunset] sunset (depending on the [isUseElevation] setting).
  ///
  /// _see [getSofZmanTfila]_
  /// _see [getShaahZmanisGra]_
  /// _see [ComplexZmanimCalendar.getSofZmanTfilaBaalHatanya]_
  /// return the <code>Date</code> of the latest zman tfilah. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getSofZmanTfilaGRA() => getSofZmanTfila(
      getElevationAdjustedSunrise(), getElevationAdjustedSunset());

  /// This method returns the latest _zman tfila_ (time to recite shema in the morning) that is 4 *
  /// _getShaahZmanisMGA] shaos zmaniyos_ (solar hours) after [getAlos72] according to the
  /// _[Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)_. The day is calculated
  /// from 72 minutes before [getSeaLevelSunrise] sea level sunrise to 72 minutes after
  /// [getSeaLevelSunrise] sea level sunset or from 72 minutes before [getSunrise] sunrise to [getSunset]
  /// sunset (depending on the [isUseElevation] setting).
  ///
  /// return the <code>Date</code> of the latest zman tfila. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set), a null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getSofZmanTfila]_
  /// _see [getShaahZmanisMGA]_
  /// _see [getAlos72]_
  DateTime? getSofZmanTfilaMGA() => getSofZmanTfila(getAlos72(), getTzais72());

  /// A generic method for calculating the latest _mincha gedola_ (the earliest time to recite the mincha  prayers)
  /// that is 6.5 * _shaos zmaniyos_ (temporal hours) after the start of the day, calculated using the start and end
  /// of the day passed to this method.
  /// The time from the start of day to the end of day are divided into 12 _shaos zmaniyos_ (temporal hours), and
  /// _mincha gedola_ is calculated as 6.5 of those _shaos zmaniyos_ after the beginning of the day. As an
  /// example, passing [getSunrise] sunrise and [getSunset] sunset or [getSeaLevelSunrise] sea level
  /// sunrise and [getSeaLevelSunset] sea level sunset (depending on the [isUseElevation] elevation
  /// setting) to this method will return _mincha gedola_ according to the opinion of the
  /// _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_.
  ///
  /// [startOfDay]
  ///            the start of day for calculating _Mincha gedola_. This can be sunrise or any alos passed to
  ///            this method.
  /// [endOfDay]
  ///            the end of day for calculating _Mincha gedola_. This can be sunrise or any alos passed to
  ///            this method.
  /// return the <code>Date</code> of the time of _Mincha gedola_ based on the start and end of day times
  ///         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
  ///         at least one day a year where the sun does not rise, and one where it does not set, a null will be
  ///         returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getMinchaGedola([DateTime? startOfDay, DateTime? endOfDay]) {
    if (startOfDay != null && endOfDay != null) {
      return getShaahZmanisBasedZman(startOfDay, endOfDay, 6.5);
    }
    return getMinchaGedola(
        getElevationAdjustedSunrise(), getElevationAdjustedSunset());
  }

  /// A generic method for calculating _mincha ketana_, (the preferred time to recite the mincha prayers in
  /// the opinion of the _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_ and others) that is
  /// 9.5 * _shaos zmaniyos_ (temporal hours) after the start of the day, calculated using the start and end
  /// of the day passed to this method.
  /// The time from the start of day to the end of day are divided into 12 _shaos zmaniyos_ (temporal hours), and
  /// _mincha ketana_ is calculated as 9.5 of those _shaos zmaniyos_ after the beginning of the day. As an
  /// example, passing [getSunrise] sunrise and [getSunset] sunset or [getSeaLevelSunrise] sea level
  /// sunrise and [getSeaLevelSunset] sea level sunset (depending on the [isUseElevation] elevation
  /// setting) to this method will return _mincha ketana_ according to the opinion of the
  /// _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_.
  ///
  /// [startOfDay] the start of day for calculating _Mincha ketana_. This can be sunrise or any alos passed to this method.
  /// [endOfDay] the end of day for calculating _Mincha ketana_. This can be sunrise or any alos passed to this method.
  /// return the <code>Date</code> of the time of _Mincha ketana_ based on the start and end of day times
  ///         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
  ///         at least one day a year where the sun does not rise, and one where it does not set, a null will be
  ///         returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  DateTime? getMinchaKetana([DateTime? startOfDay, DateTime? endOfDay]) {
    if (startOfDay != null && endOfDay != null) {
      return getShaahZmanisBasedZman(startOfDay, endOfDay, 9.5);
    }
    return getMinchaKetana(
        getElevationAdjustedSunrise(), getElevationAdjustedSunset());
  }

  /// A generic method for calculating _plag hamincha_ (the earliest time that Shabbos can be started) that is
  /// 10.75 hours after the start of the day, (or 1.25 hours before the end of the day) based on the start and end of
  /// the day passed to the method.
  /// The time from the start of day to the end of day are divided into 12 _shaos zmaniyos_ (temporal hours), and
  /// _plag hamincha_ is calculated as 10.75 of those _shaos zmaniyos_ after the beginning of the day. As an
  /// example, passing [getSunrise] sunrise and [getSunset] sunset or [getSeaLevelSunrise] sea level
  /// sunrise and [getSeaLevelSunset] sea level sunset (depending on the [isUseElevation] elevation
  /// setting) to this method will return _plag mincha_ according to the opinion of the
  /// _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_.
  ///
  /// [startOfDay] the start of day for calculating plag. This can be sunrise or any alos passed to this method.
  /// [endOfDay] the end of day for calculating plag. This can be sunrise or any alos passed to this method.
  /// return the <code>Date</code> of the time of _plag hamincha_ based on the start and end of day times
  ///         passed to this method. If the calculation can't be computed such as in the Arctic Circle where there is
  ///         at least one day a year where the sun does not rise, and one where it does not set, a null will be
  ///         returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getPlagHamincha([DateTime? startOfDay, DateTime? endOfDay]) {
    if (startOfDay != null && endOfDay != null) {
      return getShaahZmanisBasedZman(startOfDay, endOfDay, 10.75);
    }
    return getPlagHamincha(
        getElevationAdjustedSunrise(), getElevationAdjustedSunset());
  }

  /// A method that returns a _shaah zmanis_ ([getTemporalHour] temporal hour) according to
  /// the opinion of the _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_. This calculation divides
  /// the day based on the opinion of the _GRA_ that the day runs from from [getSeaLevelSunrise] sea
  /// level sunrise to [getSeaLevelSunrise] sea level sunset or [getSunrise] sunrise to
  /// [getSunset] sunset (depending on the [isUseElevation] setting). The day is split into 12 equal
  /// parts with each one being a _shaah zmanis_. This method is similar to [getTemporalHour], but can
  /// account for elevation.
  ///
  /// return the <code>long</code> millisecond length of a _shaah zmanis_ calculated from sunrise to sunset.
  ///         If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year
  ///         where the sun does not rise, and one where it does not set, double.minPositive will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getTemporalHour]_
  /// _see [getSeaLevelSunrise]_
  /// _see [getSeaLevelSunset]_
  /// _see [ComplexZmanimCalendar.getShaahZmanisBaalHatanya]_
  double getShaahZmanisGra() => getTemporalHour(
      getElevationAdjustedSunrise(), getElevationAdjustedSunset());

  /// A method that returns a _shaah zmanis_ (temporal hour) according to the opinion of the
  /// _[Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)_ based on a 72 minutes _alos_
  /// and _tzais_. This calculation divides the day that runs from dawn to dusk (for sof zman krias shema and tfila).
  /// Dawn for this calculation is 72 minutes before [getSunrise] sunrise or [getSeaLevelSunrise] sea level
  /// sunrise (depending on the [isUseElevation] elevation setting) and dusk is 72 minutes after [getSunset]
  /// sunset or [getSeaLevelSunset] sea level sunset (depending on the [isUseElevation] elevation setting).
  /// This day is split into 12 equal parts with each part being a _shaah zmanis_. Alternate methods of calculating a
  /// _shaah zmanis_ according to the Magen Avraham (MGA) are available in the subclass [ComplexZmanimCalendar].
  ///
  /// return the <code>long</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, {@link Long#MIN_VALUE} will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  double getShaahZmanisMGA() => getTemporalHour(getAlos72(), getTzais72());

  /// A method to get the offset in minutes before [AstronomicalCalendar.getSeaLevelSunset] sea level sunset which
  /// is used in calculating candle lighting time. The default time used is 18 minutes before sea level sunset. Some
  /// calendars use 15 minutes, while the custom in Jerusalem is to use a 40 minute offset. Please check the local custom
  /// for candle lighting time.
  ///
  /// return Returns the currently set candle lighting offset in minutes.
  /// _see [getCandleLighting]_
  /// _see [setCandleLightingOffset]_
  double getCandleLightingOffset() => _candleLightingOffset;

  /// A method to set the offset in minutes before [AstronomicalCalendar.getSeaLevelSunset] sea level sunset that is
  /// used in calculating candle lighting time. The default time used is 18 minutes before sunset. Some calendars use 15
  /// minutes, while the custom in Jerusalem is to use a 40 minute offset.
  ///
  /// [candleLightingOffset] The candle lighting offset to set in minutes.
  /// _see [getCandleLighting]_
  /// _see [getCandleLightingOffset]_
  void setCandleLightingOffset(double candleLightingOffset) =>
      _candleLightingOffset = candleLightingOffset;

  /// This is a utility method to determine if the current Date (date-time) passed in has a _melacha_ (work) prohibition.
  /// Since there are many opinions on the time of _tzais_, the _tzais_ for the current day has to be passed to this
  /// class. Sunset is the classes current day's [getElevationAdjustedSunset] elevation adjusted sunset that observes the
  /// [isUseElevation] settings. The [JewishCalendar#getInIsrael] will be set by the inIsrael parameter.
  ///
  /// [currentTime] the current time
  /// [tzais] the time of tzais
  /// [inIsrael] whether to use Israel holiday scheme or not
  ///
  /// return true if _melacha_ is prohibited or false if it is not.
  ///
  /// _see [JewishCalendar.isAssurBemelacha]_
  /// _see [JewishCalendar.hasCandleLighting]_
  /// _see [JewishCalendar.setInIsrael]_
  bool isAssurBemlacha(DateTime currentTime, DateTime tzais, bool inIsrael) {
    JewishCalendar jewishCalendar = JewishCalendar();
    jewishCalendar.setGregorianDate(
        getCalendar().year, getCalendar().month, getCalendar().day);
    jewishCalendar.inIsrael = inIsrael;

    if (jewishCalendar.hasCandleLighting() &&
        currentTime.compareTo(getElevationAdjustedSunset()!) >= 0) {
      //erev shabbos, YT or YT sheni and after shkiah
      return true;
    }

    if (jewishCalendar.isAssurBemelacha() &&
        currentTime.compareTo(tzais) <= 0) {
      //is shabbos or YT and it is before tzais
      return true;
    }

    return false;
  }

  /// A generic utility method for calculating any <em>shaah zmanis</em> (temporal hour) based <em>zman</em> with the
  /// day defined as the start and end of day (or night) and the number of <em>shaahos zmaniyos</em> passed to the
  /// method. This simplifies the code in other methods such as {@link #getPlagHamincha(Date, Date)} and cuts down on
  /// code replication. As an example, passing {@link #getSunrise() sunrise} and {@link #getSunset sunset} or {@link
  /// #getSeaLevelSunrise() sea level sunrise} and {@link #getSeaLevelSunset() sea level sunset} (depending on the
  /// {@link #isUseElevation()} elevation setting) and 10.75 hours to this method will return <em>plag mincha</em>
  /// according to the opinion of the [GRA](https://en.wikipedia.org/wiki/Vilna_Gaon).
  ///
  /// @param startOfDay
  ///            the start of day for calculating the <em>zman</em>. This can be sunrise or any <em>alos</em> passed
  ///            to this method.
  /// @param endOfDay
  ///            the end of day for calculating the <em>zman</em>. This can be sunrise or any <em>alos</em> passed to
  ///            this method.
  /// @param hours
  ///            the number of <em>shaahos zmaniyos</em> (temporal hours) to offset from the start of day
  /// @return the <code>Date</code> of the time of <em>zman</em> with the <em>shaahos zmaniyos</em> (temporal hours)
  ///         in the day offset from the start of day passed to this method. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a null will be  returned. See detailed explanation on top of the {@link
  ///         AstronomicalCalendar} documentation.
  DateTime? getShaahZmanisBasedZman(
      DateTime startOfDay, DateTime endOfDay, double hours) {
    double shaahZmanis = getTemporalHour(startOfDay, endOfDay);
    return AstronomicalCalendar.getTimeOffset(startOfDay, shaahZmanis * hours);
  }
}
