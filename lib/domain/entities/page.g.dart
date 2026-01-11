// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Page _$PageFromJson(Map<String, dynamic> json) => _Page(
      id: json['id'] as String,
      menuId: json['menuId'] as String,
      name: json['name'] as String,
      index: (json['index'] as num).toInt(),
      dateCreated: json['dateCreated'] == null
          ? null
          : DateTime.parse(json['dateCreated'] as String),
      dateUpdated: json['dateUpdated'] == null
          ? null
          : DateTime.parse(json['dateUpdated'] as String),
    );

Map<String, dynamic> _$PageToJson(_Page instance) => <String, dynamic>{
      'id': instance.id,
      'menuId': instance.menuId,
      'name': instance.name,
      'index': instance.index,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'dateUpdated': instance.dateUpdated?.toIso8601String(),
    };
