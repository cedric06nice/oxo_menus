import 'package:oxo_menus/domain/entities/image_file_info.dart';

class FileMapper {
  static ImageFileInfo toEntity(Map<String, dynamic> data) {
    return ImageFileInfo(
      id: data['id'] as String,
      title: data['title'] as String?,
      type: data['type'] as String?,
    );
  }
}
