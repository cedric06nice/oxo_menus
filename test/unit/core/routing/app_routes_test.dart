import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('static route constants match expected paths', () {
      expect(AppRoutes.splash, '/splash');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.menus, '/menus');
      expect(AppRoutes.adminSizes, '/admin/sizes');
      expect(AppRoutes.adminTemplates, '/admin/templates');
      expect(AppRoutes.adminTemplateCreate, '/admin/templates/create');
      expect(AppRoutes.forgotPassword, '/forgot-password');
      expect(AppRoutes.resetPassword, '/reset-password');
    });

    test('menuEditor returns correct path', () {
      expect(AppRoutes.menuEditor(1), '/menus/1');
      expect(AppRoutes.menuEditor(42), '/menus/42');
    });

    test('menuPdf returns correct path', () {
      expect(AppRoutes.menuPdf(1), '/menus/pdf/1');
      expect(AppRoutes.menuPdf(99), '/menus/pdf/99');
    });

    test('adminTemplateEditor returns correct path', () {
      expect(AppRoutes.adminTemplateEditor(1), '/admin/templates/1');
      expect(AppRoutes.adminTemplateEditor(55), '/admin/templates/55');
    });
  });
}
