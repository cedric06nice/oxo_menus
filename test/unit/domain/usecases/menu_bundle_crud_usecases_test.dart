import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/usecases/create_menu_bundle_usecase.dart';
import 'package:oxo_menus/domain/usecases/delete_menu_bundle_usecase.dart';
import 'package:oxo_menus/domain/usecases/get_menu_bundle_usecase.dart';
import 'package:oxo_menus/domain/usecases/list_menu_bundles_usecase.dart';
import 'package:oxo_menus/domain/usecases/update_menu_bundle_usecase.dart';

class MockMenuBundleRepository extends Mock implements MenuBundleRepository {}

void main() {
  late MockMenuBundleRepository repo;

  setUpAll(() {
    registerFallbackValue(const CreateMenuBundleInput(name: ''));
    registerFallbackValue(const UpdateMenuBundleInput(id: 0));
  });

  setUp(() {
    repo = MockMenuBundleRepository();
  });

  const bundle = MenuBundle(
    id: 1,
    name: 'SampleRestaurantMenu',
    menuIds: [10, 20],
  );

  group('ListMenuBundlesUseCase', () {
    test('delegates to repository.getAll', () async {
      when(() => repo.getAll()).thenAnswer(
        (_) async => const Success<List<MenuBundle>, DomainError>([bundle]),
      );

      final result = await ListMenuBundlesUseCase(repository: repo).execute();

      expect(result.isSuccess, true);
      expect(result.valueOrNull, [bundle]);
      verify(() => repo.getAll()).called(1);
    });

    test('propagates failures', () async {
      when(() => repo.getAll()).thenAnswer(
        (_) async =>
            const Failure<List<MenuBundle>, DomainError>(ServerError('boom')),
      );

      final result = await ListMenuBundlesUseCase(repository: repo).execute();

      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<ServerError>());
    });
  });

  group('GetMenuBundleUseCase', () {
    test('delegates to repository.getById', () async {
      when(
        () => repo.getById(1),
      ).thenAnswer((_) async => const Success<MenuBundle, DomainError>(bundle));

      final result = await GetMenuBundleUseCase(repository: repo).execute(1);

      expect(result.valueOrNull, bundle);
      verify(() => repo.getById(1)).called(1);
    });
  });

  group('CreateMenuBundleUseCase', () {
    test('delegates to repository.create', () async {
      const input = CreateMenuBundleInput(name: 'X', menuIds: [1]);
      when(
        () => repo.create(input),
      ).thenAnswer((_) async => const Success<MenuBundle, DomainError>(bundle));

      final result = await CreateMenuBundleUseCase(
        repository: repo,
      ).execute(input);

      expect(result.valueOrNull, bundle);
      verify(() => repo.create(input)).called(1);
    });

    test('rejects empty bundle name with ValidationError', () async {
      const input = CreateMenuBundleInput(name: '   ', menuIds: [1]);

      final result = await CreateMenuBundleUseCase(
        repository: repo,
      ).execute(input);

      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<ValidationError>());
      verifyNever(() => repo.create(any()));
    });
  });

  group('UpdateMenuBundleUseCase', () {
    test('delegates to repository.update', () async {
      const input = UpdateMenuBundleInput(id: 1, name: 'New');
      when(
        () => repo.update(input),
      ).thenAnswer((_) async => const Success<MenuBundle, DomainError>(bundle));

      final result = await UpdateMenuBundleUseCase(
        repository: repo,
      ).execute(input);

      expect(result.valueOrNull, bundle);
      verify(() => repo.update(input)).called(1);
    });
  });

  group('DeleteMenuBundleUseCase', () {
    test('delegates to repository.delete', () async {
      when(
        () => repo.delete(1),
      ).thenAnswer((_) async => const Success<void, DomainError>(null));

      final result = await DeleteMenuBundleUseCase(repository: repo).execute(1);

      expect(result.isSuccess, true);
      verify(() => repo.delete(1)).called(1);
    });
  });
}
