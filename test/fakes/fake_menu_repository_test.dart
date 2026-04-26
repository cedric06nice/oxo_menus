import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';

import 'builders/menu_builder.dart';
import 'fake_menu_repository.dart';
import 'result_helpers.dart';

void main() {
  group('FakeMenuRepository', () {
    late FakeMenuRepository fake;

    setUp(() {
      fake = FakeMenuRepository();
    });

    // -------------------------------------------------------------------------
    // Default state — unconfigured methods throw StateError
    // -------------------------------------------------------------------------

    group('unconfigured methods throw StateError', () {
      test('should throw StateError when create is called without configuration',
          () async {
        // Arrange
        final input = CreateMenuInput(name: 'Lunch', version: '1');

        // Act / Assert
        await expectLater(
          fake.create(input),
          throwsStateError,
        );
      });

      test(
          'should throw StateError when listAll is called without configuration',
          () async {
        // Act / Assert
        await expectLater(
          fake.listAll(),
          throwsStateError,
        );
      });

      test(
          'should throw StateError when getById is called without configuration',
          () async {
        // Act / Assert
        await expectLater(
          fake.getById(1),
          throwsStateError,
        );
      });

      test('should throw StateError when update is called without configuration',
          () async {
        // Arrange
        final input = UpdateMenuInput(id: 1, name: 'Dinner');

        // Act / Assert
        await expectLater(
          fake.update(input),
          throwsStateError,
        );
      });

      test('should throw StateError when delete is called without configuration',
          () async {
        // Act / Assert
        await expectLater(
          fake.delete(1),
          throwsStateError,
        );
      });
    });

    // -------------------------------------------------------------------------
    // Preset responses — canned value returned, call recorded
    // -------------------------------------------------------------------------

    group('preset responses', () {
      test('should return configured success result from create()', () async {
        // Arrange
        final menu = buildMenu(id: 10, name: 'Lunch');
        fake.whenCreate(success(menu));
        final input = CreateMenuInput(name: 'Lunch', version: '1');

        // Act
        final result = await fake.create(input);

        // Assert
        expect(result, isA<Success<Menu, dynamic>>());
        expect((result as Success).value, equals(menu));
      });

      test('should return configured failure result from listAll()', () async {
        // Arrange
        fake.whenListAll(failureNotFound());

        // Act
        final result = await fake.listAll();

        // Assert
        expect(result, isA<Failure>());
      });

      test('should return configured success result from getById()', () async {
        // Arrange
        final menu = buildMenu(id: 5);
        fake.whenGetById(success(menu));

        // Act
        final result = await fake.getById(5);

        // Assert
        expect(result, isA<Success<Menu, dynamic>>());
        expect((result as Success).value.id, equals(5));
      });

      test('should return configured success result from update()', () async {
        // Arrange
        final updated = buildMenu(id: 3, name: 'Updated Dinner');
        fake.whenUpdate(success(updated));
        final input = UpdateMenuInput(id: 3, name: 'Updated Dinner');

        // Act
        final result = await fake.update(input);

        // Assert
        expect(result, isA<Success<Menu, dynamic>>());
        expect((result as Success).value.name, equals('Updated Dinner'));
      });

      test('should complete successfully from delete() when configured',
          () async {
        // Arrange
        fake.whenDelete(success(null));

        // Act / Assert
        await expectLater(fake.delete(7), completes);
      });
    });

    // -------------------------------------------------------------------------
    // Call recording — arguments are captured correctly
    // -------------------------------------------------------------------------

    group('call recording', () {
      test(
          'should record a MenuCreateCall with the correct input when create() is called',
          () async {
        // Arrange
        final menu = buildMenu();
        fake.whenCreate(success(menu));
        final input = CreateMenuInput(
          name: 'Brunch',
          version: '2',
          status: Status.published,
        );

        // Act
        await fake.create(input);

        // Assert
        expect(fake.createCalls, hasLength(1));
        expect(fake.createCalls.first.input.name, equals('Brunch'));
        expect(fake.createCalls.first.input.version, equals('2'));
        expect(fake.createCalls.first.input.status, equals(Status.published));
      });

      test(
          'should record a MenuListAllCall with onlyPublished flag when listAll() is called',
          () async {
        // Arrange
        fake.whenListAll(success([]));

        // Act
        await fake.listAll(onlyPublished: false, areaIds: [1, 2]);

        // Assert
        expect(fake.listAllCalls, hasLength(1));
        expect(fake.listAllCalls.first.onlyPublished, isFalse);
        expect(fake.listAllCalls.first.areaIds, equals([1, 2]));
      });

      test(
          'should record a MenuGetByIdCall with the correct id when getById() is called',
          () async {
        // Arrange
        fake.whenGetById(success(buildMenu(id: 42)));

        // Act
        await fake.getById(42);

        // Assert
        expect(fake.getByIdCalls, hasLength(1));
        expect(fake.getByIdCalls.first.id, equals(42));
      });

      test(
          'should record a MenuUpdateCall with the correct input when update() is called',
          () async {
        // Arrange
        fake.whenUpdate(success(buildMenu(id: 99)));
        final input = UpdateMenuInput(id: 99, name: 'VIP Menu');

        // Act
        await fake.update(input);

        // Assert
        expect(fake.updateCalls, hasLength(1));
        expect(fake.updateCalls.first.input.id, equals(99));
        expect(fake.updateCalls.first.input.name, equals('VIP Menu'));
      });

      test(
          'should record a MenuDeleteCall with the correct id when delete() is called',
          () async {
        // Arrange
        fake.whenDelete(success(null));

        // Act
        await fake.delete(77);

        // Assert
        expect(fake.deleteCalls, hasLength(1));
        expect(fake.deleteCalls.first.id, equals(77));
      });

      test('should accumulate multiple calls in insertion order', () async {
        // Arrange
        fake.whenGetById(success(buildMenu(id: 1)));
        fake.whenDelete(success(null));

        // Act
        await fake.getById(1);
        await fake.delete(1);

        // Assert
        expect(fake.calls, hasLength(2));
        expect(fake.calls[0], isA<MenuGetByIdCall>());
        expect(fake.calls[1], isA<MenuDeleteCall>());
      });

      test(
          'should record all individual create calls when create() is called multiple times',
          () async {
        // Arrange
        fake.whenCreate(success(buildMenu(id: 1)));

        // Act
        await fake.create(CreateMenuInput(name: 'A', version: '1'));
        await fake.create(CreateMenuInput(name: 'B', version: '1'));
        await fake.create(CreateMenuInput(name: 'C', version: '1'));

        // Assert
        expect(fake.createCalls, hasLength(3));
        expect(fake.createCalls[0].input.name, equals('A'));
        expect(fake.createCalls[1].input.name, equals('B'));
        expect(fake.createCalls[2].input.name, equals('C'));
      });
    });
  });
}
