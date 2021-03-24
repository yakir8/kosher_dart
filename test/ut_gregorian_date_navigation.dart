import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  test('gregorianForwardMonthToMonth', () async {
    DateTime dateTime = DateTime.utc(2011, DateTime.january, 31);

    JewishDate hebrewDate = JewishDate.fromDateTime(dateTime);
    expect(hebrewDate.getJewishYear(), 5771);
    expect(hebrewDate.getJewishMonth(), 11);
    expect(hebrewDate.getJewishDayOfMonth(), 26);

    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 2);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 11);
    expect(hebrewDate.getJewishDayOfMonth(), 27);

    dateTime = DateTime.utc(2011, DateTime.february, 28);
    hebrewDate.setDate(dateTime);
    expect(hebrewDate.getGregorianMonth(), 2);
    expect(hebrewDate.getGregorianDayOfMonth(), 28);
    expect(hebrewDate.getJewishMonth(), 12);
    expect(hebrewDate.getJewishDayOfMonth(), 24);

    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 3);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 12);
    expect(hebrewDate.getJewishDayOfMonth(), 25);

    dateTime = DateTime.utc(2011, DateTime.march, 31);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 4);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 13);
    expect(hebrewDate.getJewishDayOfMonth(), 26);

    dateTime = DateTime.utc(2011, DateTime.april, 30);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 5);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 1);
    expect(hebrewDate.getJewishDayOfMonth(), 27);

    dateTime = DateTime.utc(2011, DateTime.may, 31);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 6);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 2);
    expect(hebrewDate.getJewishDayOfMonth(), 28);

    dateTime = DateTime.utc(2011, DateTime.june, 30);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 7);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 3);
    expect(hebrewDate.getJewishDayOfMonth(), 29);

    dateTime = DateTime.utc(2011, DateTime.july, 31);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 8);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 5);
    expect(hebrewDate.getJewishDayOfMonth(), 1);

    dateTime = DateTime.utc(2011, DateTime.august, 31);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 9);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 6);
    expect(hebrewDate.getJewishDayOfMonth(), 2);

    dateTime = DateTime.utc(2011, DateTime.september, 30);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 10);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 7);
    expect(hebrewDate.getJewishDayOfMonth(), 3);

    dateTime = DateTime.utc(2011, DateTime.october, 31);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 11);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishYear(), 5772);
    expect(hebrewDate.getJewishMonth(), 8);
    expect(hebrewDate.getJewishDayOfMonth(), 4);

    dateTime = DateTime.utc(2011, DateTime.november, 30);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianMonth(), 12);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 9);
    expect(hebrewDate.getJewishDayOfMonth(), 5);

    dateTime = DateTime.utc(2011, DateTime.december, 31);
    hebrewDate.setDate(dateTime);
    hebrewDate.forward(Calendar.DATE, 1);
    expect(hebrewDate.getGregorianYear(), 2012);
    expect(hebrewDate.getGregorianMonth(), 1);
    expect(hebrewDate.getGregorianDayOfMonth(), 1);
    expect(hebrewDate.getJewishMonth(), 10);
    expect(hebrewDate.getJewishDayOfMonth(), 6);
  });

  test('gregorianBackwardMonthToMonth', () async {
    DateTime dateTime = DateTime.utc(2011, DateTime.january, 1);

    JewishDate hebrewDate = JewishDate.fromDateTime(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianYear(), 2010);
    expect(hebrewDate.getGregorianMonth(), 12);
    expect(hebrewDate.getGregorianDayOfMonth(), 31);
    expect(hebrewDate.getJewishMonth(), 10);
    expect(hebrewDate.getJewishDayOfMonth(), 24);

    dateTime = DateTime.utc(2010, DateTime.december, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 11);
    expect(hebrewDate.getGregorianDayOfMonth(), 30);
    expect(hebrewDate.getJewishMonth(), 9);
    expect(hebrewDate.getJewishDayOfMonth(), 23);

    dateTime = DateTime.utc(2010, DateTime.november, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 10);
    expect(hebrewDate.getGregorianDayOfMonth(), 31);
    expect(hebrewDate.getJewishMonth(), 8);
    expect(hebrewDate.getJewishDayOfMonth(), 23);

    dateTime = DateTime.utc(2010, DateTime.october, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 9);
    expect(hebrewDate.getGregorianDayOfMonth(), 30);
    expect(hebrewDate.getJewishMonth(), 7);
    expect(hebrewDate.getJewishDayOfMonth(), 22);

    dateTime = DateTime.utc(2010, DateTime.september, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 8);
    expect(hebrewDate.getGregorianDayOfMonth(), 31);
    expect(hebrewDate.getJewishYear(), 5770);
    expect(hebrewDate.getJewishMonth(), 6);
    expect(hebrewDate.getJewishDayOfMonth(), 21);

    dateTime = DateTime.utc(2010, DateTime.august, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 7);
    expect(hebrewDate.getGregorianDayOfMonth(), 31);
    expect(hebrewDate.getJewishMonth(), 5);
    expect(hebrewDate.getJewishDayOfMonth(), 20);

    dateTime = DateTime.utc(2010, DateTime.july, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 6);
    expect(hebrewDate.getGregorianDayOfMonth(), 30);
    expect(hebrewDate.getJewishMonth(), 4);
    expect(hebrewDate.getJewishDayOfMonth(), 18);

    dateTime = DateTime.utc(2010, DateTime.june, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 5);
    expect(hebrewDate.getGregorianDayOfMonth(), 31);
    expect(hebrewDate.getJewishMonth(), 3);
    expect(hebrewDate.getJewishDayOfMonth(), 18);

    dateTime = DateTime.utc(2010, DateTime.may, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 4);
    expect(hebrewDate.getGregorianDayOfMonth(), 30);
    expect(hebrewDate.getJewishMonth(), 2);
    expect(hebrewDate.getJewishDayOfMonth(), 16);

    dateTime = DateTime.utc(2010, DateTime.april, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 3);
    expect(hebrewDate.getGregorianDayOfMonth(), 31);
    expect(hebrewDate.getJewishMonth(), 1);
    expect(hebrewDate.getJewishDayOfMonth(), 16);

    dateTime = DateTime.utc(2010, DateTime.march, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 2);
    expect(hebrewDate.getGregorianDayOfMonth(), 28);
    expect(hebrewDate.getJewishMonth(), 12);
    expect(hebrewDate.getJewishDayOfMonth(), 14);

    dateTime = DateTime.utc(2010, DateTime.february, 1);
    hebrewDate.setDate(dateTime);
    hebrewDate.back();
    expect(hebrewDate.getGregorianMonth(), 1);
    expect(hebrewDate.getGregorianDayOfMonth(), 31);
    expect(hebrewDate.getJewishMonth(), 11);
    expect(hebrewDate.getJewishDayOfMonth(), 16);
  });
}
