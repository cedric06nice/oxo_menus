import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Input for [ListSizesForAdminUseCase].
///
/// Wraps the optional status filter so the use case keeps the standard
/// `execute(input)` shape; defaults to `'all'` (no narrowing).
final class ListSizesForAdminInput {
  const ListSizesForAdminInput({this.statusFilter = 'all'});

  /// One of `'all' | 'draft' | 'published' | 'archived'`. Anything other
  /// than `'all'` narrows the response to sizes whose `status.name` matches.
  final String statusFilter;

  @override
  bool operator ==(Object other) =>
      other is ListSizesForAdminInput && other.statusFilter == statusFilter;

  @override
  int get hashCode => statusFilter.hashCode;
}

/// Lists every page size for the admin sizes screen.
///
/// Authorisation rule:
/// - **Admin** — every size, every status; optional status filter applied
///   client-side after the repository call.
/// - **Non-admin / anonymous** — never reaches the repository; returns
///   [UnauthorizedError].
class ListSizesForAdminUseCase
    extends UseCase<ListSizesForAdminInput, List<Size>> {
  ListSizesForAdminUseCase({
    required AuthGateway authGateway,
    required SizeRepository sizeRepository,
  }) : _authGateway = authGateway,
       _sizeRepository = sizeRepository;

  final AuthGateway _authGateway;
  final SizeRepository _sizeRepository;

  @override
  Future<Result<List<Size>, DomainError>> execute(
    ListSizesForAdminInput input,
  ) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<List<Size>, DomainError>(UnauthorizedError());
    }
    final result = await _sizeRepository.getAll();
    return result.fold(
      onSuccess: (sizes) {
        if (input.statusFilter == 'all') {
          return Success<List<Size>, DomainError>(sizes);
        }
        return Success<List<Size>, DomainError>(
          sizes.where((s) => s.status.name == input.statusFilter).toList(),
        );
      },
      onFailure: (error) => Failure<List<Size>, DomainError>(error),
    );
  }
}
