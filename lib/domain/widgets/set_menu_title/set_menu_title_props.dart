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

  /// Combined inline price string for PDF rendering.
  ///
  /// - price1 only → "45"
  /// - price1 + price2 → "45 / 55"
  /// - priceLabel1 + price1 → "3 Courses 45"
  /// - all four → "3 Courses 45 / 4 Courses 55"
  String? get formattedPrices {
    if (price1 == null) return null;
    final part1 = _formatPart(priceLabel1, price1!);
    if (price2 == null) return part1;
    final part2 = _formatPart(priceLabel2, price2!);
    return '$part1 / $part2';
  }

  static String _formatPart(String? label, double price) {
    final priceStr = _formatPriceValue(price);
    return label != null ? '$label $priceStr' : priceStr;
  }

  static String _formatPriceValue(double price) {
    return price.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  static String? _formatPrice(String? label, double? price) {
    if (label == null || price == null) return null;
    return '$label  ${_formatPriceValue(price)}';
  }
}
