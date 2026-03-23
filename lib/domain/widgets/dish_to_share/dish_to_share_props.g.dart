// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish_to_share_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DishToShareProps _$DishToSharePropsFromJson(Map<String, dynamic> json) =>
    _DishToShareProps(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      calories: (json['calories'] as num?)?.toInt(),
      allergens:
          (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      allergenInfo:
          (json['allergenInfo'] as List<dynamic>?)
              ?.map((e) => AllergenInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dietary: $enumDecodeNullable(_$DietaryTypeEnumMap, json['dietary']),
      servings: (json['servings'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DishToSharePropsToJson(_DishToShareProps instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'calories': instance.calories,
      'allergens': instance.allergens,
      'allergenInfo': instance.allergenInfo.map((e) => e.toJson()).toList(),
      'dietary': _$DietaryTypeEnumMap[instance.dietary],
      'servings': instance.servings,
    };

const _$DietaryTypeEnumMap = {
  DietaryType.vegetarian: 'vegetarian',
  DietaryType.vegan: 'vegan',
};
