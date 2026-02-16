import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/size_mapper.dart';
import 'package:oxo_menus/data/models/size_dto.dart';
import 'package:oxo_menus/domain/entities/size.dart';

void main() {
  group('SizeMapper', () {
    group('toEntity', () {
      test('should convert SizeDto to Size entity', () {
        final dto = SizeDto({
          'id': 1,
          'name': 'A4',
          'width': 210.0,
          'height': 297.0,
        });

        final result = SizeMapper.toEntity(dto);

        expect(result, isA<Size>());
        expect(result.id, 1);
        expect(result.name, 'A4');
        expect(result.width, 210.0);
        expect(result.height, 297.0);
      });

      test('should parse id from string', () {
        final dto = SizeDto({
          'id': 42,
          'name': 'Letter',
          'width': 215.9,
          'height': 279.4,
        });

        final result = SizeMapper.toEntity(dto);

        expect(result.id, 42);
        expect(result.name, 'Letter');
      });

      test('should handle numeric id correctly', () {
        final dto = SizeDto({
          'id': 5,
          'name': 'Custom',
          'width': 100.0,
          'height': 200.0,
        });

        final result = SizeMapper.toEntity(dto);

        expect(result.id, 5);
        expect(result.name, 'Custom');
      });

      test('should handle integer width and height values', () {
        final dto = SizeDto({
          'id': 1,
          'name': 'Square',
          'width': 100,
          'height': 100,
        });

        final result = SizeMapper.toEntity(dto);

        expect(result.width, 100.0);
        expect(result.height, 100.0);
      });
    });
  });
}
