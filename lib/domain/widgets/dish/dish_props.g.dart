// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DishProps _$DishPropsFromJson(Map<String, dynamic> json) => _DishProps(
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String?,
  calories: (json['calories'] as num?)?.toInt(),
  allergenInfo:
      (json['allergenInfo'] as List<dynamic>?)
          ?.map((e) => AllergenInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  dietary: $enumDecodeNullable(_$DietaryTypeEnumMap, json['dietary']),
  priceVariants:
      (json['priceVariants'] as List<dynamic>?)
          ?.map((e) => PriceVariant.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PriceVariant>[],
);

Map<String, dynamic> _$DishPropsToJson(_DishProps instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'calories': instance.calories,
      'allergenInfo': instance.allergenInfo.map((e) => e.toJson()).toList(),
      'dietary': _$DietaryTypeEnumMap[instance.dietary],
      'priceVariants': instance.priceVariants.map((e) => e.toJson()).toList(),
    };

const _$DietaryTypeEnumMap = {
  DietaryType.vegetarian: 'vegetarian',
  DietaryType.vegan: 'vegan',
};
