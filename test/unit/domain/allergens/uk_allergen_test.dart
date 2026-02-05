import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';

void main() {
  group('UkAllergen', () {
    test('should have 14 allergen values', () {
      expect(UkAllergen.values.length, 14);
    });

    test('all allergens should have a displayName', () {
      for (final allergen in UkAllergen.values) {
        expect(allergen.displayName, isNotEmpty);
      }
    });

    test('all allergens should have a shortName in CAPITALS', () {
      for (final allergen in UkAllergen.values) {
        expect(allergen.shortName, isNotEmpty);
        expect(allergen.shortName, allergen.shortName.toUpperCase());
      }
    });

    test('only gluten and nuts should support details', () {
      expect(UkAllergen.gluten.supportsDetails, true);
      expect(UkAllergen.nuts.supportsDetails, true);

      for (final allergen in UkAllergen.values) {
        if (allergen != UkAllergen.gluten && allergen != UkAllergen.nuts) {
          expect(allergen.supportsDetails, false,
              reason: '${allergen.name} should not support details');
        }
      }
    });

    test('gluten and nuts should have detailsHint', () {
      expect(UkAllergen.gluten.detailsHint, isNotNull);
      expect(UkAllergen.nuts.detailsHint, isNotNull);
    });

    test('non-detail allergens should have null detailsHint', () {
      expect(UkAllergen.celery.detailsHint, isNull);
      expect(UkAllergen.eggs.detailsHint, isNull);
      expect(UkAllergen.milk.detailsHint, isNull);
    });

    group('fromString', () {
      test('should parse valid allergen names', () {
        expect(UkAllergen.fromString('celery'), UkAllergen.celery);
        expect(UkAllergen.fromString('gluten'), UkAllergen.gluten);
        expect(UkAllergen.fromString('nuts'), UkAllergen.nuts);
        expect(UkAllergen.fromString('sulphites'), UkAllergen.sulphites);
      });

      test('should be case insensitive', () {
        expect(UkAllergen.fromString('CELERY'), UkAllergen.celery);
        expect(UkAllergen.fromString('Gluten'), UkAllergen.gluten);
        expect(UkAllergen.fromString('NUTS'), UkAllergen.nuts);
      });

      test('should handle whitespace', () {
        expect(UkAllergen.fromString('  celery  '), UkAllergen.celery);
        expect(UkAllergen.fromString('\tgluten\n'), UkAllergen.gluten);
      });

      test('should return null for invalid names', () {
        expect(UkAllergen.fromString('invalid'), isNull);
        expect(UkAllergen.fromString('dairy'), isNull); // Not exact match
        expect(UkAllergen.fromString(''), isNull);
      });
    });

    group('displayName values', () {
      test('celery should have correct displayName', () {
        expect(UkAllergen.celery.displayName, 'Celery');
      });

      test('gluten should have correct displayName', () {
        expect(UkAllergen.gluten.displayName, 'Cereals containing gluten');
      });

      test('sulphites should have correct displayName', () {
        expect(UkAllergen.sulphites.displayName, 'Sulphur dioxide/sulphites');
      });

      test('nuts should have correct displayName', () {
        expect(UkAllergen.nuts.displayName, 'Nuts (tree nuts)');
      });
    });

    group('shortName values', () {
      test('celery should have correct shortName', () {
        expect(UkAllergen.celery.shortName, 'CELERY');
      });

      test('sulphites should have correct shortName', () {
        expect(UkAllergen.sulphites.shortName, 'SULPHUR DIOXIDE');
      });

      test('nuts should have correct shortName', () {
        expect(UkAllergen.nuts.shortName, 'NUTS');
      });
    });
  });
}
