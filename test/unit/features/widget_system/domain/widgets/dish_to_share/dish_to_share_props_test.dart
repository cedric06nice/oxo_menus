import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/allergens/domain/allergen_info.dart';
import 'package:oxo_menus/features/allergens/domain/uk_allergen.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/dish_to_share/dish_to_share_props.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/dietary_type.dart';

void main() {
  group('DishToShareProps', () {
    group('construction', () {
      test('should store name when constructed with a required name', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

        expect(props.name, 'Mezze Platter');
      });

      test('should store price when constructed with a required price', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

        expect(props.price, 18.50);
      });

      test('should have null description when none is provided', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

        expect(props.description, isNull);
      });

      test('should have null calories when none is provided', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

        expect(props.calories, isNull);
      });

      test('should have an empty allergenInfo list when none is provided', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

        expect(props.allergenInfo, isEmpty);
      });

      test('should have null dietary when none is provided', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

        expect(props.dietary, isNull);
      });

      test('should have null servings when none is provided', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

        expect(props.servings, isNull);
      });

      test('should store all optional fields when provided', () {
        const props = DishToShareProps(
          name: 'Sharing Board',
          price: 24.00,
          description: 'A selection of cured meats',
          calories: 850,
          allergenInfo: [],
          dietary: DietaryType.vegetarian,
          servings: 4,
        );

        expect(props.description, 'A selection of cured meats');
        expect(props.calories, 850);
        expect(props.dietary, DietaryType.vegetarian);
        expect(props.servings, 4);
      });

      test('should store allergenInfo when a non-empty list is provided', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.gluten),
          AllergenInfo(allergen: UkAllergen.milk),
        ];
        const props = DishToShareProps(
          name: 'Test',
          price: 10.0,
          allergenInfo: allergens,
        );

        expect(props.allergenInfo, allergens);
      });
    });

    group('equality', () {
      test('should be equal when all fields are identical', () {
        const a = DishToShareProps(name: 'Test', price: 10.0, servings: 2);
        const b = DishToShareProps(name: 'Test', price: 10.0, servings: 2);

        expect(a, equals(b));
      });

      test('should not be equal when servings differ', () {
        const a = DishToShareProps(name: 'Test', price: 10.0, servings: 2);
        const b = DishToShareProps(name: 'Test', price: 10.0, servings: 4);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when names differ', () {
        const a = DishToShareProps(name: 'Platter', price: 10.0);
        const b = DishToShareProps(name: 'Board', price: 10.0);

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('should be the same for two instances with identical fields', () {
        const a = DishToShareProps(name: 'Test', price: 10.0, servings: 2);
        const b = DishToShareProps(name: 'Test', price: 10.0, servings: 2);

        expect(a.hashCode, b.hashCode);
      });
    });

    group('copyWith', () {
      test(
        'should update servings when copyWith is called with a new value',
        () {
          const original = DishToShareProps(
            name: 'Test',
            price: 10.0,
            servings: 2,
          );

          final copy = original.copyWith(servings: 6);

          expect(copy.servings, 6);
        },
      );

      test('should preserve name when copyWith only changes servings', () {
        const original = DishToShareProps(
          name: 'Test',
          price: 10.0,
          servings: 2,
        );

        final copy = original.copyWith(servings: 6);

        expect(copy.name, 'Test');
      });

      test('should preserve price when copyWith only changes servings', () {
        const original = DishToShareProps(
          name: 'Test',
          price: 10.0,
          servings: 2,
        );

        final copy = original.copyWith(servings: 6);

        expect(copy.price, 10.0);
      });

      test('should not mutate the original when copyWith is called', () {
        const original = DishToShareProps(
          name: 'Test',
          price: 10.0,
          servings: 2,
        );

        final _ = original.copyWith(servings: 8);

        expect(original.servings, 2);
      });
    });

    group('servingsLabel', () {
      test('should return empty string when servings is null', () {
        const props = DishToShareProps(name: 'Test', price: 10.0);

        expect(props.servingsLabel, '');
      });

      test('should return empty string when servings is 0', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 0);

        expect(props.servingsLabel, '');
      });

      test('should return empty string when servings is 1', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 1);

        expect(props.servingsLabel, '');
      });

      test('should return For Two when servings is 2', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 2);

        expect(props.servingsLabel, 'For Two');
      });

      test('should return For Three when servings is 3', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 3);

        expect(props.servingsLabel, 'For Three');
      });

      test('should return For Four when servings is 4', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 4);

        expect(props.servingsLabel, 'For Four');
      });

      test('should return For Five when servings is 5', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 5);

        expect(props.servingsLabel, 'For Five');
      });

      test('should return For Six when servings is 6', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 6);

        expect(props.servingsLabel, 'For Six');
      });

      test('should return For Seven when servings is 7', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 7);

        expect(props.servingsLabel, 'For Seven');
      });

      test('should return For Eight when servings is 8', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 8);

        expect(props.servingsLabel, 'For Eight');
      });

      test('should return For Nine when servings is 9', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 9);

        expect(props.servingsLabel, 'For Nine');
      });

      test('should return For Ten when servings is 10', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 10);

        expect(props.servingsLabel, 'For Ten');
      });

      test(
        'should use numeric fallback when servings exceeds the word dictionary',
        () {
          const props = DishToShareProps(
            name: 'Test',
            price: 10.0,
            servings: 12,
          );

          expect(props.servingsLabel, 'For 12');
        },
      );

      test('should use numeric fallback for servings value 11', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 11);

        expect(props.servingsLabel, 'For 11');
      });
    });

    group('sharingText', () {
      test('should return To Share when servings is null', () {
        const props = DishToShareProps(name: 'Test', price: 10.0);

        expect(props.sharingText, 'To Share');
      });

      test('should return To Share when servings is 0', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 0);

        expect(props.sharingText, 'To Share');
      });

      test('should return To Share when servings is 1', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 1);

        expect(props.sharingText, 'To Share');
      });

      test('should return For Two To Share when servings is 2', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 2);

        expect(props.sharingText, 'For Two To Share');
      });

      test('should return For Four To Share when servings is 4', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 4);

        expect(props.sharingText, 'For Four To Share');
      });

      test(
        'should compose numeric fallback with To Share when servings exceeds dictionary',
        () {
          const props = DishToShareProps(
            name: 'Test',
            price: 10.0,
            servings: 12,
          );

          expect(props.sharingText, 'For 12 To Share');
        },
      );
    });

    group('displayName', () {
      test('should return uppercased name when no dietary is set', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

        expect(props.displayName, 'MEZZE PLATTER');
      });

      test('should append (Ve) abbreviation when dietary is vegan', () {
        const props = DishToShareProps(
          name: 'Mezze Platter',
          price: 18.50,
          dietary: DietaryType.vegan,
        );

        expect(props.displayName, 'MEZZE PLATTER (Ve)');
      });

      test('should append (V) abbreviation when dietary is vegetarian', () {
        const props = DishToShareProps(
          name: 'Sharing Board',
          price: 24.00,
          dietary: DietaryType.vegetarian,
        );

        expect(props.displayName, 'SHARING BOARD (V)');
      });

      test(
        'should return empty string when name is empty and no dietary set',
        () {
          const props = DishToShareProps(name: '', price: 10.0);

          expect(props.displayName, '');
        },
      );
    });

    group('JSON round-trip', () {
      test('should be equal to the original after toJson then fromJson', () {
        const original = DishToShareProps(
          name: 'Mezze',
          price: 18.50,
          servings: 3,
          dietary: DietaryType.vegan,
        );

        final json = original.toJson();
        final restored = DishToShareProps.fromJson(json);

        expect(restored, equals(original));
      });

      test('should preserve servings value after round-trip', () {
        const original = DishToShareProps(
          name: 'Mezze',
          price: 18.50,
          servings: 3,
        );

        final json = original.toJson();
        final restored = DishToShareProps.fromJson(json);

        expect(restored.servings, 3);
      });

      test('should preserve null servings after round-trip', () {
        const original = DishToShareProps(name: 'Board', price: 20.00);

        final json = original.toJson();
        final restored = DishToShareProps.fromJson(json);

        expect(restored.servings, isNull);
      });

      test(
        'should handle missing servings key in JSON by defaulting to null',
        () {
          final json = {'name': 'Board', 'price': 20.0};

          final props = DishToShareProps.fromJson(json);

          expect(props.servings, isNull);
        },
      );

      test('should round-trip a GBP price with fractional pence correctly', () {
        const original = DishToShareProps(name: 'Platter', price: 18.99);

        final json = original.toJson();
        final restored = DishToShareProps.fromJson(json);

        expect(restored.price, 18.99);
      });
    });
  });
}
