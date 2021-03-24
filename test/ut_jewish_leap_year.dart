import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
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

void _shouldBeLeapYear(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isJewishLeapYear(), true);
}

void _shouldNotBeLeapYear(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isJewishLeapYear(), false);
}
