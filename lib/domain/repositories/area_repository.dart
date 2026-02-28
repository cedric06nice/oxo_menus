import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';

/// Repository interface for Area operations
abstract class AreaRepository {
  /// Get all areas
  Future<Result<List<Area>, DomainError>> getAll();
}
