import 'dart:typed_data';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/mappers/error_mapper.dart';
import 'package:oxo_menus/shared/data/mappers/file_mapper.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';
import 'package:oxo_menus/shared/domain/repositories/file_repository.dart';

/// Implementation of FileRepository using Directus as data source
class FileRepositoryImpl implements FileRepository {
  final DirectusDataSource dataSource;

  FileRepositoryImpl(this.dataSource);

  @override
  Future<Result<String, DomainError>> upload(
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final fileId = await dataSource.uploadFile(bytes, filename);
      return Success(fileId);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<String, DomainError>> replace(
    String fileId,
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final returnedId = await dataSource.replaceFile(fileId, bytes, filename);
      return Success(returnedId);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<ImageFileInfo>, DomainError>> listImageFiles() async {
    try {
      final data = await dataSource.listFiles(
        filter: {
          'type': {'_starts_with': 'image/'},
        },
        fields: ['id', 'title', 'type'],
        sort: ['-uploaded_on'],
        limit: 100,
      );
      final files = data.map((raw) => FileMapper.toEntity(raw)).toList();
      return Success(files);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Uint8List, DomainError>> downloadFile(String fileId) async {
    try {
      final bytes = await dataSource.downloadFileBytes(fileId);
      return Success(bytes);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
