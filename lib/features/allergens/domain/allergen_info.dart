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
}
