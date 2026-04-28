import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_router.dart';

/// Adapter that fulfills [SettingsRouter] by forwarding to the legacy
/// `go_router` tree via a [LegacyNavigator].
///
/// Used while the settings feature lives at the legacy `/settings` path inside
/// `app_router.dart`. Once `MainRouter` mounts the settings screen itself this
/// adapter can be deleted.
class LegacySettingsRouter implements SettingsRouter {
  LegacySettingsRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
