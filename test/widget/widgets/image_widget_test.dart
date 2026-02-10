import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_widget.dart';

void main() {
  group('ImageWidget', () {
    testWidgets('should render an Image widget', (tester) async {
      const props = ImageProps(fileId: 'test-file-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ImageWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should align left when align is left', (tester) async {
      const props = ImageProps(fileId: 'test-file-id', align: 'left');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ImageWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('should align center when align is center', (tester) async {
      const props = ImageProps(fileId: 'test-file-id', align: 'center');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ImageWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.center);
    });

    testWidgets('should align right when align is right', (tester) async {
      const props = ImageProps(fileId: 'test-file-id', align: 'right');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ImageWidget(
                props: props,
                context: WidgetContext(isEditable: false),
              ),
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });
  });
}
