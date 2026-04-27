import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';

/// Creates a new menu/template. Thin wrapper around [MenuRepository.create]
/// that gives the [MenuListViewModel] a use-case-shaped dependency.
class CreateMenuUseCase extends UseCase<CreateMenuInput, Menu> {
  CreateMenuUseCase({required MenuRepository menuRepository})
    : _menuRepository = menuRepository;

  final MenuRepository _menuRepository;

  @override
  Future<Result<Menu, DomainError>> execute(CreateMenuInput input) {
    return _menuRepository.create(input);
  }
}
