import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

import '../../../../fakes/fake_list_sizes_usecase.dart';
import '../../../../fakes/fake_size_repository.dart';

void main() {
  late ProviderContainer container;
  late FakeSizeRepository fakeSizeRepository;
  late FakeListSizesUseCase fakeListSizesUseCase;

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

  setUp(() {
    fakeSizeRepository = FakeSizeRepository();
    fakeListSizesUseCase = FakeListSizesUseCase();
    container = ProviderContainer(
      overrides: [
        sizeRepositoryProvider.overrideWithValue(fakeSizeRepository),
        listSizesUseCaseProvider.overrideWithValue(fakeListSizesUseCase),
      ],
    );
  });

  tearDown(() => container.dispose());

  AdminSizesNotifier readNotifier() =>
      container.read(adminSizesProvider.notifier);
  AdminSizesState readState() => container.read(adminSizesProvider);

  group('AdminSizesNotifier', () {
    group('initial state', () {
      test('should have empty sizes list', () {
        expect(readState().sizes, isEmpty);
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

    group('loadSizes', () {
      test('should load sizes successfully', () async {
        fakeListSizesUseCase.stubExecute(const Success([testSize, testSize2]));

        await readNotifier().loadSizes();

        expect(readState().sizes, hasLength(2));
        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, isNull);
      });

      test('should filter sizes by status', () async {
        fakeListSizesUseCase.stubExecute(const Success([testSize]));

        await readNotifier().loadSizes(statusFilter: 'published');

        expect(readState().sizes, hasLength(1));
        expect(readState().sizes.first.name, 'A4');
        expect(readState().statusFilter, 'published');
      });

      test('should show all sizes when filter is all', () async {
        fakeListSizesUseCase.stubExecute(const Success([testSize, testSize2]));

        await readNotifier().loadSizes(statusFilter: 'all');

        expect(readState().sizes, hasLength(2));
      });

      test('should set error message on failure', () async {
        fakeListSizesUseCase.stubExecute(
          const Failure(ServerError('Server error')),
        );

        await readNotifier().loadSizes();

        expect(readState().isLoading, isFalse);
        expect(readState().errorMessage, 'Server error');
      });

      test(
        'should preserve existing status filter when not specified',
        () async {
          fakeListSizesUseCase.stubExecute(const Success([testSize]));
          await readNotifier().loadSizes(statusFilter: 'published');
          expect(readState().statusFilter, 'published');

          fakeListSizesUseCase.stubExecute(const Success([testSize]));
          await readNotifier().loadSizes();

          expect(readState().statusFilter, 'published');
        },
      );

      test(
        'should record the use-case call with the filter argument',
        () async {
          fakeListSizesUseCase.stubExecute(const Success([]));

          await readNotifier().loadSizes(statusFilter: 'draft');

          expect(fakeListSizesUseCase.calls, hasLength(1));
          expect(fakeListSizesUseCase.calls.first.statusFilter, 'draft');
        },
      );

      test('should clear previous error on new load attempt', () async {
        fakeListSizesUseCase.stubExecute(const Failure(ServerError('Error')));
        await readNotifier().loadSizes();
        expect(readState().errorMessage, isNotNull);

        fakeListSizesUseCase.stubExecute(const Success([testSize, testSize2]));
        await readNotifier().loadSizes();

        expect(readState().errorMessage, isNull);
      });
    });

    group('createSize', () {
      test('should create size and add to list', () async {
        fakeListSizesUseCase.stubExecute(const Success([testSize]));
        await readNotifier().loadSizes();

        const newSize = Size(
          id: 3,
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );
        fakeSizeRepository.whenCreate(const Success(newSize));

        const input = CreateSizeInput(
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );
        await readNotifier().createSize(input);

        expect(readState().sizes, hasLength(2));
        expect(readState().sizes.last.name, 'A5');
      });

      test('should set error message on create failure', () async {
        fakeSizeRepository.whenCreate(
          const Failure(ServerError('Create failed')),
        );

        const input = CreateSizeInput(
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );
        await readNotifier().createSize(input);

        expect(readState().errorMessage, 'Create failed');
      });

      test('should record the create call', () async {
        const newSize = Size(
          id: 3,
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );
        fakeSizeRepository.whenCreate(const Success(newSize));

        const input = CreateSizeInput(
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.draft,
          direction: 'portrait',
        );
        await readNotifier().createSize(input);

        expect(fakeSizeRepository.createCalls, hasLength(1));
        expect(fakeSizeRepository.createCalls.first.input.name, 'A5');
      });
    });

    group('updateSize', () {
      test('should update size in list', () async {
        fakeListSizesUseCase.stubExecute(const Success([testSize]));
        await readNotifier().loadSizes();

        const updatedSize = Size(
          id: 1,
          name: 'A4 Updated',
          width: 210,
          height: 297,
          status: Status.published,
          direction: 'portrait',
        );
        fakeSizeRepository.whenUpdate(const Success(updatedSize));

        const input = UpdateSizeInput(id: 1, name: 'A4 Updated');
        await readNotifier().updateSize(input);

        expect(readState().sizes.first.name, 'A4 Updated');
      });

      test('should set error message on update failure', () async {
        fakeSizeRepository.whenUpdate(
          const Failure(ServerError('Update failed')),
        );

        const input = UpdateSizeInput(id: 1, name: 'Updated');
        await readNotifier().updateSize(input);

        expect(readState().errorMessage, 'Update failed');
      });

      test('should record the update call with the correct id', () async {
        const updatedSize = Size(
          id: 1,
          name: 'A4 Updated',
          width: 210,
          height: 297,
          status: Status.published,
          direction: 'portrait',
        );
        fakeSizeRepository.whenUpdate(const Success(updatedSize));

        const input = UpdateSizeInput(id: 1, name: 'A4 Updated');
        await readNotifier().updateSize(input);

        expect(fakeSizeRepository.updateCalls, hasLength(1));
        expect(fakeSizeRepository.updateCalls.first.input.id, 1);
      });

      test(
        'should not change non-updated items when updating one size',
        () async {
          fakeListSizesUseCase.stubExecute(
            const Success([testSize, testSize2]),
          );
          await readNotifier().loadSizes();

          const updated = Size(
            id: 1,
            name: 'A4 Updated',
            width: 210,
            height: 297,
            status: Status.published,
            direction: 'portrait',
          );
          fakeSizeRepository.whenUpdate(const Success(updated));

          const input = UpdateSizeInput(id: 1, name: 'A4 Updated');
          await readNotifier().updateSize(input);

          expect(readState().sizes, hasLength(2));
          final item2 = readState().sizes.firstWhere((s) => s.id == 2);
          expect(item2.name, 'Letter');
        },
      );
    });

    group('deleteSize', () {
      test('should remove size from list', () async {
        fakeListSizesUseCase.stubExecute(const Success([testSize, testSize2]));
        await readNotifier().loadSizes();
        expect(readState().sizes, hasLength(2));

        fakeSizeRepository.whenDelete(const Success(null));
        await readNotifier().deleteSize(1);

        expect(readState().sizes, hasLength(1));
        expect(readState().sizes.first.id, 2);
      });

      test('should set error message on delete failure', () async {
        fakeSizeRepository.whenDelete(
          const Failure(ServerError('Delete failed')),
        );

        await readNotifier().deleteSize(99);

        expect(readState().errorMessage, 'Delete failed');
      });

      test('should record the delete call with the correct id', () async {
        fakeSizeRepository.whenDelete(const Success(null));

        await readNotifier().deleteSize(42);

        expect(fakeSizeRepository.deleteCalls, hasLength(1));
        expect(fakeSizeRepository.deleteCalls.first.id, 42);
      });
    });

    group('clearError', () {
      test('should clear error message when one is set', () async {
        fakeListSizesUseCase.stubExecute(const Failure(ServerError('Error')));
        await readNotifier().loadSizes();
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
