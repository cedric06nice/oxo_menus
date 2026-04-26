import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/admin_exportable_menus_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/admin_exportable_menus_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/admin_exportable_menus_state.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

import '../../../../fakes/fake_create_menu_bundle_usecase.dart';
import '../../../../fakes/fake_delete_menu_bundle_usecase.dart';
import '../../../../fakes/fake_list_menu_bundles_usecase.dart';
import '../../../../fakes/fake_list_templates_usecase.dart';
import '../../../../fakes/fake_publish_menu_bundle_usecase.dart';
import '../../../../fakes/fake_update_menu_bundle_usecase.dart';

void main() {
  late ProviderContainer container;
  late FakeListMenuBundlesUseCase fakeListBundles;
  late FakeListTemplatesUseCase fakeListTemplates;
  late FakeCreateMenuBundleUseCase fakeCreateUseCase;
  late FakeUpdateMenuBundleUseCase fakeUpdateUseCase;
  late FakeDeleteMenuBundleUseCase fakeDeleteUseCase;
  late FakePublishMenuBundleUseCase fakePublishUseCase;

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

  setUp(() {
    fakeListBundles = FakeListMenuBundlesUseCase();
    fakeListTemplates = FakeListTemplatesUseCase();
    fakeCreateUseCase = FakeCreateMenuBundleUseCase();
    fakeUpdateUseCase = FakeUpdateMenuBundleUseCase();
    fakeDeleteUseCase = FakeDeleteMenuBundleUseCase();
    fakePublishUseCase = FakePublishMenuBundleUseCase();
    container = ProviderContainer(
      overrides: [
        listMenuBundlesUseCaseProvider.overrideWithValue(fakeListBundles),
        listTemplatesUseCaseProvider.overrideWithValue(fakeListTemplates),
        createMenuBundleUseCaseProvider.overrideWithValue(fakeCreateUseCase),
        updateMenuBundleUseCaseProvider.overrideWithValue(fakeUpdateUseCase),
        deleteMenuBundleUseCaseProvider.overrideWithValue(fakeDeleteUseCase),
        publishMenuBundleUseCaseProvider.overrideWithValue(fakePublishUseCase),
      ],
    );
  });

  tearDown(() => container.dispose());

  AdminExportableMenusNotifier notifier() =>
      container.read(adminExportableMenusProvider.notifier);
  AdminExportableMenusState state() =>
      container.read(adminExportableMenusProvider);

  group('AdminExportableMenusNotifier', () {
    group('initial state', () {
      test('should have empty bundles list', () {
        expect(state().bundles, isEmpty);
      });

      test('should have empty availableMenus list', () {
        expect(state().availableMenus, isEmpty);
      });

      test('should have isLoading false', () {
        expect(state().isLoading, isFalse);
      });

      test('should have null errorMessage', () {
        expect(state().errorMessage, isNull);
      });
    });

    group('load', () {
      test(
        'should load bundles and available menus and store them in state',
        () async {
          fakeListBundles.stubExecute(const Success([b1, b2]));
          fakeListTemplates.stubExecute(const Success([menu1, menu2]));

          await notifier().load();

          expect(state().bundles, [b1, b2]);
          expect(state().availableMenus, [menu1, menu2]);
          expect(state().isLoading, isFalse);
          expect(state().errorMessage, isNull);
        },
      );

      test('should surface bundle-load failure as error message', () async {
        fakeListBundles.stubExecute(
          const Failure<List<MenuBundle>, DomainError>(ServerError('boom')),
        );
        fakeListTemplates.stubExecute(const Success([menu1]));

        await notifier().load();

        expect(state().isLoading, isFalse);
        expect(state().errorMessage, 'boom');
      });

      test('should surface menus-load failure as error message', () async {
        fakeListBundles.stubExecute(const Success([b1]));
        fakeListTemplates.stubExecute(
          const Failure<List<Menu>, DomainError>(ServerError('menus fail')),
        );

        await notifier().load();

        expect(state().isLoading, isFalse);
        expect(state().errorMessage, 'menus fail');
      });

      test('should set isLoading false after success', () async {
        fakeListBundles.stubExecute(const Success([b1]));
        fakeListTemplates.stubExecute(const Success([menu1]));

        await notifier().load();

        expect(state().isLoading, isFalse);
      });

      test('should clear previous error on load', () async {
        fakeListBundles.stubExecute(
          const Failure<List<MenuBundle>, DomainError>(ServerError('error')),
        );
        fakeListTemplates.stubExecute(const Success([menu1]));
        await notifier().load();
        expect(state().errorMessage, isNotNull);

        fakeListBundles.stubExecute(const Success([b1]));
        fakeListTemplates.stubExecute(const Success([menu1]));
        await notifier().load();

        expect(state().errorMessage, isNull);
      });

      test('should call list-bundles use case once', () async {
        fakeListBundles.stubExecute(const Success([b1]));
        fakeListTemplates.stubExecute(const Success([menu1]));

        await notifier().load();

        expect(fakeListBundles.calls, hasLength(1));
      });

      test(
        'should call list-templates use case with statusFilter all',
        () async {
          fakeListBundles.stubExecute(const Success([b1]));
          fakeListTemplates.stubExecute(const Success([menu1]));

          await notifier().load();

          expect(fakeListTemplates.calls, hasLength(1));
          expect(fakeListTemplates.calls.first.statusFilter, 'all');
        },
      );
    });

    group('create', () {
      test(
        'should append the new bundle to state and return it on success',
        () async {
          fakeListBundles.stubExecute(const Success([b1]));
          fakeListTemplates.stubExecute(const Success([menu1]));
          await notifier().load();

          fakeCreateUseCase.stubExecute(const Success(b2));

          final result = await notifier().create(
            const CreateMenuBundleInput(name: 'B', menuIds: [10, 20]),
          );

          expect(result, b2);
          expect(state().bundles, [b1, b2]);
        },
      );

      test('should return null and set errorMessage on failure', () async {
        fakeCreateUseCase.stubExecute(
          const Failure<MenuBundle, DomainError>(ServerError('nope')),
        );

        final result = await notifier().create(
          const CreateMenuBundleInput(name: 'X'),
        );

        expect(result, isNull);
        expect(state().errorMessage, 'nope');
      });

      test('should record the create call', () async {
        fakeCreateUseCase.stubExecute(const Success(b2));

        await notifier().create(const CreateMenuBundleInput(name: 'B'));

        expect(fakeCreateUseCase.calls, hasLength(1));
      });
    });

    group('update', () {
      test(
        'should replace the matching bundle in state and return it on success',
        () async {
          fakeListBundles.stubExecute(const Success([b1, b2]));
          fakeListTemplates.stubExecute(const Success([menu1]));
          await notifier().load();

          const renamed = MenuBundle(
            id: 2,
            name: 'B renamed',
            menuIds: [10, 20],
          );
          fakeUpdateUseCase.stubExecute(const Success(renamed));

          final result = await notifier().update(
            const UpdateMenuBundleInput(id: 2, name: 'B renamed'),
          );

          expect(result, renamed);
          expect(state().bundles, [b1, renamed]);
        },
      );

      test('should return null and set errorMessage on failure', () async {
        fakeUpdateUseCase.stubExecute(
          const Failure<MenuBundle, DomainError>(ServerError('boom')),
        );

        final result = await notifier().update(
          const UpdateMenuBundleInput(id: 99, name: 'X'),
        );

        expect(result, isNull);
        expect(state().errorMessage, 'boom');
      });

      test('should record the update call with the correct id', () async {
        const renamed = MenuBundle(id: 2, name: 'B renamed', menuIds: [10, 20]);
        fakeUpdateUseCase.stubExecute(const Success(renamed));

        await notifier().update(
          const UpdateMenuBundleInput(id: 2, name: 'B renamed'),
        );

        expect(fakeUpdateUseCase.calls, hasLength(1));
        expect(fakeUpdateUseCase.calls.first.input.id, 2);
      });
    });

    group('delete', () {
      test('should remove the bundle from state on success', () async {
        fakeListBundles.stubExecute(const Success([b1, b2]));
        fakeListTemplates.stubExecute(const Success([menu1]));
        await notifier().load();

        fakeDeleteUseCase.stubExecute(const Success<void, DomainError>(null));

        await notifier().delete(1);

        expect(state().bundles, [b2]);
      });

      test('should set errorMessage on delete failure', () async {
        fakeDeleteUseCase.stubExecute(
          const Failure<void, DomainError>(ServerError('delete fail')),
        );

        await notifier().delete(1);

        expect(state().errorMessage, 'delete fail');
      });

      test('should record the delete call with the correct id', () async {
        fakeDeleteUseCase.stubExecute(const Success<void, DomainError>(null));

        await notifier().delete(42);

        expect(fakeDeleteUseCase.calls, hasLength(1));
        expect(fakeDeleteUseCase.calls.first.id, 42);
      });
    });

    group('publish', () {
      test(
        'should replace matching bundle with published version on success',
        () async {
          fakeListBundles.stubExecute(const Success([b1, b2]));
          fakeListTemplates.stubExecute(const Success([menu1, menu2]));
          await notifier().load();

          const published = MenuBundle(
            id: 2,
            name: 'B',
            menuIds: [10, 20],
            pdfFileId: 'file-uuid-42',
          );
          fakePublishUseCase.stubExecute(const Success(published));

          final result = await notifier().publish(2);

          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, published);
          expect(state().bundles, [b1, published]);
        },
      );

      test(
        'should return failure and set errorMessage on publish failure',
        () async {
          fakeListBundles.stubExecute(const Success([b1]));
          fakeListTemplates.stubExecute(const Success([menu1]));
          await notifier().load();

          fakePublishUseCase.stubExecute(
            const Failure<MenuBundle, DomainError>(ServerError('pdf fail')),
          );

          final result = await notifier().publish(1);

          expect(result.isFailure, isTrue);
          expect(state().errorMessage, 'pdf fail');
          expect(state().bundles, [b1]);
        },
      );

      test('should leave bundles unchanged on failure', () async {
        fakeListBundles.stubExecute(const Success([b1, b2]));
        fakeListTemplates.stubExecute(const Success([menu1]));
        await notifier().load();

        fakePublishUseCase.stubExecute(
          const Failure<MenuBundle, DomainError>(ServerError('err')),
        );

        await notifier().publish(2);

        expect(state().bundles, [b1, b2]);
      });
    });

    group('clearError', () {
      test('should clear error message when one is set', () async {
        fakeListBundles.stubExecute(
          const Failure<List<MenuBundle>, DomainError>(ServerError('err')),
        );
        fakeListTemplates.stubExecute(const Success([menu1]));
        await notifier().load();
        expect(state().errorMessage, isNotNull);

        notifier().clearError();

        expect(state().errorMessage, isNull);
      });

      test('should be a no-op when there is no error', () {
        expect(state().errorMessage, isNull);

        notifier().clearError();

        expect(state().errorMessage, isNull);
      });
    });
  });
}
