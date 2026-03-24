import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';

part 'set_menu_dish_props.freezed.dart';
part 'set_menu_dish_props.g.dart';

/// Properties for the SetMenuDishWidget
///
/// Represents a set menu dish with no individual price, but an optional
/// supplement surcharge. Used in fixed-price/set menus.
@freezed
abstract class SetMenuDishProps with _$SetMenuDishProps {
  const SetMenuDishProps._();

  @JsonSerializable(explicitToJson: true)
  const factory SetMenuDishProps({
    required String name,
    String? description,
    int? calories,
    @Default([]) List<String> allergens,
    @Default([]) List<AllergenInfo> allergenInfo,
    DietaryType? dietary,
    @Default(false) bool hasSupplement,
    @Default(0.0) double supplementPrice,
  }) = _SetMenuDishProps;

  factory SetMenuDishProps.fromJson(Map<String, dynamic> json) =>
      _$SetMenuDishPropsFromJson(json);

  /// Get effective allergen info, migrating from legacy format if needed
  List<AllergenInfo> get effectiveAllergenInfo {
    if (allergenInfo.isNotEmpty) return allergenInfo;
    return allergens
        .map((s) => AllergenInfo.fromLegacyString(s))
        .whereType<AllergenInfo>()
        .toList();
  }

  /// Display name: uppercased dish name with optional dietary abbreviation
  String get displayName {
    final upper = name.toUpperCase();
    if (dietary == null) return upper;
    return '$upper ${dietary!.abbreviation}';
  }

  /// Supplement text (e.g. "Supplement 5" or "Supplement 7.5")
  /// Returns empty string when no supplement or price is 0
  String get supplementText {
    if (!hasSupplement || supplementPrice <= 0) return '';
    final priceStr = supplementPrice
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'\.?0+$'), '');
    return 'Supplement $priceStr';
  }
}
