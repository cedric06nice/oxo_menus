import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/shared/domain/usecases/list_image_files_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/create_menu_bundle_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/delete_menu_bundle_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/get_menu_bundle_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/list_menu_bundles_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/list_sizes_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/list_templates_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_bundles_for_menu_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_menu_bundle_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/update_menu_bundle_usecase.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

/// Fetch menu tree use case provider
///
/// Provides the FetchMenuTreeUseCase for loading complete menu hierarchies
/// with all pages, containers, columns, and widgets.
///
/// Example usage:
/// ```dart
/// final useCase = ref.read(fetchMenuTreeUseCaseProvider);
/// final result = await useCase.execute(menuId);
/// result.fold(
///   onSuccess: (menuTree) => print('Loaded menu: ${menuTree.menu.name}'),
///   onFailure: (error) => print('Error: ${error.message}'),
/// );
/// ```
final fetchMenuTreeUseCaseProvider = Provider<FetchMenuTreeUseCase>((ref) {
  return FetchMenuTreeUseCase(
    menuRepository: ref.watch(menuRepositoryProvider),
    pageRepository: ref.watch(pageRepositoryProvider),
    containerRepository: ref.watch(containerRepositoryProvider),
    columnRepository: ref.watch(columnRepositoryProvider),
    widgetRepository: ref.watch(widgetRepositoryProvider),
  );
});

/// Generate PDF use case provider
///
/// Provides the GeneratePdfUseCase for generating PDF documents from menu trees.
///
/// Example usage:
/// ```dart
/// final useCase = ref.read(generatePdfUseCaseProvider);
/// final result = await useCase.execute(menuTree);
/// result.fold(
///   onSuccess: (pdfBytes) => savePdfFile(pdfBytes),
///   onFailure: (error) => print('Error: ${error.message}'),
/// );
/// ```
final generatePdfUseCaseProvider = Provider<GeneratePdfUseCase>((ref) {
  return GeneratePdfUseCase(
    fileRepository: ref.watch(fileRepositoryProvider),
    assetLoader: ref.watch(assetLoaderRepositoryProvider),
    useIsolate: !kIsWeb,
  );
});

/// List image files use case provider
final listImageFilesUseCaseProvider = Provider<ListImageFilesUseCase>((ref) {
  return ListImageFilesUseCase(
    fileRepository: ref.watch(fileRepositoryProvider),
  );
});

/// List sizes use case provider
final listSizesUseCaseProvider = Provider<ListSizesUseCase>((ref) {
  return ListSizesUseCase(sizeRepository: ref.watch(sizeRepositoryProvider));
});

/// List templates use case provider
final listTemplatesUseCaseProvider = Provider<ListTemplatesUseCase>((ref) {
  return ListTemplatesUseCase(
    menuRepository: ref.watch(menuRepositoryProvider),
  );
});

/// Duplicate menu use case provider
///
/// Provides the DuplicateMenuUseCase for duplicating menus with all their
/// pages, containers, columns, and widgets.
/// Reorder container use case provider
final reorderContainerUseCaseProvider = Provider<ReorderContainerUseCase>((
  ref,
) {
  return ReorderContainerUseCase(
    containerRepository: ref.watch(containerRepositoryProvider),
  );
});

/// Duplicate container use case provider
final duplicateContainerUseCaseProvider = Provider<DuplicateContainerUseCase>((
  ref,
) {
  return DuplicateContainerUseCase(
    containerRepository: ref.watch(containerRepositoryProvider),
    columnRepository: ref.watch(columnRepositoryProvider),
    widgetRepository: ref.watch(widgetRepositoryProvider),
  );
});

final duplicateMenuUseCaseProvider = Provider<DuplicateMenuUseCase>((ref) {
  return DuplicateMenuUseCase(
    fetchMenuTreeUseCase: ref.watch(fetchMenuTreeUseCaseProvider),
    menuRepository: ref.watch(menuRepositoryProvider),
    pageRepository: ref.watch(pageRepositoryProvider),
    containerRepository: ref.watch(containerRepositoryProvider),
    columnRepository: ref.watch(columnRepositoryProvider),
    widgetRepository: ref.watch(widgetRepositoryProvider),
    sizeRepository: ref.watch(sizeRepositoryProvider),
  );
});

// ===== Menu Bundle use cases =====

/// List menu bundles
final listMenuBundlesUseCaseProvider = Provider<ListMenuBundlesUseCase>((ref) {
  return ListMenuBundlesUseCase(
    repository: ref.watch(menuBundleRepositoryProvider),
  );
});

/// Get a single bundle by id
final getMenuBundleUseCaseProvider = Provider<GetMenuBundleUseCase>((ref) {
  return GetMenuBundleUseCase(
    repository: ref.watch(menuBundleRepositoryProvider),
  );
});

/// Create a bundle
final createMenuBundleUseCaseProvider = Provider<CreateMenuBundleUseCase>((
  ref,
) {
  return CreateMenuBundleUseCase(
    repository: ref.watch(menuBundleRepositoryProvider),
  );
});

/// Update a bundle
final updateMenuBundleUseCaseProvider = Provider<UpdateMenuBundleUseCase>((
  ref,
) {
  return UpdateMenuBundleUseCase(
    repository: ref.watch(menuBundleRepositoryProvider),
  );
});

/// Delete a bundle
final deleteMenuBundleUseCaseProvider = Provider<DeleteMenuBundleUseCase>((
  ref,
) {
  return DeleteMenuBundleUseCase(
    repository: ref.watch(menuBundleRepositoryProvider),
  );
});

/// Publish a single bundle to Directus (upload or replace + persist fileId).
final publishMenuBundleUseCaseProvider = Provider<PublishMenuBundleUseCase>((
  ref,
) {
  return PublishMenuBundleUseCase(
    repository: ref.watch(menuBundleRepositoryProvider),
    fetchMenuTreeUseCase: ref.watch(fetchMenuTreeUseCaseProvider),
    fileRepository: ref.watch(fileRepositoryProvider),
    assetLoader: ref.watch(assetLoaderRepositoryProvider),
    pdfBuilder: const PdfDocumentBuilder(),
  );
});

/// Publish every bundle containing a given menu id (used by the editor hook).
final publishBundlesForMenuUseCaseProvider =
    Provider<PublishBundlesForMenuUseCase>((ref) {
      return PublishBundlesForMenuUseCase(
        repository: ref.watch(menuBundleRepositoryProvider),
        publishMenuBundleUseCase: ref.watch(publishMenuBundleUseCaseProvider),
      );
    });
