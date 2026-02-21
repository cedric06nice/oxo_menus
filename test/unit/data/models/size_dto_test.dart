import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/size_dto.dart';

void main() {
  group('SizeDto', () {
    group('fromJson', () {
      test('should deserialize from JSON with all fields', () {
        final json = {
          'id': 1,
          'name': 'A4 (Portrait)',
          'width': 210,
          'height': 297,
          'status': 'published',
          'direction': 'portrait',
        };

        final dto = SizeDto(json);

        expect(dto.id, '1');
        expect(dto.name, 'A4 (Portrait)');
        expect(dto.width, 210.0);
        expect(dto.height, 297.0);
        expect(dto.status, 'published');
        expect(dto.direction, 'portrait');
      });

      test('should handle width and height as double', () {
        final json = {
          'id': 2,
          'name': 'Letter',
          'width': 215.9,
          'height': 279.4,
          'status': 'draft',
          'direction': 'landscape',
        };

        final dto = SizeDto(json);

        expect(dto.id, '2');
        expect(dto.name, 'Letter');
        expect(dto.width, 215.9);
        expect(dto.height, 279.4);
        expect(dto.status, 'draft');
        expect(dto.direction, 'landscape');
      });

      test('should handle width and height as int', () {
        final json = {
          'id': 3,
          'name': 'Custom',
          'width': 200,
          'height': 300,
          'status': 'archived',
          'direction': 'portrait',
        };

        final dto = SizeDto(json);

        expect(dto.id, '3');
        expect(dto.width, 200.0);
        expect(dto.height, 300.0);
        expect(dto.width, isA<double>());
        expect(dto.height, isA<double>());
      });
    });

    group('newItem', () {
      test('should create a new SizeDto with all fields set', () {
        final dto = SizeDto.newItem(
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: 'published',
          direction: 'portrait',
        );

        expect(dto.name, 'A4');
        expect(dto.width, 210.0);
        expect(dto.height, 297.0);
        expect(dto.status, 'published');
        expect(dto.direction, 'portrait');
      });

      test('should create a new item without pre-existing id', () {
        final dto = SizeDto.newItem(
          name: 'Letter',
          width: 215.9,
          height: 279.4,
          status: 'draft',
          direction: 'landscape',
        );

        // newItem should not have an id yet (it's assigned by Directus)
        expect(dto.name, 'Letter');
        expect(dto.direction, 'landscape');
      });
    });
  });
}
