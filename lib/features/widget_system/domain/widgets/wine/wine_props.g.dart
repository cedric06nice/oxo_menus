// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wine_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WineProps _$WinePropsFromJson(Map<String, dynamic> json) => _WineProps(
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String?,
  vintage: (json['vintage'] as num?)?.toInt(),
  dietary: $enumDecodeNullable(_$DietaryTypeEnumMap, json['dietary']),
  containsSulphites: json['containsSulphites'] as bool? ?? false,
);

Map<String, dynamic> _$WinePropsToJson(_WineProps instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'vintage': instance.vintage,
      'dietary': _$DietaryTypeEnumMap[instance.dietary],
      'containsSulphites': instance.containsSulphites,
    };

const _$DietaryTypeEnumMap = {
  DietaryType.vegetarian: 'vegetarian',
  DietaryType.vegan: 'vegan',
};
