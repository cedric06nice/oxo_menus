import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Creates a page in a template (content / header / footer).
///
/// Authorisation: admin only. Non-admin and anonymous viewers receive
/// [UnauthorizedError] without the repository being touched. The page type and
/// index are taken from the input verbatim so a single use case can serve
/// "Add Page" (`PageType.content` at the end), "Add Header"
/// (`PageType.header`, index 0), and "Add Footer" (`PageType.footer`,
/// index 0).
class CreatePageInTemplateUseCase extends UseCase<CreatePageInput, Page> {
  CreatePageInTemplateUseCase({
    required AuthGateway authGateway,
    required PageRepository pageRepository,
  }) : _authGateway = authGateway,
       _pageRepository = pageRepository;

  final AuthGateway _authGateway;
  final PageRepository _pageRepository;

  @override
  Future<Result<Page, DomainError>> execute(CreatePageInput input) async {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return const Failure<Page, DomainError>(UnauthorizedError());
    }
    return _pageRepository.create(input);
  }
}
