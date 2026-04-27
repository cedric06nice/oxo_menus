import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/admin_templates/presentation/admin_templates_notifier.dart';
import 'package:oxo_menus/features/admin_templates/presentation/admin_templates_provider.dart';
import 'package:oxo_menus/features/admin_templates/presentation/admin_templates_state.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/usecases_provider.dart';

import '../../../../fakes/fake_list_templates_usecase.dart';
import '../../../../fakes/fake_menu_repository.dart';

void main() {
  late ProviderContainer container;
  late FakeMenuRepository fakeMenuRepository;
  late FakeListTemplatesUseCase fakeListTemplatesUseCase;

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
    Menu(
      id: 4,
      name: 'Dining Menu',
      status: Status.published,
      version: '1.0.0',
      area: const Area(id: 1, name: 'Dining'),
    ),
  ];

  setUp(() {
    fakeMenuRepository = FakeMenuRepository();
    fakeListTemplatesUseCase = FakeListTemplatesUseCase();
    container = ProviderContainer(
      overrides: [
        menuRepositoryProvider.overrideWithValue(fakeMenuRepository),
        listTemplatesUseCaseProvider.overrideWithValue(
          fakeListTemplatesUseCase,
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  AdminTemplatesNotifier readNotifier() =>
      container.read(adminTemplatesProvider.notifier);
  AdminTemplatesState readState() => container.read(adminTemplatesProvider);

  group('AdminTemplatesNotifier', () {
    group('initial state', () {
      test('should have empty templates', () {
        expect(readState().templates, isEmpty);
      });

      test('should have isLoading false', () {
        expect(readState().isLoading, isFalse);
      });

      test('should have null errorMessage', () {
        expect(readState().errorMessage, isNull);
      });

      test('should have statusFilter set to all', () {
        expect(readState().statusFilter, 'all');
      });
    });

    group('loadTemplates', () {
      test('should load all menus including those with areas', () async {
        fakeListTemplatesUseCase.stubExecute(Success(allMenus));

        await readNotifier().loadTemplates();

        expect(readState().templates, hasLength(4));
        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, isNull);
      });

      test('should apply status filter when loading', () async {
        final draftMenus = [allMenus[0]];
        fakeListTemplatesUseCase.stubExecute(Success(draftMenus));

        await readNotifier().loadTemplates(statusFilter: 'draft');

        expect(readState().templates, hasLength(1));
        expect(readState().templates.first.status, Status.draft);
        expect(readState().statusFilter, 'draft');
      });

      test('should store the status filter in state', () async {
        fakeListTemplatesUseCase.stubExecute(Success(allMenus));

        await readNotifier().loadTemplates(statusFilter: 'all');

        expect(readState().statusFilter, 'all');
      });

      test('should set error message on failure', () async {
        fakeListTemplatesUseCase.stubExecute(
          const Failure(ServerError('Failed to fetch templates')),
        );

        await readNotifier().loadTemplates();

        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, 'Failed to fetch templates');
        expect(readState().templates, isEmpty);
      });

      test(
        'should preserve existing status filter when not specified',
        () async {
          fakeListTemplatesUseCase.stubExecute(
            Success([allMenus[1], allMenus[3]]),
          );
          await readNotifier().loadTemplates(statusFilter: 'published');
          expect(readState().statusFilter, 'published');

          fakeListTemplatesUseCase.stubExecute(
            Success([allMenus[1], allMenus[3]]),
          );
          await readNotifier().loadTemplates();

          expect(readState().statusFilter, 'published');
        },
      );

      test('should set isLoading to false after success', () async {
        fakeListTemplatesUseCase.stubExecute(Success(allMenus));

        await readNotifier().loadTemplates();

        expect(readState().isLoading, isFalse);
      });

      test('should set isLoading to false after failure', () async {
        fakeListTemplatesUseCase.stubExecute(
          const Failure(NetworkError('Offline')),
        );

        await readNotifier().loadTemplates();

        expect(readState().isLoading, isFalse);
      });

      test('should clear previous error on new load attempt', () async {
        fakeListTemplatesUseCase.stubExecute(
          const Failure(ServerError('Error')),
        );
        await readNotifier().loadTemplates();
        expect(readState().errorMessage, isNotNull);

        fakeListTemplatesUseCase.stubExecute(Success(allMenus));
        await readNotifier().loadTemplates();

        expect(readState().errorMessage, isNull);
      });

      test(
        'should record the use-case call with the filter argument',
        () async {
          fakeListTemplatesUseCase.stubExecute(const Success([]));

          await readNotifier().loadTemplates(statusFilter: 'archived');

          expect(fakeListTemplatesUseCase.calls, hasLength(1));
          expect(fakeListTemplatesUseCase.calls.first.statusFilter, 'archived');
        },
      );
    });

    group('deleteTemplate', () {
      test('should remove template from state on success', () async {
        fakeListTemplatesUseCase.stubExecute(Success(allMenus));
        await readNotifier().loadTemplates();
        expect(readState().templates, hasLength(4));

        fakeMenuRepository.whenDelete(const Success(null));
        await readNotifier().deleteTemplate(1);

        expect(readState().templates, hasLength(3));
        expect(readState().templates.any((t) => t.id == 1), isFalse);
      });

      test('should set error message on delete failure', () async {
        fakeMenuRepository.whenDelete(
          const Failure(ServerError('Delete failed')),
        );

        await readNotifier().deleteTemplate(1);

        expect(readState().errorMessage, 'Delete failed');
      });

      test('should record the delete call with the correct id', () async {
        fakeMenuRepository.whenDelete(const Success(null));

        await readNotifier().deleteTemplate(42);

        expect(fakeMenuRepository.deleteCalls, hasLength(1));
        expect(fakeMenuRepository.deleteCalls.first.id, 42);
      });

      test('should not change templates on delete failure', () async {
        fakeListTemplatesUseCase.stubExecute(Success(allMenus));
        await readNotifier().loadTemplates();

        fakeMenuRepository.whenDelete(
          const Failure(ServerError('Server down')),
        );
        await readNotifier().deleteTemplate(1);

        expect(readState().templates, hasLength(4));
      });
    });

    group('clearError', () {
      test('should clear error message when one is set', () async {
        fakeListTemplatesUseCase.stubExecute(
          const Failure(ServerError('Some error')),
        );
        await readNotifier().loadTemplates();
        expect(readState().errorMessage, isNotNull);

        readNotifier().clearError();

        expect(readState().errorMessage, isNull);
      });

      test('should be a no-op when there is no error', () {
        expect(readState().errorMessage, isNull);

        readNotifier().clearError();

        expect(readState().errorMessage, isNull);
      });
    });
  });
}
