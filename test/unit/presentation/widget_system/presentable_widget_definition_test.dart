import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/widget_system/presentable_widget_definition.dart';

class _TestProps {
  final String name;
  const _TestProps(this.name);
  factory _TestProps.fromJson(Map<String, dynamic> json) =>
      _TestProps(json['name'] as String);
}

void main() {
  group('PresentableWidgetDefinition', () {
    test('should extend WidgetDefinition', () {
      final definition = PresentableWidgetDefinition<_TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => _TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const _TestProps('default'),
        materialIcon: Icons.widgets,
        cupertinoIcon: CupertinoIcons.square_grid_2x2,
      );

      expect(definition, isA<WidgetDefinition<_TestProps>>());
      expect(definition.type, 'test');
      expect(definition.version, '1.0.0');
    });

    test('should provide material and cupertino icons', () {
      final definition = PresentableWidgetDefinition<_TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => _TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const _TestProps('default'),
        materialIcon: Icons.restaurant_menu,
        cupertinoIcon: CupertinoIcons.list_bullet,
      );

      expect(definition.materialIcon, Icons.restaurant_menu);
      expect(definition.cupertinoIcon, CupertinoIcons.list_bullet);
    });

    test('icons default to null when not provided', () {
      final definition = PresentableWidgetDefinition<_TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => _TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const _TestProps('default'),
      );

      expect(definition.materialIcon, isNull);
      expect(definition.cupertinoIcon, isNull);
    });

    test('should support render callback', () {
      final definition = PresentableWidgetDefinition<_TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => _TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const _TestProps('default'),
      );

      const props = _TestProps('hello');
      const widgetContext = WidgetContext(isEditable: false);
      final rendered = definition.render(props, widgetContext);
      expect(rendered, isA<Text>());
    });

    testWidgets('renderDynamic should work with type-erased props', (
      tester,
    ) async {
      final definition = PresentableWidgetDefinition<_TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => _TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const _TestProps('default'),
      );

      const props = _TestProps('dynamic test');
      const widgetContext = WidgetContext(isEditable: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: definition.renderDynamic(props, widgetContext)),
        ),
      );

      expect(find.text('dynamic test'), findsOneWidget);
    });

    test('should support displayName', () {
      final definition = PresentableWidgetDefinition<_TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => _TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const _TestProps('default'),
        displayName: 'Test Widget',
      );

      expect(definition.displayName, 'Test Widget');
    });

    test('should support migrate function', () {
      final definition = PresentableWidgetDefinition<_TestProps>(
        type: 'test',
        version: '2.0.0',
        parseProps: (json) => _TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const _TestProps('default'),
        migrate: (json) => _TestProps('migrated'),
      );

      expect(definition.migrate, isNotNull);
      final migrated = definition.migrate!({'name': 'old'});
      expect(migrated.name, 'migrated');
    });
  });
}
