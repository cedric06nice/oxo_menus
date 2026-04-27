import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/create_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/delete_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/list_sizes_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/update_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_router.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/screens/admin_sizes_screen.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/view_models/admin_sizes_view_model.dart';
import 'package:oxo_menus/features/menu/data/repositories/size_repository_impl.dart';

/// View-model factory used by [AdminSizesRoutePage].
typedef AdminSizesViewModelBuilder =
    AdminSizesViewModel Function(
      AppContainer container,
      AdminSizesRouter router,
    );

/// Stack entry for the admin sizes screen.
///
/// Builds the use cases → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and
/// reused across rebuilds; [disposeResources] tears it down when the page
/// leaves the stack for good.
///
/// Tests inject a custom [viewModelBuilder] to bypass the production
/// repositories.
class AdminSizesRoutePage extends RoutePage {
  AdminSizesRoutePage({
    required this.router,
    AdminSizesViewModelBuilder? viewModelBuilder,
  }) : _viewModelBuilder = viewModelBuilder ?? _defaultBuilder;

  final AdminSizesRouter router;
  final AdminSizesViewModelBuilder _viewModelBuilder;
  AdminSizesViewModel? _viewModel;

  @override
  Object get identity => 'admin-sizes';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= _viewModelBuilder(container, router);
    return AdminSizesScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }

  static AdminSizesViewModel _defaultBuilder(
    AppContainer container,
    AdminSizesRouter router,
  ) {
    final sizeRepository = SizeRepositoryImpl(
      dataSource: container.directusDataSource,
    );
    return AdminSizesViewModel(
      listSizes: ListSizesForAdminUseCase(
        authGateway: container.authGateway,
        sizeRepository: sizeRepository,
      ),
      createSize: CreateSizeUseCase(
        authGateway: container.authGateway,
        sizeRepository: sizeRepository,
      ),
      updateSize: UpdateSizeUseCase(
        authGateway: container.authGateway,
        sizeRepository: sizeRepository,
      ),
      deleteSize: DeleteSizeUseCase(
        authGateway: container.authGateway,
        sizeRepository: sizeRepository,
      ),
      authGateway: container.authGateway,
      connectivityGateway: container.connectivityGateway,
      router: router,
    );
  }
}
