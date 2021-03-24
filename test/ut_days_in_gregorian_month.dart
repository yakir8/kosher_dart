import 'package:test/test.dart';

import 'package:kosher_dart/kosher_dart.dart';

void main() {
  test('testDaysInMonth', () async {
    JewishDate hebrewDate = JewishDate();
    DateTime dateTime = DateTime.utc(2011, DateTime.january);
    hebrewDate.setDate(dateTime);

    _assertDaysInMonth(false, hebrewDate);
  });

  test('testDaysInMonthLeapYear', () async {
    JewishDate hebrewDate = JewishDate();
    DateTime dateTime = DateTime.utc(2012, DateTime.january);
    hebrewDate.setDate(dateTime);

    _assertDaysInMonth(true, hebrewDate);
  });

  test('testDaysInMonth100Year', () async {
    JewishDate hebrewDate = JewishDate();
    DateTime dateTime = DateTime.utc(2100, DateTime.january);
    hebrewDate.setDate(dateTime);

    _assertDaysInMonth(false, hebrewDate);
  });

  test('testDaysInMonth400Year', () async {
    JewishDate hebrewDate = JewishDate();
    DateTime dateTime = DateTime.utc(2400, DateTime.january);
    hebrewDate.setDate(dateTime);

    _assertDaysInMonth(true, hebrewDate);
  });
}

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
