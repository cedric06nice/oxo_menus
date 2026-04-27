import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/home/domain/use_cases/get_home_overview_use_case.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_router.dart';
import 'package:oxo_menus/features/home/presentation/screens/home_screen.dart';
import 'package:oxo_menus/features/home/presentation/view_models/home_view_model.dart';

/// Stack entry for the home screen.
///
/// Builds the use case → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and reused
/// across rebuilds; [disposeResources] tears it down when the page leaves the
/// stack for good.
///
/// [clock] is used by the view model to compute the time-of-day greeting at
/// construction time. Defaults to `DateTime.now`; tests inject a fixed clock
/// to assert the greeting deterministically.
class HomeRoutePage extends RoutePage {
  HomeRoutePage({required this.router, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final HomeRouter router;
  final DateTime Function() _clock;
  HomeViewModel? _viewModel;

  @override
  Object get identity => 'home';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= HomeViewModel(
      getHomeOverview: GetHomeOverviewUseCase(gateway: container.authGateway),
      router: router,
      clock: _clock,
    );
    return HomeScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }
}
