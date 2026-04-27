import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Creates a new bundle for the admin-exportable-menus screen.
///
/// Authorisation rule:
/// - **Admin** — validates that [CreateMenuBundleInput.name] is non-empty
///   after trimming, then forwards the input to the repository.
/// - **Non-admin / anonymous** — returns [UnauthorizedError] without touching
///   the repository.
///
/// Validation rule:
/// - An empty / whitespace-only name returns [ValidationError]. The admin
///   screen disables the save button in that case, but the use case still
///   gates the call as a defence-in-depth check.
class CreateMenuBundleForAdminUseCase
    extends UseCase<CreateMenuBundleInput, MenuBundle> {
  CreateMenuBundleForAdminUseCase({
    required AuthGateway authGateway,
    required MenuBundleRepository bundleRepository,
  }) : _authGateway = authGateway,
       _bundleRepository = bundleRepository;

  final AuthGateway _authGateway;
  final MenuBundleRepository _bundleRepository;

  @override
  Future<Result<MenuBundle, DomainError>> execute(
    CreateMenuBundleInput input,
  ) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<MenuBundle, DomainError>(UnauthorizedError());
    }
    if (input.name.trim().isEmpty) {
      return const Failure<MenuBundle, DomainError>(
        ValidationError('Bundle name cannot be empty'),
      );
    }
    return _bundleRepository.create(input);
  }
}
