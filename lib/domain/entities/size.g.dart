// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'size.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Size _$SizeFromJson(Map<String, dynamic> json) => _Size(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
);

Map<String, dynamic> _$SizeToJson(_Size instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'width': instance.width,
  'height': instance.height,
};
