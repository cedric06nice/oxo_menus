import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/create_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_areas_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_sizes_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_router.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/screens/admin_template_creator_screen.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/view_models/admin_template_creator_view_model.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/shared/data/repositories/area_repository_impl.dart';

/// View-model factory used by [AdminTemplateCreatorRoutePage].
typedef AdminTemplateCreatorViewModelBuilder =
    AdminTemplateCreatorViewModel Function(
      AppContainer container,
      AdminTemplateCreatorRouter router,
    );

/// Stack entry for the admin template-creator screen.
///
/// Builds the use cases → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and
/// reused across rebuilds; [disposeResources] tears it down when the page
/// leaves the stack for good.
///
/// Tests inject a custom [viewModelBuilder] to bypass the production
/// repositories.
class AdminTemplateCreatorRoutePage extends RoutePage {
  AdminTemplateCreatorRoutePage({
    required this.router,
    AdminTemplateCreatorViewModelBuilder? viewModelBuilder,
  }) : _viewModelBuilder = viewModelBuilder ?? _defaultBuilder;

  final AdminTemplateCreatorRouter router;
  final AdminTemplateCreatorViewModelBuilder _viewModelBuilder;
  AdminTemplateCreatorViewModel? _viewModel;

  @override
  Object get identity => 'admin-template-create';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= _viewModelBuilder(container, router);
    return AdminTemplateCreatorScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }

  static AdminTemplateCreatorViewModel _defaultBuilder(
    AppContainer container,
    AdminTemplateCreatorRouter router,
  ) {
    final dataSource = container.directusDataSource;
    final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
    final sizeRepository = SizeRepositoryImpl(dataSource: dataSource);
    final areaRepository = AreaRepositoryImpl(dataSource: dataSource);
    return AdminTemplateCreatorViewModel(
      listSizes: ListSizesForCreatorUseCase(
        authGateway: container.authGateway,
        sizeRepository: sizeRepository,
      ),
      listAreas: ListAreasForCreatorUseCase(
        authGateway: container.authGateway,
        areaRepository: areaRepository,
      ),
      createTemplate: CreateTemplateUseCase(
        authGateway: container.authGateway,
        menuRepository: menuRepository,
      ),
      authGateway: container.authGateway,
      connectivityGateway: container.connectivityGateway,
      router: router,
    );
  }
}
