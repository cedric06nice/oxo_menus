import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_router.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_route_adapter.dart';

class _RecordingRouteNavigator implements RouteNavigator {
  final List<({String location, Object? extra})> calls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }
}

void main() {
  group('AdminSizesRouteAdapter', () {
    late _RecordingRouteNavigator navigator;
    late AdminSizesRouteAdapter router;

    setUp(() {
      navigator = _RecordingRouteNavigator();
      router = AdminSizesRouteAdapter(navigator);
    });

    test('implements AdminSizesRouter', () {
      expect(router, isA<AdminSizesRouter>());
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
