import 'dart:async';

import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';

/// Gateway that owns connectivity state and exposes it as a stream.
///
/// One instance lives on `AppContainer` for the app's lifetime. ViewModels that
/// need to react to connectivity transitions (e.g. retry on offline → online)
/// subscribe to [statusStream] and read [currentStatus] for the value at
/// subscription time.
///
/// Wraps [ConnectivityRepository] so the rest of the application depends on a
/// domain-shaped abstraction rather than `connectivity_plus`.
class ConnectivityGateway {
  ConnectivityGateway({required ConnectivityRepository repository})
    : _repository = repository {
    _subscription = _repository.watchConnectivity().listen(_emit);
    unawaited(
      _repository.checkConnectivity().then((status) {
        // Initial probe — stored as the snapshot only, not emitted on
        // [statusStream]. Subscribers read [currentStatus] for the boot value
        // and listen to the stream for subsequent transitions.
        if (!_disposed) {
          _status = status;
        }
      }),
    );
  }

  final ConnectivityRepository _repository;
  final StreamController<ConnectivityStatus> _controller =
      StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<ConnectivityStatus>? _subscription;

  ConnectivityStatus _status = ConnectivityStatus.online;
  bool _disposed = false;

  /// The most recent status seen by the gateway. Optimistic default
  /// ([ConnectivityStatus.online]) until the first event arrives — callers
  /// that need certainty should listen to [statusStream].
  ConnectivityStatus get currentStatus => _status;

  /// Broadcast stream of status transitions. Subscribers should read
  /// [currentStatus] for the value at subscription time.
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  bool get isDisposed => _disposed;

  void _emit(ConnectivityStatus next) {
    if (_disposed) {
      return;
    }
    _status = next;
    _controller.add(next);
  }

  /// Trigger a one-shot probe through the underlying repository and emit the
  /// result on [statusStream]. Used by retry buttons that want to force-check
  /// connectivity rather than wait for the next ambient transition.
  Future<void> recheck() async {
    if (_disposed) {
      return;
    }
    final next = await _repository.checkConnectivity();
    _emit(next);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_controller.close());
  }
}
