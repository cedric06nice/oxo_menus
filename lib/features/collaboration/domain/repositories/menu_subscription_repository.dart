import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';

/// Repository interface for real-time menu change subscriptions via WebSocket.
abstract class MenuSubscriptionRepository {
  /// Subscribe to widget changes for a specific menu.
  ///
  /// Returns a stream of [MenuChangeEvent] that emits whenever a widget
  /// in the given menu is created, updated, or deleted by another user.
  Stream<MenuChangeEvent> subscribeToMenuChanges(int menuId);

  /// Unsubscribe from changes for a specific menu.
  Future<void> unsubscribe(int menuId);
}
