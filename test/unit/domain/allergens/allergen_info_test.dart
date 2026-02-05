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
        const info = AllergenInfo(
          allergen: UkAllergen.eggs,
          mayContain: true,
        );
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

    group('fromLegacyString', () {
      test('should map direct allergen names', () {
        final info = AllergenInfo.fromLegacyString('celery');
        expect(info, isNotNull);
        expect(info!.allergen, UkAllergen.celery);
      });

      test('should be case insensitive', () {
        final info = AllergenInfo.fromLegacyString('EGGS');
        expect(info, isNotNull);
        expect(info!.allergen, UkAllergen.eggs);
      });

      test('should handle whitespace', () {
        final info = AllergenInfo.fromLegacyString('  milk  ');
        expect(info, isNotNull);
        expect(info!.allergen, UkAllergen.milk);
      });

      group('common mappings', () {
        test('should map dairy to milk', () {
          final info = AllergenInfo.fromLegacyString('dairy');
          expect(info, isNotNull);
          expect(info!.allergen, UkAllergen.milk);
        });

        test('should map wheat to gluten', () {
          final info = AllergenInfo.fromLegacyString('wheat');
          expect(info, isNotNull);
          expect(info!.allergen, UkAllergen.gluten);
        });

        test('should map shellfish to crustaceans', () {
          final info = AllergenInfo.fromLegacyString('shellfish');
          expect(info, isNotNull);
          expect(info!.allergen, UkAllergen.crustaceans);
        });

        test('should map soy to soya', () {
          final info = AllergenInfo.fromLegacyString('soy');
          expect(info, isNotNull);
          expect(info!.allergen, UkAllergen.soya);
        });

        test('should map sulfites/sulphites to sulphites', () {
          expect(
            AllergenInfo.fromLegacyString('sulfites')!.allergen,
            UkAllergen.sulphites,
          );
          expect(
            AllergenInfo.fromLegacyString('sulphites')!.allergen,
            UkAllergen.sulphites,
          );
        });

        test('should map tree nuts to nuts', () {
          final info = AllergenInfo.fromLegacyString('tree nuts');
          expect(info, isNotNull);
          expect(info!.allergen, UkAllergen.nuts);
        });
      });

      group('specific nut mappings', () {
        test('should map walnut to nuts with details', () {
          final info = AllergenInfo.fromLegacyString('walnut');
          expect(info, isNotNull);
          expect(info!.allergen, UkAllergen.nuts);
          expect(info.details, 'walnut');
        });

        test('should map almonds to nuts with details', () {
          final info = AllergenInfo.fromLegacyString('almonds');
          expect(info, isNotNull);
          expect(info!.allergen, UkAllergen.nuts);
          expect(info.details, 'almonds');
        });
      });

      group('contains patterns', () {
        test('should map strings containing "nut" to nuts', () {
          final info = AllergenInfo.fromLegacyString('Mixed Nuts');
          expect(info, isNotNull);
          expect(info!.allergen, UkAllergen.nuts);
          expect(info.details, 'Mixed Nuts');
        });

        test('should map strings containing "gluten" to gluten', () {
          final info = AllergenInfo.fromLegacyString('contains gluten');
          expect(info, isNotNull);
          expect(info!.allergen, UkAllergen.gluten);
        });
      });

      test('should return null for unmappable strings', () {
        expect(AllergenInfo.fromLegacyString('unknown'), isNull);
        expect(AllergenInfo.fromLegacyString('random text'), isNull);
        expect(AllergenInfo.fromLegacyString('123'), isNull);
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
