/// Centralized route path constants for the application.
///
/// Use these instead of hardcoded route strings to ensure
/// consistency and ease of refactoring.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const settings = '/settings';
  static const menus = '/menus';
  static const adminSizes = '/admin/sizes';
  static const adminTemplates = '/admin/templates';
  static const adminTemplateCreate = '/admin/templates/create';

  static String menuEditor(int menuId) => '/menus/$menuId';
  static String menuPdf(int menuId) => '/menus/pdf/$menuId';
  static String adminTemplateEditor(int menuId) => '/admin/templates/$menuId';
}
