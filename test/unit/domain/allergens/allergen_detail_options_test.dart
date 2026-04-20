import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_detail_options.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';

void main() {
  group('AllergenDetailOptions', () {
    group('cerealOptions', () {
      test('contains the UK FSA cereals containing gluten', () {
        expect(AllergenDetailOptions.cerealOptions, const [
          'barley',
          'kamut',
          'oats',
          'rye',
          'spelt',
          'wheat',
        ]);
      });

      test('is sorted ascending alphabetical', () {
        final sorted = [...AllergenDetailOptions.cerealOptions]..sort();
        expect(AllergenDetailOptions.cerealOptions, sorted);
      });

      test('is all lowercase', () {
        for (final entry in AllergenDetailOptions.cerealOptions) {
          expect(
            entry,
            entry.toLowerCase(),
            reason: '$entry must be lowercase',
          );
        }
      });
    });

    group('nutOptions', () {
      test('contains the UK FSA tree nuts (peanuts excluded)', () {
        expect(AllergenDetailOptions.nutOptions, const [
          'almond',
          'brazil nut',
          'cashew',
          'hazelnut',
          'macadamia nut',
          'pecan',
          'pistachio',
          'walnut',
        ]);
      });

      test('is sorted ascending alphabetical', () {
        final sorted = [...AllergenDetailOptions.nutOptions]..sort();
        expect(AllergenDetailOptions.nutOptions, sorted);
      });

      test('is all lowercase', () {
        for (final entry in AllergenDetailOptions.nutOptions) {
          expect(
            entry,
            entry.toLowerCase(),
            reason: '$entry must be lowercase',
          );
        }
      });

      test('does not include peanut (peanuts are a separate allergen)', () {
        expect(AllergenDetailOptions.nutOptions.contains('peanut'), isFalse);
      });
    });

    group('forAllergen', () {
      test('returns cerealOptions for gluten', () {
        expect(
          AllergenDetailOptions.forAllergen(UkAllergen.gluten),
          AllergenDetailOptions.cerealOptions,
        );
      });

      test('returns nutOptions for nuts', () {
        expect(
          AllergenDetailOptions.forAllergen(UkAllergen.nuts),
          AllergenDetailOptions.nutOptions,
        );
      });

      test('returns empty for all other allergens', () {
        for (final allergen in UkAllergen.values) {
          if (allergen == UkAllergen.gluten || allergen == UkAllergen.nuts) {
            continue;
          }
          expect(
            AllergenDetailOptions.forAllergen(allergen),
            isEmpty,
            reason: '${allergen.name} should have no detail options',
          );
        }
      });
    });
  });
}
