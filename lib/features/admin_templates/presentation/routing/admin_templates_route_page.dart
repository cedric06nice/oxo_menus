import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_router.dart';
import 'package:oxo_menus/features/admin_templates/presentation/screens/admin_templates_screen.dart';
import 'package:oxo_menus/features/admin_templates/presentation/view_models/admin_templates_view_model.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';

/// View-model factory used by [AdminTemplatesRoutePage].
typedef AdminTemplatesViewModelBuilder =
    AdminTemplatesViewModel Function(
      AppContainer container,
      AdminTemplatesRouter router,
    );

/// Stack entry for the admin templates screen.
///
/// Builds the use cases → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and
/// reused across rebuilds; [disposeResources] tears it down when the page
/// leaves the stack for good.
///
/// Tests inject a custom [viewModelBuilder] to bypass the production
/// repositories.
class AdminTemplatesRoutePage extends RoutePage {
  AdminTemplatesRoutePage({
    required this.router,
    AdminTemplatesViewModelBuilder? viewModelBuilder,
  }) : _viewModelBuilder = viewModelBuilder ?? _defaultBuilder;

  final AdminTemplatesRouter router;
  final AdminTemplatesViewModelBuilder _viewModelBuilder;
  AdminTemplatesViewModel? _viewModel;

  @override
  Object get identity => 'admin-templates';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= _viewModelBuilder(container, router);
    return AdminTemplatesScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }

  static AdminTemplatesViewModel _defaultBuilder(
    AppContainer container,
    AdminTemplatesRouter router,
  ) {
    final menuRepository = MenuRepositoryImpl(
      dataSource: container.directusDataSource,
    );
    return AdminTemplatesViewModel(
      listTemplates: ListTemplatesForAdminUseCase(
        authGateway: container.authGateway,
        menuRepository: menuRepository,
      ),
      deleteTemplate: DeleteTemplateUseCase(menuRepository: menuRepository),
      authGateway: container.authGateway,
      connectivityGateway: container.connectivityGateway,
      router: router,
    );
  }
}
