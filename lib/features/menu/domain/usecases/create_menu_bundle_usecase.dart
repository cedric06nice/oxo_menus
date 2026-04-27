import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';

/// Use case for creating a menu bundle
class CreateMenuBundleUseCase {
  final MenuBundleRepository repository;

  const CreateMenuBundleUseCase({required this.repository});

  Future<Result<MenuBundle, DomainError>> execute(
    CreateMenuBundleInput input,
  ) async {
    if (input.name.trim().isEmpty) {
      return const Failure(ValidationError('Bundle name cannot be empty'));
    }
    return repository.create(input);
  }
}
