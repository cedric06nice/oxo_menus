// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergen_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AllergenInfo _$AllergenInfoFromJson(Map<String, dynamic> json) =>
    _AllergenInfo(
      allergen: $enumDecode(_$UkAllergenEnumMap, json['allergen']),
      mayContain: json['mayContain'] as bool? ?? false,
      details: json['details'] as String?,
    );

Map<String, dynamic> _$AllergenInfoToJson(_AllergenInfo instance) =>
    <String, dynamic>{
      'allergen': _$UkAllergenEnumMap[instance.allergen]!,
      'mayContain': instance.mayContain,
      'details': instance.details,
    };

const _$UkAllergenEnumMap = {
  UkAllergen.celery: 'celery',
  UkAllergen.gluten: 'gluten',
  UkAllergen.crustaceans: 'crustaceans',
  UkAllergen.eggs: 'eggs',
  UkAllergen.fish: 'fish',
  UkAllergen.lupin: 'lupin',
  UkAllergen.milk: 'milk',
  UkAllergen.molluscs: 'molluscs',
  UkAllergen.mustard: 'mustard',
  UkAllergen.nuts: 'nuts',
  UkAllergen.peanuts: 'peanuts',
  UkAllergen.sesame: 'sesame',
  UkAllergen.soya: 'soya',
  UkAllergen.sulphites: 'sulphites',
};
