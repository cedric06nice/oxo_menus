import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/size_dto.dart';

void main() {
  group('SizeDto', () {
    group('fromJson', () {
      test('should deserialize from JSON with all fields', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'A4 (Portrait)',
          'width': 210,
          'height': 297,
        };

        // Act
        final dto = SizeDto(json);

        // Assert
        expect(dto.id, '1');
        expect(dto.name, 'A4 (Portrait)');
        expect(dto.width, 210.0);
        expect(dto.height, 297.0);
      });

      test('should handle width and height as double', () {
        // Arrange
        final json = {
          'id': 2,
          'name': 'Letter',
          'width': 215.9,
          'height': 279.4,
        };

        // Act
        final dto = SizeDto(json);

        // Assert
        expect(dto.id, '2');
        expect(dto.name, 'Letter');
        expect(dto.width, 215.9);
        expect(dto.height, 279.4);
      });

      test('should handle width and height as int', () {
        // Arrange
        final json = {'id': 3, 'name': 'Custom', 'width': 200, 'height': 300};

        // Act
        final dto = SizeDto(json);

        // Assert
        expect(dto.id, '3');
        expect(dto.width, 200.0);
        expect(dto.height, 300.0);
        expect(dto.width, isA<double>());
        expect(dto.height, isA<double>());
      });
    });
  });
}
