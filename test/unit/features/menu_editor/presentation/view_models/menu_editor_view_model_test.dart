import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_bundles_for_menu_usecase.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/create_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/delete_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/load_menu_for_editor_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/lock_widget_for_editing_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/menu_presence_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/move_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/publish_exportable_bundles_for_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/save_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/unlock_widget_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/update_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/watch_menu_changes_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/state/menu_editor_screen_state.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/menu_editor_view_model.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_connectivity_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_bundle_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_menu_subscription_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_presence_repository.dart';
import '../../../../../fakes/fake_publish_menu_bundle_usecase.dart';
import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

const _menu = Menu(id: 1, name: 'Menu', version: '1', status: Status.published);
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

class _FakeRouter implements MenuEditorRouter {
  int goBackCount = 0;
  int? lastPdfMenuId;

  @override
  void goBack() => goBackCount++;

  @override
  void goToPdfPreview(int menuId) {
    lastPdfMenuId = menuId;
  }
}

class _Fakes {
  _Fakes()
    : menuRepo = FakeMenuRepository(),
      pageRepo = FakePageRepository(),
      containerRepo = FakeContainerRepository(),
      columnRepo = FakeColumnRepository(),
      widgetRepo = FakeWidgetRepository(),
      bundleRepo = FakeMenuBundleRepository(),
      subRepo = FakeMenuSubscriptionRepository(),
      presenceRepo = FakePresenceRepository();

  final FakeMenuRepository menuRepo;
  final FakePageRepository pageRepo;
  final FakeContainerRepository containerRepo;
  final FakeColumnRepository columnRepo;
  final FakeWidgetRepository widgetRepo;
  final FakeMenuBundleRepository bundleRepo;
  final FakeMenuSubscriptionRepository subRepo;
  final FakePresenceRepository presenceRepo;

  void primeLoadOnePage() {
    menuRepo.whenGetById(const Success(_menu));
    pageRepo.whenGetAllForMenu(const Success([_content]));
    containerRepo.whenGetAllForPage(const Success([_container]));
    containerRepo.whenGetAllForContainer(const Success([]));
    columnRepo.whenGetAllForContainer(const Success([_column]));
    widgetRepo.whenGetAllForColumn(const Success([_widget]));
  }

  void primeCollab() {
    presenceRepo.whenJoinMenu(const Success(null));
    presenceRepo.whenGetActiveUsers(1, const Success([]));
    presenceRepo.whenHeartbeat(const Success(null));
    presenceRepo.whenLeaveMenu(const Success(null));
  }
}

Future<
  ({
    MenuEditorViewModel vm,
    _FakeRouter router,
    _Fakes fakes,
    AuthGateway gateway,
    ConnectivityGateway connectivityGateway,
    FakeConnectivityRepository connectivityRepo,
  })
>
_build({void Function(_Fakes fakes)? configure}) async {
  final gateway = await gatewayFor(regularUser);
  final connectivityRepo = FakeConnectivityRepository()
    ..whenCheckConnectivity(ConnectivityStatus.online);
  final connectivityGateway = ConnectivityGateway(repository: connectivityRepo);
  final fakes = _Fakes();
  configure?.call(fakes);
  final router = _FakeRouter();
  final publishStub = FakePublishMenuBundleUseCase()
    ..stubExecute(const Failure(NetworkError()));
  final delegate = PublishBundlesForMenuUseCase(
    repository: fakes.bundleRepo,
    publishMenuBundleUseCase: publishStub,
  );
  final vm = MenuEditorViewModel(
    menuId: 1,
    authGateway: gateway,
    connectivityGateway: connectivityGateway,
    router: router,
    registry: PresentableWidgetRegistry(),
    loadMenu: LoadMenuForEditorUseCase(
      authGateway: gateway,
      menuRepository: fakes.menuRepo,
      pageRepository: fakes.pageRepo,
      containerRepository: fakes.containerRepo,
      columnRepository: fakes.columnRepo,
      widgetRepository: fakes.widgetRepo,
    ),
    createWidget: CreateWidgetInMenuUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    updateWidget: UpdateWidgetInMenuUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    deleteWidget: DeleteWidgetInMenuUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    moveWidget: MoveWidgetInMenuUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    lockWidget: LockWidgetForEditingUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    unlockWidget: UnlockWidgetUseCase(
      authGateway: gateway,
      widgetRepository: fakes.widgetRepo,
    ),
    saveMenu: SaveMenuUseCase(
      authGateway: gateway,
      menuRepository: fakes.menuRepo,
    ),
    publishBundles: PublishExportableBundlesForMenuUseCase(
      authGateway: gateway,
      delegate: delegate,
    ),
    watchChanges: WatchMenuChangesUseCase(repository: fakes.subRepo),
    presence: MenuPresenceUseCase(repository: fakes.presenceRepo),
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
  group('MenuEditorViewModel — initial state', () {
    test('starts with isLoading=true and the auth-snapshot user id', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
        },
      );
      // Capture state before any microtasks run.
      expect(ctx.vm.state.isLoading, isTrue);
      expect(ctx.vm.state.currentUserId, regularUser.id);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });

    test('after the load completes, tree is populated and isLoading flips to '
        'false', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
        },
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(ctx.vm.state.isLoading, isFalse);
      expect(ctx.vm.state.tree?.menu, _menu);
      expect(ctx.vm.state.tree?.pages, [_content]);
      expect(ctx.vm.state.errorMessage, isNull);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });

    test(
      'load failure surfaces as errorMessage with isLoading=false',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.menuRepo.whenGetById(const Failure(NetworkError()));
            f.primeCollab();
          },
        );
        await Future<void>.delayed(Duration.zero);

        expect(ctx.vm.state.isLoading, isFalse);
        expect(ctx.vm.state.errorMessage, isNotNull);
        expect(ctx.vm.state.tree, isNull);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
      },
    );
  });

  group('MenuEditorViewModel — widget CRUD', () {
    test(
      'createWidgetAt forwards to the use case and reloads the tree',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.primeCollab();
            f.widgetRepo.whenCreate(Success(_widget));
          },
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final result = await ctx.vm.createWidgetAt(
          type: 'text',
          version: '1',
          defaultProps: const {},
          columnId: 30,
          index: 0,
        );

        expect(result.isSuccess, isTrue);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
      },
    );

    test(
      'updateWidgetProps surfaces failures into state.errorMessage',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.primeCollab();
            f.widgetRepo.whenUpdate(const Failure(NetworkError()));
          },
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        await ctx.vm.updateWidgetProps(40, const {'name': 'X'});

        expect(ctx.vm.state.errorMessage, isNotNull);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
      },
    );

    test(
      'deleteWidget optimistically removes the widget from the tree',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.primeCollab();
            f.widgetRepo.whenDelete(const Success(null));
          },
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final future = ctx.vm.deleteWidget(40);
        // Optimistic state — widget removed from tree before the future resolves.
        expect(ctx.vm.state.tree?.widgets[30]?.any((w) => w.id == 40), isFalse);
        await future;

        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
      },
    );

    test('moveWidget calls the use case and reloads on success', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
          f.widgetRepo.whenReorder(const Success(null));
        },
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final result = await ctx.vm.moveWidget(
        widget: _widget,
        sourceColumnId: 30,
        targetColumnId: 30,
        targetIndex: 1,
      );

      expect(result.isSuccess, isTrue);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });
  });

  group('MenuEditorViewModel — saveMenu', () {
    test(
      'flips savingState while in flight and clears it on success',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.primeCollab();
            f.menuRepo.whenUpdate(const Success(_menu));
          },
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        await ctx.vm.saveMenu();

        expect(ctx.vm.state.savingState, MenuSavingState.idle);
        expect(ctx.vm.state.errorMessage, isNull);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
      },
    );

    test('save failure surfaces error and resets savingState', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
          f.menuRepo.whenUpdate(const Failure(NetworkError()));
        },
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      await ctx.vm.saveMenu();

      expect(ctx.vm.state.savingState, MenuSavingState.idle);
      expect(ctx.vm.state.errorMessage, isNotNull);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });
  });

  group('MenuEditorViewModel — navigation', () {
    test('goBack delegates to the router', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
        },
      );
      await Future<void>.delayed(Duration.zero);

      ctx.vm.goBack();

      expect(ctx.router.goBackCount, 1);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });

    test('publishBundlesAndPreviewPdf navigates to the PDF preview', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
          f.bundleRepo.whenFindByIncludedMenu(const Success([]));
        },
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final outcomeFuture = ctx.vm.publishBundlesAndPreviewPdf();

      expect(ctx.router.lastPdfMenuId, 1);
      final outcome = await outcomeFuture;
      expect(outcome.isEmpty, isTrue);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });
  });

  group('MenuEditorViewModel — lifecycle', () {
    test('onAppLifecycleChanged false pauses subscriptions', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
        },
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      ctx.vm.onAppLifecycleChanged(false);

      expect(ctx.vm.state.isPaused, isTrue);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });

    test(
      'onAppLifecycleChanged true after a pause resumes subscriptions',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.primeCollab();
          },
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        ctx.vm.onAppLifecycleChanged(false);
        expect(ctx.vm.state.isPaused, isTrue);
        ctx.vm.onAppLifecycleChanged(true);

        expect(ctx.vm.state.isPaused, isFalse);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
      },
    );
  });

  group('MenuEditorViewModel — connectivity', () {
    test(
      'offline pauses subscriptions; online → online afterwards reloads',
      () async {
        final ctx = await _build(
          configure: (f) {
            f.primeLoadOnePage();
            f.primeCollab();
          },
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        ctx.connectivityRepo.statusController.add(ConnectivityStatus.offline);
        await Future<void>.delayed(Duration.zero);
        expect(ctx.vm.state.isPaused, isTrue);

        ctx.connectivityRepo.statusController.add(ConnectivityStatus.online);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(ctx.vm.state.isPaused, isFalse);
        addTearDown(ctx.vm.dispose);
        addTearDown(ctx.gateway.dispose);
        addTearDown(ctx.connectivityGateway.dispose);
      },
    );
  });

  group('MenuEditorViewModel — clearError', () {
    test('no-op when there is no error', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
        },
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      ctx.vm.clearError();

      expect(ctx.vm.state.errorMessage, isNull);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });

    test('clears an existing error', () async {
      final ctx = await _build(
        configure: (f) {
          f.menuRepo.whenGetById(const Failure(NetworkError()));
          f.primeCollab();
        },
      );
      await Future<void>.delayed(Duration.zero);
      expect(ctx.vm.state.errorMessage, isNotNull);

      ctx.vm.clearError();

      expect(ctx.vm.state.errorMessage, isNull);
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });
  });

  group('MenuEditorViewModel — lock/unlock', () {
    test('startWidgetEdit forwards to the lock use case', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
          f.widgetRepo.whenLockForEditing(const Success(null));
        },
      );
      await Future<void>.delayed(Duration.zero);

      ctx.vm.startWidgetEdit(40);
      await Future<void>.delayed(Duration.zero);

      expect(
        ctx.fakes.widgetRepo.calls.whereType<WidgetLockForEditingCall>().map(
          (c) => c.widgetId,
        ),
        contains(40),
      );
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });

    test('endWidgetEdit forwards to the unlock use case', () async {
      final ctx = await _build(
        configure: (f) {
          f.primeLoadOnePage();
          f.primeCollab();
          f.widgetRepo.whenUnlockEditing(const Success(null));
        },
      );
      await Future<void>.delayed(Duration.zero);

      ctx.vm.endWidgetEdit(40);
      await Future<void>.delayed(Duration.zero);

      expect(
        ctx.fakes.widgetRepo.calls.whereType<WidgetUnlockEditingCall>().map(
          (c) => c.widgetId,
        ),
        contains(40),
      );
      addTearDown(ctx.vm.dispose);
      addTearDown(ctx.gateway.dispose);
      addTearDown(ctx.connectivityGateway.dispose);
    });
  });
}
