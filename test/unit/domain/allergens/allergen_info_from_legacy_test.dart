import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/allergens/uk_allergen.dart';

/// Tests for AllergenInfo.fromLegacyString comprehensive mapping table.
///
/// Prevents regression: legacy allergen data silently dropped or misclassified
/// during v1→v2 migration. Covers all 35+ mapping entries.
void main() {
  group('AllergenInfo.fromLegacyString — comprehensive mapping', () {
    group('dairy/milk synonyms', () {
      test('should map "lactose" to milk', () {
        final info = AllergenInfo.fromLegacyString('lactose');
        expect(info!.allergen, UkAllergen.milk);
        expect(info.details, isNull);
      });

      test('should map "cream" to milk', () {
        expect(
          AllergenInfo.fromLegacyString('cream')!.allergen,
          UkAllergen.milk,
        );
      });

      test('should map "butter" to milk', () {
        expect(
          AllergenInfo.fromLegacyString('butter')!.allergen,
          UkAllergen.milk,
        );
      });

      test('should map "cheese" to milk', () {
        expect(
          AllergenInfo.fromLegacyString('cheese')!.allergen,
          UkAllergen.milk,
        );
      });
    });

    group('gluten sources — should preserve specific cereal as details', () {
      test('should map "barley" to gluten with details', () {
        final info = AllergenInfo.fromLegacyString('barley');
        expect(info!.allergen, UkAllergen.gluten);
        expect(info.details, 'barley');
      });

      test('should map "rye" to gluten with details', () {
        final info = AllergenInfo.fromLegacyString('rye');
        expect(info!.allergen, UkAllergen.gluten);
        expect(info.details, 'rye');
      });

      test('should map "oats" to gluten with details', () {
        final info = AllergenInfo.fromLegacyString('oats');
        expect(info!.allergen, UkAllergen.gluten);
        expect(info.details, 'oats');
      });

      test('should map "spelt" to gluten with details', () {
        final info = AllergenInfo.fromLegacyString('spelt');
        expect(info!.allergen, UkAllergen.gluten);
        expect(info.details, 'spelt');
      });

      test('should map "wheat" to gluten WITHOUT details (generic)', () {
        final info = AllergenInfo.fromLegacyString('wheat');
        expect(info!.allergen, UkAllergen.gluten);
        expect(info.details, isNull);
      });

      test('should map "gluten" to gluten WITHOUT details (generic)', () {
        final info = AllergenInfo.fromLegacyString('gluten');
        expect(info!.allergen, UkAllergen.gluten);
        expect(info.details, isNull);
      });
    });

    group('crustacean synonyms', () {
      test('should map "shrimp" to crustaceans', () {
        expect(
          AllergenInfo.fromLegacyString('shrimp')!.allergen,
          UkAllergen.crustaceans,
        );
      });

      test('should map "crab" to crustaceans', () {
        expect(
          AllergenInfo.fromLegacyString('crab')!.allergen,
          UkAllergen.crustaceans,
        );
      });

      test('should map "lobster" to crustaceans', () {
        expect(
          AllergenInfo.fromLegacyString('lobster')!.allergen,
          UkAllergen.crustaceans,
        );
      });

      test('should map "prawns" to crustaceans', () {
        expect(
          AllergenInfo.fromLegacyString('prawns')!.allergen,
          UkAllergen.crustaceans,
        );
      });
    });

    group('nut variants — should preserve specific nut as details', () {
      test('should map "cashews" to nuts with details', () {
        final info = AllergenInfo.fromLegacyString('cashews');
        expect(info!.allergen, UkAllergen.nuts);
        expect(info.details, 'cashews');
      });

      test('should map "hazelnuts" to nuts with details', () {
        final info = AllergenInfo.fromLegacyString('hazelnuts');
        expect(info!.allergen, UkAllergen.nuts);
        expect(info.details, 'hazelnuts');
      });

      test('should map "pistachios" to nuts with details', () {
        final info = AllergenInfo.fromLegacyString('pistachios');
        expect(info!.allergen, UkAllergen.nuts);
        expect(info.details, 'pistachios');
      });

      test('should map "pecans" to nuts with details', () {
        final info = AllergenInfo.fromLegacyString('pecans');
        expect(info!.allergen, UkAllergen.nuts);
        expect(info.details, 'pecans');
      });

      test('should map "macadamia" to nuts with details', () {
        final info = AllergenInfo.fromLegacyString('macadamia');
        expect(info!.allergen, UkAllergen.nuts);
        expect(info.details, 'macadamia');
      });

      test('should map "brazil nuts" to nuts with details', () {
        final info = AllergenInfo.fromLegacyString('brazil nuts');
        expect(info!.allergen, UkAllergen.nuts);
        expect(info.details, 'brazil nuts');
      });

      test('should map generic "nuts" WITHOUT details', () {
        final info = AllergenInfo.fromLegacyString('nuts');
        expect(info!.allergen, UkAllergen.nuts);
        expect(info.details, isNull);
      });

      test('should map "treenuts" (no space) WITHOUT details', () {
        final info = AllergenInfo.fromLegacyString('treenuts');
        expect(info!.allergen, UkAllergen.nuts);
        expect(info.details, isNull);
      });
    });

    group('sulphites variants', () {
      test('should map "so2" to sulphites', () {
        expect(
          AllergenInfo.fromLegacyString('so2')!.allergen,
          UkAllergen.sulphites,
        );
      });

      test('should map "sulfur dioxide" to sulphites', () {
        expect(
          AllergenInfo.fromLegacyString('sulfur dioxide')!.allergen,
          UkAllergen.sulphites,
        );
      });

      test('should map "sulphur dioxide" to sulphites', () {
        expect(
          AllergenInfo.fromLegacyString('sulphur dioxide')!.allergen,
          UkAllergen.sulphites,
        );
      });
    });

    group('soya variants', () {
      test('should map "soybeans" to soya', () {
        expect(
          AllergenInfo.fromLegacyString('soybeans')!.allergen,
          UkAllergen.soya,
        );
      });

      test('should map "soybean" to soya', () {
        expect(
          AllergenInfo.fromLegacyString('soybean')!.allergen,
          UkAllergen.soya,
        );
      });
    });

    group('other mappings', () {
      test('should map "egg" (singular) to eggs', () {
        expect(
          AllergenInfo.fromLegacyString('egg')!.allergen,
          UkAllergen.eggs,
        );
      });

      test('should map "sesame seeds" to sesame', () {
        expect(
          AllergenInfo.fromLegacyString('sesame seeds')!.allergen,
          UkAllergen.sesame,
        );
      });
    });

    group('heuristic edge cases', () {
      test('"gluten-free" matches gluten heuristic (documents behavior)', () {
        // This is a known false positive from the contains('gluten') heuristic.
        // Documenting current behavior so any fix doesn't break unknowingly.
        final info = AllergenInfo.fromLegacyString('gluten-free');
        expect(info!.allergen, UkAllergen.gluten);
      });

      test('"coconut" matches nut heuristic (documents behavior)', () {
        // "coconut" contains "nut" — heuristic match.
        final info = AllergenInfo.fromLegacyString('coconut');
        expect(info!.allergen, UkAllergen.nuts);
        expect(info.details, 'coconut');
      });

      test('"peanut" matches nut heuristic (but peanuts is a separate allergen)', () {
        // Note: "peanut" is not in the explicit mapping table, but "peanuts" is
        // an enum value. "peanut" (singular) falls through to the contains('nut')
        // heuristic and maps to nuts — NOT peanuts.
        final info = AllergenInfo.fromLegacyString('peanut');
        // If it matches enum 'peanuts' directly, it would be UkAllergen.peanuts.
        // Otherwise, the "nut" heuristic maps it to UkAllergen.nuts.
        expect(info, isNotNull);
        // Documenting actual behavior:
        expect(info!.allergen, UkAllergen.nuts);
      });

      test('"peanuts" (enum name) maps to UkAllergen.peanuts directly', () {
        final info = AllergenInfo.fromLegacyString('peanuts');
        expect(info!.allergen, UkAllergen.peanuts);
      });
    });

    group('unmappable strings', () {
      test('should return null for "pineapple"', () {
        expect(AllergenInfo.fromLegacyString('pineapple'), isNull);
      });

      test('should return null for "tomato"', () {
        expect(AllergenInfo.fromLegacyString('tomato'), isNull);
      });

      test('should return null for empty string', () {
        expect(AllergenInfo.fromLegacyString(''), isNull);
      });
    });
  });
}
