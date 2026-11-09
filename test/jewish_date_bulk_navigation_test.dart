import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void expectSameJewishDate(JewishDate a, JewishDate b) {
  expect(a.getGregorianYear(), b.getGregorianYear());
  expect(a.getGregorianMonth(), b.getGregorianMonth());
  expect(a.getGregorianDayOfMonth(), b.getGregorianDayOfMonth());
  expect(a.getJewishYear(), b.getJewishYear());
  expect(a.getJewishMonth(), b.getJewishMonth());
  expect(a.getJewishDayOfMonth(), b.getJewishDayOfMonth());
  expect(a.getDayOfWeek(), b.getDayOfWeek());
  expect(a.getAbsDate(), b.getAbsDate());
}

void main() {
  final dates = [
    DateTime.utc(1900, 2, 28),
    DateTime.utc(2000, 2, 28),
    DateTime.utc(2024, 2, 28),
    DateTime.utc(2024, 9, 30),
    DateTime.utc(2026, 1, 1),
    DateTime.utc(2030, 12, 31),
  ];

  group('Gregorian absolute date', () {
    test('known century leap-day offsets match DateTime UTC', () {
      for (final start in dates) {
        final first = JewishDate.fromDateTime(start);
        for (final days in [1, 28, 31, 32, 59, 63, 64, 365, 1000]) {
          final stepped = JewishDate.fromDateTime(start);
          stepped.forward(Calendar.DATE, days);
          final expected = JewishDate.fromDateTime(
              DateTime.utc(start.year, start.month, start.day + days));
          expectSameJewishDate(stepped, expected);
          expect(stepped.getAbsDate() - first.getAbsDate(), days);
        }
      }
    });
  });

  group('bulk day navigation', () {
    test('bulk forward is identical to repeated daily increments', () {
      for (final start in dates) {
        for (final days in [31, 32, 33, 63, 64, 65, 100, 365, 1000]) {
          final bulk = JewishDate.fromDateTime(start);
          final stepped = JewishDate.fromDateTime(start);
          bulk.forward(Calendar.DATE, days);
          for (var i = 0; i < days; i++) {
            stepped.forward();
          }
          expectSameJewishDate(bulk, stepped);
        }
      }
    });

    test('bulk backwards is identical to repeated daily decrements', () {
      for (final start in dates) {
        for (final days in [31, 32, 33, 63, 64, 65, 100, 365, 1000]) {
          final bulk = JewishDate.fromDateTime(start);
          final stepped = JewishDate.fromDateTime(start);
          bulk.back(Calendar.DATE, days);
          for (var i = 0; i < days; i++) {
            stepped.back();
          }
          expectSameJewishDate(bulk, stepped);
        }
      }
    });

    test('round trip across Jewish and Gregorian leap years', () {
      final date = JewishDate.fromDateTime(DateTime.utc(2024, 2, 29));
      final previous = JewishDate.fromDateTime(DateTime.utc(2024, 2, 29));
      date.forward(Calendar.DATE, 10000);
      date.back(Calendar.DATE, 10000);
      expectSameJewishDate(date, previous);
    });
  });
}
