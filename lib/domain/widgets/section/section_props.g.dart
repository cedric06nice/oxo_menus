// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SectionPropsImpl _$$SectionPropsImplFromJson(Map<String, dynamic> json) =>
    _$SectionPropsImpl(
      title: json['title'] as String,
      uppercase: json['uppercase'] as bool? ?? false,
      showDivider: json['showDivider'] as bool? ?? true,
    );

Map<String, dynamic> _$$SectionPropsImplToJson(_$SectionPropsImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'uppercase': instance.uppercase,
      'showDivider': instance.showDivider,
    };
