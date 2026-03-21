/// Tests for [YomiCalculator.getDafYomiBavli] (Babylonian Talmud Daf Yomi).
///
/// The Bavli (Babylonian Talmud) Daf Yomi cycle is a daily schedule covering
/// all 2,711 pages of the Babylonian Talmud. Each test provides a known Jewish
/// date and verifies that the returned [Daf] (tractate number + page number)
/// matches the historically correct value.
///
/// The [HebrewDateFormatter] is used only for debug printing.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  HebrewDateFormatter hdf = HebrewDateFormatter();
  hdf.hebrewFormat = true;

  // 12 Kislev 5685 (start of the very first Daf Yomi cycle) → tractate 5 (Berakhot), daf 2.
  test('testCorrectDaf1', () async {
    JewishCalendar jewishCalendar =
        JewishCalendar.initDate(5685, JewishDate.KISLEV, 12);
    Daf daf = YomiCalculator.getDafYomiBavli(jewishCalendar);
    expect(daf.getMasechtaNumber(), 5);
    expect(daf.getDaf(), 2);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiBavli()));
  });

  // 26 Elul 5736 → tractate 4 (Shabbat), daf 14.
  test('testCorrectDaf2', () async {
    JewishCalendar jewishCalendar =
        JewishCalendar.initDate(5736, JewishDate.ELUL, 26);
    Daf daf = YomiCalculator.getDafYomiBavli(jewishCalendar);
    expect(daf.getMasechtaNumber(), 4);
    expect(daf.getDaf(), 14);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiBavli()));
  });

  // 10 Elul 5777 → tractate 23 (Bava Batra), daf 47.
  test('testCorrectDaf3', () async {
    JewishCalendar jewishCalendar =
        JewishCalendar.initDate(5777, JewishDate.ELUL, 10);
    Daf daf = YomiCalculator.getDafYomiBavli(jewishCalendar);
    expect(daf.getMasechtaNumber(), 23);
    expect(daf.getDaf(), 47);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiBavli()));
  });
}
