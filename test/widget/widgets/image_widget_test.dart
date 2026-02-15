import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_widget.dart';

class MockFileRepository extends Mock implements FileRepository {}

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

    testWidgets('should wrap in GestureDetector when isEditable is true', (
      tester,
    ) async {
      const props = ImageProps(fileId: 'test-file-id');
      final mockFileRepository = MockFileRepository();
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageWidget(
                props: props,
                context: WidgetContext(isEditable: true, onUpdate: (_) {}),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should NOT respond to tap when isEditable is false', (
      tester,
    ) async {
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
      final gesture = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gesture.onTap, isNull);
    });

    testWidgets('should be tappable when in editable mode', (tester) async {
      const props = ImageProps(fileId: 'test-file-id');
      final mockFileRepository = MockFileRepository();
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageWidget(
                props: props,
                context: WidgetContext(isEditable: true, onUpdate: (_) {}),
              ),
            ),
          ),
        ),
      );
      // The dialog itself is tested in image_edit_dialog_test.dart
      // This test confirms that when isEditable is true, the GestureDetector exists
      expect(find.byType(GestureDetector), findsOneWidget);
      final gesture = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gesture.onTap, isNotNull);
    });
  });
}
