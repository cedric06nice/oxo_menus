import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';

/// Use case for listing all templates (menus) with optional status filtering
class ListTemplatesUseCase {
  final MenuRepository menuRepository;

  ListTemplatesUseCase({required this.menuRepository});

  Future<Result<List<Menu>, DomainError>> execute({
    String? statusFilter,
  }) async {
    final result = await menuRepository.listAll(onlyPublished: false);

    if (result.isFailure) return result;

    final menus = result.valueOrNull!;

    if (statusFilter == null || statusFilter == 'all') {
      return Success(menus);
    }

    return Success(menus.where((m) => m.status.name == statusFilter).toList());
  }
}
