// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'column.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Column _$ColumnFromJson(Map<String, dynamic> json) => _Column(
  id: (json['id'] as num).toInt(),
  containerId: (json['containerId'] as num).toInt(),
  index: (json['index'] as num).toInt(),
  flex: (json['flex'] as num?)?.toInt(),
  width: (json['width'] as num?)?.toDouble(),
  dateCreated: json['dateCreated'] == null
      ? null
      : DateTime.parse(json['dateCreated'] as String),
  dateUpdated: json['dateUpdated'] == null
      ? null
      : DateTime.parse(json['dateUpdated'] as String),
);

Map<String, dynamic> _$ColumnToJson(_Column instance) => <String, dynamic>{
  'id': instance.id,
  'containerId': instance.containerId,
  'index': instance.index,
  'flex': instance.flex,
  'width': instance.width,
  'dateCreated': instance.dateCreated?.toIso8601String(),
  'dateUpdated': instance.dateUpdated?.toIso8601String(),
};
