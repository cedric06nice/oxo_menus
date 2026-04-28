import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

/// Input for [CreateTemplateUseCase].
///
/// Captures the four fields the admin-template-create form collects: name,
/// version, the chosen page size, and an optional area. The use case fixes the
/// status to [Status.draft] — only the editor flow promotes a template to
/// `published`.
final class CreateTemplateInput {
  const CreateTemplateInput({
    required this.name,
    required this.version,
    required this.sizeId,
    this.areaId,
  });

  final String name;
  final String version;
  final int sizeId;
  final int? areaId;

  @override
  bool operator ==(Object other) =>
      other is CreateTemplateInput &&
      other.name == name &&
      other.version == version &&
      other.sizeId == sizeId &&
      other.areaId == areaId;

  @override
  int get hashCode => Object.hash(name, version, sizeId, areaId);
}

/// Creates a new template (a [Menu] in `draft` status) for the
/// admin-template-creator screen.
///
/// Authorisation rule:
/// - **Admin** — forwards the request to [MenuRepository.create] with
///   `status: Status.draft`. The `sizeId` is required; `areaId` is optional.
/// - **Non-admin / anonymous** — never reaches the repository; returns
///   [UnauthorizedError].
class CreateTemplateUseCase extends UseCase<CreateTemplateInput, Menu> {
  CreateTemplateUseCase({
    required AuthGateway authGateway,
    required MenuRepository menuRepository,
  }) : _authGateway = authGateway,
       _menuRepository = menuRepository;

  final AuthGateway _authGateway;
  final MenuRepository _menuRepository;

  @override
  Future<Result<Menu, DomainError>> execute(CreateTemplateInput input) {
    final user = _authGateway.currentUser;
    if (user == null || user.role != UserRole.admin) {
      return Future.value(
        const Failure<Menu, DomainError>(UnauthorizedError()),
      );
    }
    return _menuRepository.create(
      CreateMenuInput(
        name: input.name,
        version: input.version,
        status: Status.draft,
        sizeId: input.sizeId,
        areaId: input.areaId,
      ),
    );
  }
}
