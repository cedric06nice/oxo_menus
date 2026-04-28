import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/legacy_admin_template_creator_router.dart';

class _RecordingLegacyNavigator implements LegacyNavigator {
  final List<({String location, Object? extra})> calls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }
}

void main() {
  group('LegacyAdminTemplateCreatorRouter', () {
    late _RecordingLegacyNavigator navigator;
    late LegacyAdminTemplateCreatorRouter router;

    setUp(() {
      navigator = _RecordingLegacyNavigator();
      router = LegacyAdminTemplateCreatorRouter(navigator);
    });

    test('implements AdminTemplateCreatorRouter', () {
      expect(router, isA<AdminTemplateCreatorRouter>());
    });

    test('goBack forwards to AppRoutes.adminTemplates', () {
      router.goBack();

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.adminTemplates);
      expect(navigator.calls.single.extra, isNull);
    });

    test('goToAdminSizes forwards to AppRoutes.adminSizes', () {
      router.goToAdminSizes();

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.adminSizes);
      expect(navigator.calls.single.extra, isNull);
    });

    test('goToAdminTemplateEditor forwards to the migrated '
        '/app/admin/templates/{id}/edit path', () {
      router.goToAdminTemplateEditor(7);

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, '/app/admin/templates/7/edit');
    });

    test('subsequent navigations record in order', () {
      router.goToAdminSizes();
      router.goToAdminTemplateEditor(2);
      router.goBack();

      expect(navigator.calls.map((c) => c.location).toList(), <String>[
        AppRoutes.adminSizes,
        '/app/admin/templates/2/edit',
        AppRoutes.adminTemplates,
      ]);
    });
  });
}
