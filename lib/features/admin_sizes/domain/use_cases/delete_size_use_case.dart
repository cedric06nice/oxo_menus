import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Deletes a page size on behalf of the admin sizes view model.
///
/// Authorisation rule:
/// - **Admin** — forwards the request to the repository.
/// - **Non-admin / anonymous** — never reaches the repository; returns
///   [UnauthorizedError].
class DeleteSizeUseCase extends UseCase<int, void> {
  DeleteSizeUseCase({
    required AuthGateway authGateway,
    required SizeRepository sizeRepository,
  }) : _authGateway = authGateway,
       _sizeRepository = sizeRepository;

  final AuthGateway _authGateway;
  final SizeRepository _sizeRepository;

  @override
  Future<Result<void, DomainError>> execute(int input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    return _sizeRepository.delete(input);
  }
}
