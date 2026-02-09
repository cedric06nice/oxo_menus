import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/auth_repository_impl.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

// Mock exception classes
class MockDirectusException implements Exception {
  final String code;
  final String message;

  MockDirectusException({required this.code, required this.message});

  @override
  String toString() => 'DirectusException: $code - $message';
}

void main() {
  late AuthRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = AuthRepositoryImpl(dataSource: mockDataSource);
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      const email = 'test@example.com';
      const password = 'password123';

      final loginResponseJson = {
        'access_token': 'token123',
        'refresh_token': 'refresh123',
        'expires': 900000,
        'user': {
          'id': 'user-1',
          'email': email,
          'first_name': 'Test',
          'last_name': 'User',
          'role': 'admin',
        },
      };

      test('should login successfully and return user', () async {
        // Arrange
        when(
          () => mockDataSource.login(email: email, password: password),
        ).thenAnswer((_) async => loginResponseJson);

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result.isSuccess, true);
        final user = result.valueOrNull!;
        expect(user.id, 'user-1');
        expect(user.email, email);
        expect(user.firstName, 'Test');
        expect(user.lastName, 'User');
        expect(user.role, UserRole.admin);

        verify(
          () => mockDataSource.login(email: email, password: password),
        ).called(1);
      });

      test(
        'should return InvalidCredentialsError when credentials are invalid',
        () async {
          // Arrange
          when(
            () => mockDataSource.login(email: email, password: password),
          ).thenThrow(
            MockDirectusException(
              code: 'INVALID_CREDENTIALS',
              message: 'Invalid email or password',
            ),
          );

          // Act
          final result = await repository.login(email, password);

          // Assert
          expect(result.isFailure, true);
          expect(result.errorOrNull, isA<InvalidCredentialsError>());
        },
      );

      test('should return NetworkError when network fails', () async {
        // Arrange
        when(
          () => mockDataSource.login(email: email, password: password),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<UnknownError>());
      });
    });

    group('logout', () {
      test('should logout successfully', () async {
        // Arrange
        when(() => mockDataSource.logout()).thenAnswer((_) async => {});

        // Act
        final result = await repository.logout();

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.logout()).called(1);
      });

      test('should return error when logout fails', () async {
        // Arrange
        when(
          () => mockDataSource.logout(),
        ).thenThrow(Exception('Logout failed'));

        // Act
        final result = await repository.logout();

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<UnknownError>());
      });
    });

    group('getCurrentUser', () {
      final userJson = {
        'id': 'user-1',
        'email': 'test@example.com',
        'first_name': 'Test',
        'last_name': 'User',
        'role': 'user',
        'avatar': 'avatar-123',
      };

      test('should return current user when authenticated', () async {
        // Arrange
        when(
          () => mockDataSource.getCurrentUser(),
        ).thenAnswer((_) async => userJson);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isSuccess, true);
        final user = result.valueOrNull!;
        expect(user.id, 'user-1');
        expect(user.email, 'test@example.com');
        expect(user.firstName, 'Test');
        expect(user.lastName, 'User');
        expect(user.role, UserRole.user);
        expect(user.avatar, 'avatar-123');

        verify(() => mockDataSource.getCurrentUser()).called(1);
      });

      test('should return UnauthorizedError when not authenticated', () async {
        // Arrange
        when(() => mockDataSource.getCurrentUser()).thenThrow(
          MockDirectusException(
            code: 'FORBIDDEN',
            message: 'Not authenticated',
          ),
        );

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<UnauthorizedError>());
      });

      test('should return TokenExpiredError when token has expired', () async {
        // Arrange
        when(() => mockDataSource.getCurrentUser()).thenThrow(
          MockDirectusException(
            code: 'TOKEN_EXPIRED',
            message: 'Token has expired',
          ),
        );

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<TokenExpiredError>());
      });
    });

    group('refreshSession', () {
      test(
        'should call dataSource.refreshSession and return Success',
        () async {
          // Arrange
          when(() => mockDataSource.refreshSession()).thenAnswer((_) async {});

          // Act
          final result = await repository.refreshSession();

          // Assert
          expect(result.isSuccess, true);
          verify(() => mockDataSource.refreshSession()).called(1);
        },
      );

      test(
        'should return TokenExpiredError when refresh token is invalid',
        () async {
          // Arrange
          when(() => mockDataSource.refreshSession()).thenThrow(
            MockDirectusException(
              code: 'TOKEN_EXPIRED',
              message: 'Token has expired',
            ),
          );

          // Act
          final result = await repository.refreshSession();

          // Assert
          expect(result.isFailure, true);
          expect(result.errorOrNull, isA<TokenExpiredError>());
        },
      );

      test('should return UnknownError when network fails', () async {
        // Arrange
        when(
          () => mockDataSource.refreshSession(),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await repository.refreshSession();

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<UnknownError>());
      });
    });
  });
}
