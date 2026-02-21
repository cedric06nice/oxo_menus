import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';

part 'menu_repository.freezed.dart';

/// Repository interface for Menu operations
abstract class MenuRepository {
  /// Create a new menu
  Future<Result<Menu, DomainError>> create(CreateMenuInput input);

  /// List all menus
  Future<Result<List<Menu>, DomainError>> listAll({bool onlyPublished = true});

  /// Get menu by ID
  Future<Result<Menu, DomainError>> getById(int id);

  /// Update an existing menu
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input);

  /// Delete a menu
  Future<Result<void, DomainError>> delete(int id);
}

/// Input for creating a menu
@freezed
abstract class CreateMenuInput with _$CreateMenuInput {
  const CreateMenuInput._();

  const factory CreateMenuInput({
    required String name,
    required String version,
    Status? status,
    StyleConfig? styleConfig,
    int? sizeId,
    String? area,
    MenuDisplayOptions? displayOptions,
    List<String>? allowedWidgetTypes,
  }) = _CreateMenuInput;
}

/// Input for updating a menu
@freezed
abstract class UpdateMenuInput with _$UpdateMenuInput {
  const UpdateMenuInput._();

  const factory UpdateMenuInput({
    required int id,
    String? name,
    String? version,
    Status? status,
    StyleConfig? styleConfig,
    int? sizeId,
    String? area,
    MenuDisplayOptions? displayOptions,
    List<String>? allowedWidgetTypes,
  }) = _UpdateMenuInput;
}
