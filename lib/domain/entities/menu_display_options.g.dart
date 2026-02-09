// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_display_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuDisplayOptions _$MenuDisplayOptionsFromJson(Map<String, dynamic> json) =>
    _MenuDisplayOptions(
      showPrices: json['showPrices'] as bool? ?? true,
      showAllergens: json['showAllergens'] as bool? ?? true,
    );

Map<String, dynamic> _$MenuDisplayOptionsToJson(_MenuDisplayOptions instance) =>
    <String, dynamic>{
      'showPrices': instance.showPrices,
      'showAllergens': instance.showAllergens,
    };
