import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/domain/widgets/dish/price_variant.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';

void main() {
  group('DishProps', () {
    group('construction', () {
      test('should store name when constructed with a required name', () {
        const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

        expect(props.name, 'Pasta Carbonara');
      });

      test('should store price when constructed with a required price', () {
        const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

        expect(props.price, 12.50);
      });

      test('should have null description when none is provided', () {
        const props = DishProps(name: 'Pasta', price: 10.0);

        expect(props.description, isNull);
      });

      test('should have null calories when none is provided', () {
        const props = DishProps(name: 'Pasta', price: 10.0);

        expect(props.calories, isNull);
      });

      test('should have an empty allergenInfo list when none is provided', () {
        const props = DishProps(name: 'Pasta', price: 10.0);

        expect(props.allergenInfo, isEmpty);
      });

      test('should have null dietary when none is provided', () {
        const props = DishProps(name: 'Pasta', price: 10.0);

        expect(props.dietary, isNull);
      });

      test('should have an empty priceVariants list when none is provided', () {
        const props = DishProps(name: 'Pasta', price: 10.0);

        expect(props.priceVariants, isEmpty);
      });

      test('should store description when one is provided', () {
        const props = DishProps(
          name: 'Pasta',
          price: 12.50,
          description: 'Classic Italian pasta',
        );

        expect(props.description, 'Classic Italian pasta');
      });

      test('should store calories when a value is provided', () {
        const props = DishProps(
          name: 'Pasta Carbonara',
          price: 12.50,
          calories: 350,
        );

        expect(props.calories, 350);
      });

      test('should store allergenInfo when a non-empty list is provided', () {
        const props = DishProps(
          name: 'Pasta',
          price: 12.50,
          allergenInfo: [
            AllergenInfo(allergen: UkAllergen.milk),
            AllergenInfo(allergen: UkAllergen.gluten),
          ],
        );

        expect(props.allergenInfo, hasLength(2));
      });

      test('should store dietary when a value is provided', () {
        const props = DishProps(
          name: 'Pasta',
          price: 12.50,
          dietary: DietaryType.vegetarian,
        );

        expect(props.dietary, DietaryType.vegetarian);
      });

      test('should store priceVariants when a non-empty list is provided', () {
        const props = DishProps(
          name: 'Oysters',
          price: 9.0,
          priceVariants: [
            PriceVariant(label: 'Per 3', price: 9.0),
            PriceVariant(label: 'Per 6', price: 17.0),
          ],
        );

        expect(props.priceVariants, hasLength(2));
      });
    });

    group('equality', () {
      test('should be equal when all fields are identical', () {
        const a = DishProps(
          name: 'Pasta',
          price: 12.50,
          allergenInfo: [AllergenInfo(allergen: UkAllergen.milk)],
        );
        const b = DishProps(
          name: 'Pasta',
          price: 12.50,
          allergenInfo: [AllergenInfo(allergen: UkAllergen.milk)],
        );

        expect(a, equals(b));
      });

      test('should not be equal when names differ', () {
        const a = DishProps(name: 'Pasta', price: 12.50);
        const b = DishProps(name: 'Pizza', price: 12.50);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when prices differ', () {
        const a = DishProps(name: 'Pasta', price: 10.0);
        const b = DishProps(name: 'Pasta', price: 12.0);

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('should be the same for two instances with identical fields', () {
        const a = DishProps(name: 'Pasta', price: 12.50);
        const b = DishProps(name: 'Pasta', price: 12.50);

        expect(a.hashCode, b.hashCode);
      });
    });

    group('copyWith', () {
      test('should update name when copyWith is called with a new name', () {
        const original = DishProps(name: 'Original', price: 10.0);

        final modified = original.copyWith(name: 'Modified');

        expect(modified.name, 'Modified');
      });

      test('should update price when copyWith is called with a new price', () {
        const original = DishProps(name: 'Pasta', price: 10.0);

        final modified = original.copyWith(price: 15.0);

        expect(modified.price, 15.0);
      });

      test(
        'should update calories when copyWith is called with a new value',
        () {
          const original = DishProps(name: 'Pasta', price: 10.0);

          final withCalories = original.copyWith(calories: 500);

          expect(withCalories.calories, 500);
        },
      );

      test('should clear calories when copyWith is called with null', () {
        const original = DishProps(name: 'Pasta', price: 10.0, calories: 400);

        final withoutCalories = original.copyWith(calories: null);

        expect(withoutCalories.calories, isNull);
      });

      test(
        'should update priceVariants when copyWith is called with new list',
        () {
          const original = DishProps(name: 'Dish', price: 10.0);

          final modified = original.copyWith(
            priceVariants: const [PriceVariant(label: 'Large', price: 14.0)],
          );

          expect(modified.priceVariants, hasLength(1));
          expect(modified.priceVariants.first.label, 'Large');
        },
      );

      test('should not mutate the original when copyWith is called', () {
        const original = DishProps(name: 'Original', price: 10.0);

        final _ = original.copyWith(name: 'Modified', price: 15.0);

        expect(original.name, 'Original');
        expect(original.price, 10.0);
      });
    });

    group('hasMultiplePrices', () {
      test('should be false when priceVariants is empty', () {
        const props = DishProps(name: 'Pasta', price: 12.50);

        expect(props.hasMultiplePrices, isFalse);
      });

      test('should be true when priceVariants contains entries', () {
        const props = DishProps(
          name: 'Oysters',
          price: 9.0,
          priceVariants: [
            PriceVariant(label: 'Per 3', price: 9.0),
            PriceVariant(label: 'Per 6', price: 17.0),
          ],
        );

        expect(props.hasMultiplePrices, isTrue);
      });
    });

    group('displayName', () {
      test('should return uppercased name when no dietary is set', () {
        const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

        expect(props.displayName, 'PASTA CARBONARA');
      });

      test('should append (V) abbreviation when dietary is vegetarian', () {
        const props = DishProps(
          name: 'Pasta Carbonara',
          price: 12.50,
          dietary: DietaryType.vegetarian,
        );

        expect(props.displayName, 'PASTA CARBONARA (V)');
      });

      test('should append (Ve) abbreviation when dietary is vegan', () {
        const props = DishProps(
          name: 'Garden Salad',
          price: 8.50,
          dietary: DietaryType.vegan,
        );

        expect(props.displayName, 'GARDEN SALAD (Ve)');
      });

      test(
        'should return empty string when name is empty and no dietary set',
        () {
          const props = DishProps(name: '', price: 0);

          expect(props.displayName, '');
        },
      );

      test(
        'should return space-prefixed abbreviation when name is empty and dietary is set',
        () {
          const props = DishProps(
            name: '',
            price: 0,
            dietary: DietaryType.vegan,
          );

          expect(props.displayName, ' (Ve)');
        },
      );
    });

    group('JSON round-trip', () {
      test('should serialise name as a string key in the JSON map', () {
        const props = DishProps(name: 'Pasta Carbonara', price: 12.50);

        final json = props.toJson();

        expect(json['name'], 'Pasta Carbonara');
      });

      test('should serialise price as a numeric key in the JSON map', () {
        const props = DishProps(name: 'Pasta', price: 12.50);

        final json = props.toJson();

        expect(json['price'], 12.50);
      });

      test(
        'should serialise dietary as a lowercase string in the JSON map',
        () {
          const props = DishProps(
            name: 'Pasta',
            price: 12.50,
            dietary: DietaryType.vegetarian,
          );

          final json = props.toJson();

          expect(json['dietary'], 'vegetarian');
        },
      );

      test('should serialise allergenInfo as a JSON list', () {
        const props = DishProps(
          name: 'Pasta',
          price: 12.50,
          allergenInfo: [AllergenInfo(allergen: UkAllergen.milk)],
        );

        final json = props.toJson();

        expect(json['allergenInfo'], isA<List<dynamic>>());
        expect((json['allergenInfo'] as List), hasLength(1));
      });

      test('should be equal to the original after toJson then fromJson', () {
        const original = DishProps(
          name: 'Pasta Carbonara',
          price: 12.50,
          description: 'Classic Italian pasta',
          allergenInfo: [AllergenInfo(allergen: UkAllergen.milk)],
          dietary: DietaryType.vegetarian,
        );

        final json = original.toJson();
        final restored = DishProps.fromJson(json);

        expect(restored, equals(original));
      });

      test('should round-trip a vegan dish with no allergens correctly', () {
        const original = DishProps(
          name: 'Vegan Salad',
          price: 9.50,
          dietary: DietaryType.vegan,
        );

        final json = original.toJson();
        final restored = DishProps.fromJson(json);

        expect(restored, equals(original));
      });

      test('should round-trip allergens with multiple entries correctly', () {
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
        final restored = DishProps.fromJson(json);

        expect(restored, equals(original));
      });

      test('should round-trip calories when present', () {
        const original = DishProps(
          name: 'Pasta Carbonara',
          price: 12.50,
          calories: 450,
        );

        final json = original.toJson();
        final restored = DishProps.fromJson(json);

        expect(restored.calories, 450);
      });

      test('should round-trip null calories correctly', () {
        const original = DishProps(name: 'Pasta Carbonara', price: 12.50);

        final json = original.toJson();
        final restored = DishProps.fromJson(json);

        expect(restored.calories, isNull);
      });

      test('should round-trip priceVariants when present', () {
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
        final restored = DishProps.fromJson(json);

        expect(restored, equals(original));
      });

      test(
        'should produce empty priceVariants list when key is absent in JSON',
        () {
          final json = {'name': 'Dish', 'price': 11.0};

          final props = DishProps.fromJson(json);

          expect(props.priceVariants, isEmpty);
        },
      );

      test('should handle null dietary in JSON by using null', () {
        final json = {
          'name': 'Dish',
          'price': 10.0,
          'allergenInfo': <Map<String, dynamic>>[],
          'dietary': null,
        };

        final props = DishProps.fromJson(json);

        expect(props.dietary, isNull);
      });

      test('should handle null description in JSON by using null', () {
        final json = {'name': 'Dish', 'price': 10.0, 'description': null};

        final props = DishProps.fromJson(json);

        expect(props.description, isNull);
      });

      test(
        'should use default empty allergenInfo when key is absent from JSON',
        () {
          final json = {'name': 'Simple Dish', 'price': 10.0};

          final props = DishProps.fromJson(json);

          expect(props.allergenInfo, isEmpty);
        },
      );
    });
  });
}
