import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';

/// Use case for updating a menu bundle
class UpdateMenuBundleUseCase {
  final MenuBundleRepository repository;

  const UpdateMenuBundleUseCase({required this.repository});

  Future<Result<MenuBundle, DomainError>> execute(
    UpdateMenuBundleInput input,
  ) => repository.update(input);
}
