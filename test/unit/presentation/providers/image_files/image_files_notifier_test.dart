import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';
import 'package:oxo_menus/presentation/providers/image_files/image_files_notifier.dart';
import 'package:oxo_menus/presentation/providers/image_files/image_files_provider.dart';
import 'package:oxo_menus/presentation/providers/image_files/image_files_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

import '../../../../fakes/fake_file_repository.dart';
import '../../../../fakes/result_helpers.dart';

void main() {
  group('ImageFilesNotifier', () {
    late FakeFileRepository fakeFileRepo;
    late ProviderContainer container;

    const testFile1 = ImageFileInfo(id: 'file-1', title: 'Logo');
    const testFile2 = ImageFileInfo(
      id: 'file-2',
      title: 'Banner',
      type: 'image/png',
    );

    setUp(() {
      fakeFileRepo = FakeFileRepository();
      container = ProviderContainer(
        overrides: [fileRepositoryProvider.overrideWithValue(fakeFileRepo)],
      );
    });

    tearDown(() => container.dispose());

    ImageFilesNotifier readNotifier() =>
        container.read(imageFilesProvider.notifier);
    ImageFilesState readState() => container.read(imageFilesProvider);

    test('should have correct initial state', () {
      expect(readState(), const ImageFilesState());
      expect(readState().files, isEmpty);
      expect(readState().isLoading, isFalse);
      expect(readState().errorMessage, isNull);
    });

    group('loadImageFiles', () {
      test('should load image files successfully', () async {
        fakeFileRepo.whenListImageFiles(success([testFile1, testFile2]));
        await readNotifier().loadImageFiles();
        expect(readState().files, [testFile1, testFile2]);
        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, isNull);
      });

      test('should set isLoading true during request', () async {
        fakeFileRepo.whenListImageFiles(success([testFile1]));
        final future = readNotifier().loadImageFiles();
        expect(readState().isLoading, isTrue);
        await future;
        expect(readState().isLoading, isFalse);
      });

      test('should set error message when listing fails', () async {
        fakeFileRepo.whenListImageFiles(
          failureServer<List<ImageFileInfo>>('Server error'),
        );
        await readNotifier().loadImageFiles();
        expect(readState().files, isEmpty);
        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, 'Server error');
      });

      test('should clear error on successful reload', () async {
        fakeFileRepo.whenListImageFiles(
          failureNetwork<List<ImageFileInfo>>('Error'),
        );
        await readNotifier().loadImageFiles();
        fakeFileRepo.whenListImageFiles(success([testFile1]));
        await readNotifier().loadImageFiles();
        expect(readState().errorMessage, isNull);
      });

      test('should call listImageFiles on the file repository', () async {
        fakeFileRepo.whenListImageFiles(success([testFile1]));
        await readNotifier().loadImageFiles();
        expect(fakeFileRepo.listImageFilesCalls, hasLength(1));
      });

      test('should return empty list when no files exist', () async {
        fakeFileRepo.whenListImageFiles(success(<ImageFileInfo>[]));
        await readNotifier().loadImageFiles();
        expect(readState().files, isEmpty);
        expect(readState().isLoading, isFalse);
      });
    });
  });
}
