// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_menu_dish_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetMenuDishProps _$SetMenuDishPropsFromJson(Map<String, dynamic> json) =>
    _SetMenuDishProps(
      name: json['name'] as String,
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
      hasSupplement: json['hasSupplement'] as bool? ?? false,
      supplementPrice: (json['supplementPrice'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$SetMenuDishPropsToJson(_SetMenuDishProps instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'calories': instance.calories,
      'allergens': instance.allergens,
      'allergenInfo': instance.allergenInfo.map((e) => e.toJson()).toList(),
      'dietary': _$DietaryTypeEnumMap[instance.dietary],
      'hasSupplement': instance.hasSupplement,
      'supplementPrice': instance.supplementPrice,
    };

const _$DietaryTypeEnumMap = {
  DietaryType.vegetarian: 'vegetarian',
  DietaryType.vegan: 'vegan',
};
