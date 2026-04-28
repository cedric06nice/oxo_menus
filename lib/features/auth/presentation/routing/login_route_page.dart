import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/auth/domain/use_cases/login_use_case.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/screens/login_screen.dart';
import 'package:oxo_menus/features/auth/presentation/view_models/login_view_model.dart';

/// Stack entry for the login screen.
///
/// Builds the use case → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and reused
/// across rebuilds; [disposeResources] tears it down when the page leaves the
/// stack for good.
class LoginRoutePage extends RoutePage {
  LoginRoutePage({required this.router});

  final LoginRouter router;
  LoginViewModel? _viewModel;

  @override
  Object get identity => 'login';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= LoginViewModel(
      login: LoginUseCase(gateway: container.authGateway),
      router: router,
      connectivityGateway: container.connectivityGateway,
    );
    return LoginScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }
}
