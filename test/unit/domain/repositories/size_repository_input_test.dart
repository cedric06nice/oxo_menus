import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';

void main() {
  group('CreateSizeInput', () {
    test('should create with all required fields', () {
      const input = CreateSizeInput(
        name: 'A4',
        width: 210.0,
        height: 297.0,
        status: Status.draft,
        direction: 'portrait',
      );

      expect(input.name, 'A4');
      expect(input.width, 210.0);
      expect(input.height, 297.0);
      expect(input.status, Status.draft);
      expect(input.direction, 'portrait');
    });

    test('should support copyWith', () {
      const input = CreateSizeInput(
        name: 'A4',
        width: 210.0,
        height: 297.0,
        status: Status.draft,
        direction: 'portrait',
      );

      final updated = input.copyWith(name: 'A5', width: 148.0, height: 210.0);

      expect(updated.name, 'A5');
      expect(updated.width, 148.0);
      expect(updated.height, 210.0);
      expect(updated.status, Status.draft);
      expect(updated.direction, 'portrait');
    });

    test('should support equality', () {
      const input1 = CreateSizeInput(
        name: 'A4',
        width: 210.0,
        height: 297.0,
        status: Status.draft,
        direction: 'portrait',
      );
      const input2 = CreateSizeInput(
        name: 'A4',
        width: 210.0,
        height: 297.0,
        status: Status.draft,
        direction: 'portrait',
      );

      expect(input1, equals(input2));
    });
  });

  group('UpdateSizeInput', () {
    test('should create with only required id', () {
      const input = UpdateSizeInput(id: 1);

      expect(input.id, 1);
      expect(input.name, isNull);
      expect(input.width, isNull);
      expect(input.height, isNull);
      expect(input.status, isNull);
      expect(input.direction, isNull);
    });

    test('should create with all optional fields', () {
      const input = UpdateSizeInput(
        id: 1,
        name: 'A4 Updated',
        width: 210.0,
        height: 297.0,
        status: Status.published,
        direction: 'landscape',
      );

      expect(input.id, 1);
      expect(input.name, 'A4 Updated');
      expect(input.width, 210.0);
      expect(input.height, 297.0);
      expect(input.status, Status.published);
      expect(input.direction, 'landscape');
    });

    test('should support copyWith', () {
      const input = UpdateSizeInput(id: 1);

      final updated = input.copyWith(name: 'New Name');

      expect(updated.id, 1);
      expect(updated.name, 'New Name');
    });

    test('should support equality', () {
      const input1 = UpdateSizeInput(id: 1, name: 'Test');
      const input2 = UpdateSizeInput(id: 1, name: 'Test');

      expect(input1, equals(input2));
    });
  });
}
