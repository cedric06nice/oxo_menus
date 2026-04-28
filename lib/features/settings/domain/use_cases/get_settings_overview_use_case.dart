import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/settings/domain/entities/settings_overview.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Returns a [SettingsOverview] snapshot built from the current
/// [AuthGateway] and [AdminViewAsUserGateway] state.
///
/// Synchronous because both gateways already hold the resolved values — no
/// I/O is needed to render the Settings screen.
class GetSettingsOverviewUseCase
    extends SyncUseCase<NoInput, SettingsOverview> {
  GetSettingsOverviewUseCase({
    required AuthGateway authGateway,
    required AdminViewAsUserGateway adminViewAsUserGateway,
  }) : _authGateway = authGateway,
       _adminViewAsUserGateway = adminViewAsUserGateway;

  final AuthGateway _authGateway;
  final AdminViewAsUserGateway _adminViewAsUserGateway;

  @override
  Result<SettingsOverview, DomainError> execute(NoInput input) {
    final user = _authGateway.currentUser;
    final isAdmin = user?.role == UserRole.admin;
    return Success(
      SettingsOverview(
        user: user,
        isAdmin: isAdmin,
        viewAsUser: _adminViewAsUserGateway.currentValue,
      ),
    );
  }
}
