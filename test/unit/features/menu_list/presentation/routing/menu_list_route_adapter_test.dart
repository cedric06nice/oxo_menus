import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_route_adapter.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';

class _RecordingRouteNavigator implements RouteNavigator {
  final List<({String location, Object? extra})> calls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }
}

void main() {
  group('MenuListRouteAdapter', () {
    late _RecordingRouteNavigator navigator;
    late MenuListRouteAdapter router;

    setUp(() {
      navigator = _RecordingRouteNavigator();
      router = MenuListRouteAdapter(navigator);
    });

    test('implements MenuListRouter', () {
      expect(router, isA<MenuListRouter>());
    });

    test('goToMenuEditor forwards to the /menus/{id} path', () {
      router.goToMenuEditor(42);

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.menuEditor(42));
      expect(navigator.calls.single.extra, isNull);
    });

    test('goToAdminTemplateEditor forwards to the '
        '/admin/templates/{id} path', () {
      router.goToAdminTemplateEditor(7);

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.adminTemplateEditor(7));
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
        AppRoutes.menuEditor(1),
        AppRoutes.adminTemplateEditor(2),
        AppRoutes.home,
      ]);
    });
  });
}
