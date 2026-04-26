import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/presentation/pages/menu_list/menu_list_page.dart';
import 'package:oxo_menus/presentation/pages/menu_list/widgets/menu_list_item.dart';
import 'package:oxo_menus/presentation/providers/auth_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

import '../../../fakes/fake_area_repository.dart';
import '../../../fakes/fake_fetch_menu_tree_usecase.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/fake_size_repository.dart';
import '../../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Fake DuplicateMenuUseCase
// ---------------------------------------------------------------------------

class _FakeDuplicateMenuUseCase extends DuplicateMenuUseCase {
  _FakeDuplicateMenuUseCase()
    : super(
        fetchMenuTreeUseCase: FakeFetchMenuTreeUseCase(),
        menuRepository: _NullMenuRepository(),
        pageRepository: _NullPageRepository(),
        containerRepository: _NullContainerRepository(),
        columnRepository: _NullColumnRepository(),
        widgetRepository: _NullWidgetRepository(),
        sizeRepository: _NullSizeRepository(),
      );

  Result<Menu, DomainError>? _result;

  void stubResult(Result<Menu, DomainError> result) {
    _result = result;
  }

  @override
  Future<Result<Menu, DomainError>> execute(int menuId) async {
    if (_result != null) {
      return _result!;
    }
    throw StateError('_FakeDuplicateMenuUseCase: no stub configured');
  }
}

// ---------------------------------------------------------------------------
// Null implementations to satisfy DuplicateMenuUseCase super-constructor
// ---------------------------------------------------------------------------

class _NullMenuRepository implements MenuRepository {
  @override
  Future<Result<Menu, DomainError>> create(CreateMenuInput input) async =>
      throw StateError('not used');
  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
    List<int>? areaIds,
  }) async => throw StateError('not used');
  @override
  Future<Result<Menu, DomainError>> getById(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input) async =>
      throw StateError('not used');
  @override
  Future<Result<void, DomainError>> delete(int id) async =>
      throw StateError('not used');
}

class _NullPageRepository implements PageRepository {
  @override
  Future<Result<entity.Page, DomainError>> create(
    CreatePageInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<List<entity.Page>, DomainError>> getAllForMenu(
    int menuId,
  ) async => throw StateError('not used');
  @override
  Future<Result<entity.Page, DomainError>> getById(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<entity.Page, DomainError>> update(
    UpdatePageInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<void, DomainError>> delete(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<void, DomainError>> reorder(int pageId, int newIndex) async =>
      throw StateError('not used');
}

class _NullContainerRepository implements ContainerRepository {
  @override
  Future<Result<entity.Container, DomainError>> create(
    CreateContainerInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<List<entity.Container>, DomainError>> getAllForPage(
    int pageId,
  ) async => throw StateError('not used');
  @override
  Future<Result<List<entity.Container>, DomainError>> getAllForContainer(
    int containerId,
  ) async => throw StateError('not used');
  @override
  Future<Result<entity.Container, DomainError>> getById(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<entity.Container, DomainError>> update(
    UpdateContainerInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<void, DomainError>> delete(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<void, DomainError>> reorder(
    int containerId,
    int newIndex,
  ) async => throw StateError('not used');
  @override
  Future<Result<void, DomainError>> moveTo(
    int containerId,
    int newPageId,
    int index,
  ) async => throw StateError('not used');
}

class _NullColumnRepository implements ColumnRepository {
  @override
  Future<Result<entity.Column, DomainError>> create(
    CreateColumnInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<List<entity.Column>, DomainError>> getAllForContainer(
    int containerId,
  ) async => throw StateError('not used');
  @override
  Future<Result<entity.Column, DomainError>> getById(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<entity.Column, DomainError>> update(
    UpdateColumnInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<void, DomainError>> delete(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<void, DomainError>> reorder(int columnId, int newIndex) async =>
      throw StateError('not used');
}

class _NullWidgetRepository implements WidgetRepository {
  @override
  Future<Result<WidgetInstance, DomainError>> create(
    CreateWidgetInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<List<WidgetInstance>, DomainError>> getAllForColumn(
    int columnId,
  ) async => throw StateError('not used');
  @override
  Future<Result<WidgetInstance, DomainError>> getById(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<WidgetInstance, DomainError>> update(
    UpdateWidgetInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<void, DomainError>> delete(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<void, DomainError>> reorder(int widgetId, int newIndex) async =>
      throw StateError('not used');
  @override
  Future<Result<void, DomainError>> moveTo(
    int widgetId,
    int newColumnId,
    int index,
  ) async => throw StateError('not used');
  @override
  Future<Result<void, DomainError>> lockForEditing(
    int widgetId,
    String userId,
  ) async => throw StateError('not used');
  @override
  Future<Result<void, DomainError>> unlockEditing(int widgetId) async =>
      throw StateError('not used');
}

class _NullSizeRepository implements SizeRepository {
  @override
  Future<Result<List<domain.Size>, DomainError>> getAll() async =>
      throw StateError('not used');
  @override
  Future<Result<domain.Size, DomainError>> getById(int id) async =>
      throw StateError('not used');
  @override
  Future<Result<domain.Size, DomainError>> create(
    CreateSizeInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<domain.Size, DomainError>> update(
    UpdateSizeInput input,
  ) async => throw StateError('not used');
  @override
  Future<Result<void, DomainError>> delete(int id) async =>
      throw StateError('not used');
}

// ---------------------------------------------------------------------------
// Fake GoRouter that records push() calls
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
// Slow menu repository for loading-indicator tests
// ---------------------------------------------------------------------------

/// A [FakeMenuRepository] whose [listAll] never completes, keeping the page
/// in its loading state so tests can assert on loading indicators.
class _NeverMenuRepository extends FakeMenuRepository {
  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
    List<int>? areaIds,
  }) async {
    calls.add(MenuListAllCall(onlyPublished: onlyPublished, areaIds: areaIds));
    return Completer<Result<List<Menu>, DomainError>>().future;
  }
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _adminUser = User(
  id: 'user-1',
  email: 'test@example.com',
  firstName: 'Test',
  lastName: 'User',
  role: UserRole.admin,
);

const _regularUser = User(
  id: 'user-1',
  email: 'test@example.com',
  firstName: 'Test',
  lastName: 'User',
  role: UserRole.user,
  areas: [Area(id: 1, name: 'Dining')],
);

const _sampleSize = domain.Size(
  id: 1,
  name: 'A4',
  width: 210,
  height: 297,
  status: Status.published,
  direction: 'portrait',
);

const _sampleArea = Area(id: 1, name: 'Dining');

void main() {
  late FakeMenuRepository fakeMenuRepo;
  late FakeSizeRepository fakeSizeRepo;
  late FakeAreaRepository fakeAreaRepo;
  late _FakeDuplicateMenuUseCase fakeDuplicateUseCase;
  late _FakeGoRouter fakeRouter;

  setUp(() {
    fakeMenuRepo = FakeMenuRepository();
    fakeSizeRepo = FakeSizeRepository();
    fakeAreaRepo = FakeAreaRepository();
    fakeDuplicateUseCase = _FakeDuplicateMenuUseCase();
    fakeRouter = _FakeGoRouter();

    fakeAreaRepo.whenGetAll(success([_sampleArea]));
    fakeSizeRepo.whenGetAll(success([_sampleSize]));
  });

  Widget createWidgetUnderTest({
    bool isAdmin = false,
    TargetPlatform platform = TargetPlatform.android,
    User? user,
  }) {
    final resolvedUser = user ?? (isAdmin ? _adminUser : _regularUser);

    return ProviderScope(
      overrides: [
        menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
        sizeRepositoryProvider.overrideWithValue(fakeSizeRepo),
        areaRepositoryProvider.overrideWithValue(fakeAreaRepo),
        duplicateMenuUseCaseProvider.overrideWithValue(fakeDuplicateUseCase),
        isAdminProvider.overrideWithValue(isAdmin),
        currentUserProvider.overrideWithValue(resolvedUser),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        home: InheritedGoRouter(
          goRouter: fakeRouter,
          child: const MenuListPage(),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Initial State
  // --------------------------------------------------------------------------

  group('MenuListPage - Initial State', () {
    testWidgets('should show loading indicator initially on Material', (
      tester,
    ) async {
      // Arrange — use a never-completing repo to keep the page in loading state
      final neverRepo = _NeverMenuRepository();

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            menuRepositoryProvider.overrideWithValue(neverRepo),
            sizeRepositoryProvider.overrideWithValue(fakeSizeRepo),
            areaRepositoryProvider.overrideWithValue(fakeAreaRepo),
            duplicateMenuUseCaseProvider.overrideWithValue(
              fakeDuplicateUseCase,
            ),
            isAdminProvider.overrideWithValue(false),
            currentUserProvider.overrideWithValue(_regularUser),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: InheritedGoRouter(
              goRouter: fakeRouter,
              child: const MenuListPage(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show CupertinoActivityIndicator on Apple', (
      tester,
    ) async {
      // Arrange — use a never-completing repo to keep the page in loading state
      final neverRepo = _NeverMenuRepository();

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            menuRepositoryProvider.overrideWithValue(neverRepo),
            sizeRepositoryProvider.overrideWithValue(fakeSizeRepo),
            areaRepositoryProvider.overrideWithValue(fakeAreaRepo),
            duplicateMenuUseCaseProvider.overrideWithValue(
              fakeDuplicateUseCase,
            ),
            isAdminProvider.overrideWithValue(false),
            currentUserProvider.overrideWithValue(_regularUser),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: InheritedGoRouter(
              goRouter: fakeRouter,
              child: const MenuListPage(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.widgetWithText(AppBar, 'Menus'), findsOneWidget);
    });

    testWidgets('should show Material add button for admin on Android', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(isAdmin: true, platform: TargetPlatform.android),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show Cupertino add button for admin on iOS', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(isAdmin: true, platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
    });

    testWidgets('should not show add button for regular users', (tester) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(CupertinoIcons.add), findsNothing);
    });
  });

  // --------------------------------------------------------------------------
  // Empty State
  // --------------------------------------------------------------------------

  group('MenuListPage - Empty State', () {
    testWidgets('should show themed empty state with icon on Material', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      expect(find.text('No menus found'), findsOneWidget);
      expect(
        find.text('Browse available menus or check back later'),
        findsOneWidget,
      );
    });

    testWidgets('should show themed empty state with icon on Apple', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(CupertinoIcons.doc_text), findsOneWidget);
      expect(find.text('No menus found'), findsOneWidget);
    });

    testWidgets('should not show menu list when empty', (tester) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MenuListItem), findsNothing);
    });
  });

  // --------------------------------------------------------------------------
  // Menu List Display
  // --------------------------------------------------------------------------

  group('MenuListPage - Menu List Display', () {
    testWidgets('should display menus in a full-width list', (tester) async {
      // Arrange
      const menus = [
        Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
        Menu(
          id: 2,
          name: 'Winter Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];
      fakeMenuRepo.whenListAll(success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Summer Menu'), findsOneWidget);
      expect(find.text('Winter Menu'), findsOneWidget);
      expect(find.byType(MenuListItem), findsNWidgets(2));
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('should load only published menus for regular users', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      // Assert
      final listAllCalls = fakeMenuRepo.listAllCalls;
      expect(listAllCalls, isNotEmpty);
      expect(listAllCalls.last.onlyPublished, isTrue);
    });

    testWidgets('should load all menus for admin users', (tester) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Assert
      final listAllCalls = fakeMenuRepo.listAllCalls;
      expect(listAllCalls, isNotEmpty);
      expect(listAllCalls.last.onlyPublished, isFalse);
    });
  });

  // --------------------------------------------------------------------------
  // Error Handling
  // --------------------------------------------------------------------------

  group('MenuListPage - Error Handling', () {
    testWidgets('should show themed error state with retry on Material', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenListAll(failure(const NetworkError('Network error')));

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.android),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error: Network error'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show themed error state with retry on Apple', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenListAll(failure(const NetworkError('Network error')));

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.byIcon(CupertinoIcons.exclamationmark_triangle),
        findsOneWidget,
      );
      expect(find.text('Error: Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should retry on button press', (tester) async {
      // Arrange
      fakeMenuRepo.whenListAll(failure(const NetworkError('Network error')));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final callsBefore = fakeMenuRepo.listAllCalls.length;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Assert — loadMenus called initially + retry
      expect(fakeMenuRepo.listAllCalls.length, greaterThan(callsBefore));
    });
  });

  // --------------------------------------------------------------------------
  // Navigation
  // --------------------------------------------------------------------------

  group('MenuListPage - Navigation', () {
    testWidgets('should navigate to menu editor when menu is tapped', (
      tester,
    ) async {
      // Arrange
      const menus = [
        Menu(
          id: 123,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];
      fakeMenuRepo.whenListAll(success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Summer Menu'));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeRouter.pushedRoutes, contains('/menus/123'));
    });

    testWidgets('should open create template dialog when add button tapped', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Assert — TemplateCreateDialog is shown
      expect(find.text('Create Template'), findsOneWidget);
    });
  });

  // --------------------------------------------------------------------------
  // Delete Menu (Admin)
  // --------------------------------------------------------------------------

  group('MenuListPage - Delete Menu (Admin)', () {
    testWidgets('should show delete button for admin users', (tester) async {
      // Arrange
      const menus = [
        Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];
      fakeMenuRepo.whenListAll(success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should not show delete button for regular users', (
      tester,
    ) async {
      // Arrange
      const menus = [
        Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];
      fakeMenuRepo.whenListAll(success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets(
      'should show AlertDialog confirmation on Material when delete tapped',
      (tester) async {
        // Arrange
        const menus = [
          Menu(
            id: 1,
            name: 'Summer Menu',
            status: Status.published,
            version: '1.0.0',
          ),
        ];
        fakeMenuRepo.whenListAll(success(menus));

        // Act
        await tester.pumpWidget(
          createWidgetUnderTest(
            isAdmin: true,
            platform: TargetPlatform.android,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Delete Menu'), findsOneWidget);
        expect(
          find.text('Are you sure you want to delete "Summer Menu"?'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should show CupertinoAlertDialog on Apple when delete tapped',
      (tester) async {
        // Arrange
        const menus = [
          Menu(
            id: 1,
            name: 'Summer Menu',
            status: Status.published,
            version: '1.0.0',
          ),
        ];
        fakeMenuRepo.whenListAll(success(menus));

        // Act
        await tester.pumpWidget(
          createWidgetUnderTest(isAdmin: true, platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(CupertinoIcons.delete));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text('Delete Menu'), findsOneWidget);
      },
    );

    testWidgets('should delete menu when confirmed', (tester) async {
      // Arrange
      const menus = [
        Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];
      fakeMenuRepo.whenListAll(success(menus));
      fakeMenuRepo.whenDelete(success(null));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMenuRepo.deleteCalls, hasLength(1));
      expect(fakeMenuRepo.deleteCalls.single.id, equals(1));
      expect(find.text('Summer Menu'), findsNothing);
    });

    testWidgets('should not delete menu when cancelled', (tester) async {
      // Arrange
      const menus = [
        Menu(
          id: 1,
          name: 'Summer Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];
      fakeMenuRepo.whenListAll(success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMenuRepo.deleteCalls, isEmpty);
      expect(find.text('Summer Menu'), findsOneWidget);
    });
  });

  // --------------------------------------------------------------------------
  // Pull to Refresh
  // --------------------------------------------------------------------------

  group('MenuListPage - Pull to Refresh', () {
    testWidgets('should support pull to refresh', (tester) async {
      // Arrange
      const menus = [
        Menu(
          id: 1,
          name: 'Test Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];
      fakeMenuRepo.whenListAll(success(menus));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final callsBefore = fakeMenuRepo.listAllCalls.length;

      // Act
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMenuRepo.listAllCalls.length, greaterThan(callsBefore));
    });
  });

  // --------------------------------------------------------------------------
  // Status Filters
  // --------------------------------------------------------------------------

  group('MenuListPage - Status Filters', () {
    testWidgets('should show status filter chips for admin', (tester) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ChoiceChip), findsNWidgets(4));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
    });

    testWidgets('should not show status filter chips for regular users', (
      tester,
    ) async {
      // Arrange
      fakeMenuRepo.whenListAll(success(<Menu>[]));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ChoiceChip), findsNothing);
    });

    testWidgets('should filter menus by status when chip is tapped', (
      tester,
    ) async {
      // Arrange
      const menus = [
        Menu(
          id: 1,
          name: 'Published Menu',
          status: Status.published,
          version: '1.0.0',
        ),
        Menu(id: 2, name: 'Draft Menu', status: Status.draft, version: '1.0.0'),
      ];
      fakeMenuRepo.whenListAll(success(menus));

      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      expect(find.text('Published Menu'), findsOneWidget);
      expect(find.text('Draft Menu'), findsOneWidget);

      // Act
      await tester.tap(find.text('Draft'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Draft Menu'), findsOneWidget);
      expect(find.text('Published Menu'), findsNothing);
    });

    testWidgets(
      'should show all menus when All chip is tapped after filtering',
      (tester) async {
        // Arrange
        const menus = [
          Menu(
            id: 1,
            name: 'Published Menu',
            status: Status.published,
            version: '1.0.0',
          ),
          Menu(
            id: 2,
            name: 'Draft Menu',
            status: Status.draft,
            version: '1.0.0',
          ),
        ];
        fakeMenuRepo.whenListAll(success(menus));

        await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Draft'));
        await tester.pumpAndSettle();
        expect(find.text('Published Menu'), findsNothing);

        // Act
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Published Menu'), findsOneWidget);
        expect(find.text('Draft Menu'), findsOneWidget);
      },
    );
  });

  // --------------------------------------------------------------------------
  // Area Grouping
  // --------------------------------------------------------------------------

  group('MenuListPage - Area Grouping', () {
    testWidgets('should group menus by area with section headers', (
      tester,
    ) async {
      // Arrange
      const menus = [
        Menu(
          id: 1,
          name: 'Dining Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
        Menu(
          id: 2,
          name: 'Bar Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 2, name: 'Bar'),
        ),
        Menu(
          id: 3,
          name: 'Unassigned Menu',
          status: Status.published,
          version: '1.0.0',
        ),
      ];
      fakeMenuRepo.whenListAll(success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dining'), findsOneWidget);
      expect(find.text('Bar'), findsOneWidget);
      expect(find.text('Unassigned'), findsOneWidget);
    });

    testWidgets('should pass area IDs to repository for non-admin users', (
      tester,
    ) async {
      // Arrange
      const filteredMenus = [
        Menu(
          id: 1,
          name: 'Dining Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];
      fakeMenuRepo.whenListAll(success(filteredMenus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: false));
      await tester.pumpAndSettle();

      // Assert — area IDs passed to repository
      final calls = fakeMenuRepo.listAllCalls;
      expect(calls, isNotEmpty);
      expect(calls.last.areaIds, equals([1]));
      expect(find.text('Dining Menu'), findsOneWidget);
    });

    testWidgets('should not load menus when user is null and not admin', (
      tester,
    ) async {
      // Arrange — no listAll stub needed (should not be called)

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
            sizeRepositoryProvider.overrideWithValue(fakeSizeRepo),
            areaRepositoryProvider.overrideWithValue(fakeAreaRepo),
            duplicateMenuUseCaseProvider.overrideWithValue(
              fakeDuplicateUseCase,
            ),
            isAdminProvider.overrideWithValue(false),
            currentUserProvider.overrideWithValue(null),
          ],
          child: MaterialApp(
            home: InheritedGoRouter(
              goRouter: fakeRouter,
              child: const MenuListPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMenuRepo.listAllCalls, isEmpty);
    });

    testWidgets('should show area name in menu list item', (tester) async {
      // Arrange
      const menus = [
        Menu(
          id: 1,
          name: 'Dining Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
      ];
      fakeMenuRepo.whenListAll(success(menus));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(isAdmin: true));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dining'), findsWidgets);
    });
  });
}
