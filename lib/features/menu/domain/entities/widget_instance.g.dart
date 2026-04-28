// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WidgetInstance _$WidgetInstanceFromJson(Map<String, dynamic> json) =>
    _WidgetInstance(
      id: (json['id'] as num).toInt(),
      columnId: (json['columnId'] as num).toInt(),
      type: json['type'] as String,
      version: json['version'] as String,
      index: (json['index'] as num).toInt(),
      props: json['props'] as Map<String, dynamic>,
      style: json['style'] == null
          ? null
          : WidgetStyle.fromJson(json['style'] as Map<String, dynamic>),
      isTemplate: json['isTemplate'] as bool? ?? false,
      lockedForEdition: json['lockedForEdition'] as bool? ?? false,
      dateCreated: json['dateCreated'] == null
          ? null
          : DateTime.parse(json['dateCreated'] as String),
      dateUpdated: json['dateUpdated'] == null
          ? null
          : DateTime.parse(json['dateUpdated'] as String),
      editingBy: json['editingBy'] as String?,
      editingSince: json['editingSince'] == null
          ? null
          : DateTime.parse(json['editingSince'] as String),
    );

Map<String, dynamic> _$WidgetInstanceToJson(_WidgetInstance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'columnId': instance.columnId,
      'type': instance.type,
      'version': instance.version,
      'index': instance.index,
      'props': instance.props,
      'style': instance.style,
      'isTemplate': instance.isTemplate,
      'lockedForEdition': instance.lockedForEdition,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'dateUpdated': instance.dateUpdated?.toIso8601String(),
      'editingBy': instance.editingBy,
      'editingSince': instance.editingSince?.toIso8601String(),
    };

_WidgetStyle _$WidgetStyleFromJson(Map<String, dynamic> json) => _WidgetStyle(
  fontFamily: json['fontFamily'] as String?,
  fontSize: (json['fontSize'] as num?)?.toDouble(),
  color: json['color'] as String?,
  backgroundColor: json['backgroundColor'] as String?,
  border: json['border'] as String?,
  padding: (json['padding'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WidgetStyleToJson(_WidgetStyle instance) =>
    <String, dynamic>{
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'color': instance.color,
      'backgroundColor': instance.backgroundColor,
      'border': instance.border,
      'padding': instance.padding,
    };
