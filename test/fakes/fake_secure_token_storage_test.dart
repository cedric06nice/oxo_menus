import 'package:flutter_test/flutter_test.dart';

import 'fake_secure_token_storage.dart';

void main() {
  group('FakeSecureTokenStorage', () {
    late FakeSecureTokenStorage storage;

    setUp(() {
      storage = FakeSecureTokenStorage();
    });

    group('initial state', () {
      test('should have no access token after construction', () async {
        // Act
        final token = await storage.getAccessToken();

        // Assert
        expect(token, isNull);
      });

      test('should have no refresh token after construction', () async {
        // Act
        final token = await storage.getRefreshToken();

        // Assert
        expect(token, isNull);
      });

      test('should report hasTokens as false when no tokens stored', () async {
        // Act
        final hasTokens = await storage.hasTokens();

        // Assert
        expect(hasTokens, isFalse);
      });
    });

    group('saveTokens()', () {
      test('should persist both tokens', () async {
        // Act
        await storage.saveTokens(
          accessToken: 'access-abc',
          refreshToken: 'refresh-xyz',
        );

        // Assert
        expect(await storage.getAccessToken(), equals('access-abc'));
        expect(await storage.getRefreshToken(), equals('refresh-xyz'));
      });

      test('should make hasTokens return true after saving', () async {
        // Act
        await storage.saveTokens(
          accessToken: 'access-abc',
          refreshToken: 'refresh-xyz',
        );

        // Assert
        expect(await storage.hasTokens(), isTrue);
      });

      test('should overwrite previously stored tokens', () async {
        // Arrange
        await storage.saveTokens(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
        );

        // Act
        await storage.saveTokens(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );

        // Assert
        expect(await storage.getAccessToken(), equals('new-access'));
        expect(await storage.getRefreshToken(), equals('new-refresh'));
      });
    });

    group('saveRefreshToken()', () {
      test('should update only the refresh token', () async {
        // Arrange
        await storage.saveTokens(
          accessToken: 'access-abc',
          refreshToken: 'old-refresh',
        );

        // Act
        await storage.saveRefreshToken('new-refresh');

        // Assert
        expect(await storage.getRefreshToken(), equals('new-refresh'));
        expect(await storage.getAccessToken(), equals('access-abc'));
      });
    });

    group('clearTokens()', () {
      test('should remove both tokens', () async {
        // Arrange
        await storage.saveTokens(
          accessToken: 'access-abc',
          refreshToken: 'refresh-xyz',
        );

        // Act
        await storage.clearTokens();

        // Assert
        expect(await storage.getAccessToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
      });

      test('should make hasTokens return false after clearing', () async {
        // Arrange
        await storage.saveTokens(
          accessToken: 'access-abc',
          refreshToken: 'refresh-xyz',
        );

        // Act
        await storage.clearTokens();

        // Assert
        expect(await storage.hasTokens(), isFalse);
      });
    });

    group('seedTokens() helper', () {
      test(
        'should pre-populate both tokens without calling saveTokens',
        () async {
          // Act
          storage.seedTokens(
            accessToken: 'seeded-access',
            refreshToken: 'seeded-refresh',
          );

          // Assert
          expect(await storage.getAccessToken(), equals('seeded-access'));
          expect(await storage.getRefreshToken(), equals('seeded-refresh'));
        },
      );

      test(
        'should expose seeded tokens via storedAccessToken/storedRefreshToken',
        () {
          // Act
          storage.seedTokens(accessToken: 'acc', refreshToken: 'ref');

          // Assert
          expect(storage.storedAccessToken, equals('acc'));
          expect(storage.storedRefreshToken, equals('ref'));
        },
      );
    });

    group('hasTokens()', () {
      test('should return false when only access token is present', () async {
        // Arrange
        await storage.saveRefreshToken('ref');
        // access token is still null

        // Assert
        expect(await storage.hasTokens(), isFalse);
      });

      test('should return false when only refresh token is present', () async {
        // Arrange — seed only the access token
        storage.seedTokens(accessToken: 'acc', refreshToken: 'ref');
        await storage.clearTokens();
        await storage.saveRefreshToken('ref');
        // access token is null again

        // Assert
        expect(await storage.hasTokens(), isFalse);
      });
    });
  });
}
