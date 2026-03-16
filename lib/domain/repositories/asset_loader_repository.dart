import 'dart:typed_data';

/// Repository interface for loading platform assets (fonts, images, etc.)
///
/// Abstracts Flutter's rootBundle so domain layer stays framework-free.
abstract class AssetLoaderRepository {
  /// Load an asset by path and return its raw bytes.
  Future<ByteData> loadAsset(String assetPath);
}
