import 'package:freezed_annotation/freezed_annotation.dart';
import 'uk_allergen.dart';

part 'allergen_info.freezed.dart';
part 'allergen_info.g.dart';

/// Represents an allergen selection with optional details and "may contain" flag
///
/// Used to track which allergens a dish contains, whether it definitely contains
/// or may contain the allergen, and any specific details (for gluten and nuts).
@freezed
abstract class AllergenInfo with _$AllergenInfo {
  const AllergenInfo._();

  const factory AllergenInfo({
    /// The UK allergen type
    required UkAllergen allergen,

    /// Whether this is a "may contain" vs definite contains
    @Default(false) bool mayContain,

    /// Optional details (for gluten: specific cereals; for nuts: specific nuts)
    String? details,
  }) = _AllergenInfo;

  factory AllergenInfo.fromJson(Map<String, dynamic> json) =>
      _$AllergenInfoFromJson(json);

  /// Create from a simple string (for migration from old format)
  ///
  /// Attempts to map common allergen strings to the UK allergen enum.
  /// Returns null if the string cannot be mapped.
  static AllergenInfo? fromLegacyString(String allergenString) {
    final normalized = allergenString.toLowerCase().trim();

    // Direct match with enum name
    for (final allergen in UkAllergen.values) {
      if (allergen.name == normalized) {
        return AllergenInfo(allergen: allergen);
      }
    }

    // Common mappings for legacy data
    final mappings = <String, UkAllergen>{
      // Milk/Dairy variants
      'dairy': UkAllergen.milk,
      'lactose': UkAllergen.milk,
      'cream': UkAllergen.milk,
      'butter': UkAllergen.milk,
      'cheese': UkAllergen.milk,

      // Gluten/Wheat variants
      'wheat': UkAllergen.gluten,
      'barley': UkAllergen.gluten,
      'rye': UkAllergen.gluten,
      'oats': UkAllergen.gluten,
      'spelt': UkAllergen.gluten,

      // Crustaceans variants
      'shellfish': UkAllergen.crustaceans,
      'shrimp': UkAllergen.crustaceans,
      'crab': UkAllergen.crustaceans,
      'lobster': UkAllergen.crustaceans,
      'prawns': UkAllergen.crustaceans,

      // Nuts variants
      'tree nuts': UkAllergen.nuts,
      'treenuts': UkAllergen.nuts,
      'almonds': UkAllergen.nuts,
      'almond': UkAllergen.nuts,
      'walnuts': UkAllergen.nuts,
      'walnut': UkAllergen.nuts,
      'cashews': UkAllergen.nuts,
      'cashew': UkAllergen.nuts,
      'hazelnuts': UkAllergen.nuts,
      'hazelnut': UkAllergen.nuts,
      'pistachios': UkAllergen.nuts,
      'pistachio': UkAllergen.nuts,
      'pecans': UkAllergen.nuts,
      'pecan': UkAllergen.nuts,
      'macadamia': UkAllergen.nuts,
      'brazil nuts': UkAllergen.nuts,

      // Sulphites variants
      'sulfites': UkAllergen.sulphites,
      'sulphites': UkAllergen.sulphites,
      'sulfur dioxide': UkAllergen.sulphites,
      'sulphur dioxide': UkAllergen.sulphites,
      'so2': UkAllergen.sulphites,

      // Soya variants
      'soy': UkAllergen.soya,
      'soybeans': UkAllergen.soya,
      'soybean': UkAllergen.soya,

      // Egg variants
      'egg': UkAllergen.eggs,

      // Sesame variants
      'sesame seeds': UkAllergen.sesame,
    };

    if (mappings.containsKey(normalized)) {
      final allergen = mappings[normalized]!;
      // If it's a specific type of nut or gluten source, include as details
      if (allergen == UkAllergen.nuts &&
          normalized != 'nuts' &&
          normalized != 'tree nuts' &&
          normalized != 'treenuts') {
        return AllergenInfo(allergen: allergen, details: allergenString);
      }
      if (allergen == UkAllergen.gluten &&
          normalized != 'gluten' &&
          normalized != 'wheat') {
        return AllergenInfo(allergen: allergen, details: allergenString);
      }
      return AllergenInfo(allergen: allergen);
    }

    // Check if contains "nut" (e.g., "Tree Nuts", "Mixed Nuts")
    if (normalized.contains('nut')) {
      return AllergenInfo(allergen: UkAllergen.nuts, details: allergenString);
    }

    // Check for gluten-related terms
    if (normalized.contains('gluten')) {
      return AllergenInfo(allergen: UkAllergen.gluten);
    }

    // Cannot map - return null
    return null;
  }
}
