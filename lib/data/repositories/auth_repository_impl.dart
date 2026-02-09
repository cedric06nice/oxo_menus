import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/user_mapper.dart';
import 'package:oxo_menus/data/models/user_dto.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository using Directus as data source
class AuthRepositoryImpl implements AuthRepository {
  final DirectusDataSource dataSource;

  const AuthRepositoryImpl({required this.dataSource});

  @override
  Future<Result<User, DomainError>> login(String email, String password) async {
    try {
      final response = await dataSource.login(email: email, password: password);

      // Extract user data from login response
      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        return const Failure(
          UnknownError('Login response did not contain user data'),
        );
      }

      final dto = UserDto.fromJson(userData);
      final user = UserMapper.toEntity(dto);

      return Success(user);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> logout() async {
    try {
      await dataSource.logout();
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<User, DomainError>> getCurrentUser() async {
    try {
      final data = await dataSource.getCurrentUser();

      final dto = UserDto.fromJson(data);
      final user = UserMapper.toEntity(dto);

      return Success(user);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> refreshSession() async {
    try {
      await dataSource.refreshSession();
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async {
    try {
      final restored = await dataSource.tryRestoreSession();
      if (!restored) {
        return const Failure(TokenExpiredError('No valid session to restore'));
      }

      // Session restored, fetch the current user
      final data = await dataSource.getCurrentUser();
      final dto = UserDto.fromJson(data);
      final user = UserMapper.toEntity(dto);

      return Success(user);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
