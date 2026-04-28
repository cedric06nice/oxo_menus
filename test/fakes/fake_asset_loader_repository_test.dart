import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'fake_asset_loader_repository.dart';

void main() {
  group('FakeAssetLoaderRepository', () {
    late FakeAssetLoaderRepository repo;

    setUp(() {
      repo = FakeAssetLoaderRepository();
    });

    // -----------------------------------------------------------------------
    // loadAsset
    // -----------------------------------------------------------------------

    group('loadAsset', () {
      test(
        'should throw StateError when no response is configured for path',
        () async {
          expect(
            () => repo.loadAsset('assets/fonts/Roboto.ttf'),
            throwsA(isA<StateError>()),
          );
        },
      );

      test(
        'should return preset ByteData for a specific path when configured',
        () async {
          final bytes = ByteData.sublistView(Uint8List.fromList([1, 2, 3]));
          repo.whenLoadAsset('assets/fonts/Roboto.ttf', bytes);

          final result = await repo.loadAsset('assets/fonts/Roboto.ttf');

          expect(result, same(bytes));
        },
      );

      test(
        'should return default ByteData when path not individually configured',
        () async {
          final bytes = ByteData.sublistView(Uint8List.fromList([4, 5, 6]));
          repo.whenLoadAssetDefault(bytes);

          final result = await repo.loadAsset('assets/images/logo.png');

          expect(result, same(bytes));
        },
      );

      test(
        'should prefer per-path response over default when both are set',
        () async {
          final specific = ByteData.sublistView(Uint8List.fromList([1]));
          final fallback = ByteData.sublistView(Uint8List.fromList([99]));
          repo.whenLoadAsset('assets/fonts/Roboto.ttf', specific);
          repo.whenLoadAssetDefault(fallback);

          final result = await repo.loadAsset('assets/fonts/Roboto.ttf');

          expect(result, same(specific));
        },
      );

      test('should record loadAsset call with correct path', () async {
        final bytes = ByteData.sublistView(Uint8List.fromList([0]));
        repo.whenLoadAsset('assets/fonts/Roboto.ttf', bytes);

        await repo.loadAsset('assets/fonts/Roboto.ttf');

        final recorded = repo.loadAssetCalls;
        expect(recorded.length, equals(1));
        expect(recorded.first.assetPath, equals('assets/fonts/Roboto.ttf'));
      });

      test(
        'should accumulate calls for different paths independently',
        () async {
          final b1 = ByteData.sublistView(Uint8List.fromList([1]));
          final b2 = ByteData.sublistView(Uint8List.fromList([2]));
          repo.whenLoadAsset('assets/a.ttf', b1);
          repo.whenLoadAsset('assets/b.ttf', b2);

          await repo.loadAsset('assets/a.ttf');
          await repo.loadAsset('assets/b.ttf');

          expect(repo.loadAssetCallsFor('assets/a.ttf').length, equals(1));
          expect(repo.loadAssetCallsFor('assets/b.ttf').length, equals(1));
          expect(repo.loadAssetCalls.length, equals(2));
        },
      );
    });
  });
}
