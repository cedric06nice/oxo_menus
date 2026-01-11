// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuDto _$MenuDtoFromJson(Map<String, dynamic> json) => _MenuDto(
      id: json['id'] as String,
      status: json['status'] as String,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
      dateUpdated: json['date_updated'] == null
          ? null
          : DateTime.parse(json['date_updated'] as String),
      userCreated: json['user_created'] as String?,
      userUpdated: json['user_updated'] as String?,
      name: json['name'] as String,
      version: json['version'] as String,
      styleJson: json['style_json'] as Map<String, dynamic>?,
      area: json['area'] as String?,
      size: json['size'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MenuDtoToJson(_MenuDto instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'date_created': instance.dateCreated?.toIso8601String(),
      'date_updated': instance.dateUpdated?.toIso8601String(),
      'user_created': instance.userCreated,
      'user_updated': instance.userUpdated,
      'name': instance.name,
      'version': instance.version,
      'style_json': instance.styleJson,
      'area': instance.area,
      'size': instance.size,
    };
