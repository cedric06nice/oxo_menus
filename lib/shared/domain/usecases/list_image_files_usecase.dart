import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';
import 'package:oxo_menus/shared/domain/repositories/file_repository.dart';

/// Use case for listing all available image files
class ListImageFilesUseCase {
  final FileRepository fileRepository;

  ListImageFilesUseCase({required this.fileRepository});

  Future<Result<List<ImageFileInfo>, DomainError>> execute() =>
      fileRepository.listImageFiles();
}
