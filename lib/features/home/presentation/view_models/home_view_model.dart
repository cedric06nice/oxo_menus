import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/home/domain/entities/home_overview.dart';
import 'package:oxo_menus/features/home/domain/use_cases/get_home_overview_use_case.dart';
import 'package:oxo_menus/features/home/presentation/helpers/home_helpers.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_router.dart';
import 'package:oxo_menus/features/home/presentation/state/home_state.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// View model that owns the home screen's state.
///
/// Eagerly resolves the [HomeOverview] from [GetHomeOverviewUseCase] at
/// construction time so the screen renders fully populated on first frame —
/// the snapshot is sync because the gateway already holds the auth status.
/// Knows nothing about widgets, `BuildContext`, or Riverpod.
class HomeViewModel extends ViewModel<HomeState> {
  HomeViewModel({
    required GetHomeOverviewUseCase getHomeOverview,
    required HomeRouter router,
    required DateTime Function() clock,
  }) : _router = router,
       super(_initialStateFor(getHomeOverview, clock));

  final HomeRouter _router;

  static HomeState _initialStateFor(
    GetHomeOverviewUseCase getHomeOverview,
    DateTime Function() clock,
  ) {
    final result = getHomeOverview.execute(NoInput.instance);
    return result.fold(
      onSuccess: (overview) {
        final user = overview.user;
        final greeting = buildGreeting(_displayName(user), clock());
        return HomeState(
          user: user,
          isAdmin: overview.isAdmin,
          greeting: greeting,
        );
      },
      onFailure: (_) => const HomeState(),
    );
  }

  static String _displayName(User? user) {
    if (user == null) {
      return 'User';
    }
    final first = user.firstName;
    if (first != null && first.isNotEmpty) {
      return first;
    }
    final email = user.email;
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) {
      return 'User';
    }
    return email.substring(0, atIndex);
  }

  void goToMenus() => _router.goToMenus();

  void goToAdminTemplates() => _router.goToAdminTemplates();

  void goToAdminTemplateCreate() => _router.goToAdminTemplateCreate();

  void goToAdminExportableMenus() => _router.goToAdminExportableMenus();
}
