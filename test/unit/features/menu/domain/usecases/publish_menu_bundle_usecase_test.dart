import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_menu_bundle_usecase.dart';

import '../../../../../fakes/builders/menu_builder.dart';
import '../../../../../fakes/builders/menu_bundle_builder.dart';
import '../../../../../fakes/builders/page_builder.dart';
import '../../../../../fakes/fake_asset_loader_repository.dart';
import '../../../../../fakes/fake_fetch_menu_tree_usecase.dart';
import '../../../../../fakes/fake_file_repository.dart';
import '../../../../../fakes/fake_menu_bundle_repository.dart';
import '../../../../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Local fake PdfDocumentBuilder
// ---------------------------------------------------------------------------

/// Overrides [buildBundleDocument] to return controllable bytes without
/// running the real PDF rendering pipeline.
class _FakePdfDocumentBuilder extends PdfDocumentBuilder {
  _FakePdfDocumentBuilder() : super();

  Uint8List _response = Uint8List(0);
  bool throwOnBuild = false;

  void stubBytes(Uint8List bytes) {
    _response = bytes;
  }

  @override
  Future<Uint8List> buildBundleDocument({
    required List<MenuTree> trees,
    required MenuDisplayOptions baseOptions,
    required ByteData baseFontData,
    required ByteData boldFontData,
    required ByteData sectionFontData,
    required Map<String, Uint8List> imageCache,
    required String watermarkText,
  }) async {
    if (throwOnBuild) {
      throw StateError('PDF build failed');
    }
    return _response;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PublishMenuBundleUseCase', () {
    late FakeMenuBundleRepository bundleRepo;
    late FakeFetchMenuTreeUseCase fetchMenuTree;
    late FakeFileRepository fileRepo;
    late FakeAssetLoaderRepository assetLoader;
    late _FakePdfDocumentBuilder pdfBuilder;
    late PublishMenuBundleUseCase useCase;

    final fakeBytes = ByteData(4);

    setUp(() {
      bundleRepo = FakeMenuBundleRepository();
      fetchMenuTree = FakeFetchMenuTreeUseCase();
      fileRepo = FakeFileRepository();
      assetLoader = FakeAssetLoaderRepository();
      pdfBuilder = _FakePdfDocumentBuilder();
      pdfBuilder.throwOnBuild = false;
      assetLoader.whenLoadAssetDefault(fakeBytes);

      useCase = PublishMenuBundleUseCase(
        repository: bundleRepo,
        fetchMenuTreeUseCase: fetchMenuTree,
        fileRepository: fileRepo,
        assetLoader: assetLoader,
        pdfBuilder: pdfBuilder,
      );
    });

    MenuTree buildSimpleTree({int menuId = 1}) {
      return MenuTree(
        menu: buildMenu(id: menuId),
        pages: [],
      );
    }

    // -------------------------------------------------------------------------
    // Bundle fetch failure
    // -------------------------------------------------------------------------

    group('bundle fetch failure', () {
      test('should return Failure when repository.getById fails', () async {
        // Arrange
        bundleRepo.whenGetById(failure(notFound()));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });

    // -------------------------------------------------------------------------
    // Menu tree fetch failure
    // -------------------------------------------------------------------------

    group('menu tree fetch failure', () {
      test(
        'should return Failure when fetchMenuTreeUseCase fails for any included menu',
        () async {
          // Arrange
          bundleRepo.whenGetById(
            success(buildMenuBundle(id: 1, menuIds: [10])),
          );
          fetchMenuTree.stubExecute(failure(network()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // PDF build failure
    // -------------------------------------------------------------------------

    group('PDF build failure', () {
      test(
        'should return UnknownError when PdfDocumentBuilder.buildBundleDocument throws',
        () async {
          // Arrange
          bundleRepo.whenGetById(
            success(buildMenuBundle(id: 1, menuIds: [10])),
          );
          fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
          pdfBuilder.throwOnBuild = true;

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<UnknownError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Upload failure
    // -------------------------------------------------------------------------

    group('upload failure', () {
      test(
        'should return Failure when fileRepository.upload fails on first-time publish',
        () async {
          // Arrange
          bundleRepo.whenGetById(
            success(buildMenuBundle(id: 1, menuIds: [10], pdfFileId: null)),
          );
          fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
          fileRepo.whenUpload(failure(server()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );

      test(
        'should return Failure when fileRepository.replace fails on subsequent publish',
        () async {
          // Arrange
          bundleRepo.whenGetById(
            success(
              buildMenuBundle(id: 1, menuIds: [10], pdfFileId: 'existing-id'),
            ),
          );
          fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
          fileRepo.whenReplace(failure(server()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Bundle update failure (first upload only)
    // -------------------------------------------------------------------------

    group('bundle update failure on first upload', () {
      test(
        'should return Failure when repository.update fails after first upload',
        () async {
          // Arrange
          bundleRepo.whenGetById(
            success(buildMenuBundle(id: 1, menuIds: [10], pdfFileId: null)),
          );
          fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
          fileRepo.whenUpload(success('new-file-id'));
          bundleRepo.whenUpdate(failure(server()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Happy path — first-time publish (no existing pdfFileId)
    // -------------------------------------------------------------------------

    group('happy path — first-time publish', () {
      test(
        'should upload PDF and return updated bundle with new fileId',
        () async {
          // Arrange
          final updatedBundle = buildMenuBundle(
            id: 1,
            menuIds: [10],
            pdfFileId: 'new-file-id',
          );
          bundleRepo.whenGetById(
            success(buildMenuBundle(id: 1, menuIds: [10], pdfFileId: null)),
          );
          fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
          fileRepo.whenUpload(success('new-file-id'));
          bundleRepo.whenUpdate(success(updatedBundle));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.pdfFileId, equals('new-file-id'));
        },
      );

      test('should call upload (not replace) when pdfFileId is null', () async {
        // Arrange
        bundleRepo.whenGetById(
          success(buildMenuBundle(id: 1, menuIds: [10], pdfFileId: null)),
        );
        fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
        fileRepo.whenUpload(success('new-file-id'));
        bundleRepo.whenUpdate(success(buildMenuBundle(id: 1)));

        // Act
        await useCase.execute(1);

        // Assert
        expect(fileRepo.uploadCalls.length, equals(1));
        expect(fileRepo.replaceCalls, isEmpty);
      });

      test('should use bundle name as PDF filename', () async {
        // Arrange
        bundleRepo.whenGetById(
          success(buildMenuBundle(id: 1, name: 'Weekend Set', menuIds: [10])),
        );
        fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
        fileRepo.whenUpload(success('file-id'));
        bundleRepo.whenUpdate(success(buildMenuBundle(id: 1)));

        // Act
        await useCase.execute(1);

        // Assert
        expect(fileRepo.uploadCalls.single.filename, equals('Weekend Set.pdf'));
      });

      test(
        'should pass the returned fileId to repository.update after first upload',
        () async {
          // Arrange
          bundleRepo.whenGetById(
            success(buildMenuBundle(id: 1, menuIds: [10], pdfFileId: null)),
          );
          fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
          fileRepo.whenUpload(success('returned-file-id'));
          bundleRepo.whenUpdate(success(buildMenuBundle(id: 1)));

          // Act
          await useCase.execute(1);

          // Assert
          expect(
            bundleRepo.updateCalls.single.input.pdfFileId,
            equals('returned-file-id'),
          );
        },
      );
    });

    // -------------------------------------------------------------------------
    // Happy path — subsequent publish (existing pdfFileId)
    // -------------------------------------------------------------------------

    group('happy path — subsequent publish', () {
      test(
        'should call replace (not upload) when bundle already has a pdfFileId',
        () async {
          // Arrange
          bundleRepo.whenGetById(
            success(
              buildMenuBundle(id: 1, menuIds: [10], pdfFileId: 'existing-id'),
            ),
          );
          fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
          fileRepo.whenReplace(success('existing-id'));

          // Act
          await useCase.execute(1);

          // Assert
          expect(fileRepo.replaceCalls.length, equals(1));
          expect(fileRepo.uploadCalls, isEmpty);
        },
      );

      test('should call replace with the existing pdfFileId', () async {
        // Arrange
        bundleRepo.whenGetById(
          success(
            buildMenuBundle(id: 1, menuIds: [10], pdfFileId: 'existing-id'),
          ),
        );
        fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
        fileRepo.whenReplace(success('existing-id'));

        // Act
        await useCase.execute(1);

        // Assert
        expect(fileRepo.replaceCalls.single.fileId, equals('existing-id'));
      });

      test('should not call repository.update on subsequent publish', () async {
        // Arrange
        bundleRepo.whenGetById(
          success(
            buildMenuBundle(id: 1, menuIds: [10], pdfFileId: 'existing-id'),
          ),
        );
        fetchMenuTree.stubExecute(Success(buildSimpleTree(menuId: 10)));
        fileRepo.whenReplace(success('existing-id'));

        // Act
        await useCase.execute(1);

        // Assert
        expect(bundleRepo.updateCalls, isEmpty);
      });

      test(
        'should return the original bundle (not updated) on subsequent publish',
        () async {
          // Arrange
          final bundle = buildMenuBundle(
            id: 1,
            name: 'Existing',
            pdfFileId: 'existing-id',
          );
          bundleRepo.whenGetById(success(bundle));
          fetchMenuTree.stubExecute(Success(buildSimpleTree()));
          fileRepo.whenReplace(success('existing-id'));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.name, equals('Existing'));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Bundle with no menus
    // -------------------------------------------------------------------------

    group('bundle with no menus', () {
      test(
        'should attempt to build PDF when bundle has empty menuIds',
        () async {
          // Arrange
          bundleRepo.whenGetById(success(buildMenuBundle(id: 1, menuIds: [])));
          fileRepo.whenUpload(success('file-id'));
          bundleRepo.whenUpdate(success(buildMenuBundle(id: 1)));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(fetchMenuTree.calls, isEmpty);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Multiple menus in bundle
    // -------------------------------------------------------------------------

    group('multiple menus in bundle', () {
      test(
        'should fetch each menu tree in order when bundle contains multiple menus',
        () async {
          // Arrange
          bundleRepo.whenGetById(
            success(buildMenuBundle(id: 1, menuIds: [10, 20, 30])),
          );
          fetchMenuTree.stubExecute(Success(buildSimpleTree()));
          fileRepo.whenUpload(success('file-id'));
          bundleRepo.whenUpdate(success(buildMenuBundle(id: 1)));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(fetchMenuTree.calls.length, equals(3));
          expect(fetchMenuTree.calls[0].menuId, equals(10));
          expect(fetchMenuTree.calls[1].menuId, equals(20));
          expect(fetchMenuTree.calls[2].menuId, equals(30));
        },
      );

      test(
        'should abort and return Failure on first menu tree fetch failure',
        () async {
          // Arrange
          bundleRepo.whenGetById(
            success(buildMenuBundle(id: 1, menuIds: [10, 20])),
          );
          fetchMenuTree.stubExecute(failure(notFound()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          // Only the first menuId's fetch is attempted before aborting
          expect(fetchMenuTree.calls.length, equals(1));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Watermark text
    // -------------------------------------------------------------------------

    group('watermark text', () {
      test(
        'should use default "SAMPLE MENU" watermark when not explicitly configured',
        () async {
          // Arrange
          bundleRepo.whenGetById(success(buildMenuBundle(id: 1, menuIds: [])));
          fileRepo.whenUpload(success('file-id'));
          bundleRepo.whenUpdate(success(buildMenuBundle(id: 1)));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(useCase.watermarkText, equals('SAMPLE MENU'));
        },
      );

      test('should allow custom watermark text at construction', () async {
        // Arrange
        final customUseCase = PublishMenuBundleUseCase(
          repository: bundleRepo,
          fetchMenuTreeUseCase: fetchMenuTree,
          fileRepository: fileRepo,
          assetLoader: assetLoader,
          pdfBuilder: pdfBuilder,
          watermarkText: 'PREVIEW ONLY',
        );
        bundleRepo.whenGetById(success(buildMenuBundle(id: 1, menuIds: [])));
        fileRepo.whenUpload(success('file-id'));
        bundleRepo.whenUpdate(success(buildMenuBundle(id: 1)));

        // Act
        final result = await customUseCase.execute(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(customUseCase.watermarkText, equals('PREVIEW ONLY'));
      });
    });

    // -------------------------------------------------------------------------
    // Asset loading
    // -------------------------------------------------------------------------

    group('asset loading', () {
      test(
        'should load exactly three font assets before building the PDF',
        () async {
          // Arrange
          bundleRepo.whenGetById(success(buildMenuBundle(id: 1, menuIds: [])));
          fileRepo.whenUpload(success('file-id'));
          bundleRepo.whenUpdate(success(buildMenuBundle(id: 1)));

          // Act
          await useCase.execute(1);

          // Assert
          expect(assetLoader.loadAssetCalls.length, equals(3));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Header and footer pages
    // -------------------------------------------------------------------------

    group('menu with header and footer pages', () {
      test(
        'should succeed when bundle includes a menu with header and footer pages',
        () async {
          // Arrange
          final menu = buildMenu(id: 10);
          final tree = MenuTree(
            menu: menu,
            pages: [],
            headerPage: PageWithContainers(
              page: buildPage(id: 1, menuId: 10, type: PageType.header),
              containers: [],
            ),
            footerPage: PageWithContainers(
              page: buildPage(id: 2, menuId: 10, type: PageType.footer),
              containers: [],
            ),
          );
          bundleRepo.whenGetById(
            success(buildMenuBundle(id: 1, menuIds: [10], pdfFileId: null)),
          );
          fetchMenuTree.stubExecute(Success(tree));
          fileRepo.whenUpload(success('file-id'));
          bundleRepo.whenUpdate(success(buildMenuBundle(id: 1)));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );
    });
  });
}
