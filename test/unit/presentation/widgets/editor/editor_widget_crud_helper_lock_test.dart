import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_widget_crud_helper.dart';

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockWidgetRegistry extends Mock implements WidgetRegistry {}

void main() {
  late MockWidgetRepository mockWidgetRepository;
  late MockWidgetRegistry mockWidgetRegistry;
  late EditorWidgetCrudHelper crudHelper;
  // ignore: unused_local_variable
  late int reloadCount;
  late List<String> messages;

  setUp(() {
    mockWidgetRepository = MockWidgetRepository();
    mockWidgetRegistry = MockWidgetRegistry();
    reloadCount = 0;
    messages = [];

    crudHelper = EditorWidgetCrudHelper(
      widgetRepository: mockWidgetRepository,
      widgetRegistry: mockWidgetRegistry,
      onReload: () async {
        reloadCount++;
      },
      isTemplate: false,
      currentUserId: 'user-123',
      onMessage: (msg, {bool isError = false}) {
        messages.add(msg);
      },
    );
  });

  group('EditorWidgetCrudHelper lock operations', () {
    group('lockWidget', () {
      test('should call lockForEditing on the repository', () async {
        when(
          () => mockWidgetRepository.lockForEditing(42, 'user-123'),
        ).thenAnswer((_) async => const Success(null));

        await crudHelper.lockWidget(42);

        verify(
          () => mockWidgetRepository.lockForEditing(42, 'user-123'),
        ).called(1);
      });

      test('should not lock when currentUserId is null', () async {
        final helperNoUser = EditorWidgetCrudHelper(
          widgetRepository: mockWidgetRepository,
          widgetRegistry: mockWidgetRegistry,
          onReload: () async {},
          isTemplate: false,
        );

        await helperNoUser.lockWidget(42);

        verifyNever(() => mockWidgetRepository.lockForEditing(any(), any()));
      });
    });

    group('unlockWidget', () {
      test('should call unlockEditing on the repository', () async {
        when(
          () => mockWidgetRepository.unlockEditing(42),
        ).thenAnswer((_) async => const Success(null));

        await crudHelper.unlockWidget(42);

        verify(() => mockWidgetRepository.unlockEditing(42)).called(1);
      });
    });
  });
}
