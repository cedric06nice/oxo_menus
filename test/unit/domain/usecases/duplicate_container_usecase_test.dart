import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/usecases/duplicate_container_usecase.dart';

import '../../../fakes/builders/column_builder.dart';
import '../../../fakes/builders/container_builder.dart';
import '../../../fakes/builders/widget_instance_builder.dart';
import '../../../fakes/fake_column_repository.dart';
import '../../../fakes/fake_container_repository.dart';
import '../../../fakes/fake_widget_repository.dart';
import '../../../fakes/result_helpers.dart';

void main() {
  group('DuplicateContainerUseCase', () {
    late FakeContainerRepository containerRepo;
    late FakeColumnRepository columnRepo;
    late FakeWidgetRepository widgetRepo;
    late DuplicateContainerUseCase useCase;

    setUp(() {
      containerRepo = FakeContainerRepository();
      columnRepo = FakeColumnRepository();
      widgetRepo = FakeWidgetRepository();

      useCase = DuplicateContainerUseCase(
        containerRepository: containerRepo,
        columnRepository: columnRepo,
        widgetRepository: widgetRepo,
      );
    });

    // -------------------------------------------------------------------------
    // Source container fetch failure
    // -------------------------------------------------------------------------

    group('source container fetch failure', () {
      test(
        'should return Failure when containerRepository.getById fails',
        () async {
          // Arrange
          containerRepo.whenGetById(failure(notFound()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NotFoundError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Siblings fetch failure
    // -------------------------------------------------------------------------

    group('siblings fetch failure', () {
      test(
        'should return Failure when getAllForPage fails for root-level container',
        () async {
          // Arrange
          final source = buildContainer(id: 1, pageId: 10, index: 0);
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForPage(failure(network()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );

      test(
        'should return Failure when getAllForContainer fails for nested container',
        () async {
          // Arrange
          final source = buildContainer(
            id: 1,
            pageId: 10,
            index: 0,
            parentContainerId: 5,
          );
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForContainer(failure(network()));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );
    });

    // -------------------------------------------------------------------------
    // Container creation failure
    // -------------------------------------------------------------------------

    group('container creation failure', () {
      test('should return Failure when container creation fails', () async {
        // Arrange
        final source = buildContainer(id: 1, pageId: 10, index: 0);
        containerRepo.whenGetById(success(source));
        containerRepo.whenGetAllForPage(success([]));
        containerRepo.whenCreate(failure(server()));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<ServerError>());
      });
    });

    // -------------------------------------------------------------------------
    // Column fetch failure during copy
    // -------------------------------------------------------------------------

    group('column fetch failure during copy', () {
      test(
        'should return Failure and rollback when columnRepository.getAllForContainer fails',
        () async {
          // Arrange
          final source = buildContainer(id: 1, pageId: 10, index: 0);
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForPage(success([]));
          containerRepo.whenCreate(success(buildContainer(id: 50, pageId: 10)));
          columnRepo.whenGetAllForContainer(failure(server()));
          containerRepo.whenDelete(success(null));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(containerRepo.deleteCalls.any((c) => c.id == 50), isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Happy path — container with no columns
    // -------------------------------------------------------------------------

    group('happy path — container with no columns', () {
      test('should return new container when source has no columns', () async {
        // Arrange
        final source = buildContainer(id: 1, pageId: 10, index: 0, name: 'Box');
        containerRepo.whenGetById(success(source));
        containerRepo.whenGetAllForPage(success([source]));
        containerRepo.whenReorder(success(null));
        containerRepo.whenCreate(success(buildContainer(id: 50, pageId: 10)));
        columnRepo.whenGetAllForContainer(success([]));
        containerRepo.whenGetAllForContainer(success([]));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull!.id, equals(50));
      });

      test(
        'should append "(copy)" to the container name at the top level',
        () async {
          // Arrange
          final source = buildContainer(
            id: 1,
            pageId: 10,
            index: 0,
            name: 'Header',
          );
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForPage(success([source]));
          containerRepo.whenReorder(success(null));
          containerRepo.whenCreate(success(buildContainer(id: 50, pageId: 10)));
          columnRepo.whenGetAllForContainer(success([]));
          containerRepo.whenGetAllForContainer(success([]));

          // Act
          await useCase.execute(1);

          // Assert
          expect(
            containerRepo.createCalls.first.input.name,
            equals('Header (copy)'),
          );
        },
      );

      test(
        'should set name to null in copy when source name is null',
        () async {
          // Arrange
          final source = buildContainer(id: 1, pageId: 10, index: 0);
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForPage(success([source]));
          containerRepo.whenReorder(success(null));
          containerRepo.whenCreate(success(buildContainer(id: 50, pageId: 10)));
          columnRepo.whenGetAllForContainer(success([]));
          containerRepo.whenGetAllForContainer(success([]));

          // Act
          await useCase.execute(1);

          // Assert
          expect(containerRepo.createCalls.first.input.name, isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Sibling index shifting
    // -------------------------------------------------------------------------

    group('sibling index shifting', () {
      test(
        'should shift siblings with index >= newIndex before creating the copy',
        () async {
          // Arrange
          final source = buildContainer(id: 1, pageId: 10, index: 1);
          final sibling = buildContainer(id: 2, pageId: 10, index: 2);
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForPage(success([source, sibling]));
          containerRepo.whenReorder(success(null));
          containerRepo.whenCreate(
            success(buildContainer(id: 50, pageId: 10, index: 2)),
          );
          columnRepo.whenGetAllForContainer(success([]));
          containerRepo.whenGetAllForContainer(success([]));

          // Act
          await useCase.execute(1);

          // Assert
          final reorderCalls = containerRepo.reorderCalls;
          expect(reorderCalls.any((c) => c.containerId == 2), isTrue);
          expect(reorderCalls.first.newIndex, equals(3));
        },
      );

      test('should not shift siblings with index less than newIndex', () async {
        // Arrange
        final source = buildContainer(id: 1, pageId: 10, index: 2);
        final sibling = buildContainer(id: 2, pageId: 10, index: 0);
        containerRepo.whenGetById(success(source));
        containerRepo.whenGetAllForPage(success([source, sibling]));
        containerRepo.whenCreate(
          success(buildContainer(id: 50, pageId: 10, index: 3)),
        );
        columnRepo.whenGetAllForContainer(success([]));
        containerRepo.whenGetAllForContainer(success([]));

        // Act
        await useCase.execute(1);

        // Assert
        expect(containerRepo.reorderCalls, isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // Column duplication
    // -------------------------------------------------------------------------

    group('column duplication', () {
      test('should create column linked to the new container id', () async {
        // Arrange
        final source = buildContainer(id: 1, pageId: 10, index: 0);
        final sourceColumn = buildColumn(id: 100, containerId: 1, index: 0);
        containerRepo.whenGetById(success(source));
        containerRepo.whenGetAllForPage(success([]));
        containerRepo.whenCreate(success(buildContainer(id: 50, pageId: 10)));
        columnRepo.whenGetAllForContainer(success([sourceColumn]));
        widgetRepo.whenGetAllForColumn(success([]));
        containerRepo.whenGetAllForContainer(success([]));
        columnRepo.whenCreate(success(buildColumn(id: 200, containerId: 50)));

        // Act
        final result = await useCase.execute(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(columnRepo.createCalls.single.input.containerId, equals(50));
      });
    });

    // -------------------------------------------------------------------------
    // Widget duplication
    // -------------------------------------------------------------------------

    group('widget duplication', () {
      test(
        'should create widget linked to the new column id with correct type',
        () async {
          // Arrange
          final source = buildContainer(id: 1, pageId: 10, index: 0);
          final sourceColumn = buildColumn(id: 100, containerId: 1);
          final sourceWidget = buildWidgetInstance(
            id: 200,
            columnId: 100,
            type: 'section',
          );
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForPage(success([]));
          containerRepo.whenCreate(success(buildContainer(id: 50, pageId: 10)));
          columnRepo.whenGetAllForContainer(success([sourceColumn]));
          widgetRepo.whenGetAllForColumn(success([sourceWidget]));
          containerRepo.whenGetAllForContainer(success([]));
          columnRepo.whenCreate(success(buildColumn(id: 200, containerId: 50)));
          widgetRepo.whenCreate(
            success(buildWidgetInstance(id: 300, columnId: 200)),
          );

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(widgetRepo.createCalls.single.input.type, equals('section'));
          expect(widgetRepo.createCalls.single.input.columnId, equals(200));
        },
      );
    });

    // -------------------------------------------------------------------------
    // Rollback on column creation failure
    // -------------------------------------------------------------------------

    group('rollback on column creation failure', () {
      test(
        'should delete created container when column creation fails',
        () async {
          // Arrange
          final source = buildContainer(id: 1, pageId: 10, index: 0);
          final sourceColumn = buildColumn(id: 100, containerId: 1);
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForPage(success([]));
          containerRepo.whenCreate(success(buildContainer(id: 50, pageId: 10)));
          columnRepo.whenGetAllForContainer(success([sourceColumn]));
          columnRepo.whenCreate(failure(server()));
          widgetRepo.whenGetAllForColumn(success([]));
          containerRepo.whenGetAllForContainer(success([]));
          containerRepo.whenDelete(success(null));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(containerRepo.deleteCalls.any((c) => c.id == 50), isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Rollback on widget creation failure
    // -------------------------------------------------------------------------

    group('rollback on widget creation failure', () {
      test(
        'should delete created column and container when widget creation fails',
        () async {
          // Arrange
          final source = buildContainer(id: 1, pageId: 10, index: 0);
          final sourceColumn = buildColumn(id: 100, containerId: 1);
          final sourceWidget = buildWidgetInstance(id: 200, columnId: 100);
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForPage(success([]));
          containerRepo.whenCreate(success(buildContainer(id: 50, pageId: 10)));
          columnRepo.whenGetAllForContainer(success([sourceColumn]));
          columnRepo.whenCreate(success(buildColumn(id: 150, containerId: 50)));
          widgetRepo.whenGetAllForColumn(success([sourceWidget]));
          containerRepo.whenGetAllForContainer(success([]));
          widgetRepo.whenCreate(failure(server()));
          columnRepo.whenDelete(success(null));
          containerRepo.whenDelete(success(null));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isFailure, isTrue);
          expect(columnRepo.deleteCalls.any((c) => c.id == 150), isTrue);
          expect(containerRepo.deleteCalls.any((c) => c.id == 50), isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Child containers (recursive copy)
    // -------------------------------------------------------------------------

    group('child containers', () {
      test(
        'should copy child containers recursively without "(copy)" in their name',
        () async {
          // Arrange
          final source = buildContainer(
            id: 1,
            pageId: 10,
            index: 0,
            name: 'Parent',
          );
          final childSource = buildContainer(
            id: 2,
            pageId: 10,
            index: 0,
            name: 'Child',
          );
          containerRepo.whenGetById(success(source));
          containerRepo.whenGetAllForPage(success([]));
          containerRepo.whenCreate(success(buildContainer(id: 50, pageId: 10)));
          columnRepo.whenGetAllForContainer(success([]));
          // Source container (1) has one child; child (2) has none.
          containerRepo.whenGetAllForContainerForId(1, success([childSource]));
          containerRepo.whenGetAllForContainerForId(2, success([]));

          // Act
          final result = await useCase.execute(1);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(containerRepo.createCalls.length, equals(2));
          expect(containerRepo.createCalls.last.input.name, equals('Child'));
        },
      );
    });
  });
}
