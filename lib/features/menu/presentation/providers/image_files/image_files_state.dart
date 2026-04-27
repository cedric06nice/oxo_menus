import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';

part 'image_files_state.freezed.dart';

@freezed
abstract class ImageFilesState with _$ImageFilesState {
  const factory ImageFilesState({
    @Default([]) List<ImageFileInfo> files,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ImageFilesState;
}
