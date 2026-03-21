/// Tests for [JewishDate.getLastDayOfGregorianMonth] across all 12 months.
///
/// Covers the four Gregorian leap-year rules:
/// - A regular year (2011) — February has 28 days.
/// - A standard leap year (2012, divisible by 4) — February has 29 days.
/// - A century year that is NOT a leap year (2100, divisible by 100 but not 400).
/// - A 400-year leap year (2400) — February has 29 days.
library;

import 'package:test/test.dart';

import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // Regular (non-leap) year: February = 28 days.
  test('testDaysInMonth', () async {
    JewishDate hebrewDate = JewishDate();
    DateTime dateTime = DateTime.utc(2011, DateTime.january);
    hebrewDate.setDate(dateTime);

    _assertDaysInMonth(false, hebrewDate);
  });

  // Standard leap year divisible by 4: February = 29 days.
  test('testDaysInMonthLeapYear', () async {
    JewishDate hebrewDate = JewishDate();
    DateTime dateTime = DateTime.utc(2012, DateTime.january);
    hebrewDate.setDate(dateTime);

    _assertDaysInMonth(true, hebrewDate);
  });

  // Century year NOT divisible by 400: NOT a leap year — February = 28 days.
  test('testDaysInMonth100Year', () async {
    JewishDate hebrewDate = JewishDate();
    DateTime dateTime = DateTime.utc(2100, DateTime.january);
    hebrewDate.setDate(dateTime);

    _assertDaysInMonth(false, hebrewDate);
  });

  // Year divisible by 400: IS a leap year — February = 29 days.
  test('testDaysInMonth400Year', () async {
    JewishDate hebrewDate = JewishDate();
    DateTime dateTime = DateTime.utc(2400, DateTime.january);
    hebrewDate.setDate(dateTime);

    _assertDaysInMonth(true, hebrewDate);
  });
}

/// Asserts the number of days in every Gregorian month for the year that
/// [hebrewDate] is currently set to.
///
/// [febIsLeap] controls whether February is expected to have 29 days (true)
/// or 28 days (false).
void _assertDaysInMonth(bool febIsLeap, JewishDate hebrewDate) {
  expect(hebrewDate.getLastDayOfGregorianMonth(1), 31);
  expect(hebrewDate.getLastDayOfGregorianMonth(2), febIsLeap ? 29 : 28);
  expect(hebrewDate.getLastDayOfGregorianMonth(3), 31);
  expect(hebrewDate.getLastDayOfGregorianMonth(4), 30);
  expect(hebrewDate.getLastDayOfGregorianMonth(5), 31);
  expect(hebrewDate.getLastDayOfGregorianMonth(6), 30);
  expect(hebrewDate.getLastDayOfGregorianMonth(7), 31);
  expect(hebrewDate.getLastDayOfGregorianMonth(8), 31);
  expect(hebrewDate.getLastDayOfGregorianMonth(9), 30);
  expect(hebrewDate.getLastDayOfGregorianMonth(10), 31);
  expect(hebrewDate.getLastDayOfGregorianMonth(11), 30);
  expect(hebrewDate.getLastDayOfGregorianMonth(12), 31);
}
