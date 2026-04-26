import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/presentation/pages/admin_template_editor/admin_template_editor_page.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';
import 'package:oxo_menus/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/presentation/widgets/text_widget/text_widget_definition.dart';

import '../../../fakes/fake_area_repository.dart';
import '../../../fakes/fake_column_repository.dart';
import '../../../fakes/fake_container_repository.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/fake_page_repository.dart';
import '../../../fakes/fake_size_repository.dart';
import '../../../fakes/fake_widget_repository.dart';
import '../../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Fake use cases
// ---------------------------------------------------------------------------

class _FakeReorderContainerUseCase extends ReorderContainerUseCase {
  _FakeReorderContainerUseCase()
    : super(containerRepository: _NullContainerRepository());

  final List<(int, ReorderDirection)> calls = [];
  Result<void, DomainError>? _result;

  void stubResult(Result<void, DomainError> r) {
    _result = r;
  }

  @override
  Future<Result<void, DomainError>> execute(
    int containerId,
    ReorderDirection direction,
  ) async {
    calls.add((containerId, direction));
    if (_result != null) {
      return _result!;
    }
    throw StateError('_FakeReorderContainerUseCase: not stubbed');
  }
}

class _FakeDuplicateContainerUseCase extends DuplicateContainerUseCase {
  _FakeDuplicateContainerUseCase()
    : super(
        containerRepository: _NullContainerRepository(),
        columnRepository: _NullColumnRepository(),
        widgetRepository: _NullWidgetRepository(),
      );

  final List<int> calls = [];
  Result<entity.Container, DomainError>? _result;

  void stubResult(Result<entity.Container, DomainError> r) {
    _result = r;
  }

  @override
  Future<Result<entity.Container, DomainError>> execute(int containerId) async {
    calls.add(containerId);
    if (_result != null) {
      return _result!;
    }
    throw StateError('_FakeDuplicateContainerUseCase: not stubbed');
  }
}

// ---------------------------------------------------------------------------
// Minimal null repositories (satisfy super constructors; never called)
// ---------------------------------------------------------------------------

class _NullContainerRepository implements ContainerRepository {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('_NullContainerRepository should not be called');
}

class _NullColumnRepository implements ColumnRepository {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('_NullColumnRepository should not be called');
}

class _NullWidgetRepository implements WidgetRepository {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('_NullWidgetRepository should not be called');
}

// ---------------------------------------------------------------------------
// GoRouter fake for navigation capture
// ---------------------------------------------------------------------------

class _FakeGoRouter extends GoRouter {
  _FakeGoRouter()
    : super.routingConfig(
        routingConfig: ValueNotifier(
          RoutingConfig(
            routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())],
          ),
        ),
      );

  final List<String> pushedRoutes = [];

  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) async {
    pushedRoutes.add(location);
    return null;
  }
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _menuId = 1;

const _testMenu = Menu(
  id: _menuId,
  name: 'Test Template',
  status: Status.draft,
  version: '1.0',
);

const _testPages = [
  entity.Page(
    id: 10,
    menuId: _menuId,
    name: 'Page 1',
    index: 0,
    type: entity.PageType.content,
  ),
];

const _container1 = entity.Container(id: 20, pageId: 10, index: 0);
const _container2 = entity.Container(id: 21, pageId: 10, index: 1);

const _testColumns = [entity.Column(id: 30, containerId: 20, index: 0)];
const _testColumns2 = [entity.Column(id: 31, containerId: 21, index: 0)];

const _sampleWidgets = [
  WidgetInstance(
    id: 40,
    columnId: 30,
    type: 'text',
    version: '1.0',
    index: 0,
    props: {'text': 'Hello'},
  ),
];

const _testUser = User(
  id: 'admin-1',
  email: 'admin@example.com',
  firstName: 'Admin',
  lastName: 'User',
  role: UserRole.admin,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeMenuRepository fakeMenuRepo;
  late FakePageRepository fakePageRepo;
  late FakeContainerRepository fakeContainerRepo;
  late FakeColumnRepository fakeColumnRepo;
  late FakeWidgetRepository fakeWidgetRepo;
  late FakeSizeRepository fakeSizeRepo;
  late FakeAreaRepository fakeAreaRepo;
  late _FakeGoRouter fakeRouter;
  late _FakeReorderContainerUseCase fakeReorderUseCase;
  late _FakeDuplicateContainerUseCase fakeDuplicateUseCase;
  late PresentableWidgetRegistry registry;

  setUp(() {
    fakeMenuRepo = FakeMenuRepository();
    fakePageRepo = FakePageRepository();
    fakeContainerRepo = FakeContainerRepository();
    fakeColumnRepo = FakeColumnRepository();
    fakeWidgetRepo = FakeWidgetRepository();
    fakeSizeRepo = FakeSizeRepository();
    fakeAreaRepo = FakeAreaRepository();
    fakeRouter = _FakeGoRouter();
    fakeReorderUseCase = _FakeReorderContainerUseCase();
    fakeDuplicateUseCase = _FakeDuplicateContainerUseCase();

    registry = PresentableWidgetRegistry();
    registry.register(textWidgetDefinition);

    // Stub the full tree load
    fakeMenuRepo.whenGetById(success(_testMenu));
    fakePageRepo.whenGetAllForMenu(success(_testPages));
    fakeContainerRepo.whenGetAllForPage(success([_container1, _container2]));
    fakeContainerRepo.whenGetAllForContainer(success(<entity.Container>[]));
    fakeColumnRepo.whenGetAllForContainerForId(20, success(_testColumns));
    fakeColumnRepo.whenGetAllForContainerForId(21, success(_testColumns2));
    fakeWidgetRepo.whenGetAllForColumn(success(<WidgetInstance>[]));
    // Override column 30 to return sample widgets
    fakeWidgetRepo.whenGetAllForColumnForId(30, success(_sampleWidgets));
  });

  Widget buildPage() {
    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
        pageRepositoryProvider.overrideWithValue(fakePageRepo),
        containerRepositoryProvider.overrideWithValue(fakeContainerRepo),
        columnRepositoryProvider.overrideWithValue(fakeColumnRepo),
        widgetRepositoryProvider.overrideWithValue(fakeWidgetRepo),
        sizeRepositoryProvider.overrideWithValue(fakeSizeRepo),
        areaRepositoryProvider.overrideWithValue(fakeAreaRepo),
        widgetRegistryProvider.overrideWithValue(registry),
        currentUserProvider.overrideWithValue(_testUser),
        reorderContainerUseCaseProvider.overrideWithValue(fakeReorderUseCase),
        duplicateContainerUseCaseProvider.overrideWithValue(
          fakeDuplicateUseCase,
        ),
      ],
      child: MaterialApp(
        home: InheritedGoRouter(
          goRouter: fakeRouter,
          child: const AdminTemplateEditorPage(menuId: _menuId),
        ),
      ),
    );
  }

  group('Container action buttons in AdminTemplateEditorPage', () {
    testWidgets(
      'should show reorder and duplicate buttons on every container',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byKey(const Key('container_move_up_20')), findsOneWidget);
        expect(find.byKey(const Key('container_move_down_20')), findsOneWidget);
        expect(find.byKey(const Key('container_duplicate_20')), findsOneWidget);
        expect(find.byKey(const Key('container_move_up_21')), findsOneWidget);
        expect(find.byKey(const Key('container_move_down_21')), findsOneWidget);
        expect(find.byKey(const Key('container_duplicate_21')), findsOneWidget);
      },
    );

    testWidgets(
      'should disable the up arrow when container is first in the list',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Assert
        final upButton = tester.widget<IconButton>(
          find.byKey(const Key('container_move_up_20')),
        );
        expect(upButton.onPressed, isNull);
      },
    );

    testWidgets(
      'should disable the down arrow when container is last in the list',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Assert
        final downButton = tester.widget<IconButton>(
          find.byKey(const Key('container_move_down_21')),
        );
        expect(downButton.onPressed, isNull);
      },
    );

    testWidgets(
      'should call reorderContainer with up direction when up arrow is tapped',
      (tester) async {
        // Arrange
        fakeReorderUseCase.stubResult(success(null));
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Act
        await tester.ensureVisible(
          find.byKey(const Key('container_move_up_21')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('container_move_up_21')));
        await tester.pumpAndSettle();

        // Assert
        expect(fakeReorderUseCase.calls.length, equals(1));
        expect(
          fakeReorderUseCase.calls.last,
          equals((21, ReorderDirection.up)),
        );
      },
    );

    testWidgets(
      'should call reorderContainer with down direction when down arrow is tapped',
      (tester) async {
        // Arrange
        fakeReorderUseCase.stubResult(success(null));
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byKey(const Key('container_move_down_20')));
        await tester.pumpAndSettle();

        // Assert
        expect(fakeReorderUseCase.calls.length, equals(1));
        expect(
          fakeReorderUseCase.calls.last,
          equals((20, ReorderDirection.down)),
        );
      },
    );

    testWidgets(
      'should call duplicateContainer with container id when duplicate is tapped',
      (tester) async {
        // Arrange
        fakeDuplicateUseCase.stubResult(
          success(const entity.Container(id: 99, pageId: 10, index: 1)),
        );
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byKey(const Key('container_duplicate_20')));
        await tester.pumpAndSettle();

        // Assert
        expect(fakeDuplicateUseCase.calls.length, equals(1));
        expect(fakeDuplicateUseCase.calls.last, equals(20));
      },
    );
  });
}
