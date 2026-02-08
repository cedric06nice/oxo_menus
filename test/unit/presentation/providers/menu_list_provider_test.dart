import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/providers/menu_list_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MenuListNotifier menuListNotifier;

  setUpAll(() {
    registerFallbackValue(const CreateMenuInput(
      name: 'fallback',
      version: '1.0.0',
    ));
  });

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    menuListNotifier = MenuListNotifier(mockMenuRepository);
  });

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
      expect(menuListNotifier.state.menus, isEmpty);
      expect(menuListNotifier.state.isLoading, false);
      expect(menuListNotifier.state.errorMessage, null);
    });

    group('loadMenus', () {
      test('should load menus successfully', () async {
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => Success(testMenus));

        await menuListNotifier.loadMenus(onlyPublished: true);

        expect(menuListNotifier.state.menus, testMenus);
        expect(menuListNotifier.state.isLoading, false);
        expect(menuListNotifier.state.errorMessage, null);
        verify(() => mockMenuRepository.listAll(onlyPublished: true)).called(1);
      });

      test('should load all menus when onlyPublished is false', () async {
        when(() => mockMenuRepository.listAll(onlyPublished: false))
            .thenAnswer((_) async => Success(testMenus));

        await menuListNotifier.loadMenus(onlyPublished: false);

        expect(menuListNotifier.state.menus, testMenus);
        expect(menuListNotifier.state.isLoading, false);
        verify(() => mockMenuRepository.listAll(onlyPublished: false))
            .called(1);
      });

      test('should set loading state during load', () async {
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Success(testMenus);
        });

        final states = <MenuListState>[];
        menuListNotifier.addListener((state) => states.add(state));

        final future = menuListNotifier.loadMenus(onlyPublished: true);

        // Check that loading state was set
        await Future.delayed(const Duration(milliseconds: 50));
        expect(menuListNotifier.state.isLoading, true);

        await future;

        expect(states.any((s) => s.isLoading), true);
        expect(menuListNotifier.state.isLoading, false);
      });

      test('should handle errors when loading fails', () async {
        const error = NetworkError('Failed to fetch menus');
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => const Failure(error));

        await menuListNotifier.loadMenus(onlyPublished: true);

        expect(menuListNotifier.state.menus, isEmpty);
        expect(menuListNotifier.state.isLoading, false);
        expect(menuListNotifier.state.errorMessage, 'Failed to fetch menus');
        verify(() => mockMenuRepository.listAll(onlyPublished: true)).called(1);
      });

      test('should clear error message when loading succeeds', () async {
        // First fail
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => const Failure(NetworkError('Error')));
        await menuListNotifier.loadMenus(onlyPublished: true);
        expect(menuListNotifier.state.errorMessage, 'Error');

        // Then succeed
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => Success(testMenus));
        await menuListNotifier.loadMenus(onlyPublished: true);

        expect(menuListNotifier.state.errorMessage, null);
        expect(menuListNotifier.state.menus, testMenus);
      });
    });

    group('deleteMenu', () {
      test('should delete menu successfully', () async {
        // First load some menus
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => Success(testMenus));
        await menuListNotifier.loadMenus(onlyPublished: true);

        expect(menuListNotifier.state.menus.length, 3);

        // Then delete one
        when(() => mockMenuRepository.delete(1))
            .thenAnswer((_) async => const Success(null));

        await menuListNotifier.deleteMenu(1);

        expect(menuListNotifier.state.menus.length, 2);
        expect(menuListNotifier.state.menus.any((m) => m.id == 1), false);
        expect(menuListNotifier.state.errorMessage, null);
        verify(() => mockMenuRepository.delete(1)).called(1);
      });

      test('should handle delete errors', () async {
        // First load some menus
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => Success(testMenus));
        await menuListNotifier.loadMenus(onlyPublished: true);

        // Then fail to delete
        const error = ServerError('Failed to delete menu');
        when(() => mockMenuRepository.delete(1))
            .thenAnswer((_) async => const Failure(error));

        await menuListNotifier.deleteMenu(1);

        // Menu should still be in the list
        expect(menuListNotifier.state.menus.length, 3);
        expect(menuListNotifier.state.menus.any((m) => m.id == 1), true);
        expect(menuListNotifier.state.errorMessage, 'Failed to delete menu');
        verify(() => mockMenuRepository.delete(1)).called(1);
      });

      test('should handle deleting non-existent menu', () async {
        // Load menus
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => Success(testMenus));
        await menuListNotifier.loadMenus(onlyPublished: true);

        // Delete a menu that doesn't exist in local state
        when(() => mockMenuRepository.delete(999))
            .thenAnswer((_) async => const Success(null));

        await menuListNotifier.deleteMenu(999);

        // State should be unchanged
        expect(menuListNotifier.state.menus.length, 3);
        expect(menuListNotifier.state.errorMessage, null);
      });
    });

    group('refresh', () {
      test('should reload menus', () async {
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => Success(testMenus));

        await menuListNotifier.refresh(onlyPublished: true);

        expect(menuListNotifier.state.menus, testMenus);
        expect(menuListNotifier.state.isLoading, false);
        verify(() => mockMenuRepository.listAll(onlyPublished: true)).called(1);
      });

      test('should pass onlyPublished parameter', () async {
        when(() => mockMenuRepository.listAll(onlyPublished: false))
            .thenAnswer((_) async => Success(testMenus));

        await menuListNotifier.refresh(onlyPublished: false);

        verify(() => mockMenuRepository.listAll(onlyPublished: false))
            .called(1);
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Set an error
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => const Failure(NetworkError('Error')));
        await menuListNotifier.loadMenus(onlyPublished: true);

        expect(menuListNotifier.state.errorMessage, 'Error');

        // Clear the error
        menuListNotifier.clearError();

        expect(menuListNotifier.state.errorMessage, null);
      });

      test('should not affect other state properties', () async {
        // Load menus
        when(() => mockMenuRepository.listAll(onlyPublished: true))
            .thenAnswer((_) async => Success(testMenus));
        await menuListNotifier.loadMenus(onlyPublished: true);

        // Set an error
        when(() => mockMenuRepository.delete(1))
            .thenAnswer((_) async => const Failure(ServerError('Error')));
        await menuListNotifier.deleteMenu(1);

        expect(menuListNotifier.state.errorMessage, 'Error');
        final menusBefore = menuListNotifier.state.menus;

        // Clear error
        menuListNotifier.clearError();

        expect(menuListNotifier.state.errorMessage, null);
        expect(menuListNotifier.state.menus, menusBefore);
        expect(menuListNotifier.state.isLoading, false);
      });
    });
  });

  group('createMenu', () {
    const createInput = CreateMenuInput(
      name: 'New Menu',
      version: '1.0.0',
    );

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

    test('should return created menu and prepend to list on success',
        () async {
      // Load existing menus first
      when(() => mockMenuRepository.listAll(onlyPublished: true))
          .thenAnswer((_) async => Success(existingMenus));
      await menuListNotifier.loadMenus(onlyPublished: true);

      when(() => mockMenuRepository.create(any()))
          .thenAnswer((_) async => const Success(createdMenu));

      final result = await menuListNotifier.createMenu(createInput);

      expect(result, createdMenu);
      expect(menuListNotifier.state.menus.length, 2);
      expect(menuListNotifier.state.menus.first, createdMenu);
      expect(menuListNotifier.state.isLoading, false);
      expect(menuListNotifier.state.errorMessage, isNull);
    });

    test('should return null and set error on failure', () async {
      const error = ValidationError('Name is required');
      when(() => mockMenuRepository.create(any()))
          .thenAnswer((_) async => const Failure(error));

      final result = await menuListNotifier.createMenu(createInput);

      expect(result, isNull);
      expect(menuListNotifier.state.isLoading, false);
      expect(menuListNotifier.state.errorMessage, 'Name is required');
    });

    test('should set loading state during creation', () async {
      when(() => mockMenuRepository.create(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return const Success(createdMenu);
      });

      final states = <MenuListState>[];
      menuListNotifier.addListener((state) => states.add(state));

      final future = menuListNotifier.createMenu(createInput);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(menuListNotifier.state.isLoading, true);

      await future;
      expect(states.any((s) => s.isLoading), true);
      expect(menuListNotifier.state.isLoading, false);
    });

    test('should prepend new menu at first position', () async {
      // Load existing menus
      when(() => mockMenuRepository.listAll(onlyPublished: true))
          .thenAnswer((_) async => Success(existingMenus));
      await menuListNotifier.loadMenus(onlyPublished: true);

      when(() => mockMenuRepository.create(any()))
          .thenAnswer((_) async => const Success(createdMenu));

      await menuListNotifier.createMenu(createInput);

      expect(menuListNotifier.state.menus[0].id, 10);
      expect(menuListNotifier.state.menus[1].id, 1);
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
