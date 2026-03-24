import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_menu_title_props.freezed.dart';
part 'set_menu_title_props.g.dart';

/// Properties for the SetMenuTitleWidget
///
/// Represents a set menu title with optional subtitle and up to two
/// labelled price lines (e.g. "3 Courses  45" / "4 Courses  55").
@freezed
abstract class SetMenuTitleProps with _$SetMenuTitleProps {
  const SetMenuTitleProps._();

  const factory SetMenuTitleProps({
    required String title,
    String? subtitle,
    @Default(true) bool uppercase,
    String? priceLabel1,
    double? price1,
    String? priceLabel2,
    double? price2,
  }) = _SetMenuTitleProps;

  factory SetMenuTitleProps.fromJson(Map<String, dynamic> json) =>
      _$SetMenuTitlePropsFromJson(json);

  /// Display title with optional uppercase transformation
  String get displayTitle => uppercase ? title.toUpperCase() : title;

  /// Formatted price line 1 (e.g. "3 Courses  45"), null if incomplete
  String? get formattedPrice1 => _formatPrice(priceLabel1, price1);

  /// Formatted price line 2 (e.g. "4 Courses  55"), null if incomplete
  String? get formattedPrice2 => _formatPrice(priceLabel2, price2);

  static String? _formatPrice(String? label, double? price) {
    if (label == null || price == null) return null;
    final priceStr = price.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    return '$label  $priceStr';
  }
}
