import 'uk_allergen.dart';

/// Fixed dictionaries of allowed detail values for allergens that support
/// details specification (gluten and nuts).
///
/// All entries are lowercase and pre-sorted in ascending alphabetical order so
/// iteration order matches the order they should be displayed in the UI.
class AllergenDetailOptions {
  const AllergenDetailOptions._();

  /// Cereals containing gluten — UK FSA Regulation (EU) No 1169/2011 Annex II.
  static const List<String> cerealOptions = [
    'barley',
    'kamut',
    'oats',
    'rye',
    'spelt',
    'wheat',
  ];

  /// Tree nuts — UK FSA Annex II. Peanuts are a separate allergen and excluded.
  static const List<String> nutOptions = [
    'almond',
    'brazil nut',
    'cashew',
    'hazelnut',
    'macadamia nut',
    'pecan',
    'pistachio',
    'walnut',
  ];

  /// Returns the allowed detail options for an allergen, or an empty list for
  /// allergens that don't support details.
  static List<String> forAllergen(UkAllergen allergen) {
    switch (allergen) {
      case UkAllergen.gluten:
        return cerealOptions;
      case UkAllergen.nuts:
        return nutOptions;
      default:
        return const [];
    }
  }
}
