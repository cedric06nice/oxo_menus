import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/area_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_notifier.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_provider.dart';
import 'package:oxo_menus/presentation/providers/menu_settings/menu_settings_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockSizeRepository extends Mock implements SizeRepository {}

class MockAreaRepository extends Mock implements AreaRepository {}

void main() {
  late ProviderContainer container;
  late MockMenuRepository mockMenuRepository;
  late MockSizeRepository mockSizeRepository;
  late MockAreaRepository mockAreaRepository;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockSizeRepository = MockSizeRepository();
    mockAreaRepository = MockAreaRepository();
    container = ProviderContainer(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
        areaRepositoryProvider.overrideWithValue(mockAreaRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  setUpAll(() {
    registerFallbackValue(const UpdateMenuInput(id: 0));
    registerFallbackValue(const CreateMenuInput(name: '', version: ''));
  });

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

  MenuSettingsNotifier readNotifier() =>
      container.read(menuSettingsProvider.notifier);
  MenuSettingsState readState() => container.read(menuSettingsProvider);

  group('MenuSettingsNotifier', () {
    test('should have correct initial state', () {
      expect(readState(), const MenuSettingsState());
      expect(readState().sizes, isEmpty);
      expect(readState().areas, isEmpty);
      expect(readState().isLoading, false);
      expect(readState().errorMessage, isNull);
    });

    group('loadSizes', () {
      test('should load sizes successfully', () async {
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) async => const Success([testSize, testSize2]));

        await readNotifier().loadSizes();

        expect(readState().sizes, [testSize, testSize2]);
        expect(readState().isLoading, false);
        expect(readState().errorMessage, isNull);
      });

      test('should set error message on failure', () async {
        when(() => mockSizeRepository.getAll()).thenAnswer(
          (_) async => const Failure(ServerError('Failed to load sizes')),
        );

        await readNotifier().loadSizes();

        expect(readState().sizes, isEmpty);
        expect(readState().isLoading, false);
        expect(readState().errorMessage, isNotNull);
      });

      test('should set isLoading while loading', () async {
        when(
          () => mockSizeRepository.getAll(),
        ).thenAnswer((_) async => const Success([testSize]));

        final future = readNotifier().loadSizes();

        expect(readState().isLoading, true);

        await future;

        expect(readState().isLoading, false);
      });
    });

    group('loadAreas', () {
      test('should load areas successfully', () async {
        when(
          () => mockAreaRepository.getAll(),
        ).thenAnswer((_) async => const Success([testArea, testArea2]));

        await readNotifier().loadAreas();

        expect(readState().areas, [testArea, testArea2]);
        expect(readState().isLoading, false);
        expect(readState().errorMessage, isNull);
      });

      test('should set error message on failure', () async {
        when(() => mockAreaRepository.getAll()).thenAnswer(
          (_) async => const Failure(ServerError('Failed to load areas')),
        );

        await readNotifier().loadAreas();

        expect(readState().areas, isEmpty);
        expect(readState().isLoading, false);
        expect(readState().errorMessage, isNotNull);
      });

      test('should set isLoading while loading', () async {
        when(
          () => mockAreaRepository.getAll(),
        ).thenAnswer((_) async => const Success([testArea]));

        final future = readNotifier().loadAreas();

        expect(readState().isLoading, true);

        await future;

        expect(readState().isLoading, false);
      });
    });

    group('updateDisplayOptions', () {
      test('should update display options successfully', () async {
        when(() => mockMenuRepository.update(any())).thenAnswer(
          (_) async =>
              Success(testMenu.copyWith(displayOptions: testDisplayOptions)),
        );

        final result = await readNotifier().updateDisplayOptions(
          1,
          testDisplayOptions,
        );

        expect(result.isSuccess, true);
        verify(
          () => mockMenuRepository.update(
            const UpdateMenuInput(id: 1, displayOptions: testDisplayOptions),
          ),
        ).called(1);
      });

      test('should return failure when update fails', () async {
        when(
          () => mockMenuRepository.update(any()),
        ).thenAnswer((_) async => const Failure(ServerError('Update failed')));

        final result = await readNotifier().updateDisplayOptions(
          1,
          testDisplayOptions,
        );

        expect(result.isFailure, true);
      });
    });

    group('updatePageSize', () {
      test('should update page size successfully', () async {
        when(() => mockMenuRepository.update(any())).thenAnswer(
          (_) async => Success(
            testMenu.copyWith(
              pageSize: PageSize(
                name: testSize.name,
                width: testSize.width,
                height: testSize.height,
              ),
            ),
          ),
        );

        final result = await readNotifier().updatePageSize(1, testSize.id);

        expect(result.isSuccess, true);
        verify(
          () => mockMenuRepository.update(
            const UpdateMenuInput(id: 1, sizeId: 1),
          ),
        ).called(1);
      });

      test('should return failure when update fails', () async {
        when(
          () => mockMenuRepository.update(any()),
        ).thenAnswer((_) async => const Failure(ServerError('Update failed')));

        final result = await readNotifier().updatePageSize(1, testSize.id);

        expect(result.isFailure, true);
      });
    });

    group('updateArea', () {
      test('should update area successfully', () async {
        when(
          () => mockMenuRepository.update(any()),
        ).thenAnswer((_) async => Success(testMenu.copyWith(area: testArea)));

        final result = await readNotifier().updateArea(1, testArea.id);

        expect(result.isSuccess, true);
        verify(
          () => mockMenuRepository.update(
            const UpdateMenuInput(id: 1, areaId: 1),
          ),
        ).called(1);
      });

      test('should clear area when areaId is null', () async {
        when(
          () => mockMenuRepository.update(any()),
        ).thenAnswer((_) async => const Success(testMenu));

        final result = await readNotifier().updateArea(1, null);

        expect(result.isSuccess, true);
        verify(
          () => mockMenuRepository.update(
            const UpdateMenuInput(id: 1, areaId: null),
          ),
        ).called(1);
      });

      test('should return failure when update fails', () async {
        when(
          () => mockMenuRepository.update(any()),
        ).thenAnswer((_) async => const Failure(ServerError('Update failed')));

        final result = await readNotifier().updateArea(1, testArea.id);

        expect(result.isFailure, true);
      });
    });

    group('saveMenu', () {
      test('should save menu successfully', () async {
        when(
          () => mockMenuRepository.update(any()),
        ).thenAnswer((_) async => const Success(testMenu));

        final result = await readNotifier().saveMenu(1);

        expect(result.isSuccess, true);
        verify(
          () => mockMenuRepository.update(const UpdateMenuInput(id: 1)),
        ).called(1);
      });

      test('should return failure when save fails', () async {
        when(
          () => mockMenuRepository.update(any()),
        ).thenAnswer((_) async => const Failure(ServerError('Save failed')));

        final result = await readNotifier().saveMenu(1);

        expect(result.isFailure, true);
      });
    });

    group('createTemplate', () {
      test('should create template successfully', () async {
        when(
          () => mockMenuRepository.create(any()),
        ).thenAnswer((_) async => const Success(testMenu));

        final result = await readNotifier().createTemplate(
          name: 'New Template',
          version: '1.0.0',
          status: Status.draft,
          sizeId: testSize.id,
          areaId: testArea.id,
        );

        expect(result.isSuccess, true);
        verify(
          () => mockMenuRepository.create(
            const CreateMenuInput(
              name: 'New Template',
              version: '1.0.0',
              status: Status.draft,
              sizeId: 1,
              areaId: 1,
            ),
          ),
        ).called(1);
      });

      test('should create template without area', () async {
        when(
          () => mockMenuRepository.create(any()),
        ).thenAnswer((_) async => const Success(testMenu));

        final result = await readNotifier().createTemplate(
          name: 'New Template',
          version: '1.0.0',
          status: Status.draft,
          sizeId: testSize.id,
        );

        expect(result.isSuccess, true);
        verify(
          () => mockMenuRepository.create(
            const CreateMenuInput(
              name: 'New Template',
              version: '1.0.0',
              status: Status.draft,
              sizeId: 1,
            ),
          ),
        ).called(1);
      });

      test('should return failure when creation fails', () async {
        when(() => mockMenuRepository.create(any())).thenAnswer(
          (_) async => const Failure(ServerError('Creation failed')),
        );

        final result = await readNotifier().createTemplate(
          name: 'New Template',
          version: '1.0.0',
          status: Status.draft,
          sizeId: testSize.id,
        );

        expect(result.isFailure, true);
      });
    });
  });
}
