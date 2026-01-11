// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SectionProps _$SectionPropsFromJson(Map<String, dynamic> json) =>
    _SectionProps(
      title: json['title'] as String,
      uppercase: json['uppercase'] as bool? ?? false,
      showDivider: json['showDivider'] as bool? ?? true,
    );

Map<String, dynamic> _$SectionPropsToJson(_SectionProps instance) =>
    <String, dynamic>{
      'title': instance.title,
      'uppercase': instance.uppercase,
      'showDivider': instance.showDivider,
    };
