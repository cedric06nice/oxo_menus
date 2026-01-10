// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuImpl _$$MenuImplFromJson(Map<String, dynamic> json) => _$MenuImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      status: $enumDecode(_$MenuStatusEnumMap, json['status']),
      version: json['version'] as String,
      dateCreated: json['dateCreated'] == null
          ? null
          : DateTime.parse(json['dateCreated'] as String),
      dateUpdated: json['dateUpdated'] == null
          ? null
          : DateTime.parse(json['dateUpdated'] as String),
      userCreated: json['userCreated'] as String?,
      userUpdated: json['userUpdated'] as String?,
      styleConfig: json['styleConfig'] == null
          ? null
          : StyleConfig.fromJson(json['styleConfig'] as Map<String, dynamic>),
      pageSize: json['pageSize'] == null
          ? null
          : PageSize.fromJson(json['pageSize'] as Map<String, dynamic>),
      area: json['area'] as String?,
    );

Map<String, dynamic> _$$MenuImplToJson(_$MenuImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': _$MenuStatusEnumMap[instance.status]!,
      'version': instance.version,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'dateUpdated': instance.dateUpdated?.toIso8601String(),
      'userCreated': instance.userCreated,
      'userUpdated': instance.userUpdated,
      'styleConfig': instance.styleConfig,
      'pageSize': instance.pageSize,
      'area': instance.area,
    };

const _$MenuStatusEnumMap = {
  MenuStatus.draft: 'draft',
  MenuStatus.published: 'published',
  MenuStatus.archived: 'archived',
};

_$StyleConfigImpl _$$StyleConfigImplFromJson(Map<String, dynamic> json) =>
    _$StyleConfigImpl(
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      primaryColor: json['primaryColor'] as String?,
      secondaryColor: json['secondaryColor'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      marginTop: (json['marginTop'] as num?)?.toDouble(),
      marginBottom: (json['marginBottom'] as num?)?.toDouble(),
      marginLeft: (json['marginLeft'] as num?)?.toDouble(),
      marginRight: (json['marginRight'] as num?)?.toDouble(),
      padding: (json['padding'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$StyleConfigImplToJson(_$StyleConfigImpl instance) =>
    <String, dynamic>{
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'primaryColor': instance.primaryColor,
      'secondaryColor': instance.secondaryColor,
      'backgroundColor': instance.backgroundColor,
      'marginTop': instance.marginTop,
      'marginBottom': instance.marginBottom,
      'marginLeft': instance.marginLeft,
      'marginRight': instance.marginRight,
      'padding': instance.padding,
    };

_$PageSizeImpl _$$PageSizeImplFromJson(Map<String, dynamic> json) =>
    _$PageSizeImpl(
      name: json['name'] as String,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$$PageSizeImplToJson(_$PageSizeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'width': instance.width,
      'height': instance.height,
    };
