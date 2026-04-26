import 'dart:typed_data';

import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

sealed class FileCall {
  const FileCall();
}

final class UploadCall extends FileCall {
  final Uint8List bytes;
  final String filename;
  const UploadCall({required this.bytes, required this.filename});
}

final class ReplaceCall extends FileCall {
  final String fileId;
  final Uint8List bytes;
  final String filename;
  const ReplaceCall({
    required this.fileId,
    required this.bytes,
    required this.filename,
  });
}

final class ListImageFilesCall extends FileCall {
  const ListImageFilesCall();
}

final class DownloadFileCall extends FileCall {
  final String fileId;
  const DownloadFileCall({required this.fileId});
}

// ---------------------------------------------------------------------------
// FakeFileRepository
// ---------------------------------------------------------------------------

/// Manual fake for [FileRepository].
///
/// Every call is recorded in [calls] as a typed [FileCall].
/// Return values are configured via `when*` setters before the call.
/// Unconfigured methods throw [StateError] immediately.
class FakeFileRepository implements FileRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<FileCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<String, DomainError>? _uploadResponse;
  Result<String, DomainError>? _replaceResponse;
  Result<List<ImageFileInfo>, DomainError>? _listImageFilesResponse;
  Result<Uint8List, DomainError>? _downloadFileResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenUpload(Result<String, DomainError> response) {
    _uploadResponse = response;
  }

  void whenReplace(Result<String, DomainError> response) {
    _replaceResponse = response;
  }

  void whenListImageFiles(Result<List<ImageFileInfo>, DomainError> response) {
    _listImageFilesResponse = response;
  }

  void whenDownloadFile(Result<Uint8List, DomainError> response) {
    _downloadFileResponse = response;
  }

  // -------------------------------------------------------------------------
  // FileRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<String, DomainError>> upload(
    Uint8List bytes,
    String filename,
  ) async {
    calls.add(UploadCall(bytes: bytes, filename: filename));
    if (_uploadResponse != null) {
      return _uploadResponse!;
    }
    throw StateError('FakeFileRepository: no response configured for upload()');
  }

  @override
  Future<Result<String, DomainError>> replace(
    String fileId,
    Uint8List bytes,
    String filename,
  ) async {
    calls.add(ReplaceCall(fileId: fileId, bytes: bytes, filename: filename));
    if (_replaceResponse != null) {
      return _replaceResponse!;
    }
    throw StateError(
      'FakeFileRepository: no response configured for replace()',
    );
  }

  @override
  Future<Result<List<ImageFileInfo>, DomainError>> listImageFiles() async {
    calls.add(const ListImageFilesCall());
    if (_listImageFilesResponse != null) {
      return _listImageFilesResponse!;
    }
    throw StateError(
      'FakeFileRepository: no response configured for listImageFiles()',
    );
  }

  @override
  Future<Result<Uint8List, DomainError>> downloadFile(String fileId) async {
    calls.add(DownloadFileCall(fileId: fileId));
    if (_downloadFileResponse != null) {
      return _downloadFileResponse!;
    }
    throw StateError(
      'FakeFileRepository: no response configured for downloadFile()',
    );
  }

  // -------------------------------------------------------------------------
  // Convenience call-count helpers
  // -------------------------------------------------------------------------

  List<UploadCall> get uploadCalls => calls.whereType<UploadCall>().toList();
  List<ReplaceCall> get replaceCalls => calls.whereType<ReplaceCall>().toList();
  List<ListImageFilesCall> get listImageFilesCalls =>
      calls.whereType<ListImageFilesCall>().toList();
  List<DownloadFileCall> get downloadFileCalls =>
      calls.whereType<DownloadFileCall>().toList();
}
