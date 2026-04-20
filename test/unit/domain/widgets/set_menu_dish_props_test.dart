import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';
import 'package:oxo_menus/domain/widgets/set_menu_dish/set_menu_dish_props.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';

void main() {
  group('SetMenuDishProps', () {
    group('creation', () {
      test('creates with required fields and defaults', () {
        const props = SetMenuDishProps(name: 'Beef Wellington');

        expect(props.name, 'Beef Wellington');
        expect(props.description, isNull);
        expect(props.calories, isNull);
        expect(props.allergenInfo, isEmpty);
        expect(props.dietary, isNull);
        expect(props.hasSupplement, false);
        expect(props.supplementPrice, 0.0);
      });

      test('creates with all fields', () {
        const props = SetMenuDishProps(
          name: 'Lobster Thermidor',
          description: 'Classic French lobster dish',
          calories: 650,
          allergenInfo: [],
          dietary: DietaryType.vegetarian,
          hasSupplement: true,
          supplementPrice: 7.5,
        );

        expect(props.name, 'Lobster Thermidor');
        expect(props.description, 'Classic French lobster dish');
        expect(props.calories, 650);
        expect(props.dietary, DietaryType.vegetarian);
        expect(props.hasSupplement, true);
        expect(props.supplementPrice, 7.5);
      });
    });

    group('JSON serialization', () {
      test('round-trips with supplement', () {
        const original = SetMenuDishProps(
          name: 'Lobster',
          hasSupplement: true,
          supplementPrice: 5.0,
          dietary: DietaryType.vegan,
        );

        final json = original.toJson();
        final restored = SetMenuDishProps.fromJson(json);

        expect(restored, original);
        expect(restored.hasSupplement, true);
        expect(restored.supplementPrice, 5.0);
      });

      test('round-trips without supplement', () {
        const original = SetMenuDishProps(name: 'Soup of the Day');

        final json = original.toJson();
        final restored = SetMenuDishProps.fromJson(json);

        expect(restored, original);
        expect(restored.hasSupplement, false);
        expect(restored.supplementPrice, 0.0);
      });

      test('fromJson handles missing optional keys', () {
        final json = {'name': 'Simple Dish'};
        final props = SetMenuDishProps.fromJson(json);

        expect(props.name, 'Simple Dish');
        expect(props.hasSupplement, false);
        expect(props.supplementPrice, 0.0);
        expect(props.description, isNull);
        expect(props.calories, isNull);
        expect(props.dietary, isNull);
      });
    });

    group('supplementText', () {
      test('returns empty string when hasSupplement is false', () {
        const props = SetMenuDishProps(name: 'Test');
        expect(props.supplementText, '');
      });

      test(
        'returns empty string when hasSupplement is true but price is 0',
        () {
          const props = SetMenuDishProps(
            name: 'Test',
            hasSupplement: true,
            supplementPrice: 0.0,
          );
          expect(props.supplementText, '');
        },
      );

      test('returns "Supplement 5" for whole number', () {
        const props = SetMenuDishProps(
          name: 'Test',
          hasSupplement: true,
          supplementPrice: 5.0,
        );
        expect(props.supplementText, 'Supplement 5');
      });

      test('returns "Supplement 7.5" for decimal', () {
        const props = SetMenuDishProps(
          name: 'Test',
          hasSupplement: true,
          supplementPrice: 7.5,
        );
        expect(props.supplementText, 'Supplement 7.5');
      });

      test('returns "Supplement 12.75" for two decimal places', () {
        const props = SetMenuDishProps(
          name: 'Test',
          hasSupplement: true,
          supplementPrice: 12.75,
        );
        expect(props.supplementText, 'Supplement 12.75');
      });
    });

    group('displayName', () {
      test('returns uppercased name without dietary', () {
        const props = SetMenuDishProps(name: 'Beef Wellington');
        expect(props.displayName, 'BEEF WELLINGTON');
      });

      test('returns uppercased name with dietary abbreviation', () {
        const props = SetMenuDishProps(
          name: 'Garden Risotto',
          dietary: DietaryType.vegan,
        );
        expect(props.displayName, 'GARDEN RISOTTO (Ve)');
      });

      test('returns uppercased name with vegetarian abbreviation', () {
        const props = SetMenuDishProps(
          name: 'Mushroom Soup',
          dietary: DietaryType.vegetarian,
        );
        expect(props.displayName, 'MUSHROOM SOUP (V)');
      });
    });

    group('allergenInfo', () {
      test('stores structured allergens', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.gluten),
          AllergenInfo(allergen: UkAllergen.milk),
        ];
        const props = SetMenuDishProps(name: 'Test', allergenInfo: allergens);

        expect(props.allergenInfo, allergens);
      });

      test('defaults to empty list', () {
        const props = SetMenuDishProps(name: 'Test');
        expect(props.allergenInfo, isEmpty);
      });
    });

    group('equality', () {
      test('two props with same values are equal', () {
        const a = SetMenuDishProps(
          name: 'Test',
          hasSupplement: true,
          supplementPrice: 5.0,
        );
        const b = SetMenuDishProps(
          name: 'Test',
          hasSupplement: true,
          supplementPrice: 5.0,
        );
        expect(a, b);
      });

      test('two props with different supplement are not equal', () {
        const a = SetMenuDishProps(
          name: 'Test',
          hasSupplement: true,
          supplementPrice: 5.0,
        );
        const b = SetMenuDishProps(name: 'Test', hasSupplement: false);
        expect(a, isNot(b));
      });
    });

    group('copyWith', () {
      test('copies with new supplement values', () {
        const original = SetMenuDishProps(name: 'Test');
        final copy = original.copyWith(
          hasSupplement: true,
          supplementPrice: 10.0,
        );

        expect(copy.hasSupplement, true);
        expect(copy.supplementPrice, 10.0);
        expect(copy.name, 'Test');
      });
    });
  });
}
