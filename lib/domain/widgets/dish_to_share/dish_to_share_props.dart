import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/allergens/allergen_info.dart';
import 'package:oxo_menus/domain/widgets/shared/dietary_type.dart';

part 'dish_to_share_props.freezed.dart';
part 'dish_to_share_props.g.dart';

/// Properties for the DishToShareWidget
///
/// Represents a shared dish with name, price, optional servings count,
/// description, and dietary information. Displays "{For X} To Share" after the price.
@freezed
abstract class DishToShareProps with _$DishToShareProps {
  const DishToShareProps._();

  @JsonSerializable(explicitToJson: true)
  const factory DishToShareProps({
    required String name,
    required double price,
    String? description,
    int? calories,
    @Default([]) List<AllergenInfo> allergenInfo,
    DietaryType? dietary,
    int? servings,
  }) = _DishToShareProps;

  factory DishToShareProps.fromJson(Map<String, dynamic> json) =>
      _$DishToSharePropsFromJson(json);

  static const _numberWords = {
    2: 'Two',
    3: 'Three',
    4: 'Four',
    5: 'Five',
    6: 'Six',
    7: 'Seven',
    8: 'Eight',
    9: 'Nine',
    10: 'Ten',
  };

  /// Label for the servings count (e.g., "For Two", "For Three").
  /// Returns empty string when servings is null, 0, or 1.
  String get servingsLabel {
    if (servings == null || servings! <= 1) return '';
    final word = _numberWords[servings!];
    return word != null ? 'For $word' : 'For $servings';
  }

  /// Full sharing text (e.g., "For Two To Share" or just "To Share").
  String get sharingText {
    final label = servingsLabel;
    return label.isEmpty ? 'To Share' : '$label To Share';
  }

  /// Display name: uppercased dish name with optional dietary abbreviation
  String get displayName {
    final upper = name.toUpperCase();
    if (dietary == null) return upper;
    return '$upper ${dietary!.abbreviation}';
  }
}
