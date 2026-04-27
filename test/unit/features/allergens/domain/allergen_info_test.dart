import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/allergens/domain/allergen_info.dart';
import 'package:oxo_menus/features/allergens/domain/uk_allergen.dart';

void main() {
  group('AllergenInfo', () {
    group('construction', () {
      test('should create with only the required allergen field', () {
        const info = AllergenInfo(allergen: UkAllergen.celery);
        expect(info.allergen, UkAllergen.celery);
      });

      test('should default mayContain to false when not provided', () {
        const info = AllergenInfo(allergen: UkAllergen.celery);
        expect(info.mayContain, isFalse);
      });

      test('should default details to null when not provided', () {
        const info = AllergenInfo(allergen: UkAllergen.celery);
        expect(info.details, isNull);
      });

      test('should store mayContain true when explicitly set', () {
        const info = AllergenInfo(allergen: UkAllergen.eggs, mayContain: true);
        expect(info.mayContain, isTrue);
      });

      test('should store allergen when mayContain is true', () {
        const info = AllergenInfo(allergen: UkAllergen.eggs, mayContain: true);
        expect(info.allergen, UkAllergen.eggs);
      });

      test('should store the details string when provided', () {
        const info = AllergenInfo(
          allergen: UkAllergen.gluten,
          details: 'wheat, barley',
        );
        expect(info.details, 'wheat, barley');
      });

      test('should store the allergen when details is provided', () {
        const info = AllergenInfo(
          allergen: UkAllergen.gluten,
          details: 'wheat, barley',
        );
        expect(info.allergen, UkAllergen.gluten);
      });

      test('should store all three fields when all are provided', () {
        const info = AllergenInfo(
          allergen: UkAllergen.nuts,
          mayContain: true,
          details: 'walnut, almond',
        );
        expect(info.allergen, UkAllergen.nuts);
        expect(info.mayContain, isTrue);
        expect(info.details, 'walnut, almond');
      });

      test('should allow details to be an empty string', () {
        const info = AllergenInfo(allergen: UkAllergen.gluten, details: '');
        expect(info.details, '');
      });

      test('should allow details to be whitespace only', () {
        const info = AllergenInfo(allergen: UkAllergen.gluten, details: '   ');
        expect(info.details, '   ');
      });
    });

    group('copyWith', () {
      test('should produce an equal copy when no fields are changed', () {
        const info = AllergenInfo(allergen: UkAllergen.eggs);
        final copy = info.copyWith();
        expect(copy, info);
      });

      test('should change mayContain to true when specified', () {
        const info = AllergenInfo(allergen: UkAllergen.eggs);
        final copy = info.copyWith(mayContain: true);
        expect(copy.mayContain, isTrue);
      });

      test('should preserve allergen when only mayContain is changed', () {
        const info = AllergenInfo(allergen: UkAllergen.eggs);
        final copy = info.copyWith(mayContain: true);
        expect(copy.allergen, UkAllergen.eggs);
      });

      test('should preserve details when only mayContain is changed', () {
        const info = AllergenInfo(allergen: UkAllergen.eggs);
        final copy = info.copyWith(mayContain: true);
        expect(copy.details, isNull);
      });

      test('should change details when specified', () {
        const info = AllergenInfo(allergen: UkAllergen.gluten);
        final copy = info.copyWith(details: 'wheat');
        expect(copy.details, 'wheat');
      });

      test('should preserve allergen when only details is changed', () {
        const info = AllergenInfo(allergen: UkAllergen.gluten);
        final copy = info.copyWith(details: 'wheat');
        expect(copy.allergen, UkAllergen.gluten);
      });

      test('should preserve mayContain when only details is changed', () {
        const info = AllergenInfo(allergen: UkAllergen.gluten);
        final copy = info.copyWith(details: 'wheat');
        expect(copy.mayContain, isFalse);
      });

      test('should change the allergen when specified', () {
        const info = AllergenInfo(allergen: UkAllergen.celery);
        final copy = info.copyWith(allergen: UkAllergen.milk);
        expect(copy.allergen, UkAllergen.milk);
      });

      test('should not mutate the original when copied', () {
        const info = AllergenInfo(allergen: UkAllergen.eggs);
        // ignore: unused_local_variable
        final _ = info.copyWith(mayContain: true);
        expect(info.mayContain, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when all fields are identical', () {
        const info1 = AllergenInfo(
          allergen: UkAllergen.gluten,
          mayContain: true,
          details: 'wheat',
        );
        const info2 = AllergenInfo(
          allergen: UkAllergen.gluten,
          mayContain: true,
          details: 'wheat',
        );
        expect(info1, equals(info2));
      });

      test('should not be equal when allergens differ', () {
        const info1 = AllergenInfo(allergen: UkAllergen.gluten);
        const info2 = AllergenInfo(allergen: UkAllergen.nuts);
        expect(info1, isNot(equals(info2)));
      });

      test('should not be equal when mayContain differs', () {
        const info1 = AllergenInfo(
          allergen: UkAllergen.eggs,
          mayContain: false,
        );
        const info2 = AllergenInfo(allergen: UkAllergen.eggs, mayContain: true);
        expect(info1, isNot(equals(info2)));
      });

      test('should not be equal when details differ', () {
        const info1 = AllergenInfo(
          allergen: UkAllergen.gluten,
          details: 'wheat',
        );
        const info2 = AllergenInfo(allergen: UkAllergen.gluten, details: 'rye');
        expect(info1, isNot(equals(info2)));
      });

      test(
        'should not be equal when one has details and the other does not',
        () {
          const info1 = AllergenInfo(
            allergen: UkAllergen.gluten,
            details: 'wheat',
          );
          const info2 = AllergenInfo(allergen: UkAllergen.gluten);
          expect(info1, isNot(equals(info2)));
        },
      );

      test('should have the same hashCode when values are equal', () {
        const info1 = AllergenInfo(allergen: UkAllergen.milk);
        const info2 = AllergenInfo(allergen: UkAllergen.milk);
        expect(info1.hashCode, info2.hashCode);
      });
    });

    group('JSON serialization', () {
      test('should serialize allergen to its enum name string', () {
        const info = AllergenInfo(allergen: UkAllergen.gluten);
        final json = info.toJson();
        expect(json['allergen'], 'gluten');
      });

      test('should serialize mayContain true when set', () {
        const info = AllergenInfo(
          allergen: UkAllergen.gluten,
          mayContain: true,
        );
        final json = info.toJson();
        expect(json['mayContain'], isTrue);
      });

      test('should serialize mayContain false when at default', () {
        const info = AllergenInfo(allergen: UkAllergen.gluten);
        final json = info.toJson();
        expect(json['mayContain'], isFalse);
      });

      test('should serialize details string when provided', () {
        const info = AllergenInfo(
          allergen: UkAllergen.gluten,
          details: 'wheat',
        );
        final json = info.toJson();
        expect(json['details'], 'wheat');
      });

      test('should serialize details as null when not provided', () {
        const info = AllergenInfo(allergen: UkAllergen.celery);
        final json = info.toJson();
        expect(json['details'], isNull);
      });
    });

    group('JSON deserialization', () {
      test('should deserialize allergen from its enum name string', () {
        final json = {'allergen': 'nuts', 'mayContain': false, 'details': null};
        final info = AllergenInfo.fromJson(json);
        expect(info.allergen, UkAllergen.nuts);
      });

      test('should deserialize mayContain false from JSON', () {
        final json = {'allergen': 'nuts', 'mayContain': false, 'details': null};
        final info = AllergenInfo.fromJson(json);
        expect(info.mayContain, isFalse);
      });

      test('should deserialize mayContain true from JSON', () {
        final json = {'allergen': 'eggs', 'mayContain': true};
        final info = AllergenInfo.fromJson(json);
        expect(info.mayContain, isTrue);
      });

      test('should deserialize details string from JSON', () {
        final json = {
          'allergen': 'nuts',
          'mayContain': false,
          'details': 'walnut',
        };
        final info = AllergenInfo.fromJson(json);
        expect(info.details, 'walnut');
      });

      test('should default mayContain to false when key is absent', () {
        final json = {'allergen': 'celery'};
        final info = AllergenInfo.fromJson(json);
        expect(info.mayContain, isFalse);
      });

      test('should default details to null when key is absent', () {
        final json = {'allergen': 'celery'};
        final info = AllergenInfo.fromJson(json);
        expect(info.details, isNull);
      });

      test('should deserialize all 14 allergen names correctly', () {
        final allergenNames = [
          'celery',
          'gluten',
          'crustaceans',
          'eggs',
          'fish',
          'lupin',
          'milk',
          'molluscs',
          'mustard',
          'nuts',
          'peanuts',
          'sesame',
          'soya',
          'sulphites',
        ];
        final parsed = allergenNames
            .map((name) => AllergenInfo.fromJson({'allergen': name}))
            .toList();
        expect(parsed.length, 14);
        expect(parsed.map((i) => i.allergen).toSet().length, 14);
      });
    });

    group('JSON round-trip', () {
      test('should round-trip a minimal AllergenInfo', () {
        const original = AllergenInfo(allergen: UkAllergen.celery);
        final restored = AllergenInfo.fromJson(original.toJson());
        expect(restored, original);
      });

      test('should round-trip an AllergenInfo with mayContain true', () {
        const original = AllergenInfo(
          allergen: UkAllergen.eggs,
          mayContain: true,
        );
        final restored = AllergenInfo.fromJson(original.toJson());
        expect(restored, original);
      });

      test('should round-trip an AllergenInfo with details', () {
        const original = AllergenInfo(
          allergen: UkAllergen.sulphites,
          mayContain: true,
          details: 'SO2',
        );
        final restored = AllergenInfo.fromJson(original.toJson());
        expect(restored, original);
      });

      test('should round-trip an AllergenInfo with all fields set', () {
        const original = AllergenInfo(
          allergen: UkAllergen.nuts,
          mayContain: false,
          details: 'walnut, almond',
        );
        final restored = AllergenInfo.fromJson(original.toJson());
        expect(restored, original);
      });
    });
  });
}
