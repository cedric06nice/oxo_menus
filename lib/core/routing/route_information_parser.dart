import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/routing/route_config.dart';

/// Parses platform [RouteInformation] into a [RouteConfig] (and back).
///
/// As features migrate, each path under `/app/*` gains a matching variant
/// here. URIs that do not yet match a migrated feature are returned as
/// [UnknownRouteConfig] so the legacy go_router can keep serving them.
class AppRouteInformationParser extends RouteInformationParser<RouteConfig> {
  AppRouteInformationParser();

  static const String _loginPath = '/app/login';
  static const String _forgotPasswordPath = '/app/forgot-password';
  static const String _homePath = '/app/home';
  static const String _menuListPath = '/app/menus';
  static const String _settingsPath = '/app/settings';
  static const String _adminTemplatesPath = '/app/admin/templates';
  static const String _adminTemplateCreatePath = '/app/admin/templates/create';
  static const String _adminSizesPath = '/app/admin/sizes';
  static const String _adminExportableMenusPath = '/app/admin/exportable-menus';

  @override
  Future<RouteConfig> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    if (uri.path == _loginPath) {
      return const LoginRouteConfig();
    }
    if (uri.path == _forgotPasswordPath) {
      return const ForgotPasswordRouteConfig();
    }
    if (uri.path == _homePath) {
      return const HomeRouteConfig();
    }
    if (uri.path == _menuListPath) {
      return const MenuListRouteConfig();
    }
    if (uri.path == _settingsPath) {
      return const SettingsRouteConfig();
    }
    if (uri.path == _adminTemplateCreatePath) {
      return const AdminTemplateCreatorRouteConfig();
    }
    if (uri.path == _adminTemplatesPath) {
      return const AdminTemplatesRouteConfig();
    }
    if (uri.path == _adminSizesPath) {
      return const AdminSizesRouteConfig();
    }
    if (uri.path == _adminExportableMenusPath) {
      return const AdminExportableMenusRouteConfig();
    }
    final pdfPreview = _matchPdfPreviewPath(uri);
    if (pdfPreview != null) {
      return pdfPreview;
    }
    return UnknownRouteConfig(uri);
  }

  /// Matches `/app/menus/{menuId}/pdf` and returns the corresponding config,
  /// or `null` when the path doesn't fit the shape (wrong segment count, root
  /// segment mismatch, or non-numeric id).
  static PdfPreviewRouteConfig? _matchPdfPreviewPath(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length != 4) {
      return null;
    }
    if (segments[0] != 'app' ||
        segments[1] != 'menus' ||
        segments[3] != 'pdf') {
      return null;
    }
    final menuId = int.tryParse(segments[2]);
    if (menuId == null) {
      return null;
    }
    return PdfPreviewRouteConfig(menuId);
  }

  @override
  RouteInformation? restoreRouteInformation(RouteConfig configuration) {
    return switch (configuration) {
      LoginRouteConfig() => RouteInformation(uri: Uri.parse(_loginPath)),
      ForgotPasswordRouteConfig() => RouteInformation(
        uri: Uri.parse(_forgotPasswordPath),
      ),
      HomeRouteConfig() => RouteInformation(uri: Uri.parse(_homePath)),
      MenuListRouteConfig() => RouteInformation(uri: Uri.parse(_menuListPath)),
      SettingsRouteConfig() => RouteInformation(uri: Uri.parse(_settingsPath)),
      AdminTemplatesRouteConfig() => RouteInformation(
        uri: Uri.parse(_adminTemplatesPath),
      ),
      AdminTemplateCreatorRouteConfig() => RouteInformation(
        uri: Uri.parse(_adminTemplateCreatePath),
      ),
      AdminSizesRouteConfig() => RouteInformation(
        uri: Uri.parse(_adminSizesPath),
      ),
      AdminExportableMenusRouteConfig() => RouteInformation(
        uri: Uri.parse(_adminExportableMenusPath),
      ),
      PdfPreviewRouteConfig(:final menuId) => RouteInformation(
        uri: Uri.parse('/app/menus/$menuId/pdf'),
      ),
      UnknownRouteConfig(:final uri) => RouteInformation(uri: uri),
    };
  }
}
