import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';

/// `ChangeNotifier` view of [AdminViewAsUserGateway].
///
/// Bridges the session-only "view as user" toggle into the widget tree so the
/// AppShell, the Settings screen, and the auth redirect all see the same
/// value. Replaces the old `adminViewAsUserProvider` Riverpod notifier in
/// Phase 28.
class AdminViewAsUserController extends ChangeNotifier {
  AdminViewAsUserController({required AdminViewAsUserGateway gateway})
    : _gateway = gateway,
      _value = gateway.currentValue {
    _subscription = _gateway.valueStream.listen(_onValue);
  }

  final AdminViewAsUserGateway _gateway;
  bool _value;
  StreamSubscription<bool>? _subscription;
  bool _disposed = false;

  bool get value => _value;

  void set(bool next) => _gateway.set(next);

  void toggle() => _gateway.toggle();

  void _onValue(bool next) {
    if (_disposed || _value == next) {
      return;
    }
    _value = next;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
