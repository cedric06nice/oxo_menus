// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContainerDtoImpl _$$ContainerDtoImplFromJson(Map<String, dynamic> json) =>
    _$ContainerDtoImpl(
      id: json['id'] as String,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
      dateUpdated: json['date_updated'] == null
          ? null
          : DateTime.parse(json['date_updated'] as String),
      pageId: json['page_id'] as String,
      index: (json['index'] as num).toInt(),
      name: json['name'] as String?,
      layoutJson: json['layout_json'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ContainerDtoImplToJson(_$ContainerDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date_created': instance.dateCreated?.toIso8601String(),
      'date_updated': instance.dateUpdated?.toIso8601String(),
      'page_id': instance.pageId,
      'index': instance.index,
      'name': instance.name,
      'layout_json': instance.layoutJson,
    };
