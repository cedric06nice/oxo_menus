import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/size_mapper.dart';
import 'package:oxo_menus/data/models/size_dto.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';

void main() {
  group('SizeMapper', () {
    group('toEntity', () {
      test('should map all fields from a fully-populated DTO', () {
        // Arrange
        final dto = SizeDto({
          'id': '3',
          'name': 'A4 Portrait',
          'width': 210.0,
          'height': 297.0,
          'status': 'published',
          'direction': 'portrait',
        });

        // Act
        final entity = SizeMapper.toEntity(dto);

        // Assert
        expect(entity.id, 3);
        expect(entity.name, 'A4 Portrait');
        expect(entity.width, 210.0);
        expect(entity.height, 297.0);
        expect(entity.status, Status.published);
        expect(entity.direction, 'portrait');
      });

      test('should parse string id to int', () {
        // Arrange
        final dto = SizeDto({
          'id': '88',
          'name': 'Letter',
          'width': 215.9,
          'height': 279.4,
          'status': 'draft',
          'direction': 'portrait',
        });

        // Act
        final entity = SizeMapper.toEntity(dto);

        // Assert
        expect(entity.id, 88);
      });

      test('should parse a large integer id correctly', () {
        // Arrange
        final dto = SizeDto({
          'id': '1000',
          'name': 'Custom',
          'width': 100.0,
          'height': 150.0,
          'status': 'draft',
          'direction': 'portrait',
        });

        // Act
        final entity = SizeMapper.toEntity(dto);

        // Assert
        expect(entity.id, 1000);
      });

      test('should map status "draft" to Status.draft', () {
        // Arrange
        final dto = SizeDto({
          'id': '1',
          'name': 'S',
          'width': 100.0,
          'height': 100.0,
          'status': 'draft',
          'direction': 'square',
        });

        // Act
        final entity = SizeMapper.toEntity(dto);

        // Assert
        expect(entity.status, Status.draft);
      });

      test('should map status "published" to Status.published', () {
        // Arrange
        final dto = SizeDto({
          'id': '1',
          'name': 'S',
          'width': 100.0,
          'height': 100.0,
          'status': 'published',
          'direction': 'square',
        });

        // Act
        final entity = SizeMapper.toEntity(dto);

        // Assert
        expect(entity.status, Status.published);
      });

      test('should map status "archived" to Status.archived', () {
        // Arrange
        final dto = SizeDto({
          'id': '1',
          'name': 'S',
          'width': 100.0,
          'height': 100.0,
          'status': 'archived',
          'direction': 'square',
        });

        // Act
        final entity = SizeMapper.toEntity(dto);

        // Assert
        expect(entity.status, Status.archived);
      });

      test('should map integer width and height as double', () {
        // Arrange
        final dto = SizeDto({
          'id': '1',
          'name': 'A5',
          'width': 148,
          'height': 210,
          'status': 'draft',
          'direction': 'portrait',
        });

        // Act
        final entity = SizeMapper.toEntity(dto);

        // Assert
        expect(entity.width, isA<double>());
        expect(entity.height, isA<double>());
        expect(entity.width, 148.0);
        expect(entity.height, 210.0);
      });

      test('should map direction string exactly as stored', () {
        // Arrange
        final dto = SizeDto({
          'id': '1',
          'name': 'Landscape',
          'width': 297.0,
          'height': 210.0,
          'status': 'draft',
          'direction': 'landscape',
        });

        // Act
        final entity = SizeMapper.toEntity(dto);

        // Assert
        expect(entity.direction, 'landscape');
      });
    });

    group('toCreateDto', () {
      test('should map all fields from CreateSizeInput', () {
        // Arrange
        const input = CreateSizeInput(
          name: 'A3',
          width: 297.0,
          height: 420.0,
          status: Status.published,
          direction: 'portrait',
        );

        // Act
        final payload = SizeMapper.toCreateDto(input);

        // Assert
        expect(payload['name'], 'A3');
        expect(payload['width'], 297.0);
        expect(payload['height'], 420.0);
        expect(payload['status'], 'published');
        expect(payload['direction'], 'portrait');
        expect(payload, hasLength(5));
      });

      test('should serialize Status.draft as "draft"', () {
        // Arrange
        const input = CreateSizeInput(
          name: 'X',
          width: 100.0,
          height: 100.0,
          status: Status.draft,
          direction: 'square',
        );

        // Act
        final payload = SizeMapper.toCreateDto(input);

        // Assert
        expect(payload['status'], 'draft');
      });

      test('should serialize Status.archived as "archived"', () {
        // Arrange
        const input = CreateSizeInput(
          name: 'Old',
          width: 50.0,
          height: 80.0,
          status: Status.archived,
          direction: 'portrait',
        );

        // Act
        final payload = SizeMapper.toCreateDto(input);

        // Assert
        expect(payload['status'], 'archived');
      });
    });

    group('toUpdateDto', () {
      test('should include all fields when all are provided', () {
        // Arrange
        const input = UpdateSizeInput(
          id: 1,
          name: 'Updated A4',
          width: 210.0,
          height: 297.0,
          status: Status.published,
          direction: 'portrait',
        );

        // Act
        final payload = SizeMapper.toUpdateDto(input);

        // Assert
        expect(payload['name'], 'Updated A4');
        expect(payload['width'], 210.0);
        expect(payload['height'], 297.0);
        expect(payload['status'], 'published');
        expect(payload['direction'], 'portrait');
      });

      test('should omit name when name is null', () {
        // Arrange
        const input = UpdateSizeInput(id: 1, width: 200.0);

        // Act
        final payload = SizeMapper.toUpdateDto(input);

        // Assert
        expect(payload.containsKey('name'), false);
      });

      test('should omit width when width is null', () {
        // Arrange
        const input = UpdateSizeInput(id: 1, name: 'Sized');

        // Act
        final payload = SizeMapper.toUpdateDto(input);

        // Assert
        expect(payload.containsKey('width'), false);
      });

      test('should omit height when height is null', () {
        // Arrange
        const input = UpdateSizeInput(id: 1, name: 'Sized');

        // Act
        final payload = SizeMapper.toUpdateDto(input);

        // Assert
        expect(payload.containsKey('height'), false);
      });

      test('should omit status when status is null', () {
        // Arrange
        const input = UpdateSizeInput(id: 1, name: 'Sized');

        // Act
        final payload = SizeMapper.toUpdateDto(input);

        // Assert
        expect(payload.containsKey('status'), false);
      });

      test('should omit direction when direction is null', () {
        // Arrange
        const input = UpdateSizeInput(id: 1, name: 'Sized');

        // Act
        final payload = SizeMapper.toUpdateDto(input);

        // Assert
        expect(payload.containsKey('direction'), false);
      });

      test('should return empty map when only id is provided', () {
        // Arrange
        const input = UpdateSizeInput(id: 99);

        // Act
        final payload = SizeMapper.toUpdateDto(input);

        // Assert
        expect(payload, isEmpty);
      });

      test('should never include id in the payload', () {
        // Arrange
        const input = UpdateSizeInput(id: 5, name: 'X');

        // Act
        final payload = SizeMapper.toUpdateDto(input);

        // Assert
        expect(payload.containsKey('id'), false);
      });
    });
  });
}
