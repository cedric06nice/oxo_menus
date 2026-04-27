import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';

/// Use case for listing sizes with optional status filtering
class ListSizesUseCase {
  final SizeRepository sizeRepository;

  ListSizesUseCase({required this.sizeRepository});

  Future<Result<List<Size>, DomainError>> execute({
    String? statusFilter,
  }) async {
    final result = await sizeRepository.getAll();

    if (result.isFailure) return result;

    final sizes = result.valueOrNull!;

    if (statusFilter == null || statusFilter == 'all') {
      return Success(sizes);
    }

    return Success(sizes.where((s) => s.status.name == statusFilter).toList());
  }
}
