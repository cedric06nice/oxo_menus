import 'dart:isolate';
import 'dart:typed_data';

import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/asset_loader_repository.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/domain/usecases/pdf_style_resolver.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';

/// Generate PDF UseCase
///
/// Generates a PDF document from a MenuTree matching the exact visual layout.
/// Uses the pdf package for client-side PDF generation.
class GeneratePdfUseCase {
  final PdfDocumentBuilder _builder;
  final FileRepository? _fileRepository;
  final AssetLoaderRepository _assetLoader;
  final bool _useIsolate;

  GeneratePdfUseCase({
    PdfStyleResolver resolver = const PdfStyleResolver(),
    FileRepository? fileRepository,
    required AssetLoaderRepository assetLoader,
    bool useIsolate = true,
  }) : _builder = PdfDocumentBuilder(resolver: resolver),
       _fileRepository = fileRepository,
       _assetLoader = assetLoader,
       _useIsolate = useIsolate;

  /// Execute PDF generation for a menu tree
  Future<Result<Uint8List, DomainError>> execute(MenuTree menuTree) async {
    try {
      // 1. Load fonts via injected asset loader (no Flutter dependency)
      final baseFontData = await _assetLoader.loadAsset(
        'assets/fonts/FuturaStd-Light.ttf',
      );
      final boldFontData = await _assetLoader.loadAsset(
        'assets/fonts/FuturaStd-Book.ttf',
      );
      final sectionFontData = await _assetLoader.loadAsset(
        'assets/fonts/LibreBaskerville-Regular.ttf',
      );

      // 2. Pre-fetch images (HTTP — main thread)
      final imageCache = await _prefetchImages(menuTree);

      // 3. Build PDF — use isolate on native, main thread on web
      final Uint8List bytes;
      if (_useIsolate) {
        final builder = _builder;
        bytes = await Isolate.run(
          () => builder.buildDocument(
            menuTree: menuTree,
            baseFontData: baseFontData,
            boldFontData: boldFontData,
            sectionFontData: sectionFontData,
            imageCache: imageCache,
          ),
        );
      } else {
        bytes = await _builder.buildDocument(
          menuTree: menuTree,
          baseFontData: baseFontData,
          boldFontData: boldFontData,
          sectionFontData: sectionFontData,
          imageCache: imageCache,
        );
      }

      return Success(bytes);
    } catch (e) {
      return Failure(UnknownError(e.toString()));
    }
  }

  /// Collect all image fileIds from a MenuTree and fetch their bytes
  Future<Map<String, Uint8List>> _prefetchImages(MenuTree menuTree) async {
    if (_fileRepository == null) return {};

    final fileIds = <String>{};

    // Collect from all pages (content, header, footer)
    void collectFromPages(List<PageWithContainers> pages) {
      for (final page in pages) {
        for (final container in page.containers) {
          for (final column in container.columns) {
            for (final widget in column.widgets) {
              if (widget.type == 'image') {
                final props = ImageProps.fromJson(widget.props);
                fileIds.add(props.fileId);
              }
            }
          }
        }
      }
    }

    collectFromPages(menuTree.pages);
    if (menuTree.headerPage != null) collectFromPages([menuTree.headerPage!]);
    if (menuTree.footerPage != null) collectFromPages([menuTree.footerPage!]);

    // Fetch all images (parallel for performance)
    final cache = <String, Uint8List>{};
    final futures = fileIds.map((fileId) async {
      final result = await _fileRepository.downloadFile(fileId);
      if (result.isSuccess) {
        cache[fileId] = result.valueOrNull!;
      }
      // On failure, simply skip -- placeholder will be rendered
    });
    await Future.wait(futures);

    return cache;
  }
}
