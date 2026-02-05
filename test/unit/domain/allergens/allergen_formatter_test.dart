import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_formatter.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';

void main() {
  group('AllergenFormatter', () {
    group('formatForDisplay', () {
      test('should return empty string for empty list', () {
        expect(AllergenFormatter.formatForDisplay([]), '');
      });

      test('should format single allergen', () {
        const allergens = [AllergenInfo(allergen: UkAllergen.celery)];
        expect(AllergenFormatter.formatForDisplay(allergens), 'CELERY');
      });

      test('should format multiple allergens alphabetically', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.nuts),
          AllergenInfo(allergen: UkAllergen.celery),
          AllergenInfo(allergen: UkAllergen.eggs),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'CELERY, EGGS, NUTS',
        );
      });

      test('should include details in lowercase brackets', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.gluten, details: 'Wheat, Barley'),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'GLUTEN [wheat, barley]',
        );
      });

      test('should format allergen with details correctly', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.nuts, details: 'walnut, almond'),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'NUTS [walnut, almond]',
        );
      });

      test('should format may-contain allergens with prefix', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'MAY CONTAIN EGGS',
        );
      });

      test('should separate definite and may-contain allergens', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.celery),
          AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'CELERY, MAY CONTAIN EGGS',
        );
      });

      test('should format multiple may-contain allergens together', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
          AllergenInfo(allergen: UkAllergen.soya, mayContain: true),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'MAY CONTAIN EGGS, SOYA',
        );
      });

      test('should format complex mix of allergens correctly', () {
        // Example from requirements:
        // "CELERY, NUTS [walnut, peanut], SULPHUR DIOXIDE, MAY CONTAIN EGGS, SOYA"
        const allergens = [
          AllergenInfo(allergen: UkAllergen.celery),
          AllergenInfo(allergen: UkAllergen.nuts, details: 'walnut'),
          AllergenInfo(allergen: UkAllergen.sulphites),
          AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
          AllergenInfo(allergen: UkAllergen.soya, mayContain: true),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'CELERY, NUTS [walnut], SULPHUR DIOXIDE, MAY CONTAIN EGGS, SOYA',
        );
      });

      test('should format may-contain allergen with details', () {
        const allergens = [
          AllergenInfo(
            allergen: UkAllergen.nuts,
            mayContain: true,
            details: 'walnut',
          ),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'MAY CONTAIN NUTS [walnut]',
        );
      });

      test('should sort both definite and may-contain groups alphabetically',
          () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.soya),
          AllergenInfo(allergen: UkAllergen.celery),
          AllergenInfo(allergen: UkAllergen.milk, mayContain: true),
          AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'CELERY, SOYA, MAY CONTAIN EGGS, MILK',
        );
      });

      test('should ignore empty details', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.gluten, details: ''),
        ];
        expect(AllergenFormatter.formatForDisplay(allergens), 'GLUTEN');
      });

      test('should trim whitespace in details', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.gluten, details: '  wheat  '),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'GLUTEN [wheat]',
        );
      });

      test('should handle all 14 allergens', () {
        const allergens = [
          AllergenInfo(allergen: UkAllergen.celery),
          AllergenInfo(allergen: UkAllergen.gluten),
          AllergenInfo(allergen: UkAllergen.crustaceans),
          AllergenInfo(allergen: UkAllergen.eggs),
          AllergenInfo(allergen: UkAllergen.fish),
          AllergenInfo(allergen: UkAllergen.lupin),
          AllergenInfo(allergen: UkAllergen.milk),
          AllergenInfo(allergen: UkAllergen.molluscs),
          AllergenInfo(allergen: UkAllergen.mustard),
          AllergenInfo(allergen: UkAllergen.nuts),
          AllergenInfo(allergen: UkAllergen.peanuts),
          AllergenInfo(allergen: UkAllergen.sesame),
          AllergenInfo(allergen: UkAllergen.soya),
          AllergenInfo(allergen: UkAllergen.sulphites),
        ];
        final result = AllergenFormatter.formatForDisplay(allergens);
        expect(result, contains('CELERY'));
        expect(result, contains('GLUTEN'));
        expect(result, contains('CRUSTACEANS'));
        expect(result, contains('EGGS'));
        expect(result, contains('FISH'));
        expect(result, contains('LUPIN'));
        expect(result, contains('MILK'));
        expect(result, contains('MOLLUSCS'));
        expect(result, contains('MUSTARD'));
        expect(result, contains('NUTS'));
        expect(result, contains('PEANUTS'));
        expect(result, contains('SESAME'));
        expect(result, contains('SOYA'));
        expect(result, contains('SULPHUR DIOXIDE'));
      });

      test('should format gluten and nuts with separate details', () {
        // Both gluten and nuts can have their own details
        const allergens = [
          AllergenInfo(allergen: UkAllergen.gluten, details: 'wheat, barley'),
          AllergenInfo(allergen: UkAllergen.nuts, details: 'walnut, almond'),
        ];
        expect(
          AllergenFormatter.formatForDisplay(allergens),
          'GLUTEN [wheat, barley], NUTS [walnut, almond]',
        );
      });
    });
  });
}
