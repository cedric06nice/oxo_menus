import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/domain/repositories/asset_loader_repository.dart';

/// Verifies the AssetLoaderRepository contract exists and can be implemented.
class FakeAssetLoaderRepository implements AssetLoaderRepository {
  @override
  Future<ByteData> loadAsset(String assetPath) async {
    return ByteData(0);
  }
}

void main() {
  group('AssetLoaderRepository', () {
    test('contract can be implemented', () {
      final repo = FakeAssetLoaderRepository();
      expect(repo, isA<AssetLoaderRepository>());
    });

    test('loadAsset returns ByteData', () async {
      final repo = FakeAssetLoaderRepository();
      final result = await repo.loadAsset('assets/fonts/Test.ttf');
      expect(result, isA<ByteData>());
    });
  });
}
