import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';
import 'package:oxo_menus/domain/widgets/dish_to_share/dish_to_share_props.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';

void main() {
  group('DishToShareProps', () {
    group('creation', () {
      test('creates with required fields and defaults', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);

        expect(props.name, 'Mezze Platter');
        expect(props.price, 18.50);
        expect(props.description, isNull);
        expect(props.calories, isNull);
        expect(props.allergenInfo, isEmpty);
        expect(props.dietary, isNull);
        expect(props.servings, isNull);
      });

      test('creates with all fields', () {
        const props = DishToShareProps(
          name: 'Sharing Board',
          price: 24.00,
          description: 'A selection of cured meats',
          calories: 850,
          allergenInfo: [],
          dietary: DietaryType.vegetarian,
          servings: 4,
        );

        expect(props.name, 'Sharing Board');
        expect(props.price, 24.00);
        expect(props.description, 'A selection of cured meats');
        expect(props.calories, 850);
        expect(props.dietary, DietaryType.vegetarian);
        expect(props.servings, 4);
      });
    });

    group('JSON serialization', () {
      test('round-trips with servings', () {
        const original = DishToShareProps(
          name: 'Mezze',
          price: 18.50,
          servings: 3,
          dietary: DietaryType.vegan,
        );

        final json = original.toJson();
        final restored = DishToShareProps.fromJson(json);

        expect(restored, original);
        expect(restored.servings, 3);
      });

      test('round-trips with null servings', () {
        const original = DishToShareProps(name: 'Board', price: 20.00);

        final json = original.toJson();
        final restored = DishToShareProps.fromJson(json);

        expect(restored, original);
        expect(restored.servings, isNull);
      });

      test('fromJson handles missing servings key', () {
        final json = {'name': 'Board', 'price': 20.0};
        final props = DishToShareProps.fromJson(json);

        expect(props.servings, isNull);
      });
    });

    group('servingsLabel', () {
      test('returns empty string when servings is null', () {
        const props = DishToShareProps(name: 'Test', price: 10.0);
        expect(props.servingsLabel, '');
      });

      test('returns empty string when servings is 0', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 0);
        expect(props.servingsLabel, '');
      });

      test('returns empty string when servings is 1', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 1);
        expect(props.servingsLabel, '');
      });

      test('returns "For Two" when servings is 2', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 2);
        expect(props.servingsLabel, 'For Two');
      });

      test('returns "For Three" when servings is 3', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 3);
        expect(props.servingsLabel, 'For Three');
      });

      test('returns "For Four" when servings is 4', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 4);
        expect(props.servingsLabel, 'For Four');
      });

      test('returns "For Five" when servings is 5', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 5);
        expect(props.servingsLabel, 'For Five');
      });

      test('returns "For Six" when servings is 6', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 6);
        expect(props.servingsLabel, 'For Six');
      });

      test('returns "For Seven" when servings is 7', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 7);
        expect(props.servingsLabel, 'For Seven');
      });

      test('returns "For Eight" when servings is 8', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 8);
        expect(props.servingsLabel, 'For Eight');
      });

      test('returns "For Nine" when servings is 9', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 9);
        expect(props.servingsLabel, 'For Nine');
      });

      test('returns "For Ten" when servings is 10', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 10);
        expect(props.servingsLabel, 'For Ten');
      });

      test('returns "For 12" as fallback for servings > 10', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 12);
        expect(props.servingsLabel, 'For 12');
      });
    });

    group('sharingText', () {
      test('returns "To Share" when servings is null', () {
        const props = DishToShareProps(name: 'Test', price: 10.0);
        expect(props.sharingText, 'To Share');
      });

      test('returns "To Share" when servings is 0', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 0);
        expect(props.sharingText, 'To Share');
      });

      test('returns "To Share" when servings is 1', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 1);
        expect(props.sharingText, 'To Share');
      });

      test('returns "For Two To Share" when servings is 2', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 2);
        expect(props.sharingText, 'For Two To Share');
      });

      test('returns "For Four To Share" when servings is 4', () {
        const props = DishToShareProps(name: 'Test', price: 10.0, servings: 4);
        expect(props.sharingText, 'For Four To Share');
      });
    });

    group('displayName', () {
      test('returns uppercased name without dietary', () {
        const props = DishToShareProps(name: 'Mezze Platter', price: 18.50);
        expect(props.displayName, 'MEZZE PLATTER');
      });

      test('returns uppercased name with dietary abbreviation', () {
        const props = DishToShareProps(
          name: 'Mezze Platter',
          price: 18.50,
          dietary: DietaryType.vegan,
        );
        expect(props.displayName, 'MEZZE PLATTER (Ve)');
      });

      test('returns uppercased name with vegetarian abbreviation', () {
        const props = DishToShareProps(
          name: 'Sharing Board',
          price: 24.00,
          dietary: DietaryType.vegetarian,
        );
        expect(props.displayName, 'SHARING BOARD (V)');
      });
    });

    group('allergenInfo', () {
      test('stores structured allergens', () {
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

      test('defaults to empty list', () {
        const props = DishToShareProps(name: 'Test', price: 10.0);
        expect(props.allergenInfo, isEmpty);
      });
    });

    group('equality', () {
      test('two props with same values are equal', () {
        const a = DishToShareProps(name: 'Test', price: 10.0, servings: 2);
        const b = DishToShareProps(name: 'Test', price: 10.0, servings: 2);
        expect(a, b);
      });

      test('two props with different servings are not equal', () {
        const a = DishToShareProps(name: 'Test', price: 10.0, servings: 2);
        const b = DishToShareProps(name: 'Test', price: 10.0, servings: 4);
        expect(a, isNot(b));
      });
    });

    group('copyWith', () {
      test('copies with new servings', () {
        const original = DishToShareProps(
          name: 'Test',
          price: 10.0,
          servings: 2,
        );
        final copy = original.copyWith(servings: 6);

        expect(copy.servings, 6);
        expect(copy.name, 'Test');
        expect(copy.price, 10.0);
      });
    });
  });
}
