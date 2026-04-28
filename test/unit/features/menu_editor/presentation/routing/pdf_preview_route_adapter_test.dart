import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_route_adapter.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_router.dart';

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
  group('PdfPreviewRouteAdapter', () {
    late _RecordingRouteNavigator navigator;
    late PdfPreviewRouteAdapter router;

    setUp(() {
      navigator = _RecordingRouteNavigator();
      router = PdfPreviewRouteAdapter(navigator);
    });

    test('implements PdfPreviewRouter', () {
      expect(router, isA<PdfPreviewRouter>());
    });

    test('goBack navigates to AppRoutes.menus', () {
      router.goBack();

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.menus);
      expect(navigator.calls.single.extra, isNull);
    });

    test('subsequent goBack calls record in order', () {
      router.goBack();
      router.goBack();

      expect(navigator.calls.map((c) => c.location).toList(), <String>[
        AppRoutes.menus,
        AppRoutes.menus,
      ]);
    });
  });
}
