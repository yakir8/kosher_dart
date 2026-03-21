/// Tests for [JewishDate.isJewishLeapYear].
///
/// A Jewish leap year contains 13 months instead of 12, with an extra Adar
/// (Adar II) inserted. Leap years follow the 19-year Metonic cycle and occur
/// in years 3, 6, 8, 11, 14, 17, and 19 of every cycle.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // Verifies a broad range of years spanning multiple 19-year cycles.
  test('isLeapYear', () async {
    _shouldBeLeapYear(5160);
    _shouldNotBeLeapYear(5536);

    _shouldNotBeLeapYear(5770);
    _shouldBeLeapYear(5771);
    _shouldNotBeLeapYear(5772);
    _shouldNotBeLeapYear(5773);
    _shouldBeLeapYear(5774);
    _shouldNotBeLeapYear(5775);
    _shouldBeLeapYear(5776);
    _shouldNotBeLeapYear(5777);
    _shouldNotBeLeapYear(5778);
    _shouldBeLeapYear(5779);
    _shouldNotBeLeapYear(5780);
    _shouldNotBeLeapYear(5781);
    _shouldBeLeapYear(5782);
    _shouldNotBeLeapYear(5783);
    _shouldBeLeapYear(5784);
    _shouldNotBeLeapYear(5785);
    _shouldNotBeLeapYear(5786);
    _shouldBeLeapYear(5787);
    _shouldNotBeLeapYear(5788);
    _shouldNotBeLeapYear(5789);
    _shouldBeLeapYear(5790);
    _shouldNotBeLeapYear(5791);
    _shouldNotBeLeapYear(5792);
    _shouldBeLeapYear(5793);
    _shouldNotBeLeapYear(5794);
    _shouldBeLeapYear(5795);
  });
}

/// Asserts that [year] is a Jewish leap year.
void _shouldBeLeapYear(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isJewishLeapYear(), true);
}

/// Asserts that [year] is NOT a Jewish leap year.
void _shouldNotBeLeapYear(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isJewishLeapYear(), false);
}
