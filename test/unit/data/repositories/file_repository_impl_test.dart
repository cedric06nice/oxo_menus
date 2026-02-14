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
  });
}
