import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  HebrewDateFormatter hdf = HebrewDateFormatter();
  hdf.hebrewFormat = true;

  test('testCorrectDaf1', () async {
    JewishCalendar jewishCalendar = JewishCalendar.initDate(5777, 6, 10);
    expect(jewishCalendar.getDafYomiYerushalmi().getDaf(), 8);
    expect(jewishCalendar.getDafYomiYerushalmi().getMasechtaNumber(), 29);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiYerushalmi()));
  });

  test('testCorrectDaf2', () async {
    JewishCalendar jewishCalendar = JewishCalendar.initDate(5744, 9, 1);
    expect(jewishCalendar.getDafYomiYerushalmi().getDaf(), 26);
    expect(jewishCalendar.getDafYomiYerushalmi().getMasechtaNumber(), 32);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiYerushalmi()));
  });

  test('testCorrectDaf3', () async {
    JewishCalendar jewishCalendar = JewishCalendar.initDate(5782, 3, 1);
    expect(jewishCalendar.getDafYomiYerushalmi().getDaf(), 15);
    expect(jewishCalendar.getDafYomiYerushalmi().getMasechtaNumber(), 33);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiYerushalmi()));
  });

  test('testCorrectSpecialDate', () async {
    JewishCalendar jewishCalendar = JewishCalendar.initDate(5775, 7, 10);
    expect(jewishCalendar.getDafYomiYerushalmi().getDaf(), 0);
    expect(jewishCalendar.getDafYomiYerushalmi().getMasechtaNumber(), 39);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiYerushalmi()));
  });
}
