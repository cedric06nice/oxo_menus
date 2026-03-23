import 'dart:async';

import 'package:directus_api_manager/directus_api_manager.dart';
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

  final Map<int, String> _activeSubscriptions = {};
  final Map<int, StreamController<List<MenuPresence>>> _controllers = {};

  PresenceRepositoryImpl({required this.dataSource});

  @override
  Future<Result<void, DomainError>> joinMenu(
    int menuId,
    String userId, {
    String? userName,
    String? userAvatar,
  }) async {
    try {
      // Clean up ALL existing entries for this user (user can only be on one menu)
      final existing = await dataSource.getItems<PresenceDto>(
        filter: {
          'user': {'_eq': userId},
        },
        fields: ['id'],
      );
      for (final entry in existing) {
        final dto = PresenceDto(entry);
        final id = dto.id;
        if (id != null) {
          await dataSource.deleteItem<PresenceDto>(int.parse(id.toString()));
        }
      }

      final dto = PresenceDto.newItem(
        userId: userId,
        menuId: menuId,
        lastSeen: DateTime.now().toUtc().toIso8601String(),
        userName: userName,
        userAvatar: userAvatar,
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
        fields: ['id', 'user', 'user_name', 'user_avatar', 'menu', 'last_seen'],
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

  Future<void> _refreshAndEmit(int menuId) async {
    final controller = _controllers[menuId];
    if (controller == null || controller.isClosed) return;

    final result = await getActiveUsers(menuId);
    if (result.isSuccess) {
      controller.add(result.valueOrNull ?? []);
    }
  }

  @override
  Stream<List<MenuPresence>> watchActiveUsers(int menuId) {
    final controller = StreamController<List<MenuPresence>>.broadcast();
    final uid = 'menu_presence_$menuId';

    _activeSubscriptions[menuId] = uid;
    _controllers[menuId] = controller;

    final subscription = DirectusWebSocketSubscription<PresenceDto>(
      uid: uid,
      filter: PropertyFilter(
        field: 'menu',
        operator: FilterOperator.equals,
        value: menuId,
      ),
      onCreate: (data) {
        _refreshAndEmit(menuId);
        return null;
      },
      onUpdate: (data) {
        _refreshAndEmit(menuId);
        return null;
      },
      onDelete: (data) {
        _refreshAndEmit(menuId);
        return null;
      },
    );

    dataSource.startSubscription(subscription);

    controller.onCancel = () {
      _activeSubscriptions.remove(menuId);
      _controllers.remove(menuId);
    };

    return controller.stream;
  }

  @override
  Future<void> unsubscribePresence(int menuId) async {
    final uid = _activeSubscriptions.remove(menuId);
    final controller = _controllers.remove(menuId);
    await controller?.close();
    if (uid != null) {
      try {
        await dataSource.stopSubscription(uid);
      } on StateError catch (_) {
        // WebSocket sink already closed — safe to ignore
      }
    }
  }
}
