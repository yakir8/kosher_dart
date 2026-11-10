import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void main() {
  group('long Omer formatting', () {
    test('all 49 days have a valid and distinct index', () {
      final formatter = HebrewDateFormatter()
        ..hebrewFormat = true
        ..longOmerFormat = true;
      final calendar = JewishCalendar()
        ..setJewishDate(5784, JewishDate.NISSAN, 16);
      final outputs = <String>[];
      for (var day = 1; day <= 49; day++) {
        expect(calendar.getDayOfOmer(), day);
        final output = formatter.formatOmer(calendar);
        expect(output, isNotEmpty);
        outputs.add(output);
        calendar.forward();
      }
      expect(outputs.toSet().length, 49);
      expect(outputs.first, contains('אֶחָד'));
      expect(outputs.last, contains('שִׁבְעָה שָׁבוּעוֹת'));
      expect(formatter.formatOmer(calendar), isEmpty);
    });
  });
}
