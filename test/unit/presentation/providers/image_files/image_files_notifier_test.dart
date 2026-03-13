import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/presentation/providers/image_files/image_files_notifier.dart';
import 'package:oxo_menus/presentation/providers/image_files/image_files_provider.dart';
import 'package:oxo_menus/presentation/providers/image_files/image_files_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockFileRepository extends Mock implements FileRepository {}

void main() {
  late ProviderContainer container;
  late MockFileRepository mockFileRepository;

  setUp(() {
    mockFileRepository = MockFileRepository();
    container = ProviderContainer(
      overrides: [fileRepositoryProvider.overrideWithValue(mockFileRepository)],
    );
  });

  tearDown(() => container.dispose());

  const testFile1 = ImageFileInfo(id: 'file-1', title: 'Logo');
  const testFile2 = ImageFileInfo(
    id: 'file-2',
    title: 'Banner',
    type: 'image/png',
  );

  ImageFilesNotifier readNotifier() =>
      container.read(imageFilesProvider.notifier);
  ImageFilesState readState() => container.read(imageFilesProvider);

  group('ImageFilesNotifier', () {
    test('should have correct initial state', () {
      expect(readState(), const ImageFilesState());
      expect(readState().files, isEmpty);
      expect(readState().isLoading, false);
      expect(readState().errorMessage, isNull);
    });

    group('loadImageFiles', () {
      test('should load image files successfully', () async {
        when(
          () => mockFileRepository.listImageFiles(),
        ).thenAnswer((_) async => const Success([testFile1, testFile2]));

        await readNotifier().loadImageFiles();

        expect(readState().files, [testFile1, testFile2]);
        expect(readState().isLoading, false);
        expect(readState().errorMessage, isNull);
      });

      test('should set error message on failure', () async {
        when(() => mockFileRepository.listImageFiles()).thenAnswer(
          (_) async => const Failure(ServerError('Failed to load images')),
        );

        await readNotifier().loadImageFiles();

        expect(readState().files, isEmpty);
        expect(readState().isLoading, false);
        expect(readState().errorMessage, isNotNull);
      });

      test('should set isLoading while loading', () async {
        when(
          () => mockFileRepository.listImageFiles(),
        ).thenAnswer((_) async => const Success([testFile1]));

        final future = readNotifier().loadImageFiles();

        expect(readState().isLoading, true);

        await future;

        expect(readState().isLoading, false);
      });
    });
  });
}
