import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/menu/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/create_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/delete_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/list_menus_for_viewer_use_case.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_router.dart';
import 'package:oxo_menus/features/menu_list/presentation/screens/menu_list_screen.dart';
import 'package:oxo_menus/features/menu_list/presentation/view_models/menu_list_view_model.dart';

/// View-model factory used by [MenuListRoutePage].
typedef MenuListViewModelBuilder =
    MenuListViewModel Function(AppContainer container, MenuListRouter router);

/// Stack entry for the menu-list screen.
///
/// Builds the use cases → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and
/// reused across rebuilds; [disposeResources] tears it down when the page
/// leaves the stack for good.
///
/// Tests inject a custom [viewModelBuilder] to bypass the production
/// repositories; the default builder wires the menu-list use cases and
/// `DuplicateMenuUseCase` from the container's `DirectusDataSource`.
class MenuListRoutePage extends RoutePage {
  MenuListRoutePage({
    required this.router,
    MenuListViewModelBuilder? viewModelBuilder,
  }) : _viewModelBuilder = viewModelBuilder ?? _defaultBuilder;

  final MenuListRouter router;
  final MenuListViewModelBuilder _viewModelBuilder;
  MenuListViewModel? _viewModel;

  @override
  Object get identity => 'menu-list';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= _viewModelBuilder(container, router);
    return MenuListScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }

  static MenuListViewModel _defaultBuilder(
    AppContainer container,
    MenuListRouter router,
  ) {
    final dataSource = container.directusDataSource;
    final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
    final pageRepository = PageRepositoryImpl(dataSource: dataSource);
    final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
    final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
    final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
    final sizeRepository = SizeRepositoryImpl(dataSource: dataSource);
    final fetchMenuTreeUseCase = FetchMenuTreeUseCase(
      menuRepository: menuRepository,
      pageRepository: pageRepository,
      containerRepository: containerRepository,
      columnRepository: columnRepository,
      widgetRepository: widgetRepository,
    );
    final duplicateMenuUseCase = DuplicateMenuUseCase(
      fetchMenuTreeUseCase: fetchMenuTreeUseCase,
      menuRepository: menuRepository,
      pageRepository: pageRepository,
      containerRepository: containerRepository,
      columnRepository: columnRepository,
      widgetRepository: widgetRepository,
      sizeRepository: sizeRepository,
    );
    return MenuListViewModel(
      listMenusForViewer: ListMenusForViewerUseCase(
        authGateway: container.authGateway,
        menuRepository: menuRepository,
      ),
      createMenu: CreateMenuUseCase(menuRepository: menuRepository),
      deleteMenu: DeleteMenuUseCase(menuRepository: menuRepository),
      duplicateMenu: duplicateMenuUseCase,
      authGateway: container.authGateway,
      connectivityGateway: container.connectivityGateway,
      router: router,
    );
  }
}
