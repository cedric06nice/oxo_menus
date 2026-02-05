// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Container _$ContainerFromJson(Map<String, dynamic> json) => _Container(
  id: (json['id'] as num).toInt(),
  pageId: (json['pageId'] as num).toInt(),
  index: (json['index'] as num).toInt(),
  name: json['name'] as String?,
  layout: json['layout'] == null
      ? null
      : LayoutConfig.fromJson(json['layout'] as Map<String, dynamic>),
  dateCreated: json['dateCreated'] == null
      ? null
      : DateTime.parse(json['dateCreated'] as String),
  dateUpdated: json['dateUpdated'] == null
      ? null
      : DateTime.parse(json['dateUpdated'] as String),
);

Map<String, dynamic> _$ContainerToJson(_Container instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageId': instance.pageId,
      'index': instance.index,
      'name': instance.name,
      'layout': instance.layout,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'dateUpdated': instance.dateUpdated?.toIso8601String(),
    };

_LayoutConfig _$LayoutConfigFromJson(Map<String, dynamic> json) =>
    _LayoutConfig(
      direction: json['direction'] as String?,
      alignment: json['alignment'] as String?,
      spacing: (json['spacing'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LayoutConfigToJson(_LayoutConfig instance) =>
    <String, dynamic>{
      'direction': instance.direction,
      'alignment': instance.alignment,
      'spacing': instance.spacing,
    };
