import 'dart:async';

import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/repositories/connectivity_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

sealed class ConnectivityCall {
  const ConnectivityCall();
}

final class WatchConnectivityCall extends ConnectivityCall {
  const WatchConnectivityCall();
}

final class CheckConnectivityCall extends ConnectivityCall {
  const CheckConnectivityCall();
}

// ---------------------------------------------------------------------------
// FakeConnectivityRepository
// ---------------------------------------------------------------------------

/// Manual fake for [ConnectivityRepository].
///
/// Every call is recorded in [calls] as a typed [ConnectivityCall].
///
/// ## Stream
/// [watchConnectivity] returns the stream exposed by [statusController].
/// Drive status changes in tests via `statusController.add(...)`.
/// The controller is broadcast so multiple listeners are supported.
///
/// ## checkConnectivity
/// Configure the return value via [whenCheckConnectivity].
/// Unconfigured calls throw [StateError] immediately.
class FakeConnectivityRepository implements ConnectivityRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<ConnectivityCall> calls = [];

  // -------------------------------------------------------------------------
  // Stream controller — test code drives connectivity events
  // -------------------------------------------------------------------------

  /// Broadcast [StreamController] whose stream is returned by
  /// [watchConnectivity].  Tests add events via [statusController.add].
  final StreamController<ConnectivityStatus> statusController =
      StreamController<ConnectivityStatus>.broadcast();

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  ConnectivityStatus? _checkConnectivityResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenCheckConnectivity(ConnectivityStatus response) {
    _checkConnectivityResponse = response;
  }

  // -------------------------------------------------------------------------
  // ConnectivityRepository implementation
  // -------------------------------------------------------------------------

  @override
  Stream<ConnectivityStatus> watchConnectivity() {
    calls.add(const WatchConnectivityCall());
    return statusController.stream;
  }

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    calls.add(const CheckConnectivityCall());
    if (_checkConnectivityResponse != null) {
      return _checkConnectivityResponse!;
    }
    throw StateError(
      'FakeConnectivityRepository: no response configured for '
      'checkConnectivity()',
    );
  }

  // -------------------------------------------------------------------------
  // Disposal helper
  // -------------------------------------------------------------------------

  /// Close the underlying [statusController].  Call in [tearDown] to avoid
  /// stream leaks across tests.
  Future<void> dispose() => statusController.close();

  // -------------------------------------------------------------------------
  // Convenience call-count helpers
  // -------------------------------------------------------------------------

  List<WatchConnectivityCall> get watchCalls =>
      calls.whereType<WatchConnectivityCall>().toList();

  List<CheckConnectivityCall> get checkCalls =>
      calls.whereType<CheckConnectivityCall>().toList();
}
