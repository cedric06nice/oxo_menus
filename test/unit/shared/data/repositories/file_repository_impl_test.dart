import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/repositories/file_repository_impl.dart';

void main() {
  late _FakeFileDataSource fake;
  late FileRepositoryImpl repository;

  setUp(() {
    fake = _FakeFileDataSource();
    repository = FileRepositoryImpl(fake);
  });

  group('FileRepositoryImpl', () {
    group('upload', () {
      test(
        'should return Success<String> with the file ID when upload succeeds',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1, 2, 3, 4]);
          const filename = 'test-image.png';
          fake.uploadFileResult = 'abc-123-def-456';

          // Act
          final result = await repository.upload(bytes, filename);

          // Assert
          expect(result, isA<Success<String, DomainError>>());
          expect((result as Success).value, 'abc-123-def-456');
        },
      );

      test('should forward bytes and filename to data source', () async {
        // Arrange
        final bytes = Uint8List.fromList([5, 6, 7]);
        const filename = 'logo.png';
        fake.uploadFileResult = 'file-id';

        // Act
        await repository.upload(bytes, filename);

        // Assert
        expect(fake.lastUploadBytes, bytes);
        expect(fake.lastUploadFilename, filename);
      });

      test(
        'should return Failure<DomainError> when data source throws generic exception',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1, 2, 3]);
          fake.uploadFileError = Exception('Network error');

          // Act
          final result = await repository.upload(bytes, 'img.png');

          // Assert
          expect(result, isA<Failure<String, DomainError>>());
          expect((result as Failure).error, isA<DomainError>());
        },
      );

      test(
        'should return Failure<UnauthorizedError> when data source throws NOT_AUTHENTICATED',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1, 2]);
          fake.uploadFileError = DirectusException(
            code: 'NOT_AUTHENTICATED',
            message: 'Authentication required',
          );

          // Act
          final result = await repository.upload(bytes, 'img.png');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnauthorizedError>());
        },
      );

      test(
        'should return Failure<UnknownError> when data source throws UPLOAD_FAILED',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1, 2]);
          fake.uploadFileError = DirectusException(
            code: 'UPLOAD_FAILED',
            message: 'Upload failed',
          );

          // Act
          final result = await repository.upload(bytes, 'img.png');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });

    group('replace', () {
      test(
        'should return Success<String> with the file ID when replace succeeds',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([9, 8, 7]);
          const fileId = 'file-xyz';
          const filename = 'SampleRestaurantMenu.pdf';
          fake.replaceFileResult = fileId;

          // Act
          final result = await repository.replace(fileId, bytes, filename);

          // Assert
          expect(result, isA<Success<String, DomainError>>());
          expect((result as Success).value, fileId);
        },
      );

      test(
        'should forward fileId, bytes and filename to data source',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1, 2]);
          fake.replaceFileResult = 'existing-id';

          // Act
          await repository.replace('existing-id', bytes, 'new-name.png');

          // Assert
          expect(fake.lastReplaceFileId, 'existing-id');
          expect(fake.lastReplaceBytes, bytes);
          expect(fake.lastReplaceFilename, 'new-name.png');
        },
      );

      test(
        'should return Failure<DomainError> when data source throws generic exception',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1, 2]);
          fake.replaceFileError = Exception('replace failed');

          // Act
          final result = await repository.replace('fid', bytes, 'f.png');

          // Assert
          expect(result, isA<Failure<String, DomainError>>());
        },
      );

      test(
        'should return Failure<UnauthorizedError> when data source throws NOT_AUTHENTICATED',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1]);
          fake.replaceFileError = DirectusException(
            code: 'NOT_AUTHENTICATED',
            message: 'Auth required',
          );

          // Act
          final result = await repository.replace('fid', bytes, 'f.png');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnauthorizedError>());
        },
      );
    });

    group('listImageFiles', () {
      test(
        'should return Success<List<ImageFileInfo>> with mapped entities',
        () async {
          // Arrange
          fake.listFilesResult = [
            {'id': 'file-1', 'title': 'logo.png', 'type': 'image/png'},
            {'id': 'file-2', 'title': 'bg.jpg', 'type': 'image/jpeg'},
          ];

          // Act
          final result = await repository.listImageFiles();

          // Assert
          expect(result, isA<Success>());
          final files = (result as Success).value;
          expect(files, hasLength(2));
          expect(files[0].id, 'file-1');
          expect(files[0].title, 'logo.png');
          expect(files[0].type, 'image/png');
          expect(files[1].id, 'file-2');
          expect(files[1].title, 'bg.jpg');
        },
      );

      test('should apply image type filter', () async {
        // Arrange
        fake.listFilesResult = [];

        // Act
        await repository.listImageFiles();

        // Assert
        final filter = fake.lastListFilesFilter;
        expect(filter, isNotNull);
        expect(filter!['type']['_starts_with'], 'image/');
      });

      test('should request id, title, and type fields', () async {
        // Arrange
        fake.listFilesResult = [];

        // Act
        await repository.listImageFiles();

        // Assert
        expect(fake.lastListFilesFields, containsAll(['id', 'title', 'type']));
      });

      test('should sort by -uploaded_on descending', () async {
        // Arrange
        fake.listFilesResult = [];

        // Act
        await repository.listImageFiles();

        // Assert
        expect(fake.lastListFilesSort, contains('-uploaded_on'));
      });

      test('should limit to 100 results', () async {
        // Arrange
        fake.listFilesResult = [];

        // Act
        await repository.listImageFiles();

        // Assert
        expect(fake.lastListFilesLimit, 100);
      });

      test(
        'should return empty list when data source returns no files',
        () async {
          // Arrange
          fake.listFilesResult = [];

          // Act
          final result = await repository.listImageFiles();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, isEmpty);
        },
      );

      test(
        'should return Failure<DomainError> when data source throws generic exception',
        () async {
          // Arrange
          fake.listFilesError = Exception('Network error');

          // Act
          final result = await repository.listImageFiles();

          // Assert
          expect(result, isA<Failure>());
        },
      );

      test(
        'should return Failure<UnauthorizedError> when data source throws FORBIDDEN',
        () async {
          // Arrange
          fake.listFilesError = DirectusException(
            code: 'FORBIDDEN',
            message: 'Forbidden',
          );

          // Act
          final result = await repository.listImageFiles();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnauthorizedError>());
        },
      );
    });

    group('downloadFile', () {
      test(
        'should return Success<Uint8List> with the file bytes when download succeeds',
        () async {
          // Arrange
          const fileId = 'test-file-uuid';
          final expectedBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
          fake.downloadFileBytesResult = expectedBytes;

          // Act
          final result = await repository.downloadFile(fileId);

          // Assert
          expect(result, isA<Success<Uint8List, DomainError>>());
          expect((result as Success).value, expectedBytes);
        },
      );

      test('should forward fileId to data source', () async {
        // Arrange
        fake.downloadFileBytesResult = Uint8List(0);

        // Act
        await repository.downloadFile('my-file-id');

        // Assert
        expect(fake.lastDownloadFileId, 'my-file-id');
      });

      test(
        'should return Failure<NotFoundError> when data source throws NOT_FOUND',
        () async {
          // Arrange
          fake.downloadFileBytesError = DirectusException(
            code: 'NOT_FOUND',
            message: 'File not found',
          );

          // Act
          final result = await repository.downloadFile('nonexistent-file');

          // Assert
          expect(result, isA<Failure<Uint8List, DomainError>>());
          expect((result as Failure).error, isA<NotFoundError>());
        },
      );

      test(
        'should return Failure<ServerError> when data source throws DOWNLOAD_FAILED',
        () async {
          // Arrange
          fake.downloadFileBytesError = DirectusException(
            code: 'DOWNLOAD_FAILED',
            message: 'Download failed',
          );

          // Act
          final result = await repository.downloadFile('file-id');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );

      test(
        'should return Failure<DomainError> when data source throws generic exception',
        () async {
          // Arrange
          fake.downloadFileBytesError = Exception('Network error');

          // Act
          final result = await repository.downloadFile('file-id');

          // Assert
          expect(result, isA<Failure<Uint8List, DomainError>>());
        },
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Manual fake
// ---------------------------------------------------------------------------

class _FakeFileDataSource implements DirectusDataSource {
  // upload
  String? uploadFileResult;
  Object? uploadFileError;
  Uint8List? lastUploadBytes;
  String? lastUploadFilename;

  // replace
  String? replaceFileResult;
  Object? replaceFileError;
  String? lastReplaceFileId;
  Uint8List? lastReplaceBytes;
  String? lastReplaceFilename;

  // listFiles
  List<Map<String, dynamic>>? listFilesResult;
  Object? listFilesError;
  Map<String, dynamic>? lastListFilesFilter;
  List<String>? lastListFilesFields;
  List<String>? lastListFilesSort;
  int? lastListFilesLimit;

  // downloadFileBytes
  Uint8List? downloadFileBytesResult;
  Object? downloadFileBytesError;
  String? lastDownloadFileId;

  @override
  String? get currentAccessToken => null;

  @override
  Future<String> uploadFile(Uint8List bytes, String filename) async {
    lastUploadBytes = bytes;
    lastUploadFilename = filename;
    if (uploadFileError != null) throw uploadFileError!;
    if (uploadFileResult != null) return uploadFileResult!;
    return '';
  }

  @override
  Future<String> replaceFile(
    String fileId,
    Uint8List bytes,
    String filename,
  ) async {
    lastReplaceFileId = fileId;
    lastReplaceBytes = bytes;
    lastReplaceFilename = filename;
    if (replaceFileError != null) throw replaceFileError!;
    if (replaceFileResult != null) return replaceFileResult!;
    return fileId;
  }

  @override
  Future<List<Map<String, dynamic>>> listFiles({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
  }) async {
    lastListFilesFilter = filter;
    lastListFilesFields = fields;
    lastListFilesSort = sort;
    lastListFilesLimit = limit;
    if (listFilesError != null) throw listFilesError!;
    if (listFilesResult != null) return listFilesResult!;
    return [];
  }

  @override
  Future<Uint8List> downloadFileBytes(String fileId) async {
    lastDownloadFileId = fileId;
    if (downloadFileBytesError != null) throw downloadFileBytesError!;
    if (downloadFileBytesResult != null) return downloadFileBytesResult!;
    return Uint8List(0);
  }

  // Unused methods — throw immediately for visibility
  @override
  Future<Map<String, dynamic>> getItem<T extends DirectusItem>(
    int id, {
    List<String>? fields,
  }) async => throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(
    T newItem,
  ) async => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async => throw UnimplementedError();

  @override
  Future<void> deleteItem<T extends DirectusItem>(int id) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<void> logout() async => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> getCurrentUser() async =>
      throw UnimplementedError();

  @override
  Future<void> refreshSession() async => throw UnimplementedError();

  @override
  Future<bool> tryRestoreSession() async => throw UnimplementedError();

  @override
  Future<bool> requestPasswordReset({
    required String email,
    String? resetUrl,
  }) async => throw UnimplementedError();

  @override
  Future<bool> confirmPasswordReset({
    required String token,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<void> startSubscription(
    DirectusWebSocketSubscription subscription,
  ) async => throw UnimplementedError();

  @override
  Future<void> stopSubscription(String subscriptionUid) async =>
      throw UnimplementedError();
}
