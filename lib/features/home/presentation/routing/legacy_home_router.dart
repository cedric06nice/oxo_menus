import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_router.dart';

/// Adapter that fulfills [HomeRouter] by forwarding quick-action taps to the
/// `go_router` tree via a [LegacyNavigator].
///
/// Wired by `_LegacyHomeRouteHost` in `app_router.dart` for the `/home`
/// GoRoute.
class LegacyHomeRouter implements HomeRouter {
  LegacyHomeRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goToMenus() => _navigator.go(AppRoutes.menus);

  @override
  void goToSettings() => _navigator.go(AppRoutes.settings);

  @override
  void goToAdminTemplates() => _navigator.go(AppRoutes.adminTemplates);

  @override
  void goToAdminTemplateCreate() =>
      _navigator.go(AppRoutes.adminTemplateCreate);

  @override
  void goToAdminExportableMenus() =>
      _navigator.go(AppRoutes.adminExportableMenus);
}
