import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/route_config.dart';
import 'package:oxo_menus/core/routing/route_information_parser.dart';

void main() {
  group('RouteConfig', () {
    test('UnknownRouteConfig holds the original URI', () {
      final uri = Uri.parse('/app/something/123?x=1');
      final config = UnknownRouteConfig(uri);

      expect(config.uri, uri);
    });

    test('UnknownRouteConfig equality compares URIs', () {
      final a = UnknownRouteConfig(Uri.parse('/app/x'));
      final b = UnknownRouteConfig(Uri.parse('/app/x'));
      final c = UnknownRouteConfig(Uri.parse('/app/y'));

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('LoginRouteConfig is a singleton-equal value', () {
      const a = LoginRouteConfig();
      const b = LoginRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('ForgotPasswordRouteConfig is a singleton-equal value', () {
      const a = ForgotPasswordRouteConfig();
      const b = ForgotPasswordRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('LoginRouteConfig and ForgotPasswordRouteConfig are not equal', () {
      expect(
        const LoginRouteConfig(),
        isNot(const ForgotPasswordRouteConfig()),
      );
    });

    test('AdminTemplateEditorRouteConfig equality compares menuId', () {
      const a = AdminTemplateEditorRouteConfig(42);
      const b = AdminTemplateEditorRouteConfig(42);
      const c = AdminTemplateEditorRouteConfig(43);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(const PdfPreviewRouteConfig(42))));
    });

    test('HomeRouteConfig is a singleton-equal value', () {
      const a = HomeRouteConfig();
      const b = HomeRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('HomeRouteConfig is not equal to other migrated configs', () {
      expect(const HomeRouteConfig(), isNot(const LoginRouteConfig()));
      expect(const HomeRouteConfig(), isNot(const ForgotPasswordRouteConfig()));
    });

    test('MenuListRouteConfig is a singleton-equal value', () {
      const a = MenuListRouteConfig();
      const b = MenuListRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('MenuListRouteConfig is not equal to other migrated configs', () {
      expect(const MenuListRouteConfig(), isNot(const HomeRouteConfig()));
      expect(const MenuListRouteConfig(), isNot(const LoginRouteConfig()));
    });

    test('SettingsRouteConfig is a singleton-equal value', () {
      const a = SettingsRouteConfig();
      const b = SettingsRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('SettingsRouteConfig is not equal to other migrated configs', () {
      expect(const SettingsRouteConfig(), isNot(const HomeRouteConfig()));
      expect(const SettingsRouteConfig(), isNot(const MenuListRouteConfig()));
    });

    test('AdminTemplatesRouteConfig is a singleton-equal value', () {
      const a = AdminTemplatesRouteConfig();
      const b = AdminTemplatesRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test(
      'AdminTemplatesRouteConfig is not equal to other migrated configs',
      () {
        expect(
          const AdminTemplatesRouteConfig(),
          isNot(const HomeRouteConfig()),
        );
        expect(
          const AdminTemplatesRouteConfig(),
          isNot(const MenuListRouteConfig()),
        );
        expect(
          const AdminTemplatesRouteConfig(),
          isNot(const SettingsRouteConfig()),
        );
      },
    );

    test('AdminSizesRouteConfig is a singleton-equal value', () {
      const a = AdminSizesRouteConfig();
      const b = AdminSizesRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('AdminSizesRouteConfig is not equal to other migrated configs', () {
      expect(const AdminSizesRouteConfig(), isNot(const HomeRouteConfig()));
      expect(const AdminSizesRouteConfig(), isNot(const SettingsRouteConfig()));
      expect(
        const AdminSizesRouteConfig(),
        isNot(const AdminTemplatesRouteConfig()),
      );
    });

    test('AdminTemplateCreatorRouteConfig is a singleton-equal value', () {
      const a = AdminTemplateCreatorRouteConfig();
      const b = AdminTemplateCreatorRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test(
      'AdminTemplateCreatorRouteConfig is not equal to other migrated configs',
      () {
        expect(
          const AdminTemplateCreatorRouteConfig(),
          isNot(const AdminTemplatesRouteConfig()),
        );
        expect(
          const AdminTemplateCreatorRouteConfig(),
          isNot(const AdminSizesRouteConfig()),
        );
        expect(
          const AdminTemplateCreatorRouteConfig(),
          isNot(const HomeRouteConfig()),
        );
      },
    );

    test('PdfPreviewRouteConfig equality compares menuId', () {
      const a = PdfPreviewRouteConfig(7);
      const b = PdfPreviewRouteConfig(7);
      const c = PdfPreviewRouteConfig(8);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('PdfPreviewRouteConfig is not equal to other migrated configs', () {
      expect(const PdfPreviewRouteConfig(7), isNot(const HomeRouteConfig()));
      expect(
        const PdfPreviewRouteConfig(7),
        isNot(const MenuListRouteConfig()),
      );
    });

    test('AdminExportableMenusRouteConfig is a singleton-equal value', () {
      const a = AdminExportableMenusRouteConfig();
      const b = AdminExportableMenusRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test(
      'AdminExportableMenusRouteConfig is not equal to other migrated configs',
      () {
        expect(
          const AdminExportableMenusRouteConfig(),
          isNot(const HomeRouteConfig()),
        );
        expect(
          const AdminExportableMenusRouteConfig(),
          isNot(const AdminTemplatesRouteConfig()),
        );
        expect(
          const AdminExportableMenusRouteConfig(),
          isNot(const AdminSizesRouteConfig()),
        );
      },
    );
  });

  group('AppRouteInformationParser', () {
    final parser = AppRouteInformationParser();

    test('parses /app/login into LoginRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/login')),
      );

      expect(config, const LoginRouteConfig());
    });

    test('parses an unmigrated /app/* URI into UnknownRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/somewhere/else')),
      );

      expect(config, isA<UnknownRouteConfig>());
      expect(config, UnknownRouteConfig(Uri.parse('/app/somewhere/else')));
    });

    test('round-trips an UnknownRouteConfig back to the same URI', () async {
      final original = Uri.parse('/app/menus/42?foo=bar');
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: original),
      );
      final restored = parser.restoreRouteInformation(config);

      expect(restored, isNotNull);
      expect(restored!.uri, original);
    });

    test('round-trips a LoginRouteConfig to /app/login', () {
      final restored = parser.restoreRouteInformation(const LoginRouteConfig());

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/login');
    });

    test(
      'parses /app/forgot-password into ForgotPasswordRouteConfig',
      () async {
        final config = await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/app/forgot-password')),
        );

        expect(config, const ForgotPasswordRouteConfig());
      },
    );

    test('round-trips a ForgotPasswordRouteConfig to /app/forgot-password', () {
      final restored = parser.restoreRouteInformation(
        const ForgotPasswordRouteConfig(),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/forgot-password');
    });

    test('parses /app/home into HomeRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/home')),
      );

      expect(config, const HomeRouteConfig());
    });

    test('round-trips a HomeRouteConfig to /app/home', () {
      final restored = parser.restoreRouteInformation(const HomeRouteConfig());

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/home');
    });

    test('parses /app/menus into MenuListRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/menus')),
      );

      expect(config, const MenuListRouteConfig());
    });

    test('round-trips a MenuListRouteConfig to /app/menus', () {
      final restored = parser.restoreRouteInformation(
        const MenuListRouteConfig(),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/menus');
    });

    test('parses /app/settings into SettingsRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/settings')),
      );

      expect(config, const SettingsRouteConfig());
    });

    test('round-trips a SettingsRouteConfig to /app/settings', () {
      final restored = parser.restoreRouteInformation(
        const SettingsRouteConfig(),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/settings');
    });

    test(
      'parses /app/admin/templates into AdminTemplatesRouteConfig',
      () async {
        final config = await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/app/admin/templates')),
        );

        expect(config, const AdminTemplatesRouteConfig());
      },
    );

    test(
      'round-trips an AdminTemplatesRouteConfig to /app/admin/templates',
      () {
        final restored = parser.restoreRouteInformation(
          const AdminTemplatesRouteConfig(),
        );

        expect(restored, isNotNull);
        expect(restored!.uri.path, '/app/admin/templates');
      },
    );

    test('parses /app/admin/sizes into AdminSizesRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/admin/sizes')),
      );

      expect(config, const AdminSizesRouteConfig());
    });

    test('round-trips an AdminSizesRouteConfig to /app/admin/sizes', () {
      final restored = parser.restoreRouteInformation(
        const AdminSizesRouteConfig(),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/admin/sizes');
    });

    test(
      'parses /app/admin/templates/create into AdminTemplateCreatorRouteConfig',
      () async {
        final config = await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/app/admin/templates/create')),
        );

        expect(config, const AdminTemplateCreatorRouteConfig());
      },
    );

    test('round-trips an AdminTemplateCreatorRouteConfig to '
        '/app/admin/templates/create', () {
      final restored = parser.restoreRouteInformation(
        const AdminTemplateCreatorRouteConfig(),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/admin/templates/create');
    });

    test('parses /app/menus/{id}/pdf into a PdfPreviewRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/menus/42/pdf')),
      );

      expect(config, const PdfPreviewRouteConfig(42));
    });

    test(
      'rejects non-numeric menuId in /app/menus/{id}/pdf as Unknown',
      () async {
        final config = await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/app/menus/abc/pdf')),
        );

        expect(config, isA<UnknownRouteConfig>());
      },
    );

    test('round-trips a PdfPreviewRouteConfig to /app/menus/{id}/pdf', () {
      final restored = parser.restoreRouteInformation(
        const PdfPreviewRouteConfig(42),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/menus/42/pdf');
    });

    test(
      'parses /app/admin/exportable-menus into AdminExportableMenusRouteConfig',
      () async {
        final config = await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/app/admin/exportable-menus')),
        );

        expect(config, const AdminExportableMenusRouteConfig());
      },
    );

    test('round-trips an AdminExportableMenusRouteConfig to '
        '/app/admin/exportable-menus', () {
      final restored = parser.restoreRouteInformation(
        const AdminExportableMenusRouteConfig(),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/admin/exportable-menus');
    });

    test(
      'parses /app/admin/templates/{id}/edit into AdminTemplateEditorRouteConfig',
      () async {
        final config = await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/app/admin/templates/42/edit')),
        );

        expect(config, const AdminTemplateEditorRouteConfig(42));
      },
    );

    test(
      'rejects non-numeric menuId in /app/admin/templates/{id}/edit as Unknown',
      () async {
        final config = await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/app/admin/templates/abc/edit')),
        );

        expect(config, isA<UnknownRouteConfig>());
      },
    );

    test('round-trips an AdminTemplateEditorRouteConfig to '
        '/app/admin/templates/{id}/edit', () {
      final restored = parser.restoreRouteInformation(
        const AdminTemplateEditorRouteConfig(42),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/admin/templates/42/edit');
    });

    test('handles root path', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/')),
      );

      expect(config, isA<UnknownRouteConfig>());
      expect((config as UnknownRouteConfig).uri.path, '/');
    });
  });
}
