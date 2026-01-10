// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WidgetDtoImpl _$$WidgetDtoImplFromJson(Map<String, dynamic> json) =>
    _$WidgetDtoImpl(
      id: json['id'] as String,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
      dateUpdated: json['date_updated'] == null
          ? null
          : DateTime.parse(json['date_updated'] as String),
      columnId: json['column_id'] as String,
      type: json['type'] as String,
      version: json['version'] as String,
      index: (json['index'] as num).toInt(),
      props: json['props'] as Map<String, dynamic>,
      styleJson: json['style_json'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$WidgetDtoImplToJson(_$WidgetDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date_created': instance.dateCreated?.toIso8601String(),
      'date_updated': instance.dateUpdated?.toIso8601String(),
      'column_id': instance.columnId,
      'type': instance.type,
      'version': instance.version,
      'index': instance.index,
      'props': instance.props,
      'style_json': instance.styleJson,
    };
