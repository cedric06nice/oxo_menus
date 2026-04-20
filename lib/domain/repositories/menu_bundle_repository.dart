import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';

part 'menu_bundle_repository.freezed.dart';

/// Repository interface for MenuBundle operations
abstract class MenuBundleRepository {
  /// Get all bundles
  Future<Result<List<MenuBundle>, DomainError>> getAll();

  /// Get a bundle by its ID
  Future<Result<MenuBundle, DomainError>> getById(int id);

  /// Find every bundle that includes [menuId] in its [MenuBundle.menuIds].
  ///
  /// Used by the menu editor to know which bundles must be re-published when
  /// a particular menu's PDF preview is triggered.
  Future<Result<List<MenuBundle>, DomainError>> findByIncludedMenu(int menuId);

  /// Create a new bundle
  Future<Result<MenuBundle, DomainError>> create(CreateMenuBundleInput input);

  /// Update an existing bundle
  Future<Result<MenuBundle, DomainError>> update(UpdateMenuBundleInput input);

  /// Delete a bundle by ID
  Future<Result<void, DomainError>> delete(int id);
}

/// Input for creating a bundle
@freezed
abstract class CreateMenuBundleInput with _$CreateMenuBundleInput {
  const CreateMenuBundleInput._();

  const factory CreateMenuBundleInput({
    required String name,
    @Default([]) List<int> menuIds,
  }) = _CreateMenuBundleInput;
}

/// Input for updating a bundle (only non-null fields are applied)
@freezed
abstract class UpdateMenuBundleInput with _$UpdateMenuBundleInput {
  const UpdateMenuBundleInput._();

  const factory UpdateMenuBundleInput({
    required int id,
    String? name,
    List<int>? menuIds,
    String? pdfFileId,
  }) = _UpdateMenuBundleInput;
}
