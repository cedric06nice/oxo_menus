import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_variant.freezed.dart';
part 'price_variant.g.dart';

/// A single labelled price for a dish.
///
/// Used by [DishProps.priceVariants] when a dish has multiple prices tied to
/// variants such as size ("Small" / "Large") or quantity ("Per 3" / "Per 6").
@freezed
abstract class PriceVariant with _$PriceVariant {
  const PriceVariant._();

  const factory PriceVariant({required String label, required double price}) =
      _PriceVariant;

  factory PriceVariant.fromJson(Map<String, dynamic> json) =>
      _$PriceVariantFromJson(json);
}
