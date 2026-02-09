import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/page_mapper.dart';
import 'package:oxo_menus/data/models/page_dto.dart';
import 'package:oxo_menus/domain/entities/page.dart';

void main() {
  group('PageMapper', () {
    group('toEntity', () {
      test('should convert PageDto to Page with all fields', () {
        // Arrange
        final dto = PageDto({
          'id': 1,
          'index': 0,
          'menu': 5,
          'date_created': '2025-01-15T10:00:00Z',
          'date_updated': '2025-01-15T11:00:00Z',
        });

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.id, 1);
        expect(entity.menuId, 5);
        expect(entity.name, 'Page 0'); // Generated from index
        expect(entity.index, 0);
        expect(entity.dateCreated, isA<DateTime>());
        expect(entity.dateUpdated, isA<DateTime>());
      });

      test('should convert PageDto with minimal fields', () {
        // Arrange
        final dto = PageDto({'id': 2, 'index': 1});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.id, 2);
        expect(entity.menuId, 0); // Defaults to 0
        expect(entity.name, 'Page 1');
        expect(entity.index, 1);
      });

      test('should generate name from index correctly', () {
        // Arrange
        final indexes = [0, 1, 2, 5, 10];

        // Act & Assert
        for (var i = 0; i < indexes.length; i++) {
          final dto = PageDto({'id': i + 1, 'index': indexes[i]});
          final entity = PageMapper.toEntity(dto);
          expect(entity.name, 'Page ${indexes[i]}');
        }
      });
    });

    group('toDto', () {
      test('should convert Page to PageDto with all fields', () {
        // Arrange
        final entity = Page(
          id: 1,
          menuId: 5,
          name: 'Introduction',
          index: 0,
          dateCreated: DateTime.parse('2025-01-15T10:00:00Z'),
          dateUpdated: DateTime.parse('2025-01-15T11:00:00Z'),
        );

        // Act
        final dto = PageMapper.toDto(entity);

        // Assert
        expect(dto.id, '1');
        expect(dto.menu?.id, '5');
        expect(dto.index, 0);
        expect(dto.dateCreated, isA<DateTime>());
        expect(dto.dateUpdated, isA<DateTime>());
      });

      test('should convert Page with minimal fields', () {
        // Arrange
        final entity = Page(id: 2, menuId: 3, name: 'Main Course', index: 1);

        // Act
        final dto = PageMapper.toDto(entity);

        // Assert
        expect(dto.id, '2');
        expect(dto.menu?.id, '3');
        expect(dto.index, 1);
      });
    });
  });
}
