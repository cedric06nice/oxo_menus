import 'dart:typed_data';

import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/shared/domain/repositories/asset_loader_repository.dart';
import 'package:oxo_menus/shared/domain/repositories/file_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/image/image_props.dart';

/// Publish a menu bundle as a single watermarked PDF stored in Directus.
///
/// The bundle PDF is composed of every included menu rendered without
/// allergens first, then every included menu rendered with allergens.
/// Every page carries the "SAMPLE MENU" watermark.
///
/// If the bundle already has a [MenuBundle.pdfFileId], that Directus file is
/// replaced (stable UUID / public URL). Otherwise a new file is uploaded and
/// the bundle row is updated with the returned id so subsequent publishes
/// replace instead of re-upload.
class PublishMenuBundleUseCase {
  final MenuBundleRepository repository;
  final FetchMenuTreeUseCase fetchMenuTreeUseCase;
  final FileRepository fileRepository;
  final AssetLoaderRepository assetLoader;
  final PdfDocumentBuilder pdfBuilder;
  final String watermarkText;

  const PublishMenuBundleUseCase({
    required this.repository,
    required this.fetchMenuTreeUseCase,
    required this.fileRepository,
    required this.assetLoader,
    required this.pdfBuilder,
    this.watermarkText = 'SAMPLE MENU',
  });

  Future<Result<MenuBundle, DomainError>> execute(int bundleId) async {
    final bundleResult = await repository.getById(bundleId);
    if (bundleResult.isFailure) {
      return Failure(bundleResult.errorOrNull!);
    }
    final bundle = bundleResult.valueOrNull!;

    // Fetch every included menu tree in order, abort on first failure.
    final trees = <MenuTree>[];
    for (final menuId in bundle.menuIds) {
      final treeResult = await fetchMenuTreeUseCase.execute(menuId);
      if (treeResult.isFailure) {
        return Failure(treeResult.errorOrNull!);
      }
      trees.add(treeResult.valueOrNull!);
    }

    // Load fonts and prefetch any image bytes referenced by the trees.
    final baseFontData = await assetLoader.loadAsset(
      'assets/fonts/FuturaStd-Light.ttf',
    );
    final boldFontData = await assetLoader.loadAsset(
      'assets/fonts/FuturaStd-Book.ttf',
    );
    final sectionFontData = await assetLoader.loadAsset(
      'assets/fonts/LibreBaskerville-Regular.ttf',
    );
    final imageCache = await _prefetchImages(trees);

    // Render the bundle PDF.
    final Uint8List bytes;
    try {
      bytes = await pdfBuilder.buildBundleDocument(
        trees: trees,
        baseOptions: const MenuDisplayOptions(),
        baseFontData: baseFontData,
        boldFontData: boldFontData,
        sectionFontData: sectionFontData,
        imageCache: imageCache,
        watermarkText: watermarkText,
      );
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }

    // Upload (first time) or replace (subsequent publishes).
    final filename = '${bundle.name}.pdf';
    final Result<String, DomainError> uploadResult;
    if (bundle.pdfFileId == null) {
      uploadResult = await fileRepository.upload(bytes, filename);
    } else {
      uploadResult = await fileRepository.replace(
        bundle.pdfFileId!,
        bytes,
        filename,
      );
    }
    if (uploadResult.isFailure) {
      return Failure(uploadResult.errorOrNull!);
    }
    final fileId = uploadResult.valueOrNull!;

    // Persist the new pdfFileId only if it changed (i.e., first upload).
    if (bundle.pdfFileId == null) {
      final updateResult = await repository.update(
        UpdateMenuBundleInput(id: bundle.id, pdfFileId: fileId),
      );
      if (updateResult.isFailure) {
        return Failure(updateResult.errorOrNull!);
      }
      return Success(updateResult.valueOrNull!);
    }

    return Success(bundle);
  }

  Future<Map<String, Uint8List>> _prefetchImages(List<MenuTree> trees) async {
    final fileIds = <String>{};
    void collectFromPages(List<PageWithContainers> pages) {
      for (final page in pages) {
        for (final container in page.containers) {
          for (final column in container.columns) {
            for (final widget in column.widgets) {
              if (widget.type == 'image') {
                fileIds.add(ImageProps.fromJson(widget.props).fileId);
              }
            }
          }
        }
      }
    }

    for (final tree in trees) {
      collectFromPages(tree.pages);
      if (tree.headerPage != null) collectFromPages([tree.headerPage!]);
      if (tree.footerPage != null) collectFromPages([tree.footerPage!]);
    }

    final cache = <String, Uint8List>{};
    await Future.wait(
      fileIds.map((fileId) async {
        final result = await fileRepository.downloadFile(fileId);
        if (result.isSuccess) {
          cache[fileId] = result.valueOrNull!;
        }
      }),
    );
    return cache;
  }
}
