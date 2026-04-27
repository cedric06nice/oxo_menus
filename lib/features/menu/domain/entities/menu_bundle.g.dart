// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuBundle _$MenuBundleFromJson(Map<String, dynamic> json) => _MenuBundle(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  menuIds:
      (json['menuIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  pdfFileId: json['pdfFileId'] as String?,
  dateCreated: json['dateCreated'] == null
      ? null
      : DateTime.parse(json['dateCreated'] as String),
  dateUpdated: json['dateUpdated'] == null
      ? null
      : DateTime.parse(json['dateUpdated'] as String),
);

Map<String, dynamic> _$MenuBundleToJson(_MenuBundle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'menuIds': instance.menuIds,
      'pdfFileId': instance.pdfFileId,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'dateUpdated': instance.dateUpdated?.toIso8601String(),
    };
