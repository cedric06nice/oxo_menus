import 'dart:collection';
import 'dart:typed_data';

import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';
import 'package:oxo_menus/shared/domain/repositories/file_repository.dart';

/// Gateway for image data, layered on top of [FileRepository].
///
/// [getBytes] is cached LRU (default 100 entries). [listImages] is a direct
/// pass-through. Failed in-flight futures are evicted so the next call retries.
///
/// One instance lives on `AppContainer`; UI consumers receive it via the widget
/// system context and use it instead of reaching into Riverpod for image data.
class ImageGateway {
  ImageGateway({required FileRepository repository, int maxEntries = 100})
    : _repository = repository,
      _maxEntries = maxEntries;

  final FileRepository _repository;
  final int _maxEntries;
  final LinkedHashMap<String, Future<Uint8List>> _cache = LinkedHashMap();

  /// Return the bytes for [fileId], reusing an in-flight or completed future
  /// when one exists. Failed futures are evicted.
  Future<Uint8List> getBytes(String fileId) {
    final existing = _cache.remove(fileId);
    if (existing != null) {
      _cache[fileId] = existing;
      return existing;
    }
    final future = _fetch(fileId);
    _evictExcess();
    _cache[fileId] = future;
    return future;
  }

  Future<Uint8List> _fetch(String fileId) async {
    try {
      final result = await _repository.downloadFile(fileId);
      return switch (result) {
        Success(:final value) => value,
        Failure(:final error) => throw error,
      };
    } catch (e) {
      _cache.remove(fileId);
      rethrow;
    }
  }

  void _evictExcess() {
    while (_cache.length >= _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Pass-through to [FileRepository.listImageFiles]. Not cached — the list
  /// of available images is small and may be refreshed by uploads, so callers
  /// always see the latest snapshot.
  Future<Result<List<ImageFileInfo>, DomainError>> listImages() {
    return _repository.listImageFiles();
  }
}
