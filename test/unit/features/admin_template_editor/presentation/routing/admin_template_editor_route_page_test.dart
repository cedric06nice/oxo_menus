import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_page_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_page_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/duplicate_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_areas_for_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_sizes_for_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/load_template_for_editor_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/move_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/reorder_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_template_menu_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_route_page.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_router.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/screens/admin_template_editor_screen.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/view_models/admin_template_editor_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

import '../../../../../fakes/fake_area_repository.dart';
import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_size_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';

class _StubAuthRepository implements AuthRepository {
  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());
  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);
  @override
  Future<Result<User, DomainError>> getCurrentUser() async =>
      const Failure(UnauthorizedError());
  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);
  @override
  Future<Result<User, DomainError>> tryRestoreSession() async =>
      const Failure(UnauthorizedError());
  @override
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  }) async => const Success(null);
  @override
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  }) async => const Success(null);
}

class _StubConnectivityRepository implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();
  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;
  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}

class _NoopRouter implements AdminTemplateEditorRouter {
  @override
  void goBack() {}
  @override
  void goToAdminSizes() {}
  @override
  void goToPdfPreview(int menuId) {}
}

AppContainer _makeContainer() {
  final auth = AuthGateway(repository: _StubAuthRepository());
  final connectivity = ConnectivityGateway(
    repository: _StubConnectivityRepository(),
  );
  return AppContainer(authGateway: auth, connectivityGateway: connectivity);
}

AdminTemplateEditorViewModel _testViewModelBuilder(
  AppContainer container,
  AdminTemplateEditorRouter router,
  int menuId,
) {
  final auth = container.authGateway;
  final menuRepo = FakeMenuRepository();
  final pageRepo = FakePageRepository();
  final containerRepo = FakeContainerRepository();
  final columnRepo = FakeColumnRepository();
  final widgetRepo = FakeWidgetRepository();
  final areaRepo = FakeAreaRepository();
  final sizeRepo = FakeSizeRepository();
  return AdminTemplateEditorViewModel(
    menuId: menuId,
    authGateway: auth,
    connectivityGateway: container.connectivityGateway,
    router: router,
    loadTemplate: LoadTemplateForEditorUseCase(
      authGateway: auth,
      menuRepository: menuRepo,
      pageRepository: pageRepo,
      containerRepository: containerRepo,
      columnRepository: columnRepo,
      widgetRepository: widgetRepo,
    ),
    createPage: CreatePageInTemplateUseCase(
      authGateway: auth,
      pageRepository: pageRepo,
    ),
    deletePage: DeletePageInTemplateUseCase(
      authGateway: auth,
      pageRepository: pageRepo,
    ),
    createContainer: CreateContainerInTemplateUseCase(
      authGateway: auth,
      containerRepository: containerRepo,
    ),
    updateContainer: UpdateContainerInTemplateUseCase(
      authGateway: auth,
      containerRepository: containerRepo,
    ),
    deleteContainer: DeleteContainerInTemplateUseCase(
      authGateway: auth,
      containerRepository: containerRepo,
    ),
    reorderContainer: ReorderContainerInTemplateUseCase(
      authGateway: auth,
      reorderContainerUseCase: ReorderContainerUseCase(
        containerRepository: containerRepo,
      ),
    ),
    duplicateContainer: DuplicateContainerInTemplateUseCase(
      authGateway: auth,
      duplicateContainerUseCase: DuplicateContainerUseCase(
        containerRepository: containerRepo,
        columnRepository: columnRepo,
        widgetRepository: widgetRepo,
      ),
    ),
    createColumn: CreateColumnInTemplateUseCase(
      authGateway: auth,
      columnRepository: columnRepo,
    ),
    updateColumn: UpdateColumnInTemplateUseCase(
      authGateway: auth,
      columnRepository: columnRepo,
    ),
    deleteColumn: DeleteColumnInTemplateUseCase(
      authGateway: auth,
      columnRepository: columnRepo,
    ),
    createWidget: CreateWidgetInTemplateUseCase(
      authGateway: auth,
      widgetRepository: widgetRepo,
    ),
    updateWidget: UpdateWidgetInTemplateUseCase(
      authGateway: auth,
      widgetRepository: widgetRepo,
    ),
    deleteWidget: DeleteWidgetInTemplateUseCase(
      authGateway: auth,
      widgetRepository: widgetRepo,
    ),
    moveWidget: MoveWidgetInTemplateUseCase(
      authGateway: auth,
      widgetRepository: widgetRepo,
    ),
    updateMenu: UpdateTemplateMenuUseCase(
      authGateway: auth,
      menuRepository: menuRepo,
    ),
    listAreas: ListAreasForTemplateUseCase(
      authGateway: auth,
      areaRepository: areaRepo,
    ),
    listSizes: ListSizesForTemplateUseCase(
      authGateway: auth,
      sizeRepository: sizeRepo,
    ),
  );
}

void main() {
  group('AdminTemplateEditorRoutePage', () {
    test('identity is namespaced by menuId', () {
      final page = AdminTemplateEditorRoutePage(
        router: _NoopRouter(),
        menuId: 7,
      );

      expect(page.identity, 'admin-template-editor-7');
    });

    testWidgets('buildScreen returns AdminTemplateEditorScreen', (
      tester,
    ) async {
      final page = AdminTemplateEditorRoutePage(
        router: _NoopRouter(),
        menuId: 7,
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: page.buildScreen(container))),
      );
      await tester.pump();

      expect(find.byType(AdminTemplateEditorScreen), findsOneWidget);
    });

    test('buildScreen caches the ViewModel across rebuilds', () {
      final page = AdminTemplateEditorRoutePage(
        router: _NoopRouter(),
        menuId: 7,
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();

      final first = page.buildScreen(container) as AdminTemplateEditorScreen;
      final second = page.buildScreen(container) as AdminTemplateEditorScreen;

      expect(identical(first.viewModel, second.viewModel), isTrue);
    });

    testWidgets('disposeResources disposes the ViewModel', (tester) async {
      final page = AdminTemplateEditorRoutePage(
        router: _NoopRouter(),
        menuId: 7,
        viewModelBuilder: _testViewModelBuilder,
      );
      final container = _makeContainer();
      final screen = page.buildScreen(container) as AdminTemplateEditorScreen;

      page.disposeResources();

      expect(screen.viewModel.isDisposed, isTrue);
    });

    test(
      'viewModelBuilder is invoked once with container, router, and menuId',
      () {
        var calls = 0;
        AppContainer? receivedContainer;
        AdminTemplateEditorRouter? receivedRouter;
        int? receivedMenuId;
        final router = _NoopRouter();
        AdminTemplateEditorViewModel customBuilder(
          AppContainer c,
          AdminTemplateEditorRouter r,
          int id,
        ) {
          calls++;
          receivedContainer = c;
          receivedRouter = r;
          receivedMenuId = id;
          return _testViewModelBuilder(c, r, id);
        }

        final page = AdminTemplateEditorRoutePage(
          router: router,
          menuId: 7,
          viewModelBuilder: customBuilder,
        );
        final container = _makeContainer();

        page.buildScreen(container);
        page.buildScreen(container);

        expect(calls, 1);
        expect(receivedContainer, same(container));
        expect(receivedRouter, same(router));
        expect(receivedMenuId, 7);
      },
    );
  });
}
