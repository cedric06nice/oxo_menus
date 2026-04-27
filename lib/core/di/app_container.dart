import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';

/// Application-wide dependency container.
///
/// Holds the singletons that outlive any single screen — gateways, registries,
/// and long-lived services. Constructed once in `main.dart` before `runApp`,
/// passed into `MainRouter`, and used by each `RoutePage.buildScreen()` to
/// wire use cases → view models → screens.
///
/// During the migration, [AppContainer] is also exposed to the legacy Riverpod
/// providers so both worlds read from the same instances.
class AppContainer {
  AppContainer({required AuthGateway authGateway}) : _authGateway = authGateway;

  final AuthGateway _authGateway;
  bool _disposed = false;

  AuthGateway get authGateway => _authGateway;

  bool get isDisposed => _disposed;

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _authGateway.dispose();
  }
}

/// Riverpod entry point for the [AppContainer].
///
/// `main.dart` overrides this with the production container before `runApp`.
/// Tests that don't need a full container can leave the default
/// `UnimplementedError` in place.
final appContainerProvider = Provider<AppContainer>((ref) {
  throw UnimplementedError(
    'appContainerProvider must be overridden in main.dart with a real '
    'AppContainer instance.',
  );
});
