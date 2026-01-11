// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PageDto _$PageDtoFromJson(Map<String, dynamic> json) => _PageDto(
  id: json['id'] as String,
  dateCreated: json['date_created'] == null
      ? null
      : DateTime.parse(json['date_created'] as String),
  dateUpdated: json['date_updated'] == null
      ? null
      : DateTime.parse(json['date_updated'] as String),
  menuId: json['menu_id'] as String,
  name: json['name'] as String,
  index: (json['index'] as num).toInt(),
);

Map<String, dynamic> _$PageDtoToJson(_PageDto instance) => <String, dynamic>{
  'id': instance.id,
  'date_created': instance.dateCreated?.toIso8601String(),
  'date_updated': instance.dateUpdated?.toIso8601String(),
  'menu_id': instance.menuId,
  'name': instance.name,
  'index': instance.index,
};
