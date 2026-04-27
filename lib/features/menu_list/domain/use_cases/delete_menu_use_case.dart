import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';

/// Deletes a menu by id. Thin wrapper around [MenuRepository.delete] that
/// gives the [MenuListViewModel] a use-case-shaped dependency.
class DeleteMenuUseCase extends UseCase<int, void> {
  DeleteMenuUseCase({required MenuRepository menuRepository})
    : _menuRepository = menuRepository;

  final MenuRepository _menuRepository;

  @override
  Future<Result<void, DomainError>> execute(int input) {
    return _menuRepository.delete(input);
  }
}
