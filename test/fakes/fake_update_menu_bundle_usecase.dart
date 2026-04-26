import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/usecases/update_menu_bundle_usecase.dart';

// ---------------------------------------------------------------------------
// Call-record type
// ---------------------------------------------------------------------------

final class UpdateMenuBundleCall {
  final UpdateMenuBundleInput input;
  const UpdateMenuBundleCall(this.input);
}

// ---------------------------------------------------------------------------
// FakeUpdateMenuBundleUseCase
// ---------------------------------------------------------------------------

/// A manual fake that extends [UpdateMenuBundleUseCase] and intercepts [execute].
class FakeUpdateMenuBundleUseCase extends UpdateMenuBundleUseCase {
  FakeUpdateMenuBundleUseCase()
    : super(repository: _ThrowMenuBundleRepository());

  final List<UpdateMenuBundleCall> calls = [];

  Result<MenuBundle, DomainError>? _stubResult;

  void stubExecute(Result<MenuBundle, DomainError> result) {
    _stubResult = result;
  }

  @override
  Future<Result<MenuBundle, DomainError>> execute(
    UpdateMenuBundleInput input,
  ) async {
    calls.add(UpdateMenuBundleCall(input));
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      'FakeUpdateMenuBundleUseCase: no stub configured — call stubExecute() first',
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
  Future<Result<List<MenuBundle>, DomainError>> findByIncludedMenu(
    int menuId,
  ) => throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<MenuBundle, DomainError>> create(CreateMenuBundleInput input) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<MenuBundle, DomainError>> update(UpdateMenuBundleInput input) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');
}
