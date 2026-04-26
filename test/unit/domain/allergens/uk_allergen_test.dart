import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_detail_options.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';

void main() {
  group('UkAllergen', () {
    group('enum completeness', () {
      test('should have exactly 14 allergen values', () {
        expect(UkAllergen.values.length, 14);
      });

      test('should contain all UK FSA mandated allergens', () {
        expect(
          UkAllergen.values,
          containsAll([
            UkAllergen.celery,
            UkAllergen.gluten,
            UkAllergen.crustaceans,
            UkAllergen.eggs,
            UkAllergen.fish,
            UkAllergen.lupin,
            UkAllergen.milk,
            UkAllergen.molluscs,
            UkAllergen.mustard,
            UkAllergen.nuts,
            UkAllergen.peanuts,
            UkAllergen.sesame,
            UkAllergen.soya,
            UkAllergen.sulphites,
          ]),
        );
      });
    });

    group('displayName', () {
      test('should return non-empty displayName for every allergen', () {
        final emptyDisplayNames = UkAllergen.values
            .where((a) => a.displayName.isEmpty)
            .toList();
        expect(emptyDisplayNames, isEmpty);
      });

      test('should return correct displayName for celery', () {
        expect(UkAllergen.celery.displayName, 'Celery');
      });

      test('should return correct displayName for gluten', () {
        expect(UkAllergen.gluten.displayName, 'Cereals containing gluten');
      });

      test('should return correct displayName for crustaceans', () {
        expect(UkAllergen.crustaceans.displayName, 'Crustaceans');
      });

      test('should return correct displayName for eggs', () {
        expect(UkAllergen.eggs.displayName, 'Eggs');
      });

      test('should return correct displayName for fish', () {
        expect(UkAllergen.fish.displayName, 'Fish');
      });

      test('should return correct displayName for lupin', () {
        expect(UkAllergen.lupin.displayName, 'Lupin');
      });

      test('should return correct displayName for milk', () {
        expect(UkAllergen.milk.displayName, 'Milk');
      });

      test('should return correct displayName for molluscs', () {
        expect(UkAllergen.molluscs.displayName, 'Molluscs');
      });

      test('should return correct displayName for mustard', () {
        expect(UkAllergen.mustard.displayName, 'Mustard');
      });

      test('should return correct displayName for nuts', () {
        expect(UkAllergen.nuts.displayName, 'Nuts (tree nuts)');
      });

      test('should return correct displayName for peanuts', () {
        expect(UkAllergen.peanuts.displayName, 'Peanuts');
      });

      test('should return correct displayName for sesame', () {
        expect(UkAllergen.sesame.displayName, 'Sesame');
      });

      test('should return correct displayName for soya', () {
        expect(UkAllergen.soya.displayName, 'Soya');
      });

      test('should return correct displayName for sulphites', () {
        expect(UkAllergen.sulphites.displayName, 'Sulphur dioxide/sulphites');
      });
    });

    group('shortName', () {
      test('should return non-empty shortName for every allergen', () {
        final emptyShortNames = UkAllergen.values
            .where((a) => a.shortName.isEmpty)
            .toList();
        expect(emptyShortNames, isEmpty);
      });

      test('should return all-uppercase shortName for every allergen', () {
        final nonUppercaseAllergens = UkAllergen.values
            .where((a) => a.shortName != a.shortName.toUpperCase())
            .toList();
        expect(nonUppercaseAllergens, isEmpty);
      });

      test('should return correct shortName for celery', () {
        expect(UkAllergen.celery.shortName, 'CELERY');
      });

      test('should return correct shortName for gluten', () {
        expect(UkAllergen.gluten.shortName, 'GLUTEN');
      });

      test('should return correct shortName for crustaceans', () {
        expect(UkAllergen.crustaceans.shortName, 'CRUSTACEANS');
      });

      test('should return correct shortName for eggs', () {
        expect(UkAllergen.eggs.shortName, 'EGGS');
      });

      test('should return correct shortName for fish', () {
        expect(UkAllergen.fish.shortName, 'FISH');
      });

      test('should return correct shortName for lupin', () {
        expect(UkAllergen.lupin.shortName, 'LUPIN');
      });

      test('should return correct shortName for milk', () {
        expect(UkAllergen.milk.shortName, 'MILK');
      });

      test('should return correct shortName for molluscs', () {
        expect(UkAllergen.molluscs.shortName, 'MOLLUSCS');
      });

      test('should return correct shortName for mustard', () {
        expect(UkAllergen.mustard.shortName, 'MUSTARD');
      });

      test('should return correct shortName for nuts', () {
        expect(UkAllergen.nuts.shortName, 'NUTS');
      });

      test('should return correct shortName for peanuts', () {
        expect(UkAllergen.peanuts.shortName, 'PEANUTS');
      });

      test('should return correct shortName for sesame', () {
        expect(UkAllergen.sesame.shortName, 'SESAME');
      });

      test('should return correct shortName for soya', () {
        expect(UkAllergen.soya.shortName, 'SOYA');
      });

      test('should return correct shortName for sulphites', () {
        expect(UkAllergen.sulphites.shortName, 'SULPHITES');
      });
    });

    group('supportsDetails', () {
      test('should return true for gluten', () {
        expect(UkAllergen.gluten.supportsDetails, isTrue);
      });

      test('should return true for nuts', () {
        expect(UkAllergen.nuts.supportsDetails, isTrue);
      });

      test('should return false for celery', () {
        expect(UkAllergen.celery.supportsDetails, isFalse);
      });

      test('should return false for crustaceans', () {
        expect(UkAllergen.crustaceans.supportsDetails, isFalse);
      });

      test('should return false for eggs', () {
        expect(UkAllergen.eggs.supportsDetails, isFalse);
      });

      test('should return false for fish', () {
        expect(UkAllergen.fish.supportsDetails, isFalse);
      });

      test('should return false for lupin', () {
        expect(UkAllergen.lupin.supportsDetails, isFalse);
      });

      test('should return false for milk', () {
        expect(UkAllergen.milk.supportsDetails, isFalse);
      });

      test('should return false for molluscs', () {
        expect(UkAllergen.molluscs.supportsDetails, isFalse);
      });

      test('should return false for mustard', () {
        expect(UkAllergen.mustard.supportsDetails, isFalse);
      });

      test('should return false for peanuts', () {
        expect(UkAllergen.peanuts.supportsDetails, isFalse);
      });

      test('should return false for sesame', () {
        expect(UkAllergen.sesame.supportsDetails, isFalse);
      });

      test('should return false for soya', () {
        expect(UkAllergen.soya.supportsDetails, isFalse);
      });

      test('should return false for sulphites', () {
        expect(UkAllergen.sulphites.supportsDetails, isFalse);
      });

      test('should return false for exactly 12 allergens', () {
        final nonDetailAllergens = UkAllergen.values
            .where((a) => !a.supportsDetails)
            .toList();
        expect(nonDetailAllergens.length, 12);
      });
    });

    group('detailsHint', () {
      test('should return non-null hint for gluten', () {
        expect(UkAllergen.gluten.detailsHint, isNotNull);
      });

      test('should return non-null hint for nuts', () {
        expect(UkAllergen.nuts.detailsHint, isNotNull);
      });

      test('should return null hint for celery', () {
        expect(UkAllergen.celery.detailsHint, isNull);
      });

      test('should return null hint for eggs', () {
        expect(UkAllergen.eggs.detailsHint, isNull);
      });

      test('should return null hint for milk', () {
        expect(UkAllergen.milk.detailsHint, isNull);
      });

      test(
        'should return null hint for all allergens that do not support details',
        () {
          final nonDetailAllergens = UkAllergen.values
              .where((a) => !a.supportsDetails)
              .toList();
          final allergensWithHints = nonDetailAllergens
              .where((a) => a.detailsHint != null)
              .toList();
          expect(allergensWithHints, isEmpty);
        },
      );
    });

    group('detailOptions', () {
      test('should return cereal dictionary for gluten', () {
        expect(
          UkAllergen.gluten.detailOptions,
          AllergenDetailOptions.cerealOptions,
        );
      });

      test('should return nut dictionary for nuts', () {
        expect(UkAllergen.nuts.detailOptions, AllergenDetailOptions.nutOptions);
      });

      test('should return empty list for celery', () {
        expect(UkAllergen.celery.detailOptions, isEmpty);
      });

      test('should return empty list for crustaceans', () {
        expect(UkAllergen.crustaceans.detailOptions, isEmpty);
      });

      test('should return empty list for eggs', () {
        expect(UkAllergen.eggs.detailOptions, isEmpty);
      });

      test('should return empty list for fish', () {
        expect(UkAllergen.fish.detailOptions, isEmpty);
      });

      test('should return empty list for lupin', () {
        expect(UkAllergen.lupin.detailOptions, isEmpty);
      });

      test('should return empty list for milk', () {
        expect(UkAllergen.milk.detailOptions, isEmpty);
      });

      test('should return empty list for molluscs', () {
        expect(UkAllergen.molluscs.detailOptions, isEmpty);
      });

      test('should return empty list for mustard', () {
        expect(UkAllergen.mustard.detailOptions, isEmpty);
      });

      test('should return empty list for peanuts', () {
        expect(UkAllergen.peanuts.detailOptions, isEmpty);
      });

      test('should return empty list for sesame', () {
        expect(UkAllergen.sesame.detailOptions, isEmpty);
      });

      test('should return empty list for soya', () {
        expect(UkAllergen.soya.detailOptions, isEmpty);
      });

      test('should return empty list for sulphites', () {
        expect(UkAllergen.sulphites.detailOptions, isEmpty);
      });
    });

    group('fromString', () {
      test('should parse celery from lowercase string', () {
        expect(UkAllergen.fromString('celery'), UkAllergen.celery);
      });

      test('should parse gluten from lowercase string', () {
        expect(UkAllergen.fromString('gluten'), UkAllergen.gluten);
      });

      test('should parse crustaceans from lowercase string', () {
        expect(UkAllergen.fromString('crustaceans'), UkAllergen.crustaceans);
      });

      test('should parse eggs from lowercase string', () {
        expect(UkAllergen.fromString('eggs'), UkAllergen.eggs);
      });

      test('should parse fish from lowercase string', () {
        expect(UkAllergen.fromString('fish'), UkAllergen.fish);
      });

      test('should parse lupin from lowercase string', () {
        expect(UkAllergen.fromString('lupin'), UkAllergen.lupin);
      });

      test('should parse milk from lowercase string', () {
        expect(UkAllergen.fromString('milk'), UkAllergen.milk);
      });

      test('should parse molluscs from lowercase string', () {
        expect(UkAllergen.fromString('molluscs'), UkAllergen.molluscs);
      });

      test('should parse mustard from lowercase string', () {
        expect(UkAllergen.fromString('mustard'), UkAllergen.mustard);
      });

      test('should parse nuts from lowercase string', () {
        expect(UkAllergen.fromString('nuts'), UkAllergen.nuts);
      });

      test('should parse peanuts from lowercase string', () {
        expect(UkAllergen.fromString('peanuts'), UkAllergen.peanuts);
      });

      test('should parse sesame from lowercase string', () {
        expect(UkAllergen.fromString('sesame'), UkAllergen.sesame);
      });

      test('should parse soya from lowercase string', () {
        expect(UkAllergen.fromString('soya'), UkAllergen.soya);
      });

      test('should parse sulphites from lowercase string', () {
        expect(UkAllergen.fromString('sulphites'), UkAllergen.sulphites);
      });

      test('should parse allergen when input is all uppercase', () {
        expect(UkAllergen.fromString('CELERY'), UkAllergen.celery);
      });

      test('should parse allergen when input is mixed case', () {
        expect(UkAllergen.fromString('Gluten'), UkAllergen.gluten);
      });

      test('should parse allergen when input has leading whitespace', () {
        expect(UkAllergen.fromString('  celery'), UkAllergen.celery);
      });

      test('should parse allergen when input has trailing whitespace', () {
        expect(UkAllergen.fromString('celery  '), UkAllergen.celery);
      });

      test('should parse allergen when input has surrounding whitespace', () {
        expect(UkAllergen.fromString('  gluten  '), UkAllergen.gluten);
      });

      test(
        'should parse allergen when input has tab and newline whitespace',
        () {
          expect(UkAllergen.fromString('\tgluten\n'), UkAllergen.gluten);
        },
      );

      test('should return null for an empty string', () {
        expect(UkAllergen.fromString(''), isNull);
      });

      test('should return null for a string with only whitespace', () {
        expect(UkAllergen.fromString('   '), isNull);
      });

      test('should return null for a completely unknown string', () {
        expect(UkAllergen.fromString('invalid'), isNull);
      });

      test('should return null for a close-but-not-exact match', () {
        expect(UkAllergen.fromString('dairy'), isNull);
      });

      test('should return null for a partial allergen name', () {
        expect(UkAllergen.fromString('glut'), isNull);
      });

      test(
        'should return null for a string that is a superstring of an allergen name',
        () {
          expect(UkAllergen.fromString('glutens'), isNull);
        },
      );
    });

    group('equality', () {
      test('should be equal to itself', () {
        expect(UkAllergen.milk, UkAllergen.milk);
      });

      test('should not be equal to a different allergen', () {
        expect(UkAllergen.milk, isNot(UkAllergen.eggs));
      });
    });

    group('index', () {
      test('should have index 0 for celery (first in declaration order)', () {
        expect(UkAllergen.celery.index, 0);
      });

      test(
        'should have index 13 for sulphites (last in declaration order)',
        () {
          expect(UkAllergen.sulphites.index, 13);
        },
      );

      test('should have unique index for every allergen', () {
        final indices = UkAllergen.values.map((a) => a.index).toList();
        final uniqueIndices = indices.toSet();
        expect(uniqueIndices.length, UkAllergen.values.length);
      });

      test('should have consecutive indices from 0 to 13', () {
        final sortedIndices = UkAllergen.values.map((a) => a.index).toList()
          ..sort();
        expect(sortedIndices, List.generate(14, (i) => i));
      });
    });
  });
}
