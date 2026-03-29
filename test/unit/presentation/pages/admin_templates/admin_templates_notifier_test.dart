import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/usecases/list_templates_usecase.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockListTemplatesUseCase extends Mock implements ListTemplatesUseCase {}

void main() {
  late ProviderContainer container;
  late MockMenuRepository mockMenuRepository;
  late MockListTemplatesUseCase mockListTemplatesUseCase;

  final allMenus = [
    const Menu(
      id: 1,
      name: 'Template 1',
      status: Status.draft,
      version: '1.0.0',
    ),
    const Menu(
      id: 2,
      name: 'Template 2',
      status: Status.published,
      version: '1.0.0',
    ),
    const Menu(
      id: 3,
      name: 'Template 3',
      status: Status.archived,
      version: '1.0.0',
    ),
    const Menu(
      id: 4,
      name: 'Dining Menu',
      status: Status.published,
      version: '1.0.0',
      area: Area(id: 1, name: 'Dining'),
    ),
  ];

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    mockListTemplatesUseCase = MockListTemplatesUseCase();
    container = ProviderContainer(
      overrides: [
        menuRepositoryProvider.overrideWithValue(mockMenuRepository),
        listTemplatesUseCaseProvider.overrideWithValue(
          mockListTemplatesUseCase,
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  AdminTemplatesNotifier readNotifier() =>
      container.read(adminTemplatesProvider.notifier);
  AdminTemplatesState readState() => container.read(adminTemplatesProvider);

  group('AdminTemplatesNotifier', () {
    test('initial state should be default', () {
      expect(readState(), const AdminTemplatesState());
      expect(readState().templates, isEmpty);
      expect(readState().isLoading, false);
      expect(readState().errorMessage, isNull);
      expect(readState().statusFilter, 'all');
    });

    group('loadTemplates', () {
      test('should load all menus including those with areas', () async {
        when(
          () => mockListTemplatesUseCase.execute(statusFilter: 'all'),
        ).thenAnswer((_) async => Success(allMenus));

        await readNotifier().loadTemplates();

        expect(readState().isLoading, false);
        expect(readState().templates, hasLength(4));
        expect(readState().errorMessage, isNull);
      });

      test('should apply status filter when loading', () async {
        when(
          () => mockListTemplatesUseCase.execute(statusFilter: 'draft'),
        ).thenAnswer(
          (_) async => const Success([
            Menu(
              id: 1,
              name: 'Template 1',
              status: Status.draft,
              version: '1.0.0',
            ),
          ]),
        );

        await readNotifier().loadTemplates(statusFilter: 'draft');

        expect(readState().templates, hasLength(1));
        expect(readState().templates.first.status, Status.draft);
        expect(readState().statusFilter, 'draft');
      });

      test('should return all menus when filter is "all"', () async {
        when(
          () => mockListTemplatesUseCase.execute(statusFilter: 'all'),
        ).thenAnswer((_) async => Success(allMenus));

        await readNotifier().loadTemplates(statusFilter: 'all');

        expect(readState().templates, hasLength(4));
      });

      test('should set error message on failure', () async {
        when(
          () => mockListTemplatesUseCase.execute(statusFilter: 'all'),
        ).thenAnswer(
          (_) async => const Failure(ServerError('Failed to fetch templates')),
        );

        await readNotifier().loadTemplates();

        expect(readState().isLoading, false);
        expect(readState().errorMessage, 'Failed to fetch templates');
        expect(readState().templates, isEmpty);
      });

      test(
        'should preserve existing status filter when not specified',
        () async {
          when(
            () => mockListTemplatesUseCase.execute(statusFilter: 'published'),
          ).thenAnswer(
            (_) async => const Success([
              Menu(
                id: 2,
                name: 'Template 2',
                status: Status.published,
                version: '1.0.0',
              ),
              Menu(
                id: 4,
                name: 'Dining Menu',
                status: Status.published,
                version: '1.0.0',
                area: Area(id: 1, name: 'Dining'),
              ),
            ]),
          );

          // Set a filter first
          await readNotifier().loadTemplates(statusFilter: 'published');
          expect(readState().statusFilter, 'published');

          // Reload without specifying filter
          await readNotifier().loadTemplates();
          expect(readState().statusFilter, 'published');
        },
      );
    });

    group('deleteTemplate', () {
      test('should remove template from state on success', () async {
        // First load templates
        when(
          () => mockListTemplatesUseCase.execute(statusFilter: 'all'),
        ).thenAnswer((_) async => Success(allMenus));
        await readNotifier().loadTemplates();
        expect(readState().templates, hasLength(4));

        // Delete template
        when(
          () => mockMenuRepository.delete(1),
        ).thenAnswer((_) async => const Success(null));

        await readNotifier().deleteTemplate(1);

        expect(readState().templates, hasLength(3));
        expect(readState().templates.any((t) => t.id == 1), false);
      });

      test('should set error message on delete failure', () async {
        when(
          () => mockMenuRepository.delete(1),
        ).thenAnswer((_) async => const Failure(ServerError('Delete failed')));

        await readNotifier().deleteTemplate(1);

        expect(readState().errorMessage, 'Delete failed');
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Trigger an error
        when(
          () => mockListTemplatesUseCase.execute(statusFilter: 'all'),
        ).thenAnswer((_) async => const Failure(ServerError('Some error')));
        await readNotifier().loadTemplates();
        expect(readState().errorMessage, isNotNull);

        // Clear it
        readNotifier().clearError();

        expect(readState().errorMessage, isNull);
      });
    });
  });
}
