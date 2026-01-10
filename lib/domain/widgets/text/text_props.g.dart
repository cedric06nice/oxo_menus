// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TextPropsImpl _$$TextPropsImplFromJson(Map<String, dynamic> json) =>
    _$TextPropsImpl(
      text: json['text'] as String,
      align: json['align'] as String? ?? 'left',
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
    );

Map<String, dynamic> _$$TextPropsImplToJson(_$TextPropsImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'align': instance.align,
      'bold': instance.bold,
      'italic': instance.italic,
    };
