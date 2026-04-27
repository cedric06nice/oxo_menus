import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';
import 'package:oxo_menus/shared/domain/usecases/list_image_files_usecase.dart';

import '../../../../fakes/fake_file_repository.dart';
import '../../../../fakes/result_helpers.dart';

void main() {
  group('ListImageFilesUseCase', () {
    late FakeFileRepository fileRepo;
    late ListImageFilesUseCase useCase;

    setUp(() {
      fileRepo = FakeFileRepository();
      useCase = ListImageFilesUseCase(fileRepository: fileRepo);
    });

    // -------------------------------------------------------------------------
    // Happy path
    // -------------------------------------------------------------------------

    group('happy path', () {
      test(
        'should return list of image files when repository succeeds',
        () async {
          // Arrange
          final files = [
            const ImageFileInfo(id: 'abc', title: 'Logo', type: 'image/png'),
            const ImageFileInfo(id: 'def', title: 'Banner', type: 'image/jpeg'),
          ];
          fileRepo.whenListImageFiles(success(files));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.length, equals(2));
          expect(result.valueOrNull!.first.id, equals('abc'));
          expect(result.valueOrNull!.last.id, equals('def'));
        },
      );

      test(
        'should return empty list when repository returns no image files',
        () async {
          // Arrange
          fileRepo.whenListImageFiles(success([]));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!, isEmpty);
        },
      );

      test(
        'should return single image file when repository has one entry',
        () async {
          // Arrange
          final files = [const ImageFileInfo(id: 'xyz', type: 'image/webp')];
          fileRepo.whenListImageFiles(success(files));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.single.id, equals('xyz'));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Repository failure
    // -------------------------------------------------------------------------

    group('repository failure', () {
      test(
        'should return Failure when fileRepository.listImageFiles fails with NetworkError',
        () async {
          // Arrange
          fileRepo.whenListImageFiles(failure(network()));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );

      test('should propagate ServerError from repository', () async {
        // Arrange
        fileRepo.whenListImageFiles(failure(server()));

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ServerError>());
      });
    });

    // -------------------------------------------------------------------------
    // Repository wiring
    // -------------------------------------------------------------------------

    group('repository wiring', () {
      test(
        'should delegate to fileRepository.listImageFiles exactly once',
        () async {
          // Arrange
          fileRepo.whenListImageFiles(success([]));

          // Act
          await useCase.execute();

          // Assert
          expect(fileRepo.listImageFilesCalls.length, equals(1));
        },
      );
    });
  });
}
