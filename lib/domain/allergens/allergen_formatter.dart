import 'allergen_info.dart';

/// Utility class for formatting allergen information for display
///
/// Provides UK-compliant allergen formatting for menus with:
/// - Alphabetically ordered allergens
/// - Names in CAPITAL LETTERS
/// - Details in lowercase brackets
/// - "MAY CONTAIN" prefix for potential allergens
class AllergenFormatter {
  const AllergenFormatter._();

  /// Format allergen info list for UK-compliant menu display
  ///
  /// Output format:
  /// - Definite allergens first, then may-contain allergens
  /// - Each group alphabetically ordered by short name
  /// - Names in CAPITAL LETTERS
  /// - Details in lowercase brackets
  /// - "MAY CONTAIN" prefix for potential allergens
  ///
  /// Example output:
  /// `CELERY, GLUTEN [wheat, barley], NUTS [walnut], MAY CONTAIN EGGS, SOYA`
  static String formatForDisplay(List<AllergenInfo> allergenInfoList) {
    if (allergenInfoList.isEmpty) return '';

    // Separate definite and may-contain allergens
    final definite = allergenInfoList.where((a) => !a.mayContain).toList();
    final mayContain = allergenInfoList.where((a) => a.mayContain).toList();

    // Sort each list alphabetically by short name
    definite.sort(
        (a, b) => a.allergen.shortName.compareTo(b.allergen.shortName));
    mayContain.sort(
        (a, b) => a.allergen.shortName.compareTo(b.allergen.shortName));

    final parts = <String>[];

    // Add definite allergens
    for (final info in definite) {
      parts.add(_formatSingleAllergen(info));
    }

    // Add may-contain allergens with prefix
    if (mayContain.isNotEmpty) {
      final mayContainParts =
          mayContain.map((info) => _formatSingleAllergen(info)).join(', ');
      parts.add('MAY CONTAIN $mayContainParts');
    }

    return parts.join(', ');
  }

  /// Format a single allergen entry
  static String _formatSingleAllergen(AllergenInfo info) {
    final name = info.allergen.shortName;
    if (info.details != null && info.details!.trim().isNotEmpty) {
      return '$name [${info.details!.toLowerCase().trim()}]';
    }
    return name;
  }
}
