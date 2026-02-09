import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widgets/dish/dietary_type.dart';
import 'package:oxo_menus/domain/widgets/dish/dish_props.dart';
import 'package:oxo_menus/presentation/widgets/dish_widget/dish_widget_definition.dart';

void main() {
  group('dishWidgetDefinition', () {
    test('should have version 3.0.0', () {
      expect(dishWidgetDefinition.version, '3.0.0');
    });

    test('should have type dish', () {
      expect(dishWidgetDefinition.type, 'dish');
    });

    test('should have null dietary in defaultProps', () {
      expect(dishWidgetDefinition.defaultProps.dietary, isNull);
    });
  });

  group('dish props migration', () {
    test('should migrate legacy dietary list with Vegetarian to enum', () {
      final json = {
        'name': 'Test Dish',
        'price': 10.0,
        'dietary': ['Vegetarian'],
      };
      final migrated = dishWidgetDefinition.migrate!(json);
      expect(migrated.dietary, DietaryType.vegetarian);
    });

    test('should migrate legacy dietary list with Vegan to enum', () {
      final json = {
        'name': 'Test Dish',
        'price': 10.0,
        'dietary': ['Vegan'],
      };
      final migrated = dishWidgetDefinition.migrate!(json);
      expect(migrated.dietary, DietaryType.vegan);
    });

    test('should prefer vegan when both Vegetarian and Vegan present', () {
      final json = {
        'name': 'Test Dish',
        'price': 10.0,
        'dietary': ['Vegetarian', 'Vegan'],
      };
      final migrated = dishWidgetDefinition.migrate!(json);
      expect(migrated.dietary, DietaryType.vegan);
    });

    test('should set dietary to null for unrecognized dietary strings', () {
      final json = {
        'name': 'Test Dish',
        'price': 10.0,
        'dietary': ['Gluten-Free'],
      };
      final migrated = dishWidgetDefinition.migrate!(json);
      expect(migrated.dietary, isNull);
    });

    test('should set dietary to null for empty dietary list', () {
      final json = {
        'name': 'Test Dish',
        'price': 10.0,
        'dietary': <String>[],
      };
      final migrated = dishWidgetDefinition.migrate!(json);
      expect(migrated.dietary, isNull);
    });

    test('should set dietary to null when dietary key is missing', () {
      final json = {
        'name': 'Test Dish',
        'price': 10.0,
      };
      final migrated = dishWidgetDefinition.migrate!(json);
      expect(migrated.dietary, isNull);
    });

    test('should handle dietary already as string (v3 format)', () {
      final json = {
        'name': 'Test Dish',
        'price': 10.0,
        'dietary': 'vegetarian',
      };
      final migrated = dishWidgetDefinition.migrate!(json);
      expect(migrated.dietary, DietaryType.vegetarian);
    });

    test('should still migrate allergens from v1 format', () {
      final json = {
        'name': 'Test Dish',
        'price': 10.0,
        'allergens': ['Dairy', 'Gluten'],
        'dietary': ['Vegetarian'],
      };
      final migrated = dishWidgetDefinition.migrate!(json);
      expect(migrated.effectiveAllergenInfo, isNotEmpty);
      expect(migrated.dietary, DietaryType.vegetarian);
    });

    test('should handle case-insensitive dietary matching', () {
      final json = {
        'name': 'Test Dish',
        'price': 10.0,
        'dietary': ['vegetarian'],
      };
      final migrated = dishWidgetDefinition.migrate!(json);
      expect(migrated.dietary, DietaryType.vegetarian);
    });
  });
}
