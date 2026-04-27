import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/dietary_type.dart';

part 'wine_props.freezed.dart';
part 'wine_props.g.dart';

@freezed
abstract class WineProps with _$WineProps {
  const WineProps._();

  const factory WineProps({
    required String name,
    required double price,
    String? description,
    int? vintage,
    DietaryType? dietary,
    @Default(false) bool containsSulphites,
  }) = _WineProps;

  factory WineProps.fromJson(Map<String, dynamic> json) =>
      _$WinePropsFromJson(json);

  String get displayName {
    final upper = name.toUpperCase();
    if (dietary == null) return upper;
    return '$upper ${dietary!.abbreviation}';
  }
}
