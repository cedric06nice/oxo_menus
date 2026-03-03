import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockFileRepository extends Mock implements FileRepository {}

void main() {
  group('imageDataProvider', () {
    late MockFileRepository mockFileRepository;
    late ProviderContainer container;

    setUp(() {
      mockFileRepository = MockFileRepository();
      container = ProviderContainer(
        overrides: [
          fileRepositoryProvider.overrideWithValue(mockFileRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'calls downloadFile with correct fileId and returns bytes on success',
      () async {
        final expectedBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
        when(
          () => mockFileRepository.downloadFile('file-123'),
        ).thenAnswer((_) async => Success(expectedBytes));

        final result = await container.read(
          imageDataProvider('file-123').future,
        );

        expect(result, expectedBytes);
        verify(() => mockFileRepository.downloadFile('file-123')).called(1);
      },
    );

    test('throws DomainError on failure', () async {
      when(
        () => mockFileRepository.downloadFile('bad-file'),
      ).thenAnswer((_) async => const Failure(NotFoundError('File not found')));

      // Keep the subscription alive so Riverpod doesn't auto-retry
      final sub = container.listen(imageDataProvider('bad-file'), (_, _) {});

      // Allow the async provider to resolve
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(imageDataProvider('bad-file'));
      sub.close();

      expect(state.hasError, isTrue);
      expect(state.error, isA<NotFoundError>());
    });
  });
}
