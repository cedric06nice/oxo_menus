import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/presence_mapper.dart';
import 'package:oxo_menus/data/models/presence_dto.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';

class PresenceRepositoryImpl implements PresenceRepository {
  final DirectusDataSource dataSource;

  const PresenceRepositoryImpl({required this.dataSource});

  @override
  Future<Result<void, DomainError>> joinMenu(int menuId, String userId) async {
    try {
      final dto = PresenceDto.newItem(
        userId: userId,
        menuId: menuId,
        lastSeen: DateTime.now().toUtc().toIso8601String(),
      );

      await dataSource.createItem<PresenceDto>(dto);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> leaveMenu(int menuId, String userId) async {
    try {
      final entries = await dataSource.getItems<PresenceDto>(
        filter: {
          'menu': {'_eq': menuId},
          'user': {'_eq': userId},
        },
        fields: ['id'],
      );

      for (final entry in entries) {
        final dto = PresenceDto(entry);
        final id = dto.id;
        if (id != null) {
          await dataSource.deleteItem<PresenceDto>(int.parse(id.toString()));
        }
      }

      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> heartbeat(int menuId, String userId) async {
    try {
      final entries = await dataSource.getItems<PresenceDto>(
        filter: {
          'menu': {'_eq': menuId},
          'user': {'_eq': userId},
        },
        fields: ['id'],
      );

      if (entries.isNotEmpty) {
        final dto = PresenceDto(entries.first);
        dto.setValue(
          DateTime.now().toUtc().toIso8601String(),
          forKey: 'last_seen',
        );
        await dataSource.updateItem<PresenceDto>(dto);
      }

      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<MenuPresence>, DomainError>> getActiveUsers(
    int menuId,
  ) async {
    try {
      final data = await dataSource.getItems<PresenceDto>(
        filter: {
          'menu': {'_eq': menuId},
        },
        fields: [
          'id',
          'user.id',
          'user.avatar',
          'menu',
          'last_seen',
          'user_name',
        ],
      );

      final presences = data
          .map((json) => PresenceDto(json))
          .map((dto) => PresenceMapper.toEntity(dto))
          .toList();

      return Success(presences);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
