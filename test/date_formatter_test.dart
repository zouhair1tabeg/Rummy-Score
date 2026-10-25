import 'package:flutter_test/flutter_test.dart';
import 'package:rummy_score/utils/date_formatter.dart';

void main() {
  test('AppDateFormatter formats date and time safely without throwing', () {
    final testDate = DateTime(2026, 10, 25, 14, 30);

    final formattedDate = AppDateFormatter.formatGameDate(testDate);
    expect(formattedDate, contains('25'));
    expect(formattedDate, contains('2026'));
    expect(formattedDate, contains('14:30'));

    final formattedTime = AppDateFormatter.formatTime(testDate);
    expect(formattedTime, '14:30');
  });
}
