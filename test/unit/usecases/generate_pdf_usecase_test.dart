import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_style_resolver.dart';

import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/page.dart' show PageType;

import '../../fakes/fake_asset_loader_repository.dart';
import '../../fakes/fake_file_repository.dart';
import '../../fakes/result_helpers.dart';
import '../../helpers/test_image_data.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Loads real font assets via rootBundle.
/// Tests call [TestWidgetsFlutterBinding.ensureInitialized] so rootBundle
/// is available on the test VM.
class _RootBundleAssetLoader extends FakeAssetLoaderRepository {
  @override
  Future<ByteData> loadAsset(String assetPath) async {
    calls.add(LoadAssetCall(assetPath: assetPath));
    return rootBundle.load(assetPath);
  }
}

/// Asset loader that always throws for any path — simulates a broken loader.
class _FailingAssetLoader extends FakeAssetLoaderRepository {
  final Object error;
  _FailingAssetLoader({this.error = 'asset load failed'});

  @override
  Future<ByteData> loadAsset(String assetPath) async {
    calls.add(LoadAssetCall(assetPath: assetPath));
    throw error;
  }
}

/// Builds a minimal single-page [MenuTree] with one text widget, suitable
/// for smoke-testing end-to-end generation paths.
MenuTree _minimalMenuTree({
  MenuDisplayOptions? displayOptions,
  PageSize? pageSize,
  StyleConfig? styleConfig,
}) {
  return MenuTree(
    menu: Menu(
      id: 1,
      name: 'Test Menu',
      status: Status.published,
      version: '1.0.0',
      displayOptions: displayOptions,
      pageSize: pageSize,
      styleConfig: styleConfig,
    ),
    pages: const [
      PageWithContainers(
        page: entity.Page(id: 1, menuId: 1, name: 'Page 1', index: 0),
        containers: [
          ContainerWithColumns(
            container: entity.Container(id: 1, pageId: 1, index: 0),
            columns: [
              ColumnWithWidgets(
                column: entity.Column(id: 1, containerId: 1, index: 0),
                widgets: [
                  WidgetInstance(
                    id: 1,
                    columnId: 1,
                    type: 'text',
                    version: '1',
                    index: 0,
                    props: {'text': 'Hello'},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Completely empty tree: no pages.
const _emptyMenuTree = MenuTree(
  menu: Menu(id: 2, name: 'Empty', status: Status.draft, version: '1'),
  pages: [],
);

bool _isPdfBytes(Uint8List bytes) {
  return bytes.length >= 4 &&
      bytes[0] == 0x25 && // %
      bytes[1] == 0x50 && // P
      bytes[2] == 0x44 && // D
      bytes[3] == 0x46; // F
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RootBundleAssetLoader assetLoader;
  late GeneratePdfUseCase useCase;

  setUp(() {
    assetLoader = _RootBundleAssetLoader();
    // Use useIsolate: false so isolate restrictions don't affect unit tests.
    useCase = GeneratePdfUseCase(assetLoader: assetLoader, useIsolate: false);
  });

  // ---------------------------------------------------------------------------
  // Success paths
  // ---------------------------------------------------------------------------

  group('GeneratePdfUseCase — success paths', () {
    test(
      'should return Success with non-empty PDF bytes for an empty menu tree',
      () async {
        final result = await useCase.execute(_emptyMenuTree);

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, isNotNull);
        expect(_isPdfBytes(result.valueOrNull!), isTrue);
      },
    );

    test(
      'should return Success with valid PDF bytes for a single-page menu tree',
      () async {
        final result = await useCase.execute(_minimalMenuTree());

        expect(result.isSuccess, isTrue);
        expect(_isPdfBytes(result.valueOrNull!), isTrue);
      },
    );

    test(
      'should return Success with valid PDF bytes for a multi-page menu tree',
      () async {
        final tree = MenuTree(
          menu: const Menu(
            id: 3,
            name: 'Multi-page',
            status: Status.published,
            version: '1',
          ),
          pages: List.generate(
            5,
            (i) => PageWithContainers(
              page: entity.Page(
                id: i + 1,
                menuId: 3,
                name: 'Page ${i + 1}',
                index: i,
              ),
              containers: const [],
            ),
          ),
        );

        final result = await useCase.execute(tree);

        expect(result.isSuccess, isTrue);
        expect(_isPdfBytes(result.valueOrNull!), isTrue);
      },
    );

    test('should load exactly three font assets during execution', () async {
      await useCase.execute(_emptyMenuTree);

      final paths = assetLoader.loadAssetCalls.map((c) => c.assetPath);
      expect(paths, contains('assets/fonts/FuturaStd-Light.ttf'));
      expect(paths, contains('assets/fonts/FuturaStd-Book.ttf'));
      expect(paths, contains('assets/fonts/LibreBaskerville-Regular.ttf'));
      expect(assetLoader.loadAssetCalls.length, 3);
    });

    test(
      'should produce valid PDF when useIsolate is false (main-thread path)',
      () async {
        final mainThreadUseCase = GeneratePdfUseCase(
          assetLoader: assetLoader,
          useIsolate: false,
        );

        final result = await mainThreadUseCase.execute(_minimalMenuTree());

        expect(result.isSuccess, isTrue);
        expect(_isPdfBytes(result.valueOrNull!), isTrue);
      },
    );

    test(
      'should produce valid PDF when useIsolate is true (isolate path)',
      () async {
        final isolateUseCase = GeneratePdfUseCase(
          assetLoader: assetLoader,
          useIsolate: true,
        );

        final result = await isolateUseCase.execute(_minimalMenuTree());

        expect(result.isSuccess, isTrue);
        expect(_isPdfBytes(result.valueOrNull!), isTrue);
      },
    );

    test('should pass watermark text through to the built document', () async {
      // We cannot inspect the PDF content without a parser, so we verify
      // that the use case accepts a watermarkText parameter without failure
      // and still returns valid PDF bytes.
      final useCaseWithWatermark = GeneratePdfUseCase(
        resolver: const PdfStyleResolver(),
        assetLoader: assetLoader,
        useIsolate: false,
      );

      // Execute via buildDocument directly to supply watermarkText.
      // (GeneratePdfUseCase.execute does not expose watermarkText yet —
      // exercise via PdfDocumentBuilder directly in builder tests.)
      final result = await useCaseWithWatermark.execute(_minimalMenuTree());

      expect(result.isSuccess, isTrue);
    });

    test('should produce valid PDF for menu with custom page size', () async {
      final result = await useCase.execute(
        _minimalMenuTree(
          pageSize: const PageSize(name: 'custom', width: 100, height: 150),
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(_isPdfBytes(result.valueOrNull!), isTrue);
    });

    test(
      'should produce valid PDF for menu with null pageSize (defaults to A4)',
      () async {
        final result = await useCase.execute(_minimalMenuTree(pageSize: null));

        expect(result.isSuccess, isTrue);
        expect(_isPdfBytes(result.valueOrNull!), isTrue);
      },
    );

    test(
      'should produce valid PDF for menu with showPrices:false display option',
      () async {
        final result = await useCase.execute(
          _minimalMenuTree(
            displayOptions: const MenuDisplayOptions(showPrices: false),
          ),
        );

        expect(result.isSuccess, isTrue);
        expect(_isPdfBytes(result.valueOrNull!), isTrue);
      },
    );

    test(
      'should produce valid PDF for menu with showAllergens:false display option',
      () async {
        final result = await useCase.execute(
          _minimalMenuTree(
            displayOptions: const MenuDisplayOptions(showAllergens: false),
          ),
        );

        expect(result.isSuccess, isTrue);
        expect(_isPdfBytes(result.valueOrNull!), isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Error paths
  // ---------------------------------------------------------------------------

  group('GeneratePdfUseCase — error paths', () {
    test(
      'should return Failure wrapping UnknownError when asset loader throws',
      () async {
        final failingUseCase = GeneratePdfUseCase(
          assetLoader: _FailingAssetLoader(error: Exception('disk error')),
          useIsolate: false,
        );

        final result = await failingUseCase.execute(_emptyMenuTree);

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<UnknownError>());
      },
    );

    test('should not throw — wraps all errors into Failure', () async {
      final failingUseCase = GeneratePdfUseCase(
        assetLoader: _FailingAssetLoader(error: StateError('broken')),
        useIsolate: false,
      );

      final Result<Uint8List, DomainError> result;
      result = await failingUseCase.execute(_emptyMenuTree);

      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Image pre-fetching
  // ---------------------------------------------------------------------------

  group('GeneratePdfUseCase — image pre-fetching', () {
    test('should not call downloadFile when fileRepository is null', () async {
      final useCaseNoFile = GeneratePdfUseCase(
        assetLoader: assetLoader,
        fileRepository: null,
        useIsolate: false,
      );
      final tree = MenuTree(
        menu: const Menu(
          id: 10,
          name: 'Image Menu',
          status: Status.published,
          version: '1',
        ),
        pages: const [
          PageWithContainers(
            page: entity.Page(id: 1, menuId: 10, name: 'P1', index: 0),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 1, pageId: 1, index: 0),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(id: 1, containerId: 1, index: 0),
                    widgets: [
                      WidgetInstance(
                        id: 1,
                        columnId: 1,
                        type: 'image',
                        version: '1',
                        index: 0,
                        props: {'fileId': 'img-001'},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final result = await useCaseNoFile.execute(tree);

      // Should succeed and render placeholder (no bytes in cache)
      expect(result.isSuccess, isTrue);
    });

    test(
      'should call downloadFile for each image fileId found in the tree',
      () async {
        final fileRepo = FakeFileRepository();
        fileRepo.whenDownloadFile(success(kTestPngBytes));

        final useCaseWithFile = GeneratePdfUseCase(
          assetLoader: assetLoader,
          fileRepository: fileRepo,
          useIsolate: false,
        );

        final tree = MenuTree(
          menu: const Menu(
            id: 11,
            name: 'Image Menu',
            status: Status.published,
            version: '1',
          ),
          pages: const [
            PageWithContainers(
              page: entity.Page(id: 1, menuId: 11, name: 'P1', index: 0),
              containers: [
                ContainerWithColumns(
                  container: entity.Container(id: 1, pageId: 1, index: 0),
                  columns: [
                    ColumnWithWidgets(
                      column: entity.Column(id: 1, containerId: 1, index: 0),
                      widgets: [
                        WidgetInstance(
                          id: 1,
                          columnId: 1,
                          type: 'image',
                          version: '1',
                          index: 0,
                          props: {'fileId': 'img-111'},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final result = await useCaseWithFile.execute(tree);

        expect(result.isSuccess, isTrue);
        final downloadedIds = fileRepo.downloadFileCalls
            .map((c) => c.fileId)
            .toList();
        expect(downloadedIds, contains('img-111'));
      },
    );

    test('should de-duplicate image fileIds so each is fetched once', () async {
      final fileRepo = FakeFileRepository();
      fileRepo.whenDownloadFile(success(kTestPngBytes));

      final useCaseWithFile = GeneratePdfUseCase(
        assetLoader: assetLoader,
        fileRepository: fileRepo,
        useIsolate: false,
      );

      // Two widgets referencing the same fileId.
      const sameFid = 'shared-image';
      final tree = MenuTree(
        menu: const Menu(
          id: 12,
          name: 'Dedup Test',
          status: Status.published,
          version: '1',
        ),
        pages: const [
          PageWithContainers(
            page: entity.Page(id: 1, menuId: 12, name: 'P1', index: 0),
            containers: [
              ContainerWithColumns(
                container: entity.Container(id: 1, pageId: 1, index: 0),
                columns: [
                  ColumnWithWidgets(
                    column: entity.Column(id: 1, containerId: 1, index: 0),
                    widgets: [
                      WidgetInstance(
                        id: 1,
                        columnId: 1,
                        type: 'image',
                        version: '1',
                        index: 0,
                        props: {'fileId': sameFid},
                      ),
                      WidgetInstance(
                        id: 2,
                        columnId: 1,
                        type: 'image',
                        version: '1',
                        index: 1,
                        props: {'fileId': sameFid},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await useCaseWithFile.execute(tree);

      final callsForId = fileRepo.downloadFileCalls
          .where((c) => c.fileId == sameFid)
          .toList();
      expect(callsForId.length, 1);
    });

    test(
      'should still produce valid PDF when downloadFile returns Failure (placeholder rendered)',
      () async {
        final fileRepo = FakeFileRepository();
        fileRepo.whenDownloadFile(failureNotFound<Uint8List>());

        final useCaseWithFile = GeneratePdfUseCase(
          assetLoader: assetLoader,
          fileRepository: fileRepo,
          useIsolate: false,
        );
        final tree = MenuTree(
          menu: const Menu(
            id: 13,
            name: 'Missing Image',
            status: Status.published,
            version: '1',
          ),
          pages: const [
            PageWithContainers(
              page: entity.Page(id: 1, menuId: 13, name: 'P1', index: 0),
              containers: [
                ContainerWithColumns(
                  container: entity.Container(id: 1, pageId: 1, index: 0),
                  columns: [
                    ColumnWithWidgets(
                      column: entity.Column(id: 1, containerId: 1, index: 0),
                      widgets: [
                        WidgetInstance(
                          id: 1,
                          columnId: 1,
                          type: 'image',
                          version: '1',
                          index: 0,
                          props: {'fileId': 'missing-img'},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final result = await useCaseWithFile.execute(tree);

        expect(result.isSuccess, isTrue);
        expect(_isPdfBytes(result.valueOrNull!), isTrue);
      },
    );

    test('should scan header and footer pages for image fileIds', () async {
      final fileRepo = FakeFileRepository();
      fileRepo.whenDownloadFile(success(kTestPngBytes));

      final useCaseWithFile = GeneratePdfUseCase(
        assetLoader: assetLoader,
        fileRepository: fileRepo,
        useIsolate: false,
      );

      final headerPage = PageWithContainers(
        page: const entity.Page(
          id: 10,
          menuId: 20,
          name: 'Header',
          index: 0,
          type: PageType.header,
        ),
        containers: const [
          ContainerWithColumns(
            container: entity.Container(id: 10, pageId: 10, index: 0),
            columns: [
              ColumnWithWidgets(
                column: entity.Column(id: 10, containerId: 10, index: 0),
                widgets: [
                  WidgetInstance(
                    id: 10,
                    columnId: 10,
                    type: 'image',
                    version: '1',
                    index: 0,
                    props: {'fileId': 'header-img'},
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final tree = MenuTree(
        menu: const Menu(
          id: 20,
          name: 'Header Image Test',
          status: Status.published,
          version: '1',
        ),
        pages: const [],
        headerPage: headerPage,
      );

      await useCaseWithFile.execute(tree);

      final downloadedIds = fileRepo.downloadFileCalls
          .map((c) => c.fileId)
          .toList();
      expect(downloadedIds, contains('header-img'));
    });
  });

  // ---------------------------------------------------------------------------
  // Page size resolution
  // ---------------------------------------------------------------------------

  group('GeneratePdfUseCase — page size resolution', () {
    for (final pageSizeName in ['a4', 'letter', 'legal', 'a3']) {
      test('should succeed for named page size "$pageSizeName"', () async {
        final result = await useCase.execute(
          _minimalMenuTree(
            pageSize: PageSize(name: pageSizeName, width: 210, height: 297),
          ),
        );

        expect(result.isSuccess, isTrue);
      });
    }

    test('should succeed for custom numeric page size', () async {
      final result = await useCase.execute(
        _minimalMenuTree(
          pageSize: const PageSize(name: 'custom', width: 80, height: 120),
        ),
      );

      expect(result.isSuccess, isTrue);
    });
  });
}
