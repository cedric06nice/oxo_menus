import 'dart:async';

/// Gateway that owns the admin "view as user" debug toggle.
///
/// Session-only state shared by the legacy Riverpod `adminViewAsUserProvider`
/// and the migrated Settings view model so both worlds stay in sync. Lives on
/// `AppContainer` for the app's lifetime; subscribers read [currentValue] for
/// the value at subscription time and listen to [valueStream] for subsequent
/// transitions.
class AdminViewAsUserGateway {
  AdminViewAsUserGateway({bool initialValue = false}) : _value = initialValue;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _value;
  bool _disposed = false;

  /// The most recent value seen by the gateway.
  bool get currentValue => _value;

  /// Broadcast stream of value transitions.
  Stream<bool> get valueStream => _controller.stream;

  bool get isDisposed => _disposed;

  /// Replace the stored value. No-op when [next] equals the current value or
  /// the gateway has been disposed.
  void set(bool next) {
    if (_disposed || _value == next) {
      return;
    }
    _value = next;
    _controller.add(next);
  }

  /// Flip the stored value. Convenience wrapper around [set].
  void toggle() => set(!_value);

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    unawaited(_controller.close());
  }
}
