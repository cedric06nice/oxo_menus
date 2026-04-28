import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';

/// `ChangeNotifier` view of [ConnectivityGateway].
///
/// Mirrors `gateway.statusStream` into the local `notifyListeners()` channel
/// so any widget can rebuild when the connection state flips. Replaces the
/// old `connectivityProvider` Riverpod stream provider in Phase 28.
class ConnectivityController extends ChangeNotifier {
  ConnectivityController({required ConnectivityGateway gateway})
    : _gateway = gateway,
      _status = gateway.currentStatus {
    _subscription = _gateway.statusStream.listen(_onStatus);
  }

  final ConnectivityGateway _gateway;
  ConnectivityStatus _status;
  StreamSubscription<ConnectivityStatus>? _subscription;
  bool _disposed = false;

  ConnectivityStatus get status => _status;

  bool get isOffline => _status == ConnectivityStatus.offline;

  /// Force a one-shot probe through the gateway. The result is delivered via
  /// the gateway's stream and reflected back into [status].
  Future<void> recheck() => _gateway.recheck();

  void _onStatus(ConnectivityStatus next) {
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
