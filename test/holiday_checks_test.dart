/// Tests for the single-holiday checks of [JewishCalendar]:
/// [JewishCalendar.isRoshHashana], [JewishCalendar.isYomKippur],
/// [JewishCalendar.isSuccos], [JewishCalendar.isHoshanaRabba],
/// [JewishCalendar.isShminiAtzeres], [JewishCalendar.isSimchasTorah],
/// [JewishCalendar.isPesach], [JewishCalendar.isShavuos] and
/// [JewishCalendar.isTishaBav], as in KosherJava.
library;

import 'package:test/test.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  JewishCalendar day(int year, int month, int dayOfMonth, {bool inIsrael = false}) =>
      JewishCalendar()
        ..inIsrael = inIsrael
        ..setJewishDate(year, month, dayOfMonth);

  test('Rosh Hashana: both days, not Erev Rosh Hashana', () {
    expect(day(5785, JewishDate.TISHREI, 1).isRoshHashana(), isTrue);
    expect(day(5785, JewishDate.TISHREI, 2).isRoshHashana(), isTrue);
    expect(day(5784, JewishDate.ELUL, 29).isRoshHashana(), isFalse);
  });

  test('Yom Kippur: 10 Tishrei only', () {
    expect(day(5785, JewishDate.TISHREI, 10).isYomKippur(), isTrue);
    expect(day(5785, JewishDate.TISHREI, 9).isYomKippur(), isFalse);
  });

  test('Succos: Yom Tov, Chol Hamoed and Hoshana Rabba, not Shemini Atzeres', () {
    for (final d in [15, 17, 21]) {
      expect(day(5785, JewishDate.TISHREI, d).isSuccos(), isTrue, reason: '$d Tishrei');
    }
    expect(day(5785, JewishDate.TISHREI, 14).isSuccos(), isFalse);
    expect(day(5785, JewishDate.TISHREI, 22).isSuccos(), isFalse);
  });

  test('Hoshana Rabba: 21 Tishrei', () {
    expect(day(5785, JewishDate.TISHREI, 21).isHoshanaRabba(), isTrue);
    expect(day(5785, JewishDate.TISHREI, 20).isHoshanaRabba(), isFalse);
  });

  test('Shemini Atzeres and Simchas Torah outside Israel', () {
    expect(day(5785, JewishDate.TISHREI, 22).isShminiAtzeres(), isTrue);
    expect(day(5785, JewishDate.TISHREI, 23).isSimchasTorah(), isTrue);
    expect(day(5785, JewishDate.TISHREI, 23).isShminiAtzeres(), isFalse);
  });

  test('in Israel 22 Tishrei is Shemini Atzeres and there is no separate Simchas Torah', () {
    expect(day(5785, JewishDate.TISHREI, 22, inIsrael: true).isShminiAtzeres(), isTrue);
    expect(day(5785, JewishDate.TISHREI, 22, inIsrael: true).isSimchasTorah(), isFalse);
    expect(day(5785, JewishDate.TISHREI, 23, inIsrael: true).isSimchasTorah(), isFalse);
  });

  test('Pesach: Yom Tov and Chol Hamoed, not Erev Pesach', () {
    expect(day(5784, JewishDate.NISSAN, 15).isPesach(), isTrue);
    expect(day(5784, JewishDate.NISSAN, 18).isPesach(), isTrue);
    expect(day(5784, JewishDate.NISSAN, 22).isPesach(), isTrue);
    expect(day(5784, JewishDate.NISSAN, 22, inIsrael: true).isPesach(), isFalse);
    expect(day(5784, JewishDate.NISSAN, 14).isPesach(), isFalse);
  });

  test('Shavuos: 6 Sivan, and 7 Sivan outside Israel only', () {
    expect(day(5784, JewishDate.SIVAN, 6).isShavuos(), isTrue);
    expect(day(5784, JewishDate.SIVAN, 7).isShavuos(), isTrue);
    expect(day(5784, JewishDate.SIVAN, 7, inIsrael: true).isShavuos(), isFalse);
    expect(day(5784, JewishDate.SIVAN, 5).isShavuos(), isFalse);
  });

  test('Tisha Be\'Av: 9 Av, or 10 Av when the 9th is Shabbos', () {
    expect(day(5784, JewishDate.AV, 9).isTishaBav(), isTrue);
    // 9 Av 5782 was on Shabbos, so the fast was on Sunday 10 Av.
    expect(day(5782, JewishDate.AV, 9).isTishaBav(), isFalse);
    expect(day(5782, JewishDate.AV, 10).isTishaBav(), isTrue);
  });
}
