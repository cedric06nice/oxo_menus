import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_router.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/legacy_admin_exportable_menus_router.dart';

class _RecordingLegacyNavigator implements LegacyNavigator {
  final List<({String location, Object? extra})> calls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }
}

void main() {
  group('LegacyAdminExportableMenusRouter', () {
    late _RecordingLegacyNavigator navigator;
    late LegacyAdminExportableMenusRouter router;

    setUp(() {
      navigator = _RecordingLegacyNavigator();
      router = LegacyAdminExportableMenusRouter(navigator);
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
