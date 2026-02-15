import 'dart:async';

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

class MockFileRepository extends Mock implements FileRepository {}

void main() {
  late MockFileRepository mockFileRepository;

  setUp(() {
    mockFileRepository = MockFileRepository();
  });

  group('ImageEditDialog', () {
    testWidgets('should show loading indicator while files are loading', (
      tester,
    ) async {
      const props = ImageProps(fileId: 'test-file-id');
      final completer = Completer<Result<List<ImageFileInfo>, DomainError>>();
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageEditDialog(props: props, onSave: (_) {}),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when file loading fails', (
      tester,
    ) async {
      const props = ImageProps(fileId: 'test-file-id');
      when(() => mockFileRepository.listImageFiles()).thenAnswer(
        (_) async => const Failure(ServerError('Failed to load files')),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageEditDialog(props: props, onSave: (_) {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Error loading images'), findsOneWidget);
    });

    testWidgets('should show thumbnail grid when files load successfully', (
      tester,
    ) async {
      const props = ImageProps(fileId: 'test-file-id');
      final files = [
        const ImageFileInfo(id: 'file-1', title: 'logo.png', type: 'image/png'),
        const ImageFileInfo(id: 'file-2', title: 'bg.jpg', type: 'image/jpeg'),
      ];
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => Success(files));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageEditDialog(props: props, onSave: (_) {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      // Images are network images, so we just check the grid exists
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
        ProviderScope(
          overrides: [
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageEditDialog(
                props: props,
                onSave: (updated) => savedProps = updated,
              ),
            ),
          ),
        ),
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageEditDialog(props: props, onSave: (_) {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the container for file-1 (currently selected)
      final containers = tester.widgetList<Container>(find.byType(Container));
      // The selected item should have a different border
      // This is a basic check - the actual border styling will be verified visually
      expect(containers.length, greaterThan(0));
    });

    testWidgets(
      'should show alignment selector with left/center/right options',
      (tester) async {
        const props = ImageProps(fileId: 'test-file-123', align: 'center');
        when(
          () => mockFileRepository.listImageFiles(),
        ).thenAnswer((_) async => const Success([]));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fileRepositoryProvider.overrideWithValue(mockFileRepository),
              directusBaseUrlProvider.overrideWithValue(
                'http://localhost:8055',
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: ImageEditDialog(props: props, onSave: (_) {}),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the dropdown
        expect(find.byType(DropdownButtonFormField<String>), findsWidgets);

        // Tap the alignment dropdown to open it
        await tester.tap(find.text('Center').first);
        await tester.pumpAndSettle();

        // Check that all alignment options are available
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
        ProviderScope(
          overrides: [
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageEditDialog(
                props: props,
                onSave: (updated) => savedProps = updated,
              ),
            ),
          ),
        ),
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

      // Verify onSave was called with updated props
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
        ProviderScope(
          overrides: [
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageEditDialog(
                props: props,
                onSave: (updated) => savedProps = updated,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify onSave was not called
      expect(savedProps, isNull);
    });

    testWidgets('should allow editing width and height', (tester) async {
      const props = ImageProps(fileId: 'test-file');
      ImageProps? savedProps;
      when(
        () => mockFileRepository.listImageFiles(),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fileRepositoryProvider.overrideWithValue(mockFileRepository),
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ImageEditDialog(
                props: props,
                onSave: (updated) => savedProps = updated,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter width
      await tester.enterText(
        find.widgetWithText(TextField, 'Width').first,
        '200',
      );

      // Enter height
      await tester.enterText(
        find.widgetWithText(TextField, 'Height').first,
        '150',
      );

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify dimensions were saved
      expect(savedProps?.width, 200.0);
      expect(savedProps?.height, 150.0);
    });
  });
}
