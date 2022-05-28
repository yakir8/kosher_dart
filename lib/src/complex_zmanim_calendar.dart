/*
 * Zmanim Java API
 * Copyright (C) 2004-2020 Eliyahu Hershfeld
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

import 'package:kosher_dart/src/zmanim_calendar.dart';
import 'package:kosher_dart/src/util/geo_location.dart';
import 'package:kosher_dart/src/astronomical_calendar.dart';
import 'package:kosher_dart/src/hebrewcalendar/jewish_date.dart';
import 'package:kosher_dart/src/util/astronomical_calculator.dart';
import 'package:kosher_dart/src/hebrewcalendar/jewish_calendar.dart';

/// <p>This class extends ZmanimCalendar and provides many more zmanim than available in the ZmanimCalendar. The basis for
/// most zmanim in this class are from the _sefer_ <b><a href="http://hebrewbooks.org/9765">Yisroel Vehazmanim</a></b>
/// by <b><a href="https://en.wikipedia.org/wiki/Yisroel_Dovid_Harfenes">Rabbi Yisrael Dovid Harfenes</a></b>.
/// As an example of the number of different <em>zmanim</em> made available by this class, there are methods to return 18
/// different calculations for <em>alos</em> (dawn), 18 for <em>plag hamincha</em> and 29 for <em>tzais</em> available in this
/// API. The real power of this API is the ease in calculating <em>zmanim</em> that are not part of the library. The methods for
/// <em>zmanim</em> calculations not present in this class or it's superclass  {@link ZmanimCalendar} are contained in the
/// [AstronomicalCalendar], the base class of the calendars in our API since they are generic methods for calculating
/// time based on degrees or time before or after [getSunrise sunrise and [getSunset sunset and are of interest
/// for calculation beyond _zmanim_ calculations. Here are some examples.
/// <p>First create the Calendar for the location you would like to calculate:
///
/// <pre style="background: #FEF0C9; display: inline-block;">
/// String locationName = &quot;Lakewood, NJ&quot;;
/// double latitude = 40.0828; // Lakewood, NJ
/// double longitude = -74.2094; // Lakewood, NJ
/// double elevation = 20; // optional elevation correction in Meters
/// // the String parameter in getTimeZone] has to be a valid timezone listed in
/// // {link java.util.TimeZone#getAvailableIDs]
/// TimeZone timeZone = TimeZone.getTimeZone(&quot;America/New_York&quot;);
/// GeoLocation location = new GeoLocation(locationName, latitude, longitude, elevation, timeZone);
/// ComplexZmanimCalendar czc = new ComplexZmanimCalendar(location);
/// // Optionally set the date or it will default to today's date
/// czc.getCalendar].set(Calendar.MONTH, Calendar.FEBRUARY);
/// czc.getCalendar].set(Calendar.DAY_OF_MONTH, 8);</pre>
/// <p>
/// <b>Note:</b> For locations such as Israel where the beginning and end of daylight savings time can fluctuate from
/// year to year, if your version of Java does not have an <a href=
/// "http://www.oracle.com/technetwork/java/javase/tzdata-versions-138805.html">up to date timezone database</a>, create a
/// {link java.util.SimpleTimeZone with the known start and end of DST.
/// To get _alos_ calculated as 14° below the horizon (as calculated in the calendars published in Montreal),
/// add {link AstronomicalCalendar#GEOMETRIC_ZENITH (90) to the 14° offset to get the desired time:
/// <br><br>
/// <pre style="background: #FEF0C9; display: inline-block;">
///  Date alos14 = czc.getSunriseOffsetByDegrees({link AstronomicalCalendar#GEOMETRIC_ZENITH + 14);</pre>
/// <p>
/// To get _mincha gedola_ calculated based on the _<a href="https://en.wikipedia.org/wiki/Avraham_Gombinern"
/// >Magen Avraham (MGA)</a>_ using a _shaah zmanis_ based on the day starting
/// 16.1° below the horizon (and ending 16.1° after sunset) the following calculation can be used:
///
/// <pre style="background: #FEF0C9; display: inline-block;">
/// Date minchaGedola = czc.getTimeOffset(czc.getAlos16point1Degrees], czc.getShaahZmanis16Point1Degrees] * 6.5);</pre>
/// <p>
/// or even simpler using the included convenience methods
/// <pre style="background: #FEF0C9; display: inline-block;">
/// Date minchaGedola = czc.getMinchaGedola(czc.getAlos16point1Degrees], czc.getShaahZmanis16Point1Degrees]);</pre>
/// <p>
/// A little more complex example would be calculating zmanim that rely on a _shaah zmanis_ that is
/// not present in this library. While a drop more complex, it is still rather easy. An example would be to calculate
/// the _<a href="https://en.wikipedia.org/wiki/Israel_Isserlein">Trumas Hadeshen</a>'s_ _alos_ to
/// _tzais_ based _plag hamincha_ as calculated in the Machzikei Hadass calendar in Manchester, England.
/// A number of this calendar's zmanim are calculated based on a day starting at _alos_ of 12° before sunrise
/// and ending at _tzais_ of 7.083° after sunset. Be aware that since the _alos_ and _tzais_
/// do not use identical degree based offsets, this leads to _chatzos_ being at a time other than the
/// [getSunTransit] solar transit (solar midday). To calculate this zman, use the following steps. Note that
/// _plag hamincha_ is 10.75 hours after the start of the day, and the following steps are all that it takes.
/// <br>
/// <pre style="background: #FEF0C9; display: inline-block;">
/// Date plag = czc.getPlagHamincha(czc.getSunriseOffsetByDegrees({link AstronomicalCalendar#GEOMETRIC_ZENITH + 12),
/// 				czc.getSunsetOffsetByDegrees({link AstronomicalCalendar#GEOMETRIC_ZENITH + ZENITH_7_POINT_083));</pre>
/// <p>
/// Something a drop more challenging, but still simple, would be calculating a zman using the same "complex" offset day
/// used in the above mentioned Manchester calendar, but for a _shaos zmaniyos_ based _zman_ not not
/// supported by this library, such as calculating the point that one should be _makpid_
/// not to eat on _erev Shabbos_ or _erev Yom Tov_. This is 9 _shaos zmaniyos_ into the day.
/// <ol>
/// 	<li>Calculate the _shaah zmanis_ in milliseconds for this day</li>
/// 	<li>Add 9 of these _shaos zmaniyos_ to alos starting at 12°</li>
/// </ol>
/// <br>
/// <pre style="background: #FEF0C9; display: inline-block;">
/// long shaahZmanis = czc.getTemporalHour(czc.getSunriseOffsetByDegrees({link AstronomicalCalendar#GEOMETRIC_ZENITH + 12),
/// 						czc.getSunsetOffsetByDegrees({link AstronomicalCalendar#GEOMETRIC_ZENITH + ZENITH_7_POINT_083));
/// Date sofZmanAchila = getTimeOffset(czc.getSunriseOffsetByDegrees({link AstronomicalCalendar#GEOMETRIC_ZENITH + 12),
/// 					shaahZmanis * 9);</pre>
/// <p>
/// Calculating this _sof zman achila_ according to the _<a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a>_
/// is simplicity itself.
/// <pre style="background: #FEF0C9; display: inline-block;">
/// Date sofZamnAchila = czc.getTimeOffset(czc.getSunrise], czc.getShaahZmanisGra] * 9);</pre>
///
/// <h2>Documentation from the {link ZmanimCalendar parent class</h2>
/// {inheritDoc
///
/// author &copy; Eliyahu Hershfeld 2004 - 2020
class ComplexZmanimCalendar extends ZmanimCalendar {
  /// The zenith of 3.7° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _tzais_ (nightfall) based on the opinion of the _Geonim_ that _tzais_ is the
  /// time it takes to walk 3/4 of a _Mil_ at 18 minutes a _Mil_, or 13.5 minutes after sunset. The sun
  /// is 3.7° below [GEOMETRIC_ZENITH] geometric zenith at this time in Jerusalem on March 16, about 4 days
  /// before the equinox, the day that a solar hour is 60 minutes.
  ///
  /// _see [getTzaisGeonim3Point7Degrees]_
  static const double ZENITH_3_POINT_7 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 3.7;

  /// The zenith of 3.8° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _tzais_ (nightfall) based on the opinion of the _Geonim_ that _tzais_ is the
  /// time it takes to walk 3/4 of a _Mil_ at 18 minutes a _Mil_, or 13.5 minutes after sunset. The sun
  /// is 3.8° below [GEOMETRIC_ZENITH geometric zenith at this time in Jerusalem on March 16, about 4 days
  /// before the equinox, the day that a solar hour is 60 minutes.
  ///
  /// _see [getTzaisGeonim3Point8Degrees]_
  static const double ZENITH_3_POINT_8 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 3.8;

  /// The zenith of 5.95° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _tzais_ (nightfall) according to some opinions. This calculation is based on the position of
  /// the sun 24 minutes after sunset in Jerusalem on March 16, about 4 days before the equinox, the day that a solar
  /// hour is 60 minutes, which calculates to 5.95° below [GEOMETRIC_ZENITH] geometric zenith.
  ///
  /// _see [getTzaisGeonim5Point95Degrees]_
  static const double ZENITH_5_POINT_95 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 5.95;

  /// The zenith of 7.083° below [GEOMETRIC_ZENITH] geometric zenith (90°). This is often referred to as
  /// 7°5' or 7° and 5 minutes. This calculation is used for calculating _alos_ (dawn) and
  /// _tzais_ (nightfall) according to some opinions. This calculation is based on the position of the sun 30
  /// minutes after sunset in Jerusalem on March 16, about 4 days before the equinox, the day that a solar hour is 60
  /// minutes, which calculates to 7.0833333° below [GEOMETRIC_ZENITH] geometric zenith. This is time some
  /// opinions consider dark enough for 3 stars to be visible. This is the opinion of the
  /// _[Sh"Ut Melamed Leho'il](http://www.hebrewbooks.org/1053)_, _Sh"Ut Bnei Tziyon_, _Tenuvas
  /// Sadeh_ and very close to the time of the _[Mekor Chesed](http://www.hebrewbooks.org/22044)_ of
  /// the _Sefer chasidim_.
  /// todo Confirm the proper source.
  ///
  /// _see [getTzaisGeonim7Point083Degrees]_
  /// _see [getBainHasmashosRT13Point5MinutesBefore7Point083Degrees]_
  static const double ZENITH_7_POINT_083 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 7 + (5.0 / 60);

  /// The zenith of 10.2° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _misheyakir_ according to some opinions. This calculation is based on the position of the sun
  /// 45 minutes before [getSunrise] sunrise in Jerusalem on March 16, about 4 days before the equinox, the day
  /// that a solar hour is 60 minutes which calculates to 10.2° below [GEOMETRIC_ZENITH] geometric zenith.
  ///
  /// _see [getMisheyakir10Point2Degrees]_
  static const double ZENITH_10_POINT_2 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 10.2;

  /// The zenith of 11° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _misheyakir_ according to some opinions. This calculation is based on the position of the sun
  /// 48 minutes before [getSunrise] sunrise in Jerusalem on March 16, about 4 days before the equinox, the day
  /// that a solar hour is 60 minutes which calculates to 11° below [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// _see [getMisheyakir11Degrees]_
  static const double ZENITH_11_DEGREES =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 11;

  /// The zenith of 11.5° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _misheyakir_ according to some opinions. This calculation is based on the position of the sun
  /// 52 minutes before [getSunrise] sunrise in Jerusalem on March 16, about 4 days before the equinox, the day
  /// that a solar hour is 60 minutes which calculates to 11.5° below [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// _see [getMisheyakir11Point5Degrees]_
  static const double ZENITH_11_POINT_5 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 11.5;

  /// The zenith of 13.24° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _Rabbeinu Tam's bain hashmashos_ according to some opinions.
  /// NOTE: See comments on [getBainHasmashosRT13Point24Degrees] for additional details about the degrees.
  ///
  /// _see [getBainHasmashosRT13Point24Degrees]_
  ///
  static const double ZENITH_13_POINT_24 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 13.24;

  /// The zenith of 19° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _alos_ according to some opinions.
  ///
  /// _see [getAlos19Degrees]_
  /// _see [getAlos18Degrees]_
  static const double ZENITH_19_DEGREES =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 19;

  /// The zenith of 19.8° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _alos_ (dawn) and _tzais_ (nightfall) according to some opinions. This calculation is
  /// based on the position of the sun 90 minutes after sunset in Jerusalem on March 16, about 4 days before the
  /// equinox, the day that a solar hour is 60 minutes which calculates to 19.8° below [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// _see [getTzais19Point8Degrees]_
  /// _see [getAlos19Point8Degrees]_
  /// _see [getAlos90]_
  /// _see [getTzais90]_
  static const double ZENITH_19_POINT_8 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 19.8;

  /// The zenith of 26° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _alos_ (dawn) and _tzais_ (nightfall) according to some opinions. This calculation is
  /// based on the position of the sun [getAlos120] 120 minutes after sunset in Jerusalem on March 16, about 4
  /// days before the equinox, the day that a solar hour is 60 minutes which calculates to 26° below
  /// [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// _see [getAlos26Degrees]_
  /// _see [getTzais26Degrees]_
  /// _see [getAlos120]_
  /// _see [getTzais120]_
  static const double ZENITH_26_DEGREES =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 26.0;

  /// The zenith of 4.37° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _tzais_ (nightfall) according to some opinions. This calculation is based on the position of
  /// the sun [getTzaisGeonim4Point37Degrees] 16 7/8 minutes after sunset (3/4 of a 22.5 minute Mil) in
  /// Jerusalem on March 16, about 4 days before the equinox, the day that a solar hour is 60 minutes which calculates
  /// to 4.37° below [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// _see [getTzaisGeonim4Point37Degrees]_
  static const double ZENITH_4_POINT_37 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 4.37;

  /// The zenith of 4.61° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _tzais_ (nightfall) according to some opinions. This calculation is based on the position of
  /// the sun [getTzaisGeonim4Point37Degrees] 18 minutes after sunset (3/4 of a 24 minute Mil) in Jerusalem on
  /// March 16, about 4 days before the equinox, the day that a solar hour is 60 minutes which calculates to 4.61°
  /// below [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// _see [getTzaisGeonim4Point61Degrees]_
  static const double ZENITH_4_POINT_61 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 4.61;

  /// The zenith of 5.88° below [GEOMETRIC_ZENITH] geometric zenith (90°).
  /// todo Add more documentation.
  /// _see [getTzaisGeonim4Point8Degrees]_
  static const double ZENITH_4_POINT_8 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 4.8;

  /// The zenith of 3.65° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _tzais_ (nightfall) according to some opinions. This calculation is based on the position of
  /// the sun [getTzaisGeonim3Point65Degrees] 13.5 minutes after sunset (3/4 of an 18 minute Mil) in Jerusalem
  /// on March 16, about 4 days before the equinox, the day that a solar hour is 60 minutes which calculates to
  /// 3.65° below [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// _see [getTzaisGeonim3Point65Degrees]_
  static const double ZENITH_3_POINT_65 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 3.65;

  /// The zenith of 3.676° below [GEOMETRIC_ZENITH] geometric zenith (90°).
  /// todo Add more documentation.
  static const double ZENITH_3_POINT_676 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 3.676;

  /// The zenith of 5.88° below [GEOMETRIC_ZENITH] geometric zenith (90°).
  /// todo Add more documentation.
  static const double ZENITH_5_POINT_88 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 5.88;

  /// The zenith of 1.583° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _netz amiti_ (sunrise) and _shkiah amiti_ (sunset) based on the opinion of the
  /// _[Baal Hatanya](https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi)_.
  ///
  /// _see [getSunriseBaalHatanya]_
  /// _see [getSunsetBaalHatanya]_
  static const double ZENITH_1_POINT_583 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 1.583;

  /// The zenith of 16.9° below geometric zenith (90°). This calculation is used for determining _alos_
  /// (dawn) based on the opinion of the _Baal Hatanya_. It is based on the calculation that the time between dawn
  /// and _netz amiti_ (sunrise) is 72 minutes, the time that is takes to walk 4 _mil_ at 18 minutes
  /// a mil (_[Rambam](https://en.wikipedia.org/wiki/Maimonides)_ and others). The sun's position at 72
  /// minutes before [getSunriseBaalHatanya] _netz amiti_ (sunrise) in Jerusalem on the equinox (on March 16,
  /// about 4 days before the astronomical equinox, the day that a solar hour is 60 minutes) is 16.9° below
  /// [GEOMETRIC_ZENITH] geometric zenith.
  ///
  /// _see [getAlosBaalHatanya]_
  static const double ZENITH_16_POINT_9 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 16.9;

  /// The zenith of 6° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for calculating
  /// _tzais_ (nightfall) based on the opinion of the _Baal Hatanya_. This calculation is based on the position
  /// of the sun 24 minutes after [getSunset] sunset in Jerusalem on March 16, about 4 days before the equinox, the day
  /// that a solar hour is 60 minutes, which is 6° below [GEOMETRIC_ZENITH] geometric zenith.
  ///
  /// _see [getTzaisBaalHatanya]_
  static const double ZENITH_6_DEGREES =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 6;

  /// The zenith of 6.45° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _tzais_ (nightfall) according to some opinions. This is based on the calculations of
  /// [Rabbi Yechiel Michel Tucazinsky](https://en.wikipedia.org/wiki/Yechiel_Michel_Tucazinsky) of the position of
  /// the sun no later than [getTzaisGeonim6Point45Degrees] 31 minutes after sunset in Jerusalem, and at the
  /// height of the summer solstice, this zman is 28 minutes after_shkiah_. This computes to 6.45° below
  /// {@link #GEOMETRIC_ZENITH geometric zenith}. This calculation is found in the [Birur Halacha Yoreh Deah 262]
  /// (https://hebrewbooks.org/pdfpager.aspx?req=50536&st=&pgnum=51) it the commonly used
  /// <em>zman</em> in Israel. It should be noted that this differs from the 6.1&deg;/6.2&deg; calculation for Rabbi
  /// Tucazinsky's time as calculated by the Hazmanim Bahalacha Vol II chapter 50:7 (page 515).
  ///
  /// _see #[getTzaisGeonim6Point45Degrees]_
  static const double ZENITH_6_POINT_45 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 6.45;

  /// The zenith of 7.65° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _misheyakir_ according to some opinions.
  ///
  /// _see [getMisheyakir7Point65Degrees]_
  static const double ZENITH_7_POINT_65 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 7.65;

  /// The zenith of 7.67° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _tzais_ according to some opinions.
  ///
  /// _see [getMisheyakir7Point65Degrees]_
  static const double ZENITH_7_POINT_67 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 7.67;

  /// The zenith of 9.3° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _tzais_ (nightfall) according to some opinions.
  ///
  /// _see [getTzaisGeonim9Point3Degrees]_
  static const double ZENITH_9_POINT_3 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 9.3;

  /// The zenith of 9.5° below [[GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _misheyakir_ according to some opinions.
  ///
  /// _see [getMisheyakir9Point5Degrees]_
  static const double ZENITH_9_POINT_5 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 9.5;

  /// The zenith of 9.75° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for
  /// calculating _alos_ (dawn) and _tzais_ (nightfall) according to some opinions.
  ///
  /// _see [getTzaisGeonim9Point75Degrees]_
  static const double ZENITH_9_POINT_75 =
      AstronomicalCalculator.GEOMETRIC_ZENITH + 9.75;

  /// The zenith of 2.1&deg; above {@link #GEOMETRIC_ZENITH geometric zenith} (90&deg;). This calculation is used for
  /// calculating the start of <em>bain hashmashos</em> (twilight) of 13.5 minutes before sunset converted to degrees
  /// according to the Yereim. As is traditional with degrees below the horizon, this is calculated without refraction
  /// and from the center of the sun. It would be 0.833&deg; less without this.
  ///
  /// @see #getBainHasmashosYereim2Point1Degrees()
  static const double ZENITH_MINUS_2_POINT_1 =
      AstronomicalCalculator.GEOMETRIC_ZENITH - 2.1;

  ///The zenith of 2.8&deg; above {@link #GEOMETRIC_ZENITH geometric zenith} (90&deg;). This calculation is used for
  ///calculating the start of <em>bain hashmashos</em> (twilight) of 16.875 minutes before sunset converted to degrees
  ///according to the Yereim. As is traditional with degrees below the horizon, this is calculated without refraction
  ///and from the center of the sun. It would be 0.833&deg; less without this.
  ///
  ///@see #getBainHasmashosYereim2Point8Degrees()
  static const double ZENITH_MINUS_2_POINT_8 =
      AstronomicalCalculator.GEOMETRIC_ZENITH - 2.8;

  /// The zenith of 3.05&deg; above {@link #GEOMETRIC_ZENITH geometric zenith} (90&deg;). This calculation is used for
  /// calculating the start of <em>bain hashmashos</em> (twilight) of 18 minutes before sunset converted to degrees
  /// according to the Yereim. As is traditional with degrees below the horizon, this is calculated without refraction
  /// and from the center of the sun. It would be 0.833&deg; less without this.
  ///
  /// @see #getBainHasmashosYereim3Point05Degrees()
  static const double ZENITH_MINUS_3_POINT_05 =
      AstronomicalCalculator.GEOMETRIC_ZENITH - 3.05;

  /// The offset in minutes (defaults to 40) after sunset used for _tzeit_ for Ateret Torah calculations.
  /// _see [getTzaisAteretTorah]_
  /// _see [getAteretTorahSunsetOffset]_
  /// _see [setAteretTorahSunsetOffset]_
  double _ateretTorahSunsetOffset = 40;

  ///
  Map<String, int> shiftTimeByLocationName = {
    'Jerusalem': -37,
    'Petah Tiqva': -37,
    'Safed': -25,
    'Tiberias': -25,
    'Haifa': -25,
    'Beer-Sheba': -17,
    'Ashdod': -17,
    "Ra'anana": -15,
  };

  ComplexZmanimCalendar.intGeoLocation(GeoLocation location)
      : super.intGeolocation(location);

  /// Default constructor will set a default [GeoLocation], a default
  /// [AstronomicalCalculator.getDefault] AstronomicalCalculator and default the calendar to the current date.
  ///
  /// _see [AstronomicalCalendar.AstronomicalCalendar]_
  ComplexZmanimCalendar() : super();

  /// divides the day based on the opinion of the [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)
  /// that the day runs from dawn to dusk. Dawn for this calculation is when the sun is 19.8&deg;
  /// below the eastern geometric horizon before sunrise. Dusk for this is when the sun is 19.8&deg; below the western
  /// geometric horizon after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a double.minPositive
  ///         will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  double getShaahZmanis19Point8Degrees() =>
      getTemporalHour(getAlos19Point8Degrees(), getTzais19Point8Degrees());

  /// the day based on the opinion of the [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)
  /// that the day runs from dawn to dusk. Dawn for this calculation is when the sun is 18&deg; below the
  /// eastern geometric horizon before sunrise. Dusk for this is when the sun is 18&deg; below the western geometric
  /// horizon after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a double.minPositive
  ///         will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  double getShaahZmanis18Degrees() =>
      getTemporalHour(getAlos18Degrees(), getTzais18Degrees());

  /// Method to return a _shaah zmanis_ (temporal hour) calculated using a dip of 26°. This calculation
  /// divides the day based on the opinion of the [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)
  /// that the day runs from dawn to dusk. Dawn for this calculation is when the sun is
  /// {@link #getAlos26Degrees() 26&deg;} below the eastern geometric horizon before sunrise. Dusk for this is when
  /// the sun is {@link #getTzais26Degrees() 26&deg;} below the western geometric horizon after sunset. This day is
  /// split into 12 equal parts with each part being a <em>shaah zmanis</em>.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a double.minPositive
  ///         will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  double getShaahZmanis26Degrees() =>
      getTemporalHour(getAlos26Degrees(), getTzais26Degrees());

  /// Method to return a _shaah zmanis_ (temporal hour) calculated using a dip of 16.1°. This calculation
  /// divides the day based on the opinion that the day runs from dawn to dusk. Dawn for this calculation is when the
  /// sun is 16.1° below the eastern geometric horizon before sunrise and dusk is when the sun is 16.1° below
  /// the western geometric horizon after sunset. This day is split into 12 equal parts with each part being a
  /// _shaah zmanis_.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a double.minPositive
  ///         will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getAlos16Point1Degrees]_
  /// _see [getTzais16Point1Degrees]_
  /// _see [getSofZmanShmaMGA16Point1Degrees]_
  /// _see [getSofZmanTfilaMGA16Point1Degrees]_
  /// _see [getMinchaGedola16Point1Degrees]_
  /// _see [getMinchaKetana16Point1Degrees]_
  /// _see [getPlagHamincha16Point1Degrees]_
  double getShaahZmanis16Point1Degrees() =>
      getTemporalHour(getAlos16Point1Degrees(), getTzais16Point1Degrees());

  /// Method to return a <em>shaah zmanis</em> (solar hour) according to the opinion of the [Magen Avraham (MGA)]
  /// (https://en.wikipedia.org/wiki/Avraham_Gombinern). This calculation divides the day based on the opinion of
  /// the _MGA_ that the day runs from dawn to dusk. Dawn for this calculation is 60 minutes before sunrise and dusk
  /// is 60 minutes after sunset. This day is split into 12 equal parts with each part being a _shaah zmanis_.
  /// Alternate methods of calculating a _shaah zmanis_ are available in the subclass [ComplexZmanimCalendar]
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  double getShaahZmanis60Minutes() =>
      getTemporalHour(getAlos60(), getTzais60());

  /// Method to return a <em>shaah zmanis</em> (solar hour) according to the opinion of the
  /// [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern). This calculation divides the day
  /// based on the opinion of the <em>MGA</em> that the day runs from dawn to dusk. Dawn for this calculation is 72
  /// minutes before sunrise and dusk is 72 minutes after sunset. This day is split into 12 equal parts with each part
  /// being a <em>shaah zmanis</em>. Alternate methods of calculating a <em>shaah zmanis</em> are available in the
  /// subclass {@link ComplexZmanimCalendar}
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  double getShaahZmanis72Minutes() => getShaahZmanisMGA();

  /// Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the <em><a href=
  /// [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern) based on <em>alos</em> being
  /// {@link #getAlos72Zmanis() 72} minutes <em>zmaniyos</em> before {@link #getSunrise() sunrise}. This calculation
  /// divides the day based on the opinion of the <em>MGA</em> that the day runs from dawn to dusk. Dawn for this
  /// calculation is 72 minutes <em>zmaniyos</em> before sunrise and dusk is 72 minutes <em>zmaniyos</em> after sunset.
  /// This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>. This is identical to 1/10th
  /// of the day from {@link #getSunrise() sunrise} to {@link #getSunset() sunset}.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getAlos72Zmanis]_
  /// _see [getTzais72Zmanis]_
  double getShaahZmanis72MinutesZmanis() =>
      getTemporalHour(getAlos72Zmanis(), getTzais72Zmanis());

  /// Method to return a _shaah zmanis_ (temporal hour) calculated using a dip of 90 minutes. This calculation
  /// divides the day based on the opinion of the [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)
  /// that the day runs from dawn to dusk. Dawn for this calculation is 90 minutes before sunrise
  /// and dusk is 90 minutes after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  double getShaahZmanis90Minutes() =>
      getTemporalHour(getAlos90(), getTzais90());

  /// Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the [Magen Avraham (MGA)]
  /// (https://en.wikipedia.org/wiki/Avraham_Gombinern) based on <em>alos</em> being {@link #getAlos90Zmanis() 90} minutes
  /// <em>zmaniyos</em> before {@link #getSunrise() sunrise}. This calculation divides the day based on the opinion of the
  /// <em>MGA</em> that the day runs from dawn to dusk. Dawn for this calculation is 90 minutes <em>zmaniyos</em> before
  /// sunrise and dusk is 90 minutes <em>zmaniyos</em> after sunset. This day is split into 12 equal parts with each part
  /// being a <em>shaah zmanis</em>. This is identical to 1/8th of the day from {@link #getSunrise() sunrise} to
  /// {@link #getSunset() sunset}.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getAlos90Zmanis]_
  /// _see [getTzais90Zmanis]_
  double getShaahZmanis90MinutesZmanis() =>
      getTemporalHour(getAlos90Zmanis(), getTzais90Zmanis());

  /// Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the [Magen Avraham (MGA)]
  /// (https://en.wikipedia.org/wiki/Avraham_Gombinern) based on <em>alos</em> being {@link #getAlos96Zmanis() 96}
  /// minutes <em>zmaniyos</em> before {@link #getSunrise() sunrise}. This calculation divides the day based on the
  /// opinion of the <em>MGA</em> that the day runs from dawn to dusk. Dawn for this calculation is 96 minutes
  /// <em>zmaniyos</em> before sunrise and dusk is 96 minutes <em>zmaniyos</em> after sunset. This day is split
  /// into 12 equal parts with each part being a <em>shaah zmanis</em>. This is identical to 1/7.5th of the day from
  /// {@link #getSunrise() sunrise} to {@link #getSunset() sunset}.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getAlos96Zmanis]_
  /// _see [getTzais96Zmanis]_
  double getShaahZmanis96MinutesZmanis() =>
      getTemporalHour(getAlos96Zmanis(), getTzais96Zmanis());

  /// Method to return a _shaah zmanis_ (temporal hour) according to the opinion of the
  /// _Chacham Yosef Harari-Raful_ of _Yeshivat Ateret Torah_ calculated with _alos_ being 1/10th
  /// of sunrise to sunset day, or [getAlos72Zmanis] 72 minutes _zmaniyos_ of such a day before
  /// [getSunrise] sunrise, and _tzais_ is usually calculated as [getTzaisAteretTorah] 40
  /// minutes (configurable to any offset via [setAteretTorahSunsetOffset]) after [getSunset]]
  /// sunset. This day is split into 12 equal parts with each part being a _shaah zmanis_. Note that with this
  /// system, _chatzos_ (mid-day) will not be the point that the sun is [getSunTransit] halfway across
  /// the sky.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getAlos72Zmanis]_
  /// _see [getTzaisAteretTorah]_
  /// _see [getAteretTorahSunsetOffset]_
  /// _see [setAteretTorahSunsetOffset]_
  double getShaahZmanisAteretTorah() =>
      getTemporalHour(getAlos72Zmanis(), getTzaisAteretTorah());

  /// Method to return a _shaah zmanis_ (temporal hour) calculated using a dip of 96 minutes. This calculation
  /// divides the day based on the opinion of the [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)
  /// that the day runs from dawn to dusk. Dawn for this calculation is 96 minutes before sunrise and dusk is 96 minutes
  /// after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  double getShaahZmanis96Minutes() =>
      getTemporalHour(getAlos96(), getTzais96());

  /// Method to return a _shaah zmanis_ (temporal hour) calculated using a dip of 120 minutes. This calculation
  /// divides the day based on the opinion of the [Magen Avraham (MGA)]https://en.wikipedia.org/wiki/Avraham_Gombinern
  /// that the day runs from dawn to dusk. Dawn for this calculation is 120 minutes before sunrise and dusk is 120 minutes
  /// after sunset. This day is split into 12 equal parts with each part being a <em>shaah zmanis</em>.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  double getShaahZmanis120Minutes() =>
      getTemporalHour(getAlos120(), getTzais120());

  /// Method to return a <em>shaah zmanis</em> (temporal hour) according to the opinion of the [Magen Avraham (MGA)]
  /// (https://en.wikipedia.org/wiki/Avraham_Gombinern) based on <em>alos</em> being {@link #getAlos120Zmanis() 120}
  /// minutes <em>zmaniyos</em> before {@link #getSunrise() sunrise}. This calculation divides the day based on the
  /// opinion of the <em>MGA</em> that the day runs from dawn to dusk. Dawn for this calculation is 120 minutes
  /// <em>zmaniyos</em> before sunrise and dusk is 120 minutes <em>zmaniyos</em> after sunset. This day is
  /// split into 12 equal parts with each part being a <em>shaah zmanis</em>. This is identical to 1/6th of the day from
  /// {@link #getSunrise() sunrise} to {@link #getSunset() sunset}.
  ///
  /// return the <code>double</code> millisecond length of a _shaah zmanis_. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a double.minPositive will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getAlos120Zmanis]_
  /// _see [getTzais120Zmanis]_
  double getShaahZmanis120MinutesZmanis() =>
      getTemporalHour(getAlos120Zmanis(), getTzais120Zmanis());

  /// This method returns the time of _plag hamincha_ based on sunrise being 120 minutes _zmaniyos_
  /// or 1/6th of the day before sunrise. This is calculated as 10.75 hours after [getAlos120Zmanis] dawn.
  /// The formula used is 10.75 * [getShaahZmanis120MinutesZmanis] after [getAlos120Zmanis] dawn.
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  ///
  /// see [getShaahZmanis120MinutesZmanis]
  DateTime? getPlagHamincha120MinutesZmanis() =>
      getPlagHamincha(getAlos120Zmanis(), getTzais120Zmanis());

  /// This method returns the time of _plag hamincha_ according to the _Magen Avraham_ with the day
  /// starting 120 minutes before sunrise and ending 120 minutes after sunset. This is calculated as 10.75 hours after
  /// [getAlos120] dawn 120 minutes. The formula used is
  /// 10.75 [getShaahZmanis120Minutes] after [getAlos120].
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  ///
  /// see #getShaahZmanis120Minutes]
  DateTime? getPlagHamincha120Minutes() =>
      getPlagHamincha(getAlos120(), getTzais120());

  /// Method to return _alos_ (dawn) calculated as 60 minutes before sunrise. This is the time to walk the
  /// distance of 4 _Mil_ at 15 minutes a _Mil_. This seems to be the opinion of the
  /// _[Chavas Yair](https://en.wikipedia.org/wiki/Yair_Bacharach)_ in the _Mekor Chaim, Orach Chaim Ch.
  /// 90_, though  the Mekor chaim in Ch. 58 and in the _[Chut Hashani Cha 97](http://www.hebrewbooks.org/pdfpager.aspx?req=45193&amp;pgnum=214)_
  /// states that a a person walks 3 and a 1/3 _mil_ in an hour, or an 18 minute _mil_. Also see the
  /// [Divrei Malkiel](https://he.wikipedia.org/wiki/%D7%9E%D7%9C%D7%9B%D7%99%D7%90%D7%9C_%D7%A6%D7%91%D7%99_%D7%98%D7%A0%D7%A0%D7%91%D7%95%D7%99%D7%9D)
  /// [Vol. 4, Ch. 20, page 34](http://www.hebrewbooks.org/pdfpager.aspx?req=803&amp;pgnum=33)
  /// who mentions the 15 minute _mil_ lechumra by baking matzos. Also see the
  /// [Maharik](https://en.wikipedia.org/wiki/Joseph_Colon_Trabotto) [Ch. 173](http://www.hebrewbooks.org/pdfpager.aspx?req=1142&amp;pgnum=216)
  /// where the questioner quoting the [Ra'avan](https://en.wikipedia.org/wiki/Eliezer_ben_Nathan) is of the opinion that the time to walk a
  /// _mil_ is 15 minutes (5 _mil_ in a little over an hour). There are many who believe that there is a
  /// _ta'us sofer_ (scribe's error) in the Ra'avan, and it should 4 _mil_ in a little over an hour, or an
  /// 18 minute _mil_. Time based offset calculations are based on the opinion of the
  /// _[Rishonim](https://en.wikipedia.org/wiki/Rishonim)_ who stated that the time of the _neshef_
  /// (time between dawn and sunrise) does not vary by the time of year or location but purely depends on the time it takes to
  /// walk the distance of 4* _mil_. [getTzaisGeonim9Point75Degrees] is a related _zman_ that is a
  /// degree based calculation based on 60 minutes.
  ///
  /// todo Apply documentation to Tzais once reviewed.
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  ///
  /// _see [getTzaisGeonim9Point75Degrees]
  DateTime? getAlos60() => AstronomicalCalendar.getTimeOffset(
      getSunrise(), -60 * AstronomicalCalendar.MINUTE_MILLIS);

  /// Method to return _alos_ (dawn) calculated using 72 minutes _zmaniyos_ or 1/10th of the day before
  /// sunrise. This is based on an 18 minute _Mil_ so the time for 4 _Mil_ is 72 minutes which is 1/10th
  /// of a day (12 * 60 = 720) based on the a day being from [getSeaLevelSunrise] sea level sunrise to
  /// [getSeaLevelSunrise] sea level sunset or [getSunrise sunrise to [getSunset] sunset
  /// (depending on the [isUseElevation] setting).
  /// The actual calculation is [getSeaLevelSunrise]- ( [getShaahZmanisGra] * 1.2). This calculation
  /// is used in the calendars published by
  /// _[Hisachdus Harabanim D'Artzos Habris Ve'Canada](https://en.wikipedia.org/wiki/Central_Rabbinical_Congress)_
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanisGra]_
  DateTime? getAlos72Zmanis() {
    return getZmanisBasedOffset(-1.2);
  }

  /// Utility method to return <em>alos</em> (dawn) or <em>tzais</em> (dusk) based on a fractional day offset.
  /// @param hours the number of <em>shaaos zmaniyos</em> (temporal hours) before sunrise or after sunset that defines dawn
  ///        or dusk. If a negative number is passed in, it will return the time of <em>alos</em> (dawn) (subrtacting the
  ///        time from sunrise) and if a positive number is passed in, it will return the time of <em>tzais</em> (dusk)
  ///        (adding the time to sunset). If 0 is passed in, a null will be returned (since we can't tell if it is sunrise
  ///        or sunset based).
  /// @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. A null will also be returned if 0 is passed in, since we can't tell if it is sunrise
  ///         or sunset based. See detailed explanation on top of the {@link AstronomicalCalendar} documentation.
  DateTime? getZmanisBasedOffset(double hours) {
    double shaahZmanis = getShaahZmanisGra();
    if (shaahZmanis == double.negativeInfinity || hours == 0) {
      return null;
    }
    if (hours > 0) {
      return AstronomicalCalendar.getTimeOffset(
          getElevationAdjustedSunset(), (shaahZmanis * hours));
    } else {
      return AstronomicalCalendar.getTimeOffset(
          getElevationAdjustedSunrise(), (shaahZmanis * hours));
    }
  }

  /// Method to return _alos_ (dawn) calculated using 96 minutes before before [getSunrise] sunrise or
  /// [getSeaLevelSunrise] sea level sunrise (depending on the [isUseElevation] setting) that is based
  /// on the time to walk the distance of 4 _Mil_ at 24 minutes a _Mil_. Time based offset
  /// calculations for _alos_ are based on the opinion of the _[Rishonim](https://en.wikipedia.org/wiki/Rishonim)_
  /// who stated that the time of the _Neshef_ (time between dawn and sunrise) does not vary
  /// by the time of year or location but purely depends on the time it takes to walk the distance of 4 _Mil_.
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getAlos96() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunrise(), -96 * AstronomicalCalendar.MINUTE_MILLIS);

  /// Method to return _alos_ (dawn) calculated using 90 minutes _zmaniyos_ or 1/8th of the day before
  /// [getSunrise] sunrise or [getSeaLevelSunrise] sea level sunrise (depending on the
  /// [isUseElevation] setting). This is based on a 22.5 minute _Mil_ so the time for 4 _Mil_ is 90
  /// minutes which is 1/8th of a day (12 * 60) / 8 = 90
  /// The day is calculated from [getSeaLevelSunrise] sea level sunrise to [getSeaLevelSunrise] sea level
  /// sunset or [getSunrise] sunrise to [getSunset] sunset (depending on the [isUseElevation].
  /// The actual calculation used is [getSunrise] - ( [getShaahZmanisGra] * 1.5).
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getShaahZmanisGra]_
  DateTime? getAlos90Zmanis() {
    double shaahZmanis = getShaahZmanisGra();
    if (shaahZmanis == double.minPositive) {
      return null;
    }
    return AstronomicalCalendar.getTimeOffset(
        getElevationAdjustedSunrise(), (shaahZmanis * -1.5));
  }

  /// This method returns _alos_ (dawn) calculated using 96 minutes _zmaniyos_ or 1/7.5th of the day before
  /// [getSunrise] sunrise or [getSeaLevelSunrise] sea level sunrise (depending on the
  /// [isUseElevation] setting). This is based on a 24 minute _Mil_ so the time for 4 _Mil_ is 96
  /// minutes which is 1/7.5th of a day (12 * 60 / 7.5 = 96).
  /// The day is calculated from [getSeaLevelSunrise sea level sunrise to [getSeaLevelSunrise] sea level
  /// sunset or [getSunrise] sunrise to [getSunset] sunset (depending on the [isUseElevation].
  /// The actual calculation used is [getSunrise] - ( [getShaahZmanisGra] * 1.6).
  ///
  /// _return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getShaahZmanisGra]_
  DateTime? getAlos96Zmanis() {
    return getZmanisBasedOffset(-1.6);
  }

  /// Method to return _alos_ (dawn) calculated using 90 minutes before [getSeaLevelSunrise] sea level
  /// sunrise based on the time to walk the distance of 4 _Mil_ at 22.5 minutes a _Mil_. Time based
  /// offset calculations for _alos_ are based on the opinion of the _[Rishonim](https://en.wikipedia.org/wiki/Rishonim)_
  /// who stated that the time of the _Neshef_ (time between dawn and sunrise) does not vary by the time of year or
  /// location but purely depends on the time it takes to walk the distance of 4 _Mil_.
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getAlos90() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunrise(), -90 * AstronomicalCalendar.MINUTE_MILLIS);

  /// Method to return _alos_ (dawn) calculated using 120 minutes before [getSeaLevelSunrise] sea level
  /// sunrise (no adjustment for elevation is made) based on the time to walk the distance of 5 _Mil_(
  /// _Ula_) at 24 minutes a _Mil_. Time based offset calculations for _alos_ are based on the
  /// opinion of the _[Rishonim](https://en.wikipedia.org/wiki/Rishonim)_ who stated that the time
  /// of the _Neshef_ (time between dawn and sunrise) does not vary by the time of year or location but purely
  /// depends on the time it takes to walk the distance of 5
  /// _Mil_(_Ula_).
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getAlos120() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunrise(), -120 * AstronomicalCalendar.MINUTE_MILLIS);

  /// This method returns _alos_ (dawn) calculated using 120 minutes _zmaniyos_ or 1/6th of the day before
  /// [getSunrise] sunrise or [getSeaLevelSunrise] sea level sunrise (depending on the {link
  /// #isUseElevation] setting). This is based on a 24 minute _Mil_ so the time for 5 _Mil_ is 120
  /// minutes which is 1/6th of a day (12 * 60 / 6 = 120).
  /// The day is calculated from [getSeaLevelSunrise] sea level sunrise to [getSeaLevelSunrise sea level
  /// sunset or [getSunrise] sunrise to [getSunset] sunset (depending on the [isUseElevation].
  /// The actual calculation used is [getSunrise] - ( [getShaahZmanisGra] * 2).
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getShaahZmanisGra]_
  DateTime? getAlos120Zmanis() {
    return getZmanisBasedOffset(-2.0);
  }

  /// A method to return _alos_ (dawn) calculated when the sun is [ZENITH_26_DEGREES] 26° below the
  /// eastern geometric horizon before sunrise. This calculation is based on the same calculation of
  /// [getAlos120] 120 minutes but uses a degree based calculation instead of 120 exact minutes. This
  /// calculation is based on the position of the sun 120 minutes before sunrise in Jerusalem during the equinox (on March
  /// 16, about 4 days before the astronomical equinox, the day that a solar hour is 60 minutes) which calculates to 26°
  /// below [GEOMETRIC_ZENITH] geometric zenith.
  ///
  /// return the <code>DateTime</code> representing _alos_. If the calculation can't be computed such as northern
  ///         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
  ///         may not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_26_DEGREES]_
  /// _see [getAlos120]_
  /// _see [getTzais120]_
  DateTime? getAlos26Degrees() => getSunriseOffsetByDegrees(ZENITH_26_DEGREES);

  /// A method to return _alos_ (dawn) calculated when the sun is [ASTRONOMICAL_ZENITH] 18° below the
  /// eastern geometric horizon before sunrise.
  ///
  /// return the <code>DateTime</code> representing _alos_. If the calculation can't be computed such as northern
  ///         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
  ///         may not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// see [ASTRONOMICAL_ZENITH]
  DateTime? getAlos18Degrees() =>
      getSunriseOffsetByDegrees(AstronomicalCalendar.ASTRONOMICAL_ZENITH);

  /// A method to return _alos_ (dawn) calculated when the sun is [ZENITH_19_DEGREES] 19° below the
  /// eastern geometric horizon before sunrise. This is the _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_'s
  /// alos according to Rabbi Moshe Kosower's [Maaglei Tzedek](http://www.worldcat.org/oclc/145454098), page 88,
  /// [Ayeles Hashachar Vol. I, page 12](http://www.hebrewbooks.org/pdfpager.aspx?req=33464&amp;pgnum=13),
  /// [Yom Valayla Shel Torah, Ch. 34, p. 222](http://www.hebrewbooks.org/pdfpager.aspx?req=55960&amp;pgnum=258) and
  /// Rabbi Yaakov Shakow's [Luach Ikvei Hayom](http://www.worldcat.org/oclc/1043573513).
  ///
  /// return the <code>DateTime</code> representing _alos_. If the calculation can't be computed such as northern
  ///         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
  ///         may not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// _see _[ASTRONOMICAL_ZENITH]_
  DateTime? getAlos19Degrees() => getSunriseOffsetByDegrees(ZENITH_19_DEGREES);

  /// Method to return _alos_ (dawn) calculated when the sun is [ZENITH_19_POINT_8] 19.8° below the
  /// eastern geometric horizon before sunrise. This calculation is based on the same calculation of
  /// [getAlos90] 90 minutes but uses a degree based calculation instead of 90 exact minutes. This calculation
  /// is based on the position of the sun 90 minutes before sunrise in Jerusalem during the equinox (on March 16,
  /// about 4 days before the astronomical equinox, the day that a solar hour is 60 minutes) which calculates to
  /// 19.8° below [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// return the <code>DateTime</code> representing _alos_. If the calculation can't be computed such as northern
  ///         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
  ///         may not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_19_POINT_8]_
  /// _see [getAlos90]_
  DateTime? getAlos19Point8Degrees() =>
      getSunriseOffsetByDegrees(ZENITH_19_POINT_8);

  /// Method to return _alos_ (dawn) calculated when the sun is [ZENITH_16_POINT_1] 16.1° below the
  /// eastern geometric horizon before sunrise. This calculation is based on the same calculation of
  /// [getAlos72] 72 minutes but uses a degree based calculation instead of 72 exact minutes. This calculation
  /// is based on the position of the sun 72 minutes before sunrise in Jerusalem during the equinox (on March 16,
  /// about 4 days before the astronomical equinox, the day that a solar hour is 60 minutes) which calculates to
  /// 16.1° below [GEOMETRIC_ZENITH] geometric zenith.
  ///
  /// return the <code>DateTime</code> representing _alos_. If the calculation can't be computed such as northern
  ///         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
  ///         may not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_16_POINT_1]
  /// _see [getAlos72]
  DateTime? getAlos16Point1Degrees() =>
      getSunriseOffsetByDegrees(ZmanimCalendar.ZENITH_16_POINT_1);

  /// This method returns _misheyakir_ based on the position of the sun when it is [ZENITH_11_DEGREES]
  /// 11.5° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for calculating
  /// _misheyakir_ according to some opinions. This calculation is based on the position of the sun 52 minutes
  /// before [getSunrise sunrise in Jerusalem during the equinox (on March 16, about 4 days before the
  /// astronomical equinox, the day that a solar hour is 60 minutes) which calculates to 11.5° below
  /// [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// return the <code>DateTime</code> of _misheyakir_. If the calculation can't be computed such as northern and
  ///         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
  ///         not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_11_POINT_5]_
  DateTime? getMisheyakir11Point5Degrees() =>
      getSunriseOffsetByDegrees(ZENITH_11_POINT_5);

  /// This method returns _misheyakir_ based on the position of the sun when it is [ZENITH_11_DEGREES]
  /// 11° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for calculating
  /// _misheyakir_ according to some opinions. This calculation is based on the position of the sun 48 minutes
  /// before [getSunrise sunrise in Jerusalem during the equinox (on March 16, about 4 days before the
  /// astronomical equinox, the day that a solar hour is 60 minutes) which calculates to 11° below
  /// [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// return If the calculation can't be computed such as northern and southern locations even south of the Arctic
  ///         Circle and north of the Antarctic Circle where the sun may not reach low enough below the horizon for
  ///         this calculation, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [ZENITH_11_DEGREES]_
  DateTime? getMisheyakir11Degrees() =>
      getSunriseOffsetByDegrees(ZENITH_11_DEGREES);

  /// This method returns _misheyakir_ based on the position of the sun when it is [ZENITH_10_POINT_2]
  /// 10.2° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is used for calculating
  /// _misheyakir_ according to some opinions. This calculation is based on the position of the sun 45 minutes
  /// before [getSunrise sunrise in Jerusalem during the equinox (on March 16, about 4 days before the
  /// astronomical equinox, the day that a solar hour is 60 minutes) which calculates to 10.2° below
  /// [GEOMETRIC_ZENITH] geometric zenith
  ///
  /// return the <code>DateTime</code> of _misheyakir_. If the calculation can't be computed such as
  ///         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
  ///         the sun may not reach low enough below the horizon for this calculation, a null will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_10_POINT_2]_
  DateTime? getMisheyakir10Point2Degrees() =>
      getSunriseOffsetByDegrees(ZENITH_10_POINT_2);

  /// This method returns _misheyakir_ based on the position of the sun when it is [ZENITH_7_POINT_65]
  /// 7.65° below [GEOMETRIC_ZENITH] geometric zenith (90°). The degrees are based on a 35/36 minute zman
  /// during the equinox (on March 16, about 4 days before the astronomical equinox, the day that a solar hour is 60
  /// minutes) when the _neshef_ (twilight) is the shortest. This time is based on
  /// [Rabbi Moshe Feinstein](https://en.wikipedia.org/wiki/Moshe_Feinstein) who writes in
  /// [Ohr Hachaim Vol. 4, Ch. 6](http://www.hebrewbooks.org/pdfpager.aspx?req=14677&amp;pgnum=7)
  /// that misheyakir in New York is 35-40 minutes before sunset, something that is a drop less than 8°.
  /// [Rabbi Yisroel Taplin](https://en.wikipedia.org/wiki/Yisroel_Taplin) in
  /// [Zmanei Yisrael](http://www.worldcat.org/oclc/889556744) (page 117) notes that
  /// [Rabbi Yaakov Kamenetsky](https://en.wikipedia.org/wiki/Yaakov_Kamenetsky) stated that it is not less than 36
  /// minutes before sunrise (maybe it is 40 minutes). Sefer Yisrael Vehazmanim (p. 7) quotes the Tamar Yifrach
  /// in the name of the [Satmar Rov](https://en.wikipedia.org/wiki/Joel_Teitelbaum) that one should be stringent
  /// not consider misheyakir before 36 minutes. This is also the accepted [minhag](https://en.wikipedia.org/wiki/Minhag)
  /// in [Lakewood](https://en.wikipedia.org/wiki/Lakewood_Township,_New_Jersey) that is used in the
  /// [Yeshiva](https://en.wikipedia.org/wiki/Beth_Medrash_Govoha). This follows the opinion of
  /// [Rabbi Shmuel Kamenetsky](https://en.wikipedia.org/wiki/Shmuel_Kamenetsky) who provided the time of 35/36 minutes,
  /// but did not provide a degree based time. Since this zman depends on the level of light, Rabbi Yaakov Shakow presented
  /// this degree based calculations to Rabbi Kamenetsky who agreed to them.
  ///
  /// return the <code>DateTime</code> of _misheyakir_. If the calculation can't be computed such as
  ///         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
  ///         the sun may not reach low enough below the horizon for this calculation, a null will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [ZENITH_7_POINT_65]_
  /// _see [getMisheyakir9Point5Degrees]_
  DateTime? getMisheyakir7Point65Degrees() =>
      getSunriseOffsetByDegrees(ZENITH_7_POINT_65);

  /// This method returns _misheyakir_ based on the position of the sun when it is [ZENITH_9_POINT_5]
  /// 9.5° below [GEOMETRIC_ZENITH] geometric zenith (90°). This calculation is based on Rabbi Dovid Kronglass's
  /// Calculation of 45 minutes in Baltimore as mentioned in <a href=
  /// [Divrei Chachamim No. 24](http://www.hebrewbooks.org/pdfpager.aspx?req=20287&amp;pgnum=29) brought down by the
  /// [Birur Halacha, Tinyana, Ch. 18](http://www.hebrewbooks.org/pdfpager.aspx?req=50535&amp;pgnum=87). This calculates to
  /// 9.5°. Also see [Rabbi Yaakov Yitzchok Neiman](https://en.wikipedia.org/wiki/Jacob_Isaac_Neiman) in Kovetz
  /// Eitz Chaim Vol. 9, p. 202 that the Vyaan Yosef did not want to rely on times earlier than 45 minutes in New York. This
  /// _zman_ is also used in the calendars published by Rabbi Hershel Edelstein. As mentioned in the _Yisroel
  /// Vehazmanim_,  Rabbi Edelstein who was given the 45 minute zman by Rabbi Bick. The calendars published by the
  /// _[Edot Hamizrach](https://en.wikipedia.org/wiki/Mizrahi_Jews)_ communities also use this zman. This also
  /// follows the opinion of [Rabbi Shmuel Kamenetsky](https://en.wikipedia.org/wiki/Shmuel_Kamenetsky) who provided
  /// the time of 36 and 45 minutes, but did not provide a degree based time. Since this zman depends on the level of light,
  /// Rabbi Yaakov Shakow presented these degree based times to Rabbi Shmuel Kamenetsky who agreed to them.
  ///
  /// return the <code>DateTime</code> of _misheyakir_. If the calculation can't be computed such as
  ///         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
  ///         the sun may not reach low enough below the horizon for this calculation, a null will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [ZENITH_9_POINT_5]_
  /// _see [getMisheyakir7Point65Degrees]_
  DateTime? getMisheyakir9Point5Degrees() =>
      getSunriseOffsetByDegrees(ZENITH_9_POINT_5);

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  /// opinion of the _[Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)_ based
  /// on _alos_ being [getAlos19Point8Degrees] 19.8° before [getSunrise] sunrise. This
  /// time is 3 _[getShaahZmanis19Point8Degrees] shaos zmaniyos_ (solar hours) after [getAlos19Point8Degrees]
  /// dawn based on the opinion of the _MGA_ that the day is calculated from dawn to
  /// nightfall with both being 19.8° below sunrise or sunset. This returns the time of 3 *
  /// [getShaahZmanis19Point8Degrees] after [getAlos19Point8Degrees] dawn.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis19Point8Degrees]_
  /// _see [getAlos19Point8Degrees]_
  DateTime? getSofZmanShmaMGA19Point8Degrees() =>
      getSofZmanShma(getAlos19Point8Degrees(), getTzais19Point8Degrees());

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  /// opinion of the _[Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)_ based
  /// on _alos_ being [getAlos16Point1Degrees] 16.1° before [getSunrise] sunrise. This time
  /// is 3 _[getShaahZmanis16Point1Degrees] shaos zmaniyos_ (solar hours) after
  /// [getAlos16Point1Degrees] dawn based on the opinion of the _MGA_ that the day is calculated from
  /// dawn to nightfall with both being 16.1° below sunrise or sunset. This returns the time of
  /// 3 * [getShaahZmanis16Point1Degrees] after [getAlos16Point1Degrees] dawn.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis16Point1Degrees]
  /// _see [getAlos16Point1Degrees]
  DateTime? getSofZmanShmaMGA16Point1Degrees() =>
      getSofZmanShma(getAlos16Point1Degrees(), getTzais16Point1Degrees());

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  /// opinion of the _[Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)_ based
  /// on _alos_ being [getAlos18Degrees] 18° before [getSunrise] sunrise. This time is 3
  /// _[getShaahZmanis18Degrees] shaos zmaniyos_ (solar hours) after [getAlos18Degrees] dawn
  /// based on the opinion of the _MGA_ that the day is calculated from dawn to nightfall with both being 18°
  /// below sunrise or sunset. This returns the time of 3 * [getShaahZmanis18Degrees] after
  /// [getAlos18Degrees] dawn.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis18Degrees]
  /// _see [getAlos18Degrees]
  DateTime? getSofZmanShmaMGA18Degrees() =>
      getSofZmanShma(getAlos18Degrees(), getTzais18Degrees());

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  ///  opinion of the [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern) based on
  /// <em>alos</em> being {@link #getAlos72() 72} minutes before {@link #getSunrise() sunrise}. This time is 3 <em>{@link
  /// #getShaahZmanis72Minutes() shaos zmaniyos}</em> (solar hours) after {@link #getAlos72() dawn} based on the opinion
  /// of the <em>MGA</em> that the day is calculated from a {@link #getAlos72() dawn} of 72 minutes before sunrise to
  /// {@link #getTzais72() nightfall} of 72 minutes after sunset. This returns the time of 3 * {@link
  /// #getShaahZmanis72Minutes()} after {@link #getAlos72() dawn}. This class returns an identical time to {@link
  /// #getSofZmanShmaMGA()} and is repeated here for clarity.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis72Minutes]
  /// _see [getAlos72]
  /// _see [getSofZmanShmaMGA]
  DateTime? getSofZmanShmaMGA72Minutes() => getSofZmanShmaMGA();

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  /// opinion of the _[Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)_ based
  /// on _alos_ being [getAlos72Zmanis] 72 minutes _zmaniyos_, or 1/10th of the day before
  /// [getSunrise] sunrise. This time is 3 _[getShaahZmanis90MinutesZmanis] shaos zmaniyos_
  /// (solar hours) after [getAlos72Zmanis] dawn based on the opinion of the _MGA_ that the day is
  /// calculated from a [getAlos72Zmanis] dawn of 72 minutes _zmaniyos_, or 1/10th of the day before
  /// [getSeaLevelSunrise] sea level sunrise to [getTzais72Zmanis] nightfall of 72 minutes
  /// _zmaniyos_ after [getSeaLevelSunset] sea level sunset. This returns the time of 3 *
  /// [getShaahZmanis72MinutesZmanis] after [getAlos72Zmanis] dawn.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see #getShaahZmanis72MinutesZmanis]_
  /// _see #getAlos72Zmanis]_
  DateTime? getSofZmanShmaMGA72MinutesZmanis() =>
      getSofZmanShma(getAlos72Zmanis(), getTzais72Zmanis());

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  /// opinion of the _[Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern)_ based on
  /// _alos_ being [getAlos90] 90 minutes before [getSunrise] sunrise. This time is 3
  /// _[getShaahZmanis90Minutes] shaos zmaniyos_ (solar hours) after [getAlos90] dawn based on
  /// the opinion of the _MGA_ that the day is calculated from a [getAlos90] dawn of 90 minutes before
  /// sunrise to [getTzais90] nightfall of 90 minutes after sunset. This returns the time of 3 *
  /// [getShaahZmanis90Minutes] after [getAlos90] dawn.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis90Minutes]
  /// _see [getAlos90]
  DateTime? getSofZmanShmaMGA90Minutes() =>
      getSofZmanShma(getAlos90(), getTzais90());

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  /// opinion of the [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern) based
  /// on <em>alos</em> being {@link #getAlos90Zmanis() 90} minutes <em>zmaniyos</em> before {@link #getSunrise()
  /// sunrise}. This time is 3 <em>{@link #getShaahZmanis90MinutesZmanis() shaos zmaniyos}</em> (solar hours) after
  /// {@link #getAlos90Zmanis() dawn} based on the opinion of the <em>MGA</em> that the day is calculated from a {@link
  /// #getAlos90Zmanis() dawn} of 90 minutes <em>zmaniyos</em> before sunrise to {@link #getTzais90Zmanis() nightfall}
  /// of 90 minutes <em>zmaniyos</em> after sunset. This returns the time of 3 * {@link #getShaahZmanis90MinutesZmanis()}
  /// after {@link #getAlos90Zmanis() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis90MinutesZmanis]_
  /// _see [getAlos90Zmanis]_
  DateTime? getSofZmanShmaMGA90MinutesZmanis() =>
      getSofZmanShma(getAlos90Zmanis(), getTzais90Zmanis());

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  /// opinion of the [Magen Avraham (MGA)](https://en.wikipedia.org/wiki/Avraham_Gombinern) based
  /// on <em>alos</em> being {@link #getAlos96() 96} minutes before {@link #getSunrise() sunrise}. This time is 3 <em>
  /// {@link #getShaahZmanis96Minutes() shaos zmaniyos}</em> (solar hours) after {@link #getAlos96() dawn} based on
  /// the opinion of the <em>MGA</em> that the day is calculated from a {@link #getAlos96() dawn} of 96 minutes before
  /// sunrise to {@link #getTzais96() nightfall} of 96 minutes after sunset. This returns the time of 3 * {@link
  /// #getShaahZmanis96Minutes()} after {@link #getAlos96() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis96Minutes]_
  /// _see [getAlos96]_
  DateTime? getSofZmanShmaMGA96Minutes() =>
      getSofZmanShma(getAlos96(), getTzais96());

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  /// opinion of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based
  /// on <em>alos</em> being {@link #getAlos90Zmanis() 96} minutes <em>zmaniyos</em> before {@link #getSunrise()
  /// sunrise}. This time is 3 <em>{@link #getShaahZmanis96MinutesZmanis() shaos zmaniyos}</em> (solar hours) after
  /// {@link #getAlos96Zmanis() dawn} based on the opinion of the <em>MGA</em> that the day is calculated from a {@link
  /// #getAlos96Zmanis() dawn} of 96 minutes <em>zmaniyos</em> before sunrise to {@link #getTzais90Zmanis() nightfall}
  /// of 96 minutes <em>zmaniyos</em> after sunset. This returns the time of 3 * {@link #getShaahZmanis96MinutesZmanis()}
  /// after {@link #getAlos96Zmanis() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis96MinutesZmanis]_
  /// _see [getAlos96Zmanis]_
  DateTime? getSofZmanShmaMGA96MinutesZmanis() =>
      getSofZmanShma(getAlos96Zmanis(), getTzais96Zmanis());

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) calculated as 3
  /// hours (regular and not zmaniyos) before [ZmanimCalendar.getChatzos]. This is the opinion of the
  /// _Shach_ in the _Nekudas Hakesef (Yora Deah 184), Shevus Yaakov, Chasan Sofer_ and others. This
  /// returns the time of 3 hours before [ZmanimCalendar.getChatzos].
  /// todo Add hyperlinks to documentation
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// see [ZmanimCalendar.getChatzos]_
  /// see [getSofZmanTfila2HoursBeforeChatzos]_
  DateTime? getSofZmanShma3HoursBeforeChatzos() =>
      AstronomicalCalendar.getTimeOffset(
          getChatzos(), -180 * AstronomicalCalendar.MINUTE_MILLIS);

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) according to the
  /// opinion of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based
  ///  on <em>alos</em> being {@link #getAlos120() 120} minutes or 1/6th of the day before {@link #getSunrise() sunrise}.
  ///  This time is 3 <em>{@link #getShaahZmanis120Minutes() shaos zmaniyos}</em> (solar hours) after {@link #getAlos120()
  ///  dawn} based on the opinion of the <em>MGA</em> that the day is calculated from a {@link #getAlos120() dawn} of 120
  ///  minutes before sunrise to {@link #getTzais120() nightfall} of 120 minutes after sunset. This returns the time of 3
  ///  {@link #getShaahZmanis120Minutes()} after {@link #getAlos120() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis120Minutes]_
  /// _see [getAlos120]_
  DateTime? getSofZmanShmaMGA120Minutes() =>
      getSofZmanShma(getAlos120(), getTzais120());

  /// This method returns the latest <em>zman krias shema</em> (time to recite <em>Shema</em> in the morning) based
  /// on the opinion that the day starts at <em>{@link #getAlos16Point1Degrees() alos 16.1&deg;}</em> and ends at
  /// {@link #getSeaLevelSunset() sea level sunset}. This is the opinion of the <a href=
  /// "https://hebrewbooks.org/40357">\u05D7\u05D9\u05D3\u05D5\u05E9\u05D9
  /// \u05D5\u05DB\u05DC\u05DC\u05D5\u05EA \u05D4\u05E8\u05D6\u05F4\u05D4</a> and the <a href=
  /// "https://hebrewbooks.org/14799">\u05DE\u05E0\u05D5\u05E8\u05D4 \u05D4\u05D8\u05D4\u05D5\u05E8\u05D4</a> as
  /// mentioned by Yisrael Vehazmanim <a href="https://hebrewbooks.org/pdfpager.aspx?req=9765&pgnum=81">vol 1, sec. 7,
  /// ch. 3 no. 16</a>. Three <em>shaos zmaniyos</em> are calculated based on this day and added to <em>{@link
  /// #getAlos16Point1Degrees() alos}</em> to reach this time. This time is 3 <em>shaos zmaniyos</em> (solar hours) after
  /// {@link #getAlos16Point1Degrees() dawn} based on the opinion that the day is calculated from a <em>{@link
  /// #getAlos16Point1Degrees() alos 16.1&deg;}</em> to {@link #getSeaLevelSunset() sea level sunset}.
  /// <b>Note:</b> Based on this calculation <em>chatzos</em> will not be at midday.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_ based on this day. If the calculation can't
  ///         be computed such as northern and southern locations even south of the Arctic Circle and north of the
  ///         Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a null
  ///         will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getAlos16Point1Degrees]_
  /// _see [getSeaLevelSunset]_
  DateTime? getSofZmanShmaAlos16Point1ToSunset() =>
      getSofZmanShma(getAlos16Point1Degrees(), getElevationAdjustedSunset());

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) based on the
  /// opinion that the day starts at _[getAlos16Point1Degrees] alos 16.1°_ and ends at
  /// _ [getTzaisGeonim7Point083Degrees] tzais 7.083°_. 3 _shaos zmaniyos_ are calculated
  /// based on this day and added to _[getAlos16Point1Degrees] alos_ to reach this time. This time is 3
  /// _shaos zmaniyos_ (temporal hours) after _[getAlos16Point1Degrees] alos 16.1°_ based on
  /// the opinion that the day is calculated from a _[getAlos16Point1Degrees] alos 16.1°_ to
  /// _[getTzaisGeonim7Point083Degrees] tzais 7.083°_.
  /// <b>Note: </b> Based on this calculation _chatzos_ will not be at midday.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_ based on this calculation. If the
  ///         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
  ///         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
  ///         calculation, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getAlos16Point1Degrees]_
  /// _see [getTzaisGeonim7Point083Degrees]_

  DateTime? getSofZmanShmaAlos16Point1ToTzaisGeonim7Point083Degrees() =>
      getSofZmanShma(
          getAlos16Point1Degrees(), getTzaisGeonim7Point083Degrees());

  /// From the GRA in Kol Eliyahu on Berachos #173 that states that _zman krias shema_ is calculated as half the
  /// time from [getSeaLevelSunrise] sea level sunrise to [getFixedLocalChatzos] fixed local chatzos.
  /// The GRA himself seems to contradict this when he stated that _zman krias shema_ is 1/4 of the day from
  /// sunrise to sunset. See _Sarah Lamoed_ #25 in Yisroel Vehazmanim Vol. III page 1016.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_ based on this calculation. If the
  ///         calculation can't be computed such as in the Arctic Circle where there is at least one day a year where
  ///         the sun does not rise, and one where it does not set, a null will be returned. See detailed explanation
  ///         on top of the [AstronomicalCalendar] documentation.
  /// see [getFixedLocalChatzos]
  /// deprecated As per a conversation Rabbi Yisroel Twerski had with Rabbi Harfenes, this zman published in the Yisrael
  ///         Vehazmanim was based on a misunderstanding and should not be used. This deprecated will be removed pending
  ///         confirmation from Rabbi Harfenes.
  DateTime? getSofZmanShmaKolEliyahu() {
    DateTime? chatzos = getFixedLocalChatzos();
    if (chatzos == null || getSunrise() == null) {
      return null;
    }
    double diff = chatzos.difference(getSeaLevelSunrise()!).inMilliseconds / 2;
    return AstronomicalCalendar.getTimeOffset(chatzos, -diff);
  }

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) according to the opinion
  /// of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on
  /// <em>alos</em> being {@link #getAlos19Point8Degrees() 19.8&deg;} before {@link #getSunrise() sunrise}. This time
  /// is 4 <em>{@link #getShaahZmanis19Point8Degrees() shaos zmaniyos}</em> (solar hours) after {@link
  /// #getAlos19Point8Degrees() dawn} based on the opinion of the <em>MGA</em> that the day is calculated from dawn to
  /// nightfall with both being 19.8&deg; below sunrise or sunset. This returns the time of 4 * {@link
  /// #getShaahZmanis19Point8Degrees()} after {@link #getAlos19Point8Degrees() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getShaahZmanis19Point8Degrees]_
  /// _see [getAlos19Point8Degrees]_
  DateTime? getSofZmanTfilaMGA19Point8Degrees() =>
      getSofZmanTfila(getAlos19Point8Degrees(), getTzais19Point8Degrees());

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) according to the opinion
  /// of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on
  /// <em>alos</em> being {@link #getAlos16Point1Degrees() 16.1&deg;} before {@link #getSunrise() sunrise}. This time
  /// is 4 <em>{@link #getShaahZmanis16Point1Degrees() shaos zmaniyos}</em> (solar hours) after {@link
  /// #getAlos16Point1Degrees() dawn} based on the opinion of the <em>MGA</em> that the day is calculated from dawn to
  /// nightfall with both being 16.1&deg; below sunrise or sunset. This returns the time of 4 * {@link
  /// #getShaahZmanis16Point1Degrees()} after {@link #getAlos16Point1Degrees() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see #getShaahZmanis16Point1Degrees]_
  /// _see #getAlos16Point1Degrees]_
  DateTime? getSofZmanTfilaMGA16Point1Degrees() =>
      getSofZmanTfila(getAlos16Point1Degrees(), getTzais16Point1Degrees());

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) according to the opinion
  /// of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on
  /// <em>alos</em> being {@link #getAlos18Degrees() 18&deg;} before {@link #getSunrise() sunrise}. This time is 4
  /// <em>{@link #getShaahZmanis18Degrees() shaos zmaniyos}</em> (solar hours) after {@link #getAlos18Degrees() dawn}
  /// based on the opinion of the <em>MGA</em> that the day is calculated from dawn to nightfall with both being 18&deg;
  /// below sunrise or sunset. This returns the time of 4 * {@link #getShaahZmanis18Degrees()} after
  /// {@link #getAlos18Degrees() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// see [getShaahZmanis18Degrees]_
  /// see [getAlos18Degrees]_
  DateTime? getSofZmanTfilaMGA18Degrees() =>
      getSofZmanTfila(getAlos18Degrees(), getTzais18Degrees());

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) according to the opinion
  /// of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on
  /// <em>alos</em> being {@link #getAlos72() 72} minutes before {@link #getSunrise() sunrise}. This time is 4
  /// <em>{@link #getShaahZmanis72Minutes() shaos zmaniyos}</em> (solar hours) after {@link #getAlos72() dawn} based on
  /// the opinion of the <em>MGA</em> that the day is calculated from a {@link #getAlos72() dawn} of 72 minutes before
  /// sunrise to {@link #getTzais72() nightfall} of 72 minutes after sunset. This returns the time of 4 *
  /// {@link #getShaahZmanis72Minutes()} after {@link #getAlos72() dawn}. This class returns an identical time to
  /// {@link #getSofZmanTfilaMGA()} and is repeated here for clarity.
  ///
  /// return the <code>DateTime</code> of the latest _zman tfila_. If the calculation can't be computed such as in
  ///         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis72Minutes]_
  /// _see [getAlos72]_
  /// _see [getSofZmanShmaMGA]_
  DateTime? getSofZmanTfilaMGA72Minutes() => getSofZmanTfilaMGA();

  /// This method returns the latest _zman tfila_ (time to the morning prayers) according to the opinion of the
  /// <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on <em>alos</em>
  /// being {@link #getAlos72Zmanis() 72} minutes <em>zmaniyos</em> before {@link #getSunrise() sunrise}. This time is 4
  /// <em>{@link #getShaahZmanis72MinutesZmanis() shaos zmaniyos}</em> (solar hours) after {@link #getAlos72Zmanis() dawn}
  /// based on the opinion of the <em>MGA</em> that the day is calculated from a {@link #getAlos72Zmanis() dawn} of 72
  /// minutes <em>zmaniyos</em> before sunrise to {@link #getTzais72Zmanis() nightfall} of 72 minutes <em>zmaniyos</em>
  /// after sunset. This returns the time of 4 * {@link #getShaahZmanis72MinutesZmanis()} after {@link #getAlos72Zmanis() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis72MinutesZmanis]_
  /// _see [getAlos72Zmanis]_
  DateTime? getSofZmanTfilaMGA72MinutesZmanis() =>
      getSofZmanTfila(getAlos72Zmanis(), getTzais72Zmanis());

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) according to the opinion
  /// of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on
  /// <em>alos</em> being {@link #getAlos90() 90} minutes before {@link #getSunrise() sunrise}. This time is 4
  /// <em>{@link #getShaahZmanis90Minutes() shaos zmaniyos}</em> (solar hours) after {@link #getAlos90() dawn} based on
  /// the opinion of the <em>MGA</em> that the day is calculated from a {@link #getAlos90() dawn} of 90 minutes before
  /// sunrise to {@link #getTzais90() nightfall} of 90 minutes after sunset. This returns the time of 4 *
  /// {@link #getShaahZmanis90Minutes()} after {@link #getAlos90() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman tfila_. If the calculation can't be computed such as in
  ///         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis90Minutes]_
  /// _see [getAlos90]_
  DateTime? getSofZmanTfilaMGA90Minutes() =>
      getSofZmanTfila(getAlos90(), getTzais90());

  /// This method returns the latest _zman tfila_ (time to the morning prayers) according to the opinion of the
  /// <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on <em>alos</em>
  /// being {@link #getAlos90Zmanis() 90} minutes <em>zmaniyos</em> before {@link #getSunrise() sunrise}. This time is
  /// 4 <em>{@link #getShaahZmanis90MinutesZmanis() shaos zmaniyos}</em> (solar hours) after {@link #getAlos90Zmanis()
  /// dawn} based on the opinion of the <em>MGA</em> that the day is calculated from a {@link #getAlos90Zmanis() dawn}
  /// of 90 minutes <em>zmaniyos</em> before sunrise to {@link #getTzais90Zmanis() nightfall} of 90 minutes
  /// <em>zmaniyos</em> after sunset. This returns the time of 4 * {@link #getShaahZmanis90MinutesZmanis()} after
  /// {@link #getAlos90Zmanis() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis90MinutesZmanis]_
  /// _see [getAlos90Zmanis]_
  DateTime? getSofZmanTfilaMGA90MinutesZmanis() =>
      getSofZmanTfila(getAlos90Zmanis(), getTzais90Zmanis());

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) according to the opinion
  ///  of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on
  /// <em>alos</em> being {@link #getAlos96() 96} minutes before {@link #getSunrise() sunrise}. This time is 4
  /// <em>{@link #getShaahZmanis96Minutes() shaos zmaniyos}</em> (solar hours) after {@link #getAlos96() dawn} based on
  /// the opinion of the <em>MGA</em> that the day is calculated from a {@link #getAlos96() dawn} of 96 minutes before
  /// sunrise to {@link #getTzais96() nightfall} of 96 minutes after sunset. This returns the time of 4 *
  /// {@link #getShaahZmanis96Minutes()} after {@link #getAlos96() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman tfila_. If the calculation can't be computed such as in
  ///         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis96Minutes]_
  /// _see [getAlos96]_
  DateTime? getSofZmanTfilaMGA96Minutes() =>
      getSofZmanTfila(getAlos96(), getTzais96());

  /// This method returns the latest _zman tfila_ (time to the morning prayers) according to the opinion of the
  ///  <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on <em>alos</em>
  /// being {@link #getAlos96Zmanis() 96} minutes <em>zmaniyos</em> before {@link #getSunrise() sunrise}. This time is
  /// 4 <em>{@link #getShaahZmanis96MinutesZmanis() shaos zmaniyos}</em> (solar hours) after {@link #getAlos96Zmanis()
  /// dawn} based on the opinion of the <em>MGA</em> that the day is calculated from a {@link #getAlos96Zmanis() dawn}
  /// of 96 minutes <em>zmaniyos</em> before sunrise to {@link #getTzais96Zmanis() nightfall} of 96 minutes
  /// <em>zmaniyos</em> after sunset. This returns the time of 4 * {@link #getShaahZmanis96MinutesZmanis()} after
  /// {@link #getAlos96Zmanis() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis90MinutesZmanis]_
  /// _see [getAlos90Zmanis]_
  DateTime? getSofZmanTfilaMGA96MinutesZmanis() =>
      getSofZmanTfila(getAlos96Zmanis(), getTzais96Zmanis());

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) according to the opinion
  ///  of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on
  /// <em>alos</em> being {@link #getAlos120() 120} minutes before {@link #getSunrise() sunrise} . This time is 4
  /// <em>{@link #getShaahZmanis120Minutes() shaos zmaniyos}</em> (solar hours) after {@link #getAlos120() dawn}
  /// based on the opinion of the <em>MGA</em> that the day is calculated from a {@link #getAlos120() dawn} of 120
  /// minutes before sunrise to {@link #getTzais120() nightfall} of 120 minutes after sunset. This returns the time of
  /// 4 * {@link #getShaahZmanis120Minutes()} after {@link #getAlos120() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis120Minutes]_
  /// _see [getAlos120]_
  DateTime? getSofZmanTfilaMGA120Minutes() =>
      getSofZmanTfila(getAlos120(), getTzais120());

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) calculated as 2 hours
  /// before [ZmanimCalendar.getChatzos]. This is based on the opinions that calculate
  /// _sof zman krias shema_ as [getSofZmanShma3HoursBeforeChatzos]. This returns the time of 2 hours
  /// before [ZmanimCalendar.getChatzos].
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_. If the calculation can't be computed such
  ///         as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where
  ///         it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// see [ZmanimCalendar.getChatzos]
  /// see [getSofZmanShma3HoursBeforeChatzos]
  DateTime? getSofZmanTfila2HoursBeforeChatzos() =>
      AstronomicalCalendar.getTimeOffset(
          getChatzos(), -120 * AstronomicalCalendar.MINUTE_MILLIS);

  /// This method returns mincha gedola calculated as 30 minutes after _[getChatzos] chatzos_ and not
  /// 1/2 of a _[getShaahZmanisGra] shaah zmanis_ after _[getChatzos] chatzos_ as
  /// calculated by [getMinchaGedola. Some use this time to delay the start of mincha in the winter when 1/2 of
  /// a _[getShaahZmanisGra] shaah zmanis_ is less than 30 minutes. See
  /// [getMinchaGedolaGreaterThan30]for a convenience method that returns the later of the 2 calculations. One
  /// should not use this time to start _mincha_ before the standard
  /// _[getMinchaGedola] mincha gedola_. See _Shulchan Aruch
  /// Orach Chayim Siman Raish Lamed Gimel seif alef_ and the _Shaar Hatziyon seif katan ches_.
  /// todo Add hyperlinks to documentation.
  ///
  /// return the <code>DateTime</code> of 30 minutes after _chatzos_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getMinchaGedola]_
  /// _see [getMinchaGedolaGreaterThan30]_
  DateTime? getMinchaGedola30Minutes() => AstronomicalCalendar.getTimeOffset(
      getChatzos(), AstronomicalCalendar.MINUTE_MILLIS * 30);

  /// This method returns the time of _mincha gedola_ according to the Magen Avraham with the day starting 72
  /// minutes before sunrise and ending 72 minutes after sunset. This is the earliest time to pray _mincha_. For
  /// more information on this see the documentation on _[getMinchaGedola] mincha gedola_. This is
  /// calculated as 6.5 [getTemporalHour] solar hours after alos. The calculation used is 6.5 *
  /// [getShaahZmanis72Minutes] after [getAlos72] alos.
  ///
  /// _see [getAlos72]_
  /// _see [getMinchaGedola]_
  /// _see [getMinchaKetana]_
  /// _see [ZmanimCalendar.getMinchaGedola]_
  /// return the <code>DateTime</code> of the time of mincha gedola. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getMinchaGedola72Minutes() =>
      getMinchaGedola(getAlos72(), getTzais72());

  /// This method returns the time of _mincha gedola_ according to the Magen Avraham with the day starting and
  /// ending 16.1° below the horizon. This is the earliest time to pray _mincha_. For more information on
  /// this see the documentation on _[getMinchaGedola] mincha gedola_. This is calculated as 6.5
  /// [getTemporalHour] solar hours after alos. The calculation used is 6.5 *
  /// [getShaahZmanis16Point1Degrees] after [getAlos16Point1Degrees] alos.
  ///
  /// _see [getShaahZmanis16Point1Degrees]_
  /// _see [getMinchaGedola]_
  /// _see [getMinchaKetana]_
  /// return the <code>DateTime</code> of the time of mincha gedola. If the calculation can't be computed such as northern
  ///         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
  ///         may not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getMinchaGedola16Point1Degrees() =>
      getMinchaGedola(getAlos16Point1Degrees(), getTzais16Point1Degrees());

  /// This is a convenience method that returns the later of [getMinchaGedola] and
  /// [getMinchaGedola30Minutes]. In the winter when 1/2 of a _[getShaahZmanisGra] shaah zmanis_ is
  /// less than 30 minutes [getMinchaGedola30Minutes] will be returned, otherwise [getMinchaGedola]
  /// will be returned.
  ///
  /// return the <code>DateTime</code> of the later of [getMinchaGedola] and [getMinchaGedola30Minutes].
  ///         If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year
  ///         where the sun does not rise, and one where it does not set, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getMinchaGedolaGreaterThan30() {
    if (getMinchaGedola30Minutes() == null || getMinchaGedola() == null) {
      return null;
    } else {
      return getMinchaGedola30Minutes()!.compareTo(getMinchaGedola()!) > 0
          ? getMinchaGedola30Minutes()
          : getMinchaGedola();
    }
  }

  /// This method returns the time of _mincha ketana_ according to the _Magen Avraham_ with the day
  /// starting and ending 16.1° below the horizon. This is the preferred earliest time to pray _mincha_
  /// according to the opinion of the _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_ and others.
  /// For more information on this see the documentation on _[getMinchaGedola] mincha gedola_. This is
  /// calculated as 9.5 [getTemporalHour] solar hours after alos. The calculation used is 9.5 *
  /// [getShaahZmanis16Point1Degrees] after [getAlos16Point1Degrees] alos.
  ///
  /// _see [getShaahZmanis16Point1Degrees]_
  /// _see [getMinchaGedola]_
  /// _see [getMinchaKetana]_
  /// return the <code>DateTime</code> of the time of mincha ketana. If the calculation can't be computed such as northern
  ///         and southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun
  ///         may not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getMinchaKetana16Point1Degrees() =>
      getMinchaKetana(getAlos16Point1Degrees(), getTzais16Point1Degrees());

  /// This method returns the time of _mincha ketana_ according to the _Magen Avraham_ with the day
  /// starting 72 minutes before sunrise and ending 72 minutes after sunset. This is the preferred earliest time to pray
  /// _mincha_ according to the opinion of the _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_
  /// and others. For more information on this see the documentation on _[getMinchaGedola] mincha gedola_.
  /// This is calculated as 9.5 [getShaahZmanis72Minutes] after _alos_. The calculation used is 9.5 *
  /// [getShaahZmanis72Minutes] after _[getAlos72] alos_.
  ///
  /// _see [getShaahZmanis16Point1Degrees]_
  /// _see [getMinchaGedola]_
  /// _see [getMinchaKetana]_
  /// return the <code>DateTime</code> of the time of mincha ketana. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getMinchaKetana72Minutes() =>
      getMinchaKetana(getAlos72(), getTzais72());

  /// This method returns the time of _plag hamincha_ according to the _Magen Avraham_ with the day
  /// starting 60 minutes before sunrise and ending 60 minutes after sunset. This is calculated as 10.75 hours after
  /// [getAlos60] dawn. The formula used is
  /// 10.75 [getShaahZmanis60Minutes] after [getAlos60].
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  ///
  /// _see [getShaahZmanis60Minutes]_
  DateTime? getPlagHamincha60Minutes() =>
      getPlagHamincha(getAlos60(), getTzais60());

  /// This method returns the time of _plag hamincha_ according to the _Magen Avraham_ with the day
  /// starting 72 minutes before sunrise and ending 72 minutes after sunset. This is calculated as 10.75 hours after
  /// [getAlos72] dawn. The formula used is
  /// 10.75 [getShaahZmanis72Minutes] after [getAlos72].
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  ///
  /// _see [getShaahZmanis72Minutes]_
  DateTime? getPlagHamincha72Minutes() =>
      getPlagHamincha(getAlos72(), getTzais72());

  /// This method returns the time of _plag hamincha_ according to the _Magen Avraham_ with the day
  /// starting 90 minutes before sunrise and ending 90 minutes after sunset. This is calculated as 10.75 hours after
  /// [getAlos90] dawn. The formula used is
  /// 10.75 [getShaahZmanis90Minutes] after [getAlos90].
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getShaahZmanis90Minutes]_
  DateTime? getPlagHamincha90Minutes() =>
      getPlagHamincha(getAlos90(), getTzais90());

  /// This method returns the time of _plag hamincha_ according to the _Magen Avraham_ with the day
  /// starting 96 minutes before sunrise and ending 96 minutes after sunset. This is calculated as 10.75 hours after
  /// [getAlos96] dawn. The formula used is
  /// 10.75 [getShaahZmanis96Minutes] after [getAlos96].
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanis96Minutes]_
  DateTime? getPlagHamincha96Minutes() =>
      getPlagHamincha(getAlos96(), getTzais96());

  /// This method returns the time of _plag hamincha_. This is calculated as 10.75 hours after
  /// [getAlos96Zmanis] dawn. The formula used is
  /// 10.75 * [getShaahZmanis96MinutesZmanis] after [getAlos96Zmanis] dawn.
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getPlagHamincha96MinutesZmanis() =>
      getPlagHamincha(getAlos96Zmanis(), getTzais96Zmanis());

  /// This method returns the time of _plag hamincha_. This is calculated as 10.75 hours after
  /// [getAlos90Zmanis] dawn. The formula used is
  /// 10.75 * [getShaahZmanis90MinutesZmanis] after [getAlos90Zmanis] dawn.
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getPlagHamincha90MinutesZmanis() =>
      getPlagHamincha(getAlos90Zmanis(), getTzais90Zmanis());

  /// This method returns the time of _plag hamincha_. This is calculated as 10.75 hours after
  /// [getAlos72Zmanis] dawn. The formula used is
  /// 10.75 * [getShaahZmanis72MinutesZmanis] after [getAlos72Zmanis] dawn.
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getPlagHamincha72MinutesZmanis() =>
      getPlagHamincha(getAlos72Zmanis(), getTzais72Zmanis());

  /// This method returns the time of _plag hamincha_ based on the opinion that the day starts at
  /// _[getAlos16Point1Degrees] alos 16.1°_ and ends at
  /// _[getTzais16Point1Degrees] tzais 16.1°_. This is calculated as 10.75 hours _zmaniyos_
  /// after [getAlos16Point1Degrees] dawn. The formula used is
  /// 10.75 * [getShaahZmanis16Point1Degrees] after [getAlos16Point1Degrees].
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
  ///         the sun may not reach low enough below the horizon for this calculation, a null will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see _getShaahZmanis16Point1Degrees]
  DateTime? getPlagHamincha16Point1Degrees() =>
      getPlagHamincha(getAlos16Point1Degrees(), getTzais16Point1Degrees());

  /// This method returns the time of _plag hamincha_ based on the opinion that the day starts at
  /// _[getAlos19Point8Degrees] alos 19.8°_ and ends at
  /// _[getTzais19Point8Degrees] tzais 19.8°_. This is calculated as 10.75 hours _zmaniyos_
  /// after [getAlos19Point8Degrees] dawn. The formula used is
  /// 10.75 * [getShaahZmanis19Point8Degrees] after [getAlos19Point8Degrees].
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
  ///         the sun may not reach low enough below the horizon for this calculation, a null will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getShaahZmanis19Point8Degrees]_
  DateTime? getPlagHamincha19Point8Degrees() =>
      getPlagHamincha(getAlos19Point8Degrees(), getTzais19Point8Degrees());

  /// This method returns the time of _plag hamincha_ based on the opinion that the day starts at
  /// _[getAlos26Degrees] alos 26°_ and ends at _[getTzais26Degrees] tzais 26°_
  /// . This is calculated as 10.75 hours _zmaniyos_ after [getAlos26Degrees] dawn. The formula used is
  /// 10.75 * [getShaahZmanis26Degrees] after [getAlos26Degrees].
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
  ///         the sun may not reach low enough below the horizon for this calculation, a null will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getShaahZmanis26Degrees]_
  DateTime? getPlagHamincha26Degrees() =>
      getPlagHamincha(getAlos26Degrees(), getTzais26Degrees());

  /// This method returns the time of _plag hamincha_ based on the opinion that the day starts at
  /// _[getAlos18Degrees] alos 18°_ and ends at _[getTzais18Degrees] tzais 18°_
  /// . This is calculated as 10.75 hours _zmaniyos_ after [getAlos18Degrees] dawn. The formula used is
  /// 10.75 * [getShaahZmanis18Degrees] after [getAlos18Degrees].
  ///
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
  ///         the sun may not reach low enough below the horizon for this calculation, a null will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getShaahZmanis18Degrees]_
  DateTime? getPlagHamincha18Degrees() =>
      getPlagHamincha(getAlos18Degrees(), getTzais18Degrees());

  /// This method returns the time of _plag hamincha_ based on the opinion that the day starts at
  /// _[getAlos16Point1Degrees] alos 16.1°_ and ends at [getSunset] sunset. 10.75 shaos
  /// zmaniyos are calculated based on this day and added to [getAlos16Point1Degrees] alos to reach this time.
  /// This time is 10.75 _shaos zmaniyos_ (temporal hours) after [getAlos16Point1Degrees] dawn based on
  /// the opinion that the day is calculated from a [getAlos16Point1Degrees] dawn of 16.1 degrees before
  /// sunrise to [getSeaLevelSunset] sea level sunset. This returns the time of 10.75 * the calculated
  /// _shaah zmanis_ after [getAlos16Point1Degrees] dawn.
  ///
  /// return the <code>DateTime</code> of the plag. If the calculation can't be computed such as northern and southern
  ///         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
  ///         low enough below the horizon for this calculation, a null will be returned. See detailed explanation on
  ///         top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getAlos16Point1Degrees]_
  /// _see [getSeaLevelSunset]_
  DateTime? getPlagAlosToSunset() =>
      getPlagHamincha(getAlos16Point1Degrees(), getElevationAdjustedSunset());

  /// This method returns the time of _plag hamincha_ based on the opinion that the day starts at
  /// _[getAlos16Point1Degrees] alos 16.1°_ and ends at [getTzaisGeonim7Point083Degrees]
  /// tzais. 10.75 shaos zmaniyos are calculated based on this day and added to [getAlos16Point1Degrees] alos
  /// to reach this time. This time is 10.75 _shaos zmaniyos_ (temporal hours) after
  /// [getAlos16Point1Degrees] dawn based on the opinion that the day is calculated from a
  /// [getAlos16Point1Degrees] dawn of 16.1 degrees before sunrise to
  /// [getTzaisGeonim7Point083Degrees] tzais . This returns the time of 10.75 * the calculated
  /// _shaah zmanis_ after [getAlos16Point1Degrees] dawn.
  ///
  /// return the <code>DateTime</code> of the plag. If the calculation can't be computed such as northern and southern
  ///         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
  ///         low enough below the horizon for this calculation, a null will be returned. See detailed explanation on
  ///         top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getAlos16Point1Degrees]_
  /// _see [getTzaisGeonim7Point083Degrees]_
  DateTime? getPlagAlos16Point1ToTzaisGeonim7Point083Degrees() =>
      getPlagHamincha(
          getAlos16Point1Degrees(), getTzaisGeonim7Point083Degrees());

  /// Method to return the beginning of <em>bain hashmashos</em> of <em>Rabbeinu Tam</em> calculated when the sun is
  /// [ZENITH_13_POINT_24] 13.24° below the western [GEOMETRIC_ZENITH] geometric horizon (90°)
  /// after sunset. This calculation is based on the same calculation of [getBainHasmashosRT58Point5Minutes]
  /// <em>bain hashmashos</em> Rabbeinu Tam 58.5 minutes} but uses a degree based calculation instead of 58.5 exact
  /// minutes. This calculation is based on the position of the sun 58.5 minutes after sunset in Jerusalem during the
  /// equinox (on March 16, about 4 days before the astronomical equinox, the day that a solar hour is 60 minutes)
  /// which calculates to 13.24&deg; below {@link #GEOMETRIC_ZENITH geometric zenith}.
  /// NOTE: As per Yisrael Vehazmanim Vol. III page 1028 No 50, a dip of slightly less than 13° should be used.
  /// Calculations show that the proper dip to be 13.2456° (truncated to 13.24 that provides about 1.5 second
  /// earlier (_lechumra_) time) below the horizon at that time. This makes a difference of 1 minute and 10
  /// seconds in Jerusalem during the Equinox, and 1 minute 29 seconds during the solstice as compared to the proper
  /// 13.24° versus 13°. For NY during the solstice, the difference is 1 minute 56 seconds.
  ///
  /// return the <code>DateTime</code> of the sun being 13.24° below [GEOMETRIC_ZENITH] geometric zenith
  ///         (90°). If the calculation can't be computed such as northern and southern locations even south of the
  ///         Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below the horizon
  ///         for this calculation, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  ///
  /// _see [ZENITH_13_POINT_24]_
  /// _see [getBainHasmashosRT58Point5Minutes]_
  DateTime? getBainHasmashosRT13Point24Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_13_POINT_24);

  /// This method returns the beginning of <em>Bain hashmashos</em> of <em>Rabbeinu Tam</em> calculated as a 58.5
  /// minute offset after sunset. <em>bain hashmashos</em> is 3/4 of a <em>Mil</em> before <em>tzais</em> or 3 1/4
  /// <em>Mil</em> after sunset. With a <em>Mil</em> calculated as 18 minutes, 3.25 * 18 = 58.5 minutes.
  ///
  /// return the <code>DateTime</code> of 58.5 minutes after sunset. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  ///
  DateTime? getBainHasmashosRT58Point5Minutes() =>
      AstronomicalCalendar.getTimeOffset(getElevationAdjustedSunset(),
          58.5 * AstronomicalCalendar.MINUTE_MILLIS);

  /// This method returns the beginning of <em>bain hashmashos</em> based on the calculation of 13.5 minutes (3/4 of an
  /// 18 minute <em>Mil</em>) before <em>shkiah</em> calculated as {@link #getTzaisGeonim7Point083Degrees() 7.083&deg;}.
  ///
  /// return the <code>DateTime</code> of the _bain hashmashos_ of _Rabbeinu Tam_ in this calculation. If the
  ///         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
  ///         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
  ///         calculation, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getTzaisGeonim7Point083Degrees]_
  DateTime? getBainHasmashosRT13Point5MinutesBefore7Point083Degrees() =>
      AstronomicalCalendar.getTimeOffset(
          getSunsetOffsetByDegrees(ZENITH_7_POINT_083),
          -13.5 * AstronomicalCalendar.MINUTE_MILLIS);

  /// This method returns the beginning of <em>bain hashmashos</em> of <em>Rabbeinu Tam</em> calculated according to the
  /// opinion of the <em>Divrei Yosef</em> (see Yisrael Vehazmanim) calculated 5/18th (27.77%) of the time between
  /// <em>alos</em> (calculated as 19.8&deg; before sunrise) and sunrise. This is added to sunset to arrive at the time
  /// for <em>bain hashmashos</em> of <em>Rabbeinu Tam</em>).
  ///
  /// return the <code>DateTime</code> of _bain hashmashos_ of _Rabbeinu Tam_ for this calculation. If the
  ///         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
  ///         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
  ///         calculation, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getBainHasmashosRT2Stars() {
    DateTime? alos19Point8 = getAlos19Point8Degrees();
    DateTime? sunrise = getElevationAdjustedSunrise();
    if (alos19Point8 == null || sunrise == null) {
      return null;
    }
    return AstronomicalCalendar.getTimeOffset(getElevationAdjustedSunset(),
        (sunrise.difference(alos19Point8)).inMilliseconds * (5 / 18));
  }

  /// This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the [Yereim (Rabbi Eliezer of Metz)]
  /// (https://en.wikipedia.org/wiki/Eliezer_ben_Samuel) calculated as 18 minutes or 3/4 of a 24 minute <em>Mil</em>
  /// before sunset. According to the Yereim, <em>bain hashmashos</em> starts 3/4 of a <em>Mil</em> before sunset and
  /// <em>tzais</em> or nightfall starts at sunset.
  ///
  /// @return the <code>Date</code> of 18 minutes before sunset. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the {@link AstronomicalCalendar}
  ///         documentation.
  /// @see #getBainHasmashosYereim3Point05Degrees()
  DateTime? getBainHasmashosYereim18Minutes() {
    return AstronomicalCalendar.getTimeOffset(
        getElevationAdjustedSunset(), -18 * AstronomicalCalendar.MINUTE_MILLIS);
  }

  /// This method returns the beginning of <em>hain hashmashos</em> (twilight) according to the [Yereim (Rabbi Eliezer of Metz)]
  /// (https://en.wikipedia.org/wiki/Eliezer_ben_Samuel) calculated as the sun's position 3.05&deg; above the horizon during the
  /// equinox (on March 16, about 4 days before the astronomical equinox, the day that a solar hour is 60 minutes) in
  /// Yerushalayim, its position 18 minutes or 3/4 of an 24 minute <em>Mil</em> before sunset. According to the Yereim,
  /// bain hashmashos starts 3/4 of a <em>Mil</em> before sunset and <em>tzais</em> or nightfall starts at sunset.
  ///
  /// @return the <code>Date</code> of the sun's position 3.05&deg; minutes before sunset. If the calculation can't
  ///         be computed such as in the Arctic Circle where there is at least one day a year where the sun does not
  ///         rise, and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         {@link AstronomicalCalendar} documentation.
  ///
  /// @see #ZENITH_MINUS_3_POINT_05
  /// @see #getBainHasmashosYereim18Minutes()
  ///
  DateTime? getBainHasmashosYereim3Point5Degrees() {
    return getSunsetOffsetByDegrees(ZENITH_MINUS_3_POINT_05);
  }

  /// This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the [Yereim (Rabbi Eliezer of Metz)]
  /// (https://en.wikipedia.org/wiki/Eliezer_ben_Samuel) calculated as 16.875 minutes or 3/4 of a 22.5 minute <em>Mil</em>
  /// before sunset. According to the Yereim, bain hashmashos starts 3/4 of a <em>Mil</em> before sunset and <em>tzais</em> or
  /// nightfall starts at sunset.
  ///
  /// @return the <code>Date</code> of 16.875 minutes before sunset. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the {@link AstronomicalCalendar}
  ///         documentation.
  ///
  /// @see #getBainHasmashosYereim2Point8Degrees()
  DateTime? getBainHasmashosYereim16Point875Minutes() {
    return AstronomicalCalendar.getTimeOffset(getElevationAdjustedSunset(),
        -16.875 * AstronomicalCalendar.MINUTE_MILLIS);
  }

  /// This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the [Yereim (Rabbi Eliezer of Metz)]
  /// (https://en.wikipedia.org/wiki/Eliezer_ben_Samuel) calculated as the sun's position 2.8&deg; above the horizon during
  /// the equinox (on March 16, about 4 days before the astronomical equinox, the day that a solar hour is 60 minutes) in Yerushalayim,
  /// its position 16.875 minutes or 3/4 of an 18 minute <em>Mil</em> before sunset. According to the Yereim, bain hashmashos starts
  /// 3/4 of a <em>Mil</em> before sunset and <em>tzais</em> or nightfall starts at sunset.
  ///
  /// @return the <code>Date</code> of the sun's position 2.8&deg; minutes before sunset. If the calculation can't
  ///         be computed such as in the Arctic Circle where there is at least one day a year where the sun does not
  ///         rise, and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         {@link AstronomicalCalendar} documentation.
  ///
  /// @see #ZENITH_MINUS_2_POINT_8
  /// @see #getBainHasmashosYereim16Point875Minutes()
  DateTime? getBainHasmashosYereim2Point8Degrees() {
    return getSunsetOffsetByDegrees(ZENITH_MINUS_2_POINT_8);
  }

  /// This method returns the beginning of <em>bain hashmashos</em> (twilight) according to the [Yereim (Rabbi Eliezer of Metz)]
  /// (https://en.wikipedia.org/wiki/Eliezer_ben_Samuel) calculated as 13.5 minutes or 3/4 of an 18 minute <em>Mil</em>
  /// before sunset. According to the Yereim, bain hashmashos starts 3/4 of a <em>Mil</em> before sunset and <em>tzais</em> or
  /// nightfall starts at sunset.
  ///
  /// @return the <code>Date</code> of 13.5 minutes before sunset. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the {@link AstronomicalCalendar}
  ///         documentation.
  ///
  /// @see #getBainHasmashosYereim2Point1Degrees()
  DateTime? getBainHasmashosYereim13Point5Minutes() {
    return AstronomicalCalendar.getTimeOffset(getElevationAdjustedSunset(),
        -13.5 * AstronomicalCalendar.MINUTE_MILLIS);
  }

  /// This method returns the beginning of <em>bain hashmashos</em> according to the [Yereim (Rabbi Eliezer of Metz)]
  /// (https://en.wikipedia.org/wiki/Eliezer_ben_Samuel) calculated as the sun's position 2.1&deg; above the horizon
  /// during the equinox (on March 16, about 4 days before the astronomical equinox, the day that a solar hour is 60 minutes)
  /// in Yerushalayim, its position 13.5 minutes or 3/4 of an 18 minute <em>Mil</em> before sunset. According to the Yereim,
  /// bain hashmashos starts 3/4 of a <em>Mil</em> before sunset and <em>tzais</em> or nightfall starts at sunset.
  ///
  /// @return the <code>Date</code> of the sun's position 2.1&deg; minutes before sunset. If the calculation can't
  ///         be computed such as in the Arctic Circle where there is at least one day a year where the sun does not
  ///         rise, and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         {@link AstronomicalCalendar} documentation.
  ///
  /// @see #ZENITH_MINUS_2_POINT_1
  /// @see #getBainHasmashosYereim13Point5Minutes()
  DateTime? getBainHasmashosYereim2Point1Degrees() {
    return getSunsetOffsetByDegrees(ZENITH_MINUS_2_POINT_1);
  }

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated at the
  /// sun's position at [ZENITH_3_POINT_7] 3.7° below the western horizon.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 3.7° below sea level.
  /// _see [ZENITH_3_POINT_7]_
  DateTime? getTzaisGeonim3Point7Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_3_POINT_7);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated at the
  /// sun's position at [ZENITH_3_POINT_8] 3.8° below the western horizon.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 3.8° below sea level.
  /// _see [ZENITH_3_POINT_8]_
  DateTime? getTzaisGeonim3Point8Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_3_POINT_8);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated at the
  /// sun's position at [ZENITH_5_POINT_95] 5.95° below the western horizon.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 5.95° below sea level. If the calculation
  ///         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
  ///         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
  ///         null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_5_POINT_95]_
  DateTime? getTzaisGeonim5Point95Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_5_POINT_95);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated as 3/4
  /// of a [Mil](http://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement) based on an 18
  /// minute Mil, or 13.5 minutes. It is the sun's position at [ZENITH_3_POINT_65] 3.65° below the western
  /// horizon. This is a very early _zman_ and should not be relied on without Rabbinical guidance.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 3.65° below sea level. If the calculation
  ///         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
  ///         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
  ///         null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_3_POINT_65]_
  DateTime? getTzaisGeonim3Point65Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_3_POINT_65);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated as 3/4
  /// of a [Mil](http://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement) based on an 18
  /// minute Mil, or 13.5 minutes. It is the sun's position at [ZENITH_3_POINT_676 3.676° below the western
  /// horizon based on the calculations of Stanley Fishkind. This is a very early _zman_ and should not be
  /// relied on without Rabbinical guidance.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 3.676° below sea level. If the
  ///         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
  ///         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
  ///         calculation, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [ZENITH_3_POINT_676]_
  DateTime? getTzaisGeonim3Point676Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_3_POINT_676);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated as 3/4
  /// of a [Mil](http://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement) based on a 24
  /// minute Mil, or 18 minutes. It is the sun's position at [ZENITH_4_POINT_61] 4.61° below the western
  /// horizon. This is a very early _zman_ and should not be relied on without Rabbinical guidance.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 4.61° below sea level. If the calculation
  ///         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
  ///         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
  ///         null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_4_POINT_61]_
  DateTime? getTzaisGeonim4Point61Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_4_POINT_61);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated as 3/4
  /// of a [Mil](http://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement), based on a 22.5
  /// minute Mil, or 16 7/8 minutes. It is the sun's position at [ZENITH_4_POINT_37] 4.37° below the western
  /// horizon. This is a very early _zman_ and should not be relied on without Rabbinical guidance.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 4.37° below sea level. If the calculation
  ///         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
  ///         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
  ///         null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_4_POINT_37]_
  DateTime? getTzaisGeonim4Point37Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_4_POINT_37);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated as 3/4
  /// of a 24 minute _[Mil](http://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement)_,
  /// based on a _Mil_ being 24 minutes, and is calculated as 18 + 2 + 4 for a total of 24 minutes. It is the
  /// sun's position at [ZENITH_5_POINT_88] 5.88° below the western horizon. This is a very early
  /// _zman_ and should not be relied on without Rabbinical guidance.
  ///
  /// todo Additional detailed documentation needed.
  /// return the <code>DateTime</code> representing the time when the sun is 5.88° below sea level. If the calculation
  ///         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
  ///         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
  ///         null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_5_POINT_88]_
  DateTime? getTzaisGeonim5Point88Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_5_POINT_88);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated as 3/4
  /// of a [Mil](http://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement) based on the
  /// sun's position at [ZENITH_4_POINT_8] 4.8° below the western horizon. This is based on Rabbi Leo Levi's
  /// calculations. This is the This is a very early _zman_ and should not be relied on without Rabbinical guidance.
  /// todo Additional documentation needed.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 4.8° below sea level. If the calculation
  ///         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
  ///         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
  ///         null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_4_POINT_8]_
  DateTime? getTzaisGeonim4Point8Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_4_POINT_8);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ as calculated by
  /// [Rabbi Yechiel Michel Tucazinsky](https://en.wikipedia.org/wiki/Yechiel_Michel_Tucazinsky). It is
  /// based on of the position of the sun no later than [getTzaisGeonim6Point45Degrees] 31 minutes after sunset
  /// in Jerusalem the height of the summer solstice and is 28 minutes after <em>shkiah</em> at the equinox. This
  /// computes to 6.45° below the western horizon.
  /// todo Additional documentation details needed.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 6.45° below sea level. If the
  ///         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
  ///         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
  ///         calculation, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [ZENITH_6_POINT_45]_
  DateTime? getTzaisGeonim6Point45Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_6_POINT_45);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated as 30
  /// minutes after sunset during the equinox (on March 16, about 4 days before the astronomical equinox, the day that
  /// a solar hour is 60 minutes) in Yerushalayim. The sun's position at this time computes to
  /// [ZENITH_7_POINT_083] 7.083° (or 7° 5\u2032 below the western horizon. Note that this is a common
  /// and rounded number. Computation shows the accurate number is 7.2°
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 7.083° below sea level. If the
  ///         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
  ///         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
  ///         calculation, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [ZENITH_7_POINT_083]_
  DateTime? getTzaisGeonim7Point083Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_7_POINT_083);

  /// This method returns _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated as 45 minutes
  /// after sunset during the summer solstice in New York, when the _neshef_ (twilight) is the longest. The sun's
  /// position at this time computes to [ZENITH_7_POINT_67] 7.75° below the western horizon. See
  /// [Igros Moshe Even Haezer 4, Ch. 4](http://www.hebrewbooks.org/pdfpager.aspx?req=921&amp;pgnum=149) (regarding
  /// tzais for _krias Shema_). It is also mentioned in Rabbi Heber's [Shaarei Zmanim](http://www.hebrewbooks.org/53000)
  /// on in [chapter 10 (page 87)](http://www.hebrewbooks.org/pdfpager.aspx?req=53055&amp;pgnum=101) and
  /// [chapter 12 (page 108)](http://www.hebrewbooks.org/pdfpager.aspx?req=53055&amp;pgnum=122). Also see the
  /// time of 45 minutes in [Rabbi Simcha Bunim Cohen's](https://en.wikipedia.org/wiki/Simcha_Bunim_Cohen)
  /// [The radiance of Shabbos](https://www.worldcat.org/oclc/179728985) as the earliest zman for New York. This
  /// zman is also listed in the [Divrei Shalom Vol. III, chapter 75](http://www.hebrewbooks.org/pdfpager.aspx?req=1927&amp;pgnum=90),
  /// and [Bais Av"i Vol. III, chapter 117](http://www.hebrewbooks.org/pdfpager.aspx?req=892&amp;pgnum=431).
  /// This zman is also listed in the Divrei Shalom etc. chapter 177. Since this
  /// zman depends on the level of light, Rabbi Yaakov Shakow presented this degree based calculation to Rabbi
  /// Rabbi Shmuel Kamenetsky(https://en.wikipedia.org/wiki/Shmuel_Kamenetsky) who agreed to it.
  /// todo add hyperlinks to source of Divrei Shalom.
  /// return the <code>DateTime</code> representing the time when the sun is 7.67° below sea level. If the
  ///         calculation can't be computed such as northern and southern locations even south of the Arctic Circle and
  ///         north of the Antarctic Circle where the sun may not reach low enough below the horizon for this
  ///         calculation, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [ZENITH_7_POINT_67]_
  DateTime? getTzaisGeonim7Point67Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_7_POINT_67);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated at the
  /// sun's position at [ZENITH_8_POINT_5] 8.5° below the western horizon.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 8.5° below sea level. If the calculation
  ///         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
  ///         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
  ///         null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_8_POINT_5]_
  DateTime? getTzaisGeonim8Point5Degrees() =>
      getSunsetOffsetByDegrees(ZmanimCalendar.ZENITH_8_POINT_5);

  /// This method returns the _tzais_ (nightfall) based on the calculations used in the
  /// [Luach Itim Lebinah](http://www.worldcat.org/oclc/243303103) as the stringent time for tzais.  It is calculated
  /// at the sun's position at [ZENITH_9_POINT_3] 9.3° below the western horizon.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 9.3° below sea level. If the calculation
  ///         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
  ///         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
  ///         null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getTzaisGeonim9Point3Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_9_POINT_3);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _Geonim_ calculated as 60
  /// minutes after sunset during the equinox (on March 16, about 4 days before the astronomical equinox, the day that
  /// a solar hour is 60 minutes) in New York. The sun's position at this time computes to
  /// [ZENITH_9_POINT_75] 9.75° below the western horizon. This is the opinion of
  /// [Rabbi Eliyahu Henkin](https://en.wikipedia.org/wiki/Yosef_Eliyahu_Henkin).  This also follows the opinion of
  /// [Rabbi Shmuel Kamenetsky](https://en.wikipedia.org/wiki/Shmuel_Kamenetsky). Rabbi Yaakov Shakow presented
  /// these degree based times to Rabbi Shmuel Kamenetsky who agreed to them.
  ///
  /// return the <code>DateTime</code> representing the time when the sun is 9.75° below sea level. If the calculation
  ///         can't be computed such as northern and southern locations even south of the Arctic Circle and north of
  ///         the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a
  ///         null will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getTzais60]_
  DateTime? getTzaisGeonim9Point75Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_9_POINT_75);

  /// This method returns the _tzais_ (nightfall) based on the opinion of the _
  /// [Chavas Yair](https://en.wikipedia.org/wiki/Yair_Bacharach)_ and _Divrei Malkiel_ that the time
  /// to walk the distance of a _Mil_ is 15 minutes for a total of 60 minutes for 4 _Mil_ after
  /// [getSeaLevelSunset] sea level sunset.
  ///
  /// return the <code>DateTime</code> representing 60 minutes after sea level sunset. If the calculation can't be
  ///         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise,
  ///         and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getAlos60]_
  DateTime? getTzais60() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunset(), 60 * AstronomicalCalendar.MINUTE_MILLIS);

  /// This method returns _tzais_ usually calculated as 40 minutes (configurable to any offset via
  /// [setAteretTorahSunsetOffset]) after sunset. Please note that _Chacham Yosef Harari-Raful_
  /// of _Yeshivat Ateret Torah_ who uses this time, does so only for calculating various other
  /// _zmanai hayom_ such as _Sof Zman Krias Shema_ and _Plag Hamincha_. His calendars do not
  /// publish a _zman_ for _Tzais_. It should also be noted that _Chacham Harari-Raful_ provided a
  /// 25 minute _zman_ for Israel. This API uses 40 minutes year round in any place on the globe by default.
  /// This offset can be changed by calling [setAteretTorahSunsetOffset].
  ///
  /// return the <code>DateTime</code> representing 40 minutes (configurable via [setAteretTorahSunsetOffset)
  ///         after sea level sunset. If the calculation can't be computed such as in the Arctic Circle where there is
  ///         at least one day a year where the sun does not rise, and one where it does not set, a null will be
  ///         returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getAteretTorahSunsetOffset]_
  /// _see [setAteretTorahSunsetOffset]_
  DateTime? getTzaisAteretTorah() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunset(),
      getAteretTorahSunsetOffset() * AstronomicalCalendar.MINUTE_MILLIS);

  /// Returns the offset in minutes after sunset used to calculate sunset for the Ateret Torah <em>zmanim</em>. The
  /// default value is 40 minutes. This affects most <em>zmanim</em>, since almost all zmanim use subset as part of
  /// their calculation.
  ///
  /// return the number of minutes after sunset for _Tzait_.
  /// _see [setAteretTorahSunsetOffset]_
  double getAteretTorahSunsetOffset() => _ateretTorahSunsetOffset;

  /// Allows setting the offset in minutes after sunset for the Ateret Torah zmanim. The default if unset is 40
  /// minutes. Chacham Yosef Harari-Raful of Yeshivat Ateret Torah uses 40 minutes globally with the exception of
  /// Israel where a 25 minute offset is used. This 40 minute (or any other) offset can be overridden by this method.
  /// This offset impacts all Ateret Torah zmanim.
  ///
  /// param ateretTorahSunsetOffset
  ///            the number of minutes after sunset to use as an offset for the Ateret Torah _tzais_
  /// _see [getAteretTorahSunsetOffset]_
  void setAteretTorahSunsetOffset(double ateretTorahSunsetOffset) =>
      _ateretTorahSunsetOffset = ateretTorahSunsetOffset;

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning) based on the
  /// calculation of Chacham Yosef Harari-Raful of Yeshivat Ateret Torah, that the day starts
  /// [getAlos72Zmanis] 1/10th of the day before sunrise and is usually calculated as ending
  /// [getTzaisAteretTorah] 40 minutes after sunset (configurable to any offset via
  /// [setAteretTorahSunsetOffset]). _shaos zmaniyos_ are calculated based on this day and added
  /// to [getAlos72Zmanis] alos to reach this time. This time is 3
  /// _ [getShaahZmanisAteretTorah] shaos zmaniyos_ (temporal hours) after _[getAlos72Zmanis]_
  /// alos 72 zmaniyos_. <b>Note: </b> Based on this calculation _chatzos_ will not be at midday.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_ based on this calculation. If the
  ///         calculation can't be computed such as in the Arctic Circle where there is at least one day a year where
  ///         the sun does not rise, and one where it does not set, a null will be returned. See detailed explanation
  ///         on top of the [AstronomicalCalendar] documentation.
  /// _see [getAlos72Zmanis]_
  /// _see [getTzaisAteretTorah]_
  /// _see [getAteretTorahSunsetOffset]_
  /// _see [setAteretTorahSunsetOffset]_
  /// _see [getShaahZmanisAteretTorah]_
  DateTime? getSofZmanShmaAteretTorah() =>
      getSofZmanShma(getAlos72Zmanis(), getTzaisAteretTorah());

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) based on the calculation
  /// of Chacham Yosef Harari-Raful of Yeshivat Ateret Torah, that the day starts [getAlos72Zmanis] 1/10th of
  /// the day before sunrise and is usually calculated as ending [getTzaisAteretTorah] 40 minutes after
  /// sunset (configurable to any offset via [setAteretTorahSunsetOffset(double)). _shaos zmaniyos_ are
  /// calculated based on this day and added to [getAlos72Zmanis] alos to reach this time. This time is 4 *
  /// _[getShaahZmanisAteretTorah] shaos zmaniyos_ (temporal hours) after
  /// _[getAlos72Zmanis] alos 72 zmaniyos_.
  /// <b>Note: </b> Based on this calculation _chatzos_ will not be at midday.
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_ based on this calculation. If the
  ///         calculation can't be computed such as in the Arctic Circle where there is at least one day a year where
  ///         the sun does not rise, and one where it does not set, a null will be returned. See detailed explanation
  ///         on top of the [AstronomicalCalendar] documentation.
  /// _see [getAlos72Zmanis]_
  /// _see [getTzaisAteretTorah]_
  /// _see [getShaahZmanisAteretTorah]_
  /// _see [setAteretTorahSunsetOffset_
  DateTime? getSofZmanTfilahAteretTorah() =>
      getSofZmanTfila(getAlos72Zmanis(), getTzaisAteretTorah());

  /// This method returns the time of _mincha gedola_ based on the calculation of _Chacham Yosef
  /// Harari-Raful_ of _Yeshivat Ateret Torah_, that the day starts [getAlos72Zmanis]
  /// 1/10th of the day before sunrise and is usually calculated as ending
  /// [getTzaisAteretTorah] 40 minutes after sunset (configurable to any offset via
  /// [setAteretTorahSunsetOffset(double)). This is the preferred earliest time to pray _mincha_
  /// according to the opinion of the _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_ and others.
  /// For more information on this see the documentation on _[getMinchaGedola] mincha gedola_. This is
  /// calculated as 6.5 [getShaahZmanisAteretTorah]  solar hours after alos. The calculation used is 6.5 *
  /// [getShaahZmanisAteretTorah] after _[getAlos72Zmanis] alos_.
  ///
  /// _see [getAlos72Zmanis]_
  /// _see [getTzaisAteretTorah]_
  /// _see [getShaahZmanisAteretTorah]_
  /// _see [getMinchaGedola]_
  /// _see [getMinchaKetanaAteretTorah]_
  /// _see [ZmanimCalendar#getMinchaGedola]_
  /// _see [getAteretTorahSunsetOffset]_
  /// _see [setAteretTorahSunsetOffset]_
  ///
  /// return the <code>DateTime</code> of the time of mincha gedola. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getMinchaGedolaAteretTorah() =>
      getMinchaGedola(getAlos72Zmanis(), getTzaisAteretTorah());

  /// This method returns the time of _mincha ketana_ based on the calculation of
  /// _Chacham Yosef Harari-Raful_ of _Yeshivat Ateret Torah_, that the day starts
  /// [getAlos72Zmanis] 1/10th of the day before sunrise and is usually calculated as ending
  /// [getTzaisAteretTorah] 40 minutes after sunset (configurable to any offset via
  /// [setAteretTorahSunsetOffset(double)). This is the preferred earliest time to pray _mincha_
  /// according to the opinion of the _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_ and others.
  /// For more information on this see the documentation on _[getMinchaGedola] mincha gedola_. This is
  /// calculated as 9.5 [getShaahZmanisAteretTorah] solar hours after [getAlos72Zmanis] alos. The
  /// calculation used is 9.5 * [getShaahZmanisAteretTorah] after [getAlos72Zmanis] alos.
  ///
  /// _see [getAlos72Zmanis]_
  /// _see [getTzaisAteretTorah]_
  /// _see [getShaahZmanisAteretTorah]_
  /// _see [getAteretTorahSunsetOffset]_
  /// _see [setAteretTorahSunsetOffset]_
  /// _see [getMinchaGedola]_
  /// _see [getMinchaKetana]_
  /// return the <code>DateTime</code> of the time of mincha ketana. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getMinchaKetanaAteretTorah() =>
      getMinchaKetana(getAlos72Zmanis(), getTzaisAteretTorah());

  /// This method returns the time of _plag hamincha_ based on the calculation of Chacham Yosef Harari-Raful of
  /// Yeshivat Ateret Torah, that the day starts [getAlos72Zmanis] 1/10th of the day before sunrise and is
  /// usually calculated as ending [getTzaisAteretTorah] 40 minutes after sunset (configurable to any offset
  /// via [setAteretTorahSunsetOffset(double)). _shaos zmaniyos_ are calculated based on this day and
  /// added to [getAlos72Zmanis] alos to reach this time. This time is 10.75
  /// _[getShaahZmanisAteretTorah] shaos zmaniyos_ (temporal hours) after [getAlos72Zmanis]
  /// dawn.
  ///
  /// return the <code>DateTime</code> of the plag. If the calculation can't be computed such as in the Arctic Circle
  ///         where there is at least one day a year where the sun does not rise, and one where it does not set, a null
  ///         will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getAlos72Zmanis]_
  /// _see [getTzaisAteretTorah]_
  /// _see [getShaahZmanisAteretTorah]_
  /// _see [setAteretTorahSunsetOffset_
  /// _see [getAteretTorahSunsetOffset]_
  DateTime? getPlagHaminchaAteretTorah() =>
      getPlagHamincha(getAlos72Zmanis(), getTzaisAteretTorah());

  /// Method to return _tzais_ (dusk) calculated as 72 minutes zmaniyos, or 1/10th of the day after
  /// {@link #getSeaLevelSunset() sea level sunset}.This is the way that the [Minchas Cohen]
  /// (https://en.wikipedia.org/wiki/Abraham_Cohen_Pimentel) in Ma'amar 2:4 calculates Rebbeinu Tam's
  /// time of <em>tzeis</em>. It should be noted that this calculation results in the shortest time from sunset to
  /// [tzais] being during the winter solstice, the longest at the summer solstice and 72 clock minutes at the
  /// equinox. This does not match reality, since there is no direct relationship between the length of the day and
  /// twilight. The shortest twilight is during the equinox, the longest is during the the summer solstice, and in the
  /// winter with the shortest daylight, the twilight period is longer than during the equinoxes.
  ///
  /// return the [DateTime] representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getAlos72Zmanis]_
  DateTime? getTzais72Zmanis() {
    return getZmanisBasedOffset(1.2);
  }

  /// Method to return _tzais_ (dusk) calculated using 90 minutes zmaniyos after [getSeaLevelSunset] sea level sunset.
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getAlos90Zmanis]_
  DateTime? getTzais90Zmanis() {
    return getZmanisBasedOffset(1.5);
  }

  ///  Method to return <em>tzais</em> (dusk) calculated using 96 minutes <em>zmaniyos</em> or 1/7.5 of the day after
  ///  {@link #getSeaLevelSunset() sea level sunset}.
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getAlos96Zmanis]_
  DateTime? getTzais96Zmanis() {
    return getZmanisBasedOffset(1.6);
  }

  /// Method to return _tzais_ (dusk) calculated as 90 minutes after sea level sunset. This method returns
  /// _tzais_ (nightfall) based on the opinion of the Magen Avraham that the time to walk the distance of a
  /// _Mil_ according to the _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_'s opinion
  /// is 18 minutes for a total of 90 minutes based on the opinion of _Ula_ who calculated _tzais_ as 5
  /// _Mil_ after sea level shkiah (sunset). A similar calculation [getTzais19Point8Degrees]uses solar
  /// position calculations based on this time.
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getTzais19Point8Degrees]_
  /// _see [getAlos90]_
  DateTime? getTzais90() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunset(), 90 * AstronomicalCalendar.MINUTE_MILLIS);

  /// This method returns _tzais_ (nightfall) based on the opinion of the _Magen Avraham_ that the time
  /// to walk the distance of a _Mil_ according to the _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_'s
  /// opinion is 2/5 of an hour (24 minutes) for a total of 120 minutes based on the opinion of
  /// _Ula_ who calculated _tzais_ as 5 _Mil_ after sea level _shkiah_ (sunset). A similar
  /// calculation [getTzais26Degrees] uses temporal calculations based on this time.
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getTzais26Degrees]_
  /// _see [getAlos120]_
  DateTime? getTzais120() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunset(), 120 * AstronomicalCalendar.MINUTE_MILLIS);

  /// Method to return <em>tzais</em> (dusk) calculated using 120 minutes <em>zmaniyos</em> after
  /// {@link #getSeaLevelSunset() sea level sunset}.
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getAlos120Zmanis]_
  DateTime? getTzais120Zmanis() {
    return getZmanisBasedOffset(2.0);
  }

  /// This calculates the time of <em>tzais</em> at the point when the sun is 16.1&deg; below the horizon. This is
  /// the sun's dip below the horizon 72 minutes after sunset according Rabbeinu Tam's calculation of <em>tzais</em>
  /// around the equinox in Jerusalem. This is the opinion of Rabbi Meir Posen in the  [Ohr Meir]
  /// (https://www.worldcat.org/oclc/956316270) and others. See Yisrael Vehazmanim vol I, 34:1:4.
  /// For information on how this is calculated see the comments on [getAlos16Point1Degrees]
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as northern and
  ///         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
  ///         not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getTzais72]_
  /// _see [getAlos16Point1Degrees] for more information on this calculation._
  DateTime? getTzais16Point1Degrees() =>
      getSunsetOffsetByDegrees(ZmanimCalendar.ZENITH_16_POINT_1);

  /// For information on how this is calculated see the comments on [getAlos26Degrees]
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as northern and
  ///         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
  ///         not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getTzais120]_
  /// _see [getAlos26Degrees]_
  DateTime? getTzais26Degrees() => getSunsetOffsetByDegrees(ZENITH_26_DEGREES);

  /// For information on how this is calculated see the comments on [getAlos18Degrees]
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as northern and
  ///         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
  ///         not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getAlos18Degrees]_
  DateTime? getTzais18Degrees() =>
      getSunsetOffsetByDegrees(AstronomicalCalendar.ASTRONOMICAL_ZENITH);

  /// For information on how this is calculated see the comments on [getAlos19Point8Degrees]
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as northern and
  ///         southern locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may
  ///         not reach low enough below the horizon for this calculation, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  /// _see [getTzais90]_
  /// _see [getAlos19Point8Degrees]_
  DateTime? getTzais19Point8Degrees() =>
      getSunsetOffsetByDegrees(ZENITH_19_POINT_8);

  /// A method to return _tzais_ (dusk) calculated as 96 minutes after sea level sunset. For information on how
  /// this is calculated see the comments on [getAlos96].
  ///
  /// return the <code>DateTime</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  /// _see [getAlos96]_
  DateTime? getTzais96() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunset(), 96 * AstronomicalCalendar.MINUTE_MILLIS);

  /// A method that returns the local time for fixed _chatzos_. This time is noon and midnight adjusted from
  /// standard time to account for the local latitude. The 360° of the globe divided by 24 calculates to 15°
  /// per hour with 4 minutes per degree, so at a longitude of 0 , 15, 30 etc... <em>Chatzos</em> is at exactly 12:00
  /// noon. This is the time of <em>chatzos</em> according to the <a href=
  /// "https://en.wikipedia.org/wiki/Aruch_HaShulchan">Aruch Hashulchan</a> in <a href=
  /// "https://hebrewbooks.org/pdfpager.aspx?req=7705&pgnum=426">Orach Chaim 233:14</a> and <a href=
  /// "https://en.wikipedia.org/wiki/Moshe_Feinstein">Rabbi Moshe Feinstein</a> in Igros Moshe <a href=
  /// "https://hebrewbooks.org/pdfpager.aspx?req=916&st=&pgnum=67">Orach Chaim 1:24</a> and <a href=
  /// "https://hebrewbooks.org/pdfpager.aspx?req=14675&pgnum=191">2:20</a>.
  /// Lakewood, N.J., with a longitude of -74.2094, is 0.7906 away from the closest multiple of 15 at -75&deg;. This
  /// is multiplied by 4 to yield 3 minutes and 10 seconds for a <em>chatzos</em> of 11:56:50. This method is not tied
  /// to the theoretical 15&deg; timezones, but will adjust to the actual timezone and <a
  /// href="http://en.wikipedia.org/wiki/Daylight_saving_time">Daylight saving time</a>.
  ///
  /// return the Date representing the local _chatzos_
  /// _see [GeoLocation#getLocalMeanTimeOffset]_
  DateTime? getFixedLocalChatzos() => AstronomicalCalendar.getTimeOffset(
      getDateFromTime(
          12.0 -
              getGeoLocation().getDateTime().timeZoneOffset.inMilliseconds /
                  AstronomicalCalendar.HOUR_MILLIS,
          true),
      -getGeoLocation().getLocalMeanTimeOffset());

  /// A method that returns the latest _zman krias shema_ (time to recite Shema in the morning) calculated as 3
  /// hours before [getFixedLocalChatzos].
  ///
  /// return the <code>DateTime</code> of the latest _zman krias shema_ calculated as 3 hours before
  ///         [getFixedLocalChatzos]..
  /// _see [getFixedLocalChatzos]_
  /// _see [getSofZmanTfilaFixedLocal]_
  @Deprecated(
      "This method of calculating <em>sof zman Shma</em> is considered a mistaken understanding of the proper"
      "calculation of this <em>zman</em> in the opinion of Rav Yitzchal Silber's [Sha'aos Shavos Balalacha]"
      "(https://www.worldcat.org/oclc/811253716). On pages 316-318 he discusses Rav Yisrael Harfenes's calculations "
      "and points to his seeming agreement that using fixed local <em>chatzos</em> as the focal point is problematic. "
      "See Yisrael Vehazmanim [page 57](https://hebrewbooks.org/pdfpager.aspx?req=9765&st=&pgnum=85). While the Yisrael "
      "Vehazmanim mentions this issue in vol. 1, it was not corrected in the calculations in vol. 3 and other parts of the "
      "<em>sefer</em>. A competent rabbinical authority should be consulted before using this <em>zman</em>. Instead, the use of "
      "{@link #getSofZmanShma3HoursBeforeChatzos()} should be used to calculate <em>sof zman Tfila</em> using using 3 fixed clock hours.")
  DateTime? getSofZmanShmaFixedLocal() => AstronomicalCalendar.getTimeOffset(
      getFixedLocalChatzos(), -180 * AstronomicalCalendar.MINUTE_MILLIS);

  /// This method returns the latest _zman tfila_ (time to recite the morning prayers) calculated as 2 hours
  /// before [getFixedLocalChatzos].
  ///
  /// return the <code>DateTime</code> of the latest _zman tfila_.
  /// _see [getFixedLocalChatzos]_
  /// _see [getSofZmanShmaFixedLocal]_
  @Deprecated(
      "This method of calculating <em>sof zman Tfila</em> is considered a mistaken understanding of the proper calculation "
      "of this <em>zman</em> in the opinion of Rav Yitzchal Silber's [Sha'aos Shavos Balalacha](https://www.worldcat.org/oclc/811253716). "
      "On pages 316-318 he discusses Rav Yisrael Harfenes's calculations and points to his seeming agreement that using fixed local "
      "<em>chatzos</em> as the focal point is problematic. See Yisrael Vehazmanim [page 57]"
      "(https://hebrewbooks.org/pdfpager.aspx?req=9765&st=&pgnum=85). While the Yisrael Vehazmanim mentions this issue in vol. "
      "1, it was not corrected in the calculations in vol. 3 and other parts of the <em>sefer</em>. A competent rabbinical authority "
      "should be consulted before using this <em>zman</em>. Instead, the use of {@link#getSofZmanTfila2HoursBeforeChatzos()} "
      "should be used to calculate <em>sof zman Tfila</em> using using 2 fixed clock hours.")
  DateTime? getSofZmanTfilaFixedLocal() => AstronomicalCalendar.getTimeOffset(
      getFixedLocalChatzos(), -120 * AstronomicalCalendar.MINUTE_MILLIS);

  /// Returns the latest time of Kidush Levana according to the <a
  /// [Maharil's](http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin) opinion that it is calculated as
  /// halfway between <em>molad</em> and <em>molad</em>. This adds half the 29 days, 12 hours and 793 chalakim time between
  /// <em>molad</em> and <em>molad</em> (14 days, 18 hours, 22 minutes and 666 milliseconds) to the month's <em>molad</em>.
  /// The <em>sof zman Kiddush Levana</em> will be returned even if it occurs during the day. To limit the time to between
  /// <em>tzais</em> and <em>alos</em>, see {@link #getSofZmanKidushLevanaBetweenMoldos(Date, Date)}.
  ///
  /// [alos]
  ///            the beginning of the Jewish day. If Kidush Levana occurs during the day (starting at alos and ending
  ///            at tzais), the time returned will be alos. If either the alos or tzais parameters are null, no daytime
  ///            adjustment will be made.
  /// [tzais]
  ///            the end of the Jewish day. If Kidush Levana occurs during the day (starting at alos and ending at
  ///            tzais), the time returned will be alos. If either the alos or tzais parameters are null, no daytime
  ///            adjustment will be made.
  /// return the Date representing the moment halfway between molad and molad. If the time occurs between
  ///         _alos_ and _tzais_, _alos_ will be returned
  /// _see [getSofZmanKidushLevanaBetweenMoldos]_
  /// _see [getSofZmanKidushLevana15Days(Date, Date)_
  /// _see [JewishCalendar.getSofZmanKidushLevanaBetweenMoldos]_
  DateTime? getSofZmanKidushLevanaBetweenMoldos(
      [DateTime? alos, DateTime? tzais]) {
    JewishCalendar jewishCalendar = JewishCalendar();
    jewishCalendar.setGregorianDate(
        getCalendar().year, getCalendar().month, getCalendar().day);

    // Do not calculate for impossible dates, but account for extreme cases. In the extreme case of Rapa Iti in French
    // Polynesia on Dec 2027 when kiddush Levana 3 days can be said on _Rosh Chodesh_, the sof zman Kiddush Levana
    // will be on the 12th of the Teves. In the case of Anadyr, Russia on Jan, 2071, sof zman Kiddush Levana between the
    // moldos will occur is on the night of 17th of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
    if (jewishCalendar.getJewishDayOfMonth() < 11 ||
        jewishCalendar.getJewishDayOfMonth() > 16) {
      return null;
    }
    return getMoladBasedTime(
        jewishCalendar.getSofZmanKidushLevanaBetweenMoldos(),
        alos,
        tzais,
        false);
  }

  /// Returns the Date of the molad based time if it occurs on the current date. Since Kiddush Levana can only be said
  /// during the day, there are parameters to limit it to between _alos_ and _tzais_. If the time occurs
  /// between alos and tzais, tzais will be returned
  ///
  /// param moladBasedTime
  ///            the molad based time such as molad, tchilas and sof zman Kiddush Levana
  /// [alos]
  ///            optional start of day to limit molad times to the end of the night before or beginning of the next night. Ignored if
  ///            either this or tzais are null.
  /// [tzais]
  ///            optional end of day to limit molad times to the end of the night before or beginning of the next night. Ignored if
  ///            either this or alos are null
  /// [techila]
  ///            is it the start of <em>Kiddush Levana</em> time or the end? If it is start roll it to the next <em>tzais</em>, and
  ///             and if it is the end, return the end of the previous night (<em>alos</em> passed in). Ignored if either
  ///             <em>alos</em> or <em>tzais</em> are null.
  ///  return the <em>molad</em> based time. If the <em>zman</em> does not occur during the current date, null will be returned.
  DateTime? getMoladBasedTime(
      DateTime moladBasedTime, DateTime? alos, DateTime? tzais, bool techila) {
    DateTime? lastMidnight = getMidnightLastNight();
    DateTime? midnightTonigh = getMidnightTonight();
    if (!(moladBasedTime.isBefore(lastMidnight!) ||
        moladBasedTime.isAfter(midnightTonigh!))) {
      if (alos != null || tzais != null) {
        if (techila &&
            !(moladBasedTime.isBefore(tzais!) ||
                moladBasedTime.isAfter(alos!))) {
          return tzais;
        } else {
          return alos;
        }
      }
      return moladBasedTime;
    }
    return null;
  }

  /// Returns the latest time of _Kiddush Levana_ calculated as 15 days after the _molad_. This is the
  /// opinion brought down in the Shulchan Aruch (Orach Chaim 426). It should be noted that some opinions hold that the
  /// [Rema](http://en.wikipedia.org/wiki/Moses_Isserles) who brings down the opinion of the <a
  /// [Maharil's](http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin) of calculating
  /// {@link #getSofZmanKidushLevanaBetweenMoldos(Date, Date) half way between <em>molad</em> and <em>molad</em>} is of
  /// the opinion that the Mechaber agrees to his opinion. Also see the Aruch Hashulchan. For additional details on the subject,
  /// see Rabbi Dovid Heber's very detailed write-up in <em>Siman Daled</em> (chapter 4) of <a href=
  /// "http://www.hebrewbooks.org/53000">Shaarei Zmanim</a>. If the time of <em>sof zman Kiddush Levana</em> occurs during
  /// the day (between the <em>alos</em> and <em>tzais</em> passed in as parameters), it returns the <em>alos</em> passed in. If a
  /// null <em>alos</em> or <em>tzais</em> are passed to this method, the non-daytime adjusted time will be returned.
  ///
  /// [alos]
  ///            the beginning of the Jewish day. If Kidush Levana occurs during the day (starting at alos and ending
  ///            at tzais), the time returned will be alos. If either the alos or tzais parameters are null, no daytime
  ///            adjustment will be made.
  /// [tzais]
  ///            the end of the Jewish day. If Kidush Levana occurs during the day (starting at alos and ending at
  ///            tzais), the time returned will be alos. If either the alos or tzais parameters are null, no daytime
  ///            adjustment will be made.
  ///
  /// return the Date representing the moment 15 days after the molad. If the time occurs between _alos_ and
  ///         _tzais_, _alos_ will be returned
  ///
  /// _see [getSofZmanKidushLevanaBetweenMoldos]_
  /// _see [JewishCalendar.getSofZmanKidushLevana15Days]_
  DateTime? getSofZmanKidushLevana15Days([DateTime? alos, DateTime? tzais]) {
    JewishCalendar jewishCalendar = JewishCalendar();
    jewishCalendar.setGregorianDate(
        getCalendar().year, getCalendar().month, getCalendar().day);

    // Do not calculate for impossible dates, but account for extreme cases. In the extreme case of Rapa Iti in
    // French Polynesia on Dec 2027 when kiddush Levana 3 days can be said on _Rosh Chodesh_, the sof zman Kiddush
    // Levana will be on the 12th of the Teves. in the case of Anadyr, Russia on Jan, 2071, sof zman kiddush levana will
    // occur after midnight on the 17th of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
    if (jewishCalendar.getJewishDayOfMonth() < 11 ||
        jewishCalendar.getJewishDayOfMonth() > 17) {
      return null;
    }
    return getMoladBasedTime(
        jewishCalendar.getSofZmanKidushLevana15Days(), alos, tzais, false);
  }

  /// Returns the earliest time of _Kiddush Levana_ according to _Rabbeinu Yonah_'s opinion that it can
  /// be said 3 days after the molad. If the time of _tchilas zman Kiddush Levana_ occurs during the day (between
  /// _alos_ and _tzais_ passed to this method) it will return the following _tzais_. If null is passed
  /// for either alos or tzais, the actual _tchilas zman Kiddush Levana_ will be returned, regardless of if it is
  /// during the day or not.
  /// This method is available in the current release of the API but may change or be
  /// removed in the future since it depends on the still changing {link JewishCalendar and related classes.
  ///
  /// [alos]
  ///            the beginning of the Jewish day. If Kidush Levana occurs during the day (starting at alos and ending
  ///            at tzais), the time returned will be tzais. If either the alos or tzais parameters are null, no daytime
  ///            adjustment will be made.
  /// [tzais]
  ///            the end of the Jewish day. If Kidush Levana occurs during the day (starting at alos and ending at
  ///            tzais), the time returned will be tzais. If either the alos or tzais parameters are null, no daytime
  ///            adjustment will be made.
  ///
  /// return the Date representing the moment 3 days after the molad. If the time occurs between _alos_ and
  ///         _tzais_, _tzais_ will be returned
  /// _see [getTchilasZmanKidushLevana3Days]_
  /// _see [getTchilasZmanKidushLevana7Days]_
  /// _see [JewishCalendar.getTchilasZmanKidushLevana3Days]_
  DateTime? getTchilasZmanKidushLevana3Days([DateTime? alos, DateTime? tzais]) {
    JewishCalendar jewishCalendar = JewishCalendar();
    jewishCalendar.setGregorianDate(
        getCalendar().year, getCalendar().month, getCalendar().day);

    // Do not calculate for impossible dates, but account for extreme cases. Tchilas zman kiddush Levana 3 days for
    // the extreme case of Rapa Iti in French Polynesia on Dec 2027 when kiddush Levana 3 days can be said on the evening
    // of the 30th, the second night of Rosh Chodesh. The 3rd day after the _molad_ will be on the 4th of the month.
    // In the case of Anadyr, Russia on Jan, 2071, when sof zman kiddush levana is on the 17th of the month, the 3rd day
    // from the molad will be on the 5th day of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
    if (jewishCalendar.getJewishDayOfMonth() > 5 &&
        jewishCalendar.getJewishDayOfMonth() < 30) {
      return null;
    }

    DateTime? zman = getMoladBasedTime(
        jewishCalendar.getTchilasZmanKidushLevana3Days(), alos, tzais, true);

    //Get the following month's zman kiddush Levana for the extreme case of Rapa Iti in French Polynesia on Dec 2027 when
    // kiddush Levana can be said on Rosh Chodesh (the evening of the 30th). See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (page 32)
    if (zman == null && jewishCalendar.getJewishDayOfMonth() == 30) {
      jewishCalendar.forward(Calendar.MONTH, 1);
      zman = getMoladBasedTime(
          jewishCalendar.getTchilasZmanKidushLevana3Days(), null, null, true);
    }

    return zman;
  }

  ///Returns the earliest time of <em>Kiddush Levana</em> according to <a href=
  /// "https://en.wikipedia.org/wiki/Yonah_Gerondi">Rabbeinu Yonah</a>'s opinion that it can be said 3 days after the <em>molad</em>.
  /// If the time of <em>tchilas zman Kiddush Levana</em> occurs during the day (between <em>alos</em> and <em>tzais</em> passed to
  /// this method) it will return the following <em>tzais</em>. If null is passed for either <em>alos</em> or <em>tzais</em>, the actual
  /// <em>tchilas zman Kiddush Levana</em> will be returned, regardless of if it is during the day or not.
  ///
  /// return the Date representing the moment of the molad. If the molad does not occur on this day, a null will be returned.
  ///
  /// _see [getTchilasZmanKidushLevana3Days]_
  /// _see [getTchilasZmanKidushLevana7Days]_
  /// _see [JewishCalendar#getMoladAsDate]_
  DateTime? getZmanMolad() {
    JewishCalendar jewishCalendar = JewishCalendar();
    jewishCalendar.setGregorianDate(
        getCalendar().year, getCalendar().month, getCalendar().day);

    // Optimize to not calculate for impossible dates, but account for extreme cases. The molad in the extreme case of Rapa
    // Iti in French Polynesia on Dec 2027 occurs on the night of the 27th of Kislev. In the case of Anadyr, Russia on
    // Jan 2071, the molad will be on the 2nd day of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
    if (jewishCalendar.getJewishDayOfMonth() > 2 &&
        jewishCalendar.getJewishDayOfMonth() < 27) {
      return null;
    }
    DateTime? molad = getMoladBasedTime(
        jewishCalendar.getMoladAsDateTime(), null, null, true);

    // deal with molad that happens on the end of the previous month
    if (molad == null && jewishCalendar.getJewishDayOfMonth() > 26) {
      jewishCalendar.forward(Calendar.MONTH, 1);
      molad = getMoladBasedTime(
          jewishCalendar.getMoladAsDateTime(), null, null, true);
    }
    return molad;
  }

  /// Used by Molad based zmanim to determine if zmanim occur during the current day.
  /// _see [getMoladBasedTime]_
  /// return previous midnight
  DateTime? getMidnightLastNight() {
    DateTime midnight = DateTime(getCalendar().year, getCalendar().month,
        getCalendar().day, 0, 0, 0, 0, 0);
    return midnight;
  }

  /// Used by Molad based zmanim to determine if zmanim occur during the current day.
  /// _see [getMoladBasedTime]_
  /// return following midnight
  DateTime? getMidnightTonight() {
    DateTime midnight = DateTime(getCalendar().year, getCalendar().month,
        getCalendar().day, 0, 0, 0, 0, 0);
    midnight.add(const Duration(days: 1));
    return midnight;
  }

  /// Returns the earliest time of _Kiddush Levana_ according to the opinions that it should not be said until 7
  /// days after the <em>molad</em>. The time will be returned even if it occurs during the day when <em>Kiddush Levana</em>
  /// can't be recited. Use {@link #getTchilasZmanKidushLevana7Days(Date, Date)} if you want to limit the time to night hours.
  /// [alos]
  ///            the beginning of the Jewish day. If Kidush Levana occurs during the day (starting at alos and ending
  ///            at tzais), the time returned will be tzais. If either the alos or tzais parameters are null, no daytime
  ///            adjustment will be made.
  /// [tzais]
  ///            the end of the Jewish day. If Kidush Levana occurs during the day (starting at alos and ending at
  ///            tzais), the time returned will be tzais. If either the alos or tzais parameters are null, no daytime
  ///            adjustment will be made.
  ///
  /// return the Date representing the moment 7 days after the molad. If the time occurs between _alos_ and
  ///         _tzais_, _tzais_ will be returned
  /// _see [getTchilasZmanKidushLevana3Days]
  /// _see [getTchilasZmanKidushLevana7Days]_
  /// _see [JewishCalendar#getTchilasZmanKidushLevana7Days]_
  DateTime? getTchilasZmanKidushLevana7Days([DateTime? alos, DateTime? tzais]) {
    JewishCalendar jewishCalendar = JewishCalendar();
    jewishCalendar.setGregorianDate(
        getCalendar().year, getCalendar().month, getCalendar().day);

    // Optimize to not calculate for impossible dates, but account for extreme cases. Tchilas zman kiddush Levana 7 days for
    // the extreme case of Rapa Iti in French Polynesia on Jan 2028 (when kiddush Levana 3 days can be said on the evening
    // of the 30th, the second night of Rosh Chodesh), the 7th day after the molad will be on the 4th of the month.
    // In the case of Anadyr, Russia on Jan, 2071, when sof zman kiddush levana is on the 17th of the month, the 7th day
    // from the molad will be on the 9th day of Shevat. See Rabbi Dovid Heber's Shaarei Zmanim chapter 4 (pages 28 and 32).
    if (jewishCalendar.getJewishDayOfMonth() < 4 ||
        jewishCalendar.getJewishDayOfMonth() > 9) {
      return null;
    }

    return getMoladBasedTime(
        jewishCalendar.getTchilasZmanKidushLevana7Days(), alos, tzais, true);
  }

  /// This method returns the latest time one is allowed eating chametz on Erev Pesach according to the opinion of the
  /// _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_. This time is identical to the
  /// [getSofZmanTfilaGRA] Sof zman tfilah GRA and is provided as a convenience method for those who are unaware how
  /// this zman is calculated. This time is 4 hours into the day based on the opinion of the
  /// _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_ that the day is calculated from sunrise to sunset. This
  /// returns the time 4 * [getShaahZmanisGra] after [getSeaLevelSunrise] sea level sunrise.
  ///
  /// _see [ZmanimCalendar.getShaahZmanisGra]_
  /// _see [ZmanimCalendar.getSofZmanTfilaGRA]_
  /// return the <code>DateTime</code> one is allowed eating chametz on Erev Pesach. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getSofZmanAchilasChametzGRA() => getSofZmanTfilaGRA();

  /// This method returns the latest time one is allowed eating chametz on Erev Pesach according to the opinion of the
  /// <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on <em>alos</em>
  /// being {@link #getAlos72() 72} minutes before {@link #getSunrise() sunrise}. This time is identical to the
  /// {@link #getSofZmanTfilaMGA72Minutes() Sof zman tfilah MGA 72 minutes}. This time is 4 <em>{@link #getShaahZmanisMGA()
  /// shaos zmaniyos}</em> (temporal hours) after {@link #getAlos72() dawn} based on the opinion of the <em>MGA</em> that
  /// the day is calculated from a {@link #getAlos72() dawn} of 72 minutes before sunrise to {@link #getTzais72() nightfall}
  /// of 72 minutes after sunset. This returns the time of 4 * {@link #getShaahZmanisMGA()} after {@link #getAlos72() dawn}.
  /// return the <code>DateTime</code> of the latest time of eating chametz. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set), a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanisMGA]_
  /// _see [getAlos72]_
  /// _see [getSofZmanTfilaMGA72Minutes]_
  DateTime? getSofZmanAchilasChametzMGA72Minutes() =>
      getSofZmanTfilaMGA72Minutes();

  /// This method returns the latest time one is allowed eating chametz on Erev Pesach according to the opinion of the
  ///  <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on <em>alos</em>
  /// being {@link #getAlos16Point1Degrees() 16.1&deg;} before {@link #getSunrise() sunrise}. This time is 4 <em>{@link
  /// #getShaahZmanis16Point1Degrees() shaos zmaniyos}</em> (solar hours) after {@link #getAlos16Point1Degrees() dawn}
  /// based on the opinion of the <em>MGA</em> that the day is calculated from dawn to nightfall with both being 16.1&deg;
  /// below sunrise or sunset. This returns the time of 4 {@link #getShaahZmanis16Point1Degrees()} after
  /// {@link #getAlos16Point1Degrees() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest time of eating chametz. If the calculation can't be computed such as
  ///         northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle where
  ///         the sun may not reach low enough below the horizon for this calculation, a null will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getShaahZmanis16Point1Degrees]_
  /// _see [getAlos16Point1Degrees]_
  /// _see [getSofZmanTfilaMGA16Point1Degrees]_
  DateTime? getSofZmanAchilasChametzMGA16Point1Degrees() =>
      getSofZmanTfilaMGA16Point1Degrees();

  /// This method returns the latest time for burning chametz on Erev Pesach according to the opinion of the
  /// <em><a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a></em> This time is 5 hours into the day based on the
  /// opinion of the <em><a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a></em> that the day is calculated from
  /// sunrise to sunset. This returns the time 5 * {@link #getShaahZmanisGra()} after {@link #getSeaLevelSunrise() sea
  /// level sunrise}.
  ///
  /// _see [ZmanimCalendar.getShaahZmanisGra]
  /// return the <code>DateTime</code> of the latest time for burning chametz on Erev Pesach. If the calculation can't be
  ///         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise,
  ///         and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getSofZmanBiurChametzGRA() => AstronomicalCalendar.getTimeOffset(
      getElevationAdjustedSunrise(), getShaahZmanisGra() * 5);

  /// This method returns the latest time for burning chametz on Erev Pesach according to the opinion of the
  /// <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on <em>alos</em>
  /// being {@link #getAlos72() 72} minutes before {@link #getSunrise() sunrise}. This time is 5 <em>{@link
  /// #getShaahZmanisMGA() shaos zmaniyos}</em> (temporal hours) after {@link #getAlos72() dawn} based on the opinion of
  /// the <em>MGA</em> that the day is calculated from a {@link #getAlos72() dawn} of 72 minutes before sunrise to {@link
  /// #getTzais72() nightfall} of 72 minutes after sunset. This returns the time of 5 * {@link #getShaahZmanisMGA()} after
  /// {@link #getAlos72() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest time for burning chametz on Erev Pesach. If the calculation can't be
  ///         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise,
  ///         and one where it does not set), a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  /// _see [getShaahZmanisMGA]_
  /// _see [getAlos72]_
  DateTime? getSofZmanBiurChametzMGA72Minutes() =>
      AstronomicalCalendar.getTimeOffset(getAlos72(), getShaahZmanisMGA() * 5);

  /// This method returns the latest time for burning _chametz_ on _Erev Pesach_ according to the opinion
  /// of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> based on <em>alos</em>
  /// being {@link #getAlos16Point1Degrees() 16.1&deg;} before {@link #getSunrise() sunrise}. This time is 5
  /// <em>{@link #getShaahZmanis16Point1Degrees() shaos zmaniyos}</em> (solar hours) after {@link #getAlos16Point1Degrees()
  /// dawn} based on the opinion of the <em>MGA</em> that the day is calculated from dawn to nightfall with both being 16.1&deg;
  /// below sunrise or sunset. This returns the time of 5 {@link #getShaahZmanis16Point1Degrees()} after
  /// {@link #getAlos16Point1Degrees() dawn}.
  ///
  /// return the <code>DateTime</code> of the latest time for burning chametz on Erev Pesach. If the calculation can't be
  ///         computed such as northern and southern locations even south of the Arctic Circle and north of the
  ///         Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a null
  ///         will be returned. See detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getShaahZmanis16Point1Degrees]_
  /// _see [getAlos16Point1Degrees]_
  DateTime? getSofZmanBiurChametzMGA16Point1Degrees() =>
      AstronomicalCalendar.getTimeOffset(
          getAlos16Point1Degrees(), getShaahZmanis16Point1Degrees() * 5);

  /// A method that returns "solar" midnight, or the time when the sun is at its [nadir](http://en.wikipedia.org/wiki/Nadir).
  /// <b>Note:</b> this method is experimental and might be removed.
  ///
  /// return the <code>DateTime</code> of Solar Midnight (chatzos layla). If the calculation can't be computed such as in
  ///         the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getSolarMidnight() {
    ZmanimCalendar clonedCal = ZmanimCalendar.intGeolocation(geoLocation);
    clonedCal.setCalendar(DateTime.parse(getCalendar().toIso8601String()));
    clonedCal.setCalendar(clonedCal.getCalendar().add(const Duration(days: 1)));
    DateTime? sunset = getSeaLevelSunset();
    DateTime? sunrise = clonedCal.getSeaLevelSunrise();
    return AstronomicalCalendar.getTimeOffset(
        sunset, getTemporalHour(sunset, sunrise) * 6);
  }

  /// A method that returns the _[Baal Hatanya](https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi)_'s
  /// _netz amiti_ (sunrise) without [AstronomicalCalculator.getElevationAdjustment]
  /// elevation adjustment. This forms the base for the _Baal Hatanya_'s dawn based calculations that are
  /// calculated as a dip below the horizon before sunrise.
  ///
  /// According to the _Baal Hatanya_, _netz amiti_, or true (halachic) sunrise, is when the top of the sun's
  /// disk is visible at an elevation similar to the mountains of Eretz Yisrael. The time is calculated as the point at which
  /// the center of the sun's disk is 1.583° below the horizon. This degree based calculation can be found in Rabbi Shalom
  /// DovBer Levine's commentary on The [Baal Hatanya's Seder Hachnasas Shabbos](http://www.chabadlibrary.org/books/pdf/Seder-Hachnosas-Shabbos.pdf).
  /// From an elevation of 546 meters, the top of [Har Hacarmel](https://en.wikipedia.org/wiki/Mount_Carmel),
  /// the sun disappears when it is 1° 35' or 1.583° below the sea level horizon. This in turn is based on the Gemara
  /// [Shabbos 35a](http://www.hebrewbooks.org/shas.aspx?mesechta=2&amp;daf=35). There are other opinions brought down by
  /// Rabbi Levine, including Rabbi Yosef Yitzchok
  /// Feigelstock who calculates it as the degrees below the horizon 4 minutes after sunset in Yerushalaym (on the equinox). That
  /// is brought down as 1.583°. This is identical to the 1° 35' zman and is probably a typo and should be 1.683°.
  /// These calculations are used by most [Chabad](https://en.wikipedia.org/wiki/Chabad) calendars that use the
  /// _Baal Hatanya_'s Zmanim.
  /// See [About Our Zmanim Calculations  Chabad.org](https://www.chabad.org/library/article_cdo/aid/3209349/jewish/About-Our-Zmanim-Calculations.htm).
  ///
  /// Note: _netz amiti_ is used only for calculating certain zmanim, and is intentionally unpublished. For practical purposes,
  /// daytime mitzvos like shofar and lulav should not be done until after the published time for netz-sunrise.
  ///
  /// return the <code>DateTime</code> representing the exact sea-level _netz amiti_ (sunrise) time. If the calculation can't be
  ///         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a null will be returned. See detailed explanation on top of the page.
  ///
  /// _see [getSunrise]_
  /// _see [getSeaLevelSunrise]_
  /// _see [getSunsetBaalHatanya]_
  /// _see [ZENITH_1_POINT_583]_
  DateTime? getSunriseBaalHatanya() =>
      getSunriseOffsetByDegrees(ZENITH_1_POINT_583);

  /// A method that returns the _[Baal Hatanya](https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi)_'s
  /// _shkiah amiti_ (sunset) without {link AstronomicalCalculator#getElevationAdjustment(double)
  /// elevation adjustment. This forms the base for the _Baal Hatanya_'s  dusk based calculations that are calculated
  /// as a dip below the horizon after sunset.
  ///
  /// According to the _Baal Hatanya_, _shkiah amiti_, true (halachic) sunset, is when the top of the
  /// sun's disk disappears from view at an elevation similar to the mountains of Eretz Yisrael.
  /// This time is calculated as the point at which the center of the sun's disk is 1.583 degrees below the horizon.
  ///
  /// Note: _shkiah amiti_ is used only for calculating certain zmanim, and is intentionally unpublished. For practical
  /// purposes, all daytime mitzvos should be completed before the published time for shkiah-sunset.
  ///
  /// For further explanation of the calculations used for the _Baal Hatanya_'s Zmanim in this library, see
  /// [About Our Zmanim Calculations  Chabad.org](https://www.chabad.org/library/article_cdo/aid/3209349/jewish/About-Our-Zmanim-Calculations.htm).
  ///
  /// return the <code>DateTime</code> representing the exact sea-level _shkiah amiti_ (sunset) time. If the calculation
  ///         can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not
  ///         rise, and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  ///
  /// _see [getSunset]_
  /// _see [getSeaLevelSunset]_
  /// _see [getSunriseBaalHatanya]_
  /// _see [#ZENITH_1_POINT_583]_
  DateTime? getSunsetBaalHatanya() =>
      getSunsetOffsetByDegrees(ZENITH_1_POINT_583);

  /// A method that returns the _[Baal Hatanya](https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi)_'s
  /// a _shaah zmanis_ ([getTemporalHour] temporal hour). This forms the base for the
  /// _Baal Hatanya_'s  day  based calculations that are calculated
  /// as a 1.583° dip below the horizon after sunset.
  ///
  /// According to the _Baal Hatanya_, _shkiah amiti_, true (halachic) sunset, is when the top of the
  /// sun's disk disappears from view at an elevation similar to the mountains of Eretz Yisrael.
  /// This time is calculated as the point at which the center of the sun's disk is 1.583 degrees below the horizon.
  ///
  ///
  ///
  /// A method that returns a _shaah zmanis_ ( [getTemporalHour] temporal hour) calculated
  /// based on the _[Baal Hatanya](https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi)_'s _netz
  /// amiti_ and _shkiah amiti_ using a dip of 1.583° below the sea level horizon. This calculation divides
  /// the day based on the opinion of the _Baal Hatanya_ that the day runs from [getSunriseBaalHatanya]
  /// netz amiti to [getSunsetBaalHatanya] shkiah amiti. The calculations are based on a day from {link
  /// #getSunriseBaalHatanya] sea level netz amiti to [getSunsetBaalHatanya] sea level shkiah amiti. The day
  /// is split into 12 equal parts with each one being a _shaah zmanis_. This method is similar to {link
  /// #getTemporalHour, but all calculations are based on a sea level sunrise and sunset.
  /// todo Copy sunrise and sunset comments here as applicable.
  /// return the <code>double</code> millisecond length of a _shaah zmanis_ calculated from
  ///         [getSunriseBaalHatanya] _netz amiti_ (sunrise) to [getSunsetBaalHatanya] _shkiah amiti_
  ///         ("real" sunset). If the calculation can't be computed such as in the Arctic Circle where there is at least one day a
  ///         year where the sun does not rise, and one where it does not set, double.minPositive will be returned. See
  ///         detailed explanation on top of the [AstronomicalCalendar] documentation.
  ///
  /// _see [getTemporalHour]_
  /// _see [getSunriseBaalHatanya]_
  /// _see [getSunsetBaalHatanya]_
  /// _see [ZENITH_1_POINT_583]_
  ///
  double getShaahZmanisBaalHatanya() =>
      getTemporalHour(getSunriseBaalHatanya(), getSunsetBaalHatanya());

  /// Returns the <em><a href="https://en.wikipedia.org/wiki/Shneur_Zalman_of_Liadi">Baal Hatanya</a></em>'s <em>alos</em>
  /// (dawn) calculated as the time when the sun is 16.9&deg; below the eastern {@link #GEOMETRIC_ZENITH geometric horizon}
  /// before {@link #getSunrise sunrise}. For more information the source of 16.9&deg; see {@link #ZENITH_16_POINT_9}.
  ///
  /// _see [ZENITH_16_POINT_9]_
  /// return The <code>DateTime</code> of dawn. If the calculation can't be computed such as northern and southern
  ///         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
  ///         low enough below the horizon for this calculation, a null will be returned. See detailed explanation on
  ///         top of the [AstronomicalCalendar] documentation.
  DateTime? getAlosBaalHatanya() =>
      getSunriseOffsetByDegrees(ZENITH_16_POINT_9);

  /// This method returns the latest _zman krias shema_ (time to recite Shema in the morning). This time is 3
  /// _[getShaahZmanisBaalHatanya] shaos zmaniyos_ (solar hours) after [getSunriseBaalHatanya]
  /// _netz amiti_ (sunrise) based on the opinion of the _Baal Hatanya_ that the day is calculated from
  /// sunrise to sunset. This returns the time 3 * [getShaahZmanisBaalHatanya] after [getSunriseBaalHatanya]
  /// _netz amiti_ (sunrise).
  ///
  /// _see [ZmanimCalendar#getSofZmanShma]_
  /// _see [getShaahZmanisBaalHatanya]_
  /// return the <code>DateTime</code> of the latest zman shema according to the Baal Hatanya. If the calculation
  ///         can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does
  ///         not rise, and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getSofZmanShmaBaalHatanya() =>
      getSofZmanShma(getSunriseBaalHatanya(), getSunsetBaalHatanya());

  /// This method returns the latest _zman tfilah_ (time to recite the morning prayers). This time is 4
  /// hours into the day based on the opinion of the _Baal Hatanya_ that the day is
  /// calculated from sunrise to sunset. This returns the time 4 * [getShaahZmanisBaalHatanya] after
  /// [getSunriseBaalHatanya] _netz amiti_ (sunrise).
  ///
  /// _see [ZmanimCalendar.getSofZmanTfila]_
  /// _see [getShaahZmanisBaalHatanya]_
  /// return the <code>DateTime</code> of the latest zman tfilah. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getSofZmanTfilaBaalHatanya() =>
      getSofZmanTfila(getSunriseBaalHatanya(), getSunsetBaalHatanya());

  /// This method returns the latest time one is allowed eating chametz on Erev Pesach according to the opinion of the
  /// _Baal Hatanya_. This time is identical to the [getSofZmanTfilaBaalHatanya] Sof zman
  /// tfilah Baal Hatanya. This time is 4 hours into the day based on the opinion of the _Baal
  /// Hatanya_ that the day is calculated from sunrise to sunset. This returns the time 4 *
  /// [getShaahZmanisBaalHatanya] after [getSunriseBaalHatanya] _netz amiti_ (sunrise).
  ///
  /// see [getShaahZmanisBaalHatanya]
  /// see [getSofZmanTfilaBaalHatanya]
  /// return the <code>DateTime</code> one is allowed eating chametz on Erev Pesach. If the calculation can't be computed
  ///         such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one
  ///         where it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getSofZmanAchilasChametzBaalHatanya() =>
      getSofZmanTfilaBaalHatanya();

  /// This method returns the latest time for burning chametz on Erev Pesach according to the opinion of the
  /// _Baal Hatanya_. This time is 5 hours into the day based on the opinion of the
  /// _Baal Hatanya_ that the day is calculated from sunrise to sunset. This returns the
  /// time 5 * [getShaahZmanisBaalHatanya] after [getSunriseBaalHatanya] _netz amiti_ (sunrise).
  ///
  /// _see [getShaahZmanisBaalHatanya]_
  /// return the <code>DateTime</code> of the latest time for burning chametz on Erev Pesach. If the calculation can't be
  ///         computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise,
  ///         and one where it does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getSofZmanBiurChametzBaalHatanya() =>
      AstronomicalCalendar.getTimeOffset(
          getSunriseBaalHatanya(), getShaahZmanisBaalHatanya() * 5);

  /// This method returns the time of _mincha gedola_. _Mincha gedola_ is the earliest time one can pray
  /// mincha. The _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_ is of the opinion that it is
  /// better to delay _mincha_ until _[getMinchaKetanaBaalHatanya] mincha ketana_ while the
  /// _[Ra"sh](https://en.wikipedia.org/wiki/Asher_ben_Jehiel)_,
  /// _[Tur](https://en.wikipedia.org/wiki/Jacob_ben_Asher)_, _[GRA](https://en.wikipedia.org/wiki/Vilna_Gaon)_
  /// and others are of the opinion that _mincha_ can be prayed
  /// _lechatchila_ starting at _mincha gedola_. This is calculated as 6.5 [getShaahZmanisBaalHatanya]
  /// sea level solar hours after [getSunriseBaalHatanya] _netz amiti_ (sunrise). This calculation is based
  /// on the opinion of the _Baal Hatanya_ that the day is calculated from sunrise to sunset. This returns the time 6.5 *
  /// [getShaahZmanisBaalHatanya] after [getSunriseBaalHatanya] _netz amiti_ ("real" sunrise).
  ///
  /// _see [getMinchaGedola]_
  /// _see [getShaahZmanisBaalHatanya]_
  /// _see [getMinchaKetanaBaalHatanya]_
  /// return the <code>DateTime</code> of the time of mincha gedola. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getMinchaGedolaBaalHatanya() =>
      getMinchaGedola(getSunriseBaalHatanya(), getSunsetBaalHatanya());

  /// This is a convenience method that returns the later of [getMinchaGedolaBaalHatanya] and
  /// [getMinchaGedola30Minutes]. In the winter when 1/2 of a _[getShaahZmanisBaalHatanya] shaah zmanis_ is
  /// less than 30 minutes [getMinchaGedola30Minutes] will be returned, otherwise [getMinchaGedolaBaalHatanya]
  /// will be returned.
  ///
  /// return the <code>DateTime</code> of the later of [getMinchaGedolaBaalHatanya] and [getMinchaGedola30Minutes].
  ///         If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year
  ///         where the sun does not rise, and one where it does not set, a null will be returned. See detailed
  ///         explanation on top of the [AstronomicalCalendar] documentation.
  DateTime? getMinchaGedolaBaalHatanyaGreaterThan30() {
    if (getMinchaGedola30Minutes() == null ||
        getMinchaGedolaBaalHatanya() == null) {
      return null;
    } else {
      return getMinchaGedola30Minutes()!
                  .compareTo(getMinchaGedolaBaalHatanya()!) >
              0
          ? getMinchaGedola30Minutes()
          : getMinchaGedolaBaalHatanya();
    }
  }

  /// This method returns the time of _mincha ketana_. This is the preferred earliest time to pray
  /// _mincha_ in the opinion of the _[Rambam](https://en.wikipedia.org/wiki/Maimonides)_ and others.
  /// For more information on this see the documentation on _[getMinchaGedolaBaalHatanya] mincha gedola_.
  /// This is calculated as 9.5 [getShaahZmanisBaalHatanya]  sea level solar hours after [getSunriseBaalHatanya]
  /// _netz amiti_ (sunrise). This calculation is calculated based on the opinion of the _Baal Hatanya_ that the
  /// day is calculated from sunrise to sunset. This returns the time 9.5 * [getShaahZmanisBaalHatanya] after
  /// [getSunriseBaalHatanya] _netz amiti_ (sunrise).
  ///
  /// _see [getMinchaKetana]_
  /// _see [getShaahZmanisBaalHatanya]_
  /// _see [getMinchaGedolaBaalHatanya]_
  /// return the <code>DateTime</code> of the time of mincha ketana. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the [AstronomicalCalendar]
  ///         documentation.
  DateTime? getMinchaKetanaBaalHatanya() =>
      getMinchaKetana(getSunriseBaalHatanya(), getSunsetBaalHatanya());

  /// This method returns the time of _plag hamincha_. This is calculated as 10.75 hours after sunrise. This
  /// calculation is based on the opinion of the _Baal Hatanya_ that the day is calculated
  /// from sunrise to sunset. This returns the time 10.75 * [getShaahZmanisBaalHatanya] after
  /// [getSunriseBaalHatanya] _netz amiti_ (sunrise).
  ///
  /// _see [getPlagHamincha]_
  /// return the <code>DateTime</code> of the time of _plag hamincha_. If the calculation can't be computed such as
  ///         in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it
  ///         does not set, a null will be returned. See detailed explanation on top of the
  ///         [AstronomicalCalendar] documentation.
  DateTime? getPlagHaminchaBaalHatanya() =>
      getPlagHamincha(getSunriseBaalHatanya(), getSunsetBaalHatanya());

  /// A method that returns _tzais_ (nightfall) when the sun is 6° below the western geometric horizon
  /// (90°) after [getSunset sunset. For information on the source of this calculation see
  /// [ZENITH_6_DEGREES].
  ///
  /// return The <code>DateTime</code> of nightfall. If the calculation can't be computed such as northern and southern
  ///         locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach
  ///         low enough below the horizon for this calculation, a null will be returned. See detailed explanation on
  ///         top of the [AstronomicalCalendar] documentation.
  /// _see [ZENITH_6_DEGREES]_
  DateTime? getTzaisBaalHatanya() => getSunsetOffsetByDegrees(ZENITH_6_DEGREES);

  /// Calculate zmanim based on <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein</a> as
  /// calculated in <a href="https://en.wikipedia.org/wiki/Mesivtha_Tifereth_Jerusalem">MTJ</a>, <a href=
  /// "https://en.wikipedia.org/wiki/Mesivtha_Tifereth_Jerusalem">Yeshiva of Staten Island</a>, and Camp Yeshiva
  /// of Staten Island. The day is split in two, from <em>alos</em> / sunrise to fixed local chatzos, and the second
  /// half of the day, from fixed local chatzos to sunset / <em>tzais</em>. Morning based times are calculated based
  /// on the first  6 hours, and afternoon times based on the second half of the day.
  ///
  /// @param startOfHalfDay
  ///            The start of the half day. This would be <em>alos</em> or sunrise for morning based times and fixed
  ///            local <em>chatzos</em> for the second half of the day.
  /// @param endOfHalfDay
  ///            The end of the half day. This would be fixed local <em>chatzos</em> for morning based times and sunset
  ///            or <em>tzais</em> for afternoon based times.
  /// @param hours
  ///            the number of hours to offset the beginning of the first or second half of the day
  ///
  /// @return the <code>Date</code> of the later of {@link #getMinchaGedolaBaalHatanya()} and {@link #getMinchaGedola30Minutes()}.
  ///         If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year
  ///         where the sun does not rise, and one where it does not set, a null will be returned. See detailed
  ///         explanation on top of the {@link AstronomicalCalendar} documentation.
  ///
  /// @see ComplexZmanimCalendar#getFixedLocalChatzos()
  DateTime? getFixedLocalChatzosBasedZmanim(
      DateTime? startOfHalfDay, DateTime? endOfHalfDay, double hours) {
    if (startOfHalfDay == null || endOfHalfDay == null) {
      return null;
    }
    double shaahZmanis = (endOfHalfDay.millisecondsSinceEpoch -
            startOfHalfDay.millisecondsSinceEpoch) /
        6;
    return DateTime.fromMillisecondsSinceEpoch(
        (startOfHalfDay.millisecondsSinceEpoch + shaahZmanis * hours).toInt());
  }

  /// This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
  /// claculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
  /// opinion of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> that the
  /// day is calculated from dawn to nightfall, but calculated using the first half of the day only. The half a day starts
  /// at <em>alos</em> defined as {@link #getAlos18Degrees() 18&deg;} and ends at {@link #getFixedLocalChatzos() fixed local
  /// chatzos}. <em>Sof Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after <em>alos</em> or half of this half-day.
  ///
  /// @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the {@link AstronomicalCalendar} documentation.
  /// @see #getAlos18Degrees()
  /// @see #getFixedLocalChatzos()
  /// @see #getFixedLocalChatzosBasedZmanim(Date, Date, double)
  DateTime? getSofZmanShmaMGA18DegreesToFixedLocalChatzos() {
    return getFixedLocalChatzosBasedZmanim(
        getAlos18Degrees(), getFixedLocalChatzos(), 3);
  }

  /// This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
  /// claculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
  /// opinion of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> that the
  /// day is calculated from dawn to nightfall, but calculated using the first half of the day only. The half a day starts
  /// at <em>alos</em> defined as {@link #getAlos16Point1Degrees() 16.1&deg;} and ends at {@link #getFixedLocalChatzos() fixed local
  /// chatzos}. <em>Sof Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after this <em>alos</em> or half of this half-day.
  ///
  /// @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the {@link AstronomicalCalendar} documentation.
  /// @see #getAlos16Point1Degrees()
  /// @see #getFixedLocalChatzos()
  /// @see #getFixedLocalChatzosBasedZmanim(Date, Date, double)

  DateTime? getSofZmanShmaMGA16Point1DegreesToFixedLocalChatzos() {
    return getFixedLocalChatzosBasedZmanim(
        getAlos16Point1Degrees(), getFixedLocalChatzos(), 3);
  }

  /// This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
  /// claculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
  /// opinion of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> that the
  /// day is calculated from dawn to nightfall, but calculated using the first half of the day only. The half a day starts
  /// at <em>alos</em> defined as {@link #getAlos90() 90 minutes before sunrise} and ends at {@link #getFixedLocalChatzos()
  /// fixed local chatzos}. <em>Sof Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after this <em>alos</em> or
  /// half of this half-day.
  ///
  /// @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the {@link AstronomicalCalendar} documentation.
  /// @see #getAlos90()
  /// @see #getFixedLocalChatzos()
  /// @see #getFixedLocalChatzosBasedZmanim(Date, Date, double)
  DateTime? getSofZmanShmaMGA90MinutesToFixedLocalChatzos() {
    return getFixedLocalChatzosBasedZmanim(
        getAlos90(), getFixedLocalChatzos(), 3);
  }

  /// This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
  /// claculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
  /// opinion of the <em><a href="https://en.wikipedia.org/wiki/Avraham_Gombinern">Magen Avraham (MGA)</a></em> that the
  /// day is calculated from dawn to nightfall, but calculated using the first half of the day only. The half a day starts
  /// at <em>alos</em> defined as {@link #getAlos72() 72 minutes before sunrise} and ends at {@link #getFixedLocalChatzos()
  /// fixed local chatzos}. <em>Sof Zman Shema</em> is 3 <em>shaos zmaniyos</em> (solar hours) after this <em>alos</em> or
  /// half of this half-day.
  ///
  /// @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the {@link AstronomicalCalendar} documentation.
  /// @see #getAlos72()
  /// @see #getFixedLocalChatzos()
  /// @see #getFixedLocalChatzosBasedZmanim(Date, Date, double)
  DateTime? getSofZmanShmaMGA72MinutesToFixedLocalChatzos() {
    return getFixedLocalChatzosBasedZmanim(
        getAlos72(), getFixedLocalChatzos(), 3);
  }

  /// This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
  /// claculation of <em>sof zman krias shema</em> (latest time to recite <em>Shema</em> in the morning) according to the
  /// opinion of the <em><a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a></em> that the day is calculated from
  /// sunrise to sunset, but calculated using the first half of the day only. The half a day starts at {@link #getSunrise()
  /// sunrise} and ends at {@link #getFixedLocalChatzos() fixed local chatzos}. <em>Sof Zman Shema</em> is 3 <em>shaos
  /// zmaniyos</em> (solar hours) after sunrise or half of this half-day.
  ///
  /// @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the {@link AstronomicalCalendar} documentation.
  /// @see #getSunrise()
  /// @see #getFixedLocalChatzos()
  /// @see #getFixedLocalChatzosBasedZmanim(Date, Date, double)
  DateTime? getSofZmanShmaGRASunriseToFixedLocalChatzos() {
    return getFixedLocalChatzosBasedZmanim(
        getSunrise(), getFixedLocalChatzos(), 3);
  }

  /// This method returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion of the
  /// claculation of <em>sof zman tfila</em> (<em>zman tfilah</em> (the latest time to recite the morning prayers))
  /// according to the opinion of the <em><a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a></em> that the day is
  /// calculated from sunrise to sunset, but calculated using the first half of the day only. The half a day starts at
  /// {@link #getSunrise() sunrise} and ends at {@link #getFixedLocalChatzos() fixed local chatzos}. <em>Sof zman tefila</em>
  /// is 4 <em>shaos zmaniyos</em> (solar hours) after sunrise or 2/3 of this half-day.
  ///
  /// @return the <code>Date</code> of the latest <em>zman krias shema</em>. If the calculation can't be computed such
  ///         as northern and southern locations even south of the Arctic Circle and north of the Antarctic Circle
  ///         where the sun may not reach low enough below the horizon for this calculation, a null will be returned.
  ///         See detailed explanation on top of the {@link AstronomicalCalendar} documentation.
  /// @see #getSunrise()
  /// @see #getFixedLocalChatzos()
  /// @see #getFixedLocalChatzosBasedZmanim(Date, Date, double)
  DateTime? getSofZmanTfilaGRASunriseToFixedLocalChatzos() {
    return getFixedLocalChatzosBasedZmanim(
        getSunrise(), getFixedLocalChatzos(), 4);
  }

  /// This method returns returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion
  /// of the calculation of <em>mincha gedola</em>,the earliest time one can pray <em>mincha</em> <em><a href=
  /// "https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a></em>that is 30 minutes after{@link #getFixedLocalChatzos() fixed
  /// local chatzos}.
  ///
  /// @return the <code>Date</code> of the time of mincha gedola. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the {@link AstronomicalCalendar}
  ///         documentation.
  ///
  /// @see #getMinchaGedola()
  /// @see #getFixedLocalChatzos()
  /// @see #getMinchaKetanaGRAFixedLocalChatzosToSunset
  DateTime? getMinchaGedolaGRAFixedLocalChatzos30Minutes() {
    return AstronomicalCalendar.getTimeOffset(
        getFixedLocalChatzos(), AstronomicalCalendar.MINUTE_MILLIS * 30);
  }

  /// This method returns returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion
  /// of the calculation of <em>mincha ketana</em> (the preferred time to recite the mincha prayers according to the
  /// opinion of the <em><a href="https://en.wikipedia.org/wiki/Maimonides">Rambam</a></em> and others) calculated according
  /// to the <em><a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a></em>that is 3.5 <em>shaos zmaniyos</em> (solar
  /// hours) after {@link #getFixedLocalChatzos() fixed local chatzos}.
  ///
  /// @return the <code>Date</code> of the time of mincha gedola. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the {@link AstronomicalCalendar}
  ///         documentation.
  ///
  /// @see #getMinchaGedola()
  /// @see #getFixedLocalChatzos()
  /// @see #getMinchaGedolaGRAFixedLocalChatzos30Minutes
  DateTime? getMinchaKetanaGRAFixedLocalChatzosToSunset() {
    return getFixedLocalChatzosBasedZmanim(
        getFixedLocalChatzos(), getSunset(), 3.5);
  }

  /// This method returns returns <a href="https://en.wikipedia.org/wiki/Moshe_Feinstein">Rav Moshe Feinstein's</a> opinion
  /// of the calculation of This method returns <em>plag hamincha</em> calculated according to the
  /// <em><a href="https://en.wikipedia.org/wiki/Vilna_Gaon">GRA</a></em>that is 4.75 <em>shaos zmaniyos</em> (solar
  /// hours) after {@link #getFixedLocalChatzos() fixed local chatzos}.
  ///
  /// @return the <code>Date</code> of the time of mincha gedola. If the calculation can't be computed such as in the
  ///         Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does
  ///         not set, a null will be returned. See detailed explanation on top of the {@link AstronomicalCalendar}
  ///         documentation.
  ///
  /// @see #getPlagHamincha()
  /// @see #getFixedLocalChatzos()
  /// @see #getMinchaKetanaGRAFixedLocalChatzosToSunset
  /// @see #getMinchaGedolaGRAFixedLocalChatzos30Minutes
  DateTime? getPlagHaminchaGRAFixedLocalChatzosToSunset() {
    return getFixedLocalChatzosBasedZmanim(
        getFixedLocalChatzos(), getSunset(), 4.75);
  }

  /// Method to return <em>tzais</em> (dusk) calculated as 50 minutes after sea level sunset. This method returns
  /// <em>tzais</em> (nightfall) based on the opinion of Rabbi Moshe Feinstein for the New York area. This time should
  /// not be used for latitudes different than the NY area.
  ///
  /// @return the <code>Date</code> representing the time. If the calculation can't be computed such as in the Arctic
  ///         Circle where there is at least one day a year where the sun does not rise, and one where it does not set,
  ///         a null will be returned. See detailed explanation on top of the {@link AstronomicalCalendar}
  ///         documentation.
  DateTime? getTzais50() {
    return AstronomicalCalendar.getTimeOffset(
        getElevationAdjustedSunset(), 50 * AstronomicalCalendar.MINUTE_MILLIS);
  }

  DateTime? getMidday() => getSolarMidnight()!.add(const Duration(hours: -12));

  /// A method that return Shabbos entry date of this week
  DateTime getShabbosStartTime() {
    ComplexZmanimCalendar complexZmanimCalendar = clone();
    int weekday = (complexZmanimCalendar.getCalendar().weekday + 7) % 7 + 1;
    int delta = 6 - weekday % 7;
    complexZmanimCalendar.setCalendar(
        complexZmanimCalendar.getCalendar().add(Duration(days: delta)));
    DateTime? date = complexZmanimCalendar.getSunset();
    return date!.add(Duration(minutes: _shiftTime()));
  }

  /// A method that return time of Shabbos exit in this week
  DateTime getShabbosExitTime() {
    ComplexZmanimCalendar complexZmanimCalendar = clone();
    int weekday = (complexZmanimCalendar.getCalendar().weekday + 7) % 7 + 1;
    int delta = 7 - weekday % 7;
    complexZmanimCalendar.setCalendar(
        complexZmanimCalendar.getCalendar().add(Duration(days: delta)));
    DateTime? date = complexZmanimCalendar
        .getBainHasmashosRT13Point5MinutesBefore7Point083Degrees();
    return date!.add(const Duration(minutes: 22));
  }

  /// A method that return entry time of the closer Yom Tov
  DateTime getYomTovStartTime() {
    ComplexZmanimCalendar complexZmanimCalendar = clone();
    JewishCalendar jewishCalendar = JewishCalendar.fromDateTime(getCalendar());
    while (!jewishCalendar.isErevYomTov()) {
      jewishCalendar.forward();
    }
    complexZmanimCalendar.setCalendar(jewishCalendar.getGregorianCalendar());
    DateTime? date = complexZmanimCalendar.getSunset();
    return date!.add(Duration(minutes: _shiftTime()));
  }

  /// A method that return exit time of the closer Yom Tov
  DateTime getYomTovExitTime() {
    ComplexZmanimCalendar complexZmanimCalendar = clone();
    JewishCalendar jewishCalendar = JewishCalendar.fromDateTime(getCalendar());
    while (!jewishCalendar.isYomTov()) {
      jewishCalendar.forward();
    }
    complexZmanimCalendar.setCalendar(jewishCalendar.getGregorianCalendar());
    DateTime? date = complexZmanimCalendar
        .getBainHasmashosRT13Point5MinutesBefore7Point083Degrees();
    return date!.add(const Duration(minutes: 22));
  }

  DateTime? getTaanisStartTime({bool inIsrael = false, isAshkenaz = false}) {
    JewishCalendar jewishCalendar = JewishCalendar.fromDateTime(
        DateTime.parse(getCalendar().toIso8601String()));
    DateTime calendar = DateTime.parse(getCalendar().toIso8601String());
    jewishCalendar.inIsrael = inIsrael;
    while (!jewishCalendar.isTaanis()) {
      calendar = calendar.add(const Duration(days: 1));
      jewishCalendar.setDate(calendar);
    }
    ComplexZmanimCalendar complexZmanimCalendar = clone();
    complexZmanimCalendar.setCalendar(calendar);
    // for Tisha Beav
    if (jewishCalendar.getYomTovIndex() == JewishCalendar.TISHA_BEAV) {
      return complexZmanimCalendar.getSunset();
      // for all other Taanis
    } else {
      return isAshkenaz
          ? complexZmanimCalendar.getAlosHashachar()
          : complexZmanimCalendar.getAlos72();
    }
  }

  DateTime? getTaanisExitTime({bool inIsrael = false, isAshkenaz = false}) {
    JewishCalendar jewishCalendar = JewishCalendar.fromDateTime(
        DateTime.parse(getCalendar().toIso8601String()));
    DateTime calendar = DateTime.parse(getCalendar().toIso8601String());
    jewishCalendar.inIsrael = inIsrael;
    while (!jewishCalendar.isTaanis()) {
      calendar = calendar.add(const Duration(days: 1));
      jewishCalendar.setDate(calendar);
    }
    ComplexZmanimCalendar complexZmanimCalendar = clone();
    complexZmanimCalendar.setCalendar(calendar);
    return complexZmanimCalendar
        .getBainHasmashosRT13Point5MinutesBefore7Point083Degrees()!
        .add(Duration(minutes: isAshkenaz ? 20 : 0));
  }

  /// A method that return Tallis And Tefillin Zman
  DateTime? getTallisAndTefillin({bool inIsrael = false, isAshkenaz = false}) {
    if (isAshkenaz) {
      return getMisheyakir10Point2Degrees();
    } else {
      return getAlosHashachar() == null
          ? null
          : getAlosHashachar()!.add(const Duration(minutes: 6));
    }
  }

  /// The Sabbath enters a fixed number of minutes before the astronomical sunset.
  /// Number of minutes that varies according to local custom. for example custom of Jerusalem and Petah Tikva is 40 minutes before sunset,
  /// Safed, Tiberias, Haifa and Samaria 30 minutes before sunset, Tel Aviv and Gush Dan custom 21 minutes before sunset,
  /// The custom of Beer Sheva and Ashdod is 22 minutes Raanana custom is 20 minutes before sunset.
  /// In other places whose practice is unknown to us, the Sabbath entry time is 30 minutes before the astronomical sunset time.
  /// this method that return this number of minutes before the astronomical sunset base on on the location
  int _shiftTime() {
    int shiftTime = -25;
    shiftTimeByLocationName.forEach((key, value) {
      if (getGeoLocation().getLocationName().toLowerCase().contains(key)) {
        shiftTime = value;
      }
    });
    if ((getGeoLocation().getLongitude() > 34.461262940608364 ||
            getGeoLocation().getLatitude() < 35.2408) &&
        (getGeoLocation().getLongitude() > 31.83538 ||
            getGeoLocation().getLongitude() < 32.263563983577995)) {
      shiftTime = -21;
    }
    return shiftTime;
  }

  ComplexZmanimCalendar clone() {
    return ComplexZmanimCalendar.intGeoLocation(geoLocation.clone());
  }
}
