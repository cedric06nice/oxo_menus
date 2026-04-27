import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
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
import 'package:oxo_menus/features/menu/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/shared/data/repositories/area_repository_impl.dart';

/// View-model factory used by [AdminTemplateEditorRoutePage].
///
/// Tests inject a custom builder to bypass the production repositories.
typedef AdminTemplateEditorViewModelBuilder =
    AdminTemplateEditorViewModel Function(
      AppContainer container,
      AdminTemplateEditorRouter router,
      int menuId,
    );

/// Stack entry for the admin template editor screen.
///
/// Builds the use cases → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and reused
/// across rebuilds; [disposeResources] tears it down when the page leaves the
/// stack for good. The page's identity is namespaced by `menuId` so opening
/// two different templates in sequence doesn't collide.
class AdminTemplateEditorRoutePage extends RoutePage {
  AdminTemplateEditorRoutePage({
    required this.router,
    required this.menuId,
    AdminTemplateEditorViewModelBuilder? viewModelBuilder,
  }) : _viewModelBuilder = viewModelBuilder ?? _defaultBuilder;

  final AdminTemplateEditorRouter router;
  final int menuId;
  final AdminTemplateEditorViewModelBuilder _viewModelBuilder;
  AdminTemplateEditorViewModel? _viewModel;

  @override
  Object get identity => 'admin-template-editor-$menuId';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= _viewModelBuilder(container, router, menuId);
    return AdminTemplateEditorScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }

  static AdminTemplateEditorViewModel _defaultBuilder(
    AppContainer container,
    AdminTemplateEditorRouter router,
    int menuId,
  ) {
    final dataSource = container.directusDataSource;
    final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
    final pageRepository = PageRepositoryImpl(dataSource: dataSource);
    final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
    final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
    final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
    final sizeRepository = SizeRepositoryImpl(dataSource: dataSource);
    final areaRepository = AreaRepositoryImpl(dataSource: dataSource);
    return AdminTemplateEditorViewModel(
      menuId: menuId,
      authGateway: container.authGateway,
      connectivityGateway: container.connectivityGateway,
      router: router,
      loadTemplate: LoadTemplateForEditorUseCase(
        authGateway: container.authGateway,
        menuRepository: menuRepository,
        pageRepository: pageRepository,
        containerRepository: containerRepository,
        columnRepository: columnRepository,
        widgetRepository: widgetRepository,
      ),
      createPage: CreatePageInTemplateUseCase(
        authGateway: container.authGateway,
        pageRepository: pageRepository,
      ),
      deletePage: DeletePageInTemplateUseCase(
        authGateway: container.authGateway,
        pageRepository: pageRepository,
      ),
      createContainer: CreateContainerInTemplateUseCase(
        authGateway: container.authGateway,
        containerRepository: containerRepository,
      ),
      updateContainer: UpdateContainerInTemplateUseCase(
        authGateway: container.authGateway,
        containerRepository: containerRepository,
      ),
      deleteContainer: DeleteContainerInTemplateUseCase(
        authGateway: container.authGateway,
        containerRepository: containerRepository,
      ),
      reorderContainer: ReorderContainerInTemplateUseCase(
        authGateway: container.authGateway,
        reorderContainerUseCase: ReorderContainerUseCase(
          containerRepository: containerRepository,
        ),
      ),
      duplicateContainer: DuplicateContainerInTemplateUseCase(
        authGateway: container.authGateway,
        duplicateContainerUseCase: DuplicateContainerUseCase(
          containerRepository: containerRepository,
          columnRepository: columnRepository,
          widgetRepository: widgetRepository,
        ),
      ),
      createColumn: CreateColumnInTemplateUseCase(
        authGateway: container.authGateway,
        columnRepository: columnRepository,
      ),
      updateColumn: UpdateColumnInTemplateUseCase(
        authGateway: container.authGateway,
        columnRepository: columnRepository,
      ),
      deleteColumn: DeleteColumnInTemplateUseCase(
        authGateway: container.authGateway,
        columnRepository: columnRepository,
      ),
      createWidget: CreateWidgetInTemplateUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      updateWidget: UpdateWidgetInTemplateUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      deleteWidget: DeleteWidgetInTemplateUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      moveWidget: MoveWidgetInTemplateUseCase(
        authGateway: container.authGateway,
        widgetRepository: widgetRepository,
      ),
      updateMenu: UpdateTemplateMenuUseCase(
        authGateway: container.authGateway,
        menuRepository: menuRepository,
      ),
      listAreas: ListAreasForTemplateUseCase(
        authGateway: container.authGateway,
        areaRepository: areaRepository,
      ),
      listSizes: ListSizesForTemplateUseCase(
        authGateway: container.authGateway,
        sizeRepository: sizeRepository,
      ),
    );
  }
}
