import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_file_info.freezed.dart';
part 'image_file_info.g.dart';

@freezed
abstract class ImageFileInfo with _$ImageFileInfo {
  const ImageFileInfo._();
  const factory ImageFileInfo({
    required String id,
    String? title,
    String? type,
  }) = _ImageFileInfo;

  factory ImageFileInfo.fromJson(Map<String, dynamic> json) =>
      _$ImageFileInfoFromJson(json);
}
