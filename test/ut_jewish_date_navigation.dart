/// Tests for Jewish calendar date navigation using [JewishDate].
///
/// Verifies that setting a Jewish date correctly maps to the expected Gregorian
/// date, and that known dates such as Rosh Hashana 5771 compute without
/// entering an infinite loop (a regression guard).
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // 1 Nissan 5771 should correspond to April 5, 2011.
  test('jewishForwardMonthToMonth', () async {
    JewishDate jewishDate = JewishDate();
    jewishDate.setJewishDate(5771, 1, 1);
    expect(jewishDate.getGregorianDayOfMonth(), 5);
    expect(jewishDate.getGregorianMonth(), 4);
    expect(jewishDate.getGregorianYear(), 2011);
  });

  // Regression test: computing Rosh Hashana 5771 previously caused an infinite
  // loop inside JewishDate. 1 Tishrei 5771 = September 9, 2010.
  test('computeRoshHashana5771', () async {
    // At one point, this test was failing as the JewishDate class spun through a never-ending loop...

    JewishDate jewishDate = JewishDate();
    jewishDate.setJewishDate(5771, 7, 1);
    expect(jewishDate.getGregorianDayOfMonth(), 9);
    expect(jewishDate.getGregorianMonth(), 9);
    expect(jewishDate.getGregorianYear(), 2010);
  });
}
