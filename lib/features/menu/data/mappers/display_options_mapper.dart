import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';

/// Mapper for converting between MenuDisplayOptions entity and JSON
class DisplayOptionsMapper {
  /// Convert JSON to MenuDisplayOptions entity
  static MenuDisplayOptions fromJson(Map<String, dynamic> json) {
    return MenuDisplayOptions(
      showPrices: json['showPrices'] as bool? ?? true,
      showAllergens: json['showAllergens'] as bool? ?? true,
    );
  }

  /// Convert MenuDisplayOptions entity to JSON
  static Map<String, dynamic> toJson(MenuDisplayOptions options) {
    return {
      'showPrices': options.showPrices,
      'showAllergens': options.showAllergens,
    };
  }
}
