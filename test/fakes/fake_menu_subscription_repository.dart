import 'dart:async';

import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/features/collaboration/domain/repositories/menu_subscription_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

/// Sealed union of every recorded call on [FakeMenuSubscriptionRepository].
sealed class MenuSubscriptionCall {
  const MenuSubscriptionCall();
}

final class SubscribeToMenuChangesCall extends MenuSubscriptionCall {
  final int menuId;
  const SubscribeToMenuChangesCall({required this.menuId});
}

final class UnsubscribeCall extends MenuSubscriptionCall {
  final int menuId;
  const UnsubscribeCall({required this.menuId});
}

// ---------------------------------------------------------------------------
// FakeMenuSubscriptionRepository
// ---------------------------------------------------------------------------

/// A fully manual fake for [MenuSubscriptionRepository].
///
/// Per-menu [StreamController]s are managed internally so tests can drive
/// events to one menu without affecting others.
///
/// Usage:
/// ```dart
/// final fake = FakeMenuSubscriptionRepository();
/// final stream = fake.subscribeToMenuChanges(1);
/// fake.emitChange(1, WidgetChangedEvent(eventType: 'create', data: {}, ids: null));
/// ```
class FakeMenuSubscriptionRepository implements MenuSubscriptionRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<MenuSubscriptionCall> calls = [];

  // -------------------------------------------------------------------------
  // Internal stream controllers — one per menu id
  // -------------------------------------------------------------------------

  final Map<int, StreamController<MenuChangeEvent>> _controllers = {};

  // -------------------------------------------------------------------------
  // Driver helpers
  // -------------------------------------------------------------------------

  /// Pushes [event] to the stream for [menuId].
  ///
  /// Creates an implicit subscription controller if one does not already
  /// exist, so tests can emit before calling [subscribeToMenuChanges].
  void emitChange(int menuId, MenuChangeEvent event) {
    _controllerFor(menuId).add(event);
  }

  /// Closes the stream for [menuId], simulating a server disconnect.
  void closeStream(int menuId) {
    _controllerFor(menuId).close();
  }

  /// Adds an error to the stream for [menuId].
  void addError(int menuId, Object error) {
    _controllerFor(menuId).addError(error);
  }

  // -------------------------------------------------------------------------
  // Convenience call-count helpers
  // -------------------------------------------------------------------------

  /// All [SubscribeToMenuChangesCall] records.
  List<SubscribeToMenuChangesCall> get subscribeCalls =>
      calls.whereType<SubscribeToMenuChangesCall>().toList();

  /// All [UnsubscribeCall] records.
  List<UnsubscribeCall> get unsubscribeCalls =>
      calls.whereType<UnsubscribeCall>().toList();

  // -------------------------------------------------------------------------
  // MenuSubscriptionRepository implementation
  // -------------------------------------------------------------------------

  @override
  Stream<MenuChangeEvent> subscribeToMenuChanges(int menuId) {
    calls.add(SubscribeToMenuChangesCall(menuId: menuId));
    return _controllerFor(menuId).stream;
  }

  @override
  Future<void> unsubscribe(int menuId) async {
    calls.add(UnsubscribeCall(menuId: menuId));
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  StreamController<MenuChangeEvent> _controllerFor(int menuId) {
    if (!_controllers.containsKey(menuId)) {
      _controllers[menuId] = StreamController<MenuChangeEvent>.broadcast();
    }
    return _controllers[menuId]!;
  }

  /// Disposes all open stream controllers.  Call from [tearDown] in tests
  /// that care about resource clean-up.
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
