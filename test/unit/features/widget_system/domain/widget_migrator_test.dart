import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/widget_system/domain/widget_definition.dart';
import 'package:oxo_menus/features/widget_system/domain/widget_migrator.dart';
import '../../../../fakes/builders/widget_instance_builder.dart';

// ---------------------------------------------------------------------------
// Minimal concrete props type.
//
// Must expose toJson() because WidgetMigrator.migrate calls
// `(migratedProps as dynamic).toJson()` to produce the output map.
// ---------------------------------------------------------------------------

class _MigrProps {
  final String name;
  final int value;

  const _MigrProps({required this.name, required this.value});

  factory _MigrProps.fromJson(Map<String, dynamic> json) => _MigrProps(
    name: json['name'] as String,
    value: json['value'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}

// ---------------------------------------------------------------------------
// Definition helpers
// ---------------------------------------------------------------------------

WidgetDefinition<_MigrProps> _defNoMigrate(String version) =>
    WidgetDefinition<_MigrProps>(
      type: 'test',
      version: version,
      parseProps: _MigrProps.fromJson,
      defaultProps: const _MigrProps(name: 'default', value: 0),
    );

WidgetDefinition<_MigrProps> _defWithMigrate(
  String version,
  _MigrProps Function(Map<String, dynamic>) fn,
) => WidgetDefinition<_MigrProps>(
  type: 'test',
  version: version,
  parseProps: _MigrProps.fromJson,
  defaultProps: const _MigrProps(name: 'default', value: 0),
  migrate: fn,
);

// ---------------------------------------------------------------------------
// WidgetInstance helpers
// ---------------------------------------------------------------------------

WidgetInstance _instanceAt(String version, Map<String, dynamic> props) =>
    buildWidgetInstance(type: 'test', version: version, props: props);

void main() {
  // -------------------------------------------------------------------------
  // WidgetMigrator
  // -------------------------------------------------------------------------

  group('WidgetMigrator', () {
    // -----------------------------------------------------------------------
    // needsMigration
    // -----------------------------------------------------------------------

    group('needsMigration', () {
      test(
        'should return false when instance version equals definition version',
        () {
          final instance = _instanceAt('1.0.0', {'name': 'x', 'value': 1});
          final definition = _defNoMigrate('1.0.0');

          expect(WidgetMigrator.needsMigration(instance, definition), isFalse);
        },
      );

      test(
        'should return true when instance version is older than definition',
        () {
          final instance = _instanceAt('1.0.0', {'name': 'x', 'value': 1});
          final definition = _defNoMigrate('2.0.0');

          expect(WidgetMigrator.needsMigration(instance, definition), isTrue);
        },
      );

      test(
        'should return true when instance version is newer than definition',
        () {
          final instance = _instanceAt('3.0.0', {'name': 'x', 'value': 1});
          final definition = _defNoMigrate('2.0.0');

          expect(WidgetMigrator.needsMigration(instance, definition), isTrue);
        },
      );

      test(
        'should return false when both instance and definition are at version 1',
        () {
          final instance = _instanceAt('1', {});
          final definition = _defNoMigrate('1');

          expect(WidgetMigrator.needsMigration(instance, definition), isFalse);
        },
      );

      test(
        'should return true when instance has empty version and definition has non-empty version',
        () {
          final instance = _instanceAt('', {'name': 'x', 'value': 0});
          final definition = _defNoMigrate('1.0.0');

          expect(WidgetMigrator.needsMigration(instance, definition), isTrue);
        },
      );
    });

    // -----------------------------------------------------------------------
    // migrate — no migration function
    // -----------------------------------------------------------------------

    group('migrate when no migrate function is defined', () {
      test(
        'should return original props map when definition has no migrate fn',
        () {
          final props = <String, dynamic>{'name': 'dish', 'value': 5};
          final instance = _instanceAt('1.0.0', props);
          final definition = _defNoMigrate('2.0.0');

          final result = WidgetMigrator.migrate(instance, definition);

          expect(result, equals(props));
        },
      );

      test(
        'should return map equal to original props when definition has no migrate fn',
        () {
          final props = <String, dynamic>{'name': 'dish', 'value': 5};
          final instance = _instanceAt('1.0.0', props);
          final definition = _defNoMigrate('2.0.0');

          final result = WidgetMigrator.migrate(instance, definition);

          expect(result, equals(props));
        },
      );

      test(
        'should return empty map unchanged when instance props are empty and no migrate fn',
        () {
          final instance = _instanceAt('1.0.0', {});
          final definition = _defNoMigrate('2.0.0');

          final result = WidgetMigrator.migrate(instance, definition);

          expect(result, isEmpty);
        },
      );
    });

    // -----------------------------------------------------------------------
    // migrate — with migration function
    // -----------------------------------------------------------------------

    group('migrate when migrate function is defined', () {
      test(
        'should apply migration and return toJson output of migrated props',
        () {
          final instance = _instanceAt('1.0.0', {'name': 'soup', 'value': 10});
          final definition = _defWithMigrate('2.0.0', (json) {
            return _MigrProps(
              name: (json['name'] as String).toUpperCase(),
              value: (json['value'] as int) + 100,
            );
          });

          final result = WidgetMigrator.migrate(instance, definition);

          expect(result['name'], equals('SOUP'));
          expect(result['value'], equals(110));
        },
      );

      test('should pass the instance props map to the migrate function', () {
        Map<String, dynamic>? received;
        final props = <String, dynamic>{'name': 'test', 'value': 7};
        final instance = _instanceAt('1.0.0', props);
        final definition = _defWithMigrate('2.0.0', (json) {
          received = json;
          return const _MigrProps(name: 'test', value: 7);
        });

        WidgetMigrator.migrate(instance, definition);

        expect(received, equals(props));
      });

      test(
        'should preserve fields present in migrated props in the returned map',
        () {
          final instance = _instanceAt('1.0.0', {'name': 'wine', 'value': 20});
          final definition = _defWithMigrate('2.0.0', (json) {
            return const _MigrProps(name: 'wine', value: 20);
          });

          final result = WidgetMigrator.migrate(instance, definition);

          expect(result.containsKey('name'), isTrue);
          expect(result.containsKey('value'), isTrue);
        },
      );
    });

    // -----------------------------------------------------------------------
    // migrate — migration function throws
    // -----------------------------------------------------------------------

    group('migrate when migrate function throws', () {
      test('should return original props when migrate function throws', () {
        final props = <String, dynamic>{'name': 'salad', 'value': 3};
        final instance = _instanceAt('1.0.0', props);
        final definition = _defWithMigrate('2.0.0', (_) {
          throw Exception('migration error');
        });

        final result = WidgetMigrator.migrate(instance, definition);

        expect(result, equals(props));
      });

      test(
        'should return map equal to original props when migrate function throws',
        () {
          final props = <String, dynamic>{'name': 'salad', 'value': 3};
          final instance = _instanceAt('1.0.0', props);
          final definition = _defWithMigrate('2.0.0', (_) {
            throw StateError('bad state');
          });

          final result = WidgetMigrator.migrate(instance, definition);

          expect(result, equals(props));
        },
      );

      test('should preserve all original fields when migration throws', () {
        final props = <String, dynamic>{
          'name': 'steak',
          'value': 42,
          'extra': 'data',
        };
        final instance = _instanceAt('1.0.0', props);
        final definition = _defWithMigrate('2.0.0', (_) {
          throw Exception('unexpected');
        });

        final result = WidgetMigrator.migrate(instance, definition);

        expect(result['name'], equals('steak'));
        expect(result['value'], equals(42));
        expect(result['extra'], equals('data'));
      });
    });

    // -----------------------------------------------------------------------
    // migrate — versions are identical (current, no migration needed)
    // -----------------------------------------------------------------------

    group('migrate when versions are the same', () {
      test(
        'should return props unchanged via migrate fn path when versions match and migrate fn exists',
        () {
          // The migrator doesn't guard on version equality — it always calls
          // migrate if the function is present.  This test documents that
          // calling migrate with equal versions still goes through the fn.
          final props = <String, dynamic>{'name': 'bread', 'value': 1};
          final instance = _instanceAt('1.0.0', props);
          final definition = _defWithMigrate('1.0.0', (json) {
            return _MigrProps.fromJson(json);
          });

          final result = WidgetMigrator.migrate(instance, definition);

          expect(result['name'], equals('bread'));
          expect(result['value'], equals(1));
        },
      );
    });
  });
}
