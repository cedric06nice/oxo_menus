import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';
import 'package:oxo_menus/features/collaboration/domain/repositories/presence_repository.dart';

/// Bundles every presence-related call the menu editor view model needs into a
/// single use case so the VM has one dependency to mock instead of the bare
/// repository.
class MenuPresenceUseCase {
  MenuPresenceUseCase({required PresenceRepository repository})
    : _repository = repository;

  final PresenceRepository _repository;

  Future<Result<void, DomainError>> join(
    int menuId,
    String userId, {
    String? userName,
    String? userAvatar,
  }) => _repository.joinMenu(
    menuId,
    userId,
    userName: userName,
    userAvatar: userAvatar,
  );

  Future<Result<void, DomainError>> leave(int menuId, String userId) =>
      _repository.leaveMenu(menuId, userId);

  Future<Result<void, DomainError>> heartbeat(int menuId, String userId) =>
      _repository.heartbeat(menuId, userId);

  Future<Result<List<MenuPresence>, DomainError>> getActive(int menuId) =>
      _repository.getActiveUsers(menuId);

  Stream<List<MenuPresence>> watch(int menuId) =>
      _repository.watchActiveUsers(menuId);

  Future<void> cancel(int menuId) => _repository.unsubscribePresence(menuId);
}
