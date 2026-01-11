// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'column_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ColumnDto _$ColumnDtoFromJson(Map<String, dynamic> json) => _ColumnDto(
      id: json['id'] as String,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
      dateUpdated: json['date_updated'] == null
          ? null
          : DateTime.parse(json['date_updated'] as String),
      containerId: json['container_id'] as String,
      index: (json['index'] as num).toInt(),
      flex: (json['flex'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ColumnDtoToJson(_ColumnDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date_created': instance.dateCreated?.toIso8601String(),
      'date_updated': instance.dateUpdated?.toIso8601String(),
      'container_id': instance.containerId,
      'index': instance.index,
      'flex': instance.flex,
      'width': instance.width,
    };
