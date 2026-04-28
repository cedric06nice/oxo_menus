import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_menu_bundle_usecase.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Publishes (regenerates) a bundle PDF for the admin-exportable-menus screen.
///
/// Wraps the heavy [PublishMenuBundleUseCase] with the admin auth gate so the
/// view model never reaches the inner use case for an unauthorised viewer. The
/// inner use case orchestrates fetching every included menu tree, rendering
/// the watermarked PDF in an isolate, and uploading or replacing the Directus
/// asset.
///
/// Authorisation rule:
/// - **Admin** — forwards the bundle id and returns the inner result.
/// - **Non-admin / anonymous** — returns [UnauthorizedError] without invoking
///   the inner use case.
class PublishMenuBundleForAdminUseCase extends UseCase<int, MenuBundle> {
  PublishMenuBundleForAdminUseCase({
    required AuthGateway authGateway,
    required PublishMenuBundleUseCase publishMenuBundleUseCase,
  }) : _authGateway = authGateway,
       _publish = publishMenuBundleUseCase;

  final AuthGateway _authGateway;
  final PublishMenuBundleUseCase _publish;

  @override
  Future<Result<MenuBundle, DomainError>> execute(int bundleId) {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return Future.value(
        const Failure<MenuBundle, DomainError>(UnauthorizedError()),
      );
    }
    return _publish.execute(bundleId);
  }
}
