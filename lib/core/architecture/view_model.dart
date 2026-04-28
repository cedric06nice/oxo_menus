import 'package:flutter/foundation.dart';

/// Base class for all ViewModels.
///
/// A ViewModel owns a single immutable [state] of type `S`, exposes it to its
/// Screen, and notifies listeners when [emit] replaces it. ViewModels never
/// reach into adapters or gateways directly; they receive use cases via
/// constructor injection from the router.
abstract class ViewModel<S> extends ChangeNotifier {
  ViewModel(S initialState) : _state = initialState;

  S _state;
  bool _disposed = false;
  bool _initialised = false;

  /// The current immutable state.
  S get state => _state;

  /// Whether [dispose] has run.
  bool get isDisposed => _disposed;

  /// Replace the state and notify listeners. No-op when disposed or when the
  /// next state equals the current one.
  @protected
  void emit(S next) {
    if (_disposed) {
      return;
    }
    if (_state == next) {
      return;
    }
    _state = next;
    notifyListeners();
  }

  /// Called once by the router after construction. Override to perform initial
  /// loads. Subsequent calls are ignored.
  Future<void> initialise() async {
    if (_initialised || _disposed) {
      return;
    }
    _initialised = true;
    await onInit();
  }

  /// Override for first-load side effects. Default: no-op.
  @protected
  Future<void> onInit() async {}

  /// Override for cleanup that must run before [dispose] tears down listeners.
  /// Default: no-op.
  @protected
  void onDispose() {}

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    onDispose();
    super.dispose();
  }
}
