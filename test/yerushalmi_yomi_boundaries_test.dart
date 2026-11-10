import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void main() {
  Daf dafAt(DateTime day) =>
      JewishCalendar.fromDateTime(day).getDafYomiYerushalmi();

  void expectDaf(DateTime day, int tractate, int daf) {
    final result = dafAt(day);
    expect(result.getMasechtaNumber(), tractate, reason: '$day tractate');
    expect(result.getDaf(), daf, reason: '$day page');
  }

  group('Yerushalmi Yomi cycle and boundaries', () {
    test('first day and end of first tractate', () {
      expectDaf(DateTime.utc(1980, 2, 2), 0, 1);
      expectDaf(DateTime.utc(1980, 4, 9), 0, 68);
      expectDaf(DateTime.utc(1980, 4, 10), 1, 1);
    });

    test('a cycle transition must restart at the first daf', () {
      expectDaf(DateTime.utc(1984, 5, 13), 0, 1);
      expectDaf(DateTime.utc(1984, 5, 14), 0, 2);
    });

    test('a fast on the tentative cycle boundary extends that cycle', () {
      // 10 Tishrei 5997 is 2236-10-10, when a cycle would otherwise end.
      expectDaf(DateTime.utc(2236, 10, 10), 39, 0);
      expectDaf(DateTime.utc(2236, 10, 11), 0, 1);
    });

    test('historical schedule anchors remain unchanged', () {
      expectDaf(DateTime.utc(1983, 11, 7), 32, 26);
      expectDaf(DateTime.utc(2017, 9, 1), 29, 8);
      expectDaf(DateTime.utc(2022, 5, 31), 33, 15);
    });

    test('9 Av on Shabbos has a daf; deferred 10 Av does not', () {
      expectDaf(DateTime.utc(2022, 8, 5), 35, 28);
      expectDaf(DateTime.utc(2022, 8, 6), 35, 29);
      expectDaf(DateTime.utc(2022, 8, 7), 39, 0);
      expectDaf(DateTime.utc(2022, 8, 8), 35, 30);
    });

    test('non-postponed Tisha Beav and Yom Kippur have no daf', () {
      expectDaf(DateTime.utc(2024, 8, 13), 39, 0);
      expectDaf(DateTime.utc(2024, 10, 12), 39, 0);
    });

    test('the day before the first cycle raises ArgumentError', () {
      expect(() => dafAt(DateTime.utc(1980, 2, 1)), throwsArgumentError);
    });

    test('a fast before the first cycle still reports no daf', () {
      // Yom Kippur 5740.
      expectDaf(DateTime.utc(1979, 10, 1), 39, 0);
    });

    test('normalization ignores time of day and local/UTC constructors', () {
      final a = dafAt(DateTime.utc(2024, 6, 15, 12, 30));
      final b = dafAt(DateTime(2024, 6, 15, 23, 45));
      expect(a.getMasechtaNumber(), b.getMasechtaNumber());
      expect(a.getDaf(), b.getDaf());
    });
  });
}
