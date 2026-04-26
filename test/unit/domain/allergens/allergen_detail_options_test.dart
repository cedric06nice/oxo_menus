import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_detail_options.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';

void main() {
  group('AllergenDetailOptions', () {
    group('cerealOptions', () {
      test('should contain exactly 6 cereal entries', () {
        expect(AllergenDetailOptions.cerealOptions.length, 6);
      });

      test('should contain barley', () {
        expect(AllergenDetailOptions.cerealOptions, contains('barley'));
      });

      test('should contain kamut', () {
        expect(AllergenDetailOptions.cerealOptions, contains('kamut'));
      });

      test('should contain oats', () {
        expect(AllergenDetailOptions.cerealOptions, contains('oats'));
      });

      test('should contain rye', () {
        expect(AllergenDetailOptions.cerealOptions, contains('rye'));
      });

      test('should contain spelt', () {
        expect(AllergenDetailOptions.cerealOptions, contains('spelt'));
      });

      test('should contain wheat', () {
        expect(AllergenDetailOptions.cerealOptions, contains('wheat'));
      });

      test('should be in ascending alphabetical order', () {
        final sorted = [...AllergenDetailOptions.cerealOptions]..sort();
        expect(AllergenDetailOptions.cerealOptions, sorted);
      });

      test('should be all lowercase', () {
        final nonLowercaseEntries = AllergenDetailOptions.cerealOptions
            .where((entry) => entry != entry.toLowerCase())
            .toList();
        expect(nonLowercaseEntries, isEmpty);
      });

      test('should match the complete UK FSA cereal list exactly', () {
        expect(AllergenDetailOptions.cerealOptions, const [
          'barley',
          'kamut',
          'oats',
          'rye',
          'spelt',
          'wheat',
        ]);
      });
    });

    group('nutOptions', () {
      test('should contain exactly 8 nut entries', () {
        expect(AllergenDetailOptions.nutOptions.length, 8);
      });

      test('should contain almond', () {
        expect(AllergenDetailOptions.nutOptions, contains('almond'));
      });

      test('should contain brazil nut', () {
        expect(AllergenDetailOptions.nutOptions, contains('brazil nut'));
      });

      test('should contain cashew', () {
        expect(AllergenDetailOptions.nutOptions, contains('cashew'));
      });

      test('should contain hazelnut', () {
        expect(AllergenDetailOptions.nutOptions, contains('hazelnut'));
      });

      test('should contain macadamia nut', () {
        expect(AllergenDetailOptions.nutOptions, contains('macadamia nut'));
      });

      test('should contain pecan', () {
        expect(AllergenDetailOptions.nutOptions, contains('pecan'));
      });

      test('should contain pistachio', () {
        expect(AllergenDetailOptions.nutOptions, contains('pistachio'));
      });

      test('should contain walnut', () {
        expect(AllergenDetailOptions.nutOptions, contains('walnut'));
      });

      test(
        'should not contain peanut because peanuts are a separate allergen',
        () {
          expect(AllergenDetailOptions.nutOptions, isNot(contains('peanut')));
        },
      );

      test('should be in ascending alphabetical order', () {
        final sorted = [...AllergenDetailOptions.nutOptions]..sort();
        expect(AllergenDetailOptions.nutOptions, sorted);
      });

      test('should be all lowercase', () {
        final nonLowercaseEntries = AllergenDetailOptions.nutOptions
            .where((entry) => entry != entry.toLowerCase())
            .toList();
        expect(nonLowercaseEntries, isEmpty);
      });

      test('should match the complete UK FSA tree nut list exactly', () {
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
    });

    group('forAllergen', () {
      test('should return cerealOptions for gluten', () {
        expect(
          AllergenDetailOptions.forAllergen(UkAllergen.gluten),
          AllergenDetailOptions.cerealOptions,
        );
      });

      test('should return nutOptions for nuts', () {
        expect(
          AllergenDetailOptions.forAllergen(UkAllergen.nuts),
          AllergenDetailOptions.nutOptions,
        );
      });

      test('should return empty list for celery', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.celery), isEmpty);
      });

      test('should return empty list for crustaceans', () {
        expect(
          AllergenDetailOptions.forAllergen(UkAllergen.crustaceans),
          isEmpty,
        );
      });

      test('should return empty list for eggs', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.eggs), isEmpty);
      });

      test('should return empty list for fish', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.fish), isEmpty);
      });

      test('should return empty list for lupin', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.lupin), isEmpty);
      });

      test('should return empty list for milk', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.milk), isEmpty);
      });

      test('should return empty list for molluscs', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.molluscs), isEmpty);
      });

      test('should return empty list for mustard', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.mustard), isEmpty);
      });

      test('should return empty list for peanuts', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.peanuts), isEmpty);
      });

      test('should return empty list for sesame', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.sesame), isEmpty);
      });

      test('should return empty list for soya', () {
        expect(AllergenDetailOptions.forAllergen(UkAllergen.soya), isEmpty);
      });

      test('should return empty list for sulphites', () {
        expect(
          AllergenDetailOptions.forAllergen(UkAllergen.sulphites),
          isEmpty,
        );
      });

      test('should return non-empty options for exactly 2 allergens', () {
        final allergensWithOptions = UkAllergen.values
            .where((a) => AllergenDetailOptions.forAllergen(a).isNotEmpty)
            .toList();
        expect(allergensWithOptions.length, 2);
      });

      test('should return empty options for exactly 12 allergens', () {
        final allergensWithoutOptions = UkAllergen.values
            .where((a) => AllergenDetailOptions.forAllergen(a).isEmpty)
            .toList();
        expect(allergensWithoutOptions.length, 12);
      });
    });
  });
}
