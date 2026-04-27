import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_settings/menu_settings_provider.dart';
import 'package:oxo_menus/features/menu/presentation/providers/menu_settings/menu_settings_state.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

import '../../../../../../fakes/fake_area_repository.dart';
import '../../../../../../fakes/fake_menu_repository.dart';
import '../../../../../../fakes/fake_size_repository.dart';
import '../../../../../../fakes/result_helpers.dart';

void main() {
  const testMenu = Menu(
    id: 1,
    name: 'Test Menu',
    status: Status.draft,
    version: '1',
  );
  const testSize = Size(
    id: 1,
    name: 'A4',
    width: 210,
    height: 297,
    status: Status.published,
    direction: 'portrait',
  );
  const testSize2 = Size(
    id: 2,
    name: 'Letter',
    width: 215.9,
    height: 279.4,
    status: Status.published,
    direction: 'landscape',
  );
  const testArea = Area(id: 1, name: 'Main Dining');
  const testArea2 = Area(id: 2, name: 'Bar');
  const testDisplayOptions = MenuDisplayOptions(
    showPrices: false,
    showAllergens: true,
  );

  group('MenuSettingsNotifier', () {
    late FakeMenuRepository fakeMenuRepo;
    late FakeSizeRepository fakeSizeRepo;
    late FakeAreaRepository fakeAreaRepo;
    late ProviderContainer container;

    setUp(() {
      fakeMenuRepo = FakeMenuRepository();
      fakeSizeRepo = FakeSizeRepository();
      fakeAreaRepo = FakeAreaRepository();
      container = ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(fakeMenuRepo),
          sizeRepositoryProvider.overrideWithValue(fakeSizeRepo),
          areaRepositoryProvider.overrideWithValue(fakeAreaRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    MenuSettingsState readState() => container.read(menuSettingsProvider);

    test('should have correct initial state', () {
      expect(readState(), const MenuSettingsState());
      expect(readState().sizes, isEmpty);
      expect(readState().areas, isEmpty);
      expect(readState().isLoading, isFalse);
      expect(readState().errorMessage, isNull);
    });

    group('loadSizes', () {
      test('should load sizes successfully', () async {
        fakeSizeRepo.whenGetAll(success([testSize, testSize2]));
        await container.read(menuSettingsProvider.notifier).loadSizes();
        expect(readState().sizes, [testSize, testSize2]);
        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, isNull);
      });

      test('should set isLoadingSizes true during request', () async {
        fakeSizeRepo.whenGetAll(success([testSize]));
        final future = container
            .read(menuSettingsProvider.notifier)
            .loadSizes();
        expect(readState().isLoadingSizes, isTrue);
        expect(readState().isLoading, isTrue);
        await future;
        expect(readState().isLoadingSizes, isFalse);
      });

      test('should set error message when load sizes fails', () async {
        fakeSizeRepo.whenGetAll(
          failureServer<List<Size>>('Failed to load sizes'),
        );
        await container.read(menuSettingsProvider.notifier).loadSizes();
        expect(readState().sizes, isEmpty);
        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, 'Failed to load sizes');
      });
    });

    group('loadAreas', () {
      test('should load areas successfully', () async {
        fakeAreaRepo.whenGetAll(success([testArea, testArea2]));
        await container.read(menuSettingsProvider.notifier).loadAreas();
        expect(readState().areas, [testArea, testArea2]);
        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, isNull);
      });

      test('should set isLoadingAreas true during request', () async {
        fakeAreaRepo.whenGetAll(success([testArea]));
        final future = container
            .read(menuSettingsProvider.notifier)
            .loadAreas();
        expect(readState().isLoadingAreas, isTrue);
        await future;
        expect(readState().isLoadingAreas, isFalse);
      });

      test('should set error message when load areas fails', () async {
        fakeAreaRepo.whenGetAll(
          failureServer<List<Area>>('Failed to load areas'),
        );
        await container.read(menuSettingsProvider.notifier).loadAreas();
        expect(readState().areas, isEmpty);
        expect(readState().errorMessage, 'Failed to load areas');
      });
    });

    group('updateDisplayOptions', () {
      test('should return success when update succeeds', () async {
        fakeMenuRepo.whenUpdate(
          success(testMenu.copyWith(displayOptions: testDisplayOptions)),
        );
        final result = await container
            .read(menuSettingsProvider.notifier)
            .updateDisplayOptions(1, testDisplayOptions);
        expect(result.isSuccess, isTrue);
      });

      test('should pass correct UpdateMenuInput to repository', () async {
        fakeMenuRepo.whenUpdate(success(testMenu));
        await container
            .read(menuSettingsProvider.notifier)
            .updateDisplayOptions(1, testDisplayOptions);
        expect(fakeMenuRepo.updateCalls.first.input.id, 1);
        expect(
          fakeMenuRepo.updateCalls.first.input.displayOptions,
          testDisplayOptions,
        );
      });

      test('should return failure when update fails', () async {
        fakeMenuRepo.whenUpdate(failureServer<Menu>('Update failed'));
        final result = await container
            .read(menuSettingsProvider.notifier)
            .updateDisplayOptions(1, testDisplayOptions);
        expect(result.isFailure, isTrue);
      });
    });

    group('updatePageSize', () {
      test('should return success when update succeeds', () async {
        fakeMenuRepo.whenUpdate(success(testMenu));
        final result = await container
            .read(menuSettingsProvider.notifier)
            .updatePageSize(1, testSize.id);
        expect(result.isSuccess, isTrue);
      });

      test('should pass sizeId to repository', () async {
        fakeMenuRepo.whenUpdate(success(testMenu));
        await container
            .read(menuSettingsProvider.notifier)
            .updatePageSize(1, 42);
        expect(fakeMenuRepo.updateCalls.first.input.sizeId, 42);
      });

      test('should return failure when update fails', () async {
        fakeMenuRepo.whenUpdate(failureServer<Menu>('Update failed'));
        final result = await container
            .read(menuSettingsProvider.notifier)
            .updatePageSize(1, testSize.id);
        expect(result.isFailure, isTrue);
      });
    });

    group('updateArea', () {
      test('should return success when update succeeds', () async {
        fakeMenuRepo.whenUpdate(success(testMenu.copyWith(area: testArea)));
        final result = await container
            .read(menuSettingsProvider.notifier)
            .updateArea(1, testArea.id);
        expect(result.isSuccess, isTrue);
      });

      test('should pass areaId to repository', () async {
        fakeMenuRepo.whenUpdate(success(testMenu));
        await container.read(menuSettingsProvider.notifier).updateArea(1, 5);
        expect(fakeMenuRepo.updateCalls.first.input.areaId, 5);
      });

      test('should pass null areaId when clearing area', () async {
        fakeMenuRepo.whenUpdate(success(testMenu));
        await container.read(menuSettingsProvider.notifier).updateArea(1, null);
        expect(fakeMenuRepo.updateCalls.first.input.areaId, isNull);
      });

      test('should return failure when update fails', () async {
        fakeMenuRepo.whenUpdate(failureServer<Menu>('Update failed'));
        final result = await container
            .read(menuSettingsProvider.notifier)
            .updateArea(1, testArea.id);
        expect(result.isFailure, isTrue);
      });
    });

    group('saveMenu', () {
      test('should return success when save succeeds', () async {
        fakeMenuRepo.whenUpdate(success(testMenu));
        final result = await container
            .read(menuSettingsProvider.notifier)
            .saveMenu(1);
        expect(result.isSuccess, isTrue);
      });

      test('should pass menu id to repository', () async {
        fakeMenuRepo.whenUpdate(success(testMenu));
        await container.read(menuSettingsProvider.notifier).saveMenu(99);
        expect(fakeMenuRepo.updateCalls.first.input.id, 99);
      });

      test('should return failure when save fails', () async {
        fakeMenuRepo.whenUpdate(failureServer<Menu>('Save failed'));
        final result = await container
            .read(menuSettingsProvider.notifier)
            .saveMenu(1);
        expect(result.isFailure, isTrue);
      });
    });

    group('createTemplate', () {
      test('should return success with created menu', () async {
        fakeMenuRepo.whenCreate(success(testMenu));
        final result = await container
            .read(menuSettingsProvider.notifier)
            .createTemplate(
              name: 'New Template',
              version: '1.0.0',
              status: Status.draft,
              sizeId: testSize.id,
              areaId: testArea.id,
            );
        expect(result.isSuccess, isTrue);
      });

      test('should create template without area when areaId is null', () async {
        fakeMenuRepo.whenCreate(success(testMenu));
        await container
            .read(menuSettingsProvider.notifier)
            .createTemplate(
              name: 'New Template',
              version: '1.0.0',
              status: Status.draft,
              sizeId: testSize.id,
            );
        expect(fakeMenuRepo.createCalls.first.input.areaId, isNull);
      });

      test('should return failure when creation fails', () async {
        fakeMenuRepo.whenCreate(failureServer<Menu>('Creation failed'));
        final result = await container
            .read(menuSettingsProvider.notifier)
            .createTemplate(
              name: 'New Template',
              version: '1.0.0',
              status: Status.draft,
              sizeId: testSize.id,
            );
        expect(result.isFailure, isTrue);
      });

      test('should pass all fields to repository', () async {
        fakeMenuRepo.whenCreate(success(testMenu));
        await container
            .read(menuSettingsProvider.notifier)
            .createTemplate(
              name: 'Template A',
              version: '2.0.0',
              status: Status.published,
              sizeId: 5,
              areaId: 3,
            );
        final call = fakeMenuRepo.createCalls.first.input;
        expect(call.name, 'Template A');
        expect(call.version, '2.0.0');
        expect(call.status, Status.published);
        expect(call.sizeId, 5);
        expect(call.areaId, 3);
      });
    });
  });
}
