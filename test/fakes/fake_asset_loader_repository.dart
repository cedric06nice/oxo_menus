import 'dart:typed_data';

import 'package:oxo_menus/shared/domain/repositories/asset_loader_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

sealed class AssetLoaderCall {
  const AssetLoaderCall();
}

final class LoadAssetCall extends AssetLoaderCall {
  final String assetPath;
  const LoadAssetCall({required this.assetPath});
}

// ---------------------------------------------------------------------------
// FakeAssetLoaderRepository
// ---------------------------------------------------------------------------

/// Manual fake for [AssetLoaderRepository].
///
/// Every call is recorded in [calls] as a typed [AssetLoaderCall].
/// Return values are configured per-path via [whenLoadAsset], which stores
/// a [ByteData] result keyed by [assetPath].  A catch-all [defaultResponse]
/// can be set for tests that load a single asset and don't need per-path
/// precision.  Unconfigured paths throw [StateError] immediately.
class FakeAssetLoaderRepository implements AssetLoaderRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<AssetLoaderCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-path response stubs
  // -------------------------------------------------------------------------

  final Map<String, ByteData> _responsesByPath = {};
  ByteData? _defaultResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  /// Configure a specific response for [assetPath].
  void whenLoadAsset(String assetPath, ByteData response) {
    _responsesByPath[assetPath] = response;
  }

  /// Set a default response returned for any path not individually configured.
  void whenLoadAssetDefault(ByteData response) {
    _defaultResponse = response;
  }

  // -------------------------------------------------------------------------
  // AssetLoaderRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<ByteData> loadAsset(String assetPath) async {
    calls.add(LoadAssetCall(assetPath: assetPath));
    if (_responsesByPath.containsKey(assetPath)) {
      return _responsesByPath[assetPath]!;
    }
    if (_defaultResponse != null) {
      return _defaultResponse!;
    }
    throw StateError(
      'FakeAssetLoaderRepository: no response configured for '
      'loadAsset("$assetPath")',
    );
  }

  // -------------------------------------------------------------------------
  // Convenience call-count helpers
  // -------------------------------------------------------------------------

  List<LoadAssetCall> get loadAssetCalls =>
      calls.whereType<LoadAssetCall>().toList();

  /// Returns all load calls for a specific [assetPath].
  List<LoadAssetCall> loadAssetCallsFor(String assetPath) =>
      loadAssetCalls.where((c) => c.assetPath == assetPath).toList();
}
