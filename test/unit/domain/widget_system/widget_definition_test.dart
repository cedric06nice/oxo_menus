import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';

// ---------------------------------------------------------------------------
// Minimal concrete props type used across all WidgetDefinition tests.
// ---------------------------------------------------------------------------

class _SimpleProps {
  final String label;
  final int count;

  const _SimpleProps({required this.label, required this.count});

  factory _SimpleProps.fromJson(Map<String, dynamic> json) => _SimpleProps(
        label: json['label'] as String,
        count: json['count'] as int,
      );

  Map<String, dynamic> toJson() => {'label': label, 'count': count};

  @override
  bool operator ==(Object other) =>
      other is _SimpleProps && other.label == label && other.count == count;

  @override
  int get hashCode => Object.hash(label, count);
}

void main() {
  // -------------------------------------------------------------------------
  // WidgetDefinition<P>
  // -------------------------------------------------------------------------

  group('WidgetDefinition', () {
    group('construction', () {
      test('should expose type when constructed with required fields', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
        );

        expect(definition.type, equals('simple'));
      });

      test('should expose version when constructed with required fields', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
        );

        expect(definition.version, equals('1.0.0'));
      });

      test('should expose defaultProps when constructed with required fields',
          () {
        const defaults = _SimpleProps(label: 'default', count: 0);
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: defaults,
        );

        expect(definition.defaultProps, equals(defaults));
      });

      test('should expose parseProps function when constructed', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
        );

        expect(definition.parseProps, isNotNull);
      });
    });

    group('parseProps', () {
      test('should return typed props when called with valid JSON map', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
        );

        final result = definition.parseProps({'label': 'hello', 'count': 7});

        expect(result.label, equals('hello'));
        expect(result.count, equals(7));
      });

      test('should parse distinct values independently for each call', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
        );

        final first = definition.parseProps({'label': 'alpha', 'count': 1});
        final second = definition.parseProps({'label': 'beta', 'count': 2});

        expect(first.label, equals('alpha'));
        expect(second.label, equals('beta'));
        expect(first.count, equals(1));
        expect(second.count, equals(2));
      });
    });

    group('migrate', () {
      test('should have null migrate when not provided', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
        );

        expect(definition.migrate, isNull);
      });

      test('should hold migrate function when provided', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '2.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
          migrate: (json) => _SimpleProps(
            label: (json['label'] as String).toUpperCase(),
            count: (json['count'] as int? ?? 0) + 1,
          ),
        );

        expect(definition.migrate, isNotNull);
      });

      test('should apply migration transformation when migrate is called', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '2.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
          migrate: (json) => _SimpleProps(
            label: (json['label'] as String).toUpperCase(),
            count: (json['count'] as int) + 10,
          ),
        );

        final result = definition.migrate!({'label': 'hello', 'count': 5});

        expect(result.label, equals('HELLO'));
        expect(result.count, equals(15));
      });

      test('should receive the exact map passed to migrate', () {
        Map<String, dynamic>? received;
        final input = <String, dynamic>{'label': 'x', 'count': 0};

        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '2.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
          migrate: (json) {
            received = json;
            return const _SimpleProps(label: 'x', count: 0);
          },
        );

        definition.migrate!(input);

        expect(received, same(input));
      });
    });

    group('displayName', () {
      test('should be null when not provided', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
        );

        expect(definition.displayName, isNull);
      });

      test('should expose displayName when provided', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
          displayName: 'Simple Widget',
        );

        expect(definition.displayName, equals('Simple Widget'));
      });

      test('should preserve empty string displayName when explicitly set', () {
        final definition = WidgetDefinition<_SimpleProps>(
          type: 'simple',
          version: '1.0.0',
          parseProps: _SimpleProps.fromJson,
          defaultProps: const _SimpleProps(label: 'default', count: 0),
          displayName: '',
        );

        expect(definition.displayName, equals(''));
      });
    });
  });
}
