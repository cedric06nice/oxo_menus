import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/asset_loader_repository.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/pdf_document_builder.dart';
import 'package:oxo_menus/domain/usecases/publish_menu_bundle_usecase.dart';

class MockMenuBundleRepository extends Mock implements MenuBundleRepository {}

class MockFetchMenuTreeUseCase extends Mock implements FetchMenuTreeUseCase {}

class MockFileRepository extends Mock implements FileRepository {}

class MockAssetLoaderRepository extends Mock implements AssetLoaderRepository {}

class MockPdfDocumentBuilder extends Mock implements PdfDocumentBuilder {}

MenuTree _emptyTree(int menuId) => MenuTree(
  menu: Menu(
    id: menuId,
    name: 'Menu $menuId',
    status: Status.published,
    version: '1.0.0',
  ),
  pages: [
    PageWithContainers(
      page: entity.Page(id: menuId * 100, menuId: menuId, name: 'p0', index: 0),
      containers: [
        ContainerWithColumns(
          container: entity.Container(
            id: menuId * 1000,
            pageId: menuId * 100,
            index: 0,
          ),
          columns: const [],
        ),
      ],
    ),
  ],
);

void main() {
  late MockMenuBundleRepository repo;
  late MockFetchMenuTreeUseCase fetchTree;
  late MockFileRepository fileRepo;
  late MockAssetLoaderRepository assetLoader;
  late MockPdfDocumentBuilder pdfBuilder;
  late PublishMenuBundleUseCase useCase;

  final sampleBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);
  final fontBytes = ByteData(4);

  setUpAll(() {
    registerFallbackValue(const UpdateMenuBundleInput(id: 0));
    registerFallbackValue(<MenuTree>[]);
    registerFallbackValue(const MenuDisplayOptions());
    registerFallbackValue(<String, Uint8List>{});
    registerFallbackValue(ByteData(0));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repo = MockMenuBundleRepository();
    fetchTree = MockFetchMenuTreeUseCase();
    fileRepo = MockFileRepository();
    assetLoader = MockAssetLoaderRepository();
    pdfBuilder = MockPdfDocumentBuilder();
    useCase = PublishMenuBundleUseCase(
      repository: repo,
      fetchMenuTreeUseCase: fetchTree,
      fileRepository: fileRepo,
      assetLoader: assetLoader,
      pdfBuilder: pdfBuilder,
    );

    when(() => assetLoader.loadAsset(any())).thenAnswer((_) async => fontBytes);
    when(
      () => pdfBuilder.buildBundleDocument(
        trees: any(named: 'trees'),
        baseOptions: any(named: 'baseOptions'),
        baseFontData: any(named: 'baseFontData'),
        boldFontData: any(named: 'boldFontData'),
        sectionFontData: any(named: 'sectionFontData'),
        imageCache: any(named: 'imageCache'),
        watermarkText: any(named: 'watermarkText'),
      ),
    ).thenAnswer((_) async => sampleBytes);
  });

  group('PublishMenuBundleUseCase', () {
    test(
      'fetches all menu trees in menuIds order, builds with SAMPLE MENU watermark, '
      'uploads on first publish, and persists the new pdfFileId',
      () async {
        const bundle = MenuBundle(id: 1, name: 'Sample', menuIds: [10, 20]);
        when(
          () => repo.getById(1),
        ).thenAnswer((_) async => const Success(bundle));
        when(
          () => fetchTree.execute(10),
        ).thenAnswer((_) async => Success(_emptyTree(10)));
        when(
          () => fetchTree.execute(20),
        ).thenAnswer((_) async => Success(_emptyTree(20)));
        when(
          () => fileRepo.upload(sampleBytes, 'Sample.pdf'),
        ).thenAnswer((_) async => const Success('new-file-id'));
        when(() => repo.update(any())).thenAnswer(
          (inv) async => Success(bundle.copyWith(pdfFileId: 'new-file-id')),
        );

        final result = await useCase.execute(1);

        expect(result.isSuccess, true);
        expect(result.valueOrNull!.pdfFileId, 'new-file-id');

        // Trees fetched in order
        verifyInOrder([
          () => fetchTree.execute(10),
          () => fetchTree.execute(20),
        ]);

        // Builder received the captured args with correct watermark and tree count
        final captured =
            verify(
                  () => pdfBuilder.buildBundleDocument(
                    trees: captureAny(named: 'trees'),
                    baseOptions: any(named: 'baseOptions'),
                    baseFontData: any(named: 'baseFontData'),
                    boldFontData: any(named: 'boldFontData'),
                    sectionFontData: any(named: 'sectionFontData'),
                    imageCache: any(named: 'imageCache'),
                    watermarkText: 'SAMPLE MENU',
                  ),
                ).captured.single
                as List<MenuTree>;
        expect(captured.length, 2);
        expect(captured.map((t) => t.menu.id), [10, 20]);

        // Upload was used, not replace
        verify(() => fileRepo.upload(sampleBytes, 'Sample.pdf')).called(1);
        verifyNever(() => fileRepo.replace(any(), any(), any()));

        // pdfFileId persisted via repo.update
        final updateCall =
            verify(() => repo.update(captureAny())).captured.single
                as UpdateMenuBundleInput;
        expect(updateCall.id, 1);
        expect(updateCall.pdfFileId, 'new-file-id');
      },
    );

    test(
      'replaces the existing Directus file when pdfFileId is already set',
      () async {
        const bundle = MenuBundle(
          id: 1,
          name: 'Sample',
          menuIds: [10],
          pdfFileId: 'existing-file',
        );
        when(
          () => repo.getById(1),
        ).thenAnswer((_) async => const Success(bundle));
        when(
          () => fetchTree.execute(10),
        ).thenAnswer((_) async => Success(_emptyTree(10)));
        when(
          () => fileRepo.replace('existing-file', sampleBytes, 'Sample.pdf'),
        ).thenAnswer((_) async => const Success('existing-file'));

        final result = await useCase.execute(1);

        expect(result.isSuccess, true);
        expect(result.valueOrNull!.pdfFileId, 'existing-file');

        verify(
          () => fileRepo.replace('existing-file', sampleBytes, 'Sample.pdf'),
        ).called(1);
        verifyNever(() => fileRepo.upload(any(), any()));
        // No repo.update needed since the fileId hasn't changed
        verifyNever(() => repo.update(any()));
      },
    );

    test('propagates failure when a menu tree cannot be fetched', () async {
      const bundle = MenuBundle(id: 1, name: 'Sample', menuIds: [10, 20]);
      when(
        () => repo.getById(1),
      ).thenAnswer((_) async => const Success(bundle));
      when(
        () => fetchTree.execute(10),
      ).thenAnswer((_) async => Success(_emptyTree(10)));
      when(() => fetchTree.execute(20)).thenAnswer(
        (_) async =>
            const Failure<MenuTree, DomainError>(NotFoundError('no menu')),
      );

      final result = await useCase.execute(1);

      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<NotFoundError>());
      verifyNever(
        () => pdfBuilder.buildBundleDocument(
          trees: any(named: 'trees'),
          baseOptions: any(named: 'baseOptions'),
          baseFontData: any(named: 'baseFontData'),
          boldFontData: any(named: 'boldFontData'),
          sectionFontData: any(named: 'sectionFontData'),
          imageCache: any(named: 'imageCache'),
          watermarkText: any(named: 'watermarkText'),
        ),
      );
      verifyNever(() => fileRepo.upload(any(), any()));
      verifyNever(() => fileRepo.replace(any(), any(), any()));
    });

    test(
      'propagates failure from repo.getById and does not attempt to build a PDF',
      () async {
        when(() => repo.getById(99)).thenAnswer(
          (_) async =>
              const Failure<MenuBundle, DomainError>(NotFoundError('gone')),
        );

        final result = await useCase.execute(99);

        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
        verifyNever(() => fetchTree.execute(any()));
      },
    );
  });
}
