import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';

/// Use case for deleting a menu bundle
class DeleteMenuBundleUseCase {
  final MenuBundleRepository repository;

  const DeleteMenuBundleUseCase({required this.repository});

  Future<Result<void, DomainError>> execute(int id) => repository.delete(id);
}
