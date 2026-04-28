import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';

/// Adapter that fulfills [MenuListRouter] by forwarding to the legacy
/// `go_router` tree via a [LegacyNavigator].
///
/// Used while the menu list lives at the legacy `/menus` path inside
/// `app_router.dart`. The downstream menu editor and admin template editor
/// already live on the migrated `MainRouter` stack (Phases 11 & 12), so the
/// editor methods deep-link directly into the `/app/...` paths served there.
/// Once `MainRouter` mounts the menu list itself this adapter can be deleted.
class LegacyMenuListRouter implements MenuListRouter {
  LegacyMenuListRouter(this._navigator);

  final LegacyNavigator _navigator;

  @override
  void goToMenuEditor(int menuId) => _navigator.go('/app/menus/$menuId/edit');

  @override
  void goToAdminTemplateEditor(int menuId) =>
      _navigator.go('/app/admin/templates/$menuId/edit');

  @override
  void goBack() => _navigator.go(AppRoutes.home);
}
