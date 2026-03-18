import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_definition.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_registry.dart';

class _TestProps {
  final String name;
  const _TestProps(this.name);
  factory _TestProps.fromJson(Map<String, dynamic> json) =>
      _TestProps(json['name'] as String);
}

PresentableWidgetDefinition<_TestProps> _makeDefinition(String type) {
  return PresentableWidgetDefinition<_TestProps>(
    type: type,
    version: '1.0.0',
    parseProps: (json) => _TestProps.fromJson(json),
    render: (props, context) => Text(props.name),
    defaultProps: const _TestProps('default'),
    materialIcon: Icons.widgets,
  );
}

void main() {
  group('PresentableWidgetRegistry', () {
    late PresentableWidgetRegistry registry;

    setUp(() {
      registry = PresentableWidgetRegistry();
    });

    test('should register a presentable widget definition', () {
      registry.register(_makeDefinition('test'));

      expect(registry.isRegistered('test'), true);
      expect(registry.count, 1);
    });

    test('should retrieve a registered definition', () {
      registry.register(_makeDefinition('dish'));

      final definition = registry.getDefinition('dish');

      expect(definition, isNotNull);
      expect(definition, isA<PresentableWidgetDefinition>());
      expect(definition!.type, 'dish');
    });

    test('should return null for unknown type', () {
      expect(registry.getDefinition('unknown'), isNull);
    });

    test('should list all registered types', () {
      registry.register(_makeDefinition('dish'));
      registry.register(_makeDefinition('wine'));

      expect(registry.registeredTypes, containsAll(['dish', 'wine']));
      expect(registry.registeredTypes, hasLength(2));
    });

    test('should replace existing definition when registering same type', () {
      final def1 = PresentableWidgetDefinition<_TestProps>(
        type: 'widget',
        version: '1.0.0',
        parseProps: (json) => _TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const _TestProps('v1'),
      );
      final def2 = PresentableWidgetDefinition<_TestProps>(
        type: 'widget',
        version: '2.0.0',
        parseProps: (json) => _TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const _TestProps('v2'),
      );

      registry.register(def1);
      registry.register(def2);

      expect(registry.count, 1);
      expect(registry.getDefinition('widget')?.version, '2.0.0');
    });

    test('should expose domain-only base registry', () {
      registry.register(_makeDefinition('test'));

      final baseRegistry = registry.domainRegistry;

      expect(baseRegistry.isRegistered('test'), true);
      expect(baseRegistry.getDefinition('test')?.type, 'test');
    });
  });
}
