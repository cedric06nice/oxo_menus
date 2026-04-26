import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/datasources/secure_token_storage.dart';

// ---------------------------------------------------------------------------
// InMemoryStorage
//
// A pure Dart map-backed implementation of the flutter_secure_storage
// platform-channel protocol.  Every MethodChannel call made by
// FlutterSecureStorage is intercepted by the registered mock method-call
// handler and delegated here.
//
// This avoids any platform-channel or Keychain/Keystore access during tests
// without using third-party mocking libraries.
// ---------------------------------------------------------------------------

class InMemoryStorage {
  final Map<String, String?> _store = {};

  Future<Object?> handle(MethodCall call) async {
    if (call.method == 'write') {
      final key = call.arguments['key'] as String;
      final value = call.arguments['value'] as String?;
      _store[key] = value;
      return null;
    }

    if (call.method == 'read') {
      final key = call.arguments['key'] as String;
      return _store[key];
    }

    if (call.method == 'delete') {
      final key = call.arguments['key'] as String;
      _store.remove(key);
      return null;
    }

    if (call.method == 'deleteAll') {
      _store.clear();
      return null;
    }

    if (call.method == 'readAll') {
      return Map<String, String?>.from(_store);
    }

    if (call.method == 'containsKey') {
      final key = call.arguments['key'] as String;
      return _store.containsKey(key);
    }

    // Unknown method — return null (graceful fallback)
    return null;
  }

  // Test-only helpers
  void seed(String key, String value) => _store[key] = value;
  String? read(String key) => _store[key];
  bool containsKey(String key) => _store.containsKey(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryStorage inMemoryStorage;
  late SecureTokenStorage tokenStorage;

  setUp(() {
    inMemoryStorage = InMemoryStorage();

    // Register the platform-channel handler so FlutterSecureStorage calls
    // are routed to InMemoryStorage.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      inMemoryStorage.handle,
    );

    // Use the real SecureTokenStorage with a default-constructed
    // FlutterSecureStorage; platform calls are intercepted above.
    tokenStorage = SecureTokenStorage();
  });

  tearDown(() {
    // Deregister handler so it does not bleed into subsequent tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
  });

  // =========================================================================
  group('SecureTokenStorage', () {
    // -----------------------------------------------------------------------
    group('saveTokens', () {
      test('should persist access token in secure storage', () async {
        // Arrange — nothing stored yet

        // Act
        await tokenStorage.saveTokens(
          accessToken: 'access-abc',
          refreshToken: 'refresh-xyz',
        );

        // Assert
        expect(inMemoryStorage.read('access_token'), 'access-abc');
      });

      test('should persist refresh token in secure storage', () async {
        // Act
        await tokenStorage.saveTokens(
          accessToken: 'access-abc',
          refreshToken: 'refresh-xyz',
        );

        // Assert
        expect(inMemoryStorage.read('refresh_token'), 'refresh-xyz');
      });

      test('should overwrite previously stored tokens when called again',
          () async {
        // Arrange
        await tokenStorage.saveTokens(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
        );

        // Act
        await tokenStorage.saveTokens(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );

        // Assert
        expect(inMemoryStorage.read('access_token'), 'new-access');
        expect(inMemoryStorage.read('refresh_token'), 'new-refresh');
      });
    });

    // -----------------------------------------------------------------------
    group('getAccessToken', () {
      test('should return null when no access token has been stored', () async {
        // Arrange — empty storage

        // Act
        final result = await tokenStorage.getAccessToken();

        // Assert
        expect(result, isNull);
      });

      test('should return the stored access token', () async {
        // Arrange
        inMemoryStorage.seed('access_token', 'my-access-token');

        // Act
        final result = await tokenStorage.getAccessToken();

        // Assert
        expect(result, 'my-access-token');
      });

      test('should round-trip: getAccessToken returns what saveTokens stored',
          () async {
        // Arrange
        await tokenStorage.saveTokens(
          accessToken: 'roundtrip-access',
          refreshToken: 'roundtrip-refresh',
        );

        // Act
        final result = await tokenStorage.getAccessToken();

        // Assert
        expect(result, 'roundtrip-access');
      });
    });

    // -----------------------------------------------------------------------
    group('getRefreshToken', () {
      test('should return null when no refresh token has been stored',
          () async {
        // Arrange — empty storage

        // Act
        final result = await tokenStorage.getRefreshToken();

        // Assert
        expect(result, isNull);
      });

      test('should return the stored refresh token', () async {
        // Arrange
        inMemoryStorage.seed('refresh_token', 'my-refresh-token');

        // Act
        final result = await tokenStorage.getRefreshToken();

        // Assert
        expect(result, 'my-refresh-token');
      });

      test('should round-trip: getRefreshToken returns what saveTokens stored',
          () async {
        // Arrange
        await tokenStorage.saveTokens(
          accessToken: 'any-access',
          refreshToken: 'roundtrip-refresh',
        );

        // Act
        final result = await tokenStorage.getRefreshToken();

        // Assert
        expect(result, 'roundtrip-refresh');
      });
    });

    // -----------------------------------------------------------------------
    group('saveRefreshToken', () {
      test('should persist only the refresh token without touching access token',
          () async {
        // Arrange — access token already in storage
        inMemoryStorage.seed('access_token', 'existing-access');

        // Act
        await tokenStorage.saveRefreshToken('standalone-refresh');

        // Assert — access token untouched
        expect(inMemoryStorage.read('access_token'), 'existing-access');
        expect(inMemoryStorage.read('refresh_token'), 'standalone-refresh');
      });

      test('should overwrite existing refresh token when called again',
          () async {
        // Arrange
        inMemoryStorage.seed('refresh_token', 'old-refresh');

        // Act
        await tokenStorage.saveRefreshToken('updated-refresh');

        // Assert
        expect(inMemoryStorage.read('refresh_token'), 'updated-refresh');
      });

      test('should be retrievable via getRefreshToken after saving', () async {
        // Arrange
        await tokenStorage.saveRefreshToken('callback-refresh');

        // Act
        final result = await tokenStorage.getRefreshToken();

        // Assert
        expect(result, 'callback-refresh');
      });
    });

    // -----------------------------------------------------------------------
    group('hasTokens', () {
      test('should return false when both tokens are absent', () async {
        // Arrange — empty storage

        // Act
        final result = await tokenStorage.hasTokens();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when only access token is present', () async {
        // Arrange
        inMemoryStorage.seed('access_token', 'access-only');

        // Act
        final result = await tokenStorage.hasTokens();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when only refresh token is present', () async {
        // Arrange
        inMemoryStorage.seed('refresh_token', 'refresh-only');

        // Act
        final result = await tokenStorage.hasTokens();

        // Assert
        expect(result, isFalse);
      });

      test('should return true when both tokens are stored', () async {
        // Arrange
        await tokenStorage.saveTokens(
          accessToken: 'has-access',
          refreshToken: 'has-refresh',
        );

        // Act
        final result = await tokenStorage.hasTokens();

        // Assert
        expect(result, isTrue);
      });

      test('should return false after clearTokens removes both tokens',
          () async {
        // Arrange
        await tokenStorage.saveTokens(
          accessToken: 'a',
          refreshToken: 'r',
        );

        // Act
        await tokenStorage.clearTokens();
        final result = await tokenStorage.hasTokens();

        // Assert
        expect(result, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    group('clearTokens', () {
      test('should remove access token from storage', () async {
        // Arrange
        await tokenStorage.saveTokens(
          accessToken: 'access-to-clear',
          refreshToken: 'refresh-to-clear',
        );

        // Act
        await tokenStorage.clearTokens();

        // Assert
        expect(await tokenStorage.getAccessToken(), isNull);
      });

      test('should remove refresh token from storage', () async {
        // Arrange
        await tokenStorage.saveTokens(
          accessToken: 'access-to-clear',
          refreshToken: 'refresh-to-clear',
        );

        // Act
        await tokenStorage.clearTokens();

        // Assert
        expect(await tokenStorage.getRefreshToken(), isNull);
      });

      test('should be a no-op when called on already empty storage', () async {
        // Arrange — nothing stored

        // Act & Assert — completes without error
        await expectLater(tokenStorage.clearTokens(), completes);
      });

      test('should be idempotent when called twice', () async {
        // Arrange
        await tokenStorage.saveTokens(
          accessToken: 'a',
          refreshToken: 'r',
        );

        // Act
        await tokenStorage.clearTokens();
        await tokenStorage.clearTokens();

        // Assert — both reads return null after second call
        expect(await tokenStorage.getAccessToken(), isNull);
        expect(await tokenStorage.getRefreshToken(), isNull);
      });
    });
  });
}
