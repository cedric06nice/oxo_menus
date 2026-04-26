import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widget_system/widget_registry.dart';

// ---------------------------------------------------------------------------
// Minimal props type for registry tests.
// ---------------------------------------------------------------------------

class _RegProps {
  final String value;
  const _RegProps(this.value);

  factory _RegProps.fromJson(Map<String, dynamic> json) =>
      _RegProps(json['value'] as String);

  Map<String, dynamic> toJson() => {'value': value};
}

// Helper that builds a WidgetDefinition for a given type identifier.
WidgetDefinition<_RegProps> _def(String type, {String version = '1.0.0'}) =>
    WidgetDefinition<_RegProps>(
      type: type,
      version: version,
      parseProps: _RegProps.fromJson,
      defaultProps: const _RegProps('default'),
    );

void main() {
  // -------------------------------------------------------------------------
  // WidgetRegistry
  // -------------------------------------------------------------------------

  group('WidgetRegistry', () {
    late WidgetRegistry registry;

    setUp(() {
      registry = WidgetRegistry();
    });

    group('empty registry', () {
      test('should have count zero when no definitions are registered', () {
        expect(registry.count, equals(0));
      });

      test('should have empty registeredTypes when no definitions are registered',
          () {
        expect(registry.registeredTypes, isEmpty);
      });

      test('should return null when looking up a type in an empty registry', () {
        expect(registry.getDefinition('anything'), isNull);
      });

      test('should return false for isRegistered when registry is empty', () {
        expect(registry.isRegistered('anything'), isFalse);
      });
    });

    group('register and lookup', () {
      test('should increment count by one after a single registration', () {
        registry.register(_def('dish'));

        expect(registry.count, equals(1));
      });

      test('should return the registered definition when looked up by type', () {
        registry.register(_def('dish'));

        final result = registry.getDefinition('dish');

        expect(result, isNotNull);
        expect(result!.type, equals('dish'));
      });

      test('should return true for isRegistered after registration', () {
        registry.register(_def('section'));

        expect(registry.isRegistered('section'), isTrue);
      });

      test('should include the type in registeredTypes after registration', () {
        registry.register(_def('wine'));

        expect(registry.registeredTypes, contains('wine'));
      });

      test(
          'should return null for getDefinition when type has not been registered',
          () {
        registry.register(_def('dish'));

        expect(registry.getDefinition('unknown'), isNull);
      });

      test('should return false for isRegistered when type was not registered',
          () {
        registry.register(_def('dish'));

        expect(registry.isRegistered('unknown'), isFalse);
      });
    });

    group('multiple registrations', () {
      test('should count all distinct types registered', () {
        registry.register(_def('dish'));
        registry.register(_def('section'));
        registry.register(_def('wine'));

        expect(registry.count, equals(3));
      });

      test('should list all registered types', () {
        registry.register(_def('dish'));
        registry.register(_def('section'));
        registry.register(_def('wine'));

        final types = registry.registeredTypes;

        expect(types, containsAll(['dish', 'section', 'wine']));
        expect(types, hasLength(3));
      });

      test('should find each type independently after multiple registrations',
          () {
        registry.register(_def('dish'));
        registry.register(_def('section'));

        expect(registry.getDefinition('dish'), isNotNull);
        expect(registry.getDefinition('section'), isNotNull);
      });
    });

    group('double registration (overwrite semantics)', () {
      test('should not increase count when same type is registered twice', () {
        registry.register(_def('dish', version: '1.0.0'));
        registry.register(_def('dish', version: '2.0.0'));

        expect(registry.count, equals(1));
      });

      test('should return latest version after re-registering same type', () {
        registry.register(_def('dish', version: '1.0.0'));
        registry.register(_def('dish', version: '2.0.0'));

        final result = registry.getDefinition('dish');

        expect(result!.version, equals('2.0.0'));
      });

      test(
          'should list type only once in registeredTypes after double registration',
          () {
        registry.register(_def('dish', version: '1.0.0'));
        registry.register(_def('dish', version: '2.0.0'));

        expect(
          registry.registeredTypes.where((t) => t == 'dish').length,
          equals(1),
        );
      });
    });

    group('registeredTypes enumeration', () {
      test('should return a list of length equal to count', () {
        registry.register(_def('a'));
        registry.register(_def('b'));
        registry.register(_def('c'));

        expect(registry.registeredTypes.length, equals(registry.count));
      });

      test(
          'should not contain types that were never registered after several registrations',
          () {
        registry.register(_def('dish'));
        registry.register(_def('section'));

        expect(registry.registeredTypes, isNot(contains('wine')));
      });
    });
  });
}
