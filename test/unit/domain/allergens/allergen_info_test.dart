import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';

void main() {
  group('AllergenInfo', () {
    group('constructor', () {
      test('should create with required allergen only', () {
        const info = AllergenInfo(allergen: UkAllergen.celery);
        expect(info.allergen, UkAllergen.celery);
        expect(info.mayContain, false);
        expect(info.details, isNull);
      });

      test('should create with mayContain', () {
        const info = AllergenInfo(allergen: UkAllergen.eggs, mayContain: true);
        expect(info.allergen, UkAllergen.eggs);
        expect(info.mayContain, true);
        expect(info.details, isNull);
      });

      test('should create with details', () {
        const info = AllergenInfo(
          allergen: UkAllergen.gluten,
          details: 'wheat, barley',
        );
        expect(info.allergen, UkAllergen.gluten);
        expect(info.mayContain, false);
        expect(info.details, 'wheat, barley');
      });

      test('should create with all fields', () {
        const info = AllergenInfo(
          allergen: UkAllergen.nuts,
          mayContain: true,
          details: 'walnut, almond',
        );
        expect(info.allergen, UkAllergen.nuts);
        expect(info.mayContain, true);
        expect(info.details, 'walnut, almond');
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON', () {
        const info = AllergenInfo(
          allergen: UkAllergen.gluten,
          mayContain: true,
          details: 'wheat',
        );
        final json = info.toJson();
        expect(json['allergen'], 'gluten');
        expect(json['mayContain'], true);
        expect(json['details'], 'wheat');
      });

      test('should deserialize from JSON', () {
        final json = {
          'allergen': 'nuts',
          'mayContain': false,
          'details': 'walnut',
        };
        final info = AllergenInfo.fromJson(json);
        expect(info.allergen, UkAllergen.nuts);
        expect(info.mayContain, false);
        expect(info.details, 'walnut');
      });

      test('should handle missing optional fields in JSON', () {
        final json = {'allergen': 'celery'};
        final info = AllergenInfo.fromJson(json);
        expect(info.allergen, UkAllergen.celery);
        expect(info.mayContain, false);
        expect(info.details, isNull);
      });

      test('should round-trip through JSON', () {
        const original = AllergenInfo(
          allergen: UkAllergen.sulphites,
          mayContain: true,
          details: 'SO2',
        );
        final json = original.toJson();
        final restored = AllergenInfo.fromJson(json);
        expect(restored, original);
      });
    });

    group('copyWith', () {
      test('should copy with new mayContain', () {
        const info = AllergenInfo(allergen: UkAllergen.eggs);
        final copied = info.copyWith(mayContain: true);
        expect(copied.allergen, UkAllergen.eggs);
        expect(copied.mayContain, true);
        expect(copied.details, isNull);
      });

      test('should copy with new details', () {
        const info = AllergenInfo(allergen: UkAllergen.gluten);
        final copied = info.copyWith(details: 'wheat');
        expect(copied.allergen, UkAllergen.gluten);
        expect(copied.mayContain, false);
        expect(copied.details, 'wheat');
      });
    });

    group('equality', () {
      test('same values should be equal', () {
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
        expect(info1, info2);
      });

      test('different values should not be equal', () {
        const info1 = AllergenInfo(allergen: UkAllergen.gluten);
        const info2 = AllergenInfo(allergen: UkAllergen.nuts);
        expect(info1, isNot(info2));
      });
    });
  });
}
