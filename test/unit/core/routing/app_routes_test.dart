import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';

void main() {
  group('AppRoutes', () {
    group('static constants', () {
      test('should have splash path equal to /splash', () {
        expect(AppRoutes.splash, '/splash');
      });

      test('should have login path equal to /login', () {
        expect(AppRoutes.login, '/login');
      });

      test('should have home path equal to /home', () {
        expect(AppRoutes.home, '/home');
      });

      test('should have settings path equal to /settings', () {
        expect(AppRoutes.settings, '/settings');
      });

      test('should have menus path equal to /menus', () {
        expect(AppRoutes.menus, '/menus');
      });

      test('should have adminSizes path equal to /admin/sizes', () {
        expect(AppRoutes.adminSizes, '/admin/sizes');
      });

      test('should have adminTemplates path equal to /admin/templates', () {
        expect(AppRoutes.adminTemplates, '/admin/templates');
      });

      test('should have adminTemplateCreate path equal to /admin/templates/create', () {
        expect(AppRoutes.adminTemplateCreate, '/admin/templates/create');
      });

      test('should have adminExportableMenus path equal to /admin/exportable_menus', () {
        expect(AppRoutes.adminExportableMenus, '/admin/exportable_menus');
      });

      test('should have forgotPassword path equal to /forgot-password', () {
        expect(AppRoutes.forgotPassword, '/forgot-password');
      });

      test('should have resetPassword path equal to /reset-password', () {
        expect(AppRoutes.resetPassword, '/reset-password');
      });
    });

    group('uniqueness — no two constants share the same path', () {
      test('should have all static route constants be distinct', () {
        final paths = [
          AppRoutes.splash,
          AppRoutes.login,
          AppRoutes.home,
          AppRoutes.settings,
          AppRoutes.menus,
          AppRoutes.adminSizes,
          AppRoutes.adminTemplates,
          AppRoutes.adminTemplateCreate,
          AppRoutes.adminExportableMenus,
          AppRoutes.forgotPassword,
          AppRoutes.resetPassword,
        ];

        expect(paths.toSet().length, equals(paths.length));
      });
    });

    group('menuEditor', () {
      test('should return /menus/1 for id 1', () {
        expect(AppRoutes.menuEditor(1), '/menus/1');
      });

      test('should return /menus/42 for id 42', () {
        expect(AppRoutes.menuEditor(42), '/menus/42');
      });

      test('should return /menus/0 for id 0 (boundary value)', () {
        expect(AppRoutes.menuEditor(0), '/menus/0');
      });

      test('should return correct path for a large id', () {
        expect(AppRoutes.menuEditor(999999), '/menus/999999');
      });
    });

    group('menuPdf', () {
      test('should return /menus/pdf/1 for id 1', () {
        expect(AppRoutes.menuPdf(1), '/menus/pdf/1');
      });

      test('should return /menus/pdf/99 for id 99', () {
        expect(AppRoutes.menuPdf(99), '/menus/pdf/99');
      });

      test('should return /menus/pdf/0 for id 0 (boundary value)', () {
        expect(AppRoutes.menuPdf(0), '/menus/pdf/0');
      });

      test('should not collide with menuEditor path for the same id', () {
        expect(AppRoutes.menuPdf(5), isNot(equals(AppRoutes.menuEditor(5))));
      });
    });

    group('adminTemplateEditor', () {
      test('should return /admin/templates/1 for id 1', () {
        expect(AppRoutes.adminTemplateEditor(1), '/admin/templates/1');
      });

      test('should return /admin/templates/55 for id 55', () {
        expect(AppRoutes.adminTemplateEditor(55), '/admin/templates/55');
      });

      test('should return /admin/templates/0 for id 0 (boundary value)', () {
        expect(AppRoutes.adminTemplateEditor(0), '/admin/templates/0');
      });

      test('should not collide with adminTemplateCreate constant for any id', () {
        // adminTemplateCreate = '/admin/templates/create' (non-numeric)
        // adminTemplateEditor(N) = '/admin/templates/N' — only collides if N spells "create"
        // which is impossible for an int — this ensures the int path is unambiguous.
        final editorPath = AppRoutes.adminTemplateEditor(1);
        expect(editorPath, isNot(equals(AppRoutes.adminTemplateCreate)));
      });
    });
  });
}
