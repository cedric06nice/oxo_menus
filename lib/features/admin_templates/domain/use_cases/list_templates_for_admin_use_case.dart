import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Input for [ListTemplatesForAdminUseCase].
///
/// Wraps the optional status filter so the use case keeps the standard
/// `execute(input)` shape; defaults to `'all'` (no narrowing).
final class ListTemplatesForAdminInput {
  const ListTemplatesForAdminInput({this.statusFilter = 'all'});

  /// One of `'all' | 'draft' | 'published' | 'archived'`. Anything other
  /// than `'all'` narrows the response to menus whose `status.name` matches.
  final String statusFilter;

  @override
  bool operator ==(Object other) =>
      other is ListTemplatesForAdminInput && other.statusFilter == statusFilter;

  @override
  int get hashCode => statusFilter.hashCode;
}

/// Lists every template (menu) for the admin templates screen.
///
/// Authorisation rule:
/// - **Admin** — every menu, every status, every area; optional status
///   filter applied client-side after the repository call.
/// - **Non-admin / anonymous** — never reaches the repository; returns
///   [UnauthorizedError].
class ListTemplatesForAdminUseCase
    extends UseCase<ListTemplatesForAdminInput, List<Menu>> {
  ListTemplatesForAdminUseCase({
    required AuthGateway authGateway,
    required MenuRepository menuRepository,
  }) : _authGateway = authGateway,
       _menuRepository = menuRepository;

  final AuthGateway _authGateway;
  final MenuRepository _menuRepository;

  @override
  Future<Result<List<Menu>, DomainError>> execute(
    ListTemplatesForAdminInput input,
  ) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<List<Menu>, DomainError>(UnauthorizedError());
    }
    final result = await _menuRepository.listAll(onlyPublished: false);
    return result.fold(
      onSuccess: (menus) {
        if (input.statusFilter == 'all') {
          return Success<List<Menu>, DomainError>(menus);
        }
        return Success<List<Menu>, DomainError>(
          menus.where((m) => m.status.name == input.statusFilter).toList(),
        );
      },
      onFailure: (error) => Failure<List<Menu>, DomainError>(error),
    );
  }
}
