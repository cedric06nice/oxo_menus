import 'dart:typed_data';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';

/// Repository interface for file operations
abstract class FileRepository {
  /// Upload a file to Directus and return the file ID
  Future<Result<String, DomainError>> upload(Uint8List bytes, String filename);

  /// Replace the bytes of an existing Directus file while keeping its ID.
  ///
  /// The [filename] is used as the `filename_download` so browsers save the
  /// file under a human-readable name. Returns the same [fileId] on success.
  Future<Result<String, DomainError>> replace(
    String fileId,
    Uint8List bytes,
    String filename,
  );

  /// List all image files from Directus
  Future<Result<List<ImageFileInfo>, DomainError>> listImageFiles();

  /// Download file bytes by file ID
  Future<Result<Uint8List, DomainError>> downloadFile(String fileId);
}
