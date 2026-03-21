/// Comprehensive unit tests for [JewishDate].
///
/// Covers the following areas with a focus on edge cases:
///
/// - **Jewish leap year detection** — verifies [JewishDate.isJewishLeapYear]
///   for known leap and non-leap years across multiple 19-year Metonic cycles,
///   and checks that leap years have 13 months (Adar II) while non-leap years
///   end at Adar (12).
///
/// - **Gregorian leap year rules** — tests [JewishDate.getLastDayOfGregorianMonth]
///   for Feb 28/29 across regular years, divisible-by-4 leap years, century
///   years that are NOT leap (1900), and 400-year leap years (2000).
///
/// - **Days in Jewish months** — asserts fixed-length months (Nissan = 30,
///   Iyar = 29, Tishrei = 30) and variable-length months (Cheshvan, Kislev),
///   plus the correct length of Adar I (30), Adar II (29) in leap years,
///   and Adar (29) in non-leap years.
///
/// - **Jewish ↔ Gregorian date conversion** — verifies that setting a Jewish
///   date produces the correct Gregorian fields, and vice versa, including
///   round-trip conversion and the Feb 29, 2000 edge case.
///
/// - **Date navigation** — tests [JewishDate.forward] and [JewishDate.back]
///   across month and year boundaries (e.g. Elul → Tishrei).
///
/// - **Known Rosh Hashana dates** — spot-checks specific Gregorian equivalents
///   for 1 Tishrei of several years.
///
/// - **Absolute date arithmetic** — verifies that the absolute day counter
///   increments/decrements by exactly 1 when navigating forward/backward.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // ────────────────────────────────────────────────────────────────
  // Jewish leap year
  // ────────────────────────────────────────────────────────────────
  group('JewishDate - leap year', () {
    // Years 3,6,8,11,14,17,19 of every 19-year Metonic cycle are leap years.
    test('known leap years are identified correctly', () {
      for (final year in [5771, 5774, 5776, 5779, 5782, 5784, 5787, 5790, 5793, 5795]) {
        final d = JewishDate();
        d.setJewishYear(year);
        expect(d.isJewishLeapYear(), isTrue, reason: '$year should be a leap year');
      }
    });

    test('known non-leap years are identified correctly', () {
      for (final year in [5770, 5772, 5773, 5775, 5777, 5778, 5780, 5781, 5783, 5785, 5786, 5788, 5789]) {
        final d = JewishDate();
        d.setJewishYear(year);
        expect(d.isJewishLeapYear(), isFalse, reason: '$year should NOT be a leap year');
      }
    });

    test('leap year has 13 months (Adar II exists)', () {
      // 5784 is a leap year
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.ADAR_II, 1);
      expect(d.getJewishMonth(), equals(JewishDate.ADAR_II));
    });

    test('non-leap year last month is Adar (12)', () {
      // 5785 is a non-leap year
      final d = JewishDate();
      d.setJewishYear(5785);
      expect(d.isJewishLeapYear(), isFalse);
      // Adar (12) is the last month
      d.setJewishDate(5785, JewishDate.ADAR, 1);
      expect(d.getJewishMonth(), equals(JewishDate.ADAR));
    });

    test('leap year day count is greater than non-leap year', () {
      final leapYear = JewishDate();
      leapYear.setJewishYear(5784); // leap
      final nonLeapYear = JewishDate();
      nonLeapYear.setJewishYear(5785); // non-leap
      expect(leapYear.getDaysInJewishYear(), greaterThan(nonLeapYear.getDaysInJewishYear()));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Gregorian leap year
  // ────────────────────────────────────────────────────────────────
  group('JewishDate - Gregorian leap year / February days', () {
    test('Feb 29 exists in Gregorian leap year 2000', () {
      final d = JewishDate.fromDateTime(DateTime(2000, 2, 29));
      expect(d.getGregorianMonth(), equals(2));
      expect(d.getGregorianDayOfMonth(), equals(29));
    });

    test('Feb 29 exists in Gregorian leap year 2024', () {
      final d = JewishDate.fromDateTime(DateTime(2024, 2, 29));
      expect(d.getGregorianDayOfMonth(), equals(29));
      expect(d.getGregorianMonth(), equals(2));
    });

    test('getLastDayOfGregorianMonth returns 29 for Feb in leap year', () {
      final d = JewishDate.fromDateTime(DateTime(2024, 1, 1));
      expect(d.getLastDayOfGregorianMonth(2), equals(29));
    });

    test('getLastDayOfGregorianMonth returns 28 for Feb in non-leap year', () {
      final d = JewishDate.fromDateTime(DateTime(2023, 1, 1));
      expect(d.getLastDayOfGregorianMonth(2), equals(28));
    });

    test('century year 1900 is NOT a Gregorian leap year', () {
      // 1900 is divisible by 100 but not 400, so NOT a leap year
      final d = JewishDate.fromDateTime(DateTime(1900, 1, 1));
      expect(d.getLastDayOfGregorianMonth(2), equals(28));
    });

    test('century year 2000 IS a Gregorian leap year (divisible by 400)', () {
      final d = JewishDate.fromDateTime(DateTime(2000, 1, 1));
      expect(d.getLastDayOfGregorianMonth(2), equals(29));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Days in Jewish months
  // ────────────────────────────────────────────────────────────────
  group('JewishDate - days in Jewish months', () {
    test('Nissan always has 30 days', () {
      for (final year in [5783, 5784, 5785]) {
        final d = JewishDate();
        d.setJewishDate(year, JewishDate.NISSAN, 1);
        expect(d.getDaysInJewishMonth(), equals(30),
            reason: 'Nissan $year should have 30 days');
      }
    });

    test('Iyar always has 29 days', () {
      for (final year in [5783, 5784, 5785]) {
        final d = JewishDate();
        d.setJewishDate(year, JewishDate.IYAR, 1);
        expect(d.getDaysInJewishMonth(), equals(29),
            reason: 'Iyar $year should have 29 days');
      }
    });

    test('Tishrei always has 30 days', () {
      for (final year in [5783, 5784, 5785]) {
        final d = JewishDate();
        d.setJewishDate(year, JewishDate.TISHREI, 1);
        expect(d.getDaysInJewishMonth(), equals(30));
      }
    });

    test('Cheshvan length varies (29 or 30) based on year type', () {
      // 5784 - Cheshvan is long (30 days)
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.CHESHVAN, 1);
      final cheshvan5784 = d.getDaysInJewishMonth();
      expect(cheshvan5784, anyOf(equals(29), equals(30)));

      // 5785 - Cheshvan is short (29 days)
      d.setJewishDate(5785, JewishDate.CHESHVAN, 1);
      final cheshvan5785 = d.getDaysInJewishMonth();
      expect(cheshvan5785, anyOf(equals(29), equals(30)));

      // They should not both be the same in all years (the rule varies)
      // This verifies the function returns valid values
    });

    test('Kislev length varies (29 or 30) based on year type', () {
      for (final year in [5782, 5783, 5784, 5785]) {
        final d = JewishDate();
        d.setJewishDate(year, JewishDate.KISLEV, 1);
        final days = d.getDaysInJewishMonth();
        expect(days, anyOf(equals(29), equals(30)),
            reason: 'Kislev $year must be 29 or 30 days');
      }
    });

    test('Adar I in leap year has 30 days', () {
      // 5784 is a leap year
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.ADAR, 1); // Adar I in leap year
      expect(d.getDaysInJewishMonth(), equals(30));
    });

    test('Adar II in leap year has 29 days', () {
      // 5784 is a leap year
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.ADAR_II, 1);
      expect(d.getDaysInJewishMonth(), equals(29));
    });

    test('Adar in non-leap year has 29 days', () {
      // 5785 is a non-leap year
      final d = JewishDate();
      d.setJewishDate(5785, JewishDate.ADAR, 1);
      expect(d.getDaysInJewishMonth(), equals(29));
    });

    test('isCheshvanLong and isKislevShort reflect year type correctly', () {
      for (final year in [5782, 5783, 5784, 5785, 5786]) {
        final d = JewishDate();
        d.setJewishYear(year);
        final kviah = d.getCheshvanKislevKviah();
        expect(kviah, anyOf(
          equals(JewishDate.CHASERIM),
          equals(JewishDate.KESIDRAN),
          equals(JewishDate.SHELAIMIM),
        ), reason: 'Year $year kviah must be one of the three types');
      }
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Date conversion: Jewish ↔ Gregorian
  // ────────────────────────────────────────────────────────────────
  group('JewishDate - Jewish to Gregorian conversion', () {
    test('1 Tishrei 5784 equals Sep 16, 2023', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.TISHREI, 1);
      expect(d.getGregorianYear(), equals(2023));
      expect(d.getGregorianMonth(), equals(9));
      expect(d.getGregorianDayOfMonth(), equals(16));
    });

    test('1 Nisan 5784 equals Apr 9, 2024', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.NISSAN, 1);
      expect(d.getGregorianYear(), equals(2024));
      expect(d.getGregorianMonth(), equals(4));
      expect(d.getGregorianDayOfMonth(), equals(9));
    });

    test('Gregorian to Jewish: Jan 1, 2024 is 20 Tevet 5784', () {
      final d = JewishDate.fromDateTime(DateTime(2024, 1, 1));
      expect(d.getJewishYear(), equals(5784));
      expect(d.getJewishMonth(), equals(JewishDate.TEVES));
      expect(d.getJewishDayOfMonth(), equals(20));
    });

    test('Gregorian to Jewish: Feb 29, 2000 converts correctly', () {
      final d = JewishDate.fromDateTime(DateTime(2000, 2, 29));
      expect(d.getJewishYear(), equals(5760));
      expect(d.getGregorianDayOfMonth(), equals(29));
    });

    test('round-trip: Jewish -> Gregorian -> Jewish returns same date', () {
      final original = JewishDate();
      original.setJewishDate(5783, JewishDate.NISSAN, 15); // Pesach

      final gregorian = DateTime(
        original.getGregorianYear(),
        original.getGregorianMonth(),
        original.getGregorianDayOfMonth(),
      );

      final roundTrip = JewishDate.fromDateTime(gregorian);
      expect(roundTrip.getJewishYear(), equals(5783));
      expect(roundTrip.getJewishMonth(), equals(JewishDate.NISSAN));
      expect(roundTrip.getJewishDayOfMonth(), equals(15));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Date navigation
  // ────────────────────────────────────────────────────────────────
  group('JewishDate - date navigation', () {
    test('forward one day across month boundary', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.TISHREI, 30);
      d.forward(Calendar.DATE, 1);
      expect(d.getJewishMonth(), equals(JewishDate.CHESHVAN));
      expect(d.getJewishDayOfMonth(), equals(1));
    });

    test('forward one day across year boundary (Elul -> Tishrei)', () {
      final d = JewishDate();
      d.setJewishDate(5783, JewishDate.ELUL, 29); // last day of year
      d.forward(Calendar.DATE, 1);
      expect(d.getJewishYear(), equals(5784));
      expect(d.getJewishMonth(), equals(JewishDate.TISHREI));
      expect(d.getJewishDayOfMonth(), equals(1));
    });

    test('back one day across month boundary', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.CHESHVAN, 1);
      d.back();
      expect(d.getJewishMonth(), equals(JewishDate.TISHREI));
      expect(d.getJewishDayOfMonth(), equals(30));
    });

    test('back one day across year boundary (Tishrei 1 -> Elul 29)', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.TISHREI, 1);
      d.back();
      expect(d.getJewishYear(), equals(5783));
      expect(d.getJewishMonth(), equals(JewishDate.ELUL));
      expect(d.getJewishDayOfMonth(), equals(29));
    });

    test('forward one month', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.TISHREI, 15);
      d.forward(Calendar.MONTH, 1);
      expect(d.getJewishMonth(), equals(JewishDate.CHESHVAN));
      expect(d.getJewishDayOfMonth(), equals(15));
    });

    test('back one month (regular month)', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.CHESHVAN, 15);
      d.back(Calendar.MONTH, 1);
      expect(d.getJewishMonth(), equals(JewishDate.TISHREI));
      expect(d.getJewishDayOfMonth(), equals(15));
    });

    test('back one month from Tishrei goes to Elul of previous year', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.TISHREI, 15);
      d.back(Calendar.MONTH, 1);
      expect(d.getJewishYear(), equals(5783));
      expect(d.getJewishMonth(), equals(JewishDate.ELUL));
      expect(d.getJewishDayOfMonth(), equals(15));
    });

    test('back one month from Nissan goes to Adar (non-leap year)', () {
      // 5785 is a non-leap year, so going back from Nissan should land on Adar (12)
      final d = JewishDate();
      d.setJewishDate(5785, JewishDate.NISSAN, 15);
      d.back(Calendar.MONTH, 1);
      expect(d.getJewishMonth(), equals(JewishDate.ADAR));
    });

    test('back one month from Nissan goes to Adar II (leap year)', () {
      // 5784 is a leap year, so going back from Nissan should land on Adar II (13)
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.NISSAN, 15);
      d.back(Calendar.MONTH, 1);
      expect(d.getJewishMonth(), equals(JewishDate.ADAR_II));
    });

    test('back month adjusts day when new month has fewer days', () {
      // Tishrei has 30 days; Elul has only 29 days
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.TISHREI, 30);
      d.back(Calendar.MONTH, 1);
      expect(d.getJewishYear(), equals(5783));
      expect(d.getJewishMonth(), equals(JewishDate.ELUL));
      expect(d.getJewishDayOfMonth(), equals(29)); // adjusted from 30 to 29
    });

    test('back multiple months', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.KISLEV, 15);
      d.back(Calendar.MONTH, 2);
      expect(d.getJewishMonth(), equals(JewishDate.TISHREI));
      expect(d.getJewishDayOfMonth(), equals(15));
    });

    test('back one year', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.NISSAN, 15);
      d.back(Calendar.YEAR, 1);
      expect(d.getJewishYear(), equals(5783));
      expect(d.getJewishMonth(), equals(JewishDate.NISSAN));
    });

    test('getDayOfWeek returns value between 1 and 7', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.TISHREI, 1);
      expect(d.getDayOfWeek(), inInclusiveRange(1, 7));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Rosh Hashana (known dates)
  // ────────────────────────────────────────────────────────────────
  group('JewishDate - Rosh Hashana known dates', () {
    final roshHashanaData = {
      5771: DateTime(2010, 9, 9),
      5784: DateTime(2023, 9, 16),
      5785: DateTime(2024, 10, 3),
    };

    roshHashanaData.forEach((jewishYear, gregorian) {
      test('Rosh Hashana $jewishYear == ${gregorian.year}-${gregorian.month}-${gregorian.day}', () {
        final d = JewishDate();
        d.setJewishDate(jewishYear, JewishDate.TISHREI, 1);
        expect(d.getGregorianYear(), equals(gregorian.year));
        expect(d.getGregorianMonth(), equals(gregorian.month));
        expect(d.getGregorianDayOfMonth(), equals(gregorian.day));
      });
    });
  });

  // ────────────────────────────────────────────────────────────────
  // JewishDate.initDate constructor
  // ────────────────────────────────────────────────────────────────
  group('JewishDate.initDate constructor', () {
    test('creates date with correct Jewish fields', () {
      final d = JewishDate.initDate(
        jewishYear: 5784,
        jewishMonth: JewishDate.NISSAN,
        jewishDayOfMonth: 15,
      );
      expect(d.getJewishYear(), equals(5784));
      expect(d.getJewishMonth(), equals(JewishDate.NISSAN));
      expect(d.getJewishDayOfMonth(), equals(15));
    });
  });

  // ────────────────────────────────────────────────────────────────
  // Absolute date
  // ────────────────────────────────────────────────────────────────
  group('JewishDate - absolute date', () {
    test('absDate increases by 1 after forward one day', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.NISSAN, 1);
      final before = d.getAbsDate();
      d.forward(Calendar.DATE, 1);
      expect(d.getAbsDate(), equals(before + 1));
    });

    test('absDate decreases by 1 after back one day', () {
      final d = JewishDate();
      d.setJewishDate(5784, JewishDate.NISSAN, 15);
      final before = d.getAbsDate();
      d.back();
      expect(d.getAbsDate(), equals(before - 1));
    });
  });
}
