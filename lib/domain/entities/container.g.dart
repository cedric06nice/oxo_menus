// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContainerImpl _$$ContainerImplFromJson(Map<String, dynamic> json) =>
    _$ContainerImpl(
      id: json['id'] as String,
      pageId: json['pageId'] as String,
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

Map<String, dynamic> _$$ContainerImplToJson(_$ContainerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageId': instance.pageId,
      'index': instance.index,
      'name': instance.name,
      'layout': instance.layout,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'dateUpdated': instance.dateUpdated?.toIso8601String(),
    };

_$LayoutConfigImpl _$$LayoutConfigImplFromJson(Map<String, dynamic> json) =>
    _$LayoutConfigImpl(
      direction: json['direction'] as String?,
      alignment: json['alignment'] as String?,
      spacing: (json['spacing'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$LayoutConfigImplToJson(_$LayoutConfigImpl instance) =>
    <String, dynamic>{
      'direction': instance.direction,
      'alignment': instance.alignment,
      'spacing': instance.spacing,
    };
