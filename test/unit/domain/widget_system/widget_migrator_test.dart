import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_migrator.dart';

// Mock props class for testing
class TestProps {
  final String name;
  final int value;

  const TestProps({required this.name, required this.value});

  factory TestProps.fromJson(Map<String, dynamic> json) {
    return TestProps(
      name: json['name'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };
}

void main() {
  group('WidgetMigrator', () {
    test('should detect when migration is needed', () {
      const instance = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'test',
        version: '1.0.0',
        index: 0,
        props: {'name': 'test', 'value': 42},
      );

      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '2.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
      );

      expect(WidgetMigrator.needsMigration(instance, definition), true);
    });

    test('should detect when migration is not needed', () {
      const instance = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'test',
        version: '1.0.0',
        index: 0,
        props: {'name': 'test', 'value': 42},
      );

      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
      );

      expect(WidgetMigrator.needsMigration(instance, definition), false);
    });

    test('should migrate props when migration function is provided', () {
      const instance = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'test',
        version: '1.0.0',
        index: 0,
        props: {'name': 'test', 'value': 42},
      );

      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '2.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
        migrate: (json) {
          // Migration: add 100 to value
          return TestProps(
            name: json['name'] as String,
            value: (json['value'] as int) + 100,
          );
        },
      );

      final migrated = WidgetMigrator.migrate(instance, definition);

      expect(migrated['name'], 'test');
      expect(migrated['value'], 142);
    });

    test('should return original props when no migration function', () {
      const instance = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'test',
        version: '1.0.0',
        index: 0,
        props: {'name': 'test', 'value': 42},
      );

      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '2.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
      );

      final migrated = WidgetMigrator.migrate(instance, definition);

      expect(migrated, instance.props);
      expect(migrated['name'], 'test');
      expect(migrated['value'], 42);
    });

    test('should handle migration errors gracefully', () {
      const instance = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'test',
        version: '1.0.0',
        index: 0,
        props: {'name': 'test', 'value': 42},
      );

      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '2.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
        migrate: (json) {
          // Migration that throws an error
          throw Exception('Migration failed');
        },
      );

      // Should not throw and return original props
      final migrated = WidgetMigrator.migrate(instance, definition);

      expect(migrated, instance.props);
      expect(migrated['name'], 'test');
      expect(migrated['value'], 42);
    });

    test('should handle missing fields during migration', () {
      const instance = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'test',
        version: '1.0.0',
        index: 0,
        props: {'name': 'test'},
      );

      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '2.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
        migrate: (json) {
          // Migration that adds missing field
          return TestProps(
            name: json['name'] as String,
            value: json['value'] as int? ?? 100, // Default value
          );
        },
      );

      final migrated = WidgetMigrator.migrate(instance, definition);

      expect(migrated['name'], 'test');
      expect(migrated['value'], 100);
    });

    test('should preserve all original props when migration fails', () {
      const instance = WidgetInstance(
        id: 1,
        columnId: 1,
        type: 'test',
        version: '1.0.0',
        index: 0,
        props: {
          'name': 'test',
          'value': 42,
          'extra': 'data',
        },
      );

      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '2.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
        migrate: (json) {
          throw Exception('Migration error');
        },
      );

      final migrated = WidgetMigrator.migrate(instance, definition);

      expect(migrated, instance.props);
      expect(migrated['name'], 'test');
      expect(migrated['value'], 42);
      expect(migrated['extra'], 'data');
    });
  });
}
