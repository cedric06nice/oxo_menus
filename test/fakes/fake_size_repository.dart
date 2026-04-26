import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

sealed class SizeCall {
  const SizeCall();
}

final class GetAllSizesCall extends SizeCall {
  const GetAllSizesCall();
}

final class GetSizeByIdCall extends SizeCall {
  final int id;
  const GetSizeByIdCall({required this.id});
}

final class CreateSizeCall extends SizeCall {
  final CreateSizeInput input;
  const CreateSizeCall({required this.input});
}

final class UpdateSizeCall extends SizeCall {
  final UpdateSizeInput input;
  const UpdateSizeCall({required this.input});
}

final class DeleteSizeCall extends SizeCall {
  final int id;
  const DeleteSizeCall({required this.id});
}

// ---------------------------------------------------------------------------
// FakeSizeRepository
// ---------------------------------------------------------------------------

/// Manual fake for [SizeRepository].
///
/// Every call is recorded in [calls] as a typed [SizeCall].
/// Return values are configured via `when*` setters before the call.
/// Unconfigured methods throw [StateError] immediately.
class FakeSizeRepository implements SizeRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<SizeCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<List<Size>, DomainError>? _getAllResponse;
  Result<Size, DomainError>? _getByIdResponse;
  Result<Size, DomainError>? _createResponse;
  Result<Size, DomainError>? _updateResponse;
  Result<void, DomainError>? _deleteResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenGetAll(Result<List<Size>, DomainError> response) {
    _getAllResponse = response;
  }

  void whenGetById(Result<Size, DomainError> response) {
    _getByIdResponse = response;
  }

  void whenCreate(Result<Size, DomainError> response) {
    _createResponse = response;
  }

  void whenUpdate(Result<Size, DomainError> response) {
    _updateResponse = response;
  }

  void whenDelete(Result<void, DomainError> response) {
    _deleteResponse = response;
  }

  // -------------------------------------------------------------------------
  // SizeRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<List<Size>, DomainError>> getAll() async {
    calls.add(const GetAllSizesCall());
    if (_getAllResponse != null) {
      return _getAllResponse!;
    }
    throw StateError('FakeSizeRepository: no response configured for getAll()');
  }

  @override
  Future<Result<Size, DomainError>> getById(int id) async {
    calls.add(GetSizeByIdCall(id: id));
    if (_getByIdResponse != null) {
      return _getByIdResponse!;
    }
    throw StateError(
      'FakeSizeRepository: no response configured for getById()',
    );
  }

  @override
  Future<Result<Size, DomainError>> create(CreateSizeInput input) async {
    calls.add(CreateSizeCall(input: input));
    if (_createResponse != null) {
      return _createResponse!;
    }
    throw StateError('FakeSizeRepository: no response configured for create()');
  }

  @override
  Future<Result<Size, DomainError>> update(UpdateSizeInput input) async {
    calls.add(UpdateSizeCall(input: input));
    if (_updateResponse != null) {
      return _updateResponse!;
    }
    throw StateError('FakeSizeRepository: no response configured for update()');
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    calls.add(DeleteSizeCall(id: id));
    if (_deleteResponse != null) {
      return _deleteResponse!;
    }
    throw StateError('FakeSizeRepository: no response configured for delete()');
  }

  // -------------------------------------------------------------------------
  // Convenience call-count helpers
  // -------------------------------------------------------------------------

  List<GetAllSizesCall> get getAllCalls =>
      calls.whereType<GetAllSizesCall>().toList();
  List<GetSizeByIdCall> get getByIdCalls =>
      calls.whereType<GetSizeByIdCall>().toList();
  List<CreateSizeCall> get createCalls =>
      calls.whereType<CreateSizeCall>().toList();
  List<UpdateSizeCall> get updateCalls =>
      calls.whereType<UpdateSizeCall>().toList();
  List<DeleteSizeCall> get deleteCalls =>
      calls.whereType<DeleteSizeCall>().toList();
}
