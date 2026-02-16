/// The 14 official UK allergens as defined by UK Food Standards Agency
///
/// These are the allergens that must be declared on food labels and menus
/// under UK food labeling regulations.
enum UkAllergen {
  celery,
  gluten,
  crustaceans,
  eggs,
  fish,
  lupin,
  milk,
  molluscs,
  mustard,
  nuts,
  peanuts,
  sesame,
  soya,
  sulphites;

  /// Display name for UI (user-friendly label)
  String get displayName {
    switch (this) {
      case UkAllergen.celery:
        return 'Celery';
      case UkAllergen.gluten:
        return 'Cereals containing gluten';
      case UkAllergen.crustaceans:
        return 'Crustaceans';
      case UkAllergen.eggs:
        return 'Eggs';
      case UkAllergen.fish:
        return 'Fish';
      case UkAllergen.lupin:
        return 'Lupin';
      case UkAllergen.milk:
        return 'Milk';
      case UkAllergen.molluscs:
        return 'Molluscs';
      case UkAllergen.mustard:
        return 'Mustard';
      case UkAllergen.nuts:
        return 'Nuts (tree nuts)';
      case UkAllergen.peanuts:
        return 'Peanuts';
      case UkAllergen.sesame:
        return 'Sesame';
      case UkAllergen.soya:
        return 'Soya';
      case UkAllergen.sulphites:
        return 'Sulphur dioxide/sulphites';
    }
  }

  /// Short name for formatted output (CAPITALS for menu display)
  String get shortName {
    switch (this) {
      case UkAllergen.celery:
        return 'CELERY';
      case UkAllergen.gluten:
        return 'GLUTEN';
      case UkAllergen.crustaceans:
        return 'CRUSTACEANS';
      case UkAllergen.eggs:
        return 'EGGS';
      case UkAllergen.fish:
        return 'FISH';
      case UkAllergen.lupin:
        return 'LUPIN';
      case UkAllergen.milk:
        return 'MILK';
      case UkAllergen.molluscs:
        return 'MOLLUSCS';
      case UkAllergen.mustard:
        return 'MUSTARD';
      case UkAllergen.nuts:
        return 'NUTS';
      case UkAllergen.peanuts:
        return 'PEANUTS';
      case UkAllergen.sesame:
        return 'SESAME';
      case UkAllergen.soya:
        return 'SOYA';
      case UkAllergen.sulphites:
        return 'SULPHITES';
    }
  }

  /// Whether this allergen supports detail specification
  /// (for specifying which cereals contain gluten or which tree nuts)
  bool get supportsDetails {
    return this == UkAllergen.gluten || this == UkAllergen.nuts;
  }

  /// Hint text for the details field
  String? get detailsHint {
    switch (this) {
      case UkAllergen.gluten:
        return 'e.g., wheat, rye, barley, oats';
      case UkAllergen.nuts:
        return 'e.g., walnut, almond, cashew, hazelnut';
      default:
        return null;
    }
  }

  /// Parse from JSON string value
  static UkAllergen? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    for (final allergen in UkAllergen.values) {
      if (allergen.name == normalized) {
        return allergen;
      }
    }
    return null;
  }
}
