import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

sealed class PageCall {
  const PageCall();
}

final class CreatePageCall extends PageCall {
  final CreatePageInput input;
  const CreatePageCall({required this.input});
}

final class GetAllForMenuCall extends PageCall {
  final int menuId;
  const GetAllForMenuCall({required this.menuId});
}

final class GetPageByIdCall extends PageCall {
  final int id;
  const GetPageByIdCall({required this.id});
}

final class UpdatePageCall extends PageCall {
  final UpdatePageInput input;
  const UpdatePageCall({required this.input});
}

final class DeletePageCall extends PageCall {
  final int id;
  const DeletePageCall({required this.id});
}

final class ReorderPageCall extends PageCall {
  final int pageId;
  final int newIndex;
  const ReorderPageCall({required this.pageId, required this.newIndex});
}

// ---------------------------------------------------------------------------
// FakePageRepository
// ---------------------------------------------------------------------------

/// Manual fake for [PageRepository].
///
/// Every call is recorded in [calls] as a typed [PageCall].
/// Return values are configured via `when*` setters before the call.
/// Unconfigured methods throw [StateError] immediately.
class FakePageRepository implements PageRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<PageCall> calls = [];

  // -------------------------------------------------------------------------
  // Per-method response stubs
  // -------------------------------------------------------------------------

  Result<Page, DomainError>? _createResponse;
  Result<List<Page>, DomainError>? _getAllForMenuResponse;
  Result<Page, DomainError>? _getByIdResponse;
  Result<Page, DomainError>? _updateResponse;
  Result<void, DomainError>? _deleteResponse;
  Result<void, DomainError>? _reorderResponse;

  // -------------------------------------------------------------------------
  // Response setters
  // -------------------------------------------------------------------------

  void whenCreate(Result<Page, DomainError> response) {
    _createResponse = response;
  }

  void whenGetAllForMenu(Result<List<Page>, DomainError> response) {
    _getAllForMenuResponse = response;
  }

  void whenGetById(Result<Page, DomainError> response) {
    _getByIdResponse = response;
  }

  void whenUpdate(Result<Page, DomainError> response) {
    _updateResponse = response;
  }

  void whenDelete(Result<void, DomainError> response) {
    _deleteResponse = response;
  }

  void whenReorder(Result<void, DomainError> response) {
    _reorderResponse = response;
  }

  // -------------------------------------------------------------------------
  // PageRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<Page, DomainError>> create(CreatePageInput input) async {
    calls.add(CreatePageCall(input: input));
    if (_createResponse != null) {
      return _createResponse!;
    }
    throw StateError('FakePageRepository: no response configured for create()');
  }

  @override
  Future<Result<List<Page>, DomainError>> getAllForMenu(int menuId) async {
    calls.add(GetAllForMenuCall(menuId: menuId));
    if (_getAllForMenuResponse != null) {
      return _getAllForMenuResponse!;
    }
    throw StateError(
      'FakePageRepository: no response configured for getAllForMenu()',
    );
  }

  @override
  Future<Result<Page, DomainError>> getById(int id) async {
    calls.add(GetPageByIdCall(id: id));
    if (_getByIdResponse != null) {
      return _getByIdResponse!;
    }
    throw StateError(
      'FakePageRepository: no response configured for getById()',
    );
  }

  @override
  Future<Result<Page, DomainError>> update(UpdatePageInput input) async {
    calls.add(UpdatePageCall(input: input));
    if (_updateResponse != null) {
      return _updateResponse!;
    }
    throw StateError('FakePageRepository: no response configured for update()');
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    calls.add(DeletePageCall(id: id));
    if (_deleteResponse != null) {
      return _deleteResponse!;
    }
    throw StateError('FakePageRepository: no response configured for delete()');
  }

  @override
  Future<Result<void, DomainError>> reorder(int pageId, int newIndex) async {
    calls.add(ReorderPageCall(pageId: pageId, newIndex: newIndex));
    if (_reorderResponse != null) {
      return _reorderResponse!;
    }
    throw StateError(
      'FakePageRepository: no response configured for reorder()',
    );
  }

  // -------------------------------------------------------------------------
  // Convenience call-count helpers
  // -------------------------------------------------------------------------

  List<CreatePageCall> get createCalls =>
      calls.whereType<CreatePageCall>().toList();
  List<GetAllForMenuCall> get getAllForMenuCalls =>
      calls.whereType<GetAllForMenuCall>().toList();
  List<GetPageByIdCall> get getByIdCalls =>
      calls.whereType<GetPageByIdCall>().toList();
  List<UpdatePageCall> get updateCalls =>
      calls.whereType<UpdatePageCall>().toList();
  List<DeletePageCall> get deleteCalls =>
      calls.whereType<DeletePageCall>().toList();
  List<ReorderPageCall> get reorderCalls =>
      calls.whereType<ReorderPageCall>().toList();
}
