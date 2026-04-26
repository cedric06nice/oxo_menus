import 'dart:typed_data';

import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/asset_loader_repository.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/domain/usecases/publish_menu_bundle_usecase.dart';

// ---------------------------------------------------------------------------
// Call-record type
// ---------------------------------------------------------------------------

/// Records a single [FakePublishMenuBundleUseCase.execute] call.
final class PublishMenuBundleCall {
  final int bundleId;
  const PublishMenuBundleCall({required this.bundleId});
}

// ---------------------------------------------------------------------------
// FakePublishMenuBundleUseCase
// ---------------------------------------------------------------------------

/// A manual fake that extends [PublishMenuBundleUseCase] and intercepts
/// [execute].
///
/// All required constructor parameters are satisfied with private throw-only
/// stubs so callers do not need to provide real dependencies.
///
/// Usage:
/// ```dart
/// final fake = FakePublishMenuBundleUseCase();
/// fake.stubExecute(Success(bundle));
/// final result = await fake.execute(1);
/// expect(fake.calls.single.bundleId, equals(1));
/// ```
class FakePublishMenuBundleUseCase extends PublishMenuBundleUseCase {
  FakePublishMenuBundleUseCase()
      : super(
          repository: _ThrowMenuBundleRepository(),
          fetchMenuTreeUseCase: _ThrowFetchMenuTreeUseCase(),
          fileRepository: _ThrowFileRepository(),
          assetLoader: _ThrowAssetLoaderRepository(),
          pdfBuilder: const PdfDocumentBuilder(),
        );

  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<PublishMenuBundleCall> calls = [];

  // -------------------------------------------------------------------------
  // Response stub
  // -------------------------------------------------------------------------

  Result<MenuBundle, DomainError>? _stubResult;

  /// Configures the next (and all subsequent) [execute] calls to return [result].
  void stubExecute(Result<MenuBundle, DomainError> result) {
    _stubResult = result;
  }

  // -------------------------------------------------------------------------
  // Override
  // -------------------------------------------------------------------------

  @override
  Future<Result<MenuBundle, DomainError>> execute(int bundleId) async {
    calls.add(PublishMenuBundleCall(bundleId: bundleId));
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      'FakePublishMenuBundleUseCase: no stub configured — call stubExecute() first',
    );
  }
}

// ---------------------------------------------------------------------------
// Private stubs (satisfy super constructor; never actually called)
// ---------------------------------------------------------------------------

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
  Future<Result<MenuBundle, DomainError>> create(CreateMenuBundleInput input) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<MenuBundle, DomainError>> update(UpdateMenuBundleInput input) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowMenuBundleRepository should not be called');
}

class _ThrowFetchMenuTreeUseCase extends FetchMenuTreeUseCase {
  _ThrowFetchMenuTreeUseCase()
      : super(
          menuRepository: _ThrowMenuRepository(),
          pageRepository: _ThrowPageRepository(),
          containerRepository: _ThrowContainerRepository(),
          columnRepository: _ThrowColumnRepository(),
          widgetRepository: _ThrowWidgetRepository(),
        );

  @override
  Future<Result<MenuTree, DomainError>> execute(int menuId) =>
      throw StateError('_ThrowFetchMenuTreeUseCase should not be called');
}

class _ThrowFileRepository implements FileRepository {
  @override
  Future<Result<String, DomainError>> upload(
    Uint8List bytes,
    String filename,
  ) => throw StateError('_ThrowFileRepository should not be called');

  @override
  Future<Result<String, DomainError>> replace(
    String fileId,
    Uint8List bytes,
    String filename,
  ) => throw StateError('_ThrowFileRepository should not be called');

  @override
  Future<Result<List<ImageFileInfo>, DomainError>> listImageFiles() =>
      throw StateError('_ThrowFileRepository should not be called');

  @override
  Future<Result<Uint8List, DomainError>> downloadFile(String fileId) =>
      throw StateError('_ThrowFileRepository should not be called');
}

class _ThrowAssetLoaderRepository implements AssetLoaderRepository {
  @override
  Future<ByteData> loadAsset(String assetPath) =>
      throw StateError('_ThrowAssetLoaderRepository should not be called');
}

class _ThrowMenuRepository implements MenuRepository {
  @override
  Future<Result<Menu, DomainError>> create(CreateMenuInput input) =>
      throw StateError('_ThrowMenuRepository should not be called');

  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
    List<int>? areaIds,
  }) => throw StateError('_ThrowMenuRepository should not be called');

  @override
  Future<Result<Menu, DomainError>> getById(int id) =>
      throw StateError('_ThrowMenuRepository should not be called');

  @override
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input) =>
      throw StateError('_ThrowMenuRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowMenuRepository should not be called');
}

class _ThrowPageRepository implements PageRepository {
  @override
  Future<Result<Page, DomainError>> create(CreatePageInput input) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<List<Page>, DomainError>> getAllForMenu(int menuId) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<Page, DomainError>> getById(int id) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<Page, DomainError>> update(UpdatePageInput input) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowPageRepository should not be called');

  @override
  Future<Result<void, DomainError>> reorder(int pageId, int newIndex) =>
      throw StateError('_ThrowPageRepository should not be called');
}

class _ThrowContainerRepository implements ContainerRepository {
  @override
  Future<Result<Container, DomainError>> create(CreateContainerInput input) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<List<Container>, DomainError>> getAllForPage(int pageId) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<List<Container>, DomainError>> getAllForContainer(
    int containerId,
  ) => throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<Container, DomainError>> getById(int id) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<Container, DomainError>> update(UpdateContainerInput input) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<void, DomainError>> reorder(int containerId, int newIndex) =>
      throw StateError('_ThrowContainerRepository should not be called');

  @override
  Future<Result<void, DomainError>> moveTo(
    int containerId,
    int newPageId,
    int index,
  ) => throw StateError('_ThrowContainerRepository should not be called');
}

class _ThrowColumnRepository implements ColumnRepository {
  @override
  Future<Result<Column, DomainError>> create(CreateColumnInput input) =>
      throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<List<Column>, DomainError>> getAllForContainer(
    int containerId,
  ) => throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<Column, DomainError>> getById(int id) =>
      throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<Column, DomainError>> update(UpdateColumnInput input) =>
      throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowColumnRepository should not be called');

  @override
  Future<Result<void, DomainError>> reorder(int columnId, int newIndex) =>
      throw StateError('_ThrowColumnRepository should not be called');
}

class _ThrowWidgetRepository implements WidgetRepository {
  @override
  Future<Result<WidgetInstance, DomainError>> create(
    CreateWidgetInput input,
  ) => throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<List<WidgetInstance>, DomainError>> getAllForColumn(
    int columnId,
  ) => throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<WidgetInstance, DomainError>> getById(int id) =>
      throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<WidgetInstance, DomainError>> update(
    UpdateWidgetInput input,
  ) => throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> delete(int id) =>
      throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> reorder(int widgetId, int newIndex) =>
      throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> moveTo(
    int widgetId,
    int newColumnId,
    int index,
  ) => throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> lockForEditing(
    int widgetId,
    String userId,
  ) => throw StateError('_ThrowWidgetRepository should not be called');

  @override
  Future<Result<void, DomainError>> unlockEditing(int widgetId) =>
      throw StateError('_ThrowWidgetRepository should not be called');
}
