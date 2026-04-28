import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/home/domain/entities/home_overview.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Returns a [HomeOverview] snapshot built from the current [AuthGateway]
/// state.
///
/// Synchronous because the gateway already holds the resolved auth status —
/// no I/O is needed to render the home screen. The use case exists so the
/// `HomeViewModel` depends on a feature-shaped abstraction and not on the
/// gateway directly.
class GetHomeOverviewUseCase extends SyncUseCase<NoInput, HomeOverview> {
  GetHomeOverviewUseCase({required AuthGateway gateway}) : _gateway = gateway;

  final AuthGateway _gateway;

  @override
  Result<HomeOverview, DomainError> execute(NoInput input) {
    final user = _gateway.currentUser;
    final isAdmin = user?.role == UserRole.admin;
    return Success(HomeOverview(user: user, isAdmin: isAdmin));
  }
}
