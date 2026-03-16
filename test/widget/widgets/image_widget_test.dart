import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_widget.dart';

import '../../helpers/test_image_data.dart';

class MockFileRepository extends Mock implements FileRepository {}

void main() {
  group('ImageWidget', () {
    late MockFileRepository mockFileRepository;

    setUp(() {
      mockFileRepository = MockFileRepository();
      when(
        () => mockFileRepository.downloadFile('test-file-id'),
      ).thenAnswer((_) async => Success(kTestPngBytes));
    });

    Widget buildWidget({
      ImageProps props = const ImageProps(fileId: 'test-file-id'),
      WidgetContext context = const WidgetContext(isEditable: false),
    }) {
      return ProviderScope(
        overrides: [
          fileRepositoryProvider.overrideWithValue(mockFileRepository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ImageWidget(props: props, context: context),
          ),
        ),
      );
    }

    testWidgets('should display Image.memory from downloaded bytes', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<MemoryImage>());
      final memoryImage = image.image as MemoryImage;
      expect(memoryImage.bytes, kTestPngBytes);
    });

    testWidgets('should show loading indicator while downloading', (
      tester,
    ) async {
      final completer = Completer<Result<Uint8List, DomainError>>();
      when(
        () => mockFileRepository.downloadFile('test-file-id'),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildWidget());
      // Only one pump — don't settle (future never completes)

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error placeholder when download fails', (
      tester,
    ) async {
      when(
        () => mockFileRepository.downloadFile('test-file-id'),
      ).thenAnswer((_) async => const Failure(NetworkError('Network error')));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('should align left when align is left', (tester) async {
      const props = ImageProps(fileId: 'test-file-id', align: 'left');

      await tester.pumpWidget(buildWidget(props: props));
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('should align center when align is center', (tester) async {
      const props = ImageProps(fileId: 'test-file-id', align: 'center');

      await tester.pumpWidget(buildWidget(props: props));
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.center);
    });

    testWidgets('should align right when align is right', (tester) async {
      const props = ImageProps(fileId: 'test-file-id', align: 'right');

      await tester.pumpWidget(buildWidget(props: props));
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('should wrap in GestureDetector when isEditable is true', (
      tester,
    ) async {
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        buildWidget(context: WidgetContext(isEditable: true, onUpdate: (_) {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should NOT respond to tap when isEditable is false', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final gesture = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gesture.onTap, isNull);
    });

    testWidgets(
      'should call onEditStarted before and onEditEnded after edit dialog',
      (tester) async {
        var editStartedCount = 0;
        var editEndedCount = 0;
        when(
          () => mockFileRepository.listImageFiles(),
        ).thenAnswer((_) async => const Success([]));

        await tester.pumpWidget(
          buildWidget(
            context: WidgetContext(
              isEditable: true,
              onUpdate: (_) {},
              onEditStarted: () => editStartedCount++,
              onEditEnded: () => editEndedCount++,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Invoke onTap directly
        final gesture = tester.widget<GestureDetector>(
          find.byType(GestureDetector),
        );
        gesture.onTap!();
        await tester.pumpAndSettle();

        expect(editStartedCount, 1);
        expect(editEndedCount, 0);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(editEndedCount, 1);
      },
    );

    testWidgets('should be tappable when in editable mode', (tester) async {
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        buildWidget(context: WidgetContext(isEditable: true, onUpdate: (_) {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsOneWidget);
      final gesture = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gesture.onTap, isNotNull);
    });
  });
}
