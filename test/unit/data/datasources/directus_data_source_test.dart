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
      test('delegates to apiManager.tryAndRefreshToken on success', () async {
        // Arrange — store a refresh token
        fakeTokenStorage._refreshToken = 'old-refresh-token';
        var refreshCallCount = 0;
        when(() => mockApiManager.refreshToken).thenAnswer((_) {
          // Before tryAndRefreshToken: return null so it falls through to storage
          // After tryAndRefreshToken: return the new token
          return refreshCallCount > 0 ? 'new-refresh-token' : null;
        });
        when(() => mockApiManager.tryAndRefreshToken()).thenAnswer((_) async {
          refreshCallCount++;
          return true;
        });
        when(() => mockApiManager.accessToken).thenReturn('new-access-token');

        // Act
        await dataSource.refreshSession();

        // Assert — tryAndRefreshToken was called
        verify(() => mockApiManager.tryAndRefreshToken()).called(1);
        // refreshToken was set on the api manager before calling
        verify(
          () => mockApiManager.refreshToken = 'old-refresh-token',
        ).called(1);
        // Tokens saved to storage
        expect(await fakeTokenStorage.getAccessToken(), 'new-access-token');
        expect(await fakeTokenStorage.getRefreshToken(), 'new-refresh-token');
        // Restored access token set (accessible via currentAccessToken)
        expect(dataSource.currentAccessToken, 'new-access-token');
      });

      test(
        'clears tokens and throws when tryAndRefreshToken returns false',
        () async {
          // Arrange
          fakeTokenStorage._refreshToken = 'old-refresh-token';
          when(() => mockApiManager.refreshToken).thenReturn(null);
          when(
            () => mockApiManager.tryAndRefreshToken(),
          ).thenAnswer((_) async => false);

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
          // Tokens cleared from storage
          expect(await fakeTokenStorage.getAccessToken(), isNull);
          expect(await fakeTokenStorage.getRefreshToken(), isNull);
        },
      );

      test(
        'throws when no refresh token available without calling tryAndRefreshToken',
        () async {
          // Arrange — no token in storage or api manager
          when(() => mockApiManager.refreshToken).thenReturn(null);

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
          verifyNever(() => mockApiManager.tryAndRefreshToken());
        },
      );
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
              fields:
                  'id,email,first_name,last_name,avatar,role.name,areas.area_id.id,areas.area_id.name',
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

    group('downloadFileBytes', () {
      test('delegates to apiManager.sendRequestToEndpoint', () async {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        when(
          () => mockApiManager.sendRequestToEndpoint<Uint8List>(
            prepareRequest: any(named: 'prepareRequest'),
            jsonConverter: any(named: 'jsonConverter'),
            canSaveResponseToCache: any(named: 'canSaveResponseToCache'),
            canUseCacheForResponse: any(named: 'canUseCacheForResponse'),
          ),
        ).thenAnswer((_) async => bytes);

        // Act
        final result = await dataSource.downloadFileBytes('file-123');

        // Assert
        expect(result, bytes);
        verify(
          () => mockApiManager.sendRequestToEndpoint<Uint8List>(
            prepareRequest: any(named: 'prepareRequest'),
            jsonConverter: any(named: 'jsonConverter'),
            canSaveResponseToCache: any(named: 'canSaveResponseToCache'),
            canUseCacheForResponse: any(named: 'canUseCacheForResponse'),
          ),
        ).called(1);
      });

      test(
        'throws NOT_FOUND when sendRequestToEndpoint propagates 404',
        () async {
          // Arrange
          when(
            () => mockApiManager.sendRequestToEndpoint<Uint8List>(
              prepareRequest: any(named: 'prepareRequest'),
              jsonConverter: any(named: 'jsonConverter'),
              canSaveResponseToCache: any(named: 'canSaveResponseToCache'),
              canUseCacheForResponse: any(named: 'canUseCacheForResponse'),
            ),
          ).thenThrow(
            DirectusException(code: 'NOT_FOUND', message: 'File not found'),
          );

          // Act & Assert
          expect(
            () => dataSource.downloadFileBytes('file-123'),
            throwsA(
              isA<DirectusException>().having(
                (e) => e.code,
                'code',
                'NOT_FOUND',
              ),
            ),
          );
        },
      );

      test('throws DOWNLOAD_FAILED for other errors', () async {
        // Arrange
        when(
          () => mockApiManager.sendRequestToEndpoint<Uint8List>(
            prepareRequest: any(named: 'prepareRequest'),
            jsonConverter: any(named: 'jsonConverter'),
            canSaveResponseToCache: any(named: 'canSaveResponseToCache'),
            canUseCacheForResponse: any(named: 'canUseCacheForResponse'),
          ),
        ).thenThrow(Exception('network error'));

        // Act & Assert
        expect(
          () => dataSource.downloadFileBytes('file-123'),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'DOWNLOAD_FAILED',
            ),
          ),
        );
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
          when(
            () => mockApiManager.tryAndRefreshToken(),
          ).thenAnswer((_) async => true);
          when(
            () => mockApiManager.accessToken,
          ).thenReturn('restored-access-token');
          when(
            () => mockApiManager.refreshToken,
          ).thenReturn('new-refresh-token');

          await dataSource.tryRestoreSession();

          // Act & Assert — restored token should be available
          expect(dataSource.currentAccessToken, 'restored-access-token');
        },
      );
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
          when(
            () => mockApiManager.tryAndRefreshToken(),
          ).thenAnswer((_) async => true);
          // After successful refresh, apiManager returns the new tokens
          when(
            () => mockApiManager.accessToken,
          ).thenReturn('restored-access-token');
          when(
            () => mockApiManager.refreshToken,
          ).thenReturn('new-refresh-token');

          await dataSource.tryRestoreSession();

          // Act & Assert — restored token should be available
          expect(dataSource.currentAccessToken, 'restored-access-token');
        },
      );
    });

    group('requestPasswordReset', () {
      test(
        'delegates to apiManager.requestPasswordReset and returns true',
        () async {
          // Arrange
          when(
            () => mockApiManager.requestPasswordReset(
              email: any(named: 'email'),
              resetUrl: any(named: 'resetUrl'),
            ),
          ).thenAnswer((_) async => true);

          // Act
          final result = await dataSource.requestPasswordReset(
            email: 'test@example.com',
          );

          // Assert
          expect(result, isTrue);
          verify(
            () =>
                mockApiManager.requestPasswordReset(email: 'test@example.com'),
          ).called(1);
        },
      );

      test('passes resetUrl to apiManager when provided', () async {
        // Arrange
        when(
          () => mockApiManager.requestPasswordReset(
            email: any(named: 'email'),
            resetUrl: any(named: 'resetUrl'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        await dataSource.requestPasswordReset(
          email: 'test@example.com',
          resetUrl: 'https://app.example.com/reset-password',
        );

        // Assert
        verify(
          () => mockApiManager.requestPasswordReset(
            email: 'test@example.com',
            resetUrl: 'https://app.example.com/reset-password',
          ),
        ).called(1);
      });

      test('throws DirectusException when apiManager returns false', () async {
        // Arrange
        when(
          () => mockApiManager.requestPasswordReset(
            email: any(named: 'email'),
            resetUrl: any(named: 'resetUrl'),
          ),
        ).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => dataSource.requestPasswordReset(email: 'test@example.com'),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'PASSWORD_RESET_FAILED',
            ),
          ),
        );
      });
    });

    group('confirmPasswordReset', () {
      test(
        'delegates to apiManager.confirmPasswordReset and returns true',
        () async {
          // Arrange
          when(
            () => mockApiManager.confirmPasswordReset(
              token: any(named: 'token'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => true);

          // Act
          final result = await dataSource.confirmPasswordReset(
            token: 'reset-token-123',
            password: 'newPassword1!',
          );

          // Assert
          expect(result, isTrue);
          verify(
            () => mockApiManager.confirmPasswordReset(
              token: 'reset-token-123',
              password: 'newPassword1!',
            ),
          ).called(1);
        },
      );

      test('throws DirectusException when apiManager returns false', () async {
        // Arrange
        when(
          () => mockApiManager.confirmPasswordReset(
            token: any(named: 'token'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => dataSource.confirmPasswordReset(
            token: 'invalid-token',
            password: 'newPassword1!',
          ),
          throwsA(
            isA<DirectusException>().having(
              (e) => e.code,
              'code',
              'PASSWORD_RESET_FAILED',
            ),
          ),
        );
      });
    });

    group('tryRestoreSession', () {
      test(
        'returns true and saves tokens after successful session restore',
        () async {
          // Arrange
          fakeTokenStorage._accessToken = 'old-access';
          fakeTokenStorage._refreshToken = 'old-refresh';
          when(() => mockApiManager.refreshToken).thenReturn(null);
          when(
            () => mockApiManager.tryAndRefreshToken(),
          ).thenAnswer((_) async => true);
          when(() => mockApiManager.accessToken).thenReturn('new-access-token');
          when(
            () => mockApiManager.refreshToken,
          ).thenReturn('new-refresh-token');

          // Act
          final result = await dataSource.tryRestoreSession();

          // Assert
          expect(result, isTrue);
          verify(() => mockApiManager.tryAndRefreshToken()).called(1);
        },
      );
    });
  });
}
