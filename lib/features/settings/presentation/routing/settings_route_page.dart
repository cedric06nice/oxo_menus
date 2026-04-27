import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_app_version_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_settings_overview_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/request_password_reset_use_case.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/set_admin_view_as_user_use_case.dart';
import 'package:oxo_menus/features/settings/presentation/routing/settings_router.dart';
import 'package:oxo_menus/features/settings/presentation/screens/settings_screen.dart';
import 'package:oxo_menus/features/settings/presentation/view_models/settings_view_model.dart';

/// View-model factory used by [SettingsRoutePage].
typedef SettingsViewModelBuilder =
    SettingsViewModel Function(AppContainer container, SettingsRouter router);

/// Stack entry for the settings screen.
///
/// Builds the use cases → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and
/// reused across rebuilds; [disposeResources] tears it down when the page
/// leaves the stack for good.
///
/// Tests inject a custom [viewModelBuilder] to bypass the production
/// gateways; the default builder pulls them from the container — including
/// a default [PackageInfoAppVersionGateway] when the container does not
/// expose one.
class SettingsRoutePage extends RoutePage {
  SettingsRoutePage({
    required this.router,
    SettingsViewModelBuilder? viewModelBuilder,
  }) : _viewModelBuilder = viewModelBuilder ?? _defaultBuilder;

  final SettingsRouter router;
  final SettingsViewModelBuilder _viewModelBuilder;
  SettingsViewModel? _viewModel;

  @override
  Object get identity => 'settings';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= _viewModelBuilder(container, router);
    return SettingsScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }

  static SettingsViewModel _defaultBuilder(
    AppContainer container,
    SettingsRouter router,
  ) {
    return SettingsViewModel(
      getOverview: GetSettingsOverviewUseCase(
        authGateway: container.authGateway,
        adminViewAsUserGateway: container.adminViewAsUserGateway,
      ),
      getAppVersion: GetAppVersionUseCase(gateway: container.appVersionGateway),
      requestPasswordReset: RequestPasswordResetUseCase(
        authGateway: container.authGateway,
      ),
      logout: LogoutUseCase(authGateway: container.authGateway),
      setAdminViewAsUser: SetAdminViewAsUserUseCase(
        gateway: container.adminViewAsUserGateway,
      ),
      adminViewAsUserGateway: container.adminViewAsUserGateway,
      router: router,
    );
  }
}
