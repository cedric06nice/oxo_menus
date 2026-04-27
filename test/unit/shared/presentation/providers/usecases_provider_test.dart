import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/usecases/create_menu_bundle_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/delete_menu_bundle_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/get_menu_bundle_usecase.dart';
import 'package:oxo_menus/shared/domain/usecases/list_image_files_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/list_menu_bundles_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/list_sizes_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/list_templates_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_bundles_for_menu_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_menu_bundle_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/reorder_container_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/update_menu_bundle_usecase.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/usecases_provider.dart';

import '../../../../fakes/fake_asset_loader_repository.dart';
import '../../../../fakes/fake_column_repository.dart';
import '../../../../fakes/fake_container_repository.dart';
import '../../../../fakes/fake_file_repository.dart';
import '../../../../fakes/fake_menu_bundle_repository.dart';
import '../../../../fakes/fake_menu_repository.dart';
import '../../../../fakes/fake_page_repository.dart';
import '../../../../fakes/fake_size_repository.dart';
import '../../../../fakes/fake_widget_repository.dart';

void main() {
  group('usecases_provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
          pageRepositoryProvider.overrideWithValue(FakePageRepository()),
          containerRepositoryProvider.overrideWithValue(
            FakeContainerRepository(),
          ),
          columnRepositoryProvider.overrideWithValue(FakeColumnRepository()),
          widgetRepositoryProvider.overrideWithValue(FakeWidgetRepository()),
          sizeRepositoryProvider.overrideWithValue(FakeSizeRepository()),
          fileRepositoryProvider.overrideWithValue(FakeFileRepository()),
          menuBundleRepositoryProvider.overrideWithValue(
            FakeMenuBundleRepository(),
          ),
          assetLoaderRepositoryProvider.overrideWithValue(
            FakeAssetLoaderRepository(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test(
      'fetchMenuTreeUseCaseProvider should return a FetchMenuTreeUseCase',
      () {
        expect(
          container.read(fetchMenuTreeUseCaseProvider),
          isA<FetchMenuTreeUseCase>(),
        );
      },
    );

    test('generatePdfUseCaseProvider should return a GeneratePdfUseCase', () {
      expect(
        container.read(generatePdfUseCaseProvider),
        isA<GeneratePdfUseCase>(),
      );
    });

    test(
      'listImageFilesUseCaseProvider should return a ListImageFilesUseCase',
      () {
        expect(
          container.read(listImageFilesUseCaseProvider),
          isA<ListImageFilesUseCase>(),
        );
      },
    );

    test('listSizesUseCaseProvider should return a ListSizesUseCase', () {
      expect(container.read(listSizesUseCaseProvider), isA<ListSizesUseCase>());
    });

    test(
      'listTemplatesUseCaseProvider should return a ListTemplatesUseCase',
      () {
        expect(
          container.read(listTemplatesUseCaseProvider),
          isA<ListTemplatesUseCase>(),
        );
      },
    );

    test(
      'reorderContainerUseCaseProvider should return a ReorderContainerUseCase',
      () {
        expect(
          container.read(reorderContainerUseCaseProvider),
          isA<ReorderContainerUseCase>(),
        );
      },
    );

    test(
      'duplicateContainerUseCaseProvider should return a DuplicateContainerUseCase',
      () {
        expect(
          container.read(duplicateContainerUseCaseProvider),
          isA<DuplicateContainerUseCase>(),
        );
      },
    );

    test(
      'duplicateMenuUseCaseProvider should return a DuplicateMenuUseCase',
      () {
        expect(
          container.read(duplicateMenuUseCaseProvider),
          isA<DuplicateMenuUseCase>(),
        );
      },
    );

    test(
      'listMenuBundlesUseCaseProvider should return a ListMenuBundlesUseCase',
      () {
        expect(
          container.read(listMenuBundlesUseCaseProvider),
          isA<ListMenuBundlesUseCase>(),
        );
      },
    );

    test(
      'getMenuBundleUseCaseProvider should return a GetMenuBundleUseCase',
      () {
        expect(
          container.read(getMenuBundleUseCaseProvider),
          isA<GetMenuBundleUseCase>(),
        );
      },
    );

    test(
      'createMenuBundleUseCaseProvider should return a CreateMenuBundleUseCase',
      () {
        expect(
          container.read(createMenuBundleUseCaseProvider),
          isA<CreateMenuBundleUseCase>(),
        );
      },
    );

    test(
      'updateMenuBundleUseCaseProvider should return an UpdateMenuBundleUseCase',
      () {
        expect(
          container.read(updateMenuBundleUseCaseProvider),
          isA<UpdateMenuBundleUseCase>(),
        );
      },
    );

    test(
      'deleteMenuBundleUseCaseProvider should return a DeleteMenuBundleUseCase',
      () {
        expect(
          container.read(deleteMenuBundleUseCaseProvider),
          isA<DeleteMenuBundleUseCase>(),
        );
      },
    );

    test(
      'publishMenuBundleUseCaseProvider should return a PublishMenuBundleUseCase',
      () {
        expect(
          container.read(publishMenuBundleUseCaseProvider),
          isA<PublishMenuBundleUseCase>(),
        );
      },
    );

    test(
      'publishBundlesForMenuUseCaseProvider should return a PublishBundlesForMenuUseCase',
      () {
        expect(
          container.read(publishBundlesForMenuUseCaseProvider),
          isA<PublishBundlesForMenuUseCase>(),
        );
      },
    );

    test('should return same use case instance on multiple reads', () {
      final uc1 = container.read(fetchMenuTreeUseCaseProvider);
      final uc2 = container.read(fetchMenuTreeUseCaseProvider);
      expect(identical(uc1, uc2), isTrue);
    });
  });
}
