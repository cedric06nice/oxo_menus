import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_router.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/screens/admin_template_editor_screen.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/view_models/admin_template_editor_view_model.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

import '../../../../../fakes/fake_area_repository.dart';
import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_size_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';

const _menu = Menu(
  id: 1,
  name: 'My Template',
  version: '1',
  status: Status.draft,
);

class _AdminAuthRepository implements AuthRepository {
  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());
  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);
  @override
  Future<Result<User, DomainError>> getCurrentUser() async => const Success(
    User(id: 'u-admin', email: 'admin@example.com', role: UserRole.admin),
  );
  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);
  @override
  Future<Result<User, DomainError>> tryRestoreSession() async => const Success(
    User(id: 'u-admin', email: 'admin@example.com', role: UserRole.admin),
  );
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

class _ConnectivityRepo implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();
  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;
  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}

class _RecordingRouter implements AdminTemplateEditorRouter {
  int goBackCount = 0;
  int goToAdminSizesCount = 0;
  int? lastPdfPreview;
  @override
  void goBack() => goBackCount++;
  @override
  void goToAdminSizes() => goToAdminSizesCount++;
  @override
  void goToPdfPreview(int menuId) => lastPdfPreview = menuId;
}

Future<
  ({
    AdminTemplateEditorViewModel vm,
    _RecordingRouter router,
    AuthGateway gateway,
    ConnectivityGateway connectivityGateway,
  })
>
_build({void Function(_Fakes)? configure}) async {
  final gateway = AuthGateway(repository: _AdminAuthRepository());
  await gateway.tryRestoreSession();
  final connectivityGateway = ConnectivityGateway(
    repository: _ConnectivityRepo(),
  );
  final fakes = _Fakes();
  configure?.call(fakes);
  final router = _RecordingRouter();
  final vm = AdminTemplateEditorViewModel(
    menuId: 1,
    authGateway: gateway,
    connectivityGateway: connectivityGateway,
    router: router,
    loadTemplate: LoadTemplateForEditorUseCase(
      authGateway: gateway,
      menuRepository: fakes.menuRepo,
      pageRepository: fakes.pageRepo,
      containerRepository: fakes.containerRepo,
      columnRepository: fakes.columnRepo,
      widgetRepository: fakes.widgetRepo,
    ),
    createPage: CreatePageInTemplateUseCase(
      authGateway: gateway,
      pageRepository: fakes.pageRepo,
    ),
    deletePage: DeletePageInTemplateUseCase(
      authGateway: gateway,
      pageRepository: fakes.pageRepo,
    ),
    createContainer: CreateContainerInTemplateUseCase(
      authGateway: gateway,
      containerRepository: fakes.containerRepo,
    ),
    updateContainer: UpdateContainerInTemplateUseCase(
      authGateway: gateway,
      containerRepository: fakes.containerRepo,
    ),
    deleteContainer: DeleteContainerInTemplateUseCase(
      authGateway: gateway,
      containerRepository: fakes.containerRepo,
    ),
    reorderContainer: ReorderContainerInTemplateUseCase(
      authGateway: gateway,
      reorderContainerUseCase: ReorderContainerUseCase(
        containerRepository: fakes.containerRepo,
      ),
    ),
    duplicateContainer: DuplicateContainerInTemplateUseCase(
      authGateway: gateway,
      duplicateContainerUseCase: DuplicateContainerUseCase(
        containerRepository: fakes.containerRepo,
        columnRepository: fakes.columnRepo,
        widgetRepository: fakes.widgetRepo,
      ),
    ),
    createColumn: CreateColumnInTemplateUseCase(
      authGateway: gateway,
      columnRepository: fakes.columnRepo,
    ),
    updateColumn: UpdateColumnInTemplateUseCase(
      authGateway: gateway,
      columnRepository: fakes.columnRepo,
    ),
    deleteColumn: DeleteColumnInTemplateUseCase(
      authGateway: gateway,
      columnRepository: fakes.columnRepo,
    ),
    createWidget: CreateWidgetInTemplateUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    updateWidget: UpdateWidgetInTemplateUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    deleteWidget: DeleteWidgetInTemplateUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    moveWidget: MoveWidgetInTemplateUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    updateMenu: UpdateTemplateMenuUseCase(
      authGateway: gateway,
      menuRepository: fakes.menuRepo,
    ),
    listAreas: ListAreasForTemplateUseCase(
      authGateway: gateway,
      areaRepository: fakes.areaRepo,
    ),
    listSizes: ListSizesForTemplateUseCase(
      authGateway: gateway,
      sizeRepository: fakes.sizeRepo,
    ),
  );
  return (
    vm: vm,
    router: router,
    gateway: gateway,
    connectivityGateway: connectivityGateway,
  );
}

class _Fakes {
  _Fakes()
    : menuRepo = FakeMenuRepository(),
      pageRepo = FakePageRepository(),
      containerRepo = FakeContainerRepository(),
      columnRepo = FakeColumnRepository(),
      widgetRepo = FakeWidgetRepository(),
      areaRepo = FakeAreaRepository(),
      sizeRepo = FakeSizeRepository();
  final FakeMenuRepository menuRepo;
  final FakePageRepository pageRepo;
  final FakeContainerRepository containerRepo;
  final FakeColumnRepository columnRepo;
  final FakeWidgetRepository widgetRepo;
  final FakeAreaRepository areaRepo;
  final FakeSizeRepository sizeRepo;

  void primeEmptyTree() {
    menuRepo.whenGetById(const Success(_menu));
    pageRepo.whenGetAllForMenu(const Success([]));
  }

  void primeOnePage() {
    menuRepo.whenGetById(const Success(_menu));
    pageRepo.whenGetAllForMenu(
      const Success([entity.Page(id: 10, menuId: 1, name: 'Page 1', index: 0)]),
    );
    containerRepo.whenGetAllForPage(const Success([]));
    containerRepo.whenGetAllForContainer(const Success([]));
    columnRepo.whenGetAllForContainer(const Success([]));
    widgetRepo.whenGetAllForColumn(const Success([]));
  }
}

void main() {
  setUp(() {
    // Editor expects a wide layout so the side-panel + canvas split renders.
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      1400,
      1000,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('renders the menu name in the app bar after the tree loads', (
    tester,
  ) async {
    final ctx = await _build(configure: (f) => f.primeEmptyTree());
    addTearDown(ctx.vm.dispose);
    addTearDown(ctx.gateway.dispose);
    addTearDown(ctx.connectivityGateway.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: AdminTemplateEditorScreen(viewModel: ctx.vm)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Template'), findsOneWidget);
    expect(find.byKey(const Key('add_page_button')), findsOneWidget);
    expect(find.byKey(const Key('add_header_button')), findsOneWidget);
    expect(find.byKey(const Key('add_footer_button')), findsOneWidget);
  });

  testWidgets('renders the page card when one page is loaded', (tester) async {
    final ctx = await _build(configure: (f) => f.primeOnePage());
    addTearDown(ctx.vm.dispose);
    addTearDown(ctx.gateway.dispose);
    addTearDown(ctx.connectivityGateway.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: AdminTemplateEditorScreen(viewModel: ctx.vm)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add_container_10')), findsOneWidget);
  });

  testWidgets('PDF button forwards to router.goToPdfPreview', (tester) async {
    final ctx = await _build(configure: (f) => f.primeEmptyTree());
    addTearDown(ctx.vm.dispose);
    addTearDown(ctx.gateway.dispose);
    addTearDown(ctx.connectivityGateway.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: AdminTemplateEditorScreen(viewModel: ctx.vm)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('show_pdf_button')));
    await tester.pump();

    expect(ctx.router.lastPdfPreview, 1);
  });

  testWidgets('manage page sizes button forwards to router.goToAdminSizes', (
    tester,
  ) async {
    final ctx = await _build(configure: (f) => f.primeEmptyTree());
    addTearDown(ctx.vm.dispose);
    addTearDown(ctx.gateway.dispose);
    addTearDown(ctx.connectivityGateway.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: AdminTemplateEditorScreen(viewModel: ctx.vm)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('page_size_button')));
    await tester.pump();

    expect(ctx.router.goToAdminSizesCount, 1);
  });
}
