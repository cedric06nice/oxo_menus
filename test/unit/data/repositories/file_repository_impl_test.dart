import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/file_repository_impl.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late FileRepositoryImpl repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = FileRepositoryImpl(mockDataSource);
  });

  group('FileRepositoryImpl', () {
    group('upload', () {
      test(
        'should call dataSource.uploadFile and return file ID on success',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1, 2, 3, 4]);
          const filename = 'test-image.png';
          const expectedFileId = 'abc-123-def-456';

          when(
            () => mockDataSource.uploadFile(bytes, filename),
          ).thenAnswer((_) async => expectedFileId);

          // Act
          final result = await repository.upload(bytes, filename);

          // Assert
          expect(result, isA<Success<String, DomainError>>());
          expect((result as Success).value, expectedFileId);
          verify(() => mockDataSource.uploadFile(bytes, filename)).called(1);
        },
      );

      test(
        'should return Failure with NetworkError when upload fails',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1, 2, 3, 4]);
          const filename = 'test-image.png';

          when(
            () => mockDataSource.uploadFile(bytes, filename),
          ).thenThrow(Exception('Network error'));

          // Act
          final result = await repository.upload(bytes, filename);

          // Assert
          expect(result, isA<Failure<String, DomainError>>());
          final error = (result as Failure).error;
          expect(error, isA<DomainError>());
        },
      );

      test(
        'should return Failure with appropriate DomainError for auth failure',
        () async {
          // Arrange
          final bytes = Uint8List.fromList([1, 2, 3, 4]);
          const filename = 'test-image.png';

          when(
            () => mockDataSource.uploadFile(bytes, filename),
          ).thenThrow(Exception('401 Unauthorized'));

          // Act
          final result = await repository.upload(bytes, filename);

          // Assert
          expect(result, isA<Failure<String, DomainError>>());
        },
      );
    });

    group('listImageFiles', () {
      test(
        'should call dataSource.listFiles with image filter and return ImageFileInfo list',
        () async {
          // Arrange
          final rawFiles = [
            {'id': 'file-1', 'title': 'logo.png', 'type': 'image/png'},
            {'id': 'file-2', 'title': 'bg.jpg', 'type': 'image/jpeg'},
          ];
          when(
            () => mockDataSource.listFiles(
              filter: {
                'type': {'_starts_with': 'image/'},
              },
              fields: ['id', 'title', 'type'],
              sort: ['-uploaded_on'],
              limit: 100,
            ),
          ).thenAnswer((_) async => rawFiles);

          // Act
          final result = await repository.listImageFiles();

          // Assert
          expect(result, isA<Success>());
          final files = (result as Success).value;
          expect(files.length, 2);
          expect(files[0].id, 'file-1');
          expect(files[0].title, 'logo.png');
          expect(files[0].type, 'image/png');
          expect(files[1].id, 'file-2');
          expect(files[1].title, 'bg.jpg');
          expect(files[1].type, 'image/jpeg');
        },
      );

      test('should return Failure when dataSource throws', () async {
        // Arrange
        when(
          () => mockDataSource.listFiles(
            filter: any(named: 'filter'),
            fields: any(named: 'fields'),
            sort: any(named: 'sort'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await repository.listImageFiles();

        // Assert
        expect(result, isA<Failure>());
      });
    });

    group('downloadFile', () {
      test(
        'should call dataSource.downloadFileBytes and return bytes on success',
        () async {
          // Arrange
          const fileId = 'test-file-uuid';
          final expectedBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
          when(
            () => mockDataSource.downloadFileBytes(fileId),
          ).thenAnswer((_) async => expectedBytes);

          // Act
          final result = await repository.downloadFile(fileId);

          // Assert
          expect(result, isA<Success<Uint8List, DomainError>>());
          expect((result as Success).value, expectedBytes);
          verify(() => mockDataSource.downloadFileBytes(fileId)).called(1);
        },
      );

      test(
        'should return Failure with NotFoundError when file not found',
        () async {
          // Arrange
          const fileId = 'nonexistent-file';
          when(() => mockDataSource.downloadFileBytes(fileId)).thenThrow(
            DirectusException(code: 'NOT_FOUND', message: 'File not found'),
          );

          // Act
          final result = await repository.downloadFile(fileId);

          // Assert
          expect(result, isA<Failure<Uint8List, DomainError>>());
          expect((result as Failure).error, isA<NotFoundError>());
        },
      );

      test(
        'should return Failure with mapped error when dataSource throws',
        () async {
          // Arrange
          const fileId = 'test-file';
          when(
            () => mockDataSource.downloadFileBytes(fileId),
          ).thenThrow(Exception('Network error'));

          // Act
          final result = await repository.downloadFile(fileId);

          // Assert
          expect(result, isA<Failure<Uint8List, DomainError>>());
        },
      );
    });
  });
}
