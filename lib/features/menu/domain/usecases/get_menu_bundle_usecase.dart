import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';

/// Use case for fetching a single menu bundle by ID
class GetMenuBundleUseCase {
  final MenuBundleRepository repository;

  const GetMenuBundleUseCase({required this.repository});

  Future<Result<MenuBundle, DomainError>> execute(int id) =>
      repository.getById(id);
}
