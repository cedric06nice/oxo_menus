import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_formatter.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';

void main() {
  group('AllergenFormatter', () {
    group('formatForDisplay', () {
      // ------------------------------------------------------------------
      // Empty / null-like inputs
      // ------------------------------------------------------------------

      test('should return empty string when the allergen list is empty', () {
        final result = AllergenFormatter.formatForDisplay([]);
        expect(result, '');
      });

      // ------------------------------------------------------------------
      // Single definite allergen (no details)
      // ------------------------------------------------------------------

      test(
        'should return the allergen shortName in capitals for a single allergen',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.milk),
          ]);
          expect(result, 'MILK');
        },
      );

      test('should return CELERY for a single celery allergen', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.celery),
        ]);
        expect(result, 'CELERY');
      });

      test('should return SULPHITES for a single sulphites allergen', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.sulphites),
        ]);
        expect(result, 'SULPHITES');
      });

      // ------------------------------------------------------------------
      // Multiple definite allergens — ordering
      // ------------------------------------------------------------------

      test(
        'should sort multiple definite allergens alphabetically by shortName',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.nuts),
            const AllergenInfo(allergen: UkAllergen.celery),
            const AllergenInfo(allergen: UkAllergen.eggs),
          ]);
          // Alphabetical order: CELERY, EGGS, NUTS
          expect(result, 'CELERY, EGGS, NUTS');
        },
      );

      test(
        'should separate multiple definite allergens with a comma and space',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.milk),
            const AllergenInfo(allergen: UkAllergen.fish),
          ]);
          expect(result, 'FISH, MILK');
        },
      );

      test(
        'should produce alphabetical order when input is already reversed',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.soya),
            const AllergenInfo(allergen: UkAllergen.celery),
          ]);
          expect(result, 'CELERY, SOYA');
        },
      );

      // ------------------------------------------------------------------
      // Details formatting
      // ------------------------------------------------------------------

      test('should append lowercase details in square brackets for gluten', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.gluten, details: 'wheat'),
        ]);
        expect(result, 'GLUTEN [wheat]');
      });

      test('should append lowercase details in square brackets for nuts', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(
            allergen: UkAllergen.nuts,
            details: 'walnut, almond',
          ),
        ]);
        expect(result, 'NUTS [walnut, almond]');
      });

      test('should lowercase details that were provided in uppercase', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(
            allergen: UkAllergen.gluten,
            details: 'Wheat, Barley',
          ),
        ]);
        expect(result, 'GLUTEN [wheat, barley]');
      });

      test('should lowercase details that were provided in mixed case', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.nuts, details: 'WALNUT'),
        ]);
        expect(result, 'NUTS [walnut]');
      });

      test('should trim leading whitespace from details', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.gluten, details: '  wheat'),
        ]);
        expect(result, 'GLUTEN [wheat]');
      });

      test('should trim trailing whitespace from details', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.gluten, details: 'wheat  '),
        ]);
        expect(result, 'GLUTEN [wheat]');
      });

      test('should trim surrounding whitespace from details', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.gluten, details: '  wheat  '),
        ]);
        expect(result, 'GLUTEN [wheat]');
      });

      test('should omit brackets when details is null', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.gluten),
        ]);
        expect(result, 'GLUTEN');
      });

      test('should omit brackets when details is an empty string', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.gluten, details: ''),
        ]);
        expect(result, 'GLUTEN');
      });

      test('should omit brackets when details is whitespace only', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.gluten, details: '   '),
        ]);
        expect(result, 'GLUTEN');
      });

      // ------------------------------------------------------------------
      // Single may-contain allergen
      // ------------------------------------------------------------------

      test('should prefix a single may-contain allergen with MAY CONTAIN', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
        ]);
        expect(result, 'MAY CONTAIN EGGS');
      });

      test(
        'should include details in brackets for a may-contain allergen with details',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(
              allergen: UkAllergen.nuts,
              mayContain: true,
              details: 'walnut',
            ),
          ]);
          expect(result, 'MAY CONTAIN NUTS [walnut]');
        },
      );

      // ------------------------------------------------------------------
      // Multiple may-contain allergens grouped under one MAY CONTAIN prefix
      // ------------------------------------------------------------------

      test(
        'should group multiple may-contain allergens under one MAY CONTAIN prefix',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
            const AllergenInfo(allergen: UkAllergen.soya, mayContain: true),
          ]);
          expect(result, 'MAY CONTAIN EGGS, SOYA');
        },
      );

      test(
        'should sort multiple may-contain allergens alphabetically within the group',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.soya, mayContain: true),
            const AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
          ]);
          expect(result, 'MAY CONTAIN EGGS, SOYA');
        },
      );

      test(
        'should separate may-contain allergens with comma and space inside the group',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.milk, mayContain: true),
            const AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
            const AllergenInfo(allergen: UkAllergen.soya, mayContain: true),
          ]);
          expect(result, 'MAY CONTAIN EGGS, MILK, SOYA');
        },
      );

      // ------------------------------------------------------------------
      // Mixed definite and may-contain allergens — ordering rule
      // ------------------------------------------------------------------

      test('should list definite allergens before may-contain allergens', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
          const AllergenInfo(allergen: UkAllergen.celery),
        ]);
        expect(result, 'CELERY, MAY CONTAIN EGGS');
      });

      test('should place MAY CONTAIN group after all definite allergens', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.celery),
          const AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
          const AllergenInfo(allergen: UkAllergen.soya, mayContain: true),
        ]);
        expect(result, 'CELERY, MAY CONTAIN EGGS, SOYA');
      });

      test('should sort definite and may-contain groups independently', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.soya),
          const AllergenInfo(allergen: UkAllergen.celery),
          const AllergenInfo(allergen: UkAllergen.milk, mayContain: true),
          const AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
        ]);
        expect(result, 'CELERY, SOYA, MAY CONTAIN EGGS, MILK');
      });

      // ------------------------------------------------------------------
      // Complex multi-allergen scenarios
      // ------------------------------------------------------------------

      test('should format gluten with details alongside other allergens', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.celery),
          const AllergenInfo(
            allergen: UkAllergen.gluten,
            details: 'wheat, barley',
          ),
        ]);
        expect(result, 'CELERY, GLUTEN [wheat, barley]');
      });

      test('should format gluten and nuts each with their own details', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(
            allergen: UkAllergen.gluten,
            details: 'wheat, barley',
          ),
          const AllergenInfo(
            allergen: UkAllergen.nuts,
            details: 'walnut, almond',
          ),
        ]);
        expect(result, 'GLUTEN [wheat, barley], NUTS [walnut, almond]');
      });

      test(
        'should format definite allergen with details alongside may-contain allergens',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.celery),
            const AllergenInfo(allergen: UkAllergen.nuts, details: 'walnut'),
            const AllergenInfo(allergen: UkAllergen.sulphites),
            const AllergenInfo(allergen: UkAllergen.eggs, mayContain: true),
            const AllergenInfo(allergen: UkAllergen.soya, mayContain: true),
          ]);
          expect(
            result,
            'CELERY, NUTS [walnut], SULPHITES, MAY CONTAIN EGGS, SOYA',
          );
        },
      );

      test(
        'should format may-contain allergen with details when mixed with definites',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.milk),
            const AllergenInfo(
              allergen: UkAllergen.nuts,
              mayContain: true,
              details: 'walnut',
            ),
          ]);
          expect(result, 'MILK, MAY CONTAIN NUTS [walnut]');
        },
      );

      // ------------------------------------------------------------------
      // All 14 allergens present at once
      // ------------------------------------------------------------------

      test(
        'should include all 14 allergen shortNames when all are provided',
        () {
          final allergens = UkAllergen.values
              .map((a) => AllergenInfo(allergen: a))
              .toList();
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
          expect(result, contains('SULPHITES'));
        },
      );

      test(
        'should produce a non-empty result when all 14 allergens are provided',
        () {
          final allergens = UkAllergen.values
              .map((a) => AllergenInfo(allergen: a))
              .toList();
          final result = AllergenFormatter.formatForDisplay(allergens);
          expect(result, isNotEmpty);
        },
      );

      test(
        'should produce exactly 13 comma-separators when all 14 allergens are definite',
        () {
          final allergens = UkAllergen.values
              .map((a) => AllergenInfo(allergen: a))
              .toList();
          final result = AllergenFormatter.formatForDisplay(allergens);
          final commaCount = ', '.allMatches(result).length;
          expect(commaCount, 13);
        },
      );

      // ------------------------------------------------------------------
      // Input order independence — alphabetical sort verified
      // ------------------------------------------------------------------

      test('should produce the same output regardless of input order', () {
        const set1 = [
          AllergenInfo(allergen: UkAllergen.milk),
          AllergenInfo(allergen: UkAllergen.celery),
        ];
        const set2 = [
          AllergenInfo(allergen: UkAllergen.celery),
          AllergenInfo(allergen: UkAllergen.milk),
        ];
        expect(
          AllergenFormatter.formatForDisplay(set1),
          AllergenFormatter.formatForDisplay(set2),
        );
      });

      // ------------------------------------------------------------------
      // Output format structure
      // ------------------------------------------------------------------

      test(
        'should not contain lowercase allergen shortNames in the output',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.milk),
            const AllergenInfo(allergen: UkAllergen.celery),
          ]);
          expect(result, isNot(contains('milk')));
          expect(result, isNot(contains('celery')));
        },
      );

      test('should not start with a comma or space', () {
        final result = AllergenFormatter.formatForDisplay([
          const AllergenInfo(allergen: UkAllergen.milk),
        ]);
        expect(result.startsWith(','), isFalse);
        expect(result.startsWith(' '), isFalse);
      });

      test(
        'should not end with a comma or space when there are multiple allergens',
        () {
          final result = AllergenFormatter.formatForDisplay([
            const AllergenInfo(allergen: UkAllergen.milk),
            const AllergenInfo(allergen: UkAllergen.celery),
          ]);
          expect(result.endsWith(','), isFalse);
          expect(result.endsWith(' '), isFalse);
        },
      );
    });
  });
}
