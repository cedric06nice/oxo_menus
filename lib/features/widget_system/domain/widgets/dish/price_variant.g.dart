// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceVariant _$PriceVariantFromJson(Map<String, dynamic> json) =>
    _PriceVariant(
      label: json['label'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$PriceVariantToJson(_PriceVariant instance) =>
    <String, dynamic>{'label': instance.label, 'price': instance.price};
