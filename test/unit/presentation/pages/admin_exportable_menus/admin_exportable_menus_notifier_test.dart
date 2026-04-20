import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/usecases/create_menu_bundle_usecase.dart';
import 'package:oxo_menus/domain/usecases/delete_menu_bundle_usecase.dart';
import 'package:oxo_menus/domain/usecases/list_menu_bundles_usecase.dart';
import 'package:oxo_menus/domain/usecases/list_templates_usecase.dart';
import 'package:oxo_menus/domain/usecases/update_menu_bundle_usecase.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/admin_exportable_menus_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/admin_exportable_menus_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/admin_exportable_menus_state.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

class MockListMenuBundlesUseCase extends Mock
    implements ListMenuBundlesUseCase {}

class MockListTemplatesUseCase extends Mock implements ListTemplatesUseCase {}

class MockCreateMenuBundleUseCase extends Mock
    implements CreateMenuBundleUseCase {}

class MockUpdateMenuBundleUseCase extends Mock
    implements UpdateMenuBundleUseCase {}

class MockDeleteMenuBundleUseCase extends Mock
    implements DeleteMenuBundleUseCase {}

void main() {
  late ProviderContainer container;
  late MockListMenuBundlesUseCase listBundles;
  late MockListTemplatesUseCase listTemplates;
  late MockCreateMenuBundleUseCase createUseCase;
  late MockUpdateMenuBundleUseCase updateUseCase;
  late MockDeleteMenuBundleUseCase deleteUseCase;

  const menu1 = Menu(
    id: 10,
    name: 'Mains',
    status: Status.published,
    version: '1',
  );
  const menu2 = Menu(
    id: 20,
    name: 'Desserts',
    status: Status.published,
    version: '1',
  );
  const b1 = MenuBundle(id: 1, name: 'A', menuIds: [10]);
  const b2 = MenuBundle(id: 2, name: 'B', menuIds: [10, 20]);

  setUpAll(() {
    registerFallbackValue(const CreateMenuBundleInput(name: ''));
    registerFallbackValue(const UpdateMenuBundleInput(id: 0));
  });

  setUp(() {
    listBundles = MockListMenuBundlesUseCase();
    listTemplates = MockListTemplatesUseCase();
    createUseCase = MockCreateMenuBundleUseCase();
    updateUseCase = MockUpdateMenuBundleUseCase();
    deleteUseCase = MockDeleteMenuBundleUseCase();
    container = ProviderContainer(
      overrides: [
        listMenuBundlesUseCaseProvider.overrideWithValue(listBundles),
        listTemplatesUseCaseProvider.overrideWithValue(listTemplates),
        createMenuBundleUseCaseProvider.overrideWithValue(createUseCase),
        updateMenuBundleUseCaseProvider.overrideWithValue(updateUseCase),
        deleteMenuBundleUseCaseProvider.overrideWithValue(deleteUseCase),
      ],
    );
  });

  tearDown(() => container.dispose());

  AdminExportableMenusNotifier notifier() =>
      container.read(adminExportableMenusProvider.notifier);
  AdminExportableMenusState state() =>
      container.read(adminExportableMenusProvider);

  group('AdminExportableMenusNotifier', () {
    test('initial state is empty and not loading', () {
      expect(state(), const AdminExportableMenusState());
    });

    group('load', () {
      test(
        'loads bundles AND available menus in parallel and stores them in state',
        () async {
          when(
            () => listBundles.execute(),
          ).thenAnswer((_) async => const Success([b1, b2]));
          when(
            () => listTemplates.execute(statusFilter: 'all'),
          ).thenAnswer((_) async => const Success([menu1, menu2]));

          await notifier().load();

          expect(state().bundles, [b1, b2]);
          expect(state().availableMenus, [menu1, menu2]);
          expect(state().isLoading, false);
          expect(state().errorMessage, isNull);
        },
      );

      test('surfaces bundle-load failure as error message', () async {
        when(() => listBundles.execute()).thenAnswer(
          (_) async =>
              const Failure<List<MenuBundle>, DomainError>(ServerError('boom')),
        );
        when(
          () => listTemplates.execute(statusFilter: 'all'),
        ).thenAnswer((_) async => const Success([menu1]));

        await notifier().load();

        expect(state().isLoading, false);
        expect(state().errorMessage, 'boom');
      });
    });

    group('create', () {
      test('appends the new bundle to state on success', () async {
        when(
          () => listBundles.execute(),
        ).thenAnswer((_) async => const Success([b1]));
        when(
          () => listTemplates.execute(statusFilter: 'all'),
        ).thenAnswer((_) async => const Success([menu1]));
        await notifier().load();

        when(
          () => createUseCase.execute(any()),
        ).thenAnswer((_) async => const Success(b2));

        await notifier().create(
          const CreateMenuBundleInput(name: 'B', menuIds: [10, 20]),
        );

        expect(state().bundles, [b1, b2]);
      });

      test('sets errorMessage on failure', () async {
        when(() => createUseCase.execute(any())).thenAnswer(
          (_) async =>
              const Failure<MenuBundle, DomainError>(ServerError('nope')),
        );

        await notifier().create(const CreateMenuBundleInput(name: 'X'));

        expect(state().errorMessage, 'nope');
      });
    });

    group('update', () {
      test('replaces the matching bundle in state on success', () async {
        when(
          () => listBundles.execute(),
        ).thenAnswer((_) async => const Success([b1, b2]));
        when(
          () => listTemplates.execute(statusFilter: 'all'),
        ).thenAnswer((_) async => const Success([menu1]));
        await notifier().load();

        const renamed = MenuBundle(id: 2, name: 'B renamed', menuIds: [10, 20]);
        when(
          () => updateUseCase.execute(any()),
        ).thenAnswer((_) async => const Success(renamed));

        await notifier().update(
          const UpdateMenuBundleInput(id: 2, name: 'B renamed'),
        );

        expect(state().bundles, [b1, renamed]);
      });
    });

    group('delete', () {
      test('removes the bundle from state on success', () async {
        when(
          () => listBundles.execute(),
        ).thenAnswer((_) async => const Success([b1, b2]));
        when(
          () => listTemplates.execute(statusFilter: 'all'),
        ).thenAnswer((_) async => const Success([menu1]));
        await notifier().load();

        when(
          () => deleteUseCase.execute(1),
        ).thenAnswer((_) async => const Success<void, DomainError>(null));

        await notifier().delete(1);

        expect(state().bundles, [b2]);
      });
    });
  });
}
