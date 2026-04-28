import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';
import 'package:oxo_menus/shared/domain/repositories/file_repository.dart';

class _FakeFileRepository implements FileRepository {
  int downloadCalls = 0;
  int listCalls = 0;
  Map<String, Result<Uint8List, DomainError>> downloadResults = {};
  Result<List<ImageFileInfo>, DomainError> listResult = const Success([]);

  @override
  Future<Result<Uint8List, DomainError>> downloadFile(String fileId) async {
    downloadCalls++;
    final result = downloadResults[fileId];
    if (result != null) {
      return result;
    }
    return Success(Uint8List.fromList([fileId.codeUnitAt(0)]));
  }

  @override
  Future<Result<List<ImageFileInfo>, DomainError>> listImageFiles() async {
    listCalls++;
    return listResult;
  }

  @override
  Future<Result<String, DomainError>> upload(
    Uint8List bytes,
    String filename,
  ) async => const Failure(UnknownError('unused'));

  @override
  Future<Result<String, DomainError>> replace(
    String fileId,
    Uint8List bytes,
    String filename,
  ) async => const Failure(UnknownError('unused'));
}

void main() {
  group('ImageGateway', () {
    group('getBytes', () {
      test('downloads bytes through the repository on first request', () async {
        final repo = _FakeFileRepository();
        final gateway = ImageGateway(repository: repo);

        final bytes = await gateway.getBytes('a');

        expect(bytes, Uint8List.fromList(['a'.codeUnitAt(0)]));
        expect(repo.downloadCalls, 1);
      });

      test('caches the in-flight future per fileId', () async {
        final repo = _FakeFileRepository();
        final gateway = ImageGateway(repository: repo);

        final future1 = gateway.getBytes('a');
        final future2 = gateway.getBytes('a');

        expect(identical(future1, future2), isTrue);
        expect(repo.downloadCalls, 1);

        await future1;
        await gateway.getBytes('a');

        expect(repo.downloadCalls, 1, reason: 'completed future is cached');
      });

      test('different fileIds produce independent fetches', () async {
        final repo = _FakeFileRepository();
        final gateway = ImageGateway(repository: repo);

        await gateway.getBytes('a');
        await gateway.getBytes('b');

        expect(repo.downloadCalls, 2);
      });

      test('rethrows the DomainError on failure', () async {
        final repo = _FakeFileRepository()
          ..downloadResults['x'] = const Failure(NotFoundError());
        final gateway = ImageGateway(repository: repo);

        await expectLater(
          gateway.getBytes('x'),
          throwsA(isA<NotFoundError>()),
        );
      });

      test('does not cache a failed future — next call re-fetches', () async {
        final repo = _FakeFileRepository()
          ..downloadResults['x'] = const Failure(NotFoundError());
        final gateway = ImageGateway(repository: repo);

        await expectLater(gateway.getBytes('x'), throwsA(anything));
        repo.downloadResults.remove('x');
        final bytes = await gateway.getBytes('x');

        expect(bytes, isNotEmpty);
        expect(repo.downloadCalls, 2);
      });

      test('evicts least-recently-used entries past maxEntries', () async {
        final repo = _FakeFileRepository();
        final gateway = ImageGateway(repository: repo, maxEntries: 2);

        await gateway.getBytes('a');
        await gateway.getBytes('b');
        await gateway.getBytes('c'); // should evict 'a'
        expect(repo.downloadCalls, 3);

        await gateway.getBytes('a'); // re-fetched
        expect(repo.downloadCalls, 4);

        await gateway.getBytes('c'); // still cached
        expect(repo.downloadCalls, 4);
      });
    });

    group('listImages', () {
      test('forwards to repository.listImageFiles each call (no caching)',
          () async {
        final repo = _FakeFileRepository()
          ..listResult = const Success([
            ImageFileInfo(id: 'a', title: 'a.png'),
          ]);
        final gateway = ImageGateway(repository: repo);

        final r1 = await gateway.listImages();
        final r2 = await gateway.listImages();

        expect(r1.isSuccess, isTrue);
        expect(r2.isSuccess, isTrue);
        expect(repo.listCalls, 2);
      });
    });
  });
}
