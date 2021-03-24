import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  HebrewDateFormatter hdf = HebrewDateFormatter();
  hdf.hebrewFormat = true;

  test('testCorrectDaf1', () async {
    JewishCalendar jewishCalendar =
        JewishCalendar.initDate(5685, JewishDate.KISLEV, 12);
    Daf daf = YomiCalculator.getDafYomiBavli(jewishCalendar);
    expect(daf.getMasechtaNumber(), 5);
    expect(daf.getDaf(), 2);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiBavli()));
  });

  test('testCorrectDaf2', () async {
    JewishCalendar jewishCalendar =
        JewishCalendar.initDate(5736, JewishDate.ELUL, 26);
    Daf daf = YomiCalculator.getDafYomiBavli(jewishCalendar);
    expect(daf.getMasechtaNumber(), 4);
    expect(daf.getDaf(), 14);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiBavli()));
  });

  test('testCorrectDaf3', () async {
    JewishCalendar jewishCalendar =
        JewishCalendar.initDate(5777, JewishDate.ELUL, 10);
    Daf daf = YomiCalculator.getDafYomiBavli(jewishCalendar);
    expect(daf.getMasechtaNumber(), 23);
    expect(daf.getDaf(), 47);
    print(hdf.formatDafYomiYerushalmi(jewishCalendar.getDafYomiBavli()));
  });
}
