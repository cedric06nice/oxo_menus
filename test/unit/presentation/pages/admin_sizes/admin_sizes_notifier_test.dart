import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_state.dart';

class MockSizeRepository extends Mock implements SizeRepository {}

void main() {
  late AdminSizesNotifier notifier;
  late MockSizeRepository mockRepository;

  setUp(() {
    mockRepository = MockSizeRepository();
    notifier = AdminSizesNotifier(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const CreateSizeInput(
        name: '',
        width: 0,
        height: 0,
        status: Status.draft,
        direction: 'portrait',
      ),
    );
    registerFallbackValue(const UpdateSizeInput(id: 0));
  });

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
    status: Status.draft,
    direction: 'landscape',
  );

  group('AdminSizesNotifier', () {
    test('should have correct initial state', () {
      expect(notifier.state, const AdminSizesState());
    });

    group('loadSizes', () {
      test('should load sizes successfully', () async {
        when(
          () => mockRepository.getAll(),
        ).thenAnswer((_) async => const Success([testSize, testSize2]));

        await notifier.loadSizes();

        expect(notifier.state.sizes, hasLength(2));
        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, isNull);
      });

      test('should filter sizes by status', () async {
        when(
          () => mockRepository.getAll(),
        ).thenAnswer((_) async => const Success([testSize, testSize2]));

        await notifier.loadSizes(statusFilter: 'published');

        expect(notifier.state.sizes, hasLength(1));
        expect(notifier.state.sizes.first.name, 'A4');
        expect(notifier.state.statusFilter, 'published');
      });

      test('should show all sizes when filter is all', () async {
        when(
          () => mockRepository.getAll(),
        ).thenAnswer((_) async => const Success([testSize, testSize2]));

        await notifier.loadSizes(statusFilter: 'all');

        expect(notifier.state.sizes, hasLength(2));
      });

      test('should set error message on failure', () async {
        when(
          () => mockRepository.getAll(),
        ).thenAnswer((_) async => const Failure(ServerError('Server error')));

        await notifier.loadSizes();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, 'Server error');
      });
    });

    group('createSize', () {
      test('should create size and add to list', () async {
        // First load existing sizes
        when(
          () => mockRepository.getAll(),
        ).thenAnswer((_) async => const Success([testSize]));
        await notifier.loadSizes();

        const input = CreateSizeInput(
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );
        const newSize = Size(
          id: 3,
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );

        when(
          () => mockRepository.create(any()),
        ).thenAnswer((_) async => const Success(newSize));

        await notifier.createSize(input);

        expect(notifier.state.sizes, hasLength(2));
        expect(notifier.state.sizes.last.name, 'A5');
      });

      test('should set error message on create failure', () async {
        const input = CreateSizeInput(
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );

        when(
          () => mockRepository.create(any()),
        ).thenAnswer((_) async => const Failure(ServerError('Create failed')));

        await notifier.createSize(input);

        expect(notifier.state.errorMessage, 'Create failed');
      });
    });

    group('updateSize', () {
      test('should update size in list', () async {
        when(
          () => mockRepository.getAll(),
        ).thenAnswer((_) async => const Success([testSize]));
        await notifier.loadSizes();

        const updatedSize = Size(
          id: 1,
          name: 'A4 Updated',
          width: 210,
          height: 297,
          status: Status.published,
          direction: 'portrait',
        );

        when(
          () => mockRepository.update(any()),
        ).thenAnswer((_) async => const Success(updatedSize));

        const input = UpdateSizeInput(id: 1, name: 'A4 Updated');
        await notifier.updateSize(input);

        expect(notifier.state.sizes.first.name, 'A4 Updated');
      });

      test('should set error message on update failure', () async {
        when(
          () => mockRepository.update(any()),
        ).thenAnswer((_) async => const Failure(ServerError('Update failed')));

        const input = UpdateSizeInput(id: 1, name: 'Updated');
        await notifier.updateSize(input);

        expect(notifier.state.errorMessage, 'Update failed');
      });
    });

    group('deleteSize', () {
      test('should remove size from list', () async {
        when(
          () => mockRepository.getAll(),
        ).thenAnswer((_) async => const Success([testSize, testSize2]));
        await notifier.loadSizes();
        expect(notifier.state.sizes, hasLength(2));

        when(
          () => mockRepository.delete(1),
        ).thenAnswer((_) async => const Success(null));

        await notifier.deleteSize(1);

        expect(notifier.state.sizes, hasLength(1));
        expect(notifier.state.sizes.first.id, 2);
      });

      test('should set error message on delete failure', () async {
        when(
          () => mockRepository.delete(99),
        ).thenAnswer((_) async => const Failure(ServerError('Delete failed')));

        await notifier.deleteSize(99);

        expect(notifier.state.errorMessage, 'Delete failed');
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        when(
          () => mockRepository.getAll(),
        ).thenAnswer((_) async => const Failure(ServerError('Error')));
        await notifier.loadSizes();
        expect(notifier.state.errorMessage, isNotNull);

        notifier.clearError();

        expect(notifier.state.errorMessage, isNull);
      });
    });
  });
}
