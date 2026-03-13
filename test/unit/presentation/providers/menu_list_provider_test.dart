import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/presentation/providers/menu_list_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockDuplicateMenuUseCase extends Mock implements DuplicateMenuUseCase {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MockDuplicateMenuUseCase mockDuplicateMenuUseCase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const CreateMenuInput(name: 'fallback', version: '1.0.0'),
    );
  });

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockDuplicateMenuUseCase = MockDuplicateMenuUseCase();
    container = ProviderContainer(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        duplicateMenuUseCaseProvider.overrideWithValue(
          mockDuplicateMenuUseCase,
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  MenuListNotifier readNotifier() => container.read(menuListProvider.notifier);
  MenuListState readState() => container.read(menuListProvider);

  group('MenuListNotifier', () {
    final testMenus = [
      const Menu(
        id: 1,
        name: 'Test Menu 1',
        status: Status.published,
        version: '1.0.0',
      ),
      const Menu(
        id: 2,
        name: 'Test Menu 2',
        status: Status.published,
        version: '1.0.0',
      ),
      const Menu(
        id: 3,
        name: 'Draft Menu',
        status: Status.draft,
        version: '1.0.0',
      ),
    ];

    test('should start with empty state', () {
      expect(readState().menus, isEmpty);
      expect(readState().isLoading, false);
      expect(readState().errorMessage, null);
    });

    group('loadMenus', () {
      test('should load menus successfully', () async {
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => Success(testMenus));

        await readNotifier().loadMenus(onlyPublished: true);

        expect(readState().menus, testMenus);
        expect(readState().isLoading, false);
        expect(readState().errorMessage, null);
        verify(() => mockMenuRepository.listAll(onlyPublished: true)).called(1);
      });

      test('should load all menus when onlyPublished is false', () async {
        when(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).thenAnswer((_) async => Success(testMenus));

        await readNotifier().loadMenus(onlyPublished: false);

        expect(readState().menus, testMenus);
        expect(readState().isLoading, false);
        verify(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).called(1);
      });

      test('should set loading state during load', () async {
        when(() => mockMenuRepository.listAll(onlyPublished: true)).thenAnswer((
          _,
        ) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Success(testMenus);
        });

        final states = <MenuListState>[];
        container.listen<MenuListState>(
          menuListProvider,
          (_, next) => states.add(next),
        );

        final future = readNotifier().loadMenus(onlyPublished: true);

        // Check that loading state was set
        await Future.delayed(const Duration(milliseconds: 50));
        expect(readState().isLoading, true);

        await future;

        expect(states.any((s) => s.isLoading), true);
        expect(readState().isLoading, false);
      });

      test('should handle errors when loading fails', () async {
        const error = NetworkError('Failed to fetch menus');
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => const Failure(error));

        await readNotifier().loadMenus(onlyPublished: true);

        expect(readState().menus, isEmpty);
        expect(readState().isLoading, false);
        expect(readState().errorMessage, 'Failed to fetch menus');
        verify(() => mockMenuRepository.listAll(onlyPublished: true)).called(1);
      });

      test('should clear error message when loading succeeds', () async {
        // First fail
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => const Failure(NetworkError('Error')));
        await readNotifier().loadMenus(onlyPublished: true);
        expect(readState().errorMessage, 'Error');

        // Then succeed
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => Success(testMenus));
        await readNotifier().loadMenus(onlyPublished: true);

        expect(readState().errorMessage, null);
        expect(readState().menus, testMenus);
      });
    });

    group('deleteMenu', () {
      test('should delete menu successfully', () async {
        // First load some menus
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => Success(testMenus));
        await readNotifier().loadMenus(onlyPublished: true);

        expect(readState().menus.length, 3);

        // Then delete one
        when(
          () => mockMenuRepository.delete(1),
        ).thenAnswer((_) async => const Success(null));

        await readNotifier().deleteMenu(1);

        expect(readState().menus.length, 2);
        expect(readState().menus.any((m) => m.id == 1), false);
        expect(readState().errorMessage, null);
        verify(() => mockMenuRepository.delete(1)).called(1);
      });

      test('should handle delete errors', () async {
        // First load some menus
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => Success(testMenus));
        await readNotifier().loadMenus(onlyPublished: true);

        // Then fail to delete
        const error = ServerError('Failed to delete menu');
        when(
          () => mockMenuRepository.delete(1),
        ).thenAnswer((_) async => const Failure(error));

        await readNotifier().deleteMenu(1);

        // Menu should still be in the list
        expect(readState().menus.length, 3);
        expect(readState().menus.any((m) => m.id == 1), true);
        expect(readState().errorMessage, 'Failed to delete menu');
        verify(() => mockMenuRepository.delete(1)).called(1);
      });

      test('should handle deleting non-existent menu', () async {
        // Load menus
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => Success(testMenus));
        await readNotifier().loadMenus(onlyPublished: true);

        // Delete a menu that doesn't exist in local state
        when(
          () => mockMenuRepository.delete(999),
        ).thenAnswer((_) async => const Success(null));

        await readNotifier().deleteMenu(999);

        // State should be unchanged
        expect(readState().menus.length, 3);
        expect(readState().errorMessage, null);
      });
    });

    group('refresh', () {
      test('should reload menus', () async {
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => Success(testMenus));

        await readNotifier().refresh(onlyPublished: true);

        expect(readState().menus, testMenus);
        expect(readState().isLoading, false);
        verify(() => mockMenuRepository.listAll(onlyPublished: true)).called(1);
      });

      test('should pass onlyPublished parameter', () async {
        when(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).thenAnswer((_) async => Success(testMenus));

        await readNotifier().refresh(onlyPublished: false);

        verify(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).called(1);
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Set an error
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => const Failure(NetworkError('Error')));
        await readNotifier().loadMenus(onlyPublished: true);

        expect(readState().errorMessage, 'Error');

        // Clear the error
        readNotifier().clearError();

        expect(readState().errorMessage, null);
      });

      test('should not affect other state properties', () async {
        // Load menus
        when(
          () => mockMenuRepository.listAll(onlyPublished: true),
        ).thenAnswer((_) async => Success(testMenus));
        await readNotifier().loadMenus(onlyPublished: true);

        // Set an error
        when(
          () => mockMenuRepository.delete(1),
        ).thenAnswer((_) async => const Failure(ServerError('Error')));
        await readNotifier().deleteMenu(1);

        expect(readState().errorMessage, 'Error');
        final menusBefore = readState().menus;

        // Clear error
        readNotifier().clearError();

        expect(readState().errorMessage, null);
        expect(readState().menus, menusBefore);
        expect(readState().isLoading, false);
      });
    });
  });

  group('createMenu', () {
    const createInput = CreateMenuInput(name: 'New Menu', version: '1.0.0');

    const createdMenu = Menu(
      id: 10,
      name: 'New Menu',
      status: Status.draft,
      version: '1.0.0',
    );

    final existingMenus = [
      const Menu(
        id: 1,
        name: 'Existing Menu',
        status: Status.published,
        version: '1.0.0',
      ),
    ];

    test('should return created menu and prepend to list on success', () async {
      // Load existing menus first
      when(
        () => mockMenuRepository.listAll(onlyPublished: true),
      ).thenAnswer((_) async => Success(existingMenus));
      await readNotifier().loadMenus(onlyPublished: true);

      when(
        () => mockMenuRepository.create(any()),
      ).thenAnswer((_) async => const Success(createdMenu));

      final result = await readNotifier().createMenu(createInput);

      expect(result, createdMenu);
      expect(readState().menus.length, 2);
      expect(readState().menus.first, createdMenu);
      expect(readState().isLoading, false);
      expect(readState().errorMessage, isNull);
    });

    test('should return null and set error on failure', () async {
      const error = ValidationError('Name is required');
      when(
        () => mockMenuRepository.create(any()),
      ).thenAnswer((_) async => const Failure(error));

      final result = await readNotifier().createMenu(createInput);

      expect(result, isNull);
      expect(readState().isLoading, false);
      expect(readState().errorMessage, 'Name is required');
    });

    test('should set loading state during creation', () async {
      when(() => mockMenuRepository.create(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return const Success(createdMenu);
      });

      final states = <MenuListState>[];
      container.listen(menuListProvider, (_, next) => states.add(next));

      final future = readNotifier().createMenu(createInput);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(readState().isLoading, true);

      await future;
      expect(states.any((s) => s.isLoading), true);
      expect(readState().isLoading, false);
    });

    test('should prepend new menu at first position', () async {
      // Load existing menus
      when(
        () => mockMenuRepository.listAll(onlyPublished: true),
      ).thenAnswer((_) async => Success(existingMenus));
      await readNotifier().loadMenus(onlyPublished: true);

      when(
        () => mockMenuRepository.create(any()),
      ).thenAnswer((_) async => const Success(createdMenu));

      await readNotifier().createMenu(createInput);

      expect(readState().menus[0].id, 10);
      expect(readState().menus[1].id, 1);
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

    test('should not pass areaIds when null (admin)', () async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false, areaIds: null),
      ).thenAnswer((_) async => Success(menusWithAreas));

      await readNotifier().loadMenus(onlyPublished: false, areaIds: null);

      expect(readState().menus.length, 2);
      verify(
        () => mockMenuRepository.listAll(onlyPublished: false, areaIds: null),
      ).called(1);
    });

    test(
      'should pass areaIds to repository for server-side filtering',
      () async {
        when(
          () => mockMenuRepository.listAll(onlyPublished: true, areaIds: [1]),
        ).thenAnswer((_) async => Success([menusWithAreas[0]]));

        await readNotifier().loadMenus(onlyPublished: true, areaIds: [1]);

        expect(readState().menus.length, 1);
        expect(readState().menus.first.name, 'Dining Menu');
        verify(
          () => mockMenuRepository.listAll(onlyPublished: true, areaIds: [1]),
        ).called(1);
      },
    );

    test('should forward empty areaIds to repository', () async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: true, areaIds: []),
      ).thenAnswer((_) async => const Success([]));

      await readNotifier().loadMenus(onlyPublished: true, areaIds: []);

      expect(readState().menus, isEmpty);
      verify(
        () => mockMenuRepository.listAll(onlyPublished: true, areaIds: []),
      ).called(1);
    });

    test('should pass areaIds through refresh', () async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: true, areaIds: [1, 2]),
      ).thenAnswer((_) async => Success(menusWithAreas));

      await readNotifier().refresh(onlyPublished: true, areaIds: [1, 2]);

      verify(
        () => mockMenuRepository.listAll(onlyPublished: true, areaIds: [1, 2]),
      ).called(1);
    });
  });

  group('MenuListState', () {
    test('should create state with default values', () {
      const state = MenuListState();

      expect(state.menus, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, null);
    });

    test('should create state with custom values', () {
      final menus = [
        const Menu(
          id: 1,
          name: 'Test',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      final state = MenuListState(
        menus: menus,
        isLoading: true,
        errorMessage: 'Error',
      );

      expect(state.menus, menus);
      expect(state.isLoading, true);
      expect(state.errorMessage, 'Error');
    });

    test('should support copyWith', () {
      const original = MenuListState(
        menus: [],
        isLoading: false,
        errorMessage: null,
      );

      final modified = original.copyWith(
        isLoading: true,
        errorMessage: 'Loading...',
      );

      expect(original.isLoading, false);
      expect(original.errorMessage, null);
      expect(modified.isLoading, true);
      expect(modified.errorMessage, 'Loading...');
    });

    test('should support equality', () {
      final menus = [
        const Menu(
          id: 1,
          name: 'Test',
          status: Status.published,
          version: '1.0.0',
        ),
      ];

      final state1 = MenuListState(
        menus: menus,
        isLoading: false,
        errorMessage: null,
      );

      final state2 = MenuListState(
        menus: menus,
        isLoading: false,
        errorMessage: null,
      );

      final state3 = MenuListState(
        menus: menus,
        isLoading: true,
        errorMessage: null,
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });
}
