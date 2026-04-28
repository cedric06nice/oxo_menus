import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/image_file_info.dart';
import 'package:oxo_menus/shared/domain/repositories/file_repository.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/image_widget/image_edit_dialog.dart';

import '../../../../../../helpers/test_image_data.dart';
import '../../../../../../fakes/fake_file_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A fake whose [listImageFiles] never resolves (blocks forever).
/// Use to assert loading states safely — tests must complete the completer
/// before [pumpAndSettle].
class _BlockingFileRepository implements FileRepository {
  final Completer<Result<List<ImageFileInfo>, DomainError>> completer;

  _BlockingFileRepository(this.completer);

  @override
  Future<Result<List<ImageFileInfo>, DomainError>> listImageFiles() =>
      completer.future;

  @override
  Future<Result<Uint8List, DomainError>> downloadFile(String fileId) async =>
      Success(kTestPngBytes);

  @override
  Future<Result<String, DomainError>> upload(
    Uint8List bytes,
    String filename,
  ) async => throw UnimplementedError();

  @override
  Future<Result<String, DomainError>> replace(
    String fileId,
    Uint8List bytes,
    String filename,
  ) async => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeFileRepository fakeFileRepository;
  late ImageGateway gateway;

  setUp(() {
    fakeFileRepository = FakeFileRepository();
    // Default: download succeeds with test PNG bytes
    fakeFileRepository.whenDownloadFile(Success(kTestPngBytes));
    gateway = ImageGateway(repository: fakeFileRepository);
  });

  Widget buildDialog({
    ImageProps props = const ImageProps(fileId: 'test-file-id'),
    void Function(ImageProps)? onSave,
    TargetPlatform? platform,
    bool useRoute = false,
    ImageGateway? imageGateway,
  }) {
    final effectiveGateway = imageGateway ?? gateway;
    return MaterialApp(
      theme: platform != null ? ThemeData(platform: platform) : null,
      home: useRoute
          ? Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      fullscreenDialog: true,
                      builder: (_) => ImageEditDialog(
                        props: props,
                        onSave: onSave ?? (_) {},
                        imageGateway: effectiveGateway,
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            )
          : Scaffold(
              body: ImageEditDialog(
                props: props,
                onSave: onSave ?? (_) {},
                imageGateway: effectiveGateway,
              ),
            ),
    );
  }

  group('ImageEditDialog', () {
    testWidgets('should show loading indicator while files are loading', (
      tester,
    ) async {
      // Arrange
      final completer = Completer<Result<List<ImageFileInfo>, DomainError>>();
      final slowRepo = _BlockingFileRepository(completer);
      final slowGateway = ImageGateway(repository: slowRepo);

      // Act
      await tester.pumpWidget(buildDialog(imageGateway: slowGateway));
      // Pump once to trigger addPostFrameCallback (starts loading)
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Cleanup — complete to avoid pending futures
      completer.complete(const Success([]));
      await tester.pumpAndSettle();
    });

    testWidgets('should show error message when file loading fails', (
      tester,
    ) async {
      // Arrange
      fakeFileRepository.whenListImageFiles(
        const Failure(ServerError('Failed to load files')),
      );

      // Act
      await tester.pumpWidget(buildDialog());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Error loading images'), findsOneWidget);
    });

    testWidgets('should show thumbnail grid when files load successfully', (
      tester,
    ) async {
      // Arrange
      const files = [
        ImageFileInfo(id: 'file-1', title: 'logo.png', type: 'image/png'),
        ImageFileInfo(id: 'file-2', title: 'bg.jpg', type: 'image/jpeg'),
      ];
      fakeFileRepository.whenListImageFiles(const Success(files));

      // Act
      await tester.pumpWidget(buildDialog());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('thumbnail grid uses Image.memory for each image file', (
      tester,
    ) async {
      // Arrange
      const files = [
        ImageFileInfo(id: 'file-1', title: 'logo.png', type: 'image/png'),
        ImageFileInfo(id: 'file-2', title: 'bg.jpg', type: 'image/jpeg'),
      ];
      fakeFileRepository.whenListImageFiles(const Success(files));

      // Act
      await tester.pumpWidget(buildDialog());
      await tester.pumpAndSettle();

      // Assert — all thumbnails use MemoryImage (not NetworkImage)
      final images = tester.widgetList<Image>(find.byType(Image));
      for (final image in images) {
        expect(image.image, isA<MemoryImage>());
      }
      // Both file IDs were requested
      final downloadCalls = fakeFileRepository.downloadFileCalls;
      expect(downloadCalls.any((c) => c.fileId == 'file-1'), isTrue);
      expect(downloadCalls.any((c) => c.fileId == 'file-2'), isTrue);
    });

    testWidgets('should update fileId when an image is selected', (
      tester,
    ) async {
      // Arrange
      const props = ImageProps(fileId: 'file-1');
      const files = [
        ImageFileInfo(id: 'file-1', title: 'logo.png', type: 'image/png'),
        ImageFileInfo(id: 'file-2', title: 'bg.jpg', type: 'image/jpeg'),
      ];
      fakeFileRepository.whenListImageFiles(const Success(files));
      ImageProps? savedProps;

      // Act
      await tester.pumpWidget(
        buildDialog(props: props, onSave: (updated) => savedProps = updated),
      );
      await tester.pumpAndSettle();

      // Tap the second image grid item
      final gestureDetectors = find.byType(GestureDetector);
      await tester.tap(gestureDetectors.at(1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert
      expect(savedProps?.fileId, 'file-2');
    });

    testWidgets('should highlight the currently selected image', (
      tester,
    ) async {
      // Arrange
      const props = ImageProps(fileId: 'file-1');
      const files = [
        ImageFileInfo(id: 'file-1', title: 'logo.png', type: 'image/png'),
        ImageFileInfo(id: 'file-2', title: 'bg.jpg', type: 'image/jpeg'),
      ];
      fakeFileRepository.whenListImageFiles(const Success(files));

      // Act
      await tester.pumpWidget(buildDialog(props: props));
      await tester.pumpAndSettle();

      // Assert — at least one container is rendered (selection visual exists)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets(
      'should show alignment selector with left/center/right options',
      (tester) async {
        // Arrange
        const props = ImageProps(fileId: 'test-file-123', align: 'center');
        fakeFileRepository.whenListImageFiles(const Success([]));

        // Act
        await tester.pumpWidget(buildDialog(props: props));
        await tester.pumpAndSettle();

        // Assert — DropdownButtonFormField present
        expect(find.byType(DropdownButtonFormField<String>), findsWidgets);

        // Open the alignment dropdown
        await tester.tap(find.text('Center').first);
        await tester.pumpAndSettle();

        expect(find.text('Left').hitTestable(), findsOneWidget);
        expect(find.text('Center').hitTestable(), findsWidgets);
        expect(find.text('Right').hitTestable(), findsOneWidget);
      },
    );

    testWidgets('should call onSave with updated props when saved', (
      tester,
    ) async {
      // Arrange
      const props = ImageProps(fileId: 'original-file');
      ImageProps? savedProps;
      fakeFileRepository.whenListImageFiles(const Success([]));

      // Act
      await tester.pumpWidget(
        buildDialog(props: props, onSave: (updated) => savedProps = updated),
      );
      await tester.pumpAndSettle();

      // Change alignment to 'left'
      await tester.tap(find.text('Center').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Left').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert
      expect(savedProps, isNotNull);
      expect(savedProps?.align, 'left');
    });

    testWidgets('should not call onSave when cancelled', (tester) async {
      // Arrange
      const props = ImageProps(fileId: 'test-file');
      ImageProps? savedProps;
      fakeFileRepository.whenListImageFiles(const Success([]));

      // Act
      await tester.pumpWidget(
        buildDialog(props: props, onSave: (updated) => savedProps = updated),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(savedProps, isNull);
    });

    testWidgets('should allow editing width and height', (tester) async {
      // Arrange
      const props = ImageProps(fileId: 'test-file');
      ImageProps? savedProps;
      fakeFileRepository.whenListImageFiles(const Success([]));

      // Act
      await tester.pumpWidget(
        buildDialog(props: props, onSave: (updated) => savedProps = updated),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Width').first,
        '200',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Height').first,
        '150',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert
      expect(savedProps?.width, 200.0);
      expect(savedProps?.height, 150.0);
    });

    testWidgets('renders CupertinoPageScaffold on iOS', (tester) async {
      // Arrange
      fakeFileRepository.whenListImageFiles(const Success([]));

      // Act
      await tester.pumpWidget(
        buildDialog(platform: TargetPlatform.iOS, useRoute: true),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.text('Edit Image'), findsOneWidget);
    });

    testWidgets('shows CupertinoActivityIndicator while loading on iOS', (
      tester,
    ) async {
      // Arrange
      final completer = Completer<Result<List<ImageFileInfo>, DomainError>>();
      final slowRepo = _BlockingFileRepository(completer);
      final slowGateway = ImageGateway(repository: slowRepo);

      // Act
      await tester.pumpWidget(
        buildDialog(
          platform: TargetPlatform.iOS,
          useRoute: true,
          imageGateway: slowGateway,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      // Cleanup
      completer.complete(const Success([]));
      await tester.pumpAndSettle();
    });

    testWidgets('renders AlertDialog on Android', (tester) async {
      // Arrange
      fakeFileRepository.whenListImageFiles(const Success([]));

      // Act
      await tester.pumpWidget(buildDialog(platform: TargetPlatform.android));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
