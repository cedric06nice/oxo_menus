import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/presentation/helpers/grid_helpers.dart';

void main() {
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
