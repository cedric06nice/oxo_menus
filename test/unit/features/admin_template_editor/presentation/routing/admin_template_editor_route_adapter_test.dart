import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_router.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_route_adapter.dart';

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
  group('AdminTemplateEditorRouteAdapter', () {
    late _RecordingRouteNavigator navigator;
    late AdminTemplateEditorRouteAdapter router;

    setUp(() {
      navigator = _RecordingRouteNavigator();
      router = AdminTemplateEditorRouteAdapter(navigator);
    });

    test('implements AdminTemplateEditorRouter', () {
      expect(router, isA<AdminTemplateEditorRouter>());
    });

    test('goBack navigates to AppRoutes.adminTemplates', () {
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

    test('goToPdfPreview forwards to AppRoutes.menuPdf(id)', () {
      router.goToPdfPreview(7);

      expect(navigator.calls, hasLength(1));
      expect(navigator.calls.single.location, AppRoutes.menuPdf(7));
      expect(navigator.calls.single.extra, isNull);
    });

    test('subsequent navigations record in order', () {
      router.goToAdminSizes();
      router.goToPdfPreview(2);
      router.goBack();

      expect(navigator.calls.map((c) => c.location).toList(), <String>[
        AppRoutes.adminSizes,
        AppRoutes.menuPdf(2),
        AppRoutes.adminTemplates,
      ]);
    });
  });
}
