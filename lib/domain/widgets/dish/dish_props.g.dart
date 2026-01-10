// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DishPropsImpl _$$DishPropsImplFromJson(Map<String, dynamic> json) =>
    _$DishPropsImpl(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      allergens: (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dietary: (json['dietary'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      showPrice: json['showPrice'] as bool? ?? true,
      showAllergens: json['showAllergens'] as bool? ?? true,
    );

Map<String, dynamic> _$$DishPropsImplToJson(_$DishPropsImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'allergens': instance.allergens,
      'dietary': instance.dietary,
      'showPrice': instance.showPrice,
      'showAllergens': instance.showAllergens,
    };
