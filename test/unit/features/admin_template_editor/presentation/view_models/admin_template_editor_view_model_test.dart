import 'dart:async';

import 'package:fake_async/fake_async.dart';
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
import 'package:oxo_menus/features/admin_template_editor/presentation/state/admin_template_editor_screen_state.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/state/editor_selection.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/view_models/admin_template_editor_view_model.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

import '../../../../../fakes/fake_area_repository.dart';
import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_connectivity_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_size_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

const _menu = Menu(id: 1, name: 'Template', version: '1', status: Status.draft);

const _content = entity.Page(id: 10, menuId: 1, name: 'Page 1', index: 0);
const _container = entity.Container(id: 20, pageId: 10, index: 0);
const _column = entity.Column(id: 30, containerId: 20, index: 0);
const _widget = WidgetInstance(
  id: 40,
  columnId: 30,
  type: 'text',
  version: '1',
  index: 0,
  props: {},
);

class _FakeRouter implements AdminTemplateEditorRouter {
  int goBackCount = 0;
  int goToAdminSizesCount = 0;
  int? lastPdfPreviewMenuId;

  @override
  void goBack() => goBackCount++;

  @override
  void goToAdminSizes() => goToAdminSizesCount++;

  @override
  void goToPdfPreview(int menuId) {
    lastPdfPreviewMenuId = menuId;
  }
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

  void primeLoadEmpty() {
    menuRepo.whenGetById(const Success(_menu));
    pageRepo.whenGetAllForMenu(const Success([]));
  }

  void primeLoadOnePage() {
    menuRepo.whenGetById(const Success(_menu));
    pageRepo.whenGetAllForMenu(const Success([_content]));
    containerRepo.whenGetAllForPage(const Success([_container]));
    containerRepo.whenGetAllForContainer(const Success([]));
    columnRepo.whenGetAllForContainer(const Success([_column]));
    widgetRepo.whenGetAllForColumn(const Success([_widget]));
  }
}

Future<
  ({
    AdminTemplateEditorViewModel vm,
    _FakeRouter router,
    _Fakes fakes,
    AuthGateway gateway,
    ConnectivityGateway connectivityGateway,
    FakeConnectivityRepository connectivityRepo,
  })
>
_build({bool admin = true, void Function(_Fakes fakes)? configure}) async {
  final gateway = await gatewayFor(admin ? adminUser : regularUser);
  final connectivityRepo = FakeConnectivityRepository()
    ..whenCheckConnectivity(ConnectivityStatus.online);
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final fakes = _Fakes();
  configure?.call(fakes);
  final router = _FakeRouter();
  final loadTemplate = LoadTemplateForEditorUseCase(
    authGateway: gateway,
    menuRepository: fakes.menuRepo,
    pageRepository: fakes.pageRepo,
    containerRepository: fakes.containerRepo,
    columnRepository: fakes.columnRepo,
    widgetRepository: fakes.widgetRepo,
  );
  final vm = AdminTemplateEditorViewModel(
    menuId: 1,
    authGateway: gateway,
    connectivityGateway: connectivityGateway,
    router: router,
    registry: PresentableWidgetRegistry(),
    loadTemplate: loadTemplate,
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
    fakes: fakes,
    gateway: gateway,
    connectivityGateway: connectivityGateway,
    connectivityRepo: connectivityRepo,
  );
}

void main() {
  group('AdminTemplateEditorViewModel — initial state', () {
    test('admin sees isAdmin=true and triggers a load', () async {
      final ctx = await _build(
        admin: true,
        configure: (f) => f.primeLoadOnePage(),
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);

      // Allow microtasks to flush.
      await Future<void>.delayed(Duration.zero);

      expect(ctx.vm.state.isAdmin, true);
      expect(ctx.vm.state.isLoading, false);
      expect(ctx.vm.state.tree, isNotNull);
      expect(ctx.vm.state.tree!.menu, _menu);
    });

    test(
      'non-admin sees isAdmin=false and the load surfaces unauthorized',
      () async {
        final ctx = await _build(admin: false);
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.connectivityGateway.dispose);

        await Future<void>.delayed(Duration.zero);

        expect(ctx.vm.state.isAdmin, false);
        expect(ctx.vm.state.errorMessage, isNotNull);
      },
    );
  });

  group('AdminTemplateEditorViewModel — selection', () {
    test('selectMenu sets currentStyle to menu styleConfig', () async {
      final ctx = await _build(
        configure: (f) {
          f.menuRepo.whenGetById(
            const Success(
              Menu(
                id: 1,
                name: 'T',
                version: '1',
                status: Status.draft,
                styleConfig: StyleConfig(marginTop: 4),
              ),
            ),
          );
          f.pageRepo.whenGetAllForMenu(const Success([]));
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      ctx.vm.selectMenu();

      expect(ctx.vm.state.selection, const EditorSelection.menu());
      expect(ctx.vm.state.currentStyle, const StyleConfig(marginTop: 4));
      expect(ctx.vm.state.originalStyle, const StyleConfig(marginTop: 4));
    });

    test('selectContainer / selectColumn / deselect cycle', () async {
      final ctx = await _build(configure: (f) => f.primeLoadOnePage());
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      ctx.vm.selectContainer(20);
      expect(ctx.vm.state.selection, const EditorSelection.container(20));

      ctx.vm.selectColumn(30);
      expect(ctx.vm.state.selection, const EditorSelection.column(30));

      ctx.vm.deselect();
      expect(ctx.vm.state.selection, isNull);
      expect(ctx.vm.state.currentStyle, isNull);
    });

    test('copyStyle persists across selection changes', () async {
      final ctx = await _build(configure: (f) => f.primeLoadOnePage());
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      ctx.vm.selectContainer(20);
      ctx.vm.updateSelectedStyle(const StyleConfig(marginTop: 8));
      ctx.vm.copyStyle();
      ctx.vm.selectColumn(30);

      expect(ctx.vm.state.clipboardStyle, const StyleConfig(marginTop: 8));
    });
  });

  group('AdminTemplateEditorViewModel — style debounce', () {
    test(
      'container style writes are debounced to a single repo call',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.containerRepo.whenUpdate(const Success(_container));
          },
        );
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.connectivityGateway.dispose);

        await Future<void>.delayed(Duration.zero);
        ctx.vm.selectContainer(20);

        fakeAsync((async) {
          ctx.vm.updateSelectedStyle(const StyleConfig(marginTop: 1));
          ctx.vm.updateSelectedStyle(const StyleConfig(marginTop: 2));
          ctx.vm.updateSelectedStyle(const StyleConfig(marginTop: 3));
          async.elapse(const Duration(milliseconds: 499));
          // No update yet — debounce hasn't fired.
          expect(
            ctx.fakes.containerRepo.calls.whereType<ContainerUpdateCall>(),
            isEmpty,
          );
          async.elapse(const Duration(milliseconds: 1));
          async.flushMicrotasks();
          expect(
            ctx.fakes.containerRepo.calls.whereType<ContainerUpdateCall>(),
            hasLength(1),
          );
        });
      },
    );

    test('flushStyleDebounce cancels the pending write', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.containerRepo.whenUpdate(const Success(_container));
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      ctx.vm.selectContainer(20);

      fakeAsync((async) {
        ctx.vm.updateSelectedStyle(const StyleConfig(marginTop: 1));
        ctx.vm.flushStyleDebounce();
        async.elapse(const Duration(seconds: 1));
        expect(
          ctx.fakes.containerRepo.calls.whereType<ContainerUpdateCall>(),
          isEmpty,
        );
      });
    });

    test('menu-level style is local-only — never debounced to repo', () async {
      final ctx = await _build(configure: (f) => f.primeLoadOnePage());
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      ctx.vm.selectMenu();

      fakeAsync((async) {
        ctx.vm.updateSelectedStyle(const StyleConfig(marginTop: 4));
        async.elapse(const Duration(seconds: 2));
        // No menu update calls — saveTemplate is the only path.
        expect(ctx.fakes.menuRepo.calls.whereType<MenuUpdateCall>(), isEmpty);
      });
    });
  });

  group('AdminTemplateEditorViewModel — page CRUD', () {
    test('addPage names new page with content count + 1', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.pageRepo.whenCreate(const Success(_content));
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      await ctx.vm.addPage();
      final create = ctx.fakes.pageRepo.createCalls.single;
      expect(create.input.name, 'Page 2');
      expect(create.input.index, 1);
    });

    test('addHeader creates header at index 0', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadEmpty();
          f.pageRepo.whenCreate(const Success(_content));
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      await ctx.vm.addHeader();
      final create = ctx.fakes.pageRepo.createCalls.single;
      expect(create.input.name, 'Header');
      expect(create.input.type, entity.PageType.header);
    });

    test('deletePage surfaces failures via errorMessage', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.pageRepo.whenDelete(const Failure(NetworkError()));
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      await ctx.vm.deletePage(10);
      expect(ctx.vm.state.errorMessage, isNotNull);
    });
  });

  group('AdminTemplateEditorViewModel — widget CRUD', () {
    test(
      'deleteWidget removes the widget locally before the repo call',
      () async {
        final widgetCompleter = Completer<Result<void, DomainError>>();
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.widgetRepo.whenDeleteWithFuture(widgetCompleter.future);
          },
        );
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
        await Future<void>.delayed(Duration.zero);

        final future = ctx.vm.deleteWidget(40);
        // Optimistic removal: widget should be gone from state immediately.
        expect(ctx.vm.state.tree!.widgets[30], isEmpty);

        widgetCompleter.complete(const Success(null));
        await future;
      },
    );

    test(
      'moveWidget within same column uses reorder with adjusted index',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.widgetRepo.whenReorder(const Success(null));
          },
        );
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
        await Future<void>.delayed(Duration.zero);

        await ctx.vm.moveWidget(
          widget: _widget,
          sourceColumnId: 30,
          targetColumnId: 30,
          targetIndex: 5,
        );
        final reorder = ctx.fakes.widgetRepo.calls
            .whereType<WidgetReorderCall>()
            .single;
        expect(reorder.newIndex, 4);
      },
    );
  });

  group('AdminTemplateEditorViewModel — menu-level updates', () {
    test(
      'updateAllowedWidgets is optimistic and rolls back on failure',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.menuRepo.whenUpdate(const Failure(NetworkError()));
          },
        );
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
        await Future<void>.delayed(Duration.zero);

        final originalAllowed = ctx.vm.state.tree!.menu.allowedWidgets;

        await ctx.vm.updateAllowedWidgets(const []);
        expect(
          ctx.vm.state.tree!.menu.allowedWidgets,
          originalAllowed,
          reason: 'should roll back on repo failure',
        );
        expect(ctx.vm.state.errorMessage, isNotNull);
      },
    );

    test('updateDisplayOptions writes locally on success', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.menuRepo.whenUpdate(const Success(_menu));
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      const opts = MenuDisplayOptions(showAllergens: false);
      await ctx.vm.updateDisplayOptions(opts);
      expect(ctx.vm.state.tree!.menu.displayOptions, opts);
    });

    test('saveTemplate transitions savingState idle → saving → idle', () async {
      final menuCompleter = Completer<Result<Menu, DomainError>>();
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.menuRepo.whenUpdateWithFuture(menuCompleter.future);
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      final saveFuture = ctx.vm.saveTemplate();
      expect(ctx.vm.state.savingState, TemplateSavingState.saving);
      menuCompleter.complete(const Success(_menu));
      await saveFuture;
      expect(ctx.vm.state.savingState, TemplateSavingState.idle);
    });

    test('publishTemplate forwards Status.published', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.menuRepo.whenUpdate(const Success(_menu));
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      await ctx.vm.publishTemplate();
      final updates = ctx.fakes.menuRepo.calls
          .whereType<MenuUpdateCall>()
          .toList();
      expect(updates, hasLength(1));
      expect(updates.single.input.status, Status.published);
    });
  });

  group('AdminTemplateEditorViewModel — connectivity', () {
    test(
      'reload only happens after offline → online when an error was last seen',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.menuRepo.whenGetById(const Failure(NetworkError()));
            f.pageRepo.whenGetAllForMenu(const Success([]));
          },
        );
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.connectivityGateway.dispose);

        await Future<void>.delayed(Duration.zero);
        expect(ctx.vm.state.errorMessage, isNotNull);

        // Now prime success and emit offline → online.
        ctx.fakes.menuRepo.whenGetById(const Success(_menu));
        ctx.fakes.pageRepo.whenGetAllForMenu(const Success([]));
        ctx.connectivityRepo.statusController.add(ConnectivityStatus.offline);
        await Future<void>.delayed(Duration.zero);
        ctx.connectivityRepo.statusController.add(ConnectivityStatus.online);
        await Future<void>.delayed(Duration.zero);

        expect(ctx.vm.state.errorMessage, isNull);
        expect(ctx.vm.state.tree, isNotNull);
      },
    );
  });

  group('AdminTemplateEditorViewModel — navigation', () {
    test('goBack delegates to the router', () async {
      final ctx = await _build(configure: (f) => f.primeLoadEmpty());
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      ctx.vm.goBack();
      expect(ctx.router.goBackCount, 1);
    });

    test('goToAdminSizes delegates', () async {
      final ctx = await _build(configure: (f) => f.primeLoadEmpty());
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      ctx.vm.goToAdminSizes();
      expect(ctx.router.goToAdminSizesCount, 1);
    });

    test('goToPdfPreview forwards menuId', () async {
      final ctx = await _build(configure: (f) => f.primeLoadEmpty());
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      ctx.vm.goToPdfPreview();
      expect(ctx.router.lastPdfPreviewMenuId, 1);
    });
  });

  group('AdminTemplateEditorViewModel — areas / sizes', () {
    test('loadAreas returns repository result', () async {
      const areas = [Area(id: 1, name: 'Bar')];
      final ctx = await _build(
        configure: (f) {
          f.primeLoadEmpty();
          f.areaRepo.whenGetAll(const Success(areas));
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);

      final result = await ctx.vm.loadAreas();
      expect(result.valueOrNull, areas);
    });
  });

  group('AdminTemplateEditorViewModel — clearError + dispose', () {
    test('clearError clears the message', () async {
      final ctx = await _build(
        configure: (f) {
          f.menuRepo.whenGetById(const Failure(NetworkError()));
          f.pageRepo.whenGetAllForMenu(const Success([]));
        },
      );
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      expect(ctx.vm.state.errorMessage, isNotNull);
      ctx.vm.clearError();
      expect(ctx.vm.state.errorMessage, isNull);
    });

    test('emit is a no-op after dispose', () async {
      final ctx = await _build(configure: (f) => f.primeLoadEmpty());
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
      await Future<void>.delayed(Duration.zero);
      ctx.vm.dispose();
      // calls after dispose should be no-ops, not throws.
      ctx.vm.clearError();
      expect(ctx.vm.isDisposed, true);
    });
  });
}
