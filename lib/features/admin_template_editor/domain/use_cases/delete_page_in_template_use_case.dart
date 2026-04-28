import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Deletes a page (content / header / footer) from a template.
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched.
class DeletePageInTemplateUseCase extends UseCase<int, void> {
  DeletePageInTemplateUseCase({
    required AuthGateway authGateway,
    required PageRepository pageRepository,
  }) : _authGateway = authGateway,
       _pageRepository = pageRepository;

  final AuthGateway _authGateway;
  final PageRepository _pageRepository;

  @override
  Future<Result<void, DomainError>> execute(int pageId) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<void, DomainError>(UnauthorizedError());
    }
    return _pageRepository.delete(pageId);
  }
}
