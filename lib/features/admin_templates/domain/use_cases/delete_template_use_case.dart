import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';

/// Deletes a template by id. Thin wrapper around [MenuRepository.delete] that
/// gives the admin templates view model a use-case-shaped dependency.
class DeleteTemplateUseCase extends UseCase<int, void> {
  DeleteTemplateUseCase({required MenuRepository menuRepository})
    : _menuRepository = menuRepository;

  final MenuRepository _menuRepository;

  @override
  Future<Result<void, DomainError>> execute(int input) {
    return _menuRepository.delete(input);
  }
}
