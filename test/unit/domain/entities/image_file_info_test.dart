import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/image_file_info.dart';

void main() {
  group('ImageFileInfo', () {
    test('should create ImageFileInfo with required fields', () {
      const info = ImageFileInfo(
        id: 'abc-123',
        title: 'photo.jpg',
        type: 'image/jpeg',
      );
      expect(info.id, 'abc-123');
      expect(info.title, 'photo.jpg');
      expect(info.type, 'image/jpeg');
    });

    test('should support equality', () {
      const a = ImageFileInfo(id: 'abc', title: 'x', type: 'image/png');
      const b = ImageFileInfo(id: 'abc', title: 'x', type: 'image/png');
      expect(a, equals(b));
    });

    test('should support nullable title and type', () {
      const info = ImageFileInfo(id: 'abc-123');
      expect(info.id, 'abc-123');
      expect(info.title, isNull);
      expect(info.type, isNull);
    });

    test('should support JSON serialization round-trip', () {
      const info = ImageFileInfo(
        id: 'abc-123',
        title: 'photo.jpg',
        type: 'image/jpeg',
      );
      final json = info.toJson();
      final restored = ImageFileInfo.fromJson(json);
      expect(restored, equals(info));
    });
  });
}
