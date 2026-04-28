import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/legacy_menu_list_router.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';

class _RecordingLegacyNavigator implements LegacyNavigator {
  final List<({String location, Object? extra})> calls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }
}

void main() {
  group('LegacyMenuListRouter', () {
    late _RecordingLegacyNavigator navigator;
    late LegacyMenuListRouter router;

    setUp(() {
      navigator = _RecordingLegacyNavigator();
      router = LegacyMenuListRouter(navigator);
    });

    test('implements MenuListRouter', () {
      expect(router, isA<MenuListRouter>());
    });

    test(
      'goToMenuEditor forwards to the migrated /app/menus/{id}/edit path',
      () {
        router.goToMenuEditor(42);

        expect(navigator.calls, hasLength(1));
        expect(navigator.calls.single.location, '/app/menus/42/edit');
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
      router.goToMenuEditor(1);
      router.goToAdminTemplateEditor(2);
      router.goBack();

      expect(navigator.calls.map((c) => c.location).toList(), <String>[
        '/app/menus/1/edit',
        '/app/admin/templates/2/edit',
        AppRoutes.home,
      ]);
    });
  });
}
