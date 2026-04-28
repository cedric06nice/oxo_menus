import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/shared/presentation/controllers/admin_view_as_user_controller.dart';
import 'package:oxo_menus/shared/presentation/controllers/app_lifecycle_controller.dart';
import 'package:oxo_menus/shared/presentation/controllers/auth_controller.dart';
import 'package:oxo_menus/shared/presentation/controllers/connectivity_controller.dart';

/// Read-only snapshot exposed by [AppScope] to its descendants.
///
/// Holds the singleton [AppContainer] plus the four `ChangeNotifier`s that
/// replace the old Riverpod providers. Widgets that need to rebuild on a
/// controller change wrap themselves in `ListenableBuilder(listenable: ...)`
/// or call `addListener` from their `State.initState`.
class AppScopeData {
  const AppScopeData({
    required this.container,
    required this.auth,
    required this.connectivity,
    required this.adminViewAsUser,
    required this.appLifecycle,
  });

  final AppContainer container;
  final AuthController auth;
  final ConnectivityController connectivity;
  final AdminViewAsUserController adminViewAsUser;
  final AppLifecycleController appLifecycle;
}

/// Root-level dependency-injection scope.
///
/// Wraps the app and exposes [AppContainer] plus four `ChangeNotifier`-backed
/// controllers via an `InheritedWidget`. Replaces `ProviderScope` from
/// `flutter_riverpod` in Phase 28.
///
/// Production wiring constructs an `AppScope` with only [container]; the
/// controllers are created on first build and disposed when the widget leaves
/// the tree. Tests can pass pre-built controllers in to swap behaviour
/// without standing up real gateways.
class AppScope extends StatefulWidget {
  const AppScope({
    super.key,
    required this.container,
    this.authController,
    this.connectivityController,
    this.adminViewAsUserController,
    this.appLifecycleController,
    required this.child,
  });

  final AppContainer container;
  final AuthController? authController;
  final ConnectivityController? connectivityController;
  final AdminViewAsUserController? adminViewAsUserController;
  final AppLifecycleController? appLifecycleController;
  final Widget child;

  /// Returns the nearest [AppScopeData] in the widget tree, registering this
  /// context as a dependent so it rebuilds when the snapshot changes
  /// (controllers themselves notify their own listeners separately).
  static AppScopeData of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_AppScopeInherited>();
    if (inherited == null) {
      throw FlutterError(
        'AppScope.of() called with a context that does not contain an '
        'AppScope. Wrap your app in `AppScope(...)` before reading from it.',
      );
    }
    return inherited.data;
  }

  /// Same as [of] but does not register a dependency. Use from callbacks that
  /// run outside of `build` (e.g. button handlers) where a rebuild is not
  /// desired.
  static AppScopeData read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<_AppScopeInherited>();
    if (element == null) {
      throw FlutterError(
        'AppScope.read() called with a context that does not contain an '
        'AppScope. Wrap your app in `AppScope(...)` before reading from it.',
      );
    }
    return (element.widget as _AppScopeInherited).data;
  }

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final AuthController _auth;
  late final ConnectivityController _connectivity;
  late final AdminViewAsUserController _adminViewAsUser;
  late final AppLifecycleController _appLifecycle;
  late final bool _ownsAuth;
  late final bool _ownsConnectivity;
  late final bool _ownsAdminViewAsUser;
  late final bool _ownsAppLifecycle;

  @override
  void initState() {
    super.initState();
    _ownsAuth = widget.authController == null;
    _auth =
        widget.authController ??
        AuthController(gateway: widget.container.authGateway);
    _ownsConnectivity = widget.connectivityController == null;
    _connectivity =
        widget.connectivityController ??
        ConnectivityController(gateway: widget.container.connectivityGateway);
    _ownsAdminViewAsUser = widget.adminViewAsUserController == null;
    _adminViewAsUser =
        widget.adminViewAsUserController ??
        AdminViewAsUserController(
          gateway: widget.container.adminViewAsUserGateway,
        );
    _ownsAppLifecycle = widget.appLifecycleController == null;
    _appLifecycle = widget.appLifecycleController ?? AppLifecycleController();
  }

  @override
  void dispose() {
    if (_ownsAuth) {
      _auth.dispose();
    }
    if (_ownsConnectivity) {
      _connectivity.dispose();
    }
    if (_ownsAdminViewAsUser) {
      _adminViewAsUser.dispose();
    }
    if (_ownsAppLifecycle) {
      _appLifecycle.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppScopeInherited(
      data: AppScopeData(
        container: widget.container,
        auth: _auth,
        connectivity: _connectivity,
        adminViewAsUser: _adminViewAsUser,
        appLifecycle: _appLifecycle,
      ),
      child: widget.child,
    );
  }
}

class _AppScopeInherited extends InheritedWidget {
  const _AppScopeInherited({required this.data, required super.child});

  final AppScopeData data;

  @override
  bool updateShouldNotify(_AppScopeInherited oldWidget) =>
      data.container != oldWidget.data.container ||
      data.auth != oldWidget.data.auth ||
      data.connectivity != oldWidget.data.connectivity ||
      data.adminViewAsUser != oldWidget.data.adminViewAsUser ||
      data.appLifecycle != oldWidget.data.appLifecycle;
}
