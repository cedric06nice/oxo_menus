import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widgets/dish/price_variant.dart';

void main() {
  group('DishProps', () {
    test('should create DishProps with required fields', () {
      const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

      expect(props.name, 'Pasta Carbonara');
      expect(props.price, 12.50);
      expect(props.description, isNull);
      expect(props.allergenInfo, isEmpty);
      expect(props.dietary, isNull);
    });

    test('should create DishProps with all fields', () {
      const props = DishProps(
        name: 'Pasta Carbonara',
        price: 12.50,
        description: 'Classic Italian pasta',
        allergenInfo: [
          AllergenInfo(allergen: UkAllergen.milk),
          AllergenInfo(allergen: UkAllergen.gluten),
        ],
        dietary: DietaryType.vegetarian,
      );

      expect(props.name, 'Pasta Carbonara');
      expect(props.price, 12.50);
      expect(props.description, 'Classic Italian pasta');
      expect(props.allergenInfo, hasLength(2));
      expect(props.dietary, DietaryType.vegetarian);
    });

    test('should serialize to JSON', () {
      const props = DishProps(
        name: 'Pasta Carbonara',
        price: 12.50,
        description: 'Classic Italian pasta',
        allergenInfo: [AllergenInfo(allergen: UkAllergen.milk)],
        dietary: DietaryType.vegetarian,
      );

      final json = props.toJson();

      expect(json['name'], 'Pasta Carbonara');
      expect(json['price'], 12.50);
      expect(json['description'], 'Classic Italian pasta');
      expect(json['allergenInfo'], isA<List<dynamic>>());
      expect((json['allergenInfo'] as List).length, 1);
      expect(json['dietary'], 'vegetarian');
    });

    test('should deserialize from JSON', () {
      final json = {
        'name': 'Pasta Carbonara',
        'price': 12.50,
        'description': 'Classic Italian pasta',
        'allergenInfo': [
          {'allergen': 'milk'},
          {'allergen': 'gluten'},
        ],
        'dietary': 'vegetarian',
      };

      final props = DishProps.fromJson(json);

      expect(props.name, 'Pasta Carbonara');
      expect(props.price, 12.50);
      expect(props.description, 'Classic Italian pasta');
      expect(props.allergenInfo, hasLength(2));
      expect(props.allergenInfo.first.allergen, UkAllergen.milk);
      expect(props.dietary, DietaryType.vegetarian);
    });

    test('should deserialize from JSON with defaults', () {
      final json = {'name': 'Simple Dish', 'price': 10.0};

      final props = DishProps.fromJson(json);

      expect(props.name, 'Simple Dish');
      expect(props.price, 10.0);
      expect(props.description, isNull);
      expect(props.allergenInfo, isEmpty);
      expect(props.dietary, isNull);
    });

    test('should support copyWith', () {
      const original = DishProps(name: 'Original', price: 10.0);

      final modified = original.copyWith(name: 'Modified', price: 15.0);

      expect(original.name, 'Original');
      expect(original.price, 10.0);
      expect(modified.name, 'Modified');
      expect(modified.price, 15.0);
    });

    test('should support equality', () {
      const props1 = DishProps(
        name: 'Pasta',
        price: 12.50,
        allergenInfo: [AllergenInfo(allergen: UkAllergen.milk)],
      );

      const props2 = DishProps(
        name: 'Pasta',
        price: 12.50,
        allergenInfo: [AllergenInfo(allergen: UkAllergen.milk)],
      );

      const props3 = DishProps(name: 'Pizza', price: 12.50);

      expect(props1, equals(props2));
      expect(props1, isNot(equals(props3)));
    });

    test('should handle null dietary in JSON', () {
      final json = {
        'name': 'Dish',
        'price': 10.0,
        'allergenInfo': <Map<String, dynamic>>[],
        'dietary': null,
      };

      final props = DishProps.fromJson(json);

      expect(props.allergenInfo, isEmpty);
      expect(props.dietary, isNull);
    });

    test('should handle null description in JSON', () {
      final json = {'name': 'Dish', 'price': 10.0, 'description': null};

      final props = DishProps.fromJson(json);

      expect(props.description, isNull);
    });

    test('should round-trip through JSON with dietary', () {
      const original = DishProps(
        name: 'Vegan Salad',
        price: 9.50,
        dietary: DietaryType.vegan,
      );

      final json = original.toJson();
      final deserialized = DishProps.fromJson(json);

      expect(deserialized, equals(original));
    });

    test('should round-trip through JSON without dietary', () {
      const original = DishProps(
        name: 'Test Dish',
        price: 19.99,
        description: 'A test description',
        allergenInfo: [
          AllergenInfo(allergen: UkAllergen.nuts),
          AllergenInfo(allergen: UkAllergen.soya),
        ],
      );

      final json = original.toJson();
      final deserialized = DishProps.fromJson(json);

      expect(deserialized, equals(original));
    });

    group('calories', () {
      test('should create DishProps with calories value', () {
        const props = DishProps(
          name: 'Pasta Carbonara',
          price: 12.50,
          calories: 350,
        );

        expect(props.calories, 350);
      });

      test('should round-trip through JSON with calories', () {
        const original = DishProps(
          name: 'Pasta Carbonara',
          price: 12.50,
          calories: 450,
        );

        final json = original.toJson();
        final deserialized = DishProps.fromJson(json);

        expect(deserialized, equals(original));
        expect(deserialized.calories, 450);
      });

      test('should round-trip through JSON without calories (null)', () {
        const original = DishProps(name: 'Pasta Carbonara', price: 12.50);

        final json = original.toJson();
        final deserialized = DishProps.fromJson(json);

        expect(deserialized, equals(original));
        expect(deserialized.calories, isNull);
      });

      test('should support copyWith for calories', () {
        const original = DishProps(name: 'Pasta', price: 10.0);

        final withCalories = original.copyWith(calories: 500);
        expect(withCalories.calories, 500);

        final withoutCalories = withCalories.copyWith(calories: null);
        expect(withoutCalories.calories, isNull);
      });
    });

    group('displayName', () {
      test('should return uppercased name when no dietary', () {
        const props = DishProps(name: 'Pasta Carbonara', price: 12.50);
        expect(props.displayName, 'PASTA CARBONARA');
      });

      test('should append (V) for vegetarian', () {
        const props = DishProps(
          name: 'Pasta Carbonara',
          price: 12.50,
          dietary: DietaryType.vegetarian,
        );
        expect(props.displayName, 'PASTA CARBONARA (V)');
      });

      test('should append (Ve) for vegan', () {
        const props = DishProps(
          name: 'Garden Salad',
          price: 8.50,
          dietary: DietaryType.vegan,
        );
        expect(props.displayName, 'GARDEN SALAD (Ve)');
      });

      test('should handle empty name', () {
        const props = DishProps(name: '', price: 0);
        expect(props.displayName, '');
      });

      test('should handle empty name with dietary', () {
        const props = DishProps(name: '', price: 0, dietary: DietaryType.vegan);
        expect(props.displayName, ' (Ve)');
      });
    });

    group('priceVariants', () {
      test('defaults to an empty list', () {
        const props = DishProps(name: 'Pasta', price: 12.50);

        expect(props.priceVariants, isEmpty);
        expect(props.hasMultiplePrices, isFalse);
      });

      test('hasMultiplePrices is true when variants are set', () {
        const props = DishProps(
          name: 'Oysters',
          price: 9.0,
          priceVariants: [
            PriceVariant(label: 'Per 3', price: 9.0),
            PriceVariant(label: 'Per 6', price: 17.0),
          ],
        );

        expect(props.hasMultiplePrices, isTrue);
        expect(props.priceVariants.length, 2);
      });

      test('round-trips through JSON with variants', () {
        const original = DishProps(
          name: 'Oysters',
          price: 9.0,
          priceVariants: [
            PriceVariant(label: 'Per 3', price: 9.0),
            PriceVariant(label: 'Per 6', price: 17.0),
            PriceVariant(label: 'Per 9', price: 24.0),
          ],
        );

        final json = original.toJson();
        final deserialized = DishProps.fromJson(json);

        expect(json['priceVariants'], isA<List<dynamic>>());
        expect((json['priceVariants'] as List).length, 3);
        expect(deserialized, equals(original));
      });

      test('deserializes JSON without priceVariants as an empty list', () {
        final json = {'name': 'Dish', 'price': 11.0};

        final props = DishProps.fromJson(json);

        expect(props.priceVariants, isEmpty);
        expect(props.hasMultiplePrices, isFalse);
      });

      test('copyWith updates priceVariants independently', () {
        const original = DishProps(name: 'Dish', price: 10.0);

        final modified = original.copyWith(
          priceVariants: const [PriceVariant(label: 'Large', price: 14.0)],
        );

        expect(original.priceVariants, isEmpty);
        expect(modified.priceVariants.length, 1);
        expect(modified.priceVariants.first.label, 'Large');
      });
    });
  });
}
