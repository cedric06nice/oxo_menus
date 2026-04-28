import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_props.freezed.dart';
part 'image_props.g.dart';

/// Properties for image widget
@freezed
abstract class ImageProps with _$ImageProps {
  const ImageProps._();

  const factory ImageProps({
    required String fileId,
    @Default('center') String align,
    @Default('contain') String fit,
    double? width,
    double? height,
  }) = _ImageProps;

  factory ImageProps.fromJson(Map<String, dynamic> json) =>
      _$ImagePropsFromJson(json);
}
