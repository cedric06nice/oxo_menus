import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu_list/presentation/providers/menu_list_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/usecases_provider.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_fetch_menu_tree_usecase.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_size_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';
import '../../../../../fakes/result_helpers.dart';

// ---------------------------------------------------------------------------
// Inline fake for DuplicateMenuUseCase
// ---------------------------------------------------------------------------

/// A fake [DuplicateMenuUseCase] that intercepts [execute] and returns a
/// pre-configured result without touching any real repositories.
class FakeDuplicateMenuUseCase extends DuplicateMenuUseCase {
  FakeDuplicateMenuUseCase()
    : super(
        fetchMenuTreeUseCase: FakeFetchMenuTreeUseCase(),
        menuRepository: FakeMenuRepository(),
        pageRepository: FakePageRepository(),
        containerRepository: FakeContainerRepository(),
        columnRepository: FakeColumnRepository(),
        widgetRepository: FakeWidgetRepository(),
        sizeRepository: FakeSizeRepository(),
      );

  final List<int> executeCalls = [];
  Result<Menu, DomainError>? _duplicateResult;

  void whenDuplicate(Result<Menu, DomainError> result) {
    _duplicateResult = result;
  }

  @override
  Future<Result<Menu, DomainError>> execute(int sourceMenuId) async {
    executeCalls.add(sourceMenuId);
    if (_duplicateResult != null) return _duplicateResult!;
    throw StateError(
      'FakeDuplicateMenuUseCase: no response configured — call whenDuplicate()',
    );
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const menu1 = Menu(
    id: 1,
    name: 'Summer Menu',
    status: Status.published,
    version: '1.0.0',
  );

  const menu2 = Menu(
    id: 2,
    name: 'Winter Menu',
    status: Status.published,
    version: '1.0.0',
  );

  const menu3 = Menu(
    id: 3,
    name: 'Draft Menu',
    status: Status.draft,
    version: '1.0.0',
  );

  final testMenus = [menu1, menu2, menu3];

  group('MenuListState', () {
    test('should have empty menus, no loading, no error by default', () {
      const state = MenuListState();

      expect(state.menus, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('should support copyWith for all fields', () {
      const original = MenuListState();
      final updated = original.copyWith(
        menus: [menu1],
        isLoading: true,
        errorMessage: 'Error',
      );

      expect(updated.menus, [menu1]);
      expect(updated.isLoading, isTrue);
      expect(updated.errorMessage, 'Error');
    });

    test('should preserve equality for same field values', () {
      final state1 = MenuListState(menus: [menu1]);
      final state2 = MenuListState(menus: [menu1]);

      expect(state1, equals(state2));
    });

    test('should not equal state with different isLoading', () {
      const state1 = MenuListState(isLoading: false);
      const state2 = MenuListState(isLoading: true);

      expect(state1, isNot(equals(state2)));
    });
  });

  group('MenuListNotifier', () {
    late FakeMenuRepository fakeMenuRepo;
    late FakeDuplicateMenuUseCase fakeDuplicate;
    late ProviderContainer container;

    setUp(() {
      fakeMenuRepo = FakeMenuRepository();
      fakeDuplicate = FakeDuplicateMenuUseCase();
      container = ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
          duplicateMenuUseCaseProvider.overrideWithValue(fakeDuplicate),
        ],
      );
    });

    tearDown(() => container.dispose());

    MenuListNotifier readNotifier() =>
        container.read(menuListProvider.notifier);
    MenuListState readState() => container.read(menuListProvider);

    test('should start with empty state', () {
      expect(readState().menus, isEmpty);
      expect(readState().isLoading, isFalse);
      expect(readState().errorMessage, isNull);
    });

    group('loadMenus', () {
      test('should load menus successfully with onlyPublished true', () async {
        fakeMenuRepo.whenListAll(success(testMenus));

        await readNotifier().loadMenus(onlyPublished: true);

        expect(readState().menus, testMenus);
        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, isNull);
      });

      test('should pass onlyPublished false to the repository', () async {
        fakeMenuRepo.whenListAll(success(testMenus));

        await readNotifier().loadMenus(onlyPublished: false);

        expect(fakeMenuRepo.listAllCalls.first.onlyPublished, isFalse);
      });

      test('should set loading state during load', () async {
        fakeMenuRepo.whenListAll(success(testMenus));
        final states = <MenuListState>[];
        container.listen<MenuListState>(
          menuListProvider,
          (_, next) => states.add(next),
        );

        await readNotifier().loadMenus(onlyPublished: true);

        expect(states.any((s) => s.isLoading), isTrue);
        expect(readState().isLoading, isFalse);
      });

      test('should set error message when load fails', () async {
        fakeMenuRepo.whenListAll(failureNetwork<List<Menu>>('Connection lost'));

        await readNotifier().loadMenus(onlyPublished: true);

        expect(readState().menus, isEmpty);
        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, 'Connection lost');
      });

      test('should clear previous error when load succeeds', () async {
        fakeMenuRepo.whenListAll(failureNetwork<List<Menu>>('Error'));
        await readNotifier().loadMenus(onlyPublished: true);
        expect(readState().errorMessage, 'Error');

        fakeMenuRepo.whenListAll(success(testMenus));
        await readNotifier().loadMenus(onlyPublished: true);

        expect(readState().errorMessage, isNull);
        expect(readState().menus, testMenus);
      });

      test('should pass areaIds to repository', () async {
        fakeMenuRepo.whenListAll(success([menu1]));

        await readNotifier().loadMenus(onlyPublished: true, areaIds: [1]);

        expect(fakeMenuRepo.listAllCalls.first.areaIds, [1]);
      });

      test('should pass null areaIds when not specified', () async {
        fakeMenuRepo.whenListAll(success(testMenus));

        await readNotifier().loadMenus(onlyPublished: true);

        expect(fakeMenuRepo.listAllCalls.first.areaIds, isNull);
      });

      test('should pass empty areaIds list to repository', () async {
        fakeMenuRepo.whenListAll(success(<Menu>[]));

        await readNotifier().loadMenus(onlyPublished: true, areaIds: []);

        expect(fakeMenuRepo.listAllCalls.first.areaIds, isEmpty);
      });
    });

    group('deleteMenu', () {
      test('should remove menu from state when delete succeeds', () async {
        fakeMenuRepo.whenListAll(success(testMenus));
        await readNotifier().loadMenus(onlyPublished: true);
        expect(readState().menus, hasLength(3));

        fakeMenuRepo.whenDelete(success<void>(null));
        await readNotifier().deleteMenu(1);

        expect(readState().menus, hasLength(2));
        expect(readState().menus.any((m) => m.id == 1), isFalse);
      });

      test('should set error message when delete fails', () async {
        fakeMenuRepo.whenListAll(success(testMenus));
        await readNotifier().loadMenus(onlyPublished: true);

        fakeMenuRepo.whenDelete(failureServer<void>('Delete failed'));
        await readNotifier().deleteMenu(1);

        expect(readState().menus, hasLength(3));
        expect(readState().errorMessage, 'Delete failed');
      });

      test(
        'should not change menu count when deleting non-existent id',
        () async {
          fakeMenuRepo.whenListAll(success(testMenus));
          await readNotifier().loadMenus(onlyPublished: true);

          fakeMenuRepo.whenDelete(success<void>(null));
          await readNotifier().deleteMenu(999);

          expect(readState().menus, hasLength(3));
          expect(readState().errorMessage, isNull);
        },
      );

      test('should record delete call with correct id', () async {
        fakeMenuRepo.whenListAll(success(testMenus));
        await readNotifier().loadMenus(onlyPublished: true);
        fakeMenuRepo.whenDelete(success<void>(null));

        await readNotifier().deleteMenu(2);

        expect(fakeMenuRepo.deleteCalls.first.id, 2);
      });
    });

    group('refresh', () {
      test('should reload menus with same defaults', () async {
        fakeMenuRepo.whenListAll(success(testMenus));

        await readNotifier().refresh(onlyPublished: true);

        expect(readState().menus, testMenus);
      });

      test('should pass onlyPublished false through refresh', () async {
        fakeMenuRepo.whenListAll(success(testMenus));

        await readNotifier().refresh(onlyPublished: false);

        expect(fakeMenuRepo.listAllCalls.first.onlyPublished, isFalse);
      });

      test('should pass areaIds through refresh', () async {
        fakeMenuRepo.whenListAll(success([menu1]));

        await readNotifier().refresh(onlyPublished: true, areaIds: [1, 2]);

        expect(fakeMenuRepo.listAllCalls.first.areaIds, [1, 2]);
      });
    });

    group('clearError', () {
      test('should clear the error message', () async {
        fakeMenuRepo.whenListAll(failureNetwork<List<Menu>>('Error'));
        await readNotifier().loadMenus(onlyPublished: true);
        expect(readState().errorMessage, 'Error');

        readNotifier().clearError();

        expect(readState().errorMessage, isNull);
      });

      test(
        'should not affect menus or loading state when clearing error',
        () async {
          fakeMenuRepo.whenListAll(success(testMenus));
          await readNotifier().loadMenus(onlyPublished: true);
          fakeMenuRepo.whenDelete(failureServer<void>('Error'));
          await readNotifier().deleteMenu(1);
          final menusBefore = readState().menus;

          readNotifier().clearError();

          expect(readState().menus, menusBefore);
          expect(readState().isLoading, isFalse);
        },
      );
    });

    group('createMenu', () {
      const newMenu = Menu(
        id: 10,
        name: 'New Menu',
        status: Status.draft,
        version: '1.0.0',
      );

      test(
        'should prepend created menu to list and return it on success',
        () async {
          fakeMenuRepo.whenListAll(success([menu1]));
          await readNotifier().loadMenus(onlyPublished: true);

          fakeMenuRepo.whenCreate(success(newMenu));
          final result = await readNotifier().createMenu(
            const CreateMenuInput(name: 'New Menu', version: '1.0.0'),
          );

          expect(result, newMenu);
          expect(readState().menus.first, newMenu);
          expect(readState().menus, hasLength(2));
        },
      );

      test('should return null and set error on create failure', () async {
        fakeMenuRepo.whenCreate(
          failure<Menu>(const ValidationError('Name required')),
        );

        final result = await readNotifier().createMenu(
          const CreateMenuInput(name: '', version: '1.0.0'),
        );

        expect(result, isNull);
        expect(readState().errorMessage, 'Name required');
        expect(readState().isLoading, isFalse);
      });

      test('should set loading state during creation', () async {
        fakeMenuRepo.whenCreate(success(newMenu));
        final states = <MenuListState>[];
        container.listen<MenuListState>(
          menuListProvider,
          (_, next) => states.add(next),
        );

        await readNotifier().createMenu(
          const CreateMenuInput(name: 'New Menu', version: '1.0.0'),
        );

        expect(states.any((s) => s.isLoading), isTrue);
        expect(readState().isLoading, isFalse);
      });

      test('should prepend new menu at first position in list', () async {
        fakeMenuRepo.whenListAll(success([menu1]));
        await readNotifier().loadMenus(onlyPublished: true);

        fakeMenuRepo.whenCreate(success(newMenu));
        await readNotifier().createMenu(
          const CreateMenuInput(name: 'New Menu', version: '1.0.0'),
        );

        expect(readState().menus.first.id, 10);
        expect(readState().menus[1].id, 1);
      });
    });

    group('duplicateMenu', () {
      const duplicatedMenu = Menu(
        id: 20,
        name: 'Summer Menu (copy)',
        status: Status.draft,
        version: '1.0.0',
      );

      test('should prepend duplicated menu and return it on success', () async {
        fakeMenuRepo.whenListAll(success([menu1]));
        await readNotifier().loadMenus(onlyPublished: true);

        fakeDuplicate.whenDuplicate(success(duplicatedMenu));
        final result = await readNotifier().duplicateMenu(1);

        expect(result, duplicatedMenu);
        expect(readState().menus.first, duplicatedMenu);
        expect(readState().menus, hasLength(2));
      });

      test('should return null and set error on duplicate failure', () async {
        fakeDuplicate.whenDuplicate(failureServer<Menu>('Duplicate failed'));

        final result = await readNotifier().duplicateMenu(1);

        expect(result, isNull);
        expect(readState().errorMessage, 'Duplicate failed');
        expect(readState().isLoading, isFalse);
      });

      test('should call duplicate use case with the correct menu id', () async {
        fakeDuplicate.whenDuplicate(success(duplicatedMenu));
        await readNotifier().duplicateMenu(42);

        expect(fakeDuplicate.executeCalls, contains(42));
      });
    });

    group('area filtering', () {
      final menusWithAreas = [
        const Menu(
          id: 1,
          name: 'Dining Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 1, name: 'Dining'),
        ),
        const Menu(
          id: 2,
          name: 'Bar Menu',
          status: Status.published,
          version: '1.0.0',
          area: Area(id: 2, name: 'Bar'),
        ),
      ];

      test('should pass multiple areaIds for server-side filtering', () async {
        fakeMenuRepo.whenListAll(success(menusWithAreas));

        await readNotifier().loadMenus(onlyPublished: true, areaIds: [1, 2]);

        final call = fakeMenuRepo.listAllCalls.first;
        expect(call.areaIds, [1, 2]);
        expect(readState().menus, hasLength(2));
      });
    });
  });
}
