// Run: dart run benchmark/jewish_date_navigation_benchmark.dart
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  const iterations = 1000;
  final sw = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    final date = JewishDate.fromDateTime(DateTime.utc(2024, 1, 1));
    date.forward(Calendar.DATE, 365);
    date.back(Calendar.DATE, 365);
  }
  sw.stop();
  print('Date navigation iterations: $iterations, '
      'elapsed microseconds: ${sw.elapsedMicroseconds}');
}
