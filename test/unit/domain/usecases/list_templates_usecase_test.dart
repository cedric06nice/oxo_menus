import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/usecases/list_templates_usecase.dart';

import '../../../fakes/builders/menu_builder.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  group('ListTemplatesUseCase', () {
    late FakeMenuRepository menuRepo;
    late ListTemplatesUseCase useCase;

    setUp(() {
      menuRepo = FakeMenuRepository();
      useCase = ListTemplatesUseCase(menuRepository: menuRepo);
    });

    // -------------------------------------------------------------------------
    // Repository failure
    // -------------------------------------------------------------------------

    group('repository failure', () {
      test('should return Failure when menuRepository.listAll fails', () async {
        // Arrange
        menuRepo.whenListAll(failure(network()));

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkError>());
      });

      test('should propagate ServerError from repository', () async {
        // Arrange
        menuRepo.whenListAll(failure(server()));

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ServerError>());
      });
    });

    // -------------------------------------------------------------------------
    // No filter
    // -------------------------------------------------------------------------

    group('no filter', () {
      test(
        'should return all menus when no statusFilter is provided',
        () async {
          // Arrange
          final menus = [
            buildMenu(id: 1, status: Status.draft),
            buildMenu(id: 2, status: Status.published),
            buildMenu(id: 3, status: Status.archived),
          ];
          menuRepo.whenListAll(success(menus));

          // Act
          final result = await useCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.length, equals(3));
        },
      );

      test('should return all menus when statusFilter is "all"', () async {
        // Arrange
        final menus = [
          buildMenu(id: 1, status: Status.draft),
          buildMenu(id: 2, status: Status.published),
        ];
        menuRepo.whenListAll(success(menus));

        // Act
        final result = await useCase.execute(statusFilter: 'all');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.length, equals(2));
      });
    });

    // -------------------------------------------------------------------------
    // Filter by status
    // -------------------------------------------------------------------------

    group('filter by status', () {
      test(
        'should return only draft menus when statusFilter is "draft"',
        () async {
          // Arrange
          final menus = [
            buildMenu(id: 1, status: Status.draft),
            buildMenu(id: 2, status: Status.published),
            buildMenu(id: 3, status: Status.draft),
          ];
          menuRepo.whenListAll(success(menus));

          // Act
          final result = await useCase.execute(statusFilter: 'draft');

          // Assert
          expect(result.isSuccess, isTrue);
          final filtered = result.valueOrNull!;
          expect(filtered.length, equals(2));
          expect(filtered.every((m) => m.status == Status.draft), isTrue);
        },
      );

      test(
        'should return only published menus when statusFilter is "published"',
        () async {
          // Arrange
          final menus = [
            buildMenu(id: 1, status: Status.draft),
            buildMenu(id: 2, status: Status.published),
          ];
          menuRepo.whenListAll(success(menus));

          // Act
          final result = await useCase.execute(statusFilter: 'published');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.length, equals(1));
          expect(result.valueOrNull!.single.status, equals(Status.published));
        },
      );

      test(
        'should return only archived menus when statusFilter is "archived"',
        () async {
          // Arrange
          final menus = [
            buildMenu(id: 1, status: Status.archived),
            buildMenu(id: 2, status: Status.published),
          ];
          menuRepo.whenListAll(success(menus));

          // Act
          final result = await useCase.execute(statusFilter: 'archived');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!.length, equals(1));
          expect(result.valueOrNull!.single.status, equals(Status.archived));
        },
      );

      test('should return empty list when no menus match the filter', () async {
        // Arrange
        menuRepo.whenListAll(success([buildMenu(id: 1, status: Status.draft)]));

        // Act
        final result = await useCase.execute(statusFilter: 'published');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!, isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // Empty repository
    // -------------------------------------------------------------------------

    group('empty repository', () {
      test(
        'should return empty list when repository returns no menus',
        () async {
          // Arrange
          menuRepo.whenListAll(success([]));

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
          menuRepo.whenListAll(success([]));

          // Act
          final result = await useCase.execute(statusFilter: 'published');

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull!, isEmpty);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Repository call semantics
    // -------------------------------------------------------------------------

    group('repository call semantics', () {
      test('should always call listAll with onlyPublished: false', () async {
        // Arrange
        menuRepo.whenListAll(success([]));

        // Act
        await useCase.execute();

        // Assert
        expect(menuRepo.listAllCalls.single.onlyPublished, isFalse);
      });
    });
  });
}
