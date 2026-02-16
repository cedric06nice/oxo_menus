// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TextProps _$TextPropsFromJson(Map<String, dynamic> json) => _TextProps(
  text: json['text'] as String,
  fontSize: (json['fontSize'] as num?)?.toDouble() ?? 10.0,
  align: json['align'] as String? ?? 'left',
  bold: json['bold'] as bool? ?? false,
  italic: json['italic'] as bool? ?? false,
);

Map<String, dynamic> _$TextPropsToJson(_TextProps instance) =>
    <String, dynamic>{
      'text': instance.text,
      'fontSize': instance.fontSize,
      'align': instance.align,
      'bold': instance.bold,
      'italic': instance.italic,
    };
