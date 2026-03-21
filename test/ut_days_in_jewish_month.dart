/// Tests for the three Jewish year types based on Cheshvan and Kislev length.
///
/// Every Jewish year falls into one of three structural types (kviah):
/// - **Haser (deficient):** Cheshvan = 29 days, Kislev = 29 days.
/// - **Kesidran (regular/Qesidrah):** Cheshvan = 29 days, Kislev = 30 days.
/// - **Shalem (complete):** Cheshvan = 30 days, Kislev = 30 days.
///
/// Each type can occur in both regular and leap years, giving six possible
/// year structures in total. This file tests representative years for all six.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // Haser non-leap years: both Cheshvan and Kislev are 29 days.
  test('daysInMonthsInHaserYear', () async {
    _assertHaser(5773);
    _assertHaser(5777);
    _assertHaser(5781);
    _assertHaserLeap(5784);
    _assertHaserLeap(5790);
    _assertHaserLeap(5793);
  });

  // Kesidran non-leap years: Cheshvan = 29, Kislev = 30.
  test('daysInMonthsInQesidrahYear', () async {
    _assertQesidrah(5769);
    _assertQesidrah(5772);
    _assertQesidrah(5778);
    _assertQesidrah(5786);
    _assertQesidrah(5789);
    _assertQesidrah(5792);

    _assertQesidrahLeap(5782);
  });

  // Shalem non-leap years: both Cheshvan and Kislev are 30 days.
  // Also covers all Shalem leap years.
  test('daysInMonthsInShalemYear', () async {
    _assertShalem(5770);
    _assertShalem(5780);
    _assertShalem(5783);
    _assertShalem(5785);
    _assertShalem(5788);
    _assertShalem(5791);
    _assertShalem(5794);

    _assertShalemLeap(5771);
    _assertShalemLeap(5774);
    _assertShalemLeap(5776);
    _assertShalemLeap(5779);
    _assertShalemLeap(5787);
    _assertShalemLeap(5795);
  });
}

/// Asserts that [year] is a Haser year: Cheshvan short, Kislev short.
void _assertHaser(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isCheshvanLong(), false);
  expect(jewishDate.isKislevShort(), true);
}

/// Asserts that [year] is a Haser leap year: Cheshvan short, Kislev short, 13 months.
void _assertHaserLeap(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  _assertHaser(year);
  expect(jewishDate.isJewishLeapYear(), true);
}

/// Asserts that [year] is a Kesidran year: Cheshvan short, Kislev long.
void _assertQesidrah(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isCheshvanLong(), false);
  expect(jewishDate.isKislevShort(), false);
}

/// Asserts that [year] is a Kesidran leap year: Cheshvan short, Kislev long, 13 months.
void _assertQesidrahLeap(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  _assertQesidrah(year);
  expect(jewishDate.isJewishLeapYear(), true);
}

/// Asserts that [year] is a Shalem year: Cheshvan long, Kislev long.
void _assertShalem(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isCheshvanLong(), true);
  expect(jewishDate.isKislevShort(), false);
}

/// Asserts that [year] is a Shalem leap year: Cheshvan long, Kislev long, 13 months.
void _assertShalemLeap(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  _assertShalem(year);
  expect(jewishDate.isJewishLeapYear(), true);
}
