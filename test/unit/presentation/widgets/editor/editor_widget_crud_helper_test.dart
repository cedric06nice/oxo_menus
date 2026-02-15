import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/domain/widgets/text/text_props.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_helper.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockWidgetRegistry extends Mock implements WidgetRegistry {}

class MockWidgetDefinition extends Mock
    implements WidgetDefinition<TextProps> {}

void main() {
  group('EditorWidgetCrudHelper', () {
    late MockWidgetRepository mockRepository;
    late MockWidgetRegistry mockRegistry;
    late bool reloadCalled;
    late List<String> messages;
    late List<bool> messageErrors;
    late EditorWidgetCrudHelper helper;

    setUp(() {
      mockRepository = MockWidgetRepository();
      mockRegistry = MockWidgetRegistry();
      reloadCalled = false;
      messages = [];
      messageErrors = [];

      helper = EditorWidgetCrudHelper(
        widgetRepository: mockRepository,
        widgetRegistry: mockRegistry,
        onReload: () async {
          reloadCalled = true;
        },
        isTemplate: false,
        onMessage: (message, {bool isError = false}) {
          messages.add(message);
          messageErrors.add(isError);
        },
      );

      // Register fallback values for mocktail
      registerFallbackValue(
        CreateWidgetInput(
          columnId: 0,
          type: '',
          version: '',
          index: 0,
          props: {},
        ),
      );
      registerFallbackValue(UpdateWidgetInput(id: 0, props: {}));
    });

    group('handleWidgetDropAtIndex', () {
      final mockWidget = WidgetInstance(
        id: 1,
        columnId: 5,
        type: 'text',
        version: '1.0.0',
        index: 2,
        props: {},
        isTemplate: false,
      );

      test('creates widget with isTemplate: false for menu mode', () async {
        when(
          () => mockRegistry.getDefinition('text'),
        ).thenReturn(textWidgetDefinition);
        when(
          () => mockRepository.create(any()),
        ).thenAnswer((_) async => Success(mockWidget));

        await helper.handleWidgetDropAtIndex('text', 5, 2);

        final captured = verify(
          () => mockRepository.create(captureAny()),
        ).captured;
        final input = captured.first as CreateWidgetInput;
        expect(input.columnId, 5);
        expect(input.type, 'text');
        expect(input.index, 2);
        expect(input.isTemplate, false);
        expect(reloadCalled, true);
      });

      test('creates widget with isTemplate: true for admin mode', () async {
        final adminHelper = EditorWidgetCrudHelper(
          widgetRepository: mockRepository,
          widgetRegistry: mockRegistry,
          onReload: () async {
            reloadCalled = true;
          },
          isTemplate: true,
        );

        when(
          () => mockRegistry.getDefinition('text'),
        ).thenReturn(textWidgetDefinition);
        when(
          () => mockRepository.create(any()),
        ).thenAnswer((_) async => Success(mockWidget));

        await adminHelper.handleWidgetDropAtIndex('text', 5, 2);

        final captured = verify(
          () => mockRepository.create(captureAny()),
        ).captured;
        final input = captured.first as CreateWidgetInput;
        expect(input.isTemplate, true);
      });

      test('shows error message for unknown widget type', () async {
        when(() => mockRegistry.getDefinition('unknown')).thenReturn(null);

        await helper.handleWidgetDropAtIndex('unknown', 5, 2);

        expect(messages, ['Unknown widget type: unknown']);
        expect(messageErrors, [true]);
        expect(reloadCalled, false);
        verifyNever(() => mockRepository.create(any()));
      });

      test('shows error message when create fails', () async {
        when(
          () => mockRegistry.getDefinition('text'),
        ).thenReturn(textWidgetDefinition);
        when(
          () => mockRepository.create(any()),
        ).thenAnswer((_) async => Failure(ServerError('Creation failed')));

        await helper.handleWidgetDropAtIndex('text', 5, 2);

        expect(messages, ['Failed to create widget: Creation failed']);
        expect(messageErrors, [true]);
        expect(reloadCalled, false);
      });

      test('shows error message when exception is thrown', () async {
        when(
          () => mockRegistry.getDefinition('text'),
        ).thenReturn(textWidgetDefinition);
        when(
          () => mockRepository.create(any()),
        ).thenThrow(Exception('Network error'));

        await helper.handleWidgetDropAtIndex('text', 5, 2);

        expect(messages.first, contains('Error creating widget'));
        expect(messageErrors, [true]);
        expect(reloadCalled, false);
      });
    });

    group('handleWidgetUpdate', () {
      final mockWidget = WidgetInstance(
        id: 42,
        columnId: 1,
        type: 'text',
        version: '1.0.0',
        index: 0,
        props: {'content': 'Updated'},
        isTemplate: false,
      );

      test('updates widget and calls onReload on success', () async {
        when(
          () => mockRepository.update(any()),
        ).thenAnswer((_) async => Success(mockWidget));

        await helper.handleWidgetUpdate(42, {'content': 'Updated'});

        final captured = verify(
          () => mockRepository.update(captureAny()),
        ).captured;
        final input = captured.first as UpdateWidgetInput;
        expect(input.id, 42);
        expect(input.props, {'content': 'Updated'});
        expect(reloadCalled, true);
      });

      test('does not call onReload on failure', () async {
        when(
          () => mockRepository.update(any()),
        ).thenAnswer((_) async => Failure(ServerError('Update failed')));

        await helper.handleWidgetUpdate(42, {'content': 'Updated'});

        expect(reloadCalled, false);
      });
    });

    group('performWidgetDelete', () {
      test('deletes widget and calls onReload on success', () async {
        when(
          () => mockRepository.delete(42),
        ).thenAnswer((_) async => const Success(null));

        await helper.performWidgetDelete(42);

        verify(() => mockRepository.delete(42)).called(1);
        expect(reloadCalled, true);
        expect(messages, isEmpty);
      });

      test('shows error message on failure', () async {
        when(
          () => mockRepository.delete(42),
        ).thenAnswer((_) async => Failure(ServerError('Delete failed')));

        await helper.performWidgetDelete(42);

        expect(messages, ['Failed to delete widget: Delete failed']);
        expect(messageErrors, [true]);
        expect(reloadCalled, false);
      });
    });

    group('handleWidgetMoveToIndex - same column', () {
      final widget = WidgetInstance(
        id: 10,
        columnId: 5,
        type: 'text',
        version: '1.0.0',
        index: 2,
        props: {},
        isTemplate: false,
      );

      test('adjusts index when moving down and calls reorder', () async {
        when(
          () => mockRepository.reorder(10, any()),
        ).thenAnswer((_) async => const Success(null));

        // Moving from index 2 to index 4 (down)
        await helper.handleWidgetMoveToIndex(widget, 5, 5, 4);

        // Should adjust to index 3 (4 - 1)
        verify(() => mockRepository.reorder(10, 3)).called(1);
        expect(reloadCalled, true);
      });

      test('does not adjust index when moving up and calls reorder', () async {
        when(
          () => mockRepository.reorder(10, any()),
        ).thenAnswer((_) async => const Success(null));

        // Moving from index 2 to index 0 (up)
        await helper.handleWidgetMoveToIndex(widget, 5, 5, 0);

        // Should not adjust (targetIndex <= widget.index)
        verify(() => mockRepository.reorder(10, 0)).called(1);
        expect(reloadCalled, true);
      });

      test('shows error message when reorder fails', () async {
        when(
          () => mockRepository.reorder(10, any()),
        ).thenAnswer((_) async => Failure(ServerError('Reorder failed')));

        await helper.handleWidgetMoveToIndex(widget, 5, 5, 0);

        expect(messages, ['Failed to reorder widget: Reorder failed']);
        expect(messageErrors, [true]);
        expect(reloadCalled, false);
      });
    });

    group('handleWidgetMoveToIndex - different column', () {
      final widget = WidgetInstance(
        id: 10,
        columnId: 5,
        type: 'text',
        version: '1.0.0',
        index: 2,
        props: {},
        isTemplate: false,
      );

      test('calls moveTo for cross-column move', () async {
        when(
          () => mockRepository.moveTo(10, 6, 1),
        ).thenAnswer((_) async => const Success(null));

        await helper.handleWidgetMoveToIndex(widget, 5, 6, 1);

        verify(() => mockRepository.moveTo(10, 6, 1)).called(1);
        expect(reloadCalled, true);
      });

      test('shows error message when moveTo fails', () async {
        when(
          () => mockRepository.moveTo(10, 6, 1),
        ).thenAnswer((_) async => Failure(ServerError('Move failed')));

        await helper.handleWidgetMoveToIndex(widget, 5, 6, 1);

        expect(messages, ['Failed to move widget: Move failed']);
        expect(messageErrors, [true]);
        expect(reloadCalled, false);
      });

      test('shows error message when exception is thrown', () async {
        when(
          () => mockRepository.moveTo(10, 6, 1),
        ).thenThrow(Exception('Network error'));

        await helper.handleWidgetMoveToIndex(widget, 5, 6, 1);

        expect(messages.first, contains('Error moving widget'));
        expect(messageErrors, [true]);
        expect(reloadCalled, false);
      });
    });
  });
}
