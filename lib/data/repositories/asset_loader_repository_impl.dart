import 'package:flutter/services.dart';
import 'package:oxo_menus/domain/repositories/asset_loader_repository.dart';

/// Flutter implementation of [AssetLoaderRepository] using rootBundle.
class AssetLoaderRepositoryImpl implements AssetLoaderRepository {
  @override
  Future<ByteData> loadAsset(String assetPath) {
    return rootBundle.load(assetPath);
  }
}
