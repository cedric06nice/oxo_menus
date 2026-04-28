import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// `ChangeNotifier` view of [AuthGateway].
///
/// Mirrors `gateway.statusStream` into the local `notifyListeners()` channel
/// so any `StatefulWidget` (or `ListenableBuilder`) can rebuild when the
/// authentication status changes. Replaces the old `AuthNotifier` Riverpod
/// notifier in Phase 28.
class AuthController extends ChangeNotifier {
  AuthController({required AuthGateway gateway, bool autoRestore = true})
    : _gateway = gateway,
      _status = gateway.status {
    _subscription = _gateway.statusStream.listen(_onStatus);
    if (autoRestore) {
      Future<void>.microtask(() async {
        if (_disposed) {
          return;
        }
        await _gateway.tryRestoreSession();
      });
    }
  }

  final AuthGateway _gateway;
  AuthStatus _status;
  StreamSubscription<AuthStatus>? _subscription;
  bool _disposed = false;

  AuthStatus get status => _status;

  bool get isAuthenticated => _status is AuthStatusAuthenticated;

  User? get currentUser => switch (_status) {
    AuthStatusAuthenticated(:final user) => user,
    _ => null,
  };

  /// Login with [email] and [password]. Status updates flow back through
  /// the gateway's stream listener.
  Future<void> login(String email, String password) async {
    await _gateway.login(email, password);
  }

  /// Logout the current user.
  Future<void> logout() async {
    await _gateway.logout();
  }

  /// Re-check the current user with the backend.
  Future<void> refresh() async {
    await _gateway.refresh();
  }

  void _onStatus(AuthStatus next) {
    if (_disposed || _status == next) {
      return;
    }
    _status = next;
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
