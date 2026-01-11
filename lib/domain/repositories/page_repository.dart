import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/page.dart';

part 'page_repository.freezed.dart';

/// Repository interface for Page operations
abstract class PageRepository {
  /// Create a new page
  Future<Result<Page, DomainError>> create(CreatePageInput input);

  /// Get all pages for a menu
  Future<Result<List<Page>, DomainError>> getAllForMenu(String menuId);

  /// Get page by ID
  Future<Result<Page, DomainError>> getById(String id);

  /// Update an existing page
  Future<Result<Page, DomainError>> update(UpdatePageInput input);

  /// Delete a page
  Future<Result<void, DomainError>> delete(String id);

  /// Reorder a page within its menu
  Future<Result<void, DomainError>> reorder(String pageId, int newIndex);
}

/// Input for creating a page
@freezed
abstract class CreatePageInput with _$CreatePageInput {
  const CreatePageInput._();

  const factory CreatePageInput({
    required String menuId,
    required String name,
    required int index,
  }) = _CreatePageInput;
}

/// Input for updating a page
@freezed
abstract class UpdatePageInput with _$UpdatePageInput {
  const UpdatePageInput._();

  const factory UpdatePageInput({
    required String id,
    String? name,
    int? index,
  }) = _UpdatePageInput;
}
