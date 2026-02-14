import 'dart:typed_data';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';

/// Repository interface for file operations
abstract class FileRepository {
  /// Upload a file to Directus and return the file ID
  Future<Result<String, DomainError>> upload(Uint8List bytes, String filename);
}
