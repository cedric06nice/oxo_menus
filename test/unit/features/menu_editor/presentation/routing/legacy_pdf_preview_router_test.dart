import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/migration/legacy_navigator.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/legacy_pdf_preview_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_router.dart';

class _RecordingLegacyNavigator implements LegacyNavigator {
  final List<({String location, Object? extra})> calls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }
}

void main() {
  group('LegacyPdfPreviewRouter', () {
    late _RecordingLegacyNavigator navigator;
    late LegacyPdfPreviewRouter router;

    setUp(() {
      navigator = _RecordingLegacyNavigator();
      router = LegacyPdfPreviewRouter(navigator);
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
