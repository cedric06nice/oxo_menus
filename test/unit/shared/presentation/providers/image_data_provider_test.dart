import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

import '../../../../fakes/fake_file_repository.dart';
import '../../../../fakes/result_helpers.dart';

void main() {
  group('imageDataProvider', () {
    late FakeFileRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeFileRepository();
      container = ProviderContainer(
        overrides: [fileRepositoryProvider.overrideWithValue(fakeRepo)],
      );
    });

    tearDown(() => container.dispose());

    test(
      'should call downloadFile with the correct fileId and return bytes on success',
      () async {
        final expectedBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
        fakeRepo.whenDownloadFile(success(expectedBytes));

        final result = await container.read(
          imageDataProvider('file-123').future,
        );

        expect(result, expectedBytes);
        expect(fakeRepo.downloadFileCalls, hasLength(1));
        expect(fakeRepo.downloadFileCalls.first.fileId, 'file-123');
      },
    );

    test('should throw DomainError when download fails', () async {
      fakeRepo.whenDownloadFile(
        failure<Uint8List>(const NotFoundError('File not found')),
      );

      final sub = container.listen(imageDataProvider('bad-file'), (_, _) {});
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(imageDataProvider('bad-file'));
      sub.close();

      expect(state.hasError, isTrue);
      expect(state.error, isA<NotFoundError>());
    });

    test(
      'should use different fileIds as separate provider family keys',
      () async {
        final bytes1 = Uint8List.fromList([0x01]);
        final bytes2 = Uint8List.fromList([0x02]);
        fakeRepo.whenDownloadFile(success(bytes1));

        final result1 = await container.read(
          imageDataProvider('file-a').future,
        );
        fakeRepo.whenDownloadFile(success(bytes2));
        final result2 = await container.read(
          imageDataProvider('file-b').future,
        );

        expect(result1, bytes1);
        expect(result2, bytes2);
      },
    );

    test('should throw ServerError when server fails', () async {
      fakeRepo.whenDownloadFile(failureServer<Uint8List>('Internal error'));

      final sub = container.listen(imageDataProvider('server-fail'), (_, _) {});
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(imageDataProvider('server-fail'));
      sub.close();

      expect(state.hasError, isTrue);
      expect(state.error, isA<ServerError>());
    });
  });
}
