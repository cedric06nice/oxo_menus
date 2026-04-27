import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/collaboration/data/repositories/menu_subscription_repository_impl.dart';
import 'package:oxo_menus/features/collaboration/data/repositories/presence_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_bundle_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_bundles_for_menu_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_menu_bundle_usecase.dart';
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
import 'package:oxo_menus/features/menu_editor/presentation/screens/menu_editor_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/menu_editor_view_model.dart';
import 'package:oxo_menus/shared/data/repositories/asset_loader_repository_impl.dart';
import 'package:oxo_menus/shared/data/repositories/file_repository_impl.dart';

/// View-model factory used by [MenuEditorRoutePage].
///
/// Tests inject a custom builder to bypass the production repositories.
typedef MenuEditorViewModelBuilder =
    MenuEditorViewModel Function(
      AppContainer container,
      MenuEditorRouter router,
      int menuId,
    );

/// Stack entry for the consumer-facing menu editor screen.
///
/// Builds the use cases → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and reused
/// across rebuilds; [disposeResources] tears it down when the page leaves the
/// stack for good. The page's identity is namespaced by `menuId` so opening
/// two different menus in sequence doesn't collide.
class MenuEditorRoutePage extends RoutePage {
  MenuEditorRoutePage({
    required this.router,
    required this.menuId,
    MenuEditorViewModelBuilder? viewModelBuilder,
  }) : _viewModelBuilder = viewModelBuilder ?? _defaultBuilder;

  final MenuEditorRouter router;
  final int menuId;
  final MenuEditorViewModelBuilder _viewModelBuilder;
  MenuEditorViewModel? _viewModel;

  @override
  Object get identity => 'menu-editor-$menuId';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= _viewModelBuilder(container, router, menuId);
    return MenuEditorScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }

  static MenuEditorViewModel _defaultBuilder(
    AppContainer container,
    MenuEditorRouter router,
    int menuId,
  ) {
    final dataSource = container.directusDataSource;
    final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
    final pageRepository = PageRepositoryImpl(dataSource: dataSource);
    final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
    final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
    final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
    final menuBundleRepository = MenuBundleRepositoryImpl(
      dataSource: dataSource,
    );
    final fileRepository = FileRepositoryImpl(dataSource);
    final assetLoader = AssetLoaderRepositoryImpl();
    final fetchMenuTreeUseCase = FetchMenuTreeUseCase(
      menuRepository: menuRepository,
      pageRepository: pageRepository,
      containerRepository: containerRepository,
      columnRepository: columnRepository,
      widgetRepository: widgetRepository,
    );
    final publishMenuBundleUseCase = PublishMenuBundleUseCase(
      repository: menuBundleRepository,
      fetchMenuTreeUseCase: fetchMenuTreeUseCase,
      fileRepository: fileRepository,
      assetLoader: assetLoader,
      pdfBuilder: const PdfDocumentBuilder(),
    );
    final publishBundlesForMenuUseCase = PublishBundlesForMenuUseCase(
      repository: menuBundleRepository,
      publishMenuBundleUseCase: publishMenuBundleUseCase,
    );
    final subscriptionRepository = MenuSubscriptionRepositoryImpl(
      dataSource: dataSource,
    );
    final presenceRepository = PresenceRepositoryImpl(dataSource: dataSource);
    return MenuEditorViewModel(
      menuId: menuId,
      authGateway: container.authGateway,
      connectivityGateway: container.connectivityGateway,
      router: router,
      loadMenu: LoadMenuForEditorUseCase(
        authGateway: container.authGateway,
        menuRepository: menuRepository,
        pageRepository: pageRepository,
        containerRepository: containerRepository,
        columnRepository: columnRepository,
        widgetRepository: widgetRepository,
      ),
      createWidget: CreateWidgetInMenuUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      updateWidget: UpdateWidgetInMenuUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      deleteWidget: DeleteWidgetInMenuUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      moveWidget: MoveWidgetInMenuUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      lockWidget: LockWidgetForEditingUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      unlockWidget: UnlockWidgetUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      saveMenu: SaveMenuUseCase(
        authGateway: container.authGateway,
        menuRepository: menuRepository,
      ),
      publishBundles: PublishExportableBundlesForMenuUseCase(
        authGateway: container.authGateway,
        delegate: publishBundlesForMenuUseCase,
      ),
      watchChanges: WatchMenuChangesUseCase(repository: subscriptionRepository),
      presence: MenuPresenceUseCase(repository: presenceRepository),
    );
  }
}
