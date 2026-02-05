import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart';

/// Repository interface for Size operations
abstract class SizeRepository {
  /// Get all available sizes
  Future<Result<List<Size>, DomainError>> getAll();

  /// Get size by ID
  Future<Result<Size, DomainError>> getById(int id);
}
