import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';

// Mock props class for testing
class MockProps {
  final String value;
  const MockProps(this.value);

  factory MockProps.fromJson(Map<String, dynamic> json) {
    return MockProps(json['value'] as String);
  }

  Map<String, dynamic> toJson() => {'value': value};
}

void main() {
  group('WidgetRegistry', () {
    late WidgetRegistry registry;

    setUp(() {
      registry = WidgetRegistry();
    });

    test('should register a widget definition', () {
      final definition = WidgetDefinition<MockProps>(
        type: 'mock',
        version: '1.0.0',
        parseProps: (json) => MockProps.fromJson(json),
        render: (props, context) => const SizedBox(),
        defaultProps: const MockProps('default'),
      );

      registry.register(definition);

      expect(registry.isRegistered('mock'), true);
      expect(registry.count, 1);
    });

    test('should retrieve a registered widget definition', () {
      final definition = WidgetDefinition<MockProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => MockProps.fromJson(json),
        render: (props, context) => const SizedBox(),
        defaultProps: const MockProps('default'),
      );

      registry.register(definition);

      final retrieved = registry.getDefinition('test');

      expect(retrieved, isNotNull);
      expect(retrieved?.type, 'test');
      expect(retrieved?.version, '1.0.0');
    });

    test('should return null for unknown widget type', () {
      final definition = registry.getDefinition('unknown');

      expect(definition, isNull);
    });

    test('should list all registered widget types', () {
      final definition1 = WidgetDefinition<MockProps>(
        type: 'widget1',
        version: '1.0.0',
        parseProps: (json) => MockProps.fromJson(json),
        render: (props, context) => const SizedBox(),
        defaultProps: const MockProps('default'),
      );

      final definition2 = WidgetDefinition<MockProps>(
        type: 'widget2',
        version: '1.0.0',
        parseProps: (json) => MockProps.fromJson(json),
        render: (props, context) => const SizedBox(),
        defaultProps: const MockProps('default'),
      );

      registry.register(definition1);
      registry.register(definition2);

      final types = registry.registeredTypes;

      expect(types, hasLength(2));
      expect(types, contains('widget1'));
      expect(types, contains('widget2'));
    });

    test('should check if a widget type is registered', () {
      final definition = WidgetDefinition<MockProps>(
        type: 'registered',
        version: '1.0.0',
        parseProps: (json) => MockProps.fromJson(json),
        render: (props, context) => const SizedBox(),
        defaultProps: const MockProps('default'),
      );

      registry.register(definition);

      expect(registry.isRegistered('registered'), true);
      expect(registry.isRegistered('not-registered'), false);
    });

    test('should replace existing definition when registering same type', () {
      final definition1 = WidgetDefinition<MockProps>(
        type: 'widget',
        version: '1.0.0',
        parseProps: (json) => MockProps.fromJson(json),
        render: (props, context) => const SizedBox(),
        defaultProps: const MockProps('v1'),
      );

      final definition2 = WidgetDefinition<MockProps>(
        type: 'widget',
        version: '2.0.0',
        parseProps: (json) => MockProps.fromJson(json),
        render: (props, context) => const SizedBox(),
        defaultProps: const MockProps('v2'),
      );

      registry.register(definition1);
      registry.register(definition2);

      final retrieved = registry.getDefinition('widget');

      expect(registry.count, 1);
      expect(retrieved?.version, '2.0.0');
    });

    test('should handle multiple registrations', () {
      for (int i = 0; i < 10; i++) {
        final definition = WidgetDefinition<MockProps>(
          type: 'widget$i',
          version: '1.0.0',
          parseProps: (json) => MockProps.fromJson(json),
          render: (props, context) => const SizedBox(),
          defaultProps: const MockProps('default'),
        );
        registry.register(definition);
      }

      expect(registry.count, 10);
      expect(registry.registeredTypes, hasLength(10));

      for (int i = 0; i < 10; i++) {
        expect(registry.isRegistered('widget$i'), true);
      }
    });
  });
}
