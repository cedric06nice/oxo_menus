// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageProps _$ImagePropsFromJson(Map<String, dynamic> json) => _ImageProps(
  fileId: json['fileId'] as String,
  align: json['align'] as String? ?? 'center',
  fit: json['fit'] as String? ?? 'contain',
  width: (json['width'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ImagePropsToJson(_ImageProps instance) =>
    <String, dynamic>{
      'fileId': instance.fileId,
      'align': instance.align,
      'fit': instance.fit,
      'width': instance.width,
      'height': instance.height,
    };
