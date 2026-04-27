/// Sealed type describing every destination the `MainRouter` can render.
///
/// Each variant carries the data needed to construct the screen. New variants
/// are added per-phase as features migrate; until then [UnknownRouteConfig]
/// catches any URI handed to the router.
sealed class RouteConfig {
  const RouteConfig();
}

/// Login screen — the entry point for unauthenticated users.
final class LoginRouteConfig extends RouteConfig {
  const LoginRouteConfig();

  @override
  bool operator ==(Object other) => other is LoginRouteConfig;

  @override
  int get hashCode => (LoginRouteConfig).hashCode;

  @override
  String toString() => 'LoginRouteConfig()';
}

/// Forgot-password screen — reachable from the login screen and via deep
/// link.
final class ForgotPasswordRouteConfig extends RouteConfig {
  const ForgotPasswordRouteConfig();

  @override
  bool operator ==(Object other) => other is ForgotPasswordRouteConfig;

  @override
  int get hashCode => (ForgotPasswordRouteConfig).hashCode;

  @override
  String toString() => 'ForgotPasswordRouteConfig()';
}

/// Home screen — the post-login destination.
final class HomeRouteConfig extends RouteConfig {
  const HomeRouteConfig();

  @override
  bool operator ==(Object other) => other is HomeRouteConfig;

  @override
  int get hashCode => (HomeRouteConfig).hashCode;

  @override
  String toString() => 'HomeRouteConfig()';
}

/// Menu list — the main browsing screen reachable from Home.
final class MenuListRouteConfig extends RouteConfig {
  const MenuListRouteConfig();

  @override
  bool operator ==(Object other) => other is MenuListRouteConfig;

  @override
  int get hashCode => (MenuListRouteConfig).hashCode;

  @override
  String toString() => 'MenuListRouteConfig()';
}

/// Settings — user profile, preferences, logout. Reachable from Home.
final class SettingsRouteConfig extends RouteConfig {
  const SettingsRouteConfig();

  @override
  bool operator ==(Object other) => other is SettingsRouteConfig;

  @override
  int get hashCode => (SettingsRouteConfig).hashCode;

  @override
  String toString() => 'SettingsRouteConfig()';
}

/// Admin templates list — admin-only entry point for template management.
/// Reachable from Home via the "Manage Templates" quick-action.
final class AdminTemplatesRouteConfig extends RouteConfig {
  const AdminTemplatesRouteConfig();

  @override
  bool operator ==(Object other) => other is AdminTemplatesRouteConfig;

  @override
  int get hashCode => (AdminTemplatesRouteConfig).hashCode;

  @override
  String toString() => 'AdminTemplatesRouteConfig()';
}

/// Admin page sizes — admin-only CRUD on page size definitions. Reachable
/// from Settings, from the template-create flow, and (once migrated) from
/// the template-editor.
final class AdminSizesRouteConfig extends RouteConfig {
  const AdminSizesRouteConfig();

  @override
  bool operator ==(Object other) => other is AdminSizesRouteConfig;

  @override
  int get hashCode => (AdminSizesRouteConfig).hashCode;

  @override
  String toString() => 'AdminSizesRouteConfig()';
}

/// Admin template-create form — admin-only screen reached from the admin
/// templates list. After a successful create the user lands in the legacy
/// template editor (until that screen migrates).
final class AdminTemplateCreatorRouteConfig extends RouteConfig {
  const AdminTemplateCreatorRouteConfig();

  @override
  bool operator ==(Object other) => other is AdminTemplateCreatorRouteConfig;

  @override
  int get hashCode => (AdminTemplateCreatorRouteConfig).hashCode;

  @override
  String toString() => 'AdminTemplateCreatorRouteConfig()';
}

/// PDF preview — full-page preview of a generated PDF for a given menu.
/// Reachable from the menu editor and the admin template editor; deep-linkable
/// via `/app/menus/{menuId}/pdf` so users can bookmark a generated PDF.
final class PdfPreviewRouteConfig extends RouteConfig {
  const PdfPreviewRouteConfig(this.menuId);

  final int menuId;

  @override
  bool operator ==(Object other) =>
      other is PdfPreviewRouteConfig && other.menuId == menuId;

  @override
  int get hashCode => Object.hash((PdfPreviewRouteConfig).hashCode, menuId);

  @override
  String toString() => 'PdfPreviewRouteConfig($menuId)';
}

/// Fallback variant for URIs that do not yet match a migrated feature.
///
/// During the migration the legacy `go_router` handles all unknown paths;
/// `MainRouter` simply records the URI so it can be restored if the user
/// refreshes the page.
final class UnknownRouteConfig extends RouteConfig {
  const UnknownRouteConfig(this.uri);

  final Uri uri;

  @override
  bool operator ==(Object other) =>
      other is UnknownRouteConfig && other.uri == uri;

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() => 'UnknownRouteConfig($uri)';
}
