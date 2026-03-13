import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_helper.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_mixin.dart';

class MockWidgetRepository extends Mock implements WidgetRepository {}

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  TestCrudState createState() => TestCrudState();
}

/// Concrete test class using the mixin
class TestCrudState extends State<TestWidget> with EditorWidgetCrudMixin {
  @override
  late EditorWidgetCrudHelper crudHelper;

  int reloadCount = 0;

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  late MockWidgetRepository mockWidgetRepo;
  late WidgetRegistry registry;

  setUp(() {
    mockWidgetRepo = MockWidgetRepository();
    registry = WidgetRegistry();

    registerFallbackValue(
      const CreateWidgetInput(
        columnId: 0,
        type: '',
        version: '',
        index: 0,
        props: {},
      ),
    );
    registerFallbackValue(const UpdateWidgetInput(id: 0));
  });

  group('EditorWidgetCrudMixin', () {
    testWidgets('handleWidgetUpdate delegates to crudHelper', (tester) async {
      when(() => mockWidgetRepo.update(any())).thenAnswer(
        (_) async => const Success(
          WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'text',
            version: '1.0',
            index: 0,
            props: {'text': 'updated'},
          ),
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final state = tester.state<TestCrudState>(find.byType(TestWidget));

      state.crudHelper = EditorWidgetCrudHelper(
        widgetRepository: mockWidgetRepo,
        widgetRegistry: registry,
        onReload: () async {
          state.reloadCount++;
        },
        isTemplate: false,
      );

      await state.handleWidgetUpdate(1, {'text': 'updated'});

      verify(() => mockWidgetRepo.update(any())).called(1);
      expect(state.reloadCount, 1);
    });

    testWidgets('performWidgetDelete delegates to crudHelper', (tester) async {
      when(
        () => mockWidgetRepo.delete(1),
      ).thenAnswer((_) async => const Success(null));

      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final state = tester.state<TestCrudState>(find.byType(TestWidget));

      state.crudHelper = EditorWidgetCrudHelper(
        widgetRepository: mockWidgetRepo,
        widgetRegistry: registry,
        onReload: () async {
          state.reloadCount++;
        },
        isTemplate: false,
      );

      await state.performWidgetDelete(1);

      verify(() => mockWidgetRepo.delete(1)).called(1);
      expect(state.reloadCount, 1);
    });

    testWidgets('handleWidgetMoveToIndex delegates to crudHelper', (
      tester,
    ) async {
      const widgetInstance = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'text',
        version: '1.0',
        index: 0,
        props: {},
      );

      when(
        () => mockWidgetRepo.moveTo(1, 2, 0),
      ).thenAnswer((_) async => const Success(null));

      await tester.pumpWidget(const MaterialApp(home: TestWidget()));
      final state = tester.state<TestCrudState>(find.byType(TestWidget));

      state.crudHelper = EditorWidgetCrudHelper(
        widgetRepository: mockWidgetRepo,
        widgetRegistry: registry,
        onReload: () async {
          state.reloadCount++;
        },
        isTemplate: false,
      );

      await state.handleWidgetMoveToIndex(widgetInstance, 1, 2, 0);

      verify(() => mockWidgetRepo.moveTo(1, 2, 0)).called(1);
      expect(state.reloadCount, 1);
    });
  });
}
