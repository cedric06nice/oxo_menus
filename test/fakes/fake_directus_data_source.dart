import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';

// ---------------------------------------------------------------------------
// Call-record types
//
// Each method call appended to [calls] is typed as one of these records so
// that tests can assert not just *that* a method was called but *with what
// arguments*.
// ---------------------------------------------------------------------------

/// Sealed union of every recorded call on [FakeDirectusDataSource].
sealed class DirectusCall {
  const DirectusCall();
}

final class LoginCall extends DirectusCall {
  final String email;
  final String password;
  const LoginCall({required this.email, required this.password});
}

final class LogoutCall extends DirectusCall {
  const LogoutCall();
}

final class RefreshSessionCall extends DirectusCall {
  const RefreshSessionCall();
}

final class TryRestoreSessionCall extends DirectusCall {
  const TryRestoreSessionCall();
}

final class GetCurrentUserCall extends DirectusCall {
  const GetCurrentUserCall();
}

final class RequestPasswordResetCall extends DirectusCall {
  final String email;
  final String? resetUrl;
  const RequestPasswordResetCall({required this.email, this.resetUrl});
}

final class ConfirmPasswordResetCall extends DirectusCall {
  final String token;
  final String password;
  const ConfirmPasswordResetCall({required this.token, required this.password});
}

final class GetItemCall extends DirectusCall {
  final Type itemType;
  final int id;
  final List<String>? fields;
  const GetItemCall({required this.itemType, required this.id, this.fields});
}

final class GetItemsCall extends DirectusCall {
  final Type itemType;
  final Map<String, dynamic>? filter;
  final List<String>? fields;
  final List<String>? sort;
  final int? limit;
  final int? offset;
  const GetItemsCall({
    required this.itemType,
    this.filter,
    this.fields,
    this.sort,
    this.limit,
    this.offset,
  });
}

final class CreateItemCall extends DirectusCall {
  final Type itemType;
  final DirectusItem item;
  const CreateItemCall({required this.itemType, required this.item});
}

final class UpdateItemCall extends DirectusCall {
  final Type itemType;
  final DirectusItem item;
  const UpdateItemCall({required this.itemType, required this.item});
}

final class DeleteItemCall extends DirectusCall {
  final Type itemType;
  final int id;
  const DeleteItemCall({required this.itemType, required this.id});
}

final class UploadFileCall extends DirectusCall {
  final Uint8List bytes;
  final String filename;
  const UploadFileCall({required this.bytes, required this.filename});
}

final class ReplaceFileCall extends DirectusCall {
  final String fileId;
  final Uint8List bytes;
  final String filename;
  const ReplaceFileCall({
    required this.fileId,
    required this.bytes,
    required this.filename,
  });
}

final class ListFilesCall extends DirectusCall {
  final Map<String, dynamic>? filter;
  final List<String>? fields;
  final List<String>? sort;
  final int? limit;
  const ListFilesCall({this.filter, this.fields, this.sort, this.limit});
}

final class DownloadFileBytesCall extends DirectusCall {
  final String fileId;
  const DownloadFileBytesCall({required this.fileId});
}

final class StartSubscriptionCall extends DirectusCall {
  final DirectusWebSocketSubscription subscription;
  const StartSubscriptionCall({required this.subscription});
}

final class StopSubscriptionCall extends DirectusCall {
  final String subscriptionUid;
  const StopSubscriptionCall({required this.subscriptionUid});
}

// ---------------------------------------------------------------------------
// FakeDirectusDataSource
// ---------------------------------------------------------------------------

/// A fully manual fake that mirrors the public API of [DirectusDataSource].
///
/// Because [DirectusDataSource] uses a factory constructor it cannot be
/// extended.  This fake is therefore a standalone class with an identical
/// public surface, allowing it to be used in constructor injection patterns
/// just like the real class.
///
/// - Every call is appended to [calls] as a typed [DirectusCall] record.
/// - Return values are configured via `when*` setters before the call.
/// - Unconfigured methods throw [StateError] immediately, making test
///   failures loud and obvious.
///
/// Usage:
/// ```dart
/// final fake = FakeDirectusDataSource();
/// fake.whenGetItems<MenuDto>([{'id': 1, 'name': 'Lunch'}]);
/// final repo = MenuRepositoryImpl(dataSource: fake);
/// ```
class FakeDirectusDataSource {
  // -------------------------------------------------------------------------
  // Call log — tests inspect this after the fact
  // -------------------------------------------------------------------------

  final List<DirectusCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Map<String, dynamic>? _loginResponse;
  Object? _loginError;

  bool? _refreshSessionSuccess;
  Object? _refreshSessionError;

  bool? _tryRestoreSessionResult;

  Map<String, dynamic>? _getCurrentUserResponse;
  Object? _getCurrentUserError;

  bool? _requestPasswordResetResult;
  bool? _confirmPasswordResetResult;

  String? _uploadFileResult;
  Object? _uploadFileError;

  String? _replaceFileResult;
  Object? _replaceFileError;

  List<Map<String, dynamic>>? _listFilesResult;
  Object? _listFilesError;

  Uint8List? _downloadFileBytesResult;
  Object? _downloadFileBytesError;

  // Generic CRUD stubs keyed by '<MethodName><TypeName>', e.g. 'getItem<MenuDto>'
  final Map<String, Object?> _crudResponses = {};

  Object? _startSubscriptionError;

  // -------------------------------------------------------------------------
  // Response setters — authentication
  // -------------------------------------------------------------------------

  void whenLogin(Map<String, dynamic> response) {
    _loginResponse = response;
    _loginError = null;
  }

  void whenLoginThrows(Object error) {
    _loginError = error;
    _loginResponse = null;
  }

  void whenRefreshSession({bool success = true}) {
    _refreshSessionSuccess = success;
    _refreshSessionError = null;
  }

  void whenRefreshSessionThrows(Object error) {
    _refreshSessionError = error;
    _refreshSessionSuccess = null;
  }

  void whenTryRestoreSession(bool result) {
    _tryRestoreSessionResult = result;
  }

  void whenGetCurrentUser(Map<String, dynamic> response) {
    _getCurrentUserResponse = response;
    _getCurrentUserError = null;
  }

  void whenGetCurrentUserThrows(Object error) {
    _getCurrentUserError = error;
    _getCurrentUserResponse = null;
  }

  void whenRequestPasswordReset(bool result) {
    _requestPasswordResetResult = result;
  }

  void whenConfirmPasswordReset(bool result) {
    _confirmPasswordResetResult = result;
  }

  // -------------------------------------------------------------------------
  // Response setters — file operations
  // -------------------------------------------------------------------------

  void whenUploadFile(String fileId) {
    _uploadFileResult = fileId;
    _uploadFileError = null;
  }

  void whenUploadFileThrows(Object error) {
    _uploadFileError = error;
    _uploadFileResult = null;
  }

  void whenReplaceFile(String fileId) {
    _replaceFileResult = fileId;
    _replaceFileError = null;
  }

  void whenReplaceFileThrows(Object error) {
    _replaceFileError = error;
    _replaceFileResult = null;
  }

  void whenListFiles(List<Map<String, dynamic>> result) {
    _listFilesResult = result;
    _listFilesError = null;
  }

  void whenListFilesThrows(Object error) {
    _listFilesError = error;
    _listFilesResult = null;
  }

  void whenDownloadFileBytes(Uint8List bytes) {
    _downloadFileBytesResult = bytes;
    _downloadFileBytesError = null;
  }

  void whenDownloadFileBytesThrows(Object error) {
    _downloadFileBytesError = error;
    _downloadFileBytesResult = null;
  }

  // -------------------------------------------------------------------------
  // Response setters — generic CRUD
  // -------------------------------------------------------------------------

  void whenGetItem<T extends DirectusItem>(Map<String, dynamic> response) {
    _crudResponses[_getItemKey<T>()] = response;
  }

  void whenGetItemThrows<T extends DirectusItem>(Object error) {
    _crudResponses[_getItemKey<T>()] = _Throw(error);
  }

  void whenGetItems<T extends DirectusItem>(
    List<Map<String, dynamic>> response,
  ) {
    _crudResponses[_getItemsKey<T>()] = response;
  }

  void whenGetItemsThrows<T extends DirectusItem>(Object error) {
    _crudResponses[_getItemsKey<T>()] = _Throw(error);
  }

  void whenCreateItem<T extends DirectusItem>(Map<String, dynamic> response) {
    _crudResponses[_createItemKey<T>()] = response;
  }

  void whenCreateItemThrows<T extends DirectusItem>(Object error) {
    _crudResponses[_createItemKey<T>()] = _Throw(error);
  }

  void whenUpdateItem<T extends DirectusItem>(Map<String, dynamic> response) {
    _crudResponses[_updateItemKey<T>()] = response;
  }

  void whenUpdateItemThrows<T extends DirectusItem>(Object error) {
    _crudResponses[_updateItemKey<T>()] = _Throw(error);
  }

  void whenDeleteItem<T extends DirectusItem>() {
    _crudResponses[_deleteItemKey<T>()] = const _DeleteSuccess();
  }

  void whenDeleteItemThrows<T extends DirectusItem>(Object error) {
    _crudResponses[_deleteItemKey<T>()] = _Throw(error);
  }

  // -------------------------------------------------------------------------
  // Generic escape-hatch setter (for ad-hoc cases)
  // -------------------------------------------------------------------------

  /// Sets an arbitrary response by string key (e.g. `'getItems<MenuDto>'`).
  /// Prefer the typed `when*` methods above when possible.
  void setNextResponse(String key, Object? value) {
    _crudResponses[key] = value;
  }

  // -------------------------------------------------------------------------
  // WebSocket stubs
  // -------------------------------------------------------------------------

  void whenStartSubscriptionThrows(Object error) {
    _startSubscriptionError = error;
  }

  // -------------------------------------------------------------------------
  // Public methods mirroring DirectusDataSource
  // -------------------------------------------------------------------------

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    calls.add(LoginCall(email: email, password: password));
    if (_loginError != null) throw _loginError!;
    if (_loginResponse != null) return _loginResponse!;
    throw StateError(
      'FakeDirectusDataSource: no response configured for login()',
    );
  }

  Future<void> logout() async {
    calls.add(const LogoutCall());
  }

  Future<void> refreshSession() async {
    calls.add(const RefreshSessionCall());
    if (_refreshSessionError != null) throw _refreshSessionError!;
    if (_refreshSessionSuccess != null) {
      if (!_refreshSessionSuccess!) {
        throw StateError(
          'FakeDirectusDataSource: refreshSession configured to fail',
        );
      }
      return;
    }
    throw StateError(
      'FakeDirectusDataSource: no response configured for refreshSession()',
    );
  }

  Future<bool> tryRestoreSession() async {
    calls.add(const TryRestoreSessionCall());
    if (_tryRestoreSessionResult != null) return _tryRestoreSessionResult!;
    throw StateError(
      'FakeDirectusDataSource: no response configured for tryRestoreSession()',
    );
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    calls.add(const GetCurrentUserCall());
    if (_getCurrentUserError != null) throw _getCurrentUserError!;
    if (_getCurrentUserResponse != null) return _getCurrentUserResponse!;
    throw StateError(
      'FakeDirectusDataSource: no response configured for getCurrentUser()',
    );
  }

  Future<bool> requestPasswordReset({
    required String email,
    String? resetUrl,
  }) async {
    calls.add(RequestPasswordResetCall(email: email, resetUrl: resetUrl));
    if (_requestPasswordResetResult != null) return _requestPasswordResetResult!;
    throw StateError(
      'FakeDirectusDataSource: no response configured for requestPasswordReset()',
    );
  }

  Future<bool> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    calls.add(ConfirmPasswordResetCall(token: token, password: password));
    if (_confirmPasswordResetResult != null) return _confirmPasswordResetResult!;
    throw StateError(
      'FakeDirectusDataSource: no response configured for confirmPasswordReset()',
    );
  }

  Future<Map<String, dynamic>> getItem<T extends DirectusItem>(
    int id, {
    List<String>? fields,
  }) async {
    calls.add(GetItemCall(itemType: T, id: id, fields: fields));
    final key = _getItemKey<T>();
    final response = _crudResponses[key];
    if (response is _Throw) throw response.error;
    if (_crudResponses.containsKey(key)) return response as Map<String, dynamic>;
    throw StateError(
      'FakeDirectusDataSource: no response configured for getItem<$T>()',
    );
  }

  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    calls.add(
      GetItemsCall(
        itemType: T,
        filter: filter,
        fields: fields,
        sort: sort,
        limit: limit,
        offset: offset,
      ),
    );
    final key = _getItemsKey<T>();
    final response = _crudResponses[key];
    if (response is _Throw) throw response.error;
    if (_crudResponses.containsKey(key)) {
      return response as List<Map<String, dynamic>>;
    }
    throw StateError(
      'FakeDirectusDataSource: no response configured for getItems<$T>()',
    );
  }

  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(
    T newItem,
  ) async {
    calls.add(CreateItemCall(itemType: T, item: newItem));
    final key = _createItemKey<T>();
    final response = _crudResponses[key];
    if (response is _Throw) throw response.error;
    if (_crudResponses.containsKey(key)) return response as Map<String, dynamic>;
    throw StateError(
      'FakeDirectusDataSource: no response configured for createItem<$T>()',
    );
  }

  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async {
    calls.add(UpdateItemCall(itemType: T, item: itemToUpdate));
    final key = _updateItemKey<T>();
    final response = _crudResponses[key];
    if (response is _Throw) throw response.error;
    if (_crudResponses.containsKey(key)) return response as Map<String, dynamic>;
    throw StateError(
      'FakeDirectusDataSource: no response configured for updateItem<$T>()',
    );
  }

  Future<void> deleteItem<T extends DirectusItem>(int id) async {
    calls.add(DeleteItemCall(itemType: T, id: id));
    final key = _deleteItemKey<T>();
    final response = _crudResponses[key];
    if (response is _Throw) throw response.error;
    if (_crudResponses.containsKey(key)) return;
    throw StateError(
      'FakeDirectusDataSource: no response configured for deleteItem<$T>()',
    );
  }

  Future<String> uploadFile(Uint8List bytes, String filename) async {
    calls.add(UploadFileCall(bytes: bytes, filename: filename));
    if (_uploadFileError != null) throw _uploadFileError!;
    if (_uploadFileResult != null) return _uploadFileResult!;
    throw StateError(
      'FakeDirectusDataSource: no response configured for uploadFile()',
    );
  }

  Future<String> replaceFile(
    String fileId,
    Uint8List bytes,
    String filename,
  ) async {
    calls.add(ReplaceFileCall(fileId: fileId, bytes: bytes, filename: filename));
    if (_replaceFileError != null) throw _replaceFileError!;
    if (_replaceFileResult != null) return _replaceFileResult!;
    throw StateError(
      'FakeDirectusDataSource: no response configured for replaceFile()',
    );
  }

  Future<List<Map<String, dynamic>>> listFiles({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
  }) async {
    calls.add(
      ListFilesCall(filter: filter, fields: fields, sort: sort, limit: limit),
    );
    if (_listFilesError != null) throw _listFilesError!;
    if (_listFilesResult != null) return _listFilesResult!;
    throw StateError(
      'FakeDirectusDataSource: no response configured for listFiles()',
    );
  }

  Future<Uint8List> downloadFileBytes(String fileId) async {
    calls.add(DownloadFileBytesCall(fileId: fileId));
    if (_downloadFileBytesError != null) throw _downloadFileBytesError!;
    if (_downloadFileBytesResult != null) return _downloadFileBytesResult!;
    throw StateError(
      'FakeDirectusDataSource: no response configured for downloadFileBytes()',
    );
  }

  Future<void> startSubscription(
    DirectusWebSocketSubscription subscription,
  ) async {
    calls.add(StartSubscriptionCall(subscription: subscription));
    if (_startSubscriptionError != null) throw _startSubscriptionError!;
  }

  Future<void> stopSubscription(String subscriptionUid) async {
    calls.add(StopSubscriptionCall(subscriptionUid: subscriptionUid));
  }

  // -------------------------------------------------------------------------
  // Private key builders
  // -------------------------------------------------------------------------

  String _getItemKey<T>() => 'getItem<$T>';
  String _getItemsKey<T>() => 'getItems<$T>';
  String _createItemKey<T>() => 'createItem<$T>';
  String _updateItemKey<T>() => 'updateItem<$T>';
  String _deleteItemKey<T>() => 'deleteItem<$T>';

  // -------------------------------------------------------------------------
  // Convenience call-count helpers for assertions
  // -------------------------------------------------------------------------

  /// Counts calls matching [predicate].
  int countCalls(bool Function(DirectusCall) predicate) =>
      calls.where(predicate).length;

  /// All [GetItemsCall] records for a specific DTO type.
  List<GetItemsCall> getItemsCalls<T>() =>
      calls.whereType<GetItemsCall>().where((c) => c.itemType == T).toList();

  /// All [CreateItemCall] records for a specific DTO type.
  List<CreateItemCall> createItemCalls<T>() =>
      calls.whereType<CreateItemCall>().where((c) => c.itemType == T).toList();

  /// All [UpdateItemCall] records for a specific DTO type.
  List<UpdateItemCall> updateItemCalls<T>() =>
      calls.whereType<UpdateItemCall>().where((c) => c.itemType == T).toList();

  /// All [DeleteItemCall] records for a specific DTO type.
  List<DeleteItemCall> deleteItemCalls<T>() =>
      calls.whereType<DeleteItemCall>().where((c) => c.itemType == T).toList();
}

// ---------------------------------------------------------------------------
// Internal sentinels
// ---------------------------------------------------------------------------

class _Throw {
  final Object error;
  const _Throw(this.error);
}

class _DeleteSuccess {
  const _DeleteSuccess();
}
