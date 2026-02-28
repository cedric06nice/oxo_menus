import 'dart:convert';
import 'dart:typed_data';

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/datasources/secure_token_storage.dart';

class MockDirectusApiManager extends Mock implements DirectusApiManager {}

class MockHttpClient extends Mock implements http.Client {}

class FakeTokenStorage extends Fake implements SecureTokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    _refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<bool> hasTokens() async =>
      _accessToken != null && _refreshToken != null;

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

class FakeUri extends Fake implements Uri {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(<String, String>{});
    registerFallbackValue(FakeBaseRequest());
  });

  group('DirectusDataSource', () {
    late MockDirectusApiManager mockApiManager;
    late MockHttpClient mockHttpClient;
    late FakeTokenStorage fakeTokenStorage;
    late DirectusDataSource dataSource;

    setUp(() {
      mockApiManager = MockDirectusApiManager();
      mockHttpClient = MockHttpClient();
      fakeTokenStorage = FakeTokenStorage();
      dataSource = DirectusDataSource(
        baseUrl: 'http://localhost:8055',
        apiManager: mockApiManager,
        httpClient: mockHttpClient,
        tokenStorage: fakeTokenStorage,
      );
    });

    group('constructor', () {
      test('can be constructed with injected dependencies', () {
        expect(dataSource, isNotNull);
      });
    });

    group('refreshSession', () {
      test(
        'syncs refreshToken to apiManager after successful refresh',
        () async {
          // Arrange — store a refresh token
          fakeTokenStorage._refreshToken = 'old-refresh-token';
          when(() => mockApiManager.refreshToken).thenReturn(null);

          final responseBody = json.encode({
            'data': {
              'access_token': 'new-access-token',
              'refresh_token': 'new-refresh-token',
            },
          });
          when(
            () => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => http.Response(responseBody, 200));

          // Act
          await dataSource.refreshSession();

          // Assert — refreshToken was set on the api manager
          verify(
            () => mockApiManager.refreshToken = 'new-refresh-token',
          ).called(1);
        },
      );

      test('uses injected httpClient instead of top-level http', () async {
        // Arrange
        fakeTokenStorage._refreshToken = 'old-refresh-token';
        when(() => mockApiManager.refreshToken).thenReturn(null);

        final responseBody = json.encode({
          'data': {
            'access_token': 'new-access-token',
            'refresh_token': 'new-refresh-token',
          },
        });
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.refreshSession();

        // Assert — the mock httpClient was used (not top-level http.post)
        verify(
          () => mockHttpClient.post(
            Uri.parse('http://localhost:8055/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'refresh_token': 'old-refresh-token',
              'mode': 'json',
            }),
          ),
        ).called(1);
      });

      test('clears tokens and throws when refresh fails', () async {
        // Arrange
        fakeTokenStorage._refreshToken = 'old-refresh-token';
        when(() => mockApiManager.refreshToken).thenReturn(null);

        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        // Act & Assert
        expect(
          () => dataSource.refreshSession(),
          throwsA(isA<DirectusException>()),
        );
      });
    });

    group('getCurrentUser delegates to apiManager', () {
      test(
        'uses apiManager.currentDirectusUser with expanded role fields',
        () async {
          // Arrange
          final mockUser = DirectusUser({
            'id': 'user-1',
            'email': 'test@example.com',
            'first_name': 'Test',
            'last_name': 'User',
            'role': {'name': 'admin'},
          });
          when(
            () => mockApiManager.currentDirectusUser(
              fields: any(named: 'fields'),
              canUseCacheForResponse: any(named: 'canUseCacheForResponse'),
              canSaveResponseToCache: any(named: 'canSaveResponseToCache'),
            ),
          ).thenAnswer((_) async => mockUser);

          // Act
          final result = await dataSource.getCurrentUser();

          // Assert — delegated to apiManager, not raw httpClient
          verify(
            () => mockApiManager.currentDirectusUser(
              fields: 'id,email,first_name,last_name,avatar,role.name',
              canUseCacheForResponse: false,
              canSaveResponseToCache: false,
            ),
          ).called(1);
          verifyNever(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          );
          expect(result['id'], 'user-1');
          expect(result['email'], 'test@example.com');
          expect(result['role'], {'name': 'admin'});
        },
      );

      test('throws NOT_AUTHENTICATED when apiManager returns null', () async {
        // Arrange
        when(
          () => mockApiManager.currentDirectusUser(
            fields: any(named: 'fields'),
            canUseCacheForResponse: any(named: 'canUseCacheForResponse'),
            canSaveResponseToCache: any(named: 'canSaveResponseToCache'),
          ),
        ).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'NOT_AUTHENTICATED',
            ),
          ),
        );
      });
    });

    group('uploadFile uses httpClient', () {
      test('sends multipart request via injected httpClient', () async {
        // Arrange
        when(() => mockApiManager.accessToken).thenReturn('test-token');

        final responseBody = json.encode({
          'data': {'id': 'file-123'},
        });
        when(() => mockHttpClient.send(any())).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(utf8.encode(responseBody)),
            200,
          ),
        );

        // Act
        final fileId = await dataSource.uploadFile(
          Uint8List.fromList([1, 2, 3]),
          'test.png',
        );

        // Assert
        expect(fileId, 'file-123');
        verify(() => mockHttpClient.send(any())).called(1);
      });
    });

    group('downloadFileBytes uses httpClient', () {
      test('uses injected httpClient for GET request', () async {
        // Arrange
        when(() => mockApiManager.accessToken).thenReturn('test-token');

        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response.bytes(bytes, 200));

        // Act
        final result = await dataSource.downloadFileBytes('file-123');

        // Assert
        expect(result, bytes);
        verify(
          () => mockHttpClient.get(
            Uri.parse('http://localhost:8055/assets/file-123'),
            headers: {'Authorization': 'Bearer test-token'},
          ),
        ).called(1);
      });
    });

    group('currentAccessToken', () {
      test('returns accessToken from apiManager when available', () {
        when(() => mockApiManager.accessToken).thenReturn('api-token');

        expect(dataSource.currentAccessToken, 'api-token');
      });

      test('returns null when no token is available', () {
        when(() => mockApiManager.accessToken).thenReturn(null);

        expect(dataSource.currentAccessToken, isNull);
      });

      test(
        'returns restored token after session restore when apiManager has none',
        () async {
          // Arrange — restore a session
          fakeTokenStorage._accessToken = 'old-access';
          fakeTokenStorage._refreshToken = 'old-refresh';
          when(() => mockApiManager.refreshToken).thenReturn(null);
          when(() => mockApiManager.accessToken).thenReturn(null);

          final refreshResponse = json.encode({
            'data': {
              'access_token': 'restored-access-token',
              'refresh_token': 'new-refresh-token',
            },
          });
          when(
            () => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => http.Response(refreshResponse, 200));

          await dataSource.tryRestoreSession();

          // Act & Assert — restored token should be available
          expect(dataSource.currentAccessToken, 'restored-access-token');
        },
      );
    });

    group('tryRestoreSession', () {
      test(
        'sets apiManager.refreshToken after successful session restore',
        () async {
          // Arrange
          fakeTokenStorage._accessToken = 'old-access';
          fakeTokenStorage._refreshToken = 'old-refresh';
          when(() => mockApiManager.refreshToken).thenReturn(null);

          final refreshResponse = json.encode({
            'data': {
              'access_token': 'new-access-token',
              'refresh_token': 'new-refresh-token',
            },
          });
          when(
            () => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => http.Response(refreshResponse, 200));

          // Act
          final result = await dataSource.tryRestoreSession();

          // Assert
          expect(result, isTrue);
          verify(
            () => mockApiManager.refreshToken = 'new-refresh-token',
          ).called(1);
        },
      );
    });
  });
}
