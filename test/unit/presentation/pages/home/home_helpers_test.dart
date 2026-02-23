import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/pages/home/home_helpers.dart';

void main() {
  group('buildGreeting', () {
    test('returns morning greeting before 12:00', () {
      final morning = DateTime(2024, 1, 15, 8, 30);
      expect(buildGreeting('Alice', morning), 'Good morning, Alice!');
    });

    test('returns morning greeting at 00:00', () {
      final midnight = DateTime(2024, 1, 15, 0, 0);
      expect(buildGreeting('Bob', midnight), 'Good morning, Bob!');
    });

    test('returns afternoon greeting at 12:00', () {
      final noon = DateTime(2024, 1, 15, 12, 0);
      expect(buildGreeting('Charlie', noon), 'Good afternoon, Charlie!');
    });

    test('returns afternoon greeting at 16:59', () {
      final lateAfternoon = DateTime(2024, 1, 15, 16, 59);
      expect(buildGreeting('Diana', lateAfternoon), 'Good afternoon, Diana!');
    });

    test('returns evening greeting at 17:00', () {
      final evening = DateTime(2024, 1, 15, 17, 0);
      expect(buildGreeting('Eve', evening), 'Good evening, Eve!');
    });

    test('returns evening greeting at 23:59', () {
      final lateNight = DateTime(2024, 1, 15, 23, 59);
      expect(buildGreeting('Frank', lateNight), 'Good evening, Frank!');
    });
  });
}
