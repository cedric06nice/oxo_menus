import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/area_repository.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/admin_template_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockSizeRepository extends Mock implements SizeRepository {}

class MockAreaRepository extends Mock implements AreaRepository {}

class MockGoRouter extends Mock implements GoRouter {}

class MockReorderContainerUseCase extends Mock
    implements ReorderContainerUseCase {}

class MockDuplicateContainerUseCase extends Mock
    implements DuplicateContainerUseCase {}

void main() {
  late MockMenuRepository mockMenuRepo;
  late MockPageRepository mockPageRepo;
  late MockContainerRepository mockContainerRepo;
  late MockColumnRepository mockColumnRepo;
  late MockWidgetRepository mockWidgetRepo;
  late MockSizeRepository mockSizeRepo;
  late MockAreaRepository mockAreaRepo;
  late MockGoRouter mockRouter;
  late MockReorderContainerUseCase mockReorderUseCase;
  late MockDuplicateContainerUseCase mockDuplicateUseCase;
  late PresentableWidgetRegistry registry;

  const menuId = 1;

  const testMenu = Menu(
    id: menuId,
    name: 'Test Template',
    status: Status.draft,
    version: '1.0',
  );

  const testPages = [
    entity.Page(
      id: 10,
      menuId: menuId,
      name: 'Page 1',
      index: 0,
      type: entity.PageType.content,
    ),
  ];

  const container1 = entity.Container(id: 20, pageId: 10, index: 0);
  const container2 = entity.Container(id: 21, pageId: 10, index: 1);

  const testColumns = [entity.Column(id: 30, containerId: 20, index: 0)];
  const testColumns2 = [entity.Column(id: 31, containerId: 21, index: 0)];

  const sampleWidgets = [
    WidgetInstance(
      id: 40,
      columnId: 30,
      type: 'text',
      version: '1.0',
      index: 0,
      props: {'text': 'Hello'},
    ),
  ];

  setUp(() {
    mockMenuRepo = MockMenuRepository();
    mockPageRepo = MockPageRepository();
    mockContainerRepo = MockContainerRepository();
    mockColumnRepo = MockColumnRepository();
    mockWidgetRepo = MockWidgetRepository();
    mockSizeRepo = MockSizeRepository();
    mockAreaRepo = MockAreaRepository();
    mockRouter = MockGoRouter();
    mockReorderUseCase = MockReorderContainerUseCase();
    mockDuplicateUseCase = MockDuplicateContainerUseCase();

    registry = PresentableWidgetRegistry();
    registry.register(textWidgetDefinition);

    // Stub tree load
    when(
      () => mockMenuRepo.getById(menuId),
    ).thenAnswer((_) async => const Success(testMenu));
    when(
      () => mockPageRepo.getAllForMenu(menuId),
    ).thenAnswer((_) async => const Success(testPages));
    when(
      () => mockContainerRepo.getAllForPage(10),
    ).thenAnswer((_) async => const Success([container1, container2]));
    when(
      () => mockContainerRepo.getAllForContainer(any()),
    ).thenAnswer((_) async => const Success(<entity.Container>[]));
    when(
      () => mockColumnRepo.getAllForContainer(20),
    ).thenAnswer((_) async => const Success(testColumns));
    when(
      () => mockColumnRepo.getAllForContainer(21),
    ).thenAnswer((_) async => const Success(testColumns2));
    when(
      () => mockWidgetRepo.getAllForColumn(30),
    ).thenAnswer((_) async => const Success(sampleWidgets));
    when(
      () => mockWidgetRepo.getAllForColumn(31),
    ).thenAnswer((_) async => const Success(<WidgetInstance>[]));
  });

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(
      const CreateContainerInput(pageId: -1, index: 0, direction: 'row'),
    );
    registerFallbackValue(const UpdateContainerInput(id: -1));
    registerFallbackValue(const CreateColumnInput(containerId: -1, index: 0));
    registerFallbackValue(const UpdateColumnInput(id: -1));
    registerFallbackValue(const UpdateMenuInput(id: -1));
    registerFallbackValue(
      const CreateWidgetInput(
        columnId: -1,
        type: '',
        version: '',
        index: 0,
        props: {},
      ),
    );
    registerFallbackValue(const UpdateWidgetInput(id: -1));
    registerFallbackValue(
      const CreatePageInput(menuId: -1, name: '', index: 0),
    );
    registerFallbackValue(const UpdatePageInput(id: -1));
  });

  Widget createWidgetUnderTest() {
    final user = User(
      id: 'admin-1',
      email: 'admin@example.com',
      firstName: 'Admin',
      lastName: 'User',
      role: UserRole.admin,
    );

    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepo),
        pageRepositoryProvider.overrideWithValue(mockPageRepo),
        containerRepositoryProvider.overrideWithValue(mockContainerRepo),
        columnRepositoryProvider.overrideWithValue(mockColumnRepo),
        widgetRepositoryProvider.overrideWithValue(mockWidgetRepo),
        sizeRepositoryProvider.overrideWithValue(mockSizeRepo),
        areaRepositoryProvider.overrideWithValue(mockAreaRepo),
        widgetRegistryProvider.overrideWithValue(registry),
        currentUserProvider.overrideWithValue(user),
        reorderContainerUseCaseProvider.overrideWithValue(mockReorderUseCase),
        duplicateContainerUseCaseProvider.overrideWithValue(
          mockDuplicateUseCase,
        ),
      ],
      child: MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockRouter,
          child: const AdminTemplateEditorPage(menuId: menuId),
        ),
      ),
    );
  }

  group('Container action buttons in AdminTemplateEditorPage', () {
    testWidgets('shows reorder and duplicate buttons on containers', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('container_move_up_20')), findsOneWidget);
      expect(find.byKey(const Key('container_move_down_20')), findsOneWidget);
      expect(find.byKey(const Key('container_duplicate_20')), findsOneWidget);
      expect(find.byKey(const Key('container_move_up_21')), findsOneWidget);
      expect(find.byKey(const Key('container_move_down_21')), findsOneWidget);
      expect(find.byKey(const Key('container_duplicate_21')), findsOneWidget);
    });

    testWidgets('first container has up arrow disabled', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final upButton = tester.widget<IconButton>(
        find.byKey(const Key('container_move_up_20')),
      );
      expect(upButton.onPressed, isNull);
    });

    testWidgets('last container has down arrow disabled', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final downButton = tester.widget<IconButton>(
        find.byKey(const Key('container_move_down_21')),
      );
      expect(downButton.onPressed, isNull);
    });

    testWidgets('tapping up arrow calls reorderContainer', (tester) async {
      when(
        () => mockReorderUseCase.execute(21, ReorderDirection.up),
      ).thenAnswer((_) async => const Success(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('container_move_up_21')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('container_move_up_21')));
      await tester.pumpAndSettle();

      verify(
        () => mockReorderUseCase.execute(21, ReorderDirection.up),
      ).called(1);
    });

    testWidgets('tapping down arrow calls reorderContainer', (tester) async {
      when(
        () => mockReorderUseCase.execute(20, ReorderDirection.down),
      ).thenAnswer((_) async => const Success(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('container_move_down_20')));
      await tester.pumpAndSettle();

      verify(
        () => mockReorderUseCase.execute(20, ReorderDirection.down),
      ).called(1);
    });

    testWidgets('tapping duplicate calls duplicateContainer', (tester) async {
      when(() => mockDuplicateUseCase.execute(20)).thenAnswer(
        (_) async =>
            const Success(entity.Container(id: 99, pageId: 10, index: 1)),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('container_duplicate_20')));
      await tester.pumpAndSettle();

      verify(() => mockDuplicateUseCase.execute(20)).called(1);
    });
  });
}
