import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/repositories/asset_loader_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/asset_loader_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetLoaderRepositoryImpl', () {
    test('should implement AssetLoaderRepository', () {
      // Arrange / Act
      final repo = AssetLoaderRepositoryImpl();

      // Assert
      expect(repo, isA<AssetLoaderRepository>());
    });

    test('should return ByteData from rootBundle when asset exists', () async {
      // Arrange
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

    test('should return the exact bytes registered for the asset', () async {
      // Arrange
      final expectedBytes = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF, 0x00]);
      final binding = TestDefaultBinaryMessengerBinding.instance;
      binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async => expectedBytes.buffer.asByteData(),
      );

      final repo = AssetLoaderRepositoryImpl();

      // Act
      final result = await repo.loadAsset('assets/images/placeholder.png');

      // Assert
      final actual = result.buffer.asUint8List();
      expect(actual, expectedBytes);

      // Cleanup
      binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        null,
      );
    });

    test('should return empty ByteData when handler returns empty bytes',
        () async {
      // Arrange
      final emptyBytes = Uint8List(0);
      final binding = TestDefaultBinaryMessengerBinding.instance;
      binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async => emptyBytes.buffer.asByteData(),
      );

      final repo = AssetLoaderRepositoryImpl();

      // Act
      final result = await repo.loadAsset('assets/fonts/empty.ttf');

      // Assert
      expect(result.lengthInBytes, 0);

      // Cleanup
      binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        null,
      );
    });

    test('should throw when rootBundle cannot find the asset', () async {
      // Arrange — reset handler so rootBundle has no registered asset
      final binding = TestDefaultBinaryMessengerBinding.instance;
      binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        null,
      );

      final repo = AssetLoaderRepositoryImpl();

      // Act / Assert
      await expectLater(
        repo.loadAsset('assets/nonexistent.ttf'),
        throwsA(anything),
      );
    });
  });
}
