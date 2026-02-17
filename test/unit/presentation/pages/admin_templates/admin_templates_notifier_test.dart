import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_state.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late AdminTemplatesNotifier notifier;
  late MockMenuRepository mockMenuRepository;

  final templateMenus = [
    const Menu(
      id: 1,
      name: 'Template 1',
      status: Status.draft,
      version: '1.0.0',
      area: null,
    ),
    const Menu(
      id: 2,
      name: 'Template 2',
      status: Status.published,
      version: '1.0.0',
      area: null,
    ),
    const Menu(
      id: 3,
      name: 'Template 3',
      status: Status.archived,
      version: '1.0.0',
      area: null,
    ),
  ];

  final mixedMenus = [
    ...templateMenus,
    const Menu(
      id: 4,
      name: 'Assigned Menu',
      status: Status.published,
      version: '1.0.0',
      area: 'dining',
    ),
  ];

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    notifier = AdminTemplatesNotifier(mockMenuRepository);
  });

  group('AdminTemplatesNotifier', () {
    test('initial state should be default', () {
      expect(notifier.state, const AdminTemplatesState());
      expect(notifier.state.templates, isEmpty);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.statusFilter, 'all');
    });

    group('loadTemplates', () {
      test(
        'should load templates successfully and filter out assigned menus',
        () async {
          when(
            () => mockMenuRepository.listAll(onlyPublished: false),
          ).thenAnswer((_) async => Success(mixedMenus));

          await notifier.loadTemplates();

          expect(notifier.state.isLoading, false);
          expect(notifier.state.templates, hasLength(3));
          expect(notifier.state.templates.every((t) => t.area == null), true);
          expect(notifier.state.errorMessage, isNull);
        },
      );

      test('should apply status filter when loading', () async {
        when(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).thenAnswer((_) async => Success(mixedMenus));

        await notifier.loadTemplates(statusFilter: 'draft');

        expect(notifier.state.templates, hasLength(1));
        expect(notifier.state.templates.first.status, Status.draft);
        expect(notifier.state.statusFilter, 'draft');
      });

      test('should return all templates when filter is "all"', () async {
        when(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).thenAnswer((_) async => Success(mixedMenus));

        await notifier.loadTemplates(statusFilter: 'all');

        expect(notifier.state.templates, hasLength(3));
      });

      test('should set error message on failure', () async {
        when(() => mockMenuRepository.listAll(onlyPublished: false)).thenAnswer(
          (_) async => const Failure(ServerError('Failed to fetch templates')),
        );

        await notifier.loadTemplates();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, 'Failed to fetch templates');
        expect(notifier.state.templates, isEmpty);
      });

      test(
        'should preserve existing status filter when not specified',
        () async {
          when(
            () => mockMenuRepository.listAll(onlyPublished: false),
          ).thenAnswer((_) async => Success(mixedMenus));

          // Set a filter first
          await notifier.loadTemplates(statusFilter: 'published');
          expect(notifier.state.statusFilter, 'published');

          // Reload without specifying filter
          await notifier.loadTemplates();
          expect(notifier.state.statusFilter, 'published');
        },
      );
    });

    group('deleteTemplate', () {
      test('should remove template from state on success', () async {
        // First load templates
        when(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).thenAnswer((_) async => Success(templateMenus));
        await notifier.loadTemplates();
        expect(notifier.state.templates, hasLength(3));

        // Delete template
        when(
          () => mockMenuRepository.delete(1),
        ).thenAnswer((_) async => const Success(null));

        await notifier.deleteTemplate(1);

        expect(notifier.state.templates, hasLength(2));
        expect(notifier.state.templates.any((t) => t.id == 1), false);
      });

      test('should set error message on delete failure', () async {
        when(
          () => mockMenuRepository.delete(1),
        ).thenAnswer((_) async => const Failure(ServerError('Delete failed')));

        await notifier.deleteTemplate(1);

        expect(notifier.state.errorMessage, 'Delete failed');
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Trigger an error
        when(
          () => mockMenuRepository.listAll(onlyPublished: false),
        ).thenAnswer((_) async => const Failure(ServerError('Some error')));
        await notifier.loadTemplates();
        expect(notifier.state.errorMessage, isNotNull);

        // Clear it
        notifier.clearError();

        expect(notifier.state.errorMessage, isNull);
      });
    });
  });
}
