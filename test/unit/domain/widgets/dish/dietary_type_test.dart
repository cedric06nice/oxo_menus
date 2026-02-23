import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';

void main() {
  group('DietaryType', () {
    test('should have exactly two values', () {
      expect(DietaryType.values.length, 2);
    });

    test('vegetarian should have correct displayName', () {
      expect(DietaryType.vegetarian.displayName, 'Vegetarian');
    });

    test('vegan should have correct displayName', () {
      expect(DietaryType.vegan.displayName, 'Vegan');
    });

    test('vegetarian should have abbreviation (V)', () {
      expect(DietaryType.vegetarian.abbreviation, '(V)');
    });

    test('vegan should have abbreviation (Ve)', () {
      expect(DietaryType.vegan.abbreviation, '(Ve)');
    });

    test('fromString should parse vegetarian', () {
      expect(DietaryType.fromString('vegetarian'), DietaryType.vegetarian);
    });

    test('fromString should parse vegan', () {
      expect(DietaryType.fromString('vegan'), DietaryType.vegan);
    });

    test('fromString should return null for unknown value', () {
      expect(DietaryType.fromString('gluten-free'), isNull);
    });

    test('fromString should be case-insensitive', () {
      expect(DietaryType.fromString('Vegetarian'), DietaryType.vegetarian);
      expect(DietaryType.fromString('VEGAN'), DietaryType.vegan);
    });
  });
}
