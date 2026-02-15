import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/file_mapper.dart';

void main() {
  group('FileMapper', () {
    test('should map raw file data to ImageFileInfo entity', () {
      final raw = {
        'id': 'abc-123',
        'title': 'menu-bg.jpg',
        'type': 'image/jpeg',
      };
      final entity = FileMapper.toEntity(raw);
      expect(entity.id, 'abc-123');
      expect(entity.title, 'menu-bg.jpg');
      expect(entity.type, 'image/jpeg');
    });

    test('should handle null title gracefully', () {
      final raw = {'id': 'abc-123', 'type': 'image/png'};
      final entity = FileMapper.toEntity(raw);
      expect(entity.id, 'abc-123');
      expect(entity.title, isNull);
      expect(entity.type, 'image/png');
    });

    test('should handle null type gracefully', () {
      final raw = {'id': 'abc-123', 'title': 'photo.jpg'};
      final entity = FileMapper.toEntity(raw);
      expect(entity.id, 'abc-123');
      expect(entity.title, 'photo.jpg');
      expect(entity.type, isNull);
    });

    test('should handle both null title and type', () {
      final raw = {'id': 'abc-123'};
      final entity = FileMapper.toEntity(raw);
      expect(entity.id, 'abc-123');
      expect(entity.title, isNull);
      expect(entity.type, isNull);
    });
  });
}
