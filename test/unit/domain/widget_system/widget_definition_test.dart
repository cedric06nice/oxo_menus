import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';

// Mock props class for testing
class TestProps {
  final String name;
  final int value;

  const TestProps({required this.name, required this.value});

  factory TestProps.fromJson(Map<String, dynamic> json) {
    return TestProps(name: json['name'] as String, value: json['value'] as int);
  }

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}

void main() {
  group('WidgetDefinition', () {
    test('should create a widget definition with required fields', () {
      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
      );

      expect(definition.type, 'test');
      expect(definition.version, '1.0.0');
      expect(definition.defaultProps.name, 'default');
      expect(definition.defaultProps.value, 0);
    });

    test('should parse props from JSON', () {
      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
      );

      final json = {'name': 'test', 'value': 42};
      final props = definition.parseProps(json);

      expect(props.name, 'test');
      expect(props.value, 42);
    });

    testWidgets('should render widget with props and context', (tester) async {
      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text('${props.name}: ${props.value}'),
        defaultProps: const TestProps(name: 'default', value: 0),
      );

      const props = TestProps(name: 'test', value: 123);
      const widgetContext = WidgetContext(isEditable: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: definition.render(props, widgetContext)),
        ),
      );

      expect(find.text('test: 123'), findsOneWidget);
    });

    test('should support optional migrate function', () {
      final definitionWithMigration = WidgetDefinition<TestProps>(
        type: 'test',
        version: '2.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
        migrate: (json) {
          // Example migration: add 100 to value
          return TestProps(
            name: json['name'] as String,
            value: (json['value'] as int) + 100,
          );
        },
      );

      expect(definitionWithMigration.migrate, isNotNull);

      final oldProps = {'name': 'test', 'value': 42};
      final migrated = definitionWithMigration.migrate!(oldProps);

      expect(migrated.name, 'test');
      expect(migrated.value, 142);
    });

    test('should work without migration function', () {
      final definitionWithoutMigration = WidgetDefinition<TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
      );

      expect(definitionWithoutMigration.migrate, isNull);
    });

    test('should accept optional displayName, materialIcon, cupertinoIcon', () {
      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
        displayName: 'Test Widget',
        materialIcon: Icons.widgets,
        cupertinoIcon: CupertinoIcons.square_grid_2x2,
      );

      expect(definition.displayName, 'Test Widget');
      expect(definition.materialIcon, Icons.widgets);
      expect(definition.cupertinoIcon, CupertinoIcons.square_grid_2x2);
    });

    test('display metadata defaults to null when not provided', () {
      final definition = WidgetDefinition<TestProps>(
        type: 'test',
        version: '1.0.0',
        parseProps: (json) => TestProps.fromJson(json),
        render: (props, context) => Text(props.name),
        defaultProps: const TestProps(name: 'default', value: 0),
      );

      expect(definition.displayName, isNull);
      expect(definition.materialIcon, isNull);
      expect(definition.cupertinoIcon, isNull);
    });
  });

  group('WidgetContext', () {
    test('should create widget context with required fields', () {
      const context = WidgetContext(isEditable: true);

      expect(context.isEditable, true);
      expect(context.onUpdate, isNull);
      expect(context.onDelete, isNull);
    });

    test('should create widget context with callbacks', () {
      Map<String, dynamic>? capturedUpdate;
      bool deleteCalled = false;

      final context = WidgetContext(
        isEditable: true,
        onUpdate: (props) => capturedUpdate = props,
        onDelete: () => deleteCalled = true,
      );

      expect(context.isEditable, true);
      expect(context.onUpdate, isNotNull);
      expect(context.onDelete, isNotNull);

      // Test callbacks
      context.onUpdate!({'test': 'value'});
      expect(capturedUpdate, {'test': 'value'});

      context.onDelete!();
      expect(deleteCalled, true);
    });

    test('should support non-editable context', () {
      const context = WidgetContext(isEditable: false);

      expect(context.isEditable, false);
      expect(context.onUpdate, isNull);
      expect(context.onDelete, isNull);
    });
  });
}
