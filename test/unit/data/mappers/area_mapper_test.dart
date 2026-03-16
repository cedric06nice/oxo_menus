import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/area_mapper.dart';
import 'package:oxo_menus/data/models/area_dto.dart';

void main() {
  group('AreaMapper', () {
    test('should convert AreaDto to Area entity', () {
      final dto = AreaDto({'id': 1, 'name': 'Dining'});

      final area = AreaMapper.toEntity(dto);

      expect(area.id, 1);
      expect(area.name, 'Dining');
    });

    test('should handle AreaDto with string id', () {
      final dto = AreaDto({'id': '3', 'name': 'Terrace'});

      final area = AreaMapper.toEntity(dto);

      expect(area.id, 3);
      expect(area.name, 'Terrace');
    });

    test('should handle AreaDto with integer id', () {
      final dto = AreaDto({'id': 4, 'name': 'Takeaway'});

      final area = AreaMapper.toEntity(dto);

      expect(area.id, 4);
      expect(area.name, 'Takeaway');
    });
  });
}
