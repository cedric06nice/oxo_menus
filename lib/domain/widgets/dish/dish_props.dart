import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/widgets/dish/price_variant.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';

part 'dish_props.freezed.dart';
part 'dish_props.g.dart';

/// Properties for the DishWidget
@freezed
abstract class DishProps with _$DishProps {
  const DishProps._();

  @JsonSerializable(explicitToJson: true)
  const factory DishProps({
    required String name,
    required double price,
    String? description,
    int? calories,
    @Default([]) List<AllergenInfo> allergenInfo,
    DietaryType? dietary,
    @Default(<PriceVariant>[]) List<PriceVariant> priceVariants,
  }) = _DishProps;

  factory DishProps.fromJson(Map<String, dynamic> json) =>
      _$DishPropsFromJson(json);

  /// Whether the dish has labelled price variants (>1 price).
  bool get hasMultiplePrices => priceVariants.isNotEmpty;

  /// Display name: uppercased dish name with optional dietary abbreviation
  String get displayName {
    final upper = name.toUpperCase();
    if (dietary == null) return upper;
    return '$upper ${dietary!.abbreviation}';
  }
}
