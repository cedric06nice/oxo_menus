import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/built_in_widget_definitions.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/repositories/file_repository_impl.dart';

/// Application-wide dependency container.
///
/// Holds the singletons that outlive any single screen — gateways, the
/// Directus data source, and long-lived services. Constructed once in
/// `main.dart` before `runApp` and exposed via `AppScope`; each
/// `_*RouteHost` in `app_router.dart` reads it from `AppScope.of(context)`
/// and uses it to wire use cases → view models → screens.
class AppContainer {
  AppContainer({
    required AuthGateway authGateway,
    required ConnectivityGateway connectivityGateway,
    AppVersionGateway? appVersionGateway,
    AdminViewAsUserGateway? adminViewAsUserGateway,
    DirectusDataSource? directusDataSource,
    String? directusBaseUrl,
    String? directusAccessTokenOverride,
  }) : _authGateway = authGateway,
       _connectivityGateway = connectivityGateway,
       _appVersionGateway = appVersionGateway ?? PackageInfoAppVersionGateway(),
       _adminViewAsUserGateway =
           adminViewAsUserGateway ?? AdminViewAsUserGateway(),
       _directusDataSource = directusDataSource,
       _directusBaseUrl = directusBaseUrl,
       _directusAccessTokenOverride = directusAccessTokenOverride;

  final AuthGateway _authGateway;
  final ConnectivityGateway _connectivityGateway;
  final AppVersionGateway _appVersionGateway;
  final AdminViewAsUserGateway _adminViewAsUserGateway;
  final DirectusDataSource? _directusDataSource;
  final String? _directusBaseUrl;
  final String? _directusAccessTokenOverride;
  PresentableWidgetRegistry? _widgetRegistry;
  ImageGateway? _imageGateway;
  bool _disposed = false;

  AuthGateway get authGateway => _authGateway;

  ConnectivityGateway get connectivityGateway => _connectivityGateway;

  AppVersionGateway get appVersionGateway => _appVersionGateway;

  AdminViewAsUserGateway get adminViewAsUserGateway => _adminViewAsUserGateway;

  /// The Directus base URL the production data source was configured with.
  /// Optional — tests omit this and route hosts that need it fall back to
  /// an empty string.
  String? get directusBaseUrl => _directusBaseUrl;

  /// The current Directus access token, or `null` when no session has been
  /// restored or established yet. Production wiring delegates to
  /// [DirectusDataSource]; widget tests inject a token directly via the
  /// `directusAccessTokenOverride` constructor argument so they don't have to
  /// stand up a real data source.
  String? get directusAccessToken =>
      _directusAccessTokenOverride ?? _directusDataSource?.currentAccessToken;

  /// The shared Directus data source. Route hosts use it to construct
  /// repositories on demand inside their default view-model builders. Tests
  /// that exercise feature wiring inject a custom view-model builder and
  /// never reach this getter, which is why the data source is optional at
  /// construction.
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

  /// Lazily-built registry of all presentable widget definitions.
  /// First access constructs the registry from `allWidgetDefinitions`; later
  /// accesses return the same instance.
  PresentableWidgetRegistry get widgetRegistry =>
      _widgetRegistry ??= _buildWidgetRegistry();

  PresentableWidgetRegistry _buildWidgetRegistry() {
    final registry = PresentableWidgetRegistry();
    for (final definition in allWidgetDefinitions) {
      registry.register(definition);
    }
    return registry;
  }

  /// Lazily-built [ImageGateway] backed by [FileRepositoryImpl] over
  /// [directusDataSource]. Throws the same `StateError` as
  /// [directusDataSource] when the container was constructed without one.
  ImageGateway get imageGateway => _imageGateway ??= ImageGateway(
    repository: FileRepositoryImpl(directusDataSource),
  );

  bool get isDisposed => _disposed;

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _authGateway.dispose();
    _connectivityGateway.dispose();
    _adminViewAsUserGateway.dispose();
  }
}
