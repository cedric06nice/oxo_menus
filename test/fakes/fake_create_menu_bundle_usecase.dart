import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/create_menu_bundle_usecase.dart';

// ---------------------------------------------------------------------------
// Call-record type
// ---------------------------------------------------------------------------

final class CreateMenuBundleCall {
  final CreateMenuBundleInput input;
  const CreateMenuBundleCall(this.input);
}

// ---------------------------------------------------------------------------
// FakeCreateMenuBundleUseCase
// ---------------------------------------------------------------------------

/// A manual fake that extends [CreateMenuBundleUseCase] and intercepts [execute].
class FakeCreateMenuBundleUseCase extends CreateMenuBundleUseCase {
  FakeCreateMenuBundleUseCase()
    : super(repository: _ThrowMenuBundleRepository());

  final List<CreateMenuBundleCall> calls = [];

  Result<MenuBundle, DomainError>? _stubResult;

  void stubExecute(Result<MenuBundle, DomainError> result) {
    _stubResult = result;
  }

  @override
  Future<Result<MenuBundle, DomainError>> execute(
    CreateMenuBundleInput input,
  ) async {
    calls.add(CreateMenuBundleCall(input));
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      'FakeCreateMenuBundleUseCase: no stub configured — call stubExecute() first',
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
