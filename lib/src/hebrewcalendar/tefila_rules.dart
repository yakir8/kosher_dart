/*
 * Zmanim Dart API
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License,
    or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not,
    write to
 * the Free Software Foundation,
    Inc.,
    51 Franklin Street,
    Fifth Floor,
    Boston,
    MA  02110-1301  USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 * 
 * Port Author: Daniel Smith (https://github.com/DanielSmith1239)
 */



import 'package:kosher_dart/kosher_dart.dart';

/// Tefila Rules is a utility class that covers the various <em>halachos</em> and <em>minhagim</em> regarding
/// changes to daily <em>tefila</em> / prayers,
/// based on the Jewish calendar. This is mostly useful for use in
/// developing <em>siddur</em> type applications,
/// but it is also valuable for <em>shul</em> calendars that set
/// <em>tefila</em> times based on if <a href="https://en.wikipedia.org/wiki/Tachanun"><em>tachanun</em></a> is
/// recited that day. There are many settings in this class to cover the vast majority of <em>minhagim</em>,
/// but
/// there are likely some not covered here. The source for many of the <em>chasidishe minhagim</em> can be found
/// in the <a href="https://www.nli.org.il/he/books/NNL_ALEPH001141272/NLI">Minhag Yisrael Torah</a> on Orach
/// Chaim 131.
/// Dates used in specific communities such as specific <em>yahrzeits</em> or a holidays like Purim Mezhbizh
/// (Medzhybizh) celebrated on 11 {@link JewishDate#TEVES <em>Teves</em>} or <a href=
/// "https://en.wikipedia.org/wiki/Second_Purim#Purim_Saragossa_(18_Shevat)">Purim Saragossa</a> celebrated on
/// the (17th or) 18th of {@link JewishDate#SHEVAT <em>Shevat</em>} are not (and likely will not be) supported by
/// this class.
/// <p>Sample code:
/// <pre style="background: #FEF0C9; display: inline-block;">
/// TefilaRules tr = new TefilaRules();
/// JewishCalendar jewishCalendar = new JewishCalendar();
/// HebrewDateFormatter hdf = new HebrewDateFormatter();
/// jewishCalendar.setJewishDate(5783,
/// JewishDate.TISHREI,
/// 1); // Rosh Hashana
/// System.out.println(hdf.format(jewishCalendar) + ": " + tr.isTachanunRecitedShacharis(jd));
/// jewishCalendar.setJewishDate(5783,
/// JewishDate.ADAR,
/// 17);
/// System.out.println(hdf.format(jewishCalendar) + ": " + tr.isTachanunRecitedShacharis(jewishCalendar));
/// tr.setTachanunRecitedWeekOfPurim(false);
/// System.out.println(hdf.format(jewishCalendar) + ": " + tr.isTachanunRecitedShacharis(jewishCalendar));</pre>
/// 
/// @author &copy; Y. Paritcher 2019 - 2021
/// @author &copy; Eliyahu Hershfeld 2019 - 2022
/// 
/// @todo The following items may be added at a future date.
/// <ol>
/// <li><em>Lamnatzaiach</em></li>
/// <li><em>Mizmor Lesoda</em></li>
/// <li><em>Behab</em></li>
/// <li><em>Selichos</em></li>
/// <li>...</li>
/// </ol>
class TefilaRules {
  final JewishCalendar jewishCalendar;

  /**
	 * The default value is <code>true</code>.
	 * @see #isTachanunRecitedEndOfTishrei()
	 * @see #setTachanunRecitedEndOfTishrei(boolean)
	 */
	final bool tachanunRecitedEndOfTishrei;
	
	/**
	 * The default value is <code>false</code>.
	 * @see #isTachanunRecitedWeekAfterShavuos()
	 * @see #setTachanunRecitedWeekAfterShavuos(boolean)
	 */
	final bool tachanunRecitedWeekAfterShavuos;
	
	/**
	 * The default value is <code>true</code>.
	 * @see #isTachanunRecited13SivanOutOfIsrael()
	 * @see #setTachanunRecited13SivanOutOfIsrael(boolean)
	 */
	final bool tachanunRecited13SivanOutOfIsrael;
	
	/**
	 * The default value is <code>false</code>.
	 * @see #isTachanunRecitedPesachSheni()
	 * @see #setTachanunRecitedPesachSheni(boolean)
	 */
	final bool tachanunRecitedPesachSheni;
	
	/**
	 * The default value is <code>true</code>.
	 * @see #isTachanunRecited15IyarOutOfIsrael()
	 * @see #setTachanunRecited15IyarOutOfIsrael(boolean)
	 */
	final bool tachanunRecited15IyarOutOfIsrael;
	
	/**
	 * The default value is <code>false</code>.
	 * @see #isTachanunRecitedMinchaErevLagBaomer()
	 * @see #setTachanunRecitedMinchaErevLagBaomer(boolean)
	 */
	final bool tachanunRecitedMinchaErevLagBaomer;
	
	/**
	 * The default value is <code>true</code>.
	 * @see #isTachanunRecitedShivasYemeiHamiluim()
	 * @see #setTachanunRecitedShivasYemeiHamiluim(boolean)
	 */
	final bool tachanunRecitedShivasYemeiHamiluim;
	
	/**
	 * The default value is <code>true</code>.
	 * @see #isTachanunRecitedWeekOfHod()
	 * @see #setTachanunRecitedWeekOfHod(boolean)
	 */
	final bool tachanunRecitedWeekOfHod;
	
	/**
	 * The default value is <code>true</code>.
	 * @see #isTachanunRecitedWeekOfPurim()
	 * @see #setTachanunRecitedWeekOfPurim(boolean)
	 */
	final bool tachanunRecitedWeekOfPurim;
	
	/**
	 * The default value is <code>true</code>.
	 * @see #isTachanunRecitedFridays()
	 * @see #setTachanunRecitedFridays(boolean)
	 */
	final bool tachanunRecitedFridays;
	
	/**
	 * The default value is <code>true</code>.
	 * @see #isTachanunRecitedSundays()
	 * @see #setTachanunRecitedSundays(boolean)
	 */
	final bool tachanunRecitedSundays;
	
	/**
	 * The default value is <code>true</code>.
	 * @see #isTachanunRecitedMinchaAllYear()
	 * @see #setTachanunRecitedMinchaAllYear(boolean)
	 */
	final bool tachanunRecitedMinchaAllYear;

  TefilaRules(this.jewishCalendar, {
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

  /**
	 * Returns if <em>tachanun</em> is recited during <em>shacharis</em> on the day in question. See the many
	 * <em>minhag</em> based settings that are available in this class.
	 * 
	 * @param jewishCalendar the Jewish calendar day.
	 * @return if <em>tachanun</em> is recited during <em>shacharis</em>.
	 * @see #isTachanunRecitedMincha(JewishCalendar)
	 */
	bool get isTachanunRecitedShacharis {
		final holidayIndex = jewishCalendar.getYomTovIndex();
		final day = jewishCalendar.getJewishDayOfMonth();
		final month = jewishCalendar.getJewishMonth();

		final ret = (jewishCalendar.getDayOfWeek() == JewishDate.saturday
				|| (!tachanunRecitedSundays && jewishCalendar.getDayOfWeek() == JewishDate.sunday)
				|| (!tachanunRecitedFridays && jewishCalendar.getDayOfWeek() == JewishDate.friday)
				|| month == JewishDate.NISSAN
				|| (month == JewishDate.TISHREI && ((!tachanunRecitedEndOfTishrei && day > 8)
				|| (tachanunRecitedEndOfTishrei && (day > 8 && day < 22))))
				|| (month == JewishDate.SIVAN && (tachanunRecitedWeekAfterShavuos && day < 7
						|| !tachanunRecitedWeekAfterShavuos && day < (!jewishCalendar.inIsrael
								&& !tachanunRecited13SivanOutOfIsrael ? 14: 13)))
				|| (jewishCalendar.isYomTov() && (! jewishCalendar.isTaanis()
						|| (!tachanunRecitedPesachSheni && holidayIndex == JewishCalendar.PESACH_SHENI))) // Erev YT is included in isYomTov()
				|| (!jewishCalendar.inIsrael && !tachanunRecitedPesachSheni && !tachanunRecited15IyarOutOfIsrael
						&& jewishCalendar.getJewishMonth() == JewishDate.IYAR && day == 15)
				|| holidayIndex == JewishCalendar.TISHA_BEAV || jewishCalendar.isIsruChag()
				|| jewishCalendar.isRoshChodesh()
				|| (!tachanunRecitedShivasYemeiHamiluim &&
						((!jewishCalendar.isJewishLeapYear() && month == JewishDate.ADAR)
								|| (jewishCalendar.isJewishLeapYear() && month == JewishDate.ADAR_II)) && day > 22)
				|| (!tachanunRecitedWeekOfPurim &&
						((!jewishCalendar.isJewishLeapYear() && month == JewishDate.ADAR)
								|| (jewishCalendar.isJewishLeapYear() && month == JewishDate.ADAR_II)) && day > 10 && day < 18)
				|| (jewishCalendar.isUseModernHolidays()
						&& (holidayIndex == JewishCalendar.YOM_HAATZMAUT || holidayIndex == JewishCalendar.YOM_YERUSHALAYIM))
				|| (!tachanunRecitedWeekOfHod && month == JewishDate.IYAR && day > 13 && day < 21));

		return ret;
	}
}