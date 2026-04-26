import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import '../../../fakes/builders/widget_instance_builder.dart';

void main() {
  group('WidgetInstance', () {
    group('construction', () {
      test(
        'should create widget instance with correct required fields when all required fields are provided',
        () {
          // Arrange & Act
          const instance = WidgetInstance(
            id: 1,
            columnId: 2,
            type: 'dish',
            version: '1.0.0',
            index: 0,
            props: {},
          );

          // Assert
          expect(instance.id, 1);
          expect(instance.columnId, 2);
          expect(instance.type, 'dish');
          expect(instance.version, '1.0.0');
          expect(instance.index, 0);
          expect(instance.props, isEmpty);
        },
      );

      test('should default isTemplate to false when not specified', () {
        // Arrange & Act
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(instance.isTemplate, isFalse);
      });

      test('should default lockedForEdition to false when not specified', () {
        // Arrange & Act
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(instance.lockedForEdition, isFalse);
      });

      test('should default style to null when not specified', () {
        // Arrange & Act
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(instance.style, isNull);
      });

      test('should default dateCreated to null when not specified', () {
        // Arrange & Act
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(instance.dateCreated, isNull);
      });

      test('should default dateUpdated to null when not specified', () {
        // Arrange & Act
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(instance.dateUpdated, isNull);
      });

      test(
        'should store isTemplate true when isTemplate is explicitly set to true',
        () {
          // Arrange & Act
          const instance = WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'text',
            version: '1',
            index: 0,
            props: {},
            isTemplate: true,
          );

          // Assert
          expect(instance.isTemplate, isTrue);
        },
      );

      test(
        'should store lockedForEdition true when lockedForEdition is explicitly set to true',
        () {
          // Arrange & Act
          const instance = WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'dish',
            version: '1',
            index: 0,
            props: {},
            lockedForEdition: true,
          );

          // Assert
          expect(instance.lockedForEdition, isTrue);
        },
      );

      test('should store props map when props contain key-value pairs', () {
        // Arrange & Act
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {'name': 'Soup', 'price': 5.50},
        );

        // Assert
        expect(instance.props['name'], 'Soup');
        expect(instance.props['price'], 5.50);
      });

      test('should store style when a WidgetStyle is provided', () {
        // Arrange
        const style = WidgetStyle(fontFamily: 'Arial', fontSize: 14.0);

        // Act
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
          style: style,
        );

        // Assert
        expect(instance.style, isNotNull);
        expect(instance.style!.fontFamily, 'Arial');
      });

      test('should store all fields when fully specified', () {
        // Arrange
        final created = DateTime(2024, 1, 10);
        final updated = DateTime(2024, 1, 20);

        // Act
        final instance = WidgetInstance(
          id: 5,
          columnId: 3,
          type: 'wine',
          version: '2',
          index: 4,
          props: {'label': 'Bordeaux'},
          isTemplate: true,
          lockedForEdition: true,
          dateCreated: created,
          dateUpdated: updated,
        );

        // Assert
        expect(instance.id, 5);
        expect(instance.columnId, 3);
        expect(instance.type, 'wine');
        expect(instance.version, '2');
        expect(instance.index, 4);
        expect(instance.isTemplate, isTrue);
        expect(instance.lockedForEdition, isTrue);
        expect(instance.dateCreated, created);
        expect(instance.dateUpdated, updated);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );
        const b = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );
        const b = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );
        const b = WidgetInstance(
          id: 2,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when type differs', () {
        // Arrange
        const a = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
        );
        const b = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test(
        'should update isTemplate to true when copyWith is called with isTemplate true',
        () {
          // Arrange
          const instance = WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'text',
            version: '1',
            index: 0,
            props: {},
          );

          // Act
          final updated = instance.copyWith(isTemplate: true);

          // Assert
          expect(updated.isTemplate, isTrue);
        },
      );

      test(
        'should preserve id when only isTemplate is updated via copyWith',
        () {
          // Arrange
          const instance = WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'text',
            version: '1',
            index: 0,
            props: {},
          );

          // Act
          final updated = instance.copyWith(isTemplate: true);

          // Assert
          expect(updated.id, 1);
          expect(updated.type, 'text');
        },
      );

      test('should update type when copyWith is called with a new type', () {
        // Arrange
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'dish',
          version: '1',
          index: 0,
          props: {},
        );

        // Act
        final updated = instance.copyWith(type: 'wine');

        // Assert
        expect(updated.type, 'wine');
      });

      test(
        'should update props when copyWith is called with a new props map',
        () {
          // Arrange
          const instance = WidgetInstance(
            id: 1,
            columnId: 1,
            type: 'dish',
            version: '1',
            index: 0,
            props: {'name': 'Old'},
          );

          // Act
          final updated = instance.copyWith(
            props: {'name': 'New', 'price': 12.0},
          );

          // Assert
          expect(updated.props['name'], 'New');
          expect(updated.props['price'], 12.0);
        },
      );

      test('should update index when copyWith is called with a new index', () {
        // Arrange
        final instance = buildWidgetInstance(index: 0);

        // Act
        final updated = instance.copyWith(index: 5);

        // Assert
        expect(updated.index, 5);
      });

      test(
        'should update lockedForEdition when copyWith is called with true',
        () {
          // Arrange
          final instance = buildWidgetInstance(lockedForEdition: false);

          // Act
          final updated = instance.copyWith(lockedForEdition: true);

          // Assert
          expect(updated.lockedForEdition, isTrue);
        },
      );

      test(
        'should preserve all fields when copyWith is called with no arguments',
        () {
          // Arrange
          final instance = buildWidgetInstance(type: 'section', index: 2);

          // Act
          final copy = instance.copyWith();

          // Assert
          expect(copy, equals(instance));
        },
      );
    });

    group('JSON serialization', () {
      test('should serialize required fields to JSON', () {
        // Arrange
        const instance = WidgetInstance(
          id: 1,
          columnId: 2,
          type: 'dish',
          version: '1.0.0',
          index: 0,
          props: {},
        );

        // Act
        final json = instance.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['columnId'], 2);
        expect(json['type'], 'dish');
        expect(json['version'], '1.0.0');
        expect(json['index'], 0);
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        final instance = buildWidgetInstance(
          id: 9,
          columnId: 3,
          type: 'text',
          version: '2',
          index: 1,
          props: {'content': 'Hello'},
        );

        // Act
        final restored = WidgetInstance.fromJson(instance.toJson());

        // Assert
        expect(restored, equals(instance));
      });
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const instance = WidgetInstance(
          id: 1,
          columnId: 1,
          type: 'text',
          version: '1',
          index: 0,
          props: {},
        );

        // Act
        final result = instance.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });
  });

  group('WidgetStyle', () {
    group('construction', () {
      test('should create WidgetStyle with all fields null by default', () {
        // Arrange & Act
        const style = WidgetStyle();

        // Assert
        expect(style.fontFamily, isNull);
        expect(style.fontSize, isNull);
        expect(style.color, isNull);
        expect(style.backgroundColor, isNull);
        expect(style.border, isNull);
        expect(style.padding, isNull);
      });

      test('should store all fields when fully specified', () {
        // Arrange & Act
        const style = WidgetStyle(
          fontFamily: 'Georgia',
          fontSize: 16.0,
          color: '#333333',
          backgroundColor: '#FFFFFF',
          border: '1px solid black',
          padding: 8.0,
        );

        // Assert
        expect(style.fontFamily, 'Georgia');
        expect(style.fontSize, 16.0);
        expect(style.color, '#333333');
        expect(style.backgroundColor, '#FFFFFF');
        expect(style.border, '1px solid black');
        expect(style.padding, 8.0);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = WidgetStyle(fontFamily: 'Arial', fontSize: 14.0);
        const b = WidgetStyle(fontFamily: 'Arial', fontSize: 14.0);

        // Assert
        expect(a, equals(b));
      });

      test('should not be equal when fontFamily differs', () {
        // Arrange
        const a = WidgetStyle(fontFamily: 'Arial');
        const b = WidgetStyle(fontFamily: 'Helvetica');

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test(
        'should update fontSize when copyWith is called with a new fontSize',
        () {
          // Arrange
          const style = WidgetStyle(fontFamily: 'Arial', fontSize: 14.0);

          // Act
          final updated = style.copyWith(fontSize: 18.0);

          // Assert
          expect(updated.fontSize, 18.0);
          expect(updated.fontFamily, 'Arial');
        },
      );
    });

    group('JSON serialization', () {
      test('should round-trip through JSON preserving equality', () {
        // Arrange
        final style = buildWidgetStyle(
          fontFamily: 'Georgia',
          fontSize: 12.0,
          color: '#000',
          padding: 4.0,
        );

        // Act
        final restored = WidgetStyle.fromJson(style.toJson());

        // Assert
        expect(restored, equals(style));
      });
    });
  });
}
