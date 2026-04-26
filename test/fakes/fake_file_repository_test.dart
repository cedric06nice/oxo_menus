import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';

import 'fake_file_repository.dart';
import 'result_helpers.dart';

void main() {
  group('FakeFileRepository', () {
    late FakeFileRepository repo;

    setUp(() {
      repo = FakeFileRepository();
    });

    // -----------------------------------------------------------------------
    // upload
    // -----------------------------------------------------------------------

    group('upload', () {
      test('should throw StateError when no response is configured', () async {
        expect(
          () => repo.upload(Uint8List.fromList([1, 2]), 'file.png'),
          throwsA(isA<StateError>()),
        );
      });

      test('should return file ID when configured with success', () async {
        repo.whenUpload(success('file-id-123'));

        final result = await repo.upload(
          Uint8List.fromList([1, 2]),
          'file.png',
        );

        expect(result, equals(Success<String, DomainError>('file-id-123')));
      });

      test('should return failure when configured with error', () async {
        repo.whenUpload(failure(network()));

        final result = await repo.upload(Uint8List.fromList([1]), 'file.png');

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkError>());
      });

      test(
        'should record upload call with correct bytes and filename',
        () async {
          final bytes = Uint8List.fromList([10, 20, 30]);
          repo.whenUpload(success('id-1'));

          await repo.upload(bytes, 'menu.png');

          final recorded = repo.uploadCalls;
          expect(recorded.length, equals(1));
          expect(recorded.first.bytes, equals(bytes));
          expect(recorded.first.filename, equals('menu.png'));
        },
      );
    });

    // -----------------------------------------------------------------------
    // replace
    // -----------------------------------------------------------------------

    group('replace', () {
      test('should throw StateError when no response is configured', () async {
        expect(
          () => repo.replace('file-id', Uint8List.fromList([1]), 'f.png'),
          throwsA(isA<StateError>()),
        );
      });

      test('should return same file ID when configured with success', () async {
        repo.whenReplace(success('file-id'));

        final result = await repo.replace(
          'file-id',
          Uint8List.fromList([1]),
          'updated.png',
        );

        expect(result, equals(Success<String, DomainError>('file-id')));
      });

      test('should record replace call with correct arguments', () async {
        final bytes = Uint8List.fromList([5, 6]);
        repo.whenReplace(success('file-id'));

        await repo.replace('file-id', bytes, 'updated.png');

        final recorded = repo.replaceCalls;
        expect(recorded.length, equals(1));
        expect(recorded.first.fileId, equals('file-id'));
        expect(recorded.first.bytes, equals(bytes));
        expect(recorded.first.filename, equals('updated.png'));
      });
    });

    // -----------------------------------------------------------------------
    // listImageFiles
    // -----------------------------------------------------------------------

    group('listImageFiles', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.listImageFiles(), throwsA(isA<StateError>()));
      });

      test(
        'should return image file list when configured with success',
        () async {
          final files = [
            const ImageFileInfo(id: 'img-1', title: 'Logo', type: 'image/png'),
            const ImageFileInfo(id: 'img-2', title: 'Banner'),
          ];
          repo.whenListImageFiles(success(files));

          final result = await repo.listImageFiles();

          expect(
            result,
            equals(Success<List<ImageFileInfo>, DomainError>(files)),
          );
        },
      );

      test(
        'should return empty list when configured with empty list',
        () async {
          repo.whenListImageFiles(success([]));

          final result = await repo.listImageFiles();

          expect(result.valueOrNull, isEmpty);
        },
      );

      test('should record listImageFiles call', () async {
        repo.whenListImageFiles(success([]));

        await repo.listImageFiles();

        expect(repo.listImageFilesCalls.length, equals(1));
      });
    });

    // -----------------------------------------------------------------------
    // downloadFile
    // -----------------------------------------------------------------------

    group('downloadFile', () {
      test('should throw StateError when no response is configured', () async {
        expect(() => repo.downloadFile('file-id'), throwsA(isA<StateError>()));
      });

      test('should return file bytes when configured with success', () async {
        final bytes = Uint8List.fromList([7, 8, 9]);
        repo.whenDownloadFile(success(bytes));

        final result = await repo.downloadFile('file-id');

        expect(result, equals(Success<Uint8List, DomainError>(bytes)));
      });

      test('should return failure when configured with error', () async {
        repo.whenDownloadFile(failure(notFound()));

        final result = await repo.downloadFile('missing-id');

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      });

      test('should record downloadFile call with correct fileId', () async {
        repo.whenDownloadFile(success(Uint8List(0)));

        await repo.downloadFile('abc-file');

        final recorded = repo.downloadFileCalls;
        expect(recorded.length, equals(1));
        expect(recorded.first.fileId, equals('abc-file'));
      });
    });
  });
}
