import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';

void main() {
  group('DietaryType', () {
    group('values', () {
      test('should contain exactly two values', () {
        expect(DietaryType.values.length, 2);
      });

      test('should include vegetarian', () {
        expect(DietaryType.values, contains(DietaryType.vegetarian));
      });

      test('should include vegan', () {
        expect(DietaryType.values, contains(DietaryType.vegan));
      });
    });

    group('displayName', () {
      test('should return Vegetarian when type is vegetarian', () {
        expect(DietaryType.vegetarian.displayName, 'Vegetarian');
      });

      test('should return Vegan when type is vegan', () {
        expect(DietaryType.vegan.displayName, 'Vegan');
      });
    });

    group('abbreviation', () {
      test('should return (V) when type is vegetarian', () {
        expect(DietaryType.vegetarian.abbreviation, '(V)');
      });

      test('should return (Ve) when type is vegan', () {
        expect(DietaryType.vegan.abbreviation, '(Ve)');
      });
    });

    group('fromString', () {
      test('should return vegetarian when input is vegetarian', () {
        expect(DietaryType.fromString('vegetarian'), DietaryType.vegetarian);
      });

      test('should return vegan when input is vegan', () {
        expect(DietaryType.fromString('vegan'), DietaryType.vegan);
      });

      test('should return vegetarian when input is uppercase VEGETARIAN', () {
        expect(DietaryType.fromString('VEGETARIAN'), DietaryType.vegetarian);
      });

      test('should return vegan when input is uppercase VEGAN', () {
        expect(DietaryType.fromString('VEGAN'), DietaryType.vegan);
      });

      test('should return vegetarian when input is mixed-case Vegetarian', () {
        expect(DietaryType.fromString('Vegetarian'), DietaryType.vegetarian);
      });

      test('should return vegetarian when input has leading/trailing whitespace',
          () {
        expect(DietaryType.fromString('  vegetarian  '), DietaryType.vegetarian);
      });

      test('should return null when input is an unrecognised string', () {
        expect(DietaryType.fromString('gluten-free'), isNull);
      });

      test('should return null when input is an empty string', () {
        expect(DietaryType.fromString(''), isNull);
      });

      test('should return null when input is a partial match', () {
        expect(DietaryType.fromString('veg'), isNull);
      });
    });
  });
}
