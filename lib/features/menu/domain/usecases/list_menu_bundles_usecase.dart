import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';

/// Use case for listing all menu bundles
class ListMenuBundlesUseCase {
  final MenuBundleRepository repository;

  const ListMenuBundlesUseCase({required this.repository});

  Future<Result<List<MenuBundle>, DomainError>> execute() =>
      repository.getAll();
}
