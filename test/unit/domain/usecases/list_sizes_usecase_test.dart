import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/usecases/list_sizes_usecase.dart';

import '../../../fakes/builders/size_builder.dart';
import '../../../fakes/fake_size_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  group('ListSizesUseCase', () {
    late FakeSizeRepository sizeRepo;
    late ListSizesUseCase useCase;

    setUp(() {
      sizeRepo = FakeSizeRepository();
      useCase = ListSizesUseCase(sizeRepository: sizeRepo);
    });

    // -------------------------------------------------------------------------
    // Repository failure
    // -------------------------------------------------------------------------

    group('repository failure', () {
      test(
        'should return Failure when sizeRepository.getAll fails',
        () async {
          // Arrange
          sizeRepo.whenGetAll(failure(network()));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );

      test(
        'should propagate ServerError from repository',
        () async {
          // Arrange
          sizeRepo.whenGetAll(failure(server()));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<ServerError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // No filter
    // -------------------------------------------------------------------------

    group('no filter', () {
      test(
        'should return all sizes when no statusFilter is provided',
        () async {
          // Arrange
          final sizes = [
            buildSize(id: 1, status: Status.draft),
            buildSize(id: 2, status: Status.published),
            buildSize(id: 3, status: Status.archived),
          ];
          sizeRepo.whenGetAll(success(sizes));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.length, equals(3));
        },
      );

      test(
        'should return all sizes when statusFilter is "all"',
        () async {
          // Arrange
          final sizes = [
            buildSize(id: 1, status: Status.draft),
            buildSize(id: 2, status: Status.published),
          ];
          sizeRepo.whenGetAll(success(sizes));

          // Act
          final result = await useCase.execute(statusFilter: 'all');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.length, equals(2));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Filter by status
    // -------------------------------------------------------------------------

    group('filter by status', () {
      test(
        'should return only published sizes when statusFilter is "published"',
        () async {
          // Arrange
          final sizes = [
            buildSize(id: 1, status: Status.draft),
            buildSize(id: 2, status: Status.published),
            buildSize(id: 3, status: Status.published),
          ];
          sizeRepo.whenGetAll(success(sizes));

          // Act
          final result = await useCase.execute(statusFilter: 'published');

          // Assert
          expect(result.isSuccess, isTrue);
          final filtered = result.valueOrNull!;
          expect(filtered.length, equals(2));
          expect(
            filtered.every((s) => s.status == Status.published),
            isTrue,
          );
        },
      );

      test(
        'should return only draft sizes when statusFilter is "draft"',
        () async {
          // Arrange
          final sizes = [
            buildSize(id: 1, status: Status.draft),
            buildSize(id: 2, status: Status.published),
          ];
          sizeRepo.whenGetAll(success(sizes));

          // Act
          final result = await useCase.execute(statusFilter: 'draft');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.length, equals(1));
          expect(result.valueOrNull!.single.status, equals(Status.draft));
        },
      );

      test(
        'should return only archived sizes when statusFilter is "archived"',
        () async {
          // Arrange
          final sizes = [
            buildSize(id: 1, status: Status.archived),
            buildSize(id: 2, status: Status.published),
          ];
          sizeRepo.whenGetAll(success(sizes));

          // Act
          final result = await useCase.execute(statusFilter: 'archived');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.length, equals(1));
          expect(result.valueOrNull!.single.status, equals(Status.archived));
        },
      );

      test(
        'should return empty list when no sizes match the filter',
        () async {
          // Arrange
          sizeRepo.whenGetAll(
            success([buildSize(id: 1, status: Status.draft)]),
          );

          // Act
          final result = await useCase.execute(statusFilter: 'published');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!, isEmpty);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Empty repository
    // -------------------------------------------------------------------------

    group('empty repository', () {
      test(
        'should return empty list when repository returns no sizes',
        () async {
          // Arrange
          sizeRepo.whenGetAll(success([]));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!, isEmpty);
        },
      );

      test(
        'should return empty list when filtering an empty repository',
        () async {
          // Arrange
          sizeRepo.whenGetAll(success([]));

          // Act
          final result = await useCase.execute(statusFilter: 'published');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!, isEmpty);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Repository wiring
    // -------------------------------------------------------------------------

    group('repository wiring', () {
      test(
        'should call sizeRepository.getAll exactly once',
        () async {
          // Arrange
          sizeRepo.whenGetAll(success([]));

          // Act
          await useCase.execute();

          // Assert
          expect(sizeRepo.getAllCalls.length, equals(1));
        },
      );
    });
  });
}
