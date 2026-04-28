import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';

void main() {
  group('WidgetTypeConfig', () {
    group('construction', () {
      test(
        'should create config with correct type when only type is provided',
        () {
          // Arrange & Act
          const config = WidgetTypeConfig(type: 'dish');

          // Assert
          expect(config.type, 'dish');
        },
      );

      test(
        'should default alignment to WidgetAlignment.start when not specified',
        () {
          // Arrange & Act
          const config = WidgetTypeConfig(type: 'dish');

          // Assert
          expect(config.alignment, WidgetAlignment.start);
        },
      );

      test('should default enabled to true when not specified', () {
        // Arrange & Act
        const config = WidgetTypeConfig(type: 'dish');

        // Assert
        expect(config.enabled, isTrue);
      });

      test(
        'should store the specified alignment when alignment is provided',
        () {
          // Arrange & Act
          const config = WidgetTypeConfig(
            type: 'dish',
            alignment: WidgetAlignment.justified,
          );

          // Assert
          expect(config.alignment, WidgetAlignment.justified);
        },
      );

      test('should store alignment center when alignment is center', () {
        // Arrange & Act
        const config = WidgetTypeConfig(
          type: 'wine',
          alignment: WidgetAlignment.center,
        );

        // Assert
        expect(config.alignment, WidgetAlignment.center);
      });

      test('should store alignment end when alignment is end', () {
        // Arrange & Act
        const config = WidgetTypeConfig(
          type: 'wine',
          alignment: WidgetAlignment.end,
        );

        // Assert
        expect(config.alignment, WidgetAlignment.end);
      });

      test(
        'should store enabled false when enabled is explicitly set to false',
        () {
          // Arrange & Act
          const config = WidgetTypeConfig(type: 'section', enabled: false);

          // Assert
          expect(config.enabled, isFalse);
        },
      );
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = WidgetTypeConfig(
          type: 'dish',
          alignment: WidgetAlignment.start,
          enabled: true,
        );
        const b = WidgetTypeConfig(
          type: 'dish',
          alignment: WidgetAlignment.start,
          enabled: true,
        );

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = WidgetTypeConfig(type: 'text');
        const b = WidgetTypeConfig(type: 'text');

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when type differs', () {
        // Arrange
        const a = WidgetTypeConfig(type: 'dish');
        const b = WidgetTypeConfig(type: 'text');

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when alignment differs', () {
        // Arrange
        const a = WidgetTypeConfig(
          type: 'dish',
          alignment: WidgetAlignment.start,
        );
        const b = WidgetTypeConfig(
          type: 'dish',
          alignment: WidgetAlignment.center,
        );

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when enabled differs', () {
        // Arrange
        const a = WidgetTypeConfig(type: 'dish', enabled: true);
        const b = WidgetTypeConfig(type: 'dish', enabled: false);

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test(
        'should update alignment when copyWith is called with a new alignment',
        () {
          // Arrange
          const config = WidgetTypeConfig(
            type: 'dish',
            alignment: WidgetAlignment.start,
          );

          // Act
          final updated = config.copyWith(alignment: WidgetAlignment.justified);

          // Assert
          expect(updated.alignment, WidgetAlignment.justified);
          expect(updated.type, 'dish');
        },
      );

      test(
        'should update enabled to false when copyWith is called with false',
        () {
          // Arrange
          const config = WidgetTypeConfig(type: 'dish', enabled: true);

          // Act
          final updated = config.copyWith(enabled: false);

          // Assert
          expect(updated.enabled, isFalse);
          expect(updated.type, 'dish');
        },
      );

      test(
        'should preserve all fields when copyWith is called with no arguments',
        () {
          // Arrange
          const config = WidgetTypeConfig(
            type: 'section',
            alignment: WidgetAlignment.center,
            enabled: false,
          );

          // Act
          final copy = config.copyWith();

          // Assert
          expect(copy, equals(config));
        },
      );
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const config = WidgetTypeConfig(type: 'dish');

        // Act
        final result = config.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('JSON serialization', () {
      test('should serialize type and alignment to JSON', () {
        // Arrange
        const config = WidgetTypeConfig(
          type: 'dish',
          alignment: WidgetAlignment.justified,
        );

        // Act
        final json = config.toJson();

        // Assert
        expect(json['type'], 'dish');
        expect(json['alignment'], 'justified');
      });

      test('should serialize enabled to JSON', () {
        // Arrange
        const config = WidgetTypeConfig(type: 'dish', enabled: false);

        // Act
        final json = config.toJson();

        // Assert
        expect(json['enabled'], isFalse);
      });

      test(
        'should deserialize WidgetTypeConfig from JSON with correct field values',
        () {
          // Arrange
          final json = {'type': 'dish', 'alignment': 'center', 'enabled': true};

          // Act
          final config = WidgetTypeConfig.fromJson(json);

          // Assert
          expect(config.type, 'dish');
          expect(config.alignment, WidgetAlignment.center);
          expect(config.enabled, isTrue);
        },
      );

      test(
        'should default alignment to start when alignment is absent from JSON',
        () {
          // Arrange
          final json = {'type': 'dish'};

          // Act
          final config = WidgetTypeConfig.fromJson(json);

          // Assert
          expect(config.alignment, WidgetAlignment.start);
        },
      );

      test(
        'should default enabled to true when enabled is absent from JSON',
        () {
          // Arrange
          final json = {'type': 'dish'};

          // Act
          final config = WidgetTypeConfig.fromJson(json);

          // Assert
          expect(config.enabled, isTrue);
        },
      );

      test('should round-trip justified alignment through JSON', () {
        // Arrange
        const original = WidgetTypeConfig(
          type: 'dish',
          alignment: WidgetAlignment.justified,
        );

        // Act
        final restored = WidgetTypeConfig.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });

      test('should round-trip center alignment through JSON', () {
        // Arrange
        const original = WidgetTypeConfig(
          type: 'wine',
          alignment: WidgetAlignment.center,
        );

        // Act
        final restored = WidgetTypeConfig.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });

      test('should round-trip end alignment through JSON', () {
        // Arrange
        const original = WidgetTypeConfig(
          type: 'wine',
          alignment: WidgetAlignment.end,
        );

        // Act
        final restored = WidgetTypeConfig.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });

      test('should round-trip enabled false through JSON', () {
        // Arrange
        const original = WidgetTypeConfig(
          type: 'dish',
          alignment: WidgetAlignment.center,
          enabled: false,
        );

        // Act
        final restored = WidgetTypeConfig.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });
  });
}
