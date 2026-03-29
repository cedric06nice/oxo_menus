import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/usecases/list_image_files_usecase.dart';

class MockFileRepository extends Mock implements FileRepository {}

void main() {
  late ListImageFilesUseCase useCase;
  late MockFileRepository mockFileRepository;

  setUp(() {
    mockFileRepository = MockFileRepository();
    useCase = ListImageFilesUseCase(fileRepository: mockFileRepository);
  });

  const testFile1 = ImageFileInfo(id: 'file-1', title: 'Logo');
  const testFile2 = ImageFileInfo(
    id: 'file-2',
    title: 'Banner',
    type: 'image/png',
  );

  group('ListImageFilesUseCase', () {
    test('should return list of image files on success', () async {
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([testFile1, testFile2]));

      final result = await useCase.execute();

      expect(result.isSuccess, true);
      expect(result.valueOrNull, [testFile1, testFile2]);
      verify(() => mockFileRepository.listImageFiles()).called(1);
    });

    test('should return failure when repository fails', () async {
      when(() => mockFileRepository.listImageFiles()).thenAnswer(
        (_) async => const Failure(ServerError('Failed to load images')),
      );

      final result = await useCase.execute();

      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<ServerError>());
      verify(() => mockFileRepository.listImageFiles()).called(1);
    });

    test('should return empty list when no files exist', () async {
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      final result = await useCase.execute();

      expect(result.isSuccess, true);
      expect(result.valueOrNull, isEmpty);
    });
  });
}
