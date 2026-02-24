import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';

/// Concrete fake for testing the interface contract
class FakePresenceRepository implements PresenceRepository {
  final List<MenuPresence> _store = [];
  int _nextId = 1;

  @override
  Future<Result<void, DomainError>> joinMenu(int menuId, String userId) async {
    _store.add(
      MenuPresence(
        id: _nextId++,
        userId: userId,
        menuId: menuId,
        lastSeen: DateTime.now(),
      ),
    );
    return const Success(null);
  }

  @override
  Future<Result<void, DomainError>> leaveMenu(int menuId, String userId) async {
    _store.removeWhere((p) => p.menuId == menuId && p.userId == userId);
    return const Success(null);
  }

  @override
  Future<Result<void, DomainError>> heartbeat(int menuId, String userId) async {
    final idx = _store.indexWhere(
      (p) => p.menuId == menuId && p.userId == userId,
    );
    if (idx >= 0) {
      _store[idx] = _store[idx].copyWith(lastSeen: DateTime.now());
    }
    return const Success(null);
  }

  @override
  Future<Result<List<MenuPresence>, DomainError>> getActiveUsers(
    int menuId,
  ) async {
    return Success(_store.where((p) => p.menuId == menuId).toList());
  }
}

void main() {
  group('PresenceRepository', () {
    late FakePresenceRepository repository;

    setUp(() {
      repository = FakePresenceRepository();
    });

    test('joinMenu adds a presence entry', () async {
      final result = await repository.joinMenu(42, 'user-1');
      expect(result.isSuccess, isTrue);

      final users = await repository.getActiveUsers(42);
      expect(users.valueOrNull, hasLength(1));
      expect(users.valueOrNull?.first.userId, 'user-1');
    });

    test('leaveMenu removes the presence entry', () async {
      await repository.joinMenu(42, 'user-1');
      await repository.leaveMenu(42, 'user-1');

      final users = await repository.getActiveUsers(42);
      expect(users.valueOrNull, isEmpty);
    });

    test('heartbeat updates lastSeen', () async {
      await repository.joinMenu(42, 'user-1');
      final before = (await repository.getActiveUsers(
        42,
      )).valueOrNull!.first.lastSeen;

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repository.heartbeat(42, 'user-1');

      final after = (await repository.getActiveUsers(
        42,
      )).valueOrNull!.first.lastSeen;

      expect(after.isAfter(before), isTrue);
    });

    test('getActiveUsers returns only users for the given menu', () async {
      await repository.joinMenu(42, 'user-1');
      await repository.joinMenu(99, 'user-2');

      final users42 = await repository.getActiveUsers(42);
      expect(users42.valueOrNull, hasLength(1));
      expect(users42.valueOrNull?.first.userId, 'user-1');
    });
  });
}
