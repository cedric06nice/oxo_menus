import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/repositories/area_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

sealed class AreaCall {
  const AreaCall();
}

final class GetAllAreasCall extends AreaCall {
  const GetAllAreasCall();
}

// ---------------------------------------------------------------------------
// FakeAreaRepository
// ---------------------------------------------------------------------------

/// Manual fake for [AreaRepository].
///
/// Every call is recorded in [calls] as a typed [AreaCall].
/// Return values are configured via `when*` setters before the call.
/// Unconfigured methods throw [StateError] immediately.
class FakeAreaRepository implements AreaRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<AreaCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<List<Area>, DomainError>? _getAllResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenGetAll(Result<List<Area>, DomainError> response) {
    _getAllResponse = response;
  }

  // -------------------------------------------------------------------------
  // AreaRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<Area>, DomainError>> getAll() async {
    calls.add(const GetAllAreasCall());
    if (_getAllResponse != null) {
      return _getAllResponse!;
    }
    throw StateError('FakeAreaRepository: no response configured for getAll()');
  }

  // -------------------------------------------------------------------------
  // Convenience call-count helpers
  // -------------------------------------------------------------------------

  List<GetAllAreasCall> get getAllCalls =>
      calls.whereType<GetAllAreasCall>().toList();
}
