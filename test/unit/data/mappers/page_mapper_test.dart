import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/page_mapper.dart';
import 'package:oxo_menus/data/models/page_dto.dart';
import 'package:oxo_menus/domain/entities/page.dart';

void main() {
  group('PageMapper', () {
    group('toEntity', () {
      test('should map all core fields from a fully-populated DTO', () {
        // Arrange
        final dto = PageDto({
          'id': '8',
          'index': 2,
          'status': 'published',
          'type': 'content',
          'menu': {'id': '3'},
          'date_created': '2025-01-20T08:00:00Z',
          'date_updated': '2025-01-21T09:00:00Z',
        });

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.id, 8);
        expect(entity.menuId, 3);
        expect(entity.index, 2);
        expect(entity.name, 'Page 2');
        expect(entity.type, PageType.content);
        expect(entity.dateCreated, DateTime.parse('2025-01-20T08:00:00Z'));
        expect(entity.dateUpdated, DateTime.parse('2025-01-21T09:00:00Z'));
      });

      test('should parse string id to int', () {
        // Arrange
        final dto = PageDto({'id': '55', 'index': 0, 'status': 'draft', 'type': 'content'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.id, 55);
      });

      test('should parse a large integer id correctly', () {
        // Arrange
        final dto = PageDto({'id': '1000', 'index': 0, 'status': 'draft', 'type': 'content'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.id, 1000);
      });

      test('should default menuId to 0 when menu is null', () {
        // Arrange
        final dto = PageDto({'id': '1', 'index': 0, 'status': 'draft', 'type': 'content'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.menuId, 0);
      });

      test('should resolve menuId when menu is an int reference', () {
        // Arrange
        final dto = PageDto({
          'id': '1',
          'index': 0,
          'status': 'draft',
          'type': 'content',
          'menu': 12,
        });

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.menuId, 12);
      });

      test('should resolve menuId when menu is an expanded map', () {
        // Arrange
        final dto = PageDto({
          'id': '1',
          'index': 0,
          'status': 'draft',
          'type': 'content',
          'menu': {'id': '7'},
        });

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.menuId, 7);
      });

      test('should build name as "Page {index}"', () {
        // Arrange
        final dto = PageDto({'id': '1', 'index': 3, 'status': 'draft', 'type': 'content'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.name, 'Page 3');
      });

      test('should map type "header" to PageType.header', () {
        // Arrange
        final dto = PageDto({'id': '1', 'index': 0, 'status': 'draft', 'type': 'header'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.type, PageType.header);
      });

      test('should map type "footer" to PageType.footer', () {
        // Arrange
        final dto = PageDto({'id': '1', 'index': 0, 'status': 'draft', 'type': 'footer'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.type, PageType.footer);
      });

      test('should map type "content" to PageType.content', () {
        // Arrange
        final dto = PageDto({'id': '1', 'index': 0, 'status': 'draft', 'type': 'content'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.type, PageType.content);
      });

      test('should default to PageType.content for unknown type strings', () {
        // Arrange
        final dto = PageDto({'id': '1', 'index': 0, 'status': 'draft', 'type': 'sidebar'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.type, PageType.content);
      });

      test('should default to PageType.content when type is absent', () {
        // Arrange
        final dto = PageDto({'id': '1', 'index': 0, 'status': 'draft'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.type, PageType.content);
      });

      test('should map null dateCreated and dateUpdated to null', () {
        // Arrange
        final dto = PageDto({'id': '1', 'index': 0, 'status': 'draft', 'type': 'content'});

        // Act
        final entity = PageMapper.toEntity(dto);

        // Assert
        expect(entity.dateCreated, isNull);
        expect(entity.dateUpdated, isNull);
      });
    });

    group('toDto', () {
      test('should map all fields from a fully-populated Page entity', () {
        // Arrange
        final entity = Page(
          id: 10,
          menuId: 4,
          name: 'Page 1',
          index: 1,
          type: PageType.content,
          dateCreated: DateTime.parse('2025-02-01T10:00:00Z'),
          dateUpdated: DateTime.parse('2025-02-02T11:00:00Z'),
        );

        // Act
        final dto = PageMapper.toDto(entity);

        // Assert
        expect(dto.id, '10');
        expect(dto.menu?.id, '4');
        expect(dto.index, 1);
        expect(dto.type, 'content');
      });

      test('should serialize PageType.header as "header"', () {
        // Arrange
        final entity = Page(id: 1, menuId: 1, name: 'Header', index: 0, type: PageType.header);

        // Act
        final dto = PageMapper.toDto(entity);

        // Assert
        expect(dto.type, 'header');
      });

      test('should serialize PageType.footer as "footer"', () {
        // Arrange
        final entity = Page(id: 2, menuId: 1, name: 'Footer', index: 10, type: PageType.footer);

        // Act
        final dto = PageMapper.toDto(entity);

        // Assert
        expect(dto.type, 'footer');
      });

      test('should serialize null dates as null in raw data', () {
        // Arrange
        final entity = Page(id: 3, menuId: 1, name: 'Page 0', index: 0);

        // Act
        final dto = PageMapper.toDto(entity);
        final raw = dto.getRawData();

        // Assert
        expect(raw['date_created'], isNull);
        expect(raw['date_updated'], isNull);
      });

      test('should serialize dates as ISO 8601 strings', () {
        // Arrange
        final created = DateTime.parse('2025-04-15T10:30:00Z');
        final updated = DateTime.parse('2025-04-16T11:45:00Z');
        final entity = Page(
          id: 4,
          menuId: 2,
          name: 'Page 0',
          index: 0,
          dateCreated: created,
          dateUpdated: updated,
        );

        // Act
        final dto = PageMapper.toDto(entity);
        final raw = dto.getRawData();

        // Assert
        expect(raw['date_created'], created.toIso8601String());
        expect(raw['date_updated'], updated.toIso8601String());
      });

      test('should round-trip page type through toDto then read back via getter', () {
        // Arrange
        final entity = Page(id: 5, menuId: 1, name: 'Footer', index: 99, type: PageType.footer);

        // Act
        final dto = PageMapper.toDto(entity);
        final roundTripped = PageMapper.toEntity(dto);

        // Assert
        expect(roundTripped.type, PageType.footer);
      });
    });
  });
}
