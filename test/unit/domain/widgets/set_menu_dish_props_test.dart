import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';
import 'package:oxo_menus/domain/widgets/set_menu_dish/set_menu_dish_props.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';

void main() {
  group('SetMenuDishProps', () {
    group('construction', () {
      test('should store name when constructed with a required name', () {
        const props = SetMenuDishProps(name: 'Beef Wellington');

        expect(props.name, 'Beef Wellington');
      });

      test('should default description to null when none is provided', () {
        const props = SetMenuDishProps(name: 'Beef Wellington');

        expect(props.description, isNull);
      });

      test('should default calories to null when none is provided', () {
        const props = SetMenuDishProps(name: 'Beef Wellington');

        expect(props.calories, isNull);
      });

      test(
        'should default allergenInfo to an empty list when none is provided',
        () {
          const props = SetMenuDishProps(name: 'Beef Wellington');

          expect(props.allergenInfo, isEmpty);
        },
      );

      test('should default dietary to null when none is provided', () {
        const props = SetMenuDishProps(name: 'Beef Wellington');

        expect(props.dietary, isNull);
      });

      test('should default hasSupplement to false when none is provided', () {
        const props = SetMenuDishProps(name: 'Beef Wellington');

        expect(props.hasSupplement, isFalse);
      });

      test('should default supplementPrice to 0.0 when none is provided', () {
        const props = SetMenuDishProps(name: 'Beef Wellington');

        expect(props.supplementPrice, 0.0);
      });

      test('should store all optional fields when provided', () {
        const props = SetMenuDishProps(
          name: 'Lobster Thermidor',
          description: 'Classic French lobster dish',
          calories: 650,
          dietary: DietaryType.vegetarian,
          hasSupplement: true,
          supplementPrice: 7.5,
        );

        expect(props.description, 'Classic French lobster dish');
        expect(props.calories, 650);
        expect(props.dietary, DietaryType.vegetarian);
        expect(props.hasSupplement, isTrue);
        expect(props.supplementPrice, 7.5);
      });

      test('should store allergenInfo when a non-empty list is provided', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.gluten),
          AllergenInfo(allergen: UkAllergen.milk),
        ];
        const props = SetMenuDishProps(name: 'Test', allergenInfo: allergens);

        expect(props.allergenInfo, allergens);
      });
    });

    group('equality', () {
      test('should be equal when all fields are identical', () {
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

        expect(a, equals(b));
      });

      test('should not be equal when hasSupplement differs', () {
        const a = SetMenuDishProps(
          name: 'Test',
          hasSupplement: true,
          supplementPrice: 5.0,
        );
        const b = SetMenuDishProps(name: 'Test', hasSupplement: false);

        expect(a, isNot(equals(b)));
      });

      test('should not be equal when names differ', () {
        const a = SetMenuDishProps(name: 'Dish A');
        const b = SetMenuDishProps(name: 'Dish B');

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('should be the same for two instances with identical fields', () {
        const a = SetMenuDishProps(name: 'Test', hasSupplement: true);
        const b = SetMenuDishProps(name: 'Test', hasSupplement: true);

        expect(a.hashCode, b.hashCode);
      });
    });

    group('copyWith', () {
      test('should update hasSupplement when copyWith is called with true', () {
        const original = SetMenuDishProps(name: 'Test');

        final copy = original.copyWith(
          hasSupplement: true,
          supplementPrice: 10.0,
        );

        expect(copy.hasSupplement, isTrue);
      });

      test(
        'should update supplementPrice when copyWith is called with a new value',
        () {
          const original = SetMenuDishProps(name: 'Test');

          final copy = original.copyWith(supplementPrice: 10.0);

          expect(copy.supplementPrice, 10.0);
        },
      );

      test(
        'should preserve name when copyWith only changes supplement fields',
        () {
          const original = SetMenuDishProps(name: 'Test');

          final copy = original.copyWith(
            hasSupplement: true,
            supplementPrice: 10.0,
          );

          expect(copy.name, 'Test');
        },
      );

      test('should not mutate the original when copyWith is called', () {
        const original = SetMenuDishProps(name: 'Test');

        final _ = original.copyWith(hasSupplement: true, supplementPrice: 10.0);

        expect(original.hasSupplement, isFalse);
        expect(original.supplementPrice, 0.0);
      });
    });

    group('supplementText', () {
      test('should return empty string when hasSupplement is false', () {
        const props = SetMenuDishProps(name: 'Test');

        expect(props.supplementText, '');
      });

      test(
        'should return empty string when hasSupplement is true but price is 0.0',
        () {
          const props = SetMenuDishProps(
            name: 'Test',
            hasSupplement: true,
            supplementPrice: 0.0,
          );

          expect(props.supplementText, '');
        },
      );

      test(
        'should return Supplement 5 for whole-number GBP supplement price',
        () {
          const props = SetMenuDishProps(
            name: 'Test',
            hasSupplement: true,
            supplementPrice: 5.0,
          );

          expect(props.supplementText, 'Supplement 5');
        },
      );

      test(
        'should return Supplement 7.5 for a single-decimal GBP supplement price',
        () {
          const props = SetMenuDishProps(
            name: 'Test',
            hasSupplement: true,
            supplementPrice: 7.5,
          );

          expect(props.supplementText, 'Supplement 7.5');
        },
      );

      test(
        'should return Supplement 12.75 for a two-decimal GBP supplement price',
        () {
          const props = SetMenuDishProps(
            name: 'Test',
            hasSupplement: true,
            supplementPrice: 12.75,
          );

          expect(props.supplementText, 'Supplement 12.75');
        },
      );

      test(
        'should return Supplement 10 for a round ten-pound GBP supplement price',
        () {
          const props = SetMenuDishProps(
            name: 'Test',
            hasSupplement: true,
            supplementPrice: 10.0,
          );

          expect(props.supplementText, 'Supplement 10');
        },
      );
    });

    group('displayName', () {
      test('should return uppercased name when no dietary is set', () {
        const props = SetMenuDishProps(name: 'Beef Wellington');

        expect(props.displayName, 'BEEF WELLINGTON');
      });

      test('should append (Ve) abbreviation when dietary is vegan', () {
        const props = SetMenuDishProps(
          name: 'Garden Risotto',
          dietary: DietaryType.vegan,
        );

        expect(props.displayName, 'GARDEN RISOTTO (Ve)');
      });

      test('should append (V) abbreviation when dietary is vegetarian', () {
        const props = SetMenuDishProps(
          name: 'Mushroom Soup',
          dietary: DietaryType.vegetarian,
        );

        expect(props.displayName, 'MUSHROOM SOUP (V)');
      });

      test(
        'should return empty string when name is empty and no dietary set',
        () {
          const props = SetMenuDishProps(name: '');

          expect(props.displayName, '');
        },
      );
    });

    group('JSON round-trip', () {
      test(
        'should be equal to the original with supplement after toJson/fromJson',
        () {
          const original = SetMenuDishProps(
            name: 'Lobster',
            hasSupplement: true,
            supplementPrice: 5.0,
            dietary: DietaryType.vegan,
          );

          final json = original.toJson();
          final restored = SetMenuDishProps.fromJson(json);

          expect(restored, equals(original));
        },
      );

      test('should preserve hasSupplement false after round-trip', () {
        const original = SetMenuDishProps(name: 'Soup of the Day');

        final json = original.toJson();
        final restored = SetMenuDishProps.fromJson(json);

        expect(restored.hasSupplement, isFalse);
        expect(restored.supplementPrice, 0.0);
      });

      test('should use default values when only name is present in JSON', () {
        final json = {'name': 'Simple Dish'};

        final props = SetMenuDishProps.fromJson(json);

        expect(props.hasSupplement, isFalse);
        expect(props.supplementPrice, 0.0);
        expect(props.description, isNull);
        expect(props.calories, isNull);
        expect(props.dietary, isNull);
      });

      test('should round-trip allergens with multiple entries correctly', () {
        const original = SetMenuDishProps(
          name: 'Test',
          allergenInfo: [
            AllergenInfo(allergen: UkAllergen.gluten),
            AllergenInfo(allergen: UkAllergen.milk),
          ],
        );

        final json = original.toJson();
        final restored = SetMenuDishProps.fromJson(json);

        expect(restored, equals(original));
      });

      test(
        'should round-trip a GBP supplement price with fractional pence correctly',
        () {
          const original = SetMenuDishProps(
            name: 'Dish',
            hasSupplement: true,
            supplementPrice: 7.50,
          );

          final json = original.toJson();
          final restored = SetMenuDishProps.fromJson(json);

          expect(restored.supplementPrice, 7.50);
        },
      );
    });
  });
}
