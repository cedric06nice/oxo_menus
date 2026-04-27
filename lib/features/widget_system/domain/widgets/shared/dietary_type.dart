import 'package:freezed_annotation/freezed_annotation.dart';

/// Dietary type for a dish
///
/// Represents the two supported dietary classifications.
/// Serialized as lowercase string for JSON storage.
enum DietaryType {
  @JsonValue('vegetarian')
  vegetarian,

  @JsonValue('vegan')
  vegan;

  /// User-friendly display name
  String get displayName {
    switch (this) {
      case DietaryType.vegetarian:
        return 'Vegetarian';
      case DietaryType.vegan:
        return 'Vegan';
    }
  }

  /// Abbreviation shown inline after the dish name
  String get abbreviation {
    switch (this) {
      case DietaryType.vegetarian:
        return '(V)';
      case DietaryType.vegan:
        return '(Ve)';
    }
  }

  /// Parse from JSON string value (case-insensitive)
  static DietaryType? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    for (final type in DietaryType.values) {
      if (type.name == normalized) {
        return type;
      }
    }
    return null;
  }
}
