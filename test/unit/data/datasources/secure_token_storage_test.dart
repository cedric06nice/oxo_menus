import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/data/datasources/secure_token_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late SecureTokenStorage tokenStorage;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    tokenStorage = SecureTokenStorage(storage: mockStorage);
  });

  group('SecureTokenStorage', () {
    group('saveRefreshToken', () {
      test(
        'should save only the refresh token without affecting access token',
        () async {
          // Arrange
          when(
            () => mockStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).thenAnswer((_) async {});

          // Act
          await tokenStorage.saveRefreshToken('new-refresh-token');

          // Assert — only refresh_token key is written
          verify(
            () => mockStorage.write(
              key: 'refresh_token',
              value: 'new-refresh-token',
            ),
          ).called(1);
          verifyNever(
            () => mockStorage.write(
              key: 'access_token',
              value: any(named: 'value'),
            ),
          );
        },
      );
    });
  });
}
