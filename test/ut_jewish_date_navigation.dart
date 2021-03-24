import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  test('jewishForwardMonthToMonth', () async {
    JewishDate jewishDate = JewishDate();
    jewishDate.setJewishDate(5771, 1, 1);
    expect(jewishDate.getGregorianDayOfMonth(), 5);
    expect(jewishDate.getGregorianMonth(), 4);
    expect(jewishDate.getGregorianYear(), 2011);
  });

  test('computeRoshHashana5771', () async {
    // At one point, this test was failing as the JewishDate class spun through a never-ending loop...

    JewishDate jewishDate = JewishDate();
    jewishDate.setJewishDate(5771, 7, 1);
    expect(jewishDate.getGregorianDayOfMonth(), 9);
    expect(jewishDate.getGregorianMonth(), 9);
    expect(jewishDate.getGregorianYear(), 2010);
  });
}
