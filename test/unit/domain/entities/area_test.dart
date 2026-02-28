import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/area.dart';

void main() {
  group('Area Entity', () {
    test('should create Area with required fields', () {
      const area = Area(id: 1, name: 'Dining');

      expect(area.id, 1);
      expect(area.name, 'Dining');
    });

    test('should support equality', () {
      const area1 = Area(id: 1, name: 'Dining');
      const area2 = Area(id: 1, name: 'Dining');

      expect(area1, equals(area2));
      expect(area1.hashCode, equals(area2.hashCode));
    });

    test('should not be equal when fields differ', () {
      const area1 = Area(id: 1, name: 'Dining');
      const area2 = Area(id: 2, name: 'Bar');

      expect(area1, isNot(equals(area2)));
    });

    test('should support copyWith', () {
      const area = Area(id: 1, name: 'Dining');

      final updated = area.copyWith(name: 'Restaurant');

      expect(updated.id, 1);
      expect(updated.name, 'Restaurant');
    });

    test('should serialize to JSON', () {
      const area = Area(id: 1, name: 'Dining');

      final json = area.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Dining');
    });

    test('should deserialize from JSON', () {
      final json = {'id': 1, 'name': 'Dining'};

      final area = Area.fromJson(json);

      expect(area.id, 1);
      expect(area.name, 'Dining');
    });
  });
}
