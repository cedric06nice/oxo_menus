import 'package:freezed_annotation/freezed_annotation.dart';

part 'dish_props.freezed.dart';
part 'dish_props.g.dart';

/// Properties for the DishWidget
///
/// Represents a menu dish with name, price, description, dietary information,
/// and display preferences.
@freezed
class DishProps with _$DishProps {
  const DishProps._();

  const factory DishProps({
    /// The name of the dish
    required String name,

    /// The price of the dish
    required double price,

    /// Optional description of the dish
    String? description,

    /// List of allergens (e.g., 'Dairy', 'Gluten', 'Nuts')
    @Default([]) List<String> allergens,

    /// List of dietary tags (e.g., 'Vegetarian', 'Vegan', 'Gluten-Free')
    @Default([]) List<String> dietary,

    /// Whether to display the price
    @Default(true) bool showPrice,

    /// Whether to display allergen information
    @Default(true) bool showAllergens,
  }) = _DishProps;

  factory DishProps.fromJson(Map<String, dynamic> json) =>
      _$DishPropsFromJson(json);
}
