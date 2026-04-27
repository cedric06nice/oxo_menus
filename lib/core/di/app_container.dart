import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';

/// Application-wide dependency container.
///
/// Holds the singletons that outlive any single screen — gateways, the
/// Directus data source, and long-lived services. Constructed once in
/// `main.dart` before `runApp`, passed into `MainRouter`, and used by each
/// `RoutePage.buildScreen()` to wire use cases → view models → screens.
///
/// During the migration, [AppContainer] is also exposed to the legacy
/// Riverpod providers so both worlds read from the same instances.
class AppContainer {
  AppContainer({
    required AuthGateway authGateway,
    required ConnectivityGateway connectivityGateway,
    DirectusDataSource? directusDataSource,
  }) : _authGateway = authGateway,
       _connectivityGateway = connectivityGateway,
       _directusDataSource = directusDataSource;

  final AuthGateway _authGateway;
  final ConnectivityGateway _connectivityGateway;
  final DirectusDataSource? _directusDataSource;
  bool _disposed = false;

  AuthGateway get authGateway => _authGateway;

  ConnectivityGateway get connectivityGateway => _connectivityGateway;

  /// The shared Directus data source. Route pages use it to construct
  /// repositories on demand inside `buildScreen()`. Tests that exercise
  /// feature wiring inject a custom view-model builder and never reach this
  /// getter, which is why the data source is optional at construction.
  DirectusDataSource get directusDataSource {
    final ds = _directusDataSource;
    if (ds == null) {
      throw StateError(
        'AppContainer was constructed without a DirectusDataSource. Pass one '
        'in production, or use a feature-specific test builder that bypasses '
        'this dependency.',
      );
    }
    return ds;
  }

  bool get isDisposed => _disposed;

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _authGateway.dispose();
    _connectivityGateway.dispose();
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
