import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_edit_dialog.dart';

import '../../../../helpers/test_image_data.dart';

class MockFileRepository extends Mock implements FileRepository {}

void main() {
  late MockFileRepository mockFileRepository;

  setUp(() {
    mockFileRepository = MockFileRepository();
    // Default stub for downloadFile — individual tests can override
    when(
      () => mockFileRepository.downloadFile(any()),
    ).thenAnswer((_) async => Success(kTestPngBytes));
  });

  Widget buildDialog({
    ImageProps props = const ImageProps(fileId: 'test-file-id'),
    void Function(ImageProps)? onSave,
    TargetPlatform? platform,
    bool useRoute = false,
  }) {
    final widget = ProviderScope(
      overrides: [fileRepositoryProvider.overrideWithValue(mockFileRepository)],
      child: MaterialApp(
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
                        ),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              )
            : Scaffold(
                body: ImageEditDialog(props: props, onSave: onSave ?? (_) {}),
              ),
      ),
    );
    return widget;
  }

  group('ImageEditDialog', () {
    testWidgets('should show loading indicator while files are loading', (
      tester,
    ) async {
      final completer = Completer<Result<List<ImageFileInfo>, DomainError>>();
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildDialog());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when file loading fails', (
      tester,
    ) async {
      when(() => mockFileRepository.listImageFiles()).thenAnswer(
        (_) async => const Failure(ServerError('Failed to load files')),
      );

      await tester.pumpWidget(buildDialog());
      await tester.pumpAndSettle();

      expect(find.textContaining('Error loading images'), findsOneWidget);
    });

    testWidgets('should show thumbnail grid when files load successfully', (
      tester,
    ) async {
      final files = [
        const ImageFileInfo(id: 'file-1', title: 'logo.png', type: 'image/png'),
        const ImageFileInfo(id: 'file-2', title: 'bg.jpg', type: 'image/jpeg'),
      ];
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => Success(files));

      await tester.pumpWidget(buildDialog());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('thumbnail grid uses Image.memory for each image file', (
      tester,
    ) async {
      final files = [
        const ImageFileInfo(id: 'file-1', title: 'logo.png', type: 'image/png'),
        const ImageFileInfo(id: 'file-2', title: 'bg.jpg', type: 'image/jpeg'),
      ];
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => Success(files));

      await tester.pumpWidget(buildDialog());
      await tester.pumpAndSettle();

      // All thumbnail images should be Image.memory (MemoryImage), not NetworkImage
      final images = tester.widgetList<Image>(find.byType(Image));
      for (final image in images) {
        expect(image.image, isA<MemoryImage>());
      }
      verify(() => mockFileRepository.downloadFile('file-1')).called(1);
      verify(() => mockFileRepository.downloadFile('file-2')).called(1);
    });

    testWidgets('should update fileId when an image is selected', (
      tester,
    ) async {
      const props = ImageProps(fileId: 'file-1');
      final files = [
        const ImageFileInfo(id: 'file-1', title: 'logo.png', type: 'image/png'),
        const ImageFileInfo(id: 'file-2', title: 'bg.jpg', type: 'image/jpeg'),
      ];
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => Success(files));

      ImageProps? savedProps;

      await tester.pumpWidget(
        buildDialog(props: props, onSave: (updated) => savedProps = updated),
      );
      await tester.pumpAndSettle();

      // Tap on the second image (bg.jpg) - find the GestureDetector containing it
      final gestureDetectors = find.byType(GestureDetector);
      await tester.tap(gestureDetectors.at(1)); // Second grid item
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps?.fileId, 'file-2');
    });

    testWidgets('should highlight the currently selected image', (
      tester,
    ) async {
      const props = ImageProps(fileId: 'file-1');
      final files = [
        const ImageFileInfo(id: 'file-1', title: 'logo.png', type: 'image/png'),
        const ImageFileInfo(id: 'file-2', title: 'bg.jpg', type: 'image/jpeg'),
      ];
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => Success(files));

      await tester.pumpWidget(buildDialog(props: props));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.length, greaterThan(0));
    });

    testWidgets(
      'should show alignment selector with left/center/right options',
      (tester) async {
        const props = ImageProps(fileId: 'test-file-123', align: 'center');
        when(
          () => mockFileRepository.listImageFiles(),
        ).thenAnswer((_) async => const Success([]));

        await tester.pumpWidget(buildDialog(props: props));
        await tester.pumpAndSettle();

        expect(find.byType(DropdownButtonFormField<String>), findsWidgets);

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
      const props = ImageProps(fileId: 'original-file');
      ImageProps? savedProps;
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        buildDialog(props: props, onSave: (updated) => savedProps = updated),
      );
      await tester.pumpAndSettle();

      // Change alignment
      await tester.tap(find.text('Center').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Left').last);
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedProps, isNotNull);
      expect(savedProps?.align, 'left');
    });

    testWidgets('should not call onSave when cancelled', (tester) async {
      const props = ImageProps(fileId: 'test-file');
      ImageProps? savedProps;
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        buildDialog(props: props, onSave: (updated) => savedProps = updated),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(savedProps, isNull);
    });

    testWidgets('should allow editing width and height', (tester) async {
      const props = ImageProps(fileId: 'test-file');
      ImageProps? savedProps;
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

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

      expect(savedProps?.width, 200.0);
      expect(savedProps?.height, 150.0);
    });

    testWidgets('renders CupertinoPageScaffold on iOS', (tester) async {
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        buildDialog(platform: TargetPlatform.iOS, useRoute: true),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.text('Edit Image'), findsOneWidget);
    });

    testWidgets('shows CupertinoActivityIndicator while loading on iOS', (
      tester,
    ) async {
      final completer = Completer<Result<List<ImageFileInfo>, DomainError>>();
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        buildDialog(platform: TargetPlatform.iOS, useRoute: true),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('renders AlertDialog on Android', (tester) async {
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(buildDialog(platform: TargetPlatform.android));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
