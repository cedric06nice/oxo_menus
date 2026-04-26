import 'dart:convert';
import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';

import '../../../fakes/fake_secure_token_storage.dart';
import '../../../fakes/reflectable_bootstrap.dart';

// ---------------------------------------------------------------------------
// FakeDirectusApiManager
//
// Extends the concrete DirectusApiManager so the DirectusDataSource constructor
// can accept it without modifications.  Every method used by DirectusDataSource
// is overridden with controlled behaviour; calls are recorded for assertion.
// ---------------------------------------------------------------------------

class FakeDirectusApiManager extends DirectusApiManager {
  FakeDirectusApiManager()
    : super(baseURL: 'http://localhost:8055', httpClient: http.Client());

  // --- call log ---

  final List<String> calledMethods = [];

  // --- stubs for loginDirectusUser ---
  DirectusLoginResult? _loginResult;

  void stubLogin(DirectusLoginResult result) {
    _loginResult = result;
  }

  @override
  Future<DirectusLoginResult> loginDirectusUser(
    String username,
    String password, {
    String? oneTimePassword,
  }) async {
    calledMethods.add('loginDirectusUser');
    if (_loginResult != null) {
      return _loginResult!;
    }
    throw StateError('FakeDirectusApiManager: login not stubbed');
  }

  // --- stubs for logoutDirectusUser ---
  bool _logoutResult = true;

  void stubLogout({bool result = true}) {
    _logoutResult = result;
  }

  @override
  Future<bool> logoutDirectusUser() async {
    calledMethods.add('logoutDirectusUser');
    return _logoutResult;
  }

  // --- stubs for currentDirectusUser ---
  DirectusUser? _currentUser;
  Object? _currentUserError;

  void stubCurrentUser(DirectusUser user) {
    _currentUser = user;
    _currentUserError = null;
  }

  void stubCurrentUserThrows(Object error) {
    _currentUserError = error;
    _currentUser = null;
  }

  void stubCurrentUserReturnsNull() {
    _currentUser = null;
    _currentUserError = null;
  }

  @override
  Future<DirectusUser?> currentDirectusUser({
    String fields = '*',
    bool canUseCacheForResponse = false,
    bool canSaveResponseToCache = true,
    bool canUseOldCachedResponseAsFallback = true,
    Duration maxCacheAge = const Duration(days: 1),
  }) async {
    calledMethods.add('currentDirectusUser');
    if (_currentUserError != null) throw _currentUserError!;
    return _currentUser;
  }

  // --- stubs for tryAndRefreshToken ---
  bool _tryAndRefreshTokenResult = true;

  void stubTryAndRefreshToken({required bool result}) {
    _tryAndRefreshTokenResult = result;
  }

  @override
  Future<bool> tryAndRefreshToken() async {
    calledMethods.add('tryAndRefreshToken');
    return _tryAndRefreshTokenResult;
  }

  // --- stubs for requestPasswordReset ---
  bool _requestPasswordResetResult = true;

  void stubRequestPasswordReset({required bool result}) {
    _requestPasswordResetResult = result;
  }

  @override
  Future<bool> requestPasswordReset({
    required String email,
    String? resetUrl,
  }) async {
    calledMethods.add('requestPasswordReset');
    _lastRequestPasswordResetEmail = email;
    _lastRequestPasswordResetUrl = resetUrl;
    return _requestPasswordResetResult;
  }

  String? _lastRequestPasswordResetEmail;
  String? _lastRequestPasswordResetUrl;

  String? get lastRequestPasswordResetEmail => _lastRequestPasswordResetEmail;
  String? get lastRequestPasswordResetUrl => _lastRequestPasswordResetUrl;

  // --- stubs for confirmPasswordReset ---
  bool _confirmPasswordResetResult = true;

  void stubConfirmPasswordReset({required bool result}) {
    _confirmPasswordResetResult = result;
  }

  @override
  Future<bool> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    calledMethods.add('confirmPasswordReset');
    _lastConfirmToken = token;
    _lastConfirmPassword = password;
    return _confirmPasswordResetResult;
  }

  String? _lastConfirmToken;
  String? _lastConfirmPassword;

  String? get lastConfirmToken => _lastConfirmToken;
  String? get lastConfirmPassword => _lastConfirmPassword;

  // --- stubs for getSpecificItem ---
  DirectusData? _getSpecificItemResult;
  Object? _getSpecificItemError;
  String? _lastGetSpecificItemId;
  String? _lastGetSpecificItemFields;

  void stubGetSpecificItem(DirectusData item) {
    _getSpecificItemResult = item;
    _getSpecificItemError = null;
  }

  void stubGetSpecificItemReturnsNull() {
    _getSpecificItemResult = null;
    _getSpecificItemError = null;
  }

  void stubGetSpecificItemThrows(Object error) {
    _getSpecificItemError = error;
    _getSpecificItemResult = null;
  }

  String? get lastGetSpecificItemId => _lastGetSpecificItemId;
  String? get lastGetSpecificItemFields => _lastGetSpecificItemFields;

  @override
  Future<T?> getSpecificItem<T extends DirectusData>({
    required String id,
    String? fields,
    String? requestIdentifier,
    bool canUseCacheForResponse = false,
    bool canSaveResponseToCache = true,
    bool canUseOldCachedResponseAsFallback = true,
    List<String> extraTags = const [],
    Duration maxCacheAge = const Duration(days: 1),
  }) async {
    calledMethods.add('getSpecificItem');
    _lastGetSpecificItemId = id;
    _lastGetSpecificItemFields = fields;
    if (_getSpecificItemError != null) throw _getSpecificItemError!;
    return _getSpecificItemResult as T?;
  }

  // --- stubs for findListOfItems ---
  List<DirectusData> _findListOfItemsResult = [];
  Object? _findListOfItemsError;
  Filter? _lastFindListFilter;
  List<SortProperty>? _lastFindListSortBy;
  String? _lastFindListFields;
  int? _lastFindListLimit;
  int? _lastFindListOffset;

  void stubFindListOfItems(List<DirectusData> items) {
    _findListOfItemsResult = items;
    _findListOfItemsError = null;
  }

  void stubFindListOfItemsThrows(Object error) {
    _findListOfItemsError = error;
  }

  Filter? get lastFindListFilter => _lastFindListFilter;
  List<SortProperty>? get lastFindListSortBy => _lastFindListSortBy;
  String? get lastFindListFields => _lastFindListFields;
  int? get lastFindListLimit => _lastFindListLimit;
  int? get lastFindListOffset => _lastFindListOffset;

  @override
  Future<Iterable<T>> findListOfItems<T extends DirectusData>({
    Filter? filter,
    List<SortProperty>? sortBy,
    String? fields,
    int? limit,
    int? offset,
    String? requestIdentifier,
    bool canUseCacheForResponse = false,
    bool canSaveResponseToCache = true,
    bool canUseOldCachedResponseAsFallback = true,
    List<String> extraTags = const [],
    Duration maxCacheAge = const Duration(days: 1),
  }) async {
    calledMethods.add('findListOfItems');
    _lastFindListFilter = filter;
    _lastFindListSortBy = sortBy;
    _lastFindListFields = fields;
    _lastFindListLimit = limit;
    _lastFindListOffset = offset;
    if (_findListOfItemsError != null) throw _findListOfItemsError!;
    return List<T>.from(_findListOfItemsResult);
  }

  // --- stubs for createNewItem ---
  // We store the stub data untyped so the override can re-create the result
  // with the correct generic type T, working around Dart's reified generics.
  bool? _createNewItemSuccess;
  DirectusData? _createNewItemCreatedItem;
  DirectusApiError? _createNewItemFailureError;
  Object? _createNewItemError;
  DirectusItem? _lastCreatedItem;

  void stubCreateNewItem(DirectusItem createdItem) {
    _createNewItemSuccess = true;
    _createNewItemCreatedItem = createdItem;
    _createNewItemFailureError = null;
    _createNewItemError = null;
  }

  void stubCreateNewItemFailure(DirectusApiError error) {
    _createNewItemSuccess = false;
    _createNewItemFailureError = error;
    _createNewItemCreatedItem = null;
    _createNewItemError = null;
  }

  void stubCreateNewItemThrows(Object error) {
    _createNewItemError = error;
    _createNewItemSuccess = null;
    _createNewItemCreatedItem = null;
    _createNewItemFailureError = null;
  }

  DirectusItem? get lastCreatedItem => _lastCreatedItem;

  @override
  Future<DirectusItemCreationResult<T>> createNewItem<T extends DirectusData>({
    required T objectToCreate,
    String? fields,
    List<String> extraTagsToClear = const [],
  }) async {
    calledMethods.add('createNewItem');
    _lastCreatedItem = objectToCreate as DirectusItem;
    if (_createNewItemError != null) throw _createNewItemError!;
    if (_createNewItemSuccess == true) {
      final item = _createNewItemCreatedItem as T?;
      return DirectusItemCreationResult<T>(isSuccess: true, createdItem: item);
    }
    if (_createNewItemSuccess == false) {
      return DirectusItemCreationResult<T>(
        isSuccess: false,
        error: _createNewItemFailureError!,
      );
    }
    throw StateError('FakeDirectusApiManager: createNewItem not stubbed');
  }

  // --- stubs for updateItem ---
  DirectusItem? _updateItemResult;
  Object? _updateItemError;
  DirectusItem? _lastUpdatedItem;

  void stubUpdateItem(DirectusItem item) {
    _updateItemResult = item;
    _updateItemError = null;
  }

  void stubUpdateItemThrows(Object error) {
    _updateItemError = error;
    _updateItemResult = null;
  }

  DirectusItem? get lastUpdatedItem => _lastUpdatedItem;

  @override
  Future<T> updateItem<T extends DirectusData>({
    required T objectToUpdate,
    String? fields,
    List<String> extraTagsToClear = const [],
    bool force = false,
  }) async {
    calledMethods.add('updateItem');
    _lastUpdatedItem = objectToUpdate as DirectusItem;
    if (_updateItemError != null) throw _updateItemError!;
    if (_updateItemResult != null) {
      return _updateItemResult! as T;
    }
    throw StateError('FakeDirectusApiManager: updateItem not stubbed');
  }

  // --- stubs for deleteItem ---
  bool _deleteItemResult = true;
  Object? _deleteItemError;
  String? _lastDeletedItemId;

  void stubDeleteItem({bool result = true}) {
    _deleteItemResult = result;
    _deleteItemError = null;
  }

  void stubDeleteItemThrows(Object error) {
    _deleteItemError = error;
  }

  String? get lastDeletedItemId => _lastDeletedItemId;

  @override
  Future<bool> deleteItem<T extends DirectusData>({
    required String objectId,
    bool mustBeAuthenticated = true,
    List<String> extraTagsToClear = const [],
  }) async {
    calledMethods.add('deleteItem');
    _lastDeletedItemId = objectId;
    if (_deleteItemError != null) throw _deleteItemError!;
    return _deleteItemResult;
  }

  // --- stubs for sendRequestToEndpoint ---
  Object? _sendRequestToEndpointResult;
  Object? _sendRequestToEndpointError;

  void stubSendRequestToEndpoint(Object result) {
    _sendRequestToEndpointResult = result;
    _sendRequestToEndpointError = null;
  }

  void stubSendRequestToEndpointThrows(Object error) {
    _sendRequestToEndpointError = error;
    _sendRequestToEndpointResult = null;
  }

  @override
  Future<T> sendRequestToEndpoint<T>({
    required http.BaseRequest Function() prepareRequest,
    required T Function(http.Response) jsonConverter,
    String? requestIdentifier,
    bool canUseCacheForResponse = false,
    bool canSaveResponseToCache = true,
    bool canUseOldCachedResponseAsFallback = true,
    List<String> extraTagsToAssociate = const [],
    List<String> extraTagsToClear = const [],
    Duration maxCacheAge = const Duration(days: 1),
  }) async {
    calledMethods.add('sendRequestToEndpoint');
    if (_sendRequestToEndpointError != null) {
      throw _sendRequestToEndpointError!;
    }
    if (_sendRequestToEndpointResult != null) {
      return _sendRequestToEndpointResult! as T;
    }
    throw StateError(
      'FakeDirectusApiManager: sendRequestToEndpoint not stubbed',
    );
  }

  // --- stubs for startWebsocketSubscription ---
  Object? _startWebsocketSubscriptionError;
  DirectusWebSocketSubscription? _lastStartedSubscription;

  void stubStartWebsocketSubscriptionThrows(Object error) {
    _startWebsocketSubscriptionError = error;
  }

  DirectusWebSocketSubscription? get lastStartedSubscription =>
      _lastStartedSubscription;

  @override
  Future<void> startWebsocketSubscription(
    DirectusWebSocketSubscription subscription,
  ) async {
    calledMethods.add('startWebsocketSubscription');
    _lastStartedSubscription = subscription;
    if (_startWebsocketSubscriptionError != null) {
      throw _startWebsocketSubscriptionError!;
    }
  }

  // --- stubs for stopWebsocketSubscription ---
  String? _lastStoppedSubscriptionUid;

  String? get lastStoppedSubscriptionUid => _lastStoppedSubscriptionUid;

  @override
  Future<void> stopWebsocketSubscription(String webSocketSubscriptionId) async {
    calledMethods.add('stopWebsocketSubscription');
    _lastStoppedSubscriptionUid = webSocketSubscriptionId;
  }

  // --- overrideable token accessors ---

  String? _accessTokenOverride;
  String? _refreshTokenOverride;

  void setAccessToken(String? token) => _accessTokenOverride = token;
  void setRefreshToken(String? token) => _refreshTokenOverride = token;

  @override
  String? get accessToken => _accessTokenOverride;

  @override
  String? get refreshToken => _refreshTokenOverride;

  @override
  set refreshToken(String? value) => _refreshTokenOverride = value;
}

// ---------------------------------------------------------------------------
// FakeHttpClient
//
// Minimal fake for http.Client that returns a canned StreamedResponse.
// Used only for upload / replace-file tests where DirectusDataSource
// calls _httpClient.send() directly.
// ---------------------------------------------------------------------------

class FakeHttpClient extends http.BaseClient {
  http.StreamedResponse? _nextResponse;
  Object? _nextError;
  http.BaseRequest? _lastRequest;

  void stubResponse(http.StreamedResponse response) {
    _nextResponse = response;
    _nextError = null;
  }

  void stubThrows(Object error) {
    _nextError = error;
    _nextResponse = null;
  }

  http.BaseRequest? get lastRequest => _lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _lastRequest = request;
    if (_nextError != null) throw _nextError!;
    if (_nextResponse != null) return _nextResponse!;
    throw StateError('FakeHttpClient: no response stubbed');
  }
}

// ---------------------------------------------------------------------------
// Helper – build a JSON response body string
// ---------------------------------------------------------------------------

String _jsonBody(Map<String, dynamic> data) => json.encode(data);

http.StreamedResponse _streamedResponse(String body, {int statusCode = 200}) {
  return http.StreamedResponse(Stream.value(utf8.encode(body)), statusCode);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(initializeReflectableForTests);

  late FakeDirectusApiManager fakeApiManager;
  late FakeSecureTokenStorage fakeStorage;
  late FakeHttpClient fakeHttpClient;
  late DirectusDataSource dataSource;

  setUp(() {
    fakeApiManager = FakeDirectusApiManager();
    fakeStorage = FakeSecureTokenStorage();
    fakeHttpClient = FakeHttpClient();
    dataSource = DirectusDataSource(
      baseUrl: 'http://localhost:8055',
      apiManager: fakeApiManager,
      tokenStorage: fakeStorage,
      httpClient: fakeHttpClient,
    );
  });

  // =========================================================================
  group('DirectusDataSource construction', () {
    test(
      'should expose non-null instance when constructed with dependencies',
      () {
        expect(dataSource, isNotNull);
      },
    );
  });

  // =========================================================================
  group('currentAccessToken', () {
    test('should return null when apiManager has no token and no restore', () {
      fakeApiManager.setAccessToken(null);

      expect(dataSource.currentAccessToken, isNull);
    });

    test('should return apiManager access token when available', () {
      fakeApiManager.setAccessToken('live-access-token');

      expect(dataSource.currentAccessToken, 'live-access-token');
    });

    test(
      'should return restored token after successful refreshSession',
      () async {
        // Arrange
        fakeStorage.seedTokens(
          accessToken: 'stored-access',
          refreshToken: 'stored-refresh',
        );
        fakeApiManager.setRefreshToken(null); // no token in manager initially
        fakeApiManager.stubTryAndRefreshToken(result: true);
        fakeApiManager.setAccessToken('restored-access');
        fakeApiManager.setRefreshToken('restored-refresh');

        // Act
        await dataSource.refreshSession();

        // Assert
        expect(dataSource.currentAccessToken, 'restored-access');
      },
    );
  });

  // =========================================================================
  group('login', () {
    test('should return user data and tokens on successful login', () async {
      // Arrange
      fakeApiManager.setAccessToken('new-access');
      fakeApiManager.setRefreshToken('new-refresh');
      fakeApiManager.stubLogin(
        const DirectusLoginResult(DirectusLoginResultType.success),
      );
      fakeApiManager.stubCurrentUser(
        DirectusUser({
          'id': 'user-1',
          'email': 'chef@restaurant.com',
          'first_name': 'Chef',
          'last_name': 'Masters',
          'role': {'name': 'Admin'},
        }),
      );

      // Act
      final result = await dataSource.login(
        email: 'chef@restaurant.com',
        password: 's3cret',
      );

      // Assert
      expect(result['user'], isA<Map<String, dynamic>>());
      expect(result['access_token'], 'new-access');
      expect(result['refresh_token'], 'new-refresh');
    });

    test('should save tokens to storage on successful login', () async {
      // Arrange
      fakeApiManager.setAccessToken('tok-access');
      fakeApiManager.setRefreshToken('tok-refresh');
      fakeApiManager.stubLogin(
        const DirectusLoginResult(DirectusLoginResultType.success),
      );
      fakeApiManager.stubCurrentUser(
        DirectusUser({'id': 'u1', 'email': 'a@b.com'}),
      );

      // Act
      await dataSource.login(email: 'a@b.com', password: 'pass');

      // Assert
      expect(fakeStorage.storedAccessToken, 'tok-access');
      expect(fakeStorage.storedRefreshToken, 'tok-refresh');
    });

    test(
      'should throw INVALID_CREDENTIALS when login result is invalidCredentials',
      () async {
        // Arrange
        fakeApiManager.stubLogin(
          const DirectusLoginResult(DirectusLoginResultType.invalidCredentials),
        );

        // Act & Assert
        await expectLater(
          () => dataSource.login(email: 'bad@email.com', password: 'wrong'),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'INVALID_CREDENTIALS',
            ),
          ),
        );
      },
    );

    test('should throw INVALID_OTP when login result is invalidOTP', () async {
      // Arrange
      fakeApiManager.stubLogin(
        const DirectusLoginResult(DirectusLoginResultType.invalidOTP),
      );

      // Act & Assert
      await expectLater(
        () => dataSource.login(email: 'a@b.com', password: 'pass'),
        throwsA(
          isA<DirectusException>().having((e) => e.code, 'code', 'INVALID_OTP'),
        ),
      );
    });

    test(
      'should throw REQUESTS_EXCEEDED when login result is requestsExceeded',
      () async {
        // Arrange
        fakeApiManager.stubLogin(
          const DirectusLoginResult(
            DirectusLoginResultType.requestsExceeded,
            message: 'Rate limited',
          ),
        );

        // Act & Assert
        await expectLater(
          () => dataSource.login(email: 'a@b.com', password: 'pass'),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'REQUESTS_EXCEEDED',
            ),
          ),
        );
      },
    );

    test('should throw LOGIN_ERROR when login result is error', () async {
      // Arrange
      fakeApiManager.stubLogin(
        const DirectusLoginResult(
          DirectusLoginResultType.error,
          message: 'Server exploded',
        ),
      );

      // Act & Assert
      await expectLater(
        () => dataSource.login(email: 'a@b.com', password: 'pass'),
        throwsA(
          isA<DirectusException>().having((e) => e.code, 'code', 'LOGIN_ERROR'),
        ),
      );
    });

    test('should not save tokens when login fails', () async {
      // Arrange
      fakeApiManager.stubLogin(
        const DirectusLoginResult(DirectusLoginResultType.invalidCredentials),
      );

      // Act
      try {
        await dataSource.login(email: 'bad@email.com', password: 'nope');
      } on DirectusException {
        // expected
      }

      // Assert — storage is untouched
      expect(fakeStorage.storedAccessToken, isNull);
      expect(fakeStorage.storedRefreshToken, isNull);
    });
  });

  // =========================================================================
  group('logout', () {
    test('should call logoutDirectusUser on apiManager', () async {
      // Arrange
      fakeStorage.seedTokens(
        accessToken: 'existing-access',
        refreshToken: 'existing-refresh',
      );

      // Act
      await dataSource.logout();

      // Assert
      expect(fakeApiManager.calledMethods, contains('logoutDirectusUser'));
    });

    test('should clear tokens from storage on logout', () async {
      // Arrange
      fakeStorage.seedTokens(
        accessToken: 'existing-access',
        refreshToken: 'existing-refresh',
      );

      // Act
      await dataSource.logout();

      // Assert
      expect(fakeStorage.storedAccessToken, isNull);
      expect(fakeStorage.storedRefreshToken, isNull);
    });

    test('should clear restoredAccessToken on logout', () async {
      // Arrange: simulate a restored session
      fakeStorage.seedTokens(
        accessToken: 'stored-access',
        refreshToken: 'stored-refresh',
      );
      fakeApiManager.setRefreshToken(null);
      fakeApiManager.stubTryAndRefreshToken(result: true);
      fakeApiManager.setAccessToken('restored-access');
      fakeApiManager.setRefreshToken('restored-refresh');
      await dataSource.refreshSession();
      expect(dataSource.currentAccessToken, 'restored-access');

      // Act
      fakeApiManager.setAccessToken(null);
      await dataSource.logout();

      // Assert
      expect(dataSource.currentAccessToken, isNull);
    });
  });

  // =========================================================================
  group('refreshSession', () {
    test(
      'should call tryAndRefreshToken on apiManager when refresh token available',
      () async {
        // Arrange
        fakeStorage.seedTokens(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
        );
        fakeApiManager.setRefreshToken(null);
        fakeApiManager.stubTryAndRefreshToken(result: true);
        fakeApiManager.setAccessToken('new-access');
        fakeApiManager.setRefreshToken('new-refresh');

        // Act
        await dataSource.refreshSession();

        // Assert
        expect(fakeApiManager.calledMethods, contains('tryAndRefreshToken'));
      },
    );

    test('should save new tokens to storage on successful refresh', () async {
      // Arrange
      fakeStorage.seedTokens(
        accessToken: 'old-access',
        refreshToken: 'old-refresh',
      );
      fakeApiManager.setRefreshToken(null);
      fakeApiManager.stubTryAndRefreshToken(result: true);
      fakeApiManager.setAccessToken('fresh-access');
      fakeApiManager.setRefreshToken('fresh-refresh');

      // Act
      await dataSource.refreshSession();

      // Assert
      expect(fakeStorage.storedAccessToken, 'fresh-access');
      expect(fakeStorage.storedRefreshToken, 'fresh-refresh');
    });

    test('should prefer apiManager refresh token over stored one', () async {
      // Arrange: manager already has a token (takes priority)
      fakeApiManager.setRefreshToken('manager-refresh');
      fakeStorage.seedTokens(
        accessToken: 'stored-access',
        refreshToken: 'stored-refresh',
      );
      fakeApiManager.stubTryAndRefreshToken(result: true);
      fakeApiManager.setAccessToken('new-access');
      fakeApiManager.setRefreshToken('new-refresh');

      // Act
      await dataSource.refreshSession();

      // Assert — tryAndRefreshToken was called
      expect(fakeApiManager.calledMethods, contains('tryAndRefreshToken'));
    });

    test(
      'should throw TOKEN_EXPIRED when no refresh token is available',
      () async {
        // Arrange — neither manager nor storage has a refresh token
        fakeApiManager.setRefreshToken(null);
        // storage has no tokens either (default empty state)

        // Act & Assert
        await expectLater(
          () => dataSource.refreshSession(),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'TOKEN_EXPIRED',
            ),
          ),
        );
      },
    );

    test(
      'should throw TOKEN_EXPIRED and clear storage when refresh fails',
      () async {
        // Arrange
        fakeStorage.seedTokens(
          accessToken: 'stale-access',
          refreshToken: 'stale-refresh',
        );
        fakeApiManager.setRefreshToken(null);
        fakeApiManager.stubTryAndRefreshToken(result: false);

        // Act & Assert
        await expectLater(
          () => dataSource.refreshSession(),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'TOKEN_EXPIRED',
            ),
          ),
        );
        expect(fakeStorage.storedAccessToken, isNull);
        expect(fakeStorage.storedRefreshToken, isNull);
      },
    );

    test(
      'should throw TOKEN_EXPIRED when refresh succeeds but tokens are null',
      () async {
        // Arrange: tryAndRefreshToken succeeds but manager returns null tokens
        fakeStorage.seedTokens(
          accessToken: 'some-access',
          refreshToken: 'some-refresh',
        );
        fakeApiManager.setRefreshToken(null);
        fakeApiManager.stubTryAndRefreshToken(result: true);
        fakeApiManager.setAccessToken(null); // manager returns null tokens
        fakeApiManager.setRefreshToken(null);

        // Act & Assert
        await expectLater(
          () => dataSource.refreshSession(),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'TOKEN_EXPIRED',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  group('tryRestoreSession', () {
    test('should return false when no tokens are stored', () async {
      // Arrange — storage is empty (default state)

      // Act
      final result = await dataSource.tryRestoreSession();

      // Assert
      expect(result, isFalse);
    });

    test('should return true after a successful session restore', () async {
      // Arrange
      fakeStorage.seedTokens(
        accessToken: 'stored-access',
        refreshToken: 'stored-refresh',
      );
      fakeApiManager.setRefreshToken(null);
      fakeApiManager.stubTryAndRefreshToken(result: true);
      fakeApiManager.setAccessToken('fresh-access');
      fakeApiManager.setRefreshToken('fresh-refresh');

      // Act
      final result = await dataSource.tryRestoreSession();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when refreshSession throws', () async {
      // Arrange — tokens present but refresh fails
      fakeStorage.seedTokens(
        accessToken: 'stale-access',
        refreshToken: 'stale-refresh',
      );
      fakeApiManager.setRefreshToken(null);
      fakeApiManager.stubTryAndRefreshToken(result: false);

      // Act
      final result = await dataSource.tryRestoreSession();

      // Assert
      expect(result, isFalse);
    });
  });

  // =========================================================================
  group('getCurrentUser', () {
    test('should return user map with fields from apiManager', () async {
      // Arrange
      fakeApiManager.stubCurrentUser(
        DirectusUser({
          'id': 'user-42',
          'email': 'head@chef.com',
          'first_name': 'Gordon',
          'last_name': 'Ramsay',
          'role': {'name': 'Admin'},
        }),
      );

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result['id'], 'user-42');
      expect(result['email'], 'head@chef.com');
      expect(result['role'], {'name': 'Admin'});
    });

    test(
      'should call apiManager.currentDirectusUser with expanded role fields',
      () async {
        // Arrange
        fakeApiManager.stubCurrentUser(
          DirectusUser({'id': 'u1', 'email': 'a@b.com'}),
        );

        // Act
        await dataSource.getCurrentUser();

        // Assert
        expect(fakeApiManager.calledMethods, contains('currentDirectusUser'));
      },
    );

    test(
      'should throw NOT_AUTHENTICATED when apiManager returns null',
      () async {
        // Arrange
        fakeApiManager.stubCurrentUserReturnsNull();

        // Act & Assert
        await expectLater(
          () => dataSource.getCurrentUser(),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'NOT_AUTHENTICATED',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  group('requestPasswordReset', () {
    test('should delegate to apiManager and return true on success', () async {
      // Arrange
      fakeApiManager.stubRequestPasswordReset(result: true);

      // Act
      final result = await dataSource.requestPasswordReset(
        email: 'chef@restaurant.com',
      );

      // Assert
      expect(result, isTrue);
      expect(fakeApiManager.calledMethods, contains('requestPasswordReset'));
      expect(
        fakeApiManager.lastRequestPasswordResetEmail,
        'chef@restaurant.com',
      );
    });

    test('should forward optional resetUrl to apiManager', () async {
      // Arrange
      fakeApiManager.stubRequestPasswordReset(result: true);

      // Act
      await dataSource.requestPasswordReset(
        email: 'chef@restaurant.com',
        resetUrl: 'https://app.example.com/reset',
      );

      // Assert
      expect(
        fakeApiManager.lastRequestPasswordResetUrl,
        'https://app.example.com/reset',
      );
    });

    test(
      'should throw PASSWORD_RESET_FAILED when apiManager returns false',
      () async {
        // Arrange
        fakeApiManager.stubRequestPasswordReset(result: false);

        // Act & Assert
        await expectLater(
          () => dataSource.requestPasswordReset(email: 'bad@email.com'),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'PASSWORD_RESET_FAILED',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  group('confirmPasswordReset', () {
    test('should delegate to apiManager and return true on success', () async {
      // Arrange
      fakeApiManager.stubConfirmPasswordReset(result: true);

      // Act
      final result = await dataSource.confirmPasswordReset(
        token: 'reset-token-abc',
        password: 'NewP@ss1',
      );

      // Assert
      expect(result, isTrue);
      expect(fakeApiManager.lastConfirmToken, 'reset-token-abc');
      expect(fakeApiManager.lastConfirmPassword, 'NewP@ss1');
    });

    test(
      'should throw PASSWORD_RESET_FAILED when apiManager returns false',
      () async {
        // Arrange
        fakeApiManager.stubConfirmPasswordReset(result: false);

        // Act & Assert
        await expectLater(
          () => dataSource.confirmPasswordReset(
            token: 'invalid-token',
            password: 'NewP@ss1',
          ),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'PASSWORD_RESET_FAILED',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  group('getItem', () {
    test('should return raw data map of the matching item', () async {
      // Arrange
      final dto = MenuDto({
        'id': 10,
        'name': 'Summer Menu',
        'version': '1',
        'status': 'published',
      });
      fakeApiManager.stubGetSpecificItem(dto);

      // Act
      final result = await dataSource.getItem<MenuDto>(10);

      // Assert
      expect(result['id'], 10);
      expect(result['name'], 'Summer Menu');
    });

    test('should forward id as string to apiManager.getSpecificItem', () async {
      // Arrange
      final dto = MenuDto({
        'id': 7,
        'name': 'Lunch',
        'version': '1',
        'status': 'draft',
      });
      fakeApiManager.stubGetSpecificItem(dto);

      // Act
      await dataSource.getItem<MenuDto>(7);

      // Assert
      expect(fakeApiManager.lastGetSpecificItemId, '7');
    });

    test(
      'should forward fields parameter to apiManager.getSpecificItem',
      () async {
        // Arrange
        final dto = MenuDto({
          'id': 5,
          'name': 'N',
          'version': '1',
          'status': 'draft',
        });
        fakeApiManager.stubGetSpecificItem(dto);

        // Act
        await dataSource.getItem<MenuDto>(5, fields: ['id', 'name']);

        // Assert
        expect(fakeApiManager.lastGetSpecificItemFields, 'id,name');
      },
    );

    test('should throw NOT_FOUND when apiManager returns null', () async {
      // Arrange
      fakeApiManager.stubGetSpecificItemReturnsNull();

      // Act & Assert
      await expectLater(
        () => dataSource.getItem<MenuDto>(999),
        throwsA(
          isA<DirectusException>().having((e) => e.code, 'code', 'NOT_FOUND'),
        ),
      );
    });
  });

  // =========================================================================
  group('getItems', () {
    test('should return a list of raw data maps', () async {
      // Arrange
      fakeApiManager.stubFindListOfItems([
        MenuDto({
          'id': 1,
          'name': 'Breakfast',
          'version': '1',
          'status': 'published',
        }),
        MenuDto({'id': 2, 'name': 'Lunch', 'version': '2', 'status': 'draft'}),
      ]);

      // Act
      final results = await dataSource.getItems<MenuDto>();

      // Assert
      expect(results, hasLength(2));
      expect(results[0]['name'], 'Breakfast');
      expect(results[1]['name'], 'Lunch');
    });

    test(
      'should return an empty list when apiManager returns no items',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        final results = await dataSource.getItems<MenuDto>();

        // Assert
        expect(results, isEmpty);
      },
    );

    test(
      'should forward limit and offset to apiManager.findListOfItems',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        await dataSource.getItems<MenuDto>(limit: 5, offset: 10);

        // Assert
        expect(fakeApiManager.lastFindListLimit, 5);
        expect(fakeApiManager.lastFindListOffset, 10);
      },
    );

    test(
      'should forward fields string to apiManager.findListOfItems',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        await dataSource.getItems<MenuDto>(fields: ['id', 'name', 'status']);

        // Assert
        expect(fakeApiManager.lastFindListFields, 'id,name,status');
      },
    );

    test(
      'should convert ascending sort field to SortProperty with ascending true',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        await dataSource.getItems<MenuDto>(sort: ['name']);

        // Assert
        final sortBy = fakeApiManager.lastFindListSortBy;
        expect(sortBy, isNotNull);
        expect(sortBy!.single.name, 'name');
        expect(sortBy.single.ascending, isTrue);
      },
    );

    test(
      'should convert descending sort field (prefixed with -) to SortProperty with ascending false',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        await dataSource.getItems<MenuDto>(sort: ['-date_created']);

        // Assert
        final sortBy = fakeApiManager.lastFindListSortBy;
        expect(sortBy, isNotNull);
        expect(sortBy!.single.name, 'date_created');
        expect(sortBy.single.ascending, isFalse);
      },
    );

    test(
      'should convert equality filter to PropertyFilter with equals operator',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        await dataSource.getItems<MenuDto>(
          filter: {
            'status': {'_eq': 'published'},
          },
        );

        // Assert
        final filter = fakeApiManager.lastFindListFilter;
        expect(filter, isA<PropertyFilter>());
        final pf = filter as PropertyFilter;
        expect(pf.field, 'status');
        expect(pf.operator, FilterOperator.equals);
        expect(pf.value, 'published');
      },
    );

    test('should combine multiple filter conditions with AND', () async {
      // Arrange
      fakeApiManager.stubFindListOfItems([]);

      // Act
      await dataSource.getItems<MenuDto>(
        filter: {
          'status': {'_eq': 'published'},
          'version': {'_neq': '0'},
        },
      );

      // Assert
      final filter = fakeApiManager.lastFindListFilter;
      expect(filter, isA<LogicalOperatorFilter>());
      final lof = filter as LogicalOperatorFilter;
      expect(lof.operator, LogicalOperator.and);
      expect(lof.children, hasLength(2));
    });

    test(
      'should pass null filter to apiManager when filter map is empty',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        await dataSource.getItems<MenuDto>(filter: {});

        // Assert
        expect(fakeApiManager.lastFindListFilter, isNull);
      },
    );

    test('should support _null filter operator mapping to isNull', () async {
      // Arrange
      fakeApiManager.stubFindListOfItems([]);

      // Act
      await dataSource.getItems<MenuDto>(
        filter: {
          'user_updated': {'_null': true},
        },
      );

      // Assert
      final filter = fakeApiManager.lastFindListFilter;
      expect(filter, isA<PropertyFilter>());
      final pf = filter as PropertyFilter;
      expect(pf.operator, FilterOperator.isNull);
    });

    test(
      'should support _contains filter operator mapping to contains',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        await dataSource.getItems<MenuDto>(
          filter: {
            'name': {'_contains': 'summer'},
          },
        );

        // Assert
        final filter = fakeApiManager.lastFindListFilter;
        expect(filter, isA<PropertyFilter>());
        final pf = filter as PropertyFilter;
        expect(pf.operator, FilterOperator.contains);
        expect(pf.value, 'summer');
      },
    );

    test('should support _in filter operator mapping to oneOf', () async {
      // Arrange
      fakeApiManager.stubFindListOfItems([]);

      // Act
      await dataSource.getItems<MenuDto>(
        filter: {
          'status': {
            '_in': ['published', 'draft'],
          },
        },
      );

      // Assert
      final filter = fakeApiManager.lastFindListFilter;
      expect(filter, isA<PropertyFilter>());
      final pf = filter as PropertyFilter;
      expect(pf.operator, FilterOperator.oneOf);
    });

    test('should skip unsupported filter operator without crashing', () async {
      // Arrange
      fakeApiManager.stubFindListOfItems([]);

      // Act — unsupported operator _unknown should produce a null filter
      await dataSource.getItems<MenuDto>(
        filter: {
          'status': {'_unknown_op': 'value'},
        },
      );

      // Assert — no filter produced, no exception
      expect(fakeApiManager.lastFindListFilter, isNull);
    });

    test(
      'should support _between operator with a two-element list value',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        await dataSource.getItems<MenuDto>(
          filter: {
            'index': {
              '_between': [1, 10],
            },
          },
        );

        // Assert
        final filter = fakeApiManager.lastFindListFilter;
        expect(filter, isA<PropertyFilter>());
        final pf = filter as PropertyFilter;
        expect(pf.operator, FilterOperator.between);
      },
    );

    test(
      'should ignore _between operator when value is not a two-element list',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act — value is a single-element list, not valid for _between
        await dataSource.getItems<MenuDto>(
          filter: {
            'index': {
              '_between': [1],
            },
          },
        );

        // Assert — filter should be null because _between was invalid
        expect(fakeApiManager.lastFindListFilter, isNull);
      },
    );
  });

  // =========================================================================
  group('createItem', () {
    test('should return raw data of the created item on success', () async {
      // Arrange
      final newDto = MenuDto.newItem(name: 'Dinner Menu', version: '1');
      final createdDto = MenuDto({
        'id': 99,
        'name': 'Dinner Menu',
        'version': '1',
        'status': 'draft',
      });
      fakeApiManager.stubCreateNewItem(createdDto);

      // Act
      final result = await dataSource.createItem<MenuDto>(newDto);

      // Assert
      expect(result['id'], 99);
      expect(result['name'], 'Dinner Menu');
    });

    test(
      'should throw CREATE_FAILED when creation result is not success',
      () async {
        // Arrange
        final newDto = MenuDto.newItem(name: 'Bad Menu', version: '1');
        fakeApiManager.stubCreateNewItemFailure(
          DirectusApiError(customMessage: 'Validation failed'),
        );

        // Act & Assert
        await expectLater(
          () => dataSource.createItem<MenuDto>(newDto),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'CREATE_FAILED',
            ),
          ),
        );
      },
    );

    test('should forward item to apiManager.createNewItem', () async {
      // Arrange
      final newDto = MenuDto.newItem(name: 'Wedding Menu', version: '1');
      final createdDto = MenuDto({
        'id': 55,
        'name': 'Wedding Menu',
        'version': '1',
        'status': 'draft',
      });
      fakeApiManager.stubCreateNewItem(createdDto);

      // Act
      await dataSource.createItem<MenuDto>(newDto);

      // Assert
      expect(fakeApiManager.lastCreatedItem, same(newDto));
    });
  });

  // =========================================================================
  group('updateItem', () {
    test('should return updated raw data map on success', () async {
      // Arrange
      final existing = MenuDto({
        'id': 3,
        'name': 'Old Name',
        'version': '1',
        'status': 'draft',
      });
      existing.setValue('Updated Name', forKey: 'name');
      final returned = MenuDto({
        'id': 3,
        'name': 'Updated Name',
        'version': '1',
        'status': 'draft',
      });
      fakeApiManager.stubUpdateItem(returned);

      // Act
      final result = await dataSource.updateItem<MenuDto>(existing);

      // Assert
      expect(result['name'], 'Updated Name');
    });

    test('should forward item to apiManager.updateItem', () async {
      // Arrange
      final dto = MenuDto({
        'id': 8,
        'name': 'Menu',
        'version': '1',
        'status': 'draft',
      });
      fakeApiManager.stubUpdateItem(dto);

      // Act
      await dataSource.updateItem<MenuDto>(dto);

      // Assert
      expect(fakeApiManager.lastUpdatedItem, same(dto));
    });
  });

  // =========================================================================
  group('deleteItem', () {
    test('should complete without error when deletion succeeds', () async {
      // Arrange
      fakeApiManager.stubDeleteItem(result: true);

      // Act & Assert — no exception
      await expectLater(dataSource.deleteItem<MenuDto>(42), completes);
    });

    test('should forward id as string to apiManager.deleteItem', () async {
      // Arrange
      fakeApiManager.stubDeleteItem(result: true);

      // Act
      await dataSource.deleteItem<MenuDto>(42);

      // Assert
      expect(fakeApiManager.lastDeletedItemId, '42');
    });

    test('should throw DELETE_FAILED when apiManager returns false', () async {
      // Arrange
      fakeApiManager.stubDeleteItem(result: false);

      // Act & Assert
      await expectLater(
        () => dataSource.deleteItem<MenuDto>(42),
        throwsA(
          isA<DirectusException>().having(
            (e) => e.code,
            'code',
            'DELETE_FAILED',
          ),
        ),
      );
    });
  });

  // =========================================================================
  group('uploadFile', () {
    test('should return file ID from HTTP response on success', () async {
      // Arrange
      fakeApiManager.setAccessToken('upload-token');
      fakeHttpClient.stubResponse(
        _streamedResponse(
          _jsonBody({
            'data': {'id': 'file-abc-123'},
          }),
        ),
      );

      // Act
      final fileId = await dataSource.uploadFile(
        Uint8List.fromList([1, 2, 3]),
        'menu-image.png',
      );

      // Assert
      expect(fileId, 'file-abc-123');
    });

    test('should send multipart POST to /files endpoint', () async {
      // Arrange
      fakeApiManager.setAccessToken('upload-token');
      fakeHttpClient.stubResponse(
        _streamedResponse(
          _jsonBody({
            'data': {'id': 'file-xyz'},
          }),
        ),
      );

      // Act
      await dataSource.uploadFile(Uint8List.fromList([255]), 'test.jpg');

      // Assert
      final req = fakeHttpClient.lastRequest as http.MultipartRequest?;
      expect(req, isNotNull);
      expect(req!.method, 'POST');
      expect(req.url.path, '/files');
    });

    test('should include Bearer token in Authorization header', () async {
      // Arrange
      fakeApiManager.setAccessToken('bearer-abc');
      fakeHttpClient.stubResponse(
        _streamedResponse(
          _jsonBody({
            'data': {'id': 'f1'},
          }),
        ),
      );

      // Act
      await dataSource.uploadFile(Uint8List.fromList([1]), 'img.png');

      // Assert
      final req = fakeHttpClient.lastRequest as http.MultipartRequest?;
      expect(req!.headers['Authorization'], 'Bearer bearer-abc');
    });

    test(
      'should throw NOT_AUTHENTICATED when no access token is available',
      () async {
        // Arrange
        fakeApiManager.setAccessToken(null);

        // Act & Assert
        await expectLater(
          () => dataSource.uploadFile(Uint8List.fromList([1]), 'img.png'),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'NOT_AUTHENTICATED',
            ),
          ),
        );
      },
    );

    test('should throw NOT_AUTHENTICATED on HTTP 401 response', () async {
      // Arrange
      fakeApiManager.setAccessToken('tok');
      fakeHttpClient.stubResponse(
        _streamedResponse('{"errors":[]}', statusCode: 401),
      );

      // Act & Assert
      await expectLater(
        () => dataSource.uploadFile(Uint8List.fromList([1]), 'img.png'),
        throwsA(
          isA<DirectusException>().having(
            (e) => e.code,
            'code',
            'NOT_AUTHENTICATED',
          ),
        ),
      );
    });

    test('should throw UPLOAD_FAILED on non-2xx non-401 response', () async {
      // Arrange
      fakeApiManager.setAccessToken('tok');
      fakeHttpClient.stubResponse(
        _streamedResponse('{"errors":[]}', statusCode: 500),
      );

      // Act & Assert
      await expectLater(
        () => dataSource.uploadFile(Uint8List.fromList([1]), 'img.png'),
        throwsA(
          isA<DirectusException>().having(
            (e) => e.code,
            'code',
            'UPLOAD_FAILED',
          ),
        ),
      );
    });

    test(
      'should throw UPLOAD_FAILED when response has no file ID in data',
      () async {
        // Arrange
        fakeApiManager.setAccessToken('tok');
        fakeHttpClient.stubResponse(_streamedResponse(_jsonBody({'data': {}})));

        // Act & Assert
        await expectLater(
          () => dataSource.uploadFile(Uint8List.fromList([1]), 'img.png'),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'UPLOAD_FAILED',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  group('replaceFile', () {
    test('should return file ID from HTTP response on success', () async {
      // Arrange
      fakeApiManager.setAccessToken('replace-token');
      fakeHttpClient.stubResponse(
        _streamedResponse(
          _jsonBody({
            'data': {'id': 'file-xyz-999'},
          }),
        ),
      );

      // Act
      final fileId = await dataSource.replaceFile(
        'file-xyz-999',
        Uint8List.fromList([9, 8, 7]),
        'updated-menu.pdf',
      );

      // Assert
      expect(fileId, 'file-xyz-999');
    });

    test('should send PATCH to /files/:id endpoint', () async {
      // Arrange
      fakeApiManager.setAccessToken('tok');
      fakeHttpClient.stubResponse(
        _streamedResponse(
          _jsonBody({
            'data': {'id': 'f-77'},
          }),
        ),
      );

      // Act
      await dataSource.replaceFile('f-77', Uint8List.fromList([1]), 'file.pdf');

      // Assert
      final req = fakeHttpClient.lastRequest as http.MultipartRequest?;
      expect(req!.method, 'PATCH');
      expect(req.url.path, '/files/f-77');
    });

    test('should set Bearer Authorization header on PATCH request', () async {
      // Arrange
      fakeApiManager.setAccessToken('replace-bearer');
      fakeHttpClient.stubResponse(
        _streamedResponse(
          _jsonBody({
            'data': {'id': 'f-1'},
          }),
        ),
      );

      // Act
      await dataSource.replaceFile('f-1', Uint8List.fromList([1]), 'menu.pdf');

      // Assert
      final req = fakeHttpClient.lastRequest as http.MultipartRequest?;
      expect(req!.headers['Authorization'], 'Bearer replace-bearer');
    });

    test(
      'should use the provided filename in the multipart file part',
      () async {
        // Arrange
        fakeApiManager.setAccessToken('tok');
        fakeHttpClient.stubResponse(
          _streamedResponse(
            _jsonBody({
              'data': {'id': 'f-2'},
            }),
          ),
        );

        // Act
        await dataSource.replaceFile(
          'f-2',
          Uint8List.fromList([1]),
          'SummerMenu.pdf',
        );

        // Assert
        final req = fakeHttpClient.lastRequest as http.MultipartRequest?;
        expect(req!.files.single.filename, 'SummerMenu.pdf');
      },
    );

    test('should throw NOT_AUTHENTICATED when access token is null', () async {
      // Arrange
      fakeApiManager.setAccessToken(null);

      // Act & Assert
      await expectLater(
        () => dataSource.replaceFile('f-1', Uint8List.fromList([1]), 'f.pdf'),
        throwsA(
          isA<DirectusException>().having(
            (e) => e.code,
            'code',
            'NOT_AUTHENTICATED',
          ),
        ),
      );
    });

    test('should throw NOT_AUTHENTICATED on HTTP 401 response', () async {
      // Arrange
      fakeApiManager.setAccessToken('tok');
      fakeHttpClient.stubResponse(
        _streamedResponse('{"errors":[]}', statusCode: 401),
      );

      // Act & Assert
      await expectLater(
        () => dataSource.replaceFile('f-1', Uint8List.fromList([1]), 'f.pdf'),
        throwsA(
          isA<DirectusException>().having(
            (e) => e.code,
            'code',
            'NOT_AUTHENTICATED',
          ),
        ),
      );
    });

    test('should throw UPLOAD_FAILED on non-2xx non-401 response', () async {
      // Arrange
      fakeApiManager.setAccessToken('tok');
      fakeHttpClient.stubResponse(
        _streamedResponse('{"errors":[]}', statusCode: 503),
      );

      // Act & Assert
      await expectLater(
        () => dataSource.replaceFile('f-1', Uint8List.fromList([1]), 'f.pdf'),
        throwsA(
          isA<DirectusException>().having(
            (e) => e.code,
            'code',
            'UPLOAD_FAILED',
          ),
        ),
      );
    });
  });

  // =========================================================================
  group('downloadFileBytes', () {
    test('should return bytes from apiManager.sendRequestToEndpoint', () async {
      // Arrange
      final expected = Uint8List.fromList([10, 20, 30, 40]);
      fakeApiManager.stubSendRequestToEndpoint(expected);

      // Act
      final result = await dataSource.downloadFileBytes('file-download-id');

      // Assert
      expect(result, expected);
    });

    test('should call apiManager.sendRequestToEndpoint once', () async {
      // Arrange
      final bytes = Uint8List.fromList([1]);
      fakeApiManager.stubSendRequestToEndpoint(bytes);

      // Act
      await dataSource.downloadFileBytes('some-file');

      // Assert
      expect(fakeApiManager.calledMethods, contains('sendRequestToEndpoint'));
    });

    test(
      'should rethrow DirectusException with NOT_FOUND code from apiManager',
      () async {
        // Arrange
        fakeApiManager.stubSendRequestToEndpointThrows(
          DirectusException(code: 'NOT_FOUND', message: 'File not found'),
        );

        // Act & Assert
        await expectLater(
          () => dataSource.downloadFileBytes('missing-file'),
          throwsA(
            isA<DirectusException>().having((e) => e.code, 'code', 'NOT_FOUND'),
          ),
        );
      },
    );

    test(
      'should wrap non-DirectusException errors in DOWNLOAD_FAILED exception',
      () async {
        // Arrange
        fakeApiManager.stubSendRequestToEndpointThrows(
          Exception('Network timeout'),
        );

        // Act & Assert
        await expectLater(
          () => dataSource.downloadFileBytes('some-file'),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'DOWNLOAD_FAILED',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  group('listFiles', () {
    test('should return raw data maps from apiManager', () async {
      // Arrange
      fakeApiManager.stubFindListOfItems([
        DirectusFile({'id': 'img-1', 'filename_download': 'photo.jpg'}),
        DirectusFile({'id': 'img-2', 'filename_download': 'menu.pdf'}),
      ]);

      // Act
      final results = await dataSource.listFiles();

      // Assert
      expect(results, hasLength(2));
    });

    test('should return an empty list when no files match filter', () async {
      // Arrange
      fakeApiManager.stubFindListOfItems([]);

      // Act
      final results = await dataSource.listFiles();

      // Assert
      expect(results, isEmpty);
    });

    test('should forward limit to apiManager.findListOfItems', () async {
      // Arrange
      fakeApiManager.stubFindListOfItems([]);

      // Act
      await dataSource.listFiles(limit: 20);

      // Assert
      expect(fakeApiManager.lastFindListLimit, 20);
    });

    test('should forward fields to apiManager.findListOfItems', () async {
      // Arrange
      fakeApiManager.stubFindListOfItems([]);

      // Act
      await dataSource.listFiles(fields: ['id', 'filename_download']);

      // Assert
      expect(fakeApiManager.lastFindListFields, 'id,filename_download');
    });

    test(
      'should convert descending sort field prefix to SortProperty',
      () async {
        // Arrange
        fakeApiManager.stubFindListOfItems([]);

        // Act
        await dataSource.listFiles(sort: ['-uploaded_on']);

        // Assert
        final sortBy = fakeApiManager.lastFindListSortBy;
        expect(sortBy, isNotNull);
        expect(sortBy!.single.ascending, isFalse);
        expect(sortBy.single.name, 'uploaded_on');
      },
    );
  });

  // =========================================================================
  group('DirectusException', () {
    test('should have correct code and message fields', () {
      final ex = DirectusException(
        code: 'SERVER_ERROR',
        message: 'Something went wrong',
      );

      expect(ex.code, 'SERVER_ERROR');
      expect(ex.message, 'Something went wrong');
    });

    test('should format toString as code - message', () {
      final ex = DirectusException(code: 'NOT_FOUND', message: 'Item missing');

      expect(ex.toString(), contains('NOT_FOUND'));
      expect(ex.toString(), contains('Item missing'));
    });
  });
}
