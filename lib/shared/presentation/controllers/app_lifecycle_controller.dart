import 'package:flutter/widgets.dart';

/// `ChangeNotifier` view of the framework's lifecycle observer.
///
/// Exposes [AppLifecycleState] and a convenience [isInForeground] flag so
/// widgets can rebuild on resume/pause without registering their own
/// `WidgetsBindingObserver`. Replaces the old `appLifecycleProvider`
/// Riverpod notifier in Phase 28.
class AppLifecycleController extends ChangeNotifier
    with WidgetsBindingObserver {
  AppLifecycleController() {
    WidgetsBinding.instance.addObserver(this);
  }

  AppLifecycleState _state = AppLifecycleState.resumed;
  bool _disposed = false;

  AppLifecycleState get state => _state;

  bool get isInForeground => _state == AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed || _state == state) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
