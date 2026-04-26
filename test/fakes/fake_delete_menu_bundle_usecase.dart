import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/usecases/delete_menu_bundle_usecase.dart';

// ---------------------------------------------------------------------------
// Call-record type
// ---------------------------------------------------------------------------

final class DeleteMenuBundleCall {
  final int id;
  const DeleteMenuBundleCall(this.id);
}

// ---------------------------------------------------------------------------
// FakeDeleteMenuBundleUseCase
// ---------------------------------------------------------------------------

/// A manual fake that extends [DeleteMenuBundleUseCase] and intercepts [execute].
class FakeDeleteMenuBundleUseCase extends DeleteMenuBundleUseCase {
  FakeDeleteMenuBundleUseCase()
      : super(repository: _ThrowMenuBundleRepository());

  final List<DeleteMenuBundleCall> calls = [];

  Result<void, DomainError>? _stubResult;

  void stubExecute(Result<void, DomainError> result) {
    _stubResult = result;
  }

  @override
  Future<Result<void, DomainError>> execute(int id) async {
    calls.add(DeleteMenuBundleCall(id));
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      'FakeDeleteMenuBundleUseCase: no stub configured — call stubExecute() first',
    );
  }
}

class _ThrowMenuBundleRepository implements MenuBundleRepository {
  @override
  Future<Result<List<MenuBundle>, DomainError>> getAll() =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<MenuBundle, DomainError>> getById(int id) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<List<MenuBundle>, DomainError>> findByIncludedMenu(int menuId) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<MenuBundle, DomainError>> create(
    CreateMenuBundleInput input,
  ) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<MenuBundle, DomainError>> update(
    UpdateMenuBundleInput input,
  ) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');
}
