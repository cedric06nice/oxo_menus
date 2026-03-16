import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/repositories/asset_loader_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/asset_loader_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetLoaderRepositoryImpl', () {
    test('implements AssetLoaderRepository', () {
      final repo = AssetLoaderRepositoryImpl();
      expect(repo, isA<AssetLoaderRepository>());
    });

    test('loadAsset returns ByteData from rootBundle', () async {
      // Arrange — register a fake asset in the test binding
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4]);
      final binding = TestDefaultBinaryMessengerBinding.instance;
      binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async => fakeBytes.buffer.asByteData(),
      );

      final repo = AssetLoaderRepositoryImpl();

      // Act
      final result = await repo.loadAsset('assets/fonts/Test.ttf');

      // Assert
      expect(result, isA<ByteData>());
      expect(result.lengthInBytes, 4);

      // Cleanup
      binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        null,
      );
    });
  });
}
