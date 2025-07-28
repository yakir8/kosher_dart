## 2.0.18
- Updated intl dependency constraint from ^0.19.0 to ^0.20.1
- Updated the Dart SDK constraint to >=3.0.0 <4.0.0 to ensure compatibility with newer SDK
- Implemented missing JewishCalendar.initDate constructor body

## 2.0.17
- Update 'intl' to v0.19
- Update Dart SDK
- Fix bug on ZmanimCalendar.getCandleLighting() for erev yom tov sheni out side israel

## 2.0.16
- Bug fix

## 2.0.15
- Fixed syntax mistakes

## 2.0.14
- Replace method 'equals' to operator == on classes AstronomicalCalendar, GeoLocation, JewishCalendar, JewishDate
- Add hashCode() to classes GeoLocation, JewishCalendar, JewishDate
- Added Supporting on Dart 3
- Update 'intl' to v0.18.1

## 2.0.13
- Fix JewishDate.clone()
- Added tefila rules
- 
## 2.0.12
- Fix bug on HebrewDateFormatter.format()

## 2.0.11
- Bug fixed on formatWeeklyParsha();
- Remove  get & set for inIsrael variable.

## 2.0.10
- Fix bug on getShabbosStartTime()
- General syntax fix

## 2.0.9
- Added method isShoavavimWeek()
- Improved implementation of format() method with 'pattern' parameter for building date format
- Changes have been made base on KosherJava (last commit 28.12.2021)
  - Fix AstronomicalCalendar getSunriseSolarDipFromOffset() and getSunsetSolarDipFromOffset (they are still inefficient) to properly allow calculations before and after sun rise/set.
  - Simplify and reduce code duplication in ZmanimCalendar generic zmanim calculations.
  - Added Daf.setMasechtaTransliterated(List<String> masechtosBavliTransliterated) and Daf.setYerushlmiMasechtaTransliterated(List<String> masechtosYerushalmiTransliterated).
  - Added JewishCalendar.isTaanisBechoros().
  - Add seasonal davening based zmanim including Vesein Tal Umatar/ Vesein Berachah / Mashiv Haruach.
  - Fix an issue with sof zman kiddush levana being off by an hour when the molad is on one side of the DST change, and the sof zman on the other.

## 2.0.8
- Fix method getCandleLighting() for Chanukah

## 2.0.7
- Fix method getCandleLighting()

## 2.0.6
- Added method getTallisAndTefillin()
- Added Usage section on README.md file.

## 2.0.5
- Fixed _getSunHourAngleAtSunrise() always return null for same location.

## 2.0.4
- Fixed zmanim calculation on some time zone.

## 2.0.3
- Add support for null safety.
- Fixed Taanis times.

## 2.0.2

- Now only need to import kosher_dart.dart file
- Added method getEventsList() to hebrew_date_formatter.dart file. Return list of events for the day.
- Added method getEvent() to hebrew_date_formatter.dart file. Return event for the day.
- Added method for exit and entry Shabbos time of this week.
- Added method for exit and entry of the closer Yom Tov.
- Added method for exit and entry of the closer Taanis.
- Bugs fixed Based on [KosherJava Zmanim API commit f7e24ce](https://github.com/KosherJava/zmanim/tree/f7e24ce604e3fcd1c10824fc0d18bb7c8a0b7e99)
- Bug & Documentation fix

## 2.0.1

- Bug & Documentation fix.

## 2.0.0

- Added `formatWeeklyParsha` function for getting String of Parsha in given week.
- Bug fix Based on [KosherJava Zmanim API commit cb5977c](https://github.com/KosherJava/zmanim/tree/cb5977c9efa5396660f130eac0150d41b47613d2)

## 1.0.0

Completion of translation from [KosherJava Zmanim API](https://github.com/KosherJava/zmanim) 