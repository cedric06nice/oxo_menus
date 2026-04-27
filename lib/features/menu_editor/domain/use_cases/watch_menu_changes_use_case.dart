import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/features/collaboration/domain/repositories/menu_subscription_repository.dart';

/// Subscribe to widget-level change events for a menu.
///
/// Wraps [MenuSubscriptionRepository.subscribeToMenuChanges] so the view model
/// has a single dependency it can swap in tests instead of reaching into the
/// repository. Returns the stream synchronously — the caller listens / cancels.
class WatchMenuChangesUseCase {
  WatchMenuChangesUseCase({required MenuSubscriptionRepository repository})
    : _repository = repository;

  final MenuSubscriptionRepository _repository;

  Stream<MenuChangeEvent> execute(int menuId) =>
      _repository.subscribeToMenuChanges(menuId);

  Future<void> cancel(int menuId) => _repository.unsubscribe(menuId);
}
