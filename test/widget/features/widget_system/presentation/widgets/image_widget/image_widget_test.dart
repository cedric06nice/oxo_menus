import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';
import 'package:oxo_menus/shared/domain/repositories/file_repository.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/features/widget_system/domain/widget_definition.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/image_widget/image_widget.dart';

import '../../../../../../helpers/test_image_data.dart';
import '../../../../../../fakes/fake_file_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void _noOp(Map<String, dynamic> _) {}

/// A fake that holds a [Completer] so tests can observe the loading state
/// before resolving the future.
class _ControllableFileRepository implements FileRepository {
  final Completer<Result<Uint8List, DomainError>> completer;

  _ControllableFileRepository(this.completer);

  @override
  Future<Result<Uint8List, DomainError>> downloadFile(String fileId) =>
      completer.future;

  @override
  Future<Result<String, DomainError>> upload(
    Uint8List bytes,
    String filename,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<String, DomainError>> replace(
    String fileId,
    Uint8List bytes,
    String filename,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<ImageFileInfo>, DomainError>> listImageFiles() async {
    throw UnimplementedError();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ImageWidget', () {
    late FakeFileRepository fakeFileRepository;
    late ImageGateway gateway;

    setUp(() {
      fakeFileRepository = FakeFileRepository();
      fakeFileRepository.whenDownloadFile(Success(kTestPngBytes));
      gateway = ImageGateway(repository: fakeFileRepository);
    });

    Widget buildWidget({
      ImageProps props = const ImageProps(fileId: 'test-file-id'),
      WidgetContext? context,
      ImageGateway? imageGateway,
    }) {
      final effectiveGateway = imageGateway ?? gateway;
      final effectiveContext =
          context ?? WidgetContext(isEditable: false, imageGateway: effectiveGateway);
      return MaterialApp(
        home: Scaffold(
          body: ImageWidget(props: props, context: effectiveContext),
        ),
      );
    }

    testWidgets('should display Image.memory from downloaded bytes', (
      tester,
    ) async {
      // Arrange — setUp configures success response

      // Act
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Assert
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<MemoryImage>());
      final memoryImage = image.image as MemoryImage;
      expect(memoryImage.bytes, kTestPngBytes);
    });

    testWidgets('should show loading indicator while downloading', (
      tester,
    ) async {
      // Arrange
      final completer = Completer<Result<Uint8List, DomainError>>();
      final slowRepo = _ControllableFileRepository(completer);
      final slowGateway = ImageGateway(repository: slowRepo);

      // Act
      await tester.pumpWidget(buildWidget(imageGateway: slowGateway));
      // One pump triggers the FutureBuilder but does not settle it
      await tester.pump();

      // Assert — loading state visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Cleanup — resolve future and settle to avoid pending timers
      completer.complete(Success(kTestPngBytes));
      await tester.pumpAndSettle();
    });

    testWidgets('should show error placeholder when download fails', (
      tester,
    ) async {
      // Arrange
      fakeFileRepository.whenDownloadFile(
        Failure(const NetworkError('Network error')),
      );

      // Act
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('should pass left alignment to Image.memory', (tester) async {
      // Arrange
      const props = ImageProps(fileId: 'test-file-id', align: 'left');

      // Act
      await tester.pumpWidget(buildWidget(props: props));
      await tester.pumpAndSettle();

      // Assert
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.alignment, Alignment.centerLeft);
    });

    testWidgets('should pass center alignment to Image.memory', (tester) async {
      // Arrange
      const props = ImageProps(fileId: 'test-file-id', align: 'center');

      // Act
      await tester.pumpWidget(buildWidget(props: props));
      await tester.pumpAndSettle();

      // Assert
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.alignment, Alignment.center);
    });

    testWidgets('should pass right alignment to Image.memory', (tester) async {
      // Arrange
      const props = ImageProps(fileId: 'test-file-id', align: 'right');

      // Act
      await tester.pumpWidget(buildWidget(props: props));
      await tester.pumpAndSettle();

      // Assert
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.alignment, Alignment.centerRight);
    });

    testWidgets('should wrap in GestureDetector when isEditable is true', (
      tester,
    ) async {
      // Arrange
      fakeFileRepository.whenListImageFiles(const Success([]));

      // Act
      await tester.pumpWidget(
        buildWidget(
          context: WidgetContext(
            isEditable: true,
            onUpdate: _noOp,
            imageGateway: gateway,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should NOT respond to tap when isEditable is false', (
      tester,
    ) async {
      // Arrange — default context has isEditable: false

      // Act
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Assert
      final gesture = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gesture.onTap, isNull);
    });

    testWidgets(
      'should call onEditStarted before and onEditEnded after edit dialog',
      (tester) async {
        // Arrange
        var editStartedCount = 0;
        var editEndedCount = 0;
        fakeFileRepository.whenListImageFiles(const Success([]));

        // Act
        await tester.pumpWidget(
          buildWidget(
            context: WidgetContext(
              isEditable: true,
              onUpdate: (_) {},
              onEditStarted: () => editStartedCount++,
              onEditEnded: () => editEndedCount++,
              imageGateway: gateway,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Invoke onTap directly via the GestureDetector
        final gesture = tester.widget<GestureDetector>(
          find.byType(GestureDetector),
        );
        gesture.onTap!();
        await tester.pumpAndSettle();

        // Assert — onEditStarted called, onEditEnded not yet
        expect(editStartedCount, 1);
        expect(editEndedCount, 0);

        // Dismiss dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert — onEditEnded called after dialog dismissed
        expect(editEndedCount, 1);
      },
    );

    testWidgets('should be tappable when in editable mode', (tester) async {
      // Arrange
      fakeFileRepository.whenListImageFiles(const Success([]));

      // Act
      await tester.pumpWidget(
        buildWidget(
          context: WidgetContext(
            isEditable: true,
            onUpdate: _noOp,
            imageGateway: gateway,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GestureDetector), findsOneWidget);
      final gesture = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gesture.onTap, isNotNull);
    });
  });
}
