import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/usecases/list_sizes_usecase.dart';

// ---------------------------------------------------------------------------
// Call-record type
// ---------------------------------------------------------------------------

/// Records a single [FakeListSizesUseCase.execute] call.
final class ListSizesCall {
  final String? statusFilter;
  const ListSizesCall({this.statusFilter});
}

// ---------------------------------------------------------------------------
// FakeListSizesUseCase
// ---------------------------------------------------------------------------

/// A manual fake that extends [ListSizesUseCase] and intercepts [execute].
///
/// Usage:
/// ```dart
/// final fake = FakeListSizesUseCase();
/// fake.stubExecute(Success([size1, size2]));
/// await fake.execute(statusFilter: 'published');
/// expect(fake.calls.single.statusFilter, 'published');
/// ```
class FakeListSizesUseCase extends ListSizesUseCase {
  FakeListSizesUseCase() : super(sizeRepository: _ThrowSizeRepository());

  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<ListSizesCall> calls = [];

  // -------------------------------------------------------------------------
  // Response stub
  // -------------------------------------------------------------------------

  Result<List<Size>, DomainError>? _stubResult;

  /// Configures all subsequent [execute] calls to return [result].
  void stubExecute(Result<List<Size>, DomainError> result) {
    _stubResult = result;
  }

  // -------------------------------------------------------------------------
  // Override
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<Size>, DomainError>> execute({
    String? statusFilter,
  }) async {
    calls.add(ListSizesCall(statusFilter: statusFilter));
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      'FakeListSizesUseCase: no stub configured — call stubExecute() first',
    );
  }
}

// ---------------------------------------------------------------------------
// Private stub repository (satisfies super constructor; never called)
// ---------------------------------------------------------------------------

class _ThrowSizeRepository implements SizeRepository {
  @override
  Future<Result<List<Size>, DomainError>> getAll() =>
      throw StateError('_ThrowSizeRepository should not be called');

  @override
  Future<Result<Size, DomainError>> getById(int id) =>
      throw StateError('_ThrowSizeRepository should not be called');

  @override
  Future<Result<Size, DomainError>> create(CreateSizeInput input) =>
      throw StateError('_ThrowSizeRepository should not be called');

  @override
  Future<Result<Size, DomainError>> update(UpdateSizeInput input) =>
      throw StateError('_ThrowSizeRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowSizeRepository should not be called');
}
