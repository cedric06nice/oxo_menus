import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_router.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_route_adapter.dart';

class _RecordingRouteNavigator implements RouteNavigator {
  final List<({String location, Object? extra})> calls = [];

  final List<({String location, Object? extra})> pushCalls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }

  @override
  void push(String location, {Object? extra}) {
    pushCalls.add((location: location, extra: extra));
  }
}

void main() {
  group('AdminExportableMenusRouteAdapter', () {
    late _RecordingRouteNavigator navigator;
    late AdminExportableMenusRouteAdapter router;

    setUp(() {
      navigator = _RecordingRouteNavigator();
      router = AdminExportableMenusRouteAdapter(navigator);
    });

    test('implements AdminExportableMenusRouter', () {
      expect(router, isA<AdminExportableMenusRouter>());
    });

    test('goBack navigates to AppRoutes.home', () {
      router.goBack();

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.home);
      expect(navigator.calls.single.extra, isNull);
    });

    test('subsequent goBack calls record in order', () {
      router.goBack();
      router.goBack();

      expect(navigator.calls.map((c) => c.location).toList(), <String>[
        AppRoutes.home,
        AppRoutes.home,
      ]);
    });
  });
}
