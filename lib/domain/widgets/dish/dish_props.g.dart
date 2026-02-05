// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DishProps _$DishPropsFromJson(Map<String, dynamic> json) => _DishProps(
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String?,
  allergens:
      (json['allergens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  allergenInfo:
      (json['allergenInfo'] as List<dynamic>?)
          ?.map((e) => AllergenInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  dietary:
      (json['dietary'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  showPrice: json['showPrice'] as bool? ?? true,
  showAllergens: json['showAllergens'] as bool? ?? true,
);

Map<String, dynamic> _$DishPropsToJson(_DishProps instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'allergens': instance.allergens,
      'allergenInfo': instance.allergenInfo,
      'dietary': instance.dietary,
      'showPrice': instance.showPrice,
      'showAllergens': instance.showAllergens,
    };
