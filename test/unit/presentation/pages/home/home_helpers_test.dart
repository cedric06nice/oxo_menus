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

  group('computeGridColumns', () {
    test('returns 1 column for width below 400', () {
      expect(computeGridColumns(399), 1);
    });

    test('returns 2 columns for width exactly 400', () {
      expect(computeGridColumns(400), 2);
    });

    test('returns 2 columns for width 900', () {
      expect(computeGridColumns(900), 2);
    });

    test('returns 3 columns for width above 900', () {
      expect(computeGridColumns(901), 3);
    });

    test('returns 1 column for very small width', () {
      expect(computeGridColumns(200), 1);
    });

    test('returns 3 columns for very large width', () {
      expect(computeGridColumns(1920), 3);
    });
  });
}
