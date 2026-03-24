// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_menu_title_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetMenuTitleProps _$SetMenuTitlePropsFromJson(Map<String, dynamic> json) =>
    _SetMenuTitleProps(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      uppercase: json['uppercase'] as bool? ?? true,
      priceLabel1: json['priceLabel1'] as String?,
      price1: (json['price1'] as num?)?.toDouble(),
      priceLabel2: json['priceLabel2'] as String?,
      price2: (json['price2'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SetMenuTitlePropsToJson(_SetMenuTitleProps instance) =>
    <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'uppercase': instance.uppercase,
      'priceLabel1': instance.priceLabel1,
      'price1': instance.price1,
      'priceLabel2': instance.priceLabel2,
      'price2': instance.price2,
    };
