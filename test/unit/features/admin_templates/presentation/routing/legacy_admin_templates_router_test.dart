import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/legacy_admin_templates_router.dart';

class _RecordingLegacyNavigator implements LegacyNavigator {
  final List<({String location, Object? extra})> calls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }
}

void main() {
  group('LegacyAdminTemplatesRouter', () {
    late _RecordingLegacyNavigator navigator;
    late LegacyAdminTemplatesRouter router;

    setUp(() {
      navigator = _RecordingLegacyNavigator();
      router = LegacyAdminTemplatesRouter(navigator);
    });

    test('implements AdminTemplatesRouter', () {
      expect(router, isA<AdminTemplatesRouter>());
    });

    test(
      'goToAdminTemplateCreate forwards to AppRoutes.adminTemplateCreate',
      () {
        router.goToAdminTemplateCreate();

        expect(navigator.calls, hasLength(1));
        expect(navigator.calls.single.location, AppRoutes.adminTemplateCreate);
        expect(navigator.calls.single.extra, isNull);
      },
    );

    test('goToAdminTemplateEditor forwards to the migrated '
        '/app/admin/templates/{id}/edit path', () {
      router.goToAdminTemplateEditor(7);

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, '/app/admin/templates/7/edit');
    });

    test('goBack navigates to AppRoutes.home', () {
      router.goBack();

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.home);
    });

    test('subsequent navigations record in order', () {
      router.goToAdminTemplateCreate();
      router.goToAdminTemplateEditor(2);
      router.goBack();

      expect(navigator.calls.map((c) => c.location).toList(), <String>[
        AppRoutes.adminTemplateCreate,
        '/app/admin/templates/2/edit',
        AppRoutes.home,
      ]);
    });
  });
}
