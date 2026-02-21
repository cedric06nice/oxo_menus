import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/size_mapper.dart';
import 'package:oxo_menus/data/models/size_dto.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';

void main() {
  group('SizeMapper', () {
    group('toEntity', () {
      test('should convert SizeDto to Size entity with all fields', () {
        final dto = SizeDto({
          'id': 1,
          'name': 'A4',
          'width': 210.0,
          'height': 297.0,
          'status': 'published',
          'direction': 'portrait',
        });

        final result = SizeMapper.toEntity(dto);

        expect(result, isA<Size>());
        expect(result.id, 1);
        expect(result.name, 'A4');
        expect(result.width, 210.0);
        expect(result.height, 297.0);
        expect(result.status, Status.published);
        expect(result.direction, 'portrait');
      });

      test('should parse id from string', () {
        final dto = SizeDto({
          'id': 42,
          'name': 'Letter',
          'width': 215.9,
          'height': 279.4,
          'status': 'draft',
          'direction': 'landscape',
        });

        final result = SizeMapper.toEntity(dto);

        expect(result.id, 42);
        expect(result.name, 'Letter');
        expect(result.status, Status.draft);
        expect(result.direction, 'landscape');
      });

      test('should handle numeric id correctly', () {
        final dto = SizeDto({
          'id': 5,
          'name': 'Custom',
          'width': 100.0,
          'height': 200.0,
          'status': 'archived',
          'direction': 'portrait',
        });

        final result = SizeMapper.toEntity(dto);

        expect(result.id, 5);
        expect(result.name, 'Custom');
        expect(result.status, Status.archived);
      });

      test('should handle integer width and height values', () {
        final dto = SizeDto({
          'id': 1,
          'name': 'Square',
          'width': 100,
          'height': 100,
          'status': 'published',
          'direction': 'portrait',
        });

        final result = SizeMapper.toEntity(dto);

        expect(result.width, 100.0);
        expect(result.height, 100.0);
      });

      test('should default unknown status to draft', () {
        final dto = SizeDto({
          'id': 1,
          'name': 'Test',
          'width': 100.0,
          'height': 200.0,
          'status': 'unknown_status',
          'direction': 'portrait',
        });

        final result = SizeMapper.toEntity(dto);

        expect(result.status, Status.draft);
      });
    });

    group('toCreateDto', () {
      test('should convert CreateSizeInput to map with all fields', () {
        const input = CreateSizeInput(
          name: 'A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );

        final result = SizeMapper.toCreateDto(input);

        expect(result['name'], 'A4');
        expect(result['width'], 210.0);
        expect(result['height'], 297.0);
        expect(result['status'], 'published');
        expect(result['direction'], 'portrait');
      });

      test('should convert draft status correctly', () {
        const input = CreateSizeInput(
          name: 'Letter',
          width: 215.9,
          height: 279.4,
          status: Status.draft,
          direction: 'landscape',
        );

        final result = SizeMapper.toCreateDto(input);

        expect(result['status'], 'draft');
        expect(result['direction'], 'landscape');
      });
    });

    group('toUpdateDto', () {
      test('should only include non-null fields', () {
        const input = UpdateSizeInput(id: 1, name: 'Updated A4');

        final result = SizeMapper.toUpdateDto(input);

        expect(result['name'], 'Updated A4');
        expect(result.containsKey('width'), false);
        expect(result.containsKey('height'), false);
        expect(result.containsKey('status'), false);
        expect(result.containsKey('direction'), false);
      });

      test('should include all provided fields', () {
        const input = UpdateSizeInput(
          id: 1,
          name: 'A5',
          width: 148.0,
          height: 210.0,
          status: Status.archived,
          direction: 'landscape',
        );

        final result = SizeMapper.toUpdateDto(input);

        expect(result['name'], 'A5');
        expect(result['width'], 148.0);
        expect(result['height'], 210.0);
        expect(result['status'], 'archived');
        expect(result['direction'], 'landscape');
      });

      test('should return empty map when only id is provided', () {
        const input = UpdateSizeInput(id: 1);

        final result = SizeMapper.toUpdateDto(input);

        expect(result, isEmpty);
      });
    });
  });
}
