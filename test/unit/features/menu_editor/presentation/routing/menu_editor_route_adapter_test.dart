import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_route_adapter.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_router.dart';

class _RecordingRouteNavigator implements RouteNavigator {
  final List<({String location, Object? extra})> calls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }
}

void main() {
  group('MenuEditorRouteAdapter', () {
    late _RecordingRouteNavigator navigator;
    late MenuEditorRouteAdapter router;

    setUp(() {
      navigator = _RecordingRouteNavigator();
      router = MenuEditorRouteAdapter(navigator);
    });

    test('implements MenuEditorRouter', () {
      expect(router, isA<MenuEditorRouter>());
    });

    test('goBack navigates to AppRoutes.menus', () {
      router.goBack();

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.menus);
      expect(navigator.calls.single.extra, isNull);
    });

    test('goToPdfPreview forwards to AppRoutes.menuPdf(id)', () {
      router.goToPdfPreview(42);

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.menuPdf(42));
      expect(navigator.calls.single.extra, isNull);
    });

    test('subsequent navigations record in order', () {
      router.goToPdfPreview(1);
      router.goBack();
      router.goToPdfPreview(2);

      expect(navigator.calls.map((c) => c.location).toList(), <String>[
        AppRoutes.menuPdf(1),
        AppRoutes.menus,
        AppRoutes.menuPdf(2),
      ]);
    });
  });
}
