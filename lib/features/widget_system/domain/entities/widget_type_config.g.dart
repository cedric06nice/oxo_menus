// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_type_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WidgetTypeConfig _$WidgetTypeConfigFromJson(Map<String, dynamic> json) =>
    _WidgetTypeConfig(
      type: json['type'] as String,
      alignment:
          $enumDecodeNullable(_$WidgetAlignmentEnumMap, json['alignment']) ??
          WidgetAlignment.start,
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$WidgetTypeConfigToJson(_WidgetTypeConfig instance) =>
    <String, dynamic>{
      'type': instance.type,
      'alignment': _$WidgetAlignmentEnumMap[instance.alignment]!,
      'enabled': instance.enabled,
    };

const _$WidgetAlignmentEnumMap = {
  WidgetAlignment.start: 'start',
  WidgetAlignment.center: 'center',
  WidgetAlignment.end: 'end',
  WidgetAlignment.justified: 'justified',
};
