import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/create_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/delete_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_available_menus_for_bundles_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_menu_bundles_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/publish_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/update_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_router.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/screens/admin_exportable_menus_screen.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/view_models/admin_exportable_menus_view_model.dart';
import 'package:oxo_menus/features/menu/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_bundle_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_menu_bundle_usecase.dart';
import 'package:oxo_menus/shared/data/repositories/asset_loader_repository_impl.dart';
import 'package:oxo_menus/shared/data/repositories/file_repository_impl.dart';

/// View-model factory used by [AdminExportableMenusRoutePage].
typedef AdminExportableMenusViewModelBuilder =
    AdminExportableMenusViewModel Function(
      AppContainer container,
      AdminExportableMenusRouter router,
    );

/// Stack entry for the admin exportable-menus screen.
///
/// Builds the use cases → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and reused
/// across rebuilds; [disposeResources] tears it down when the page leaves the
/// stack for good.
///
/// Tests inject a custom [viewModelBuilder] to bypass the production
/// repositories. The Directus base URL passed to the screen is read from the
/// container's data source when one is configured, or falls back to an empty
/// string in tests where no data source is available.
class AdminExportableMenusRoutePage extends RoutePage {
  AdminExportableMenusRoutePage({
    required this.router,
    AdminExportableMenusViewModelBuilder? viewModelBuilder,
  }) : _viewModelBuilder = viewModelBuilder ?? _defaultBuilder;

  final AdminExportableMenusRouter router;
  final AdminExportableMenusViewModelBuilder _viewModelBuilder;
  AdminExportableMenusViewModel? _viewModel;

  @override
  Object get identity => 'admin-exportable-menus';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= _viewModelBuilder(container, router);
    return AdminExportableMenusScreen(
      viewModel: vm,
      directusBaseUrl: _resolveBaseUrl(container),
    );
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }

  static String _resolveBaseUrl(AppContainer container) =>
      container.directusBaseUrl ?? '';

  static AdminExportableMenusViewModel _defaultBuilder(
    AppContainer container,
    AdminExportableMenusRouter router,
  ) {
    final dataSource = container.directusDataSource;
    final bundleRepository = MenuBundleRepositoryImpl(dataSource: dataSource);
    final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
    final pageRepository = PageRepositoryImpl(dataSource: dataSource);
    final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
    final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
    final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
    final fileRepository = FileRepositoryImpl(dataSource);
    final assetLoader = AssetLoaderRepositoryImpl();
    final fetchMenuTreeUseCase = FetchMenuTreeUseCase(
      menuRepository: menuRepository,
      pageRepository: pageRepository,
      containerRepository: containerRepository,
      columnRepository: columnRepository,
      widgetRepository: widgetRepository,
    );
    final publishUseCase = PublishMenuBundleUseCase(
      repository: bundleRepository,
      fetchMenuTreeUseCase: fetchMenuTreeUseCase,
      fileRepository: fileRepository,
      assetLoader: assetLoader,
      pdfBuilder: const PdfDocumentBuilder(),
    );
    return AdminExportableMenusViewModel(
      listBundles: ListMenuBundlesForAdminUseCase(
        authGateway: container.authGateway,
        bundleRepository: bundleRepository,
      ),
      listAvailableMenus: ListAvailableMenusForBundlesUseCase(
        authGateway: container.authGateway,
        menuRepository: menuRepository,
      ),
      createBundle: CreateMenuBundleForAdminUseCase(
        authGateway: container.authGateway,
        bundleRepository: bundleRepository,
      ),
      updateBundle: UpdateMenuBundleForAdminUseCase(
        authGateway: container.authGateway,
        bundleRepository: bundleRepository,
      ),
      deleteBundle: DeleteMenuBundleForAdminUseCase(
        authGateway: container.authGateway,
        bundleRepository: bundleRepository,
      ),
      publishBundle: PublishMenuBundleForAdminUseCase(
        authGateway: container.authGateway,
        publishMenuBundleUseCase: publishUseCase,
      ),
      authGateway: container.authGateway,
      connectivityGateway: container.connectivityGateway,
      router: router,
    );
  }
}
