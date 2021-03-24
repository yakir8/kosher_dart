import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  test('daysInMonthsInHaserYear', () async {
    _assertHaser(5773);
    _assertHaser(5777);
    _assertHaser(5781);
    _assertHaserLeap(5784);
    _assertHaserLeap(5790);
    _assertHaserLeap(5793);
  });

  test('daysInMonthsInQesidrahYear', () async {
    _assertQesidrah(5769);
    _assertQesidrah(5772);
    _assertQesidrah(5778);
    _assertQesidrah(5786);
    _assertQesidrah(5789);
    _assertQesidrah(5792);

    _assertQesidrahLeap(5782);
  });

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

void _assertHaser(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isCheshvanLong(), false);
  expect(jewishDate.isKislevShort(), true);
}

void _assertHaserLeap(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  _assertHaser(year);
  expect(jewishDate.isJewishLeapYear(), true);
}

void _assertQesidrah(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isCheshvanLong(), false);
  expect(jewishDate.isKislevShort(), false);
}

void _assertQesidrahLeap(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  _assertQesidrah(year);
  expect(jewishDate.isJewishLeapYear(), true);
}

void _assertShalem(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  expect(jewishDate.isCheshvanLong(), true);
  expect(jewishDate.isKislevShort(), false);
}

void _assertShalemLeap(int year) {
  JewishDate jewishDate = JewishDate();
  jewishDate.setJewishYear(year);

  _assertShalem(year);
  expect(jewishDate.isJewishLeapYear(), true);
}
