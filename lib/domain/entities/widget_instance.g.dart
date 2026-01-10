// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WidgetInstanceImpl _$$WidgetInstanceImplFromJson(Map<String, dynamic> json) =>
    _$WidgetInstanceImpl(
      id: json['id'] as String,
      columnId: json['columnId'] as String,
      type: json['type'] as String,
      version: json['version'] as String,
      index: (json['index'] as num).toInt(),
      props: json['props'] as Map<String, dynamic>,
      style: json['style'] == null
          ? null
          : WidgetStyle.fromJson(json['style'] as Map<String, dynamic>),
      dateCreated: json['dateCreated'] == null
          ? null
          : DateTime.parse(json['dateCreated'] as String),
      dateUpdated: json['dateUpdated'] == null
          ? null
          : DateTime.parse(json['dateUpdated'] as String),
    );

Map<String, dynamic> _$$WidgetInstanceImplToJson(
        _$WidgetInstanceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'columnId': instance.columnId,
      'type': instance.type,
      'version': instance.version,
      'index': instance.index,
      'props': instance.props,
      'style': instance.style,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'dateUpdated': instance.dateUpdated?.toIso8601String(),
    };

_$WidgetStyleImpl _$$WidgetStyleImplFromJson(Map<String, dynamic> json) =>
    _$WidgetStyleImpl(
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      color: json['color'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      border: json['border'] as String?,
      padding: (json['padding'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$WidgetStyleImplToJson(_$WidgetStyleImpl instance) =>
    <String, dynamic>{
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'color': instance.color,
      'backgroundColor': instance.backgroundColor,
      'border': instance.border,
      'padding': instance.padding,
    };
